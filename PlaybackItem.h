//
//  PlaybackItem.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <AudioToolbox/AudioToolbox.h>

@class AudioFile;

@interface PlaybackItem : NSObject
+ (instancetype)playbackItemWithAudioFile:(AudioFile *)file;
- (instancetype)initWithAudioFile:(AudioFile *)file;

@property (nonatomic, readonly) AudioFile *audioFile;
@property (nonatomic, readonly) NSURL *cachedURL;
@property (nonatomic, readonly) NSData *mappedData;

@property (nonatomic, readonly) AudioFileID fileID;
@property (nonatomic, readonly) AudioStreamBasicDescription fileFormat;
@property (nonatomic, readonly) NSUInteger bitRate;
@property (nonatomic, readonly) NSUInteger dataOffset;
@property (nonatomic, readonly) NSUInteger estimatedDuration;

@property (nonatomic, readonly, getter = isOpened) BOOL opened;

- (BOOL)open;
- (void)close;


@end
