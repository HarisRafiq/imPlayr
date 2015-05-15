//
//  AudioControlsView.h
//  AirDab
//
//  Created by YAZ on 2/5/14.
//  Copyright (c) 2014 AirWalker. All rights reserved.
//
#import "AudioPlayer.h"
#import "Utitlities.h"
  #import <UIKit/UIKit.h>
#import "MTZSlider.h"
 
   @interface AudioControlsView : UIView<MPMediaPickerControllerDelegate>
{
    
    UIButton *nextButton;
    UIButton *prevButton;
    UIImageView *playButton;
    UIView *bottomView;
    UIView *playBar;
     UITapGestureRecognizer *tapGesture;
    UILabel *broadcastLabel;
    UILabel *broadcastStatusLabel;
    UILabel *artistLabel;
    UILabel *durationLabel;
    UILabel *songLabel;
 
    UILabel *_leftLabel;
    UILabel *_rightLabel;
       UIView *seekBar;
 
}
 @property (strong, nonatomic) MPMusicPlayerController *player;
-(void)broadCastStartedOn:(NSString *)s;


@property (nonatomic, strong) NSTimer *positionTimer;
@property (strong, nonatomic) MTZSlider *trackSlider;
@end
