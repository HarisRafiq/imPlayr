//
//  Download.m
//  imPlayr2
//
//  Created by YAZ on 5/23/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "Download.h"
#import "FileUtilities.h"
#import "DownloadManager.h"
@interface DownloadManager (Private)

-(void)saveDownloads;

@end

@interface Download ()

/**
 This is the underlying download task associated with the object
 */
@property (weak, nonatomic, readwrite) id downloadTask;

/**
 The download url
 */
@property (strong, nonatomic, readwrite) NSURL *url;

@end
@implementation Download
- (id)initPrivate
{
    if (self = [super init]) {
        _downloadTask = nil;
        _url = nil;
        
    }
    return self;
}
- (id)init
{
    return nil;

}

-(void)resumeOrPause
{
    NSURLSessionTask *task = [self downloadTask];
    
    if (task.state == NSURLSessionTaskStateRunning)
    {
        [task suspend];
    } else if (task.state == NSURLSessionTaskStateSuspended)
    {
        [task resume];
    }
}
+(Download *)downloadTaskForURL:(NSURL *)url
{
    Download *task = [[DownloadManager sharedInstance] downloadForURL:url];
    return task;
}


-(void)start
{
    // save the downloads (directory path, name) before starting it
    [[DownloadManager sharedInstance] saveDownloads];
    
    // start
    [[self downloadTask] resume];
}

/**
 Cancel the download - private
 */
-(void)cancel
{
    [[DownloadManager sharedInstance] cancelDownloadForURL:self.url];
}
-(void)cancelPrivate
{
    [[self downloadTask] cancel];
}

- (NSString *)fileName
{
    
        NSString *filename = [NSString stringWithString:[self.url.absoluteString lastPathComponent]];
        return [[filename componentsSeparatedByString:@"?"] firstObject];
     }


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:@"url"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initPrivate];
    if (self) {
        _url = [aDecoder decodeObjectForKey:@"url"];
 
        
    }
    return self;
}

@end
