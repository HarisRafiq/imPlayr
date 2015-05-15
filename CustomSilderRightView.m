//
//  CustomSilderRightView.m
//  imPlayr2
//
//  Created by YAZ on 5/29/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "CustomSilderRightView.h"
#import "Utitlities.h"
#import "AudioManager.h"
#import  "imConstants.h"
#import "AppDelegate.h"
@implementation CustomSilderRightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth=2;
        self.layer.cornerRadius=frame.size.width/2;
        self.layer.borderColor= [[AudioManager sharedInstance] primaryColor].CGColor;
        self.layer.backgroundColor= [[AudioManager sharedInstance] bgColor] .CGColor;
        currentPlayingArtist=[[UILabel alloc] initWithFrame:CGRectMake(1, 10, 73, 10)];
        currentPlayingArtist.textAlignment=NSTextAlignmentCenter;
  currentPlayingArtist.text=@"<- To Skip";
        
        currentPlayingArtist.font = [UIFont fontWithName:@"Marker Felt" size:10];
        currentSongTime=[[UILabel alloc] initWithFrame:CGRectMake(1,self.frame.size.height/2-20/2, 73, 20)];
        currentSongTime.textAlignment=NSTextAlignmentCenter;
        currentSongTime.font = [UIFont fontWithName:@"bebas" size:18];
        currentSongTime.text=@"00:00";

        currentPlayingArtist.textColor=[UIColor whiteColor];
         currentSongTime.textColor=[UIColor blackColor];
        [self addSubview:currentSongTime];
        [self addSubview:currentPlayingArtist];
 
        
        
      
   
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20/2,50,20 ,20) ] ;
         _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
        [self addSubview:_imageView];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
         [self addGestureRecognizer:tap];
        
        isOn=NO;
        
        
    }
    return self;
}
-(void)updateTimeLabel{
    
    [currentSongTime setText:[Utitlities convertTimeFromSeconds:[NSString stringWithFormat:@"%f", [[AudioManager sharedInstance ] duration ]-[[AudioManager sharedInstance ] currentTime ]  ]]];
}

-(void)refreshColors{
    currentSongTime.textColor=[[AudioManager sharedInstance] secondaryColor];
    currentPlayingArtist.textColor=[[AudioManager sharedInstance] primaryColor];
            _imageView.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]  ];
    self.layer.borderColor= [[AudioManager sharedInstance] primaryColor].CGColor;
    self.layer.backgroundColor= [[AudioManager sharedInstance] bgColor] .CGColor;
    
}
-(void)changeItToConnectedView{

    currentSongTime.text=@"---";
 
    

}




-(void)toggle{
    AppDelegate *jnad = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [[jnad mainVC] toggleMenu];
}

@end

 
