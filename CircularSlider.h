//
//  CircularSlider.h
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TB_BACKGROUND_WIDTH 10.0
#define TB_LINE_WIDTH 10.0                             

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height >= 568.0f)

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 10
#define TB_IMAGE_PADDING ((TB_SAFEAREA_PADDING*2)+10)


@interface CircularSlider : UIControl{
int radius;
    float TB_SLIDER_SIZE;
    float IMAGE_SIZE;

}
@property (nonatomic,assign) float angle;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end
