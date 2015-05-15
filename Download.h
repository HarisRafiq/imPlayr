//
//  Download.h
//  imPlayr2
//
//  Created by YAZ on 5/23/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Download : NSObject <NSCoding>
@property (copy, nonatomic) void (^progressBlock)(NSURL *url, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
-(void)setProgressBlock:(void (^)(NSURL *url, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))progressBlock;
+(Download *)downloadTaskForURL:(NSURL *)url;
@property (copy, nonatomic) void (^completionBlock)(BOOL success, NSError *error);
-(void)setCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock;
-(void)start;
-(void)cancel;
-(void)resumeOrPause;
@property (strong, nonatomic, readonly) NSURL *url;
@property (weak, nonatomic, readonly) id downloadTask;
- (NSString *)fileName;

@end
