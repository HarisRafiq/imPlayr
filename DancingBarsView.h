//
//  DancingBarsView.h
//  imPlayr2
//
//  Created by YAZ on 5/2/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DancingBarsView : UIView
{
    UIImageView *_imageView;

     UILabel *currentSongTime;
    UILabel *currentPlayingArtist;

}
- (void)playbackChanged;
-(void)refreshColors;
-(void)trackDidChanged;
-(void)setupForControlHeader;
-(void)updateTimeLabel;
-(void)changeItToConnectedView;
-(void)setCurrentSongTime:(NSString *)s;
-(void)changeItBackToPlayr; 
  @end
