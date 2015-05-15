//
//  AudioRenderer.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioRenderer : NSObject
+ (instancetype)rendererWithBufferTime:(NSUInteger)bufferTime;
- (instancetype)initWithBufferTime:(NSUInteger)bufferTime;

- (BOOL)setUp;
- (void)tearDown;

- (void)renderBytes:(const void *)bytes length:(NSUInteger)length;
- (void)stop;
- (void)flush;
- (void)flushShouldResetTiming:(BOOL)shouldResetTiming;

@property (nonatomic, readonly) NSUInteger currentTime;
@property (nonatomic, readonly, getter = isStarted) BOOL started;
@property (nonatomic, assign, getter = isInterrupted) BOOL interrupted;
@property (nonatomic, assign) double volume;

 
@end
