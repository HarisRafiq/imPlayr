//
//  TrackExporter.m
//  imPlayr2
//
//  Created by YAZ on 6/11/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//
#include <CommonCrypto/CommonDigest.h>

#import "TrackExporter.h"
 #import "FileUtilities.h"
#if TARGET_OS_IPHONE
#include <MobileCoreServices/MobileCoreServices.h>
#else /* TARGET_OS_IPHONE */
#include <CoreServices/CoreServices.h>
#endif /* TARGET_OS_IPHONE */
@implementation TrackExporter
+ (instancetype)loaderWithURL:(NSURL *)url
{
    return [[[self class] alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _assetURL = url;
    }
    
    return self;
}
- (void)start
{
    if (_exportSession != nil) {
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:_assetURL];
    if (asset == nil) {
        [self _reportFailure];
        return;
    }
    _exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                       presetName:AVAssetExportPresetPassthrough];
    if (_exportSession == nil) {
        [self _reportFailure];
        return;
    }
    [_exportSession setShouldOptimizeForNetworkUse:YES];
    [_exportSession setOutputFileType:@"com.apple.quicktime-movie"];
    NSString *extension = (__bridge  NSString *)UTTypeCopyPreferredTagWithClass((__bridge  CFStringRef)_exportSession.outputFileType, kUTTagClassFilenameExtension);
    NSString *filename = [NSString stringWithFormat:@"imp-local-%@.%@", [[self class] _sha256ForURL:_assetURL], extension];
    
    NSString *basePath = [FileUtilities appIpodCacheDirectory];
    
    NSString *file = [basePath stringByAppendingPathComponent:filename];
    [_exportSession setOutputURL:[NSURL fileURLWithPath:file]];
    
    __weak typeof(self) weakSelf = self;
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSFileManager *manage = [NSFileManager defaultManager];
        [manage moveItemAtPath:file toPath:[self cachedPath] error:nil];
        [strongSelf _exportSessionDidComplete];
        
        
    }];
}

- (void)cancel
{
    if (_exportSession == nil) {
        return;
    }
    
    [_exportSession cancelExport];
    _exportSession = nil;
}

- (void)_exportSessionDidComplete
{
    if ([_exportSession status] != AVAssetExportSessionStatusCompleted ||
        [_exportSession error] != nil) {
        [self _reportFailure];
        return;
    }
    
    
    [self _invokeCompletedBlock];
}

- (void)_invokeCompletedBlock
{
    @synchronized(self) {
        if (_completedBlock != NULL) {
            _completedBlock();
        }
    }
}

- (void)_reportFailure
{
    _failed = YES;
    [self _invokeCompletedBlock];
}

- (NSString *)cachedPath
{
    if (_cachedPath == nil) {
        NSString *filename = [NSString stringWithFormat:@"imp-local-%@.%@", [[self class] _sha256ForURL:_assetURL], [self fileExtension]];
        
        NSString *basePath = [FileUtilities appIpodCacheDirectory];
        
        _cachedPath = [basePath stringByAppendingPathComponent:filename];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_cachedPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_cachedPath error:NULL];
        }
    }
    
    return _cachedPath;
}


- (NSString *)mimeType
{
    return AVFileTypeMPEGLayer3;
}

- (NSString *)fileExtension
{
    return @"mp3";
}

+ (NSString *)_sha256ForURL:(NSURL *)url
{
    NSString *string = [url absoluteString];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], hash);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        [result appendFormat:@"%02x", hash[i]];
    }
    
    return result;
}



@end

 
