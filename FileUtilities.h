//
//  FileUtilities.h
//  IMP
//
//  Created by YAZ on 3/22/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtilities : NSObject
+(FileUtilities*)getInstance;
+(NSString *)appIpodCacheDirectory;
+ (NSString *)appFilesDirectory;
+ (NSString *)appPlaylistDirectory;
+(NSString *)appHTTPCacheDirectory;
+ (NSString *)appNowPlayingDirectory
;
+ (NSString *)appImageDirectory;
+(void)deleteFileWithName:(NSString *)name;
@end
