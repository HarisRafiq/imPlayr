/* vim: set ft=objc fenc=utf-8 sw=2 ts=2 et: */
/*
 *  DOUAudioStreamer - A Core Audio based streaming audio player for iOS/Mac:
 *
 *      https://github.com/douban/DOUAudioStreamer
 *
 *  Copyright 2013-2014 Douban Inc.  All rights reserved.
 *
 *  Use and distribution licensed under the BSD license.  See
 *  the LICENSE file for full text.
 *
 *  Authors:
 *      Chongyu Zhu <i@lembacon.com>
 *
 */
#import "FileUtilities.h"
#import "AudioFile.h"
#import "HttpSource.h"
#include <CommonCrypto/CommonDigest.h>
#include <AudioToolbox/AudioToolbox.h>
#if TARGET_OS_IPHONE
#import "LocalAssetLoader.h"
#endif /* TARGET_OS_IPHONE */
static NSURL *gHintFile = nil;
static AudioFile *gHintProvider = nil;
static BOOL gLastProviderIsFinished = NO;
@implementation LocalAudioFile

- (instancetype)_initWithAudioFileURL:(NSURL *)url
{
    self = [super _initWithAudioFileURL:url];
    if (self) {
        _audioURL=url;
        _cachedURL = url;
        _cachedPath = [_cachedURL path];
        _isRemote=NO;
        BOOL isDirectory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cachedPath
                                                  isDirectory:&isDirectory] ||
            isDirectory) {
            return nil;
        }
        
        _mappedData = [NSData dataWithMappedContentsOfFile:_cachedPath];
        _expectedLength = [_mappedData length];
        _receivedLength = [_mappedData length];
    }
    
    return self;
}

- (NSString *)mimeType
{
    if (_mimeType == nil &&
        [self fileExtension] != nil) {
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self fileExtension], NULL);
        if (uti != NULL) {
            _mimeType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType));
            CFRelease(uti);
        }
    }
    
    return _mimeType;
}

- (NSString *)fileExtension
{
    if (_fileExtension == nil) {
        _fileExtension = [_audioURL pathExtension];
    }
    
    return _fileExtension;
}

- (NSString *)sha256
{
  
    if (_sha256 == nil  &&
        [self mappedData] != nil) {
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256([[self mappedData] bytes], (CC_LONG)[[self mappedData] length], hash);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
            [result appendFormat:@"%02x", hash[i]];
        }
        
        _sha256 = [result copy];
    }
    
    return _sha256;
      }

- (NSUInteger)downloadSpeed
{
    return _receivedLength;
}

- (BOOL)isReady
{
    return YES;
}

- (BOOL)isFinished
{
    return YES;
}

@end
#pragma mark - Concrete Audio Remote File Provider

@implementation RemoteAudioFile

@synthesize finished = _requestCompleted;

- (instancetype)_initWithAudioFileURL:(NSURL *)url
{
    
    self = [super _initWithAudioFileURL:url];
    if (self) {
        _isRemote=YES;
        _audioURL = url;
        
             _sha256Ctx = (CC_SHA256_CTX *)malloc(sizeof(CC_SHA256_CTX));
            CC_SHA256_Init(_sha256Ctx);
        
       
        [self _openAudioFileStream];
        [self _createRequest];
        [_request start];
    }
    
    return self;
}
- (void)dealloc
{
    @synchronized(_request) {
        [_request setCompletedBlock:NULL];
        [_request setProgressBlock:NULL];
        [_request setDidReceiveResponseBlock:NULL];
        [_request setDidReceiveDataBlock:NULL];
        
        [_request cancel];
    }
    
    if (_sha256Ctx != NULL) {
        free(_sha256Ctx);
    }
    
    [self _closeAudioFileStream];
    
         //[[NSFileManager defaultManager] removeItemAtPath:_cachedPath error:NULL];
    }

+ (NSString *)_sha256ForAudioFileURL:(NSURL *)audioFileURL
{
    NSString *string = [audioFileURL absoluteString];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], hash);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        [result appendFormat:@"%02x", hash[i]];
    }
    
    return result;
}

