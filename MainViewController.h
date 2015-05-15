//
//  MainViewController.h
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

 #import <UIKit/UIKit.h>
#import "CircularSlider.h"
 #import "DESlideToConfirmView.h"
#import "DancingBarsView.h"
#import "CustomSilderRightView.h"
#import "imNowPlayingViewController.h"
#import "RNGridMenu.h"
#import "dance.h"
#import "imStreamer.h"
#import "Utitlities.h"
#import "UIImage+Thumbnail.h"
#import "imConstants.h"
#import  "UIImage+StackBlur.h"
#import "DZWebBrowser.h"

 @interface MainViewController : UIViewController
-(void)toggleMenu;
-(void)setupRemoteControlView;
@property (strong, nonatomic) imStreamer *imStream;

@property (strong, nonatomic) dance *visualizeView;
@property (nonatomic, strong) UITapGestureRecognizer *tapreog;

@property (nonatomic, strong) DESlideToConfirmView *slideToConfirmView;
@property (nonatomic, strong) DZWebBrowser *webBrowser;

@property (nonatomic, strong) NSTimer *positionTimer;




@end
