//
//  AMPMiddlewareRunner.h
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
#import "AMPMiddleware.h"

@class Amplitude;

@interface AMPMiddlewareRunner : NSObject

@property (nonatomic, nonnull, readonly) NSMutableArray<id<AMPMiddleware>> *middlewares;

+ (instancetype _Nonnull)middleRunner;

- (void) add:(id<AMPMiddleware> _Nonnull)middleware;

- (void)remove:(nonnull id<AMPMiddleware>)middleware;

- (void) run:(AMPMiddlewarePayload *_Nonnull)payload next:(AMPMiddlewareNext _Nonnull)next;

- (void)dispatchAmplitudeInitialized:(nonnull Amplitude *)amplitude;
- (void)dispatchAmplitudeInitialized:(nonnull Amplitude *)amplitude
                        toMiddleware:(nonnull id<AMPMiddleware>)middleware;

- (void)dispatchAmplitude:(nonnull Amplitude *)amplitude didUploadEventsManually:(BOOL)isManualUpload;
- (void)dispatchAmplitude:(nonnull Amplitude *)amplitude didChangeDeviceId:(nonnull NSString *)deviceId;
- (void)dispatchAmplitude:(nonnull Amplitude *)amplitude didChangeSessionId:(long long)sessionId;
- (void)dispatchAmplitude:(nonnull Amplitude *)amplitude didChangeUserId:(nonnull NSString *)userId;
- (void)dispatchAmplitude:(nonnull Amplitude *)amplitude didOptOut:(BOOL)optOut;

@end
