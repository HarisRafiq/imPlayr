//
//  BottomView.h
//  AirDab
//
//  Created by YAZ on 2/9/14.
//  Copyright (c) 2014 AirWalker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"
#import "Utitlities.h"
 #import <UIKit/UIKit.h>
#import "MTZSlider.h"
#import "dance.h"
#import "InAppPurchaseManager.h"
 
#import "SevenSwitch.h"
#import "dance.h"
@interface BottomView : UIView<MPMediaPickerControllerDelegate>
{
       SevenSwitch *mySwitch3;
 
   
    SevenSwitch *broadcastSwitch;

    UIButton *colorButton;

        UIView *volumeBar;
    UIImageView *speakerOn;
     
    UIImageView *speakerOff;
    UIImageView *visualizerOn;
    
    
    UIImageView *visualizerOff;
  UIImageView *broadCastOn;
    UIImageView *broadCastOff;

    UILabel *broadcastAddress;

    BOOL isViusalizerHidden;
 }
-(void)setHttpON;
-(void)setHttpOFF;
@property (strong, nonatomic) dance *visualizeView;

@property (strong, nonatomic) MPMusicPlayerController *player;
 
@property (strong, nonatomic) MTZSlider *volumeSlider;

@property (nonatomic, strong) InAppPurchaseManager *purchaseManager;

  @end
