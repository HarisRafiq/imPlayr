//
//  Utitlities.h
//  AirDab
//
//  Created by Haris Rafiq on 10/30/13.
//  Copyright (c) 2013 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class playrsTrack;
@interface Utitlities : NSObject
+ (NSString *)convertTimeFromSeconds:(NSString *)seconds ;
+(void)setNowPlayingInfo:(NSInteger)currentInx;
 +(void)trackImageFromTrack:(playrsTrack *)track;
 
+(UIColor *)defaultFontColor;
 + (UIImage *)imageNamed:(UIImage *)img withColor:(UIColor *)color;
+(void)isDemoCompleted;
+(BOOL)isDemo;
+ (NSString *)currencyStringValue:(double)d;
+(void)trackImageFromTrack:(NSURL *)url withCompletionHandler:(void (^)(UIImage *))handler;
+ (void)attachArtwork:(playrsTrack *)artwork toImageView:(UIImageView *)view thumbnail:(BOOL)thumbnail;
@end
 
 