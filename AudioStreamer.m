//
//  AudioStreamer.m
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "AudioStreamer.h"

NSString *const AudioStreamerErrorDomain = @"com.douban.audio-streamer.error-domain";

@interface AudioStreamer () {
@private
    NSURL *currentURL;
   AudioStreamerStatus _status;
    
    NSTimeInterval _duration;
    NSInteger _timingOffset;
    
    AudioFile *_fileProvider;
    PlaybackItem *_playbackItem;
    AudioDecoder *_decoder;
    
    double _bufferingRatio;
    
#if TARGET_OS_IPHONE
    BOOL _pausedByInterruption;
#endif /* TARGET_OS_IPHONE */
}
@end
@implementation AudioStreamer
@synthesize status = _status;
@synthesize error = _error;
 @synthesize duration = _duration;
@synthesize timingOffset = _timingOffset;
@synthesize fileProvider=_fileProvider;
 @synthesize playbackItem = _playbackItem;
@synthesize decoder = _decoder;

@synthesize bufferingRatio = _bufferingRatio;

#if TARGET_OS_IPHONE
@synthesize pausedByInterruption = _pausedByInterruption;
#endif /* TARGET_OS_IPHONE */

+ (instancetype)streamerWithAudioFileURL:(NSURL *)url
{
    return [[[self class] alloc] initWithAudioFileURL:url];
}

- (instancetype)initWithAudioFileURL:(NSURL *)url
{
    self = [super init];
    if (self) {
         _status = AudioStreamerIdle;
        
        _fileProvider = [AudioFile AudioFileWithURL:url];
        if (_fileProvider == nil) {
            return nil;
        }
        else
        NSLog(@"sha256: %@", [url absoluteString]);

        _bufferingRatio = (double)[_fileProvider receivedLength] / [_fileProvider expectedLength];
    }
    
    return self;
}
+ (double)volume
{
    return [[AudioPlayer sharedInstance] volume];
}

+ (void)setVolume:(double)volume
{
    [[AudioPlayer sharedInstance] setVolume:volume];
}
/*
+ (NSArray *)analyzers
{
    return [[DOUAudioEventLoop sharedEventLoop] analyzers];
}

+ (void)setAnalyzers:(NSArray *)analyzers
{
    [[DOUAudioEventLoop sharedEventLoop] setAnalyzers:analyzers];
}
*/



- (NSURL *)url
{
    return [_fileProvider audioURL];
}

- (NSTimeInterval)currentTime
{
    if ([[AudioPlayer sharedInstance] currentStreamer] != self) {
        return 0.0;
    }
    
    return [[AudioPlayer sharedInstance] currentTime];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if ([[AudioPlayer sharedInstance] currentStreamer] != self) {
        return;
    }
    
    [[AudioPlayer sharedInstance] setCurrentTime:currentTime];
}

- (double)volume
{
    return [[self class] volume];
}

- (void)setVolume:(double)volume
{
    [[self class] setVolume:volume];
}

 
- (NSString *)cachedPath
{
    return [_fileProvider cachedPath];
}

- (NSURL *)cachedURL
{
    return [_fileProvider cachedURL];
}

- (NSString *)sha256
{
    return [_fileProvider sha256];
}

- (NSUInteger)expectedLength
{
    return [_fileProvider expectedLength];
}

- (NSUInteger)receivedLength
{
    return [_fileProvider receivedLength];
}

- (NSUInteger)downloadSpeed
{
    return [_fileProvider downloadSpeed];
}

- (void)play
{
    @synchronized(self) {
        if (_status != AudioStreamerPaused &&
            _status != AudioStreamerIdle &&
            _status != AudioStreamerFinished) {
            return;
        }
        
        if ([[AudioPlayer sharedInstance] currentStreamer] != self) {
            [[AudioPlayer sharedInstance] pause];
            [[AudioPlayer sharedInstance] setCurrentStreamer:self];
        }
        
        [[AudioPlayer sharedInstance] play];
    }
}

- (void)pause
{
    @synchronized(self) {
        if (_status == AudioStreamerPaused ||
            _status == AudioStreamerIdle ||
            _status == AudioStreamerFinished) {
            return;
        }
        
        if ([[AudioPlayer sharedInstance] currentStreamer] != self) {
            return;
        }
        
        [[AudioPlayer sharedInstance] pause];
    }
}

- (void)stop
{
    @synchronized(self) {
        if (_status == AudioStreamerIdle) {
            return;
        }
        
        if ([[AudioPlayer sharedInstance] currentStreamer] != self) {
            return;
        }
        
        [[AudioPlayer sharedInstance] stop];
        [[AudioPlayer sharedInstance] setCurrentStreamer:nil];
    }
}

+ (void)setHintWithAudioFile:(NSURL *)url
{
    [AudioFile setHintWithAudioFile:url];
}


@end
