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
#import "NSData+DOUMappedFile.h"

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <AudioToolbox/AudioToolbox.h>
#import "HttpSource.h"
#if TARGET_OS_IPHONE
#include <MobileCoreServices/MobileCoreServices.h>
#else /* TARGET_OS_IPHONE */
#include <CoreServices/CoreServices.h>
#endif /* TARGET_OS_IPHONE */

#if TARGET_OS_IPHONE
#import "LocalAssetLoader.h"
#endif


typedef void (^AudioFileEventBlock)(void);

@interface AudioFile : NSObject
{
    AudioFileEventBlock _eventBlock;
    NSString *_cachedPath;
    NSURL *_cachedURL;
    NSString *_mimeType;
    NSString *_fileExtension;
    NSString *_sha256;
    NSData *_mappedData;
    NSUInteger _expectedLength;
    NSUInteger _receivedLength;
    BOOL _failed;
    NSURL *_audioURL;
    BOOL _isRemote;

}
@property (nonatomic, copy) AudioFileEventBlock eventBlock;

@property (nonatomic, readonly) NSString *cachedPath;
@property (nonatomic, readonly) NSURL *cachedURL;
@property (nonatomic, readonly) NSURL *audioURL;
@property (nonatomic, readonly) BOOL isRemote;

@property (nonatomic, readonly) NSString *mimeType;
@property (nonatomic, readonly) NSString *fileExtension;
@property (nonatomic, readonly) NSString *sha256;

@property (nonatomic, readonly) NSData *mappedData;

@property (nonatomic, readonly) NSUInteger expectedLength;
@property (nonatomic, readonly) NSUInteger receivedLength;
@property (nonatomic, readonly) NSUInteger downloadSpeed;

@property (nonatomic, readonly, getter = isFailed) BOOL failed;
@property (nonatomic, readonly, getter = isReady) BOOL ready;
@property (nonatomic, readonly, getter = isFinished) BOOL finished;

+ (instancetype)AudioFileWithURL:(NSURL *)url;
- (instancetype)_initWithAudioFileURL:(NSURL *)url;
+ (void)setHintWithAudioFile:(NSURL *)audioFile;



- (NSData *)handleData:(NSData *)data offset:(NSUInteger)offset;

@end
@interface LocalAudioFile : AudioFile
@end

@interface RemoteAudioFile : AudioFile {
@private
    HttpSource *_request;
    
    CC_SHA256_CTX *_sha256Ctx;
    
    AudioFileStreamID _audioFileStreamID;
    BOOL _requiresCompleteFile;
    BOOL _readyToProducePackets;
    BOOL _requestCompleted;
}

@end
#if TARGET_OS_IPHONE
@interface iTunesAudioFile : AudioFile {
@private
    LocalAssetLoader *_assetLoader;
    BOOL _loaderCompleted;
}
@end
#endif
