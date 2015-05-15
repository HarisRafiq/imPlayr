//
//  PlaybackItem.m
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "PlaybackItem.h"
#import "AudioFile.h"
@interface PlaybackItem () {
@private
    AudioFile *_audioFile;
     AudioFileID _fileID;
    AudioStreamBasicDescription _fileFormat;
    NSUInteger _bitRate;
    NSUInteger _dataOffset;
    NSUInteger _estimatedDuration;
}
@end

@implementation PlaybackItem
@synthesize fileID = _fileID;
@synthesize fileFormat = _fileFormat;
@synthesize bitRate = _bitRate;
@synthesize dataOffset = _dataOffset;
@synthesize estimatedDuration = _estimatedDuration;
@synthesize audioFile=_audioFile;
- (NSURL *)cachedURL
{
    return [_audioFile cachedURL];
}

- (NSData *)mappedData
{
    return [_audioFile mappedData];
}

- (BOOL)isOpened
{
    return _fileID != NULL;
}
-(BOOL)isRemote{


    return [_audioFile isRemote];
}

static OSStatus audio_file_read(void *inClientData,
                                SInt64 inPosition,
                                UInt32 requestCount,
                                void *buffer,
                                UInt32 *actualCount)
{
    __unsafe_unretained PlaybackItem *item = (__bridge PlaybackItem *)inClientData;
    
    if (inPosition + requestCount > [[item mappedData] length]) {
        if (inPosition >= [[item mappedData] length]) {
            *actualCount = 0;
        }
        else {
            *actualCount = (UInt32)((SInt64)[[item mappedData] length] - inPosition);
        }
    }
    else {
        *actualCount = requestCount;
    }
    
    if (*actualCount == 0) {
        return noErr;
    }
    
         memcpy(buffer, (uint8_t *)[[item mappedData] bytes] + inPosition, *actualCount);
        return noErr;
}
static SInt64 audio_file_get_size(void *inClientData)
{
    __unsafe_unretained PlaybackItem *item = (__bridge PlaybackItem *)inClientData;
    return (SInt64)[[item mappedData] length];
}
- (BOOL)_openWithFileTypeHint:(AudioFileTypeID)fileTypeHint
{
    OSStatus status;
    status = AudioFileOpenWithCallbacks((__bridge void *)self,
                                        audio_file_read,
                                        NULL,
                                        audio_file_get_size,
                                        NULL,
                                        fileTypeHint,
                                        &_fileID);
    
    return status == noErr;
}
- (BOOL)_openWithFallbacks
{
    NSArray *fallbackTypeIDs = [self _fallbackTypeIDs];
    for (NSNumber *typeIDNumber in fallbackTypeIDs) {
        AudioFileTypeID typeID = (AudioFileTypeID)[typeIDNumber unsignedLongValue];
        if ([self _openWithFileTypeHint:typeID]) {
            return YES;
        }
    }
    
    return NO;
}
- (NSArray *)_fallbackTypeIDs
{
    NSMutableArray *fallbackTypeIDs = [NSMutableArray array];
    NSMutableSet *fallbackTypeIDSet = [NSMutableSet set];
    
    struct {
        CFStringRef specifier;
        AudioFilePropertyID propertyID;
    } properties[] = {
        { (__bridge CFStringRef)[_audioFile mimeType], kAudioFileGlobalInfo_TypesForMIMEType },
        { (__bridge CFStringRef)[_audioFile fileExtension], kAudioFileGlobalInfo_TypesForExtension }
    };
    
    const size_t numberOfProperties = sizeof(properties) / sizeof(properties[0]);
    
    for (size_t i = 0; i < numberOfProperties; ++i) {
        if (properties[i].specifier == NULL) {
            continue;
        }
        
        UInt32 outSize = 0;
        OSStatus status;
        
        status = AudioFileGetGlobalInfoSize(properties[i].propertyID,
                                            sizeof(properties[i].specifier),
                                            &properties[i].specifier,
                                            &outSize);
        if (status != noErr) {
            continue;
        }
        
        size_t count = outSize / sizeof(AudioFileTypeID);
        AudioFileTypeID *buffer = (AudioFileTypeID *)malloc(outSize);
        if (buffer == NULL) {
            continue;
        }
        
        status = AudioFileGetGlobalInfo(properties[i].propertyID,
                                        sizeof(properties[i].specifier),
                                        &properties[i].specifier,
                                        &outSize,
                                        buffer);
        if (status != noErr) {
            free(buffer);
            continue;
        }
        
        for (size_t j = 0; j < count; ++j) {
            NSNumber *tid = [NSNumber numberWithUnsignedLong:buffer[j]];
            if ([fallbackTypeIDSet containsObject:tid]) {
                continue;
            }
            
            [fallbackTypeIDs addObject:tid];
            [fallbackTypeIDSet addObject:tid];
        }
        
        free(buffer);
    }
    
    return fallbackTypeIDs;
}
- (BOOL)open
{
    if ([self isOpened]) {
        return YES;
    }
    
    if (![self _openWithFileTypeHint:0] &&
        ![self _openWithFallbacks]) {
        _fileID = NULL;
        return NO;
    }
    
    if (![self _fillFileFormat] ||
        ![self _fillMiscProperties]) {
        AudioFileClose(_fileID);
        _fileID = NULL;
        return NO;
    }
    
    return YES;
}

