//
//  DancingBarsView.m
//  imPlayr2
//
//  Created by YAZ on 5/2/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "DancingBarsView.h"
#import "Utitlities.h"
#import "AudioManager.h"
#import  "imConstants.h"
#import "imStreamer.h"
@implementation DancingBarsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth=2;
        self.layer.cornerRadius=frame.size.width/2;
        self.layer.borderColor= [[AudioManager sharedInstance] primaryColor].CGColor;
        self.layer.backgroundColor= [[AudioManager sharedInstance] bgColor].CGColor;
        currentPlayingArtist=[[UILabel alloc] initWithFrame:CGRectMake(1, 10, 73, 10)];
        currentPlayingArtist.textAlignment=NSTextAlignmentCenter;
        
        currentPlayingArtist.text=@"To Skip -> ";
        
        currentPlayingArtist.font = [UIFont fontWithName:@"Marker Felt" size:10];
        currentSongTime=[[UILabel alloc] initWithFrame:CGRectMake(1,self.frame.size.height/2-20/2, 73, 20)];
        currentSongTime.textAlignment=NSTextAlignmentCenter;
        currentSongTime.font = [UIFont fontWithName:@"bebas" size:18];

        currentPlayingArtist.textColor=[UIColor whiteColor];
        currentSongTime.text=@"00:00";
        
        currentSongTime.textColor=[UIColor blackColor];
        [self addSubview:currentSongTime];
        [self addSubview:currentPlayingArtist];
             _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20/2,50,20 ,20) ] ;
  
        [self addSubview:_imageView];
        [self playbackChanged];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePlayPause)];
        [self addGestureRecognizer:tap];
 _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];


        
    }
    return self;
}

-(void)updateTimeLabel{
    if(![[imStreamer sharedInstance] isHTTPRunning])
    [currentSongTime setText:[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f", [[AudioManager sharedInstance ] currentTime ]  ]]];
}
-(void)trackDidChanged{
    
    if([[AudioManager sharedInstance] currentTrack]!=nil){
    currentSongTime.text=[[[AudioManager sharedInstance] currentTrack] artist];
        currentPlayingArtist.text=@"imPlaying";

    }
else {
    currentSongTime.text=@"Playr";
    currentPlayingArtist.text=@"im";

}
    
    
}
-(void)setupForControlHeader{
    currentSongTime.font =  [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:13];
    currentSongTime.text=@"Playr";
    currentPlayingArtist.text=@"im";
    
 

}

-(void)refreshColors{
    currentSongTime.textColor=[[AudioManager sharedInstance] secondaryColor];
    currentPlayingArtist.textColor=[[AudioManager sharedInstance] primaryColor];

    self.layer.borderColor= [[AudioManager sharedInstance] primaryColor].CGColor;
    self.layer.backgroundColor= [[AudioManager sharedInstance] bgColor].CGColor;
    [self playbackChanged];
}
-(void)changeItToConnectedView{
    currentPlayingArtist.text=@"To Skip -> ";

    currentSongTime.text=@"http://";
    currentSongTime.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12];

    
    
    
}

-(void)changeItBackToPlayr{
    currentSongTime.font = [UIFont fontWithName:@"bebas" size:18];
    currentSongTime.text=@"---";


}
-(void)setCurrentSongTime:(NSString *)s{

    currentSongTime.text=s;


}
-(void)togglePlayPause{
    [[AudioManager sharedInstance] _actionPlayPause:nil];
}
- (void)playbackChanged
{
     if([[AudioManager sharedInstance ] currentStreamer]!=nil){
        switch ([[[AudioManager sharedInstance ] currentStreamer] status]) {
            case AudioStreamerPlaying:
                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-pause" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
           
                
                break;
                
            case AudioStreamerPaused:
                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
                
              
                
                
                break;
                
            case AudioStreamerIdle:
                                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
                
                
                break;
                
            case AudioStreamerFinished:
          
                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
                
                break;
                
            case AudioStreamerBuffering:
                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];

                
                break;
                
            case AudioStreamerError:
                _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];

                 
                break;
                
                
        }
     }
    
     else if([[imStreamer sharedInstance ] isHTTPRunning] ) {
     
     if([[imStreamer sharedInstance] isPlaying])
     {
         _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-pause" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
         

     
     
     }
         
     else {
     
         _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"media-play" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
         

     
     }
     
     
     }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
