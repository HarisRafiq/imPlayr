//
//  imNowPlayingViewController.h
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "playrsTrack.h"
#import "playrsMemory.h"
 #import "AudioManager.h"
#import "TopPlayerView.h"
@protocol imNowPlayingViewControllerDelegate <NSObject>

 
@optional

- (void)dismissNowPlaying;

@end

@interface imNowPlayingViewController : UIView<UITableViewDataSource, UITableViewDelegate,TopPlayerViewDelegate>
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIView * bottomView;
@property (strong, nonatomic) UILabel * closeLabel;
@property (nonatomic, weak) id <imNowPlayingViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *tracks;
-(void)switchToiPad;
-(void)setTracks;
-(void)cleanUp;
-(void)addNotfification;


@end
