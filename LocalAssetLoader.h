//
//  LocalAssetLoader.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>

typedef void (^LocalAssetLoaderCompletedBlock)(void);

@interface LocalAssetLoader : NSObject

+ (instancetype)loaderWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, strong, readonly) NSString *cachedPath;
@property (nonatomic, strong, readonly) NSString *mimeType;
@property (nonatomic, strong, readonly) NSString *fileExtension;

@property (nonatomic, assign, readonly, getter = isFailed) BOOL failed;

@property (copy) LocalAssetLoaderCompletedBlock completedBlock;

- (void)start;
- (void)cancel;

@end

#endif  
 