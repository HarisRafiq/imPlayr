//
//  AudioPlayer.m
//  IMP
//
//  Created by YAZ on 3/15/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "AudioPlayer.h"
#import "AudioStreamer.h"
 #import "AudioFile.h"
#import "PlaybackItem.h"
#import "LPCBuffer.h"
#import "AudioDecoder.h"
#import "AudioRenderer.h"
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <pthread.h>
#include <sched.h>
 const NSUInteger AudioStreamerBufferTime = 200;
typedef NS_ENUM(uint64_t, event_type) {
    event_play,
    event_pause,
    event_stop,
    event_seek,
    event_streamer_changed,
    event_provider_events,
    event_finalizing,
#if TARGET_OS_IPHONE
    event_interruption_begin,
    event_interruption_end,
    event_old_device_unavailable,
#endif /* TARGET_OS_IPHONE */
    
    event_first = event_play,
#if TARGET_OS_IPHONE
    event_last = event_old_device_unavailable,
#else /* TARGET_OS_IPHONE */
    event_last = event_finalizing,
#endif /* TARGET_OS_IPHONE */
    
    event_timeout
};
@interface AudioPlayer () {
@private
    AudioRenderer *_renderer;
    AudioStreamer *_currentStreamer;
    
    NSUInteger _decoderBufferSize;
    AudioFileEventBlock _fileEventBlock;
    
    int _kq;
    void *_lastKQUserData;
    pthread_mutex_t _mutex;
    pthread_t _thread;
}
@end


@implementation AudioPlayer
@synthesize currentStreamer = _currentStreamer;

+ (instancetype)sharedInstance
{
    static AudioPlayer *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudioPlayer alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _kq = kqueue();
        pthread_mutex_init(&_mutex, NULL);
        
        _renderer = [AudioRenderer rendererWithBufferTime:AudioStreamerBufferTime];
        [_renderer setUp];
        
        
        _decoderBufferSize = [[self class] _decoderBufferSize];
#if TARGET_OS_IPHONE
        [self _setupAudioSession];
#endif /* TARGET_OS_IPHONE */
        [self _setupFileEventBlock];
        [self _enableEvents];
        [self _createThread];
    }
    
    return self;
}

- (void)dealloc
{
    [self _sendEvent:event_finalizing];
    pthread_join(_thread, NULL);
    
    close(_kq);
    pthread_mutex_destroy(&_mutex);
}

+ (NSUInteger)_decoderBufferSize
{
    AudioStreamBasicDescription format = [AudioDecoder defaultOutputFormat];
    return AudioStreamerBufferTime * format.mSampleRate * format.mChannelsPerFrame * format.mBitsPerChannel / 8 / 1000;
}
#if TARGET_OS_IPHONE

- (void)_handleAudioSessionInterruptionWithState:(UInt32)state
{
    if (state == kAudioSessionBeginInterruption) {
        [_renderer setInterrupted:YES];
        [_renderer stop];
        [self _sendEvent:event_interruption_begin];
    }
    else if (state == kAudioSessionEndInterruption) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        AudioSessionInterruptionType interruptionType = kAudioSessionInterruptionType_ShouldNotResume;
        UInt32 interruptionTypeSize = sizeof(interruptionType);
        OSStatus status;
        status = AudioSessionGetProperty(kAudioSessionProperty_InterruptionType,
                                         &interruptionTypeSize,
                                         &interruptionType);
        NSAssert(status == noErr, @"failed to get interruption type");
#pragma clang diagnostic pop
        
        [self _sendEvent:event_interruption_end
                userData:(void *)(uintptr_t)interruptionType];
    }
}

- (void)_handleAudioRouteChangeWithDictionary:(NSDictionary *)routeChangeDictionary
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    
    NSUInteger reason = [[routeChangeDictionary objectForKey:(__bridge NSString *)kAudioSession_RouteChangeKey_Reason] unsignedIntegerValue];
    if (reason != kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        return;
    }
    
    NSDictionary *previousRouteDescription = [routeChangeDictionary objectForKey:(__bridge NSString *)kAudioSession_AudioRouteChangeKey_PreviousRouteDescription];
    NSArray *previousOutputRoutes = [previousRouteDescription objectForKey:(__bridge NSString *)kAudioSession_AudioRouteKey_Outputs];
    if ([previousOutputRoutes count] == 0) {
        return;
    }
    
    NSString *previousOutputRouteType = [[previousOutputRoutes objectAtIndex:0] objectForKey:(__bridge NSString *)kAudioSession_AudioRouteKey_Type];
    if (previousOutputRouteType == nil ||
        ![previousOutputRouteType isEqualToString:(__bridge NSString *)kAudioSessionOutputRoute_Headphones]) {
        return;
    }
