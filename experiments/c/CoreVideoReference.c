// CoreVideo C entry points used by Corsairs' image binding. Swift cannot call
// CVPixelBufferRetain/Release (ARC owns CF objects), so their lowering comes
// from clang instead of ImageReference.swift. One noinline wrapper per call:
//
//   xcrun clang -O1 -S -emit-llvm experiments/c/CoreVideoReference.c \
//       -o target/images-reference/corevideo.ll
#include <CoreVideo/CoreVideo.h>

#define WRAP __attribute__((noinline, used))

WRAP CVReturn create(size_t width, size_t height, OSType format, CVPixelBufferRef *out) {
    return CVPixelBufferCreate(NULL, width, height, format, NULL, out);
}
WRAP CVReturn lock(CVPixelBufferRef buffer, CVPixelBufferLockFlags flags) {
    return CVPixelBufferLockBaseAddress(buffer, flags);
}
WRAP CVReturn unlock(CVPixelBufferRef buffer, CVPixelBufferLockFlags flags) {
    return CVPixelBufferUnlockBaseAddress(buffer, flags);
}
WRAP void *base_address(CVPixelBufferRef buffer) { return CVPixelBufferGetBaseAddress(buffer); }
WRAP size_t bytes_per_row(CVPixelBufferRef buffer) { return CVPixelBufferGetBytesPerRow(buffer); }
WRAP size_t width(CVPixelBufferRef buffer) { return CVPixelBufferGetWidth(buffer); }
WRAP size_t height(CVPixelBufferRef buffer) { return CVPixelBufferGetHeight(buffer); }
WRAP OSType pixel_format(CVPixelBufferRef buffer) { return CVPixelBufferGetPixelFormatType(buffer); }
WRAP Boolean is_planar(CVPixelBufferRef buffer) { return CVPixelBufferIsPlanar(buffer); }
WRAP size_t data_size(CVPixelBufferRef buffer) { return CVPixelBufferGetDataSize(buffer); }
WRAP CVPixelBufferRef retain(CVPixelBufferRef buffer) { return CVPixelBufferRetain(buffer); }
WRAP void release(CVPixelBufferRef buffer) { CVPixelBufferRelease(buffer); }
WRAP CVPixelBufferLockFlags read_only(void) { return kCVPixelBufferLock_ReadOnly; }
