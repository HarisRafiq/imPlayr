//
//  TopPlayerView.m
//  imPlayr2
//
//  Created by YAZ on 5/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "TopPlayerView.h"
#import "AudioManager.h"
#import "AudioManager.h"
 #import "imConstants.h"
@implementation TopPlayerView
@synthesize danceView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        middleView = [[UIView alloc] initWithFrame:CGRectMake(((self.bounds.size.width)/2)-(70/2) ,2.5, 70 , 70  )];
      
        
        middleView.backgroundColor=  [UIColor redColor];
        middleView.layer.cornerRadius=70/2;
        middleView.layer.borderWidth=1;
        middleView.clipsToBounds=YES;
        middleView.layer.borderColor=  [UIColor colorWithRed:0.0501961 green:0.0501961 blue:0.0501961 alpha:1.0].CGColor;
        [self addSubview:middleView];
        
        
        
       
        
        middleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,70 ,70)];
        [middleView addSubview:middleLabel];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(middleAction)];
        singleFingerTap.numberOfTapsRequired = 1;
        [middleView addGestureRecognizer:singleFingerTap];
        middleLabel.textColor=[UIColor whiteColor];
        middleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
        middleLabel.numberOfLines=0;
        middleLabel.text=@"Delete All";
        middleLabel.textAlignment=NSTextAlignmentCenter;
        leftView=[[UIView alloc] initWithFrame:CGRectMake(((self.bounds.size.width)/2)-70-60,10,60 ,60) ] ;
        leftView.backgroundColor=  [UIColor blackColor];
        leftView.layer.cornerRadius=60/2;
        leftView.layer.borderWidth=1;
        leftView.clipsToBounds=YES;
        leftView.layer.borderColor=  [UIColor colorWithRed:0.0501961 green:0.0501961 blue:0.0501961 alpha:1.0].CGColor;
        [self addSubview:leftView];
        leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,60 ,60)];
        [leftView addSubview:leftLabel];
        UITapGestureRecognizer *singleFingerTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftAction)];
        singleFingerTap.numberOfTapsRequired = 1;
        [leftView addGestureRecognizer:singleFingerTap2];
        leftLabel.textColor=[UIColor whiteColor];
        leftLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
        leftLabel.numberOfLines=1;
        leftLabel.text=@"Done";
        leftLabel.textAlignment=NSTextAlignmentCenter;
        
        
        
        rightView = [[UIView alloc] initWithFrame:CGRectMake(((self.bounds.size.width)/2)+70,10,60 ,60)];
        
        
        rightView.backgroundColor=  [UIColor blackColor];
        rightView.layer.cornerRadius=60/2;
        rightView.layer.borderWidth=1;
        rightView.clipsToBounds=YES;
        rightView.layer.borderColor=  [UIColor colorWithRed:0.0501961 green:0.0501961 blue:0.0501961 alpha:1.0].CGColor;
        [self addSubview:rightView];
        
        
        
        
        
        rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,60 ,60)];
        [rightView addSubview:rightLabel];
        UITapGestureRecognizer *singleFingerTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightAction)];
        singleFingerTap.numberOfTapsRequired = 1;
        [rightView addGestureRecognizer:singleFingerTap3];
        rightLabel.textColor=[UIColor whiteColor];
        rightLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
        rightLabel.numberOfLines=0;
        rightLabel.text=@"Save";
        rightLabel.textAlignment=NSTextAlignmentCenter;
        self.backgroundColor=[UIColor clearColor];
       
            }
    return self;
}
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshColors)
                                                 name:NOTIFICATION_COLORS_CHANGED
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playbackChanged)
                                                 name:NOTIFICATION_STREAMER_PLAYBACK_CHANGED
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_BUFFERING object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_IDLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PAUSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PLAYING_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_STARTED_PLAYING object:nil];
    [self refreshColors];
    [self playbackChanged];
}
-(void)removeNotification{


[[NSNotificationCenter defaultCenter] removeObserver:self
 ];

}
-(void)playbackChanged{

    [danceView playbackChanged];
    [danceView trackDidChanged ];
    
    
    
}


-(void)refreshColors{
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    
    if(isIPad)
    {    self.backgroundColor=[[AudioManager sharedInstance] bgColor];
    
    
    
    }else {
     self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];
    
    }
    [danceView refreshColors];
    [danceView trackDidChanged ];

}