+ (NSString *)_cachedPathForAudioFileURL:(NSURL *)audioFileURL
{
    NSString *filename = [NSString stringWithFormat:@"imp-%@.mp3", [self _sha256ForAudioFileURL:audioFileURL]];
    
    NSString *cahc=[FileUtilities appHTTPCacheDirectory];
    return [cahc stringByAppendingPathComponent:filename];
}

- (void)_invokeEventBlock
{
    if (_eventBlock != NULL) {
        _eventBlock();
    }
}

- (void)_requestDidComplete
{
    if ([_request isFailed] ||
        !([_request statusCode] >= 200 && [_request statusCode] < 300)) {
        _failed = YES;
    }
    else {
        _requestCompleted = YES;
        [_mappedData synchronizeMappedFile];
    }
    
    if (!_failed &&
        _sha256Ctx != NULL) {
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256_Final(hash, _sha256Ctx);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
            [result appendFormat:@"%02x", hash[i]];
        }
        
        _sha256 = [result copy];
    }
    
    if (gHintFile != nil &&
        gHintProvider == nil) {
        gHintProvider = [[[self class] alloc] _initWithAudioFileURL:gHintFile];
    }
    
    [self _invokeEventBlock];
}

- (void)_requestDidReportProgress:(double)progress
{
    [self _invokeEventBlock];
}

- (void)_requestDidReceiveResponse
{
    _expectedLength = [_request responseContentLength];
    
    _cachedPath = [[self class] _cachedPathForAudioFileURL:_audioURL];
    _cachedURL = [NSURL fileURLWithPath:_cachedPath];
    
    [[NSFileManager defaultManager] createFileAtPath:_cachedPath contents:nil attributes:nil];
    [[NSFileHandle fileHandleForWritingAtPath:_cachedPath] truncateFileAtOffset:_expectedLength];
    
    _mimeType = [[_request responseHeaders] objectForKey:@"Content-Type"];
    
    _mappedData = [NSData modifiableDataWithMappedContentsOfFile:_cachedPath];
}

- (void)_requestDidReceiveData:(NSData *)data
{
    if (_mappedData == nil) {
        return;
    }
    
    NSUInteger availableSpace = _expectedLength - _receivedLength;
    NSUInteger bytesToWrite = MIN(availableSpace, [data length]);
    
    memcpy((uint8_t *)[_mappedData bytes] + _receivedLength, [data bytes], bytesToWrite);
    _receivedLength += bytesToWrite;
    
    if (_sha256Ctx != NULL) {
        CC_SHA256_Update(_sha256Ctx, [data bytes], (CC_LONG)[data length]);
    }
    
    if (!_readyToProducePackets && !_failed && !_requiresCompleteFile) {
        OSStatus status = kAudioFileStreamError_UnsupportedFileType;
        
        if (_audioFileStreamID != NULL) {
            status = AudioFileStreamParseBytes(_audioFileStreamID,
                                               (UInt32)[data length],
                                               [data bytes],
                                               0);
        }
        
        if (status != noErr && status != kAudioFileStreamError_NotOptimized) {
            NSArray *fallbackTypeIDs = [self _fallbackTypeIDs];
            for (NSNumber *typeIDNumber in fallbackTypeIDs) {
                AudioFileTypeID typeID = (AudioFileTypeID)[typeIDNumber unsignedLongValue];
                [self _closeAudioFileStream];
                [self _openAudioFileStreamWithFileTypeHint:typeID];
                
                if (_audioFileStreamID != NULL) {
                    status = AudioFileStreamParseBytes(_audioFileStreamID,
                                                       (UInt32)_receivedLength,
                                                       [_mappedData bytes],
                                                       0);
                    
                    if (status == noErr || status == kAudioFileStreamError_NotOptimized) {
                        break;
                    }
                }
            }
            
            if (status != noErr && status != kAudioFileStreamError_NotOptimized) {
                _failed = YES;
            }
        }
        
        if (status == kAudioFileStreamError_NotOptimized) {
            [self _closeAudioFileStream];
            _requiresCompleteFile = YES;
        }
        
 
    }
}

