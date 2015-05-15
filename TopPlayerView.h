//
//  TopPlayerView.h
//  imPlayr2
//
//  Created by YAZ on 5/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DancingBarsView.h"
@class TopPlayerView;
@protocol TopPlayerViewDelegate <NSObject>

 

@optional

- (void)topPlayer:(TopPlayerView *)topPlayer didSelectIndex:(NSInteger)selectedIndex;

@end
@interface TopPlayerView : UIView{
        UIView *leftView;
    UIView *middleView;
    UIView *rightView;
    UILabel *middleLabel;
    UILabel *rightLabel;
    UILabel *leftLabel;
     BOOL isEdit;
 
}
-(void)setupForSongView;
-(void)setControlForSubHeader;
-(void)setupForControlForSubHeader;
-(void)setEditViewForControlHeader;
-(void)setupForControlHeader;
-(void)setControlView;
-(void)setRepeatOn;
-(void)setShuffleView;
-(void)setEditView;
-(void)setMiddleText:(NSString * )s;
-(void)setLeftText:(NSString * )s;
-(void)addNotification;
-(void)removeNotification;
@property (nonatomic, strong) DancingBarsView *danceView;

@property (nonatomic, weak) id <TopPlayerViewDelegate> delegate;

 @end
