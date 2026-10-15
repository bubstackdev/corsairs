#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdatomic.h>
#define SWIFT __attribute__((swiftcall))
#define ASYNC __attribute__((swiftasynccall))
#define CTX __attribute__((swift_async_context))
#define SELF __attribute__((swift_context))
typedef struct { void *task, *context; } TaskPair;
typedef TaskPair SWIFT CreateTask(size_t, void *, void *, void *, void *);
typedef void SWIFT RunJob(void *, uintptr_t, uintptr_t);
typedef void *SWIFT CurrentTask(void);
typedef void *SWIFT AllocTask(size_t);
typedef void SWIFT DeallocTask(void *);
typedef void *RetainTask(void *);
typedef void ReleaseTask(void *);
typedef void ASYNC Completion(void *CTX, void *SELF);
typedef void ASYNC Yield(void *CTX);
typedef struct State {
  pthread_mutex_t mutex;
  pthread_cond_t condition;
  int done, entries, resumes, identity_matches, completion_tls_clear;
  void *expected_task;
  pthread_t entry_thread, resume_thread;
  _Atomic int references;
} State;
typedef struct Root {
  void *parent;
  Completion *resume;
  void *child;
  Completion *native_completion;
  State *state;
  uintptr_t reserved[3];
} Root;
_Static_assert(sizeof(Root) == 64, "root frame");
static AllocTask *task_alloc;
static DeallocTask *task_dealloc;
static CurrentTask *current_task;
static Yield *yield_entry;
static uint32_t yield_context_size;
static void ASYNC yield_resume(void *CTX child);
static void release_state(State *state) {
  if (atomic_fetch_sub_explicit(&state->references,1,memory_order_acq_rel) == 1) {
    pthread_cond_destroy(&state->condition);
    pthread_mutex_destroy(&state->mutex);
    free(state);
  }
}
static void signal_completed(State *state) {
  int clear = current_task() == NULL;
  pthread_mutex_lock(&state->mutex);
  state->completion_tls_clear = clear;
  state->done = 1;
  pthread_cond_signal(&state->condition);
  pthread_mutex_unlock(&state->mutex);
  // Release the callback's own reference after the unlock returned.
  release_state(state);
}
static void ASYNC completion_wrapper(void *CTX context, void *SELF error) {
  Root *root = context;
  Completion *native_completion = root->native_completion;
  State *owned_state = root->state;
  native_completion(context, error);
  signal_completed(owned_state);
}
void ASYNC oracle_entry(void *result, void *CTX context, void *SELF capture) {
  (void)result; (void)capture;
  Root *root = context;
  State *state = root->state;
  state->entries++;
  state->identity_matches += current_task() == state->expected_task;
  state->entry_thread = pthread_self();
  void **child = task_alloc(yield_context_size);
  root->child = child;
  child[0] = root;
  child[1] = (void *)yield_resume;
  yield_entry(child);
}
static void ASYNC yield_resume(void *CTX child) {
  Root *root = *(Root **)child;
  State *state = root->state;
  state->resumes++;
  state->identity_matches += current_task() == state->expected_task;
  state->resume_thread = pthread_self();
  task_dealloc(child);
  root->resume(root, NULL);
}
__asm__(".section __TEXT,__const\n"
        ".p2align 3\n"
        "_oracle_descriptor:\n"
        ".long _oracle_entry - _oracle_descriptor\n"
        ".long 64\n");
extern char oracle_descriptor;
static void *symbol(void *handle, const char *name) {
  void *value = dlsym(handle, name);
  if (!value) { fprintf(stderr, "missing %s: %s\n", name, dlerror()); exit(2); }
  return value;
}
int main(void) {
  void *concurrency = dlopen("/usr/lib/swift/libswift_Concurrency.dylib", RTLD_NOW|RTLD_LOCAL);
  void *core = dlopen("/usr/lib/swift/libswiftCore.dylib", RTLD_NOW|RTLD_LOCAL);
  if (!concurrency || !core) { fprintf(stderr,"dlopen: %s\n",dlerror());return 2; }
  CreateTask *create = symbol(concurrency,"swift_task_create");
  RunJob *run = symbol(concurrency,"swift_job_run");
  current_task = symbol(concurrency,"swift_task_getCurrent");
  task_alloc = symbol(concurrency,"swift_task_alloc");
  task_dealloc = symbol(concurrency,"swift_task_dealloc");
  RetainTask *retain_task = symbol(core,"swift_retain");
  ReleaseTask *release_task = symbol(core,"swift_release");
  char *void_metadata = (char *)symbol(core,"$sytN") + 8;
  char *yield_descriptor = symbol(concurrency,"$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu");
  int32_t relative_entry;
  memcpy(&relative_entry, yield_descriptor, sizeof(relative_entry));
  memcpy(&yield_context_size, yield_descriptor+4, sizeof(yield_context_size));
  yield_entry = (Yield *)((uintptr_t)yield_descriptor + (uintptr_t)(intptr_t)relative_entry);
  if (yield_context_size < 16 || yield_context_size > 1048576 || current_task()) return 3;
  State *state = calloc(1,sizeof(*state));
  atomic_init(&state->references,2); // Caller and completion callback own separate +1s.
  pthread_mutex_init(&state->mutex,NULL);
  pthread_cond_init(&state->condition,NULL);
  TaskPair pair = create(0,NULL,void_metadata,&oracle_descriptor,NULL);
  if (!pair.task || !pair.context) abort();
  Root *root = pair.context;
  state->expected_task = pair.task;
  root->native_completion = root->resume;
  root->state = state;
  root->resume = completion_wrapper;
  retain_task(pair.task);
  run(pair.task,0,0);
  int caller_tls_clear = current_task() == NULL;
  pthread_mutex_lock(&state->mutex);
  while (!state->done) pthread_cond_wait(&state->condition,&state->mutex);
  pthread_mutex_unlock(&state->mutex);
  int changed_thread = !pthread_equal(state->entry_thread,state->resume_thread);
  int ok = state->entries == 1 && state->resumes == 1 && state->identity_matches == 2
      && state->completion_tls_clear && caller_tls_clear;
  printf("ok=%d entries=%d resumes=%d identity_matches=%d completion_tls_clear=%d caller_tls_clear=%d changed_thread=%d yield_context_size=%u\n", ok,state->entries,state->resumes,state->identity_matches,state->completion_tls_clear,caller_tls_clear,changed_thread,yield_context_size);
  release_task(pair.task);
  release_state(state);
  // Handles intentionally remain open until process exit; executor epilogue can still run.
  return !ok;
}
