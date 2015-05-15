//
//  AudioControlsView.m
//  AirDab
//
//  Created by YAZ on 2/5/14.
//  Copyright (c) 2014 AirWalker. All rights reserved.
//

#import "AudioControlsView.h"
#import "AudioManager.h"
#import "imStreamer.h"
@implementation AudioControlsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
            [self setupViews];
 
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(handleEnteredBackground:)
                                                         name: UIApplicationDidEnterBackgroundNotification
                                                       object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(handleEnteredForgorund:)
                                                         name: UIApplicationWillEnterForegroundNotification
                                                       object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshColors) name:NOTIFICATION_COLORS_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_BUFFERING object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_IDLE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PAUSED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PLAYING_ERROR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_STARTED_PLAYING object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamerPlaybackChanged) name:NOTIFICATION_STREAMER_PLAYBACK_CHANGED object:nil];
            [self setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.95]];
        
  
        [self setupPlayButtons];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    }
        return self;
}
-(void)broadCastStartedOn:(NSString *)s{


    broadcastStatusLabel.text=s ;


}

    -(void)handleEnteredForgorund:(id)s{
        [self playbackChanged];
       
     }
    
-(void)streamerPlaybackChanged{
    if([[imStreamer sharedInstance ] isHTTPRunning] ) {
        
        if([[imStreamer sharedInstance] isPlaying])
        {
                         [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ppause" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
            
        }
        
        else {
                                 [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];

        }

    }
}
    -(void)handleEnteredBackground:(id)s{
        [self stopTimer];
    }
    -(void)cleanup{
        [self stopTimer];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
             
        if(artistLabel)
        {
            [artistLabel removeFromSuperview];
            artistLabel=nil;
            
        }
        
        if(songLabel)
        {
            [songLabel removeFromSuperview];
            songLabel=nil;
            
        }
        
        if(_trackSlider)
        {
             [_trackSlider removeFromSuperview];
            _trackSlider=nil;
            
        }
        if(_rightLabel)
        {
            
            [_rightLabel removeFromSuperview];
            _rightLabel=nil;
            
        }
        if(_leftLabel)
        {
            
            [_leftLabel removeFromSuperview];
            _leftLabel=nil;
            
        }
        
     
        
         }
- (void)playbackChanged
{
    if([[AudioManager sharedInstance ] currentStreamer]!=nil){
        switch ([[[AudioManager sharedInstance ] currentStreamer] status]) {
            case AudioStreamerPlaying:
                       [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ppause" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
        
                [self startTimer];
                
                break;
                
            case AudioStreamerPaused:
                
                [self stopTimer];
                         [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
                
                break;
                
            case AudioStreamerIdle:
                
                [self stopTimer];
                       [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
                
                break;
                
            case AudioStreamerFinished:
                
                [self stopTimer];
                         [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
                break;
                
            case AudioStreamerBuffering:
                
                [self stopTimer];
                        [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
                break;
                
            case AudioStreamerError:
                
                [self stopTimer];
                        [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
                break;
        }
        
        
    }
    else {
    
       [playButton setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pplay" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]] ];
    }
    
}
    -(void)setupViews{
        broadcastStatusLabel =  [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4,30,self.bounds.size.width/2,17) ] ;
        broadcastLabel =  [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4,5,self.bounds.size.width/2,19) ] ;
        
        [broadcastStatusLabel setBackgroundColor:[UIColor clearColor]]  ;
        
        broadcastLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:19];
        broadcastStatusLabel.textAlignment=NSTextAlignmentCenter;
        //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        
        [self addSubview:broadcastLabel];
        
        
        [broadcastLabel setBackgroundColor:[UIColor clearColor]]  ;
        broadcastStatusLabel.textColor= broadcastLabel.textColor=[UIColor colorWithRed:0.95  green:0.95 blue:0.95 alpha:1.0];
        broadcastStatusLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:17];
        broadcastLabel.textAlignment=NSTextAlignmentCenter;
        
        [self addSubview:broadcastStatusLabel];
   
        
            artistLabel =  [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4,30,self.bounds.size.width/2,17) ] ;
            songLabel =  [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/4,5,self.bounds.size.width/2,19) ] ;

        [artistLabel setBackgroundColor:[UIColor clearColor]]  ;
        
        songLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:19];
        artistLabel.textAlignment=NSTextAlignmentCenter;
        //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        
      [self addSubview:artistLabel];
        
        
        [songLabel setBackgroundColor:[UIColor clearColor]]  ;
        artistLabel.textColor= songLabel.textColor=[UIColor colorWithRed:0.95  green:0.95 blue:0.95 alpha:1.0];
        artistLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:17];
        songLabel.textAlignment=NSTextAlignmentCenter;
        
     [self addSubview:songLabel];
        broadcastLabel.text=@"Broadcast" ;
         broadcastStatusLabel.text=@"Off" ;
        
        artistLabel.text=@"imPlayr" ;
       //songLabel.text=@"imewewewewewewewewewewewewewewewewewewewcxzcxczxcczxczxc";
            [self setupTrackSlider];
        
        
    }
    -(void)setupTrackSlider{
              seekBar=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-22,self.bounds.size.width, 20)];
        
         _trackSlider = [[MTZSlider alloc] initWithFrame:(CGRect){40,1,seekBar.bounds.size.width-80,16}];
        
        
        _leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,3,36,12)];
        _rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(seekBar.bounds.size.width-36, 3,36,12)];
       
        [self addSubview:seekBar];
        
        _trackSlider.tintColor = [UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0];
        
        _trackSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _trackSlider.fillImage =       [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track_Fill" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
        _trackSlider.trackImage =  [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
        
        [_trackSlider setThumbImage:   [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Thumb" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]
                           forState:UIControlStateNormal];
        [seekBar addSubview:_trackSlider];
        
        _rightLabel.textColor=_leftLabel.textColor =  [UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0];
        [_leftLabel setBackgroundColor:[UIColor clearColor]];
        [_rightLabel setBackgroundColor:[UIColor clearColor]];
        _leftLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12];
        _leftLabel.textAlignment=NSTextAlignmentRight;
        _rightLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12];
        _rightLabel.textAlignment=NSTextAlignmentLeft;
        _rightLabel.text=_leftLabel.text=@"0:00";
        [self updateTimeLabel];
        [seekBar addSubview:_leftLabel];
        [seekBar addSubview:_rightLabel];
        
        [_trackSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];

        
    }
    

        -(void)refreshColors{
     bottomView.layer.backgroundColor=[[AudioManager sharedInstance] bgColor].CGColor;
            bottomView.layer.borderColor=[[AudioManager sharedInstance] primaryColor].CGColor;
                 [self setBackgroundColor:[[AudioManager sharedInstance] bgColorDark]];
            songLabel.textColor=[[AudioManager sharedInstance] secondaryColor];

            artistLabel.textColor= [[AudioManager sharedInstance] primaryColor];
            broadcastLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
            
            broadcastStatusLabel.textColor= [[AudioManager sharedInstance] primaryColor];
 
            _rightLabel.textColor=_leftLabel.textColor =  [[AudioManager sharedInstance] secondaryColor];
         
            _trackSlider.fillImage =       [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track_Fill" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
            _trackSlider.trackImage =  [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
            
            [_trackSlider setThumbImage:   [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Thumb" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]
                               forState:UIControlStateNormal];
                 _trackSlider.tintColor =[[AudioManager sharedInstance] secondaryColor];
            if([[AudioManager sharedInstance] currentTrack
                ]!=nil){
               songLabel.text=[[[AudioManager sharedInstance] currentTrack
                                 ] title];
                artistLabel.text=[[[AudioManager sharedInstance] currentTrack
                                   ] artist];
            }
      
            [prevButton setImage:          [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bbackward" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]  forState:UIControlStateNormal];
            [nextButton setImage:      [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fforward" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]  forState:UIControlStateNormal];
            [self playbackChanged];
     }

    
    
    -(void)startTimer{
        
        if(self.positionTimer)
        {
            [self.positionTimer invalidate];
            self.positionTimer=nil;
        }
        self.positionTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.positionTimer forMode:NSRunLoopCommonModes];
    }
    -(void)stopTimer{
        if(self.positionTimer){
            [self.positionTimer invalidate];
            self.positionTimer=nil;
        }
    }
    - (void)_timerAction:(id)timer
    {
        
        [self updateTimeLabel];
        
    }
    -(void)updateTimeLabel{
        _trackSlider.value=[[AudioManager sharedInstance ] currentTime ]/[[AudioManager sharedInstance ] duration ];
        
        _leftLabel.text=[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f",[[AudioManager sharedInstance] currentTime]   ] ];
        _rightLabel.text=[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f", [[AudioManager sharedInstance] duration]-[[AudioPlayer sharedInstance] currentTime]   ] ];
        
        
    }


    


    

 

- (UIViewController *)rootViewController
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}
-(void)layoutSubviews{

    
    [broadcastStatusLabel setFrame:CGRectMake(5,40,self.bounds.size.width/2-(70/2)-80,17) ] ;
    
    [broadcastLabel setFrame:CGRectMake( 5,15,self.bounds.size.width/2-(70/2)-80,19) ] ;
 
    [artistLabel setFrame:CGRectMake(self.bounds.size.width-(self.bounds.size.width/2-(70/2)-80),40,self.bounds.size.width/2-(70/2)-80,17) ] ;

     [songLabel setFrame:CGRectMake(self.bounds.size.width-(self.bounds.size.width/2-(70/2)-80),15,self.bounds.size.width/2-(70/2)-80,19) ] ;
  
    [nextButton setFrame:CGRectMake(self.bounds.size.width/2+(70/2)+20,20,35 ,35) ] ;
    [prevButton setFrame:CGRectMake(self.bounds.size.width/2-(70/2)-55,20,35,35) ] ;
    [bottomView setFrame:CGRectMake(self.bounds.size.width/2-(60/2),5, 60 , 60 )];

    [playButton setFrame:CGRectMake(bottomView.bounds.size.width/2-(30/2),15, 30 , 30 )];
    
    

  

    [seekBar setFrame:CGRectMake(0, self.bounds.size.height-22,self.bounds.size.width, 20)];

    [_trackSlider setFrame:(CGRect){40,1,seekBar.bounds.size.width-80,16}];

    [_leftLabel setFrame:CGRectMake(0,3,36,12)];
    [_rightLabel setFrame:CGRectMake(seekBar.bounds.size.width-36, 3,36,12)];



}
-(void)next{

    [[AudioManager sharedInstance] _actionNext];

}

-(void)prev{
    
    [[AudioManager sharedInstance] _actionPrev];
    
}
-(void)togglePlayPause{
    [[AudioManager sharedInstance] _actionPlayPause:nil];
}

-(void)setupPlayButtons{
    bottomView=[[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-(60/2),5, 60 , 60 )];
    tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlayPause)];
    [bottomView addGestureRecognizer:tapGesture];
    
    bottomView.layer.borderWidth=1;
    bottomView.layer.cornerRadius=60/2;
    bottomView.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
     bottomView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    [self addSubview:bottomView];
    bottomView.clipsToBounds=YES;
    
    playButton=[[UIImageView alloc] initWithFrame:CGRectMake(bottomView.bounds.size.width/2-(30/2),15, 30 , 30 )];
    
    [bottomView addSubview:playButton];
    nextButton=[[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2+(70/2)+20,20,35 ,35) ] ;
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    prevButton=[[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-(70/2)-55,20,35,35) ] ;
    [prevButton addTarget:self action:@selector(prev) forControlEvents:UIControlEventTouchUpInside];
    
    [self playbackChanged];
    
    [prevButton setImage:          [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bbackward" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]  forState:UIControlStateNormal];
    [nextButton setImage:      [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fforward" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]  forState:UIControlStateNormal];
    [self addSubview:bottomView];
    [self addSubview:nextButton];
    [self addSubview:prevButton];
    
}
-(void)newValue:(MTZSlider*)sliders{
    
    
    [[[AudioManager sharedInstance ] currentStreamer] setCurrentTime:([[AudioManager sharedInstance ] duration ] * sliders.value)  ];
    _leftLabel.text=[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f",[[AudioManager sharedInstance] currentTime]   ] ];
    _rightLabel.text=[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f", [[AudioManager sharedInstance] duration]-[[AudioPlayer sharedInstance] currentTime]   ] ];
    

}
    @end
