//
//  AudioPlayer.h
//  IMP
//
//  Created by YAZ on 3/15/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioStreamer;

@interface AudioPlayer : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, strong) AudioStreamer *currentStreamer;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) double volume;

 
- (void)play;
- (void)pause;
- (void)stop;

@end
