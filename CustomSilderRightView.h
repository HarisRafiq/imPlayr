//
//  CustomSilderRightView.h
//  imPlayr2
//
//  Created by YAZ on 5/29/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSilderRightView : UIView{

    BOOL isEditMode;

    UIImageView *_imageView;
    
        UILabel *currentSongTime;
        UILabel *currentPlayingArtist;
        
    BOOL isOn;

}
-(void)changeItToConnectedView;
 -(void)updateTimeLabel;
-(void)refreshColors;
 @end
