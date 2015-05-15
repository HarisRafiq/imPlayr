//
//  playrsTrack.h
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface playrsTrack : NSObject<NSCoding>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *album;
@property (nonatomic) BOOL  isRemote;
 @property (nonatomic, strong) NSURL *audioFileURL;

@property (nonatomic, strong) NSString *audioFileURLstr;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) UIImage *artworkThumbnail;
 -(id)initItemWithFilePath:(NSString *)filePath;
@end