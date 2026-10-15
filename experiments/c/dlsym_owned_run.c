// Standalone lookup-cost experiment. It never calls any resolved symbol.
// Run only after coordinated GPU timings. Production source is untouched.
#include <dlfcn.h>
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

_Static_assert(RTLD_NOW == 2 && RTLD_LOCAL == 4, "Darwin production flags differ");
static const char *const symbols[] = {
    "$s13CoreAIRuntime7NDArrayVMa",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC",
    "$sSiN",
    "$sSaMa",
    "swift_bridgeObjectRelease",
    "$sSayxSiciM",
    "$sSa9repeating5countSayxGx_SitcfC",
    "$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC",
    "$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa",
    "$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF",
    "$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF",
    "$s13CoreAIRuntime7NDArrayV14MutableRawViewV16storageByteCountSiyF",
    "$s13CoreAIRuntime17InferenceFunctionV6InputsVMa",
    "$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC",
    "$s13CoreAIRuntime7NDArrayV7RawViewVMa",
    "$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF",
    "$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF",
    "$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa",
    "$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
    "$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
    "$s13CoreAIRuntime17InferenceFunctionV7OutputsVMa",
    "swift_task_create",
    "swift_job_run",
    "swift_task_getCurrent",
    "swift_task_alloc",
    "swift_task_dealloc",
    "swift_retain",
    "swift_release",
    "swift_errorRelease",
    "$sytN",
    "$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu",
    "$s13CoreAIRuntime14InferenceValueVMa",
    "$sSqMa",
    "$s13CoreAIRuntime7NDArrayVMa",
    "$sSqMa",
    "$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF",
    "$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg",
    "$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg",
    "swift_bridgeObjectRelease",
    "$sSiN",
    "$sSa5countSivg",
    "$sSayxSicig",
    "$sSayxSicig",
    "$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg",
    "swift_bridgeObjectRelease",
    "$sSiN",
    "$sSa5countSivg",
    "$sSayxSicig",
    "$sSayxSicig",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa",
    "$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float16yA2EmFWC",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC",
    "$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC",
    "$s13CoreAIRuntime7NDArrayV7RawViewVMa",
    "$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF",
    "$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg",
    "$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg",
};
enum { LOOKUPS = sizeof(symbols) / sizeof(symbols[0]), WARMUP = 1000 };
_Static_assert(LOOKUPS == 59, "owned success-path lookup ledger changed");
static void *volatile cached[LOOKUPS];
static volatile uintptr_t sink;

static uint64_t now_ns(void) {
    struct timespec t;
    if (clock_gettime(CLOCK_MONOTONIC_RAW, &t) != 0) {
        perror("clock_gettime");
        exit(2);
    }
    return (uint64_t)t.tv_sec * UINT64_C(1000000000) + (uint64_t)t.tv_nsec;
}
static int lookup_batches(void *library, uint64_t iterations) {
    uintptr_t value = 0;
    for (uint64_t n = 0; n < iterations; ++n) {
        for (size_t i = 0; i < LOOKUPS; ++i) {
            void *pointer = dlsym(library, symbols[i]);
            if (pointer == NULL || pointer != cached[i]) {
                fprintf(stderr, "lookup changed or failed at %zu: %s\n", i, symbols[i]);
                return 0;
            }
            value ^= (uintptr_t)pointer + i;
        }
    }
    sink = value;
    return 1;
}
static void cached_batches(uint64_t iterations) {
    uintptr_t value = 0;
    for (uint64_t n = 0; n < iterations; ++n) {
        for (size_t i = 0; i < LOOKUPS; ++i) {
            // Volatile pointer-table reads prevent the compiler folding this loop.
            value ^= (uintptr_t)cached[i] + i;
        }
    }
    sink = value;
}
int main(int argc, char **argv) {
    uint64_t iterations = 100000;
    if (argc > 2) {
        fprintf(stderr, "usage: %s [iterations:1..100000000]\n", argv[0]);
        return 2;
    }
    if (argc == 2) {
        char *end = NULL;
        errno = 0;
        unsigned long long parsed = strtoull(argv[1], &end, 10);
        if (errno || end == argv[1] || *end || parsed == 0 || parsed > 100000000) {
            fprintf(stderr, "invalid iteration count\n");
            return 2;
        }
        iterations = (uint64_t)parsed;
    }
    const char *path = "/System/Library/Frameworks/CoreAI.framework/Versions/A/CoreAI";
    void *library = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!library) {
        fprintf(stderr, "dlopen: %s\n", dlerror());
        return 2;
    }
    for (size_t i = 0; i < LOOKUPS; ++i) {
        cached[i] = dlsym(library, symbols[i]);
        if (!cached[i]) {
            fprintf(stderr, "initial dlsym: %s: %s\n", symbols[i], dlerror());
            dlclose(library);
            return 2;
        }
    }
    if (!lookup_batches(library, WARMUP)) {
        dlclose(library);
        return 2;
    }
    cached_batches(WARMUP);
    uint64_t start = now_ns();
    cached_batches(iterations);
    uint64_t cached_ns = now_ns() - start;
    start = now_ns();
    if (!lookup_batches(library, iterations)) {
        dlclose(library);
        return 2;
    }
    uint64_t lookup_ns = now_ns() - start;
    double calls = (double)iterations * LOOKUPS;
    int closed = dlclose(library) == 0;
    printf("{\"schema\":1,\"passed\":%s,\"native_symbols_called\":false,"
           "\"library_path\":\"%s\",\"dlopen_flags\":6,"
           "\"clock\":\"CLOCK_MONOTONIC_RAW\",\"iterations\":%" PRIu64 ","
           "\"warmup_iterations\":%u,\"lookups_per_iteration\":%u,"
           "\"all_addresses_equal_initial\":true,\"lookup_total_ns\":%" PRIu64 ","
           "\"lookup_ns_per_call\":%.6f,\"lookup_ns_per_owned_batch\":%.6f,"
           "\"cached_control_total_ns\":%" PRIu64 ",\"cached_control_ns_per_call\":%.6f,"
           "\"cached_control_ns_per_batch\":%.6f,\"sink\":%" PRIuPTR "}\n",
           closed ? "true" : "false", path, iterations, (unsigned)WARMUP,
           (unsigned)LOOKUPS, lookup_ns,
           lookup_ns / calls, (double)lookup_ns / iterations, cached_ns,
           cached_ns / calls, (double)cached_ns / iterations, sink);
    return closed ? 0 : 2;
}