#pragma clang diagnostic pop
    
    [self _sendEvent:event_old_device_unavailable];
}

static void audio_session_interruption_listener(void *inClientData, UInt32 inInterruptionState)
{
    __unsafe_unretained AudioPlayer *eventLoop = (__bridge AudioPlayer *)inClientData;
    [eventLoop _handleAudioSessionInterruptionWithState:inInterruptionState];
}

static void audio_route_change_listener(void *inClientData,
                                        AudioSessionPropertyID inID,
                                        UInt32 inDataSize,
                                        const void *inData)
{
    if (inID != kAudioSessionProperty_AudioRouteChange) {
        return;
    }
    
    __unsafe_unretained AudioPlayer *eventLoop = (__bridge AudioPlayer *)inClientData;
    [eventLoop _handleAudioRouteChangeWithDictionary:(__bridge NSDictionary *)inData];
}

- (void)_setupAudioSession
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    
    AudioSessionInitialize(NULL, NULL, audio_session_interruption_listener, (__bridge void *)self);
    
    UInt32 audioCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audio_route_change_listener, (__bridge void *)self);
    
    AudioSessionSetActive(TRUE);
    
#pragma clang diagnostic pop
}

#endif /* TARGET_OS_IPHONE */

- (void)_setupFileEventBlock
{
    __unsafe_unretained AudioPlayer *eventLoop = self;
    _fileEventBlock = ^{
        [eventLoop _sendEvent:event_provider_events];
    };
}

- (void)_enableEvents
{
    for (uint64_t event = event_first; event <= event_last; ++event) {
        struct kevent kev;
        EV_SET(&kev, event, EVFILT_USER, EV_ADD | EV_ENABLE | EV_CLEAR, 0, 0, NULL);
        kevent(_kq, &kev, 1, NULL, 0, NULL);
    }
}

- (void)_sendEvent:(event_type)event
{
    [self _sendEvent:event userData:NULL];
}

- (void)_sendEvent:(event_type)event userData:(void *)userData
{
    struct kevent kev;
    EV_SET(&kev, event, EVFILT_USER, 0, NOTE_TRIGGER, 0, userData);
    kevent(_kq, &kev, 1, NULL, 0, NULL);
}

- (event_type)_waitForEvent
{
    return [self _waitForEventWithTimeout:NSUIntegerMax];
}

