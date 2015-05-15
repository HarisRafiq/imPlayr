//
//  HttpSource.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^HTTPRequestCompletedBlock)(void);
typedef void (^HTTPRequestProgressBlock)(double downloadProgress);
typedef void (^HTTPRequestDidReceiveResponseBlock)(void);
typedef void (^HTTPRequestDidReceiveDataBlock)(NSData *data);


@interface HttpSource : NSObject{
@private
    HTTPRequestCompletedBlock _completedBlock;
    HTTPRequestProgressBlock _progressBlock;
    HTTPRequestDidReceiveResponseBlock _didReceiveResponseBlock;
    HTTPRequestDidReceiveDataBlock _didReceiveDataBlock;
    
    NSString *_userAgent;
    NSTimeInterval _timeoutInterval;
    
    CFHTTPMessageRef _message;
    CFReadStreamRef _responseStream;
    
    NSDictionary *_responseHeaders;
    NSMutableData *_responseData;
    NSString *_responseString;
    
    NSInteger _statusCode;
    NSString *_statusMessage;
    BOOL _failed;
    
    CFAbsoluteTime _startedTime;
    NSUInteger _downloadSpeed;
    
    NSUInteger _responseContentLength;
    NSUInteger _receivedLength;
}



+ (instancetype)requestWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

+ (NSTimeInterval)defaultTimeoutInterval;
+ (NSString *)defaultUserAgent;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong) NSString *userAgent;

@property (nonatomic, readonly) NSData *responseData;
@property (nonatomic, readonly) NSString *responseString;

@property (nonatomic, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSUInteger responseContentLength;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSString *statusMessage;

@property (nonatomic, readonly) NSUInteger downloadSpeed;
@property (nonatomic, readonly, getter = isFailed) BOOL failed;

@property (copy) HTTPRequestCompletedBlock completedBlock;
@property (copy) HTTPRequestProgressBlock progressBlock;
@property (copy) HTTPRequestDidReceiveResponseBlock didReceiveResponseBlock;
@property (copy) HTTPRequestDidReceiveDataBlock didReceiveDataBlock;

- (void)start;
- (void)cancel;

@end

