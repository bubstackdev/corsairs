#define ASYNC __attribute__((swiftasynccall))
#define CTX __attribute__((swift_async_context))
#define SELF __attribute__((swift_context))
typedef void ASYNC AsyncCompletion(void *CTX, void *SELF);
extern void signal_after_native_completion(void *);
void ASYNC wrapCompletion(void *CTX context, void *SELF error) {
  AsyncCompletion *complete = ((AsyncCompletion **)context)[2];
  void *owned_state = ((void **)context)[3];
  complete(context, error);
  signal_after_native_completion(owned_state);
}