- (event_type)_waitForEventWithTimeout:(NSUInteger)timeout
{
    struct timespec _ts;
    struct timespec *ts = NULL;
    if (timeout != NSUIntegerMax) {
        ts = &_ts;
        
        ts->tv_sec = timeout / 1000;
        ts->tv_nsec = (timeout % 1000) * 1000;
    }
    
    while (1) {
        struct kevent kev;
        int n = kevent(_kq, NULL, 0, &kev, 1, ts);
        if (n > 0) {
            if (kev.filter == EVFILT_USER &&
                kev.ident >= event_first &&
                kev.ident <= event_last) {
                _lastKQUserData = kev.udata;
                return kev.ident;
            }
        }
        else {
            break;
        }
    }
    
    return event_timeout;
}
- (BOOL)_handleEvent:(event_type)event withStreamer:(AudioStreamer **)streamer
{
    if (event == event_play) {
        if (*streamer != nil &&
            ([*streamer status] == AudioStreamerPaused ||
             [*streamer status] == AudioStreamerIdle ||
             [*streamer status] == AudioStreamerFinished)) {
                [*streamer setStatus:AudioStreamerPlaying];
                [_renderer setInterrupted:NO];
            }
    }
    else if (event == event_pause) {
        if (*streamer != nil &&
            ([*streamer status] != AudioStreamerPaused &&
             [*streamer status] != AudioStreamerIdle &&
             [*streamer status] != AudioStreamerFinished)) {
                [_renderer stop];
                [*streamer setStatus:AudioStreamerPaused];
            }
    }
    else if (event == event_stop) {
        if (*streamer != nil &&
            [*streamer status] != AudioStreamerIdle) {
            if ([*streamer status] != AudioStreamerPaused) {
                [_renderer stop];
            }
            [_renderer flush];
            [*streamer setDecoder:nil];
            [*streamer setPlaybackItem:nil];
            [*streamer setStatus:AudioStreamerIdle];
        }
    }
    else if (event == event_seek) {
        if (*streamer != nil &&
            [*streamer decoder] != nil) {
            NSUInteger milliseconds =  MIN((NSUInteger)(uintptr_t)_lastKQUserData,
                                           [[*streamer playbackItem] estimatedDuration]);
            [*streamer setTimingOffset:(NSInteger)milliseconds - (NSInteger)[_renderer currentTime]];
            [[*streamer decoder] seekToTime:milliseconds];
            [_renderer flushShouldResetTiming:NO];
        }
    }
    else if (event == event_streamer_changed) {
        [_renderer stop];
        [_renderer flush];
        
        [[*streamer fileProvider] setEventBlock:NULL];
        *streamer = _currentStreamer;
        [[*streamer fileProvider] setEventBlock:_fileEventBlock];
    }
    else if (event == event_provider_events) {
        if (*streamer != nil &&
            [*streamer status] == AudioStreamerBuffering) {
            [*streamer setStatus:AudioStreamerPlaying];
        }
        
        [*streamer setBufferingRatio:(double)[[*streamer fileProvider] receivedLength] / [[*streamer fileProvider] expectedLength]];
    }
    else if (event == event_finalizing) {
        return NO;
    }
#if TARGET_OS_IPHONE
    else if (event == event_interruption_begin) {
        if (*streamer != nil &&
            ([*streamer status] != AudioStreamerPaused &&
             [*streamer status] != AudioStreamerIdle &&
             [*streamer status] != AudioStreamerFinished)) {
                [self performSelector:@selector(pause) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
                [*streamer setPausedByInterruption:YES];
            }
    }
    else if (event == event_interruption_end) {
        const AudioSessionInterruptionType interruptionType = (AudioSessionInterruptionType)(uintptr_t)_lastKQUserData;
        NSAssert(interruptionType == kAudioSessionInterruptionType_ShouldResume ||
                 interruptionType == kAudioSessionInterruptionType_ShouldNotResume,
                 @"invalid interruption type");
        
        if (interruptionType == kAudioSessionInterruptionType_ShouldResume) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            OSStatus status;
            status = AudioSessionSetActive(TRUE);
            NSAssert(status == noErr, @"failed to activate audio session");
#pragma clang diagnostic pop
            [_renderer setInterrupted:NO];
            
            if (*streamer != nil &&
                [*streamer status] == AudioStreamerPaused &&
                [*streamer isPausedByInterruption]) {
                [*streamer setPausedByInterruption:NO];
                [self performSelector:@selector(play) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            }
        }
    }
    else if (event == event_old_device_unavailable) {
        if (*streamer != nil) {
            if ([*streamer status] != AudioStreamerPaused &&
                [*streamer status] != AudioStreamerIdle &&
                [*streamer status] != AudioStreamerFinished) {
                [self performSelector:@selector(pause)
                             onThread:[NSThread mainThread]
                           withObject:nil
                        waitUntilDone:NO];
            }
            
            [*streamer setPausedByInterruption:NO];
        }
    }
#endif /* TARGET_OS_IPHONE */
    else if (event == event_timeout) {
    }
    
    return YES;
}


- (void)_handleStreamer:(AudioStreamer *)streamer
{
    if (streamer == nil) {
        return;
    }
    
    if ([streamer status] != AudioStreamerPlaying) {
        return;
    }
    
    if ([[streamer fileProvider] isFailed]) {
        [streamer setError:[NSError errorWithDomain:AudioStreamerErrorDomain
                                               code:AudioStreamerNetworkError
                                           userInfo:nil]];
        [streamer setStatus:AudioStreamerError];
        return;
    }
    
    if (![[streamer fileProvider] isReady]) {
        [streamer setStatus:AudioStreamerBuffering];
        return;
    }
    
    if ([streamer playbackItem] == nil) {
        [streamer setPlaybackItem:[PlaybackItem playbackItemWithAudioFile:[streamer fileProvider]]];
        if (![[streamer playbackItem] open]) {
            [streamer setError:[NSError errorWithDomain:AudioStreamerErrorDomain
                                                   code:AudioStreamerDecodingError
                                               userInfo:nil]];
            [streamer setStatus:AudioStreamerError];
            return;
        }
        
        [streamer setDuration:(NSTimeInterval)[[streamer playbackItem] estimatedDuration] / 1000.0];
    }
    
    if ([streamer decoder] == nil) {
        [streamer setDecoder:[AudioDecoder decoderWithPlaybackItem:[streamer playbackItem]
                                                           bufferSize:_decoderBufferSize]];
        if (![[streamer decoder] setUp]) {
            [streamer setError:[NSError errorWithDomain:AudioStreamerErrorDomain
                                                   code:AudioStreamerDecodingError
                                               userInfo:nil]];
            [streamer setStatus:AudioStreamerError];
            return;
        }
    }
    
    switch ([[streamer decoder] decodeOnce]) {
        case AudioDecoderSucceeded:
            break;
            
        case AudioDecoderFailed:
            [streamer setError:[NSError errorWithDomain:AudioStreamerErrorDomain
                                                   code:AudioStreamerDecodingError
                                               userInfo:nil]];
            [streamer setStatus:AudioStreamerError];
            return;
            
        case AudioDecoderEndEncountered:
            [_renderer stop];
            [streamer setDecoder:nil];
            [streamer setPlaybackItem:nil];
            [streamer setStatus:AudioStreamerFinished];
            return;
            
        case AudioDecoderWaiting:
            [streamer setStatus:AudioStreamerBuffering];
            return;
    }
    
    void *bytes = NULL;
    NSUInteger length = 0;
    [[[streamer decoder] lpcmBuffer] readBytes:&bytes length:&length];
    if (bytes != NULL) {
        [_renderer renderBytes:bytes length:length];
        free(bytes);
    }
}
- (void)_eventLoop
{
    AudioStreamer *streamer = nil;
    
    while (1) {
        @autoreleasepool {
            if (streamer != nil) {
                switch ([streamer status]) {
                    case AudioStreamerPaused:
                    case AudioStreamerIdle:
                    case AudioStreamerFinished:
                    case AudioStreamerBuffering:
                    case AudioStreamerError:
                        if (![self _handleEvent:[self _waitForEvent]
                                   withStreamer:&streamer]) {
                            return;
                        }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                if (![self _handleEvent:[self _waitForEvent]
                           withStreamer:&streamer]) {
                    return;
                }
            }
            
            if (![self _handleEvent:[self _waitForEventWithTimeout:0]
                       withStreamer:&streamer]) {
                return;
            }
            
            if (streamer != nil) {
                [self _handleStreamer:streamer];
            }
        }
    }
}

static void *event_loop_main(void *info)
{
    pthread_setname_np("com.implayr.audio-streamer.event-loop");
    
    __unsafe_unretained AudioPlayer *eventLoop = (__bridge AudioPlayer *)info;
    @autoreleasepool {
        [eventLoop _eventLoop];
    }
    
    return NULL;
}

- (void)_createThread
{
    pthread_attr_t attr;
    struct sched_param sched_param;
    int sched_policy = SCHED_FIFO;
    
    pthread_attr_init(&attr);
    pthread_attr_setschedpolicy(&attr, sched_policy);
    sched_param.sched_priority = sched_get_priority_max(sched_policy);
    pthread_attr_setschedparam(&attr, &sched_param);
    
    pthread_create(&_thread, &attr, event_loop_main, (__bridge void *)self);
    
    pthread_attr_destroy(&attr);
}

- (void)setCurrentStreamer:(AudioStreamer *)currentStreamer
{
    if (_currentStreamer != currentStreamer) {
        _currentStreamer = currentStreamer;
        [self _sendEvent:event_streamer_changed];
    }
}

- (NSTimeInterval)currentTime
{
    return (NSTimeInterval)((NSUInteger)[[self currentStreamer] timingOffset] + [_renderer currentTime]) / 1000.0;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    NSUInteger milliseconds = (NSUInteger)lrint(currentTime * 1000.0);
    [self _sendEvent:event_seek userData:(void *)(uintptr_t)milliseconds];
}

- (double)volume
{
    return [_renderer volume];
}

- (void)setVolume:(double)volume
{
   /* [_renderer setVolume:volume];
    
    if ([AudioStreamer options] & DOUAudioStreamerKeepPersistentVolume) {
        [[NSUserDefaults standardUserDefaults] setDouble:volume
                                                  forKey:kDOUAudioStreamerVolumeKey];
    }
    */
}

- (void)play
{
    [self _sendEvent:event_play];
}

- (void)pause
{
    [self _sendEvent:event_pause];
}

- (void)stop
{
    [self _sendEvent:event_stop];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (aSelector == @selector(analyzers) ||
        aSelector == @selector(setAnalyzers:)) {
        return _renderer;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

@end
