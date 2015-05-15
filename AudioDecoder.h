//
//  AudioDecoder.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudioTypes.h>

typedef NS_ENUM(NSUInteger,AudioDecoderStatus) {
    AudioDecoderSucceeded,
    AudioDecoderFailed,
    AudioDecoderEndEncountered,
    AudioDecoderWaiting
};

@class PlaybackItem;
@class LPCBuffer;

@interface AudioDecoder : NSObject
+ (AudioStreamBasicDescription)defaultOutputFormat;

+ (instancetype)decoderWithPlaybackItem:(PlaybackItem *)playbackItem
                             bufferSize:(NSUInteger)bufferSize;

- (instancetype)initWithPlaybackItem:(PlaybackItem *)playbackItem
                          bufferSize:(NSUInteger)bufferSize;

- (BOOL)setUp;
- (void)tearDown;

- (AudioDecoderStatus)decodeOnce;
- (void)seekToTime:(NSUInteger)milliseconds;

@property (nonatomic, readonly) PlaybackItem *playbackItem;
@property (nonatomic, readonly) LPCBuffer *lpcmBuffer;


@end
