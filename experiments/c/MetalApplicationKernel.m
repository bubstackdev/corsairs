// Development-only application kernel. Never linked by the production crate.
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <stdint.h>
#include <stdio.h>

int corsairs_app_scale(void *queueObject, void *bufferObject, size_t byteOffset,
                       uint32_t count, void **ownedCommand) {
    @autoreleasepool {
        if (!queueObject || !bufferObject || !ownedCommand || count == 0) return 1;
        *ownedCommand = NULL;
        id<MTLCommandQueue> queue = (__bridge id<MTLCommandQueue>)queueObject;
        id<MTLBuffer> buffer = (__bridge id<MTLBuffer>)bufferObject;
        if (byteOffset > buffer.length || (uint64_t)count * sizeof(float) > buffer.length - byteOffset) return 2;
        NSError *error = nil;
        NSString *source = @"#include <metal_stdlib>\nusing namespace metal;\n"
            "kernel void triple(device float *x [[buffer(0)]], constant uint &n [[buffer(1)]], uint i [[thread_position_in_grid]]) { if (i < n) x[i] *= 3.0f; }";
        id<MTLLibrary> library = [queue.device newLibraryWithSource:source options:nil error:&error];
        id<MTLFunction> function = [library newFunctionWithName:@"triple"];
        id<MTLComputePipelineState> pipeline = function ? [queue.device newComputePipelineStateWithFunction:function error:&error] : nil;
        if (!pipeline) {
            fprintf(stderr, "application Metal kernel compile failed: %s\n", error.description.UTF8String);
            return 3;
        }
        id<MTLCommandBuffer> command = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [command computeCommandEncoder];
        if (!command || !encoder) return 4;
        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:buffer offset:byteOffset atIndex:0];
        [encoder setBytes:&count length:sizeof(count) atIndex:1];
        NSUInteger width = MIN((NSUInteger)count, pipeline.maxTotalThreadsPerThreadgroup);
        [encoder dispatchThreads:MTLSizeMake(count, 1, 1) threadsPerThreadgroup:MTLSizeMake(width, 1, 1)];
        [encoder endEncoding];
        [command commit];
        // The caller receives +1; default command buffers retain GPU resources.
        *ownedCommand = (__bridge_retained void *)command;
        return 0;
    }
}

uint64_t corsairs_app_status(void *command) {
    return (uint64_t)[(__bridge id<MTLCommandBuffer>)command status];
}

void corsairs_app_release(void *command) {
    // Drain even when the Rust experiment exits early after submitting work.
    // Releasing an Objective-C reference alone does not establish completion
    // required by the exported raw buffer's external-access contract.
    id<MTLCommandBuffer> released = (__bridge_transfer id<MTLCommandBuffer>)command;
    [released waitUntilCompleted];
}
