//
//  DownloadManager.h
//  imPlayr2
//
//  Created by YAZ on 5/23/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"
@class Download;
@interface DownloadManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate,
NSURLSessionDownloadDelegate>
+(id)sharedInstance;
 
@property (copy, nonatomic, readonly) NSMutableDictionary *tasks;
-(Download *)downloadForURL:(NSURL *)url;
-(Download *)downloadForURL:(NSURL *)url withResumeData:(NSData *)data;
-(Download *)downloadForURLRequest:(NSURLRequest *)request;
-(BOOL)cancelDownloadForURL:(NSURL *)url;
-(void)saveDownloads;
@end
