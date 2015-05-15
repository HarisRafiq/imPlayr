//
//  AudioStreamer.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import "AudioFile.h"
#import "AudioPlayer.h"
#import "AudioDecoder.h"
#import "PlaybackItem.h"
#import "imConstants.h"
imPlayr_EXTERN
NSString *const AudioStreamerErrorDomain;
 
typedef NS_ENUM(NSUInteger,AudioStreamerStatus) {
    AudioStreamerPlaying,
    AudioStreamerPaused,
    AudioStreamerIdle,
    AudioStreamerFinished,
    AudioStreamerBuffering,
    AudioStreamerError
};

typedef NS_ENUM(NSInteger,AudioStreamerErrorCode) {
    AudioStreamerNetworkError,
    AudioStreamerDecodingError
};

@interface AudioStreamer : NSObject
+ (instancetype)streamerWithAudioFileURL:(NSURL *)url;
- (instancetype)initWithAudioFileURL:(NSURL *)url;

+ (double)volume;
+ (void)setVolume:(double)volume;


+ (void)setHintWithAudioFile:(NSURL *)url;

@property (assign) AudioStreamerStatus status;
@property (assign) NSError *error;

 @property (nonatomic, readonly) NSURL *url;

 @property (nonatomic, assign) NSInteger timingOffset;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) double volume;

@property (nonatomic, copy) NSArray *analyzers;

@property (nonatomic, readonly) NSString *cachedPath;
@property (nonatomic, readonly) NSURL *cachedURL;

@property (nonatomic, readonly) NSString *sha256;

@property (nonatomic, readonly) NSUInteger expectedLength;
@property (nonatomic, readonly) NSUInteger receivedLength;
@property (nonatomic, readonly) NSUInteger downloadSpeed;
@property (nonatomic, assign) double bufferingRatio;
@property (nonatomic, readonly) AudioFile *fileProvider;
@property (nonatomic, strong) PlaybackItem *playbackItem;
@property (nonatomic, strong) AudioDecoder *decoder;
#if TARGET_OS_IPHONE
@property (nonatomic, assign, getter = isPausedByInterruption) BOOL pausedByInterruption;
#endif /* TARGET_OS_IPHONE */
- (void)play;
- (void)pause;
- (void)stop;

@end
