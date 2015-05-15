//
//  imageManager.h
//  imPlayr2
//
//  Created by YAZ on 6/6/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUtilities.h"

@interface imageManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *images;

@property (nonatomic, strong) NSMutableDictionary *internalDownloader;

+(imageManager*)getInstance;
- (BOOL)save;
-(void)removeImageForUrl:(NSArray *)a;
-(void)addImageURL:(NSString *)url WithKey:(NSString *)key;
-(NSArray * )loadImagesForTrack:(NSString *)pList;
-(void)addImageURL:(NSString *)url ForTrack:(NSString *)s;
+(void)saveToFile:(UIImage *)image;
+ (UIImage *) imageForURL:(NSString *)fileName;
+(void)removeFileForTrack:(NSString *)s;

@end