- (BOOL)_fillFileFormat
{
    UInt32 size;
    OSStatus status;
    
    status = AudioFileGetPropertyInfo(_fileID, kAudioFilePropertyFormatList, &size, NULL);
    if (status != noErr) {
        return NO;
    }
    
    UInt32 numFormats = size / sizeof(AudioFormatListItem);
    AudioFormatListItem *formatList = (AudioFormatListItem *)malloc(size);
    
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyFormatList, &size, formatList);
    if (status != noErr) {
        free(formatList);
        return NO;
    }
    
    if (numFormats == 1) {
        _fileFormat = formatList[0].mASBD;
    }
    else {
        status = AudioFormatGetPropertyInfo(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size);
        if (status != noErr) {
            free(formatList);
            return NO;
        }
        
        UInt32 numDecoders = size / sizeof(OSType);
        OSType *decoderIDS = (OSType *)malloc(size);
        
        status = AudioFormatGetProperty(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size, decoderIDS);
        if (status != noErr) {
            free(formatList);
            free(decoderIDS);
            return NO;
        }
        
        UInt32 i;
        for (i = 0; i < numFormats; ++i) {
            OSType decoderID = formatList[i].mASBD.mFormatID;
            
            BOOL found = NO;
            for (UInt32 j = 0; j < numDecoders; ++j) {
                if (decoderID == decoderIDS[j]) {
                    found = YES;
                    break;
                }
            }
            
            if (found) {
                break;
            }
        }
        
        free(decoderIDS);
        
        if (i >= numFormats) {
            free(formatList);
            return NO;
        }
        
        _fileFormat = formatList[i].mASBD;
    }
    
    free(formatList);
    return YES;
}

- (BOOL)_fillMiscProperties
{
    UInt32 size;
    OSStatus status;
    
    UInt32 bitRate = 0;
    size = sizeof(bitRate);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyBitRate, &size, &bitRate);
    if (status != noErr) {
        return NO;
    }
    _bitRate = bitRate;
    
    SInt64 dataOffset = 0;
    size = sizeof(dataOffset);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyDataOffset, &size, &dataOffset);
    if (status != noErr) {
        return NO;
    }
    _dataOffset = (NSUInteger)dataOffset;
    
    Float64 estimatedDuration = 0.0;
    size = sizeof(estimatedDuration);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyEstimatedDuration, &size, &estimatedDuration);
    if (status != noErr) {
        return NO;
    }
    _estimatedDuration = estimatedDuration * 1000.0;
    
    return YES;
}

- (void)close
{
    if (![self isOpened]) {
        return;
    }
    
    AudioFileClose(_fileID);
    _fileID = NULL;
}

+ (instancetype)playbackItemWithAudioFile:(AudioFile *)file
{
    return [[[self class] alloc] initWithAudioFile:file];
}

- (instancetype)initWithAudioFile:(AudioFile *)file
{
    self = [super init];
    if (self) {
        _audioFile = file;
        
             }
    
    return self;
}

- (void)dealloc
{
    if ([self isOpened]) {
        [self close];
    }
}
@end
