//
//  AMPMiddlewareRunner.m
//  Copyright (c) 2021 Amplitude Inc. (https://amplitude.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AMPMiddlewareRunner.h"
#import "AMPMiddleware.h"

@implementation AMPMiddlewareRunner

- (instancetype)init {
    if ((self = [super init])) {
        _middlewares = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype _Nonnull)middleRunner {
    return [[self alloc] init];
}

- (void) add:(id<AMPMiddleware> _Nonnull)middleware {
    [self.middlewares addObject:middleware];
}

- (void)remove:(id<AMPMiddleware>)middleware {
    [self.middlewares removeObject:middleware];
}

- (void) run:(AMPMiddlewarePayload *_Nonnull)payload next:(AMPMiddlewareNext _Nonnull)next {
    [self runMiddlewares:self.middlewares payload:payload callback:next];
}

- (void) runMiddlewares:(NSArray<id<AMPMiddleware>> *_Nonnull)middlewares
                payload:(AMPMiddlewarePayload *_Nonnull)payload
               callback:(AMPMiddlewareNext _Nullable)callback {
    if (middlewares.count == 0) {
        if (callback) {
            callback(payload);
        }
        return;
    }
    
    [middlewares[0] run:payload next:^(AMPMiddlewarePayload *_Nullable newPayload) {
        NSArray *remainingMiddlewares = [middlewares subarrayWithRange:NSMakeRange(1, middlewares.count - 1)];
        [self runMiddlewares:remainingMiddlewares payload:newPayload callback:callback];
    }];
}

- (void)dispatchAmplitudeInitialized:(Amplitude *)amplitude {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        [self dispatchAmplitudeInitialized:amplitude toMiddleware:middleware];
    }
}

- (void)dispatchAmplitudeInitialized:(Amplitude *)amplitude
                        toMiddleware:(id<AMPMiddleware>)middleware {
    if ([AMPMiddlewareRunner object:middleware
                 respondsToSelector:@selector(amplitudeDidFinishInitializing:)]) {
        [middleware amplitudeDidFinishInitializing:amplitude];
    }
}

- (void)dispatchAmplitude:(Amplitude *)amplitude didUploadEventsManually:(BOOL)isManualUpload {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        if ([AMPMiddlewareRunner object:middleware
                     respondsToSelector:@selector(amplitude:didUploadEventsManually:)]) {
            [middleware amplitude:amplitude didUploadEventsManually:isManualUpload];
        }
    }
}

- (void)dispatchAmplitude:(Amplitude *)amplitude didChangeDeviceId:(NSString *)deviceId {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        if ([AMPMiddlewareRunner object:middleware
                     respondsToSelector:@selector(amplitude:didChangeDeviceId:)]) {
            [middleware amplitude:amplitude didChangeDeviceId:deviceId];
        }
    }
}

- (void)dispatchAmplitude:(Amplitude *)amplitude didChangeSessionId:(long long)sessionId {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        if ([AMPMiddlewareRunner object:middleware
                     respondsToSelector:@selector(amplitude:didChangeSessionId:)]) {
            [middleware amplitude:amplitude didChangeSessionId:sessionId];
        }
    }
}

- (void)dispatchAmplitude:(Amplitude *)amplitude didChangeUserId:(NSString *)userId {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        if ([AMPMiddlewareRunner object:middleware
                     respondsToSelector:@selector(amplitude:didChangeUserId:)]) {
            [middleware amplitude:amplitude didChangeUserId:userId];
        }
    }
}

- (void)dispatchAmplitude:(Amplitude *)amplitude didOptOut:(BOOL)optOut {
    for (id<AMPMiddleware> middleware in self.middlewares) {
        if ([AMPMiddlewareRunner object:middleware
                     respondsToSelector:@selector(amplitude:didOptOut:)]) {
            [middleware amplitude:amplitude didOptOut:optOut];
        }
    }
}

// AMPMiddleware never conformed to NSObject, which means we can't use the standard
// [object respondsToSelector:] syntax to check for protocol conformance to optional methods.
+ (BOOL)object:(id)object respondsToSelector:(SEL)selector {
    Class middlewareClass = object_getClass(object);
    if (middlewareClass) {
        return class_respondsToSelector(middlewareClass, selector);
    }
    return NO;
}

@end
