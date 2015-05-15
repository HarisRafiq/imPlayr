//
//  FileUtilities.m
//  IMP
//
//  Created by YAZ on 3/22/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "FileUtilities.h"

@implementation FileUtilities
+(FileUtilities*)getInstance
{
    static FileUtilities *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[FileUtilities alloc] init];
    });
    return sharedMyManager;
}
+(NSString *)appIpodCacheDirectory{

NSString *basePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"iPod"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    return basePath
    ;
}
+(NSString *)appHTTPCacheDirectory{
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [searchPaths[0] stringByAppendingPathComponent:@"Files"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath])
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}
+ (NSString *)appFilesDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [searchPaths[0] stringByAppendingPathComponent:@"Files"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath])
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}
+ (NSString *)appImageDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [searchPaths[0] stringByAppendingPathComponent:@"Images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath])
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}
+ (NSString *)appPlaylistDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [searchPaths[0] stringByAppendingPathComponent:@"Playlists"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath])
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}
+ (NSString *)appNowPlayingDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [searchPaths[0] stringByAppendingPathComponent:@"NowPlaying"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath])
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}
+(void)deleteFileWithName:(NSString *)name{
    
    
    NSString *basePath = [FileUtilities appFilesDirectory];
    NSString *finalFilePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:finalFilePath])
        [fileManager removeItemAtPath:finalFilePath error:nil];
}
@end