-(void)setRepeatOn{
    leftLabel.text=@"Repeat On";
    leftLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    leftView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    leftView.layer.borderColor=  [[AudioManager sharedInstance] bgColorDark].CGColor;
    leftLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:10];


}

-(void)setShuffleOn{
    middleLabel.text=@"Shuffle On";
    middleLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    middleView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    middleView.layer.borderColor=  [[AudioManager sharedInstance] bgColorDark].CGColor;
    middleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:10];

    
}
-(void)setShuffleView{
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    
    if(isIPad)
    {    self.backgroundColor=[[AudioManager sharedInstance] bgColor];
        
        
        
    }else {
        self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];
        
    }
    leftLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
    middleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];

    middleView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    middleView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    middleLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    rightView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    rightView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    rightLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    leftView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    leftView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    leftLabel.textColor=[[AudioManager sharedInstance] secondaryColor];

    middleLabel.text=@"Shuffle";
    
    rightLabel.text=@"Edit";
    leftLabel.text=@"Repeat";
if([[AudioManager sharedInstance] isRepeatOn])
{

    [self setRepeatOn];
}
    if([[AudioManager sharedInstance] isShuffleOn])
    {
        
        [self setShuffleOn];
    }
}

-(void)setEditView{
     middleView.backgroundColor=  [UIColor redColor];
    middleView.layer.borderColor=  [UIColor colorWithRed:0.0501961 green:0.0501961 blue:0.0501961 alpha:1.0].CGColor;
    
    middleLabel.textColor=[UIColor whiteColor];
    middleLabel.text=@"Clear";

    rightLabel.text=@"Save";
    leftLabel.text=@"Done";

}

-(void)setMiddleText:(NSString * )s{
    middleLabel.text=s;


}
-(void)setLeftText:(NSString * )s{
    leftLabel.text=s;
    
    
}

- (void)controlTouchedAt:(NSInteger)i {
	// blowUp animation
  		[_delegate topPlayer:(id)self didSelectIndex:i];
	 
}
-(void)middleAction{
    [self controlTouchedAt:1];

}
-(void)leftAction{
    [self controlTouchedAt:0];

    
}
-(void)rightAction{
    [self controlTouchedAt:2];

    
}

-(void)setEditViewForControlHeader{
    leftView.backgroundColor=  [UIColor redColor];
    leftView.layer.borderColor=  [UIColor colorWithRed:0.0501961 green:0.0501961 blue:0.0501961 alpha:1.0].CGColor;
    
    leftLabel.textColor=[UIColor whiteColor];

    
    leftLabel.text=@"Clear";
    rightLabel.text=@"Done";


}

-(void)setControlView{
    leftLabel.text=@"Home";
    rightLabel.text=@"Edit";
    rightView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    rightView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    rightLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    leftView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    leftView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    leftLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];

}
-(void)setupForControlHeader{
    [middleView setFrame:CGRectMake(((self.bounds.size.width)/2)-(75/2) ,0, 75 , 75  )];
    

    middleView.backgroundColor=  [UIColor clearColor];

    middleView.layer.cornerRadius=0;
    middleView.layer.borderWidth=0;

    danceView=[[DancingBarsView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [middleLabel removeFromSuperview];
    [middleView addSubview:danceView];
    [danceView setupForControlHeader];

    leftLabel.text=@"Home";
    rightLabel.text=@"Edit";
    self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];


}
-(void)setControlForSubHeader{
    self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];

    leftLabel.text=@"Back";
    rightLabel.text=@"Edit";
    rightView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    rightView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    rightLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    leftView.backgroundColor=  [[AudioManager sharedInstance] bgColor];
    leftView.layer.borderColor=  [[AudioManager sharedInstance] primaryColor].CGColor;
    leftLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
 }
-(void)setupForControlForSubHeader{
    [middleView setFrame:CGRectMake(((self.bounds.size.width)/2)-(75/2) ,0, 75 , 75  )];
    
    
    middleView.backgroundColor=  [UIColor clearColor];
    
    middleView.layer.cornerRadius=0;
    middleView.layer.borderWidth=0;
    
    danceView=[[DancingBarsView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [middleLabel removeFromSuperview];
    [middleView addSubview:danceView];
    [danceView setupForControlHeader];
    
    leftLabel.text=@"Back";
    rightLabel.text=@"Edit";
    self.backgroundColor=[[AudioManager sharedInstance] bgColorDark];

    
    
}
-(void)setupForSongView{
    [self setupForControlHeader];
    rightView.hidden=YES;
}
@end
