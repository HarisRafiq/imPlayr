//
//  TrackExporter.h
//  imPlayr2
//
//  Created by YAZ on 6/11/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TrackExporter : NSObject{
     NSString *_cachedPath;
    AVAssetExportSession *_exportSession;
}
@property (nonatomic, strong, readonly) NSURL *assetURL;
typedef void (^TrackExporterCompletedBlock)(void);
@property (copy) TrackExporterCompletedBlock completedBlock;
@property (nonatomic, assign, readonly, getter = isFailed) BOOL failed;
+ (instancetype)loaderWithURL:(NSURL *)url;
- (NSString *)cachedPath;
- (void)start;
- (void)cancel;
@end