- (void)_createRequest
{
    _request = [HttpSource requestWithURL:_audioURL];
    __unsafe_unretained RemoteAudioFile *_self = self;
    
    [_request setCompletedBlock:^{
        [_self _requestDidComplete];
    }];
    
    [_request setProgressBlock:^(double downloadProgress) {
        [_self _requestDidReportProgress:downloadProgress];
    }];
    
    [_request setDidReceiveResponseBlock:^{
        [_self _requestDidReceiveResponse];
    }];
    
    [_request setDidReceiveDataBlock:^(NSData *data) {
        [_self _requestDidReceiveData:data];
    }];
}

- (void)_handleAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID
{
    if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
        _readyToProducePackets = YES;
    }
   
    
}

- (void)_handleAudioFileStreamPackets:(const void *)packets
                        numberOfBytes:(UInt32)numberOfBytes
                      numberOfPackets:(UInt32)numberOfPackets
                   packetDescriptions:(AudioStreamPacketDescription *)packetDescriptioins
{
}

static void audio_file_stream_property_listener_proc(void *inClientData,
                                                     AudioFileStreamID inAudioFileStream,
                                                     AudioFileStreamPropertyID inPropertyID,
                                                     UInt32 *ioFlags)
{
    __unsafe_unretained RemoteAudioFile *fileProvider = (__bridge RemoteAudioFile *)inClientData;
    [fileProvider _handleAudioFileStreamProperty:inPropertyID];
}

static void audio_file_stream_packets_proc(void *inClientData,
                                           UInt32 inNumberBytes,
                                           UInt32 inNumberPackets,
                                           const void *inInputData,
                                           AudioStreamPacketDescription	*inPacketDescriptions)
{
    __unsafe_unretained RemoteAudioFile *fileProvider = (__bridge RemoteAudioFile *)inClientData;
    [fileProvider _handleAudioFileStreamPackets:inInputData
                                  numberOfBytes:inNumberBytes
                                numberOfPackets:inNumberPackets
                             packetDescriptions:inPacketDescriptions];
}

- (void)_openAudioFileStream
{
    [self _openAudioFileStreamWithFileTypeHint:0];
}

- (void)_openAudioFileStreamWithFileTypeHint:(AudioFileTypeID)fileTypeHint
{
    OSStatus status = AudioFileStreamOpen((__bridge void *)self,
                                          audio_file_stream_property_listener_proc,
                                          audio_file_stream_packets_proc,
                                          fileTypeHint,
                                          &_audioFileStreamID);
    
    if (status != noErr) {
        _audioFileStreamID = NULL;
    }
}

- (void)_closeAudioFileStream
{
    if (_audioFileStreamID != NULL) {
        AudioFileStreamClose(_audioFileStreamID);
        _audioFileStreamID = NULL;
    }
}

- (NSArray *)_fallbackTypeIDs
{
    NSMutableArray *fallbackTypeIDs = [NSMutableArray array];
    NSMutableSet *fallbackTypeIDSet = [NSMutableSet set];
    
    struct {
        CFStringRef specifier;
        AudioFilePropertyID propertyID;
    } properties[] = {
        { (__bridge CFStringRef)[self mimeType], kAudioFileGlobalInfo_TypesForMIMEType },
        { (__bridge CFStringRef)[self fileExtension], kAudioFileGlobalInfo_TypesForExtension }
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

- (NSString *)fileExtension
{
    if (_fileExtension == nil) {
        _fileExtension = [[_audioURL path] pathExtension];
    }
    
    return _fileExtension;
}

- (NSUInteger)downloadSpeed
{
    return [_request downloadSpeed];
}

- (BOOL)isReady
{
    if (!_requiresCompleteFile) {
        return _readyToProducePackets;
    }
    
    return _requestCompleted;
}

@end

#pragma mark - Concrete Audio Media Library File Provider

#if TARGET_OS_IPHONE
@implementation iTunesAudioFile

- (instancetype)_initWithAudioFileURL:(NSURL *)url
{
    self = [super _initWithAudioFileURL:url];
    if (self) {
        _audioURL=url;
        [self _createAssetLoader];
        [_assetLoader start];
    }
    
    return self;
}

- (void)dealloc
{
    @synchronized(_assetLoader) {
        [_assetLoader setCompletedBlock:NULL];
        [_assetLoader cancel];
    }
    
 
}

- (void)_invokeEventBlock
{
    if (_eventBlock != NULL) {
        _eventBlock();
    }
}

- (void)_assetLoaderDidComplete
{
    if ([_assetLoader isFailed]) {
        _failed = YES;
        [self _invokeEventBlock];
        return;
    }
    
    _mimeType = [_assetLoader mimeType];
    _fileExtension = [_assetLoader fileExtension];
    
    _cachedPath = [_assetLoader cachedPath];
    _cachedURL = [NSURL fileURLWithPath:_cachedPath];
    
    _mappedData = [NSData dataWithMappedContentsOfFile:_cachedPath];
    _expectedLength = [_mappedData length];
    _receivedLength = [_mappedData length];
    
    _loaderCompleted = YES;
    [self _invokeEventBlock];
}

- (void)_createAssetLoader
{
    _assetLoader = [LocalAssetLoader loaderWithURL:_audioURL];
    
    __weak typeof(self) weakSelf = self;
    [_assetLoader setCompletedBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _assetLoaderDidComplete];
    }];
}

- (NSString *)sha256
{
    if (_sha256 == nil  &&
        [self mappedData] != nil) {
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256([[self mappedData] bytes], (CC_LONG)[[self mappedData] length], hash);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
            [result appendFormat:@"%02x", hash[i]];
        }
        
        _sha256 = [result copy];
    }
    
    return _sha256;
}

- (NSUInteger)downloadSpeed
{
    return _receivedLength;
}

- (BOOL)isReady
{
    return _loaderCompleted;
}

- (BOOL)isFinished
{
    return _loaderCompleted;
}

@end
#endif /* TARGET_OS_IPHONE */


@implementation AudioFile
@synthesize isRemote=_isRemote;
@synthesize audioURL = _audioURL;
@synthesize eventBlock = _eventBlock;
@synthesize cachedPath = _cachedPath;
@synthesize cachedURL = _cachedURL;
@synthesize mimeType = _mimeType;
@synthesize fileExtension = _fileExtension;
@synthesize sha256 = _sha256;
@synthesize mappedData = _mappedData;
@synthesize expectedLength = _expectedLength;
@synthesize receivedLength = _receivedLength;
@synthesize failed = _failed;

+ (instancetype)_audioFileWithURL:(NSURL *)url
{
    if (url == nil) {
        return nil;
    }
    
    
    
    if ([url isFileURL]) {
        return [[LocalAudioFile alloc] _initWithAudioFileURL:url];
    }
#if TARGET_OS_IPHONE
    else if ([[url scheme] isEqualToString:@"ipod-library"]) {
        return [[iTunesAudioFile alloc] _initWithAudioFileURL:url];
    }
#endif /* TARGET_OS_IPHONE */
    else {
        return [[RemoteAudioFile alloc] _initWithAudioFileURL:url];
    }
}
+ (instancetype)AudioFileWithURL:(NSURL *)url
{
    if ((url == gHintFile ||
         [url isEqual:gHintFile]) &&
        gHintProvider != nil) {
        AudioFile *provider = gHintProvider;
        gHintFile = nil;
        gHintProvider = nil;
        gLastProviderIsFinished = [provider isFinished];
        
        return provider;
    }
    
    gHintFile = nil;
    gHintProvider = nil;
    gLastProviderIsFinished = NO;
    
    return [self _audioFileWithURL:url];
}
+ (void)setHintWithAudioFile:(NSURL *)audioFile
{
    if (audioFile == gHintFile ||
        [audioFile isEqual:gHintFile]) {
        return;
    }
    
    gHintFile = nil;
    gHintProvider = nil;
    
    if (audioFile == nil) {
        return;
    }
    
    
    if (audioFile == nil ||
#if TARGET_OS_IPHONE
        [[audioFile scheme] isEqualToString:@"ipod-library"] ||
#endif /* TARGET_OS_IPHONE */
        [audioFile isFileURL]) {
        return;
    }
    
    gHintFile = audioFile;
    
    if (gLastProviderIsFinished) {
        gHintProvider = [self _audioFileWithURL:gHintFile];
    }
}
- (instancetype)_initWithAudioFileURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _audioURL = url;
    }
    
    return self;
}

- (NSUInteger)downloadSpeed
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (BOOL)isReady
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isFinished
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}
- (NSData *)handleData:(NSData *)data offset:(NSUInteger)offset
{
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
