//
//  Utitlities.m
//  AirDab
//
//  Created by Haris Rafiq on 10/30/13.
//  Copyright (c) 2013 Haris Rafiq. All rights reserved.
//

#import "Utitlities.h"
#import "AudioManager.h"
 #include <tgmath.h>
#import "imConstants.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Thumbnail.h"
 #define kIsDemo @"isDemoComplet23"
#import "imageManager.h"
@implementation Utitlities
+ (void)attachArtwork:(playrsTrack *)artwork toImageView:(UIImageView *)view thumbnail:(BOOL)thumbnail
{
    // use the tag property of UIView to determine if the image view has been reused before the artwork has finished loading. only set the image if the identifiers match
    __block NSInteger identifier = arc4random();
    view.tag = identifier;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        view.image =[UIImage imageNamed:@"placeholder-91-album.png"];
    });
 
    [Utitlities trackImageFromTrack:[artwork audioFileURL] withCompletionHandler:^(UIImage *image) {
        
        if(image!=nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (view.tag == identifier) {
                view.image = image;
            }
        });
        }
    }];
}



+(void)trackImageFromTrack:(NSURL *)url withCompletionHandler:(void (^)(UIImage *))handler
{
  
    
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    [asset loadValuesAsynchronouslyForKeys:@[@"commonMetadata"]
                         completionHandler:^{
                             UIImage *finalImage=nil;

                             NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                                withKey:AVMetadataCommonKeyArtwork
                                                                               keySpace:AVMetadataKeySpaceCommon];
                             for (AVMetadataItem *item in artworks)
                             {
                                 if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                                 {
                                     NSDictionary *dict = [item.value copyWithZone:nil];
                                     
                                     // 获取图片
                                     finalImage = [UIImage imageWithData:[dict objectForKey:@"data"]];
                                 }
                                 if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                                 {
                                     // 获取图片
                                     finalImage= [UIImage imageWithData:[item.value copyWithZone:nil]];
                                 }
                                 
                             }
                           
                             handler(finalImage);

                             
                         }];
    
    
   
    }

 


+(void)setNowPlayingInfo:(NSInteger)currentInx{
         Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter) {
            playrsTrack *t=[[AudioManager sharedInstance] currentTrack];
            UIImage *finalImage=[[AudioManager sharedInstance] nowPlayingImage];
            if(finalImage==nil){
                
                finalImage=[UIImage imageNamed:@"emptyQueue.png"];
                
            }

            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:finalImage];
            
            [songInfo setObject:[t title] forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[t artist]  forKey:MPMediaItemPropertyArtist];
            
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
             [songInfo setObject:[t duration] forKey:MPMediaItemPropertyPlaybackDuration];
             [songInfo setObject:[NSNumber numberWithDouble:0] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
             [songInfo setObject:[NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            songInfo=nil;
          
                         albumArt=nil;

            
        }
    
}

+ (NSString *)currencyStringValue:(double)d
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    return [formatter stringFromNumber:[NSNumber numberWithDouble:d]];
}
+ (NSString *)convertTimeFromSeconds:(NSString *)seconds {
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    NSInteger secs = [seconds integerValue];
    NSInteger tempHour    = 0;
    NSInteger tempMinute  = 0;
    NSInteger tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInteger:tempHour] stringValue];
    minute  = [[NSNumber numberWithInteger:tempMinute] stringValue];
    second  = [[NSNumber numberWithInteger:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
        
        
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    seconds=nil;
    return result;
    
}
 
+ (UIImage *)imageNamed:(UIImage *)img withColor:(UIColor *)color{
    
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

 
+(UIColor *)defaultFontColor{
    
    return [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0];
    
    
}

+(BOOL)isDemo{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults boolForKey:kIsDemo] ;
    
}
+(void)isDemoCompleted{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setBool:YES forKey:kIsDemo];
    
}
 @end


