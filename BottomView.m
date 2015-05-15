//
//  BottomView.m
//  AirDab
//
//  Created by YAZ on 2/9/14.
//  Copyright (c) 2014 AirWalker. All rights reserved.
//

#import "BottomView.h"
#import "AudioManager.h"
#import "UIImage+Thumbnail.h"
#import "imStreamer.h"
@implementation BottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshColors) name:NOTIFICATION_COLORS_CHANGED object:nil];
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1280.0, -1280.0, 0.0f, 0.0f)];
        [self addSubview:volumeView];
        _player = [MPMusicPlayerController iPodMusicPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeDidChange:)
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                   object:_player];
        
        [_player beginGeneratingPlaybackNotifications];
         [self setupTrackSlider];
        
         [self setupSwitch];
              self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
         [self setupVisualizer];
        [self refreshColors];
    }
    return self;
}

- (void)volumeDidChange:(id)sender
{
	_volumeSlider.value = _player.volume;
}
- (void)volumeChanged:(id)sender
{
	_player.volume = _volumeSlider.value;
}

 


-(void)setupTrackSlider{
    volumeBar=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-25,self.bounds.size.width, 20)];
    
    
    
    
    
    _volumeSlider = [[MTZSlider alloc] initWithFrame:(CGRect){40,1,volumeBar.bounds.size.width-80,16}];
    _volumeSlider.tintColor = [UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0];
    [_volumeSlider addTarget:self
                      action:@selector(volumeChanged:)
            forControlEvents:UIControlEventValueChanged];
    _volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _volumeSlider.value = _player.volume;
    
    _volumeSlider.fillImage = [Utitlities imageNamed:[UIImage imageNamed:@"Track_Fill.png"] withColor:[UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0]];
    _volumeSlider.trackImage = [Utitlities imageNamed:[UIImage imageNamed:@"Track.png"] withColor:[UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0]];
    
    [_volumeSlider setThumbImage:[Utitlities imageNamed:[UIImage imageNamed:@"Thumb.png"] withColor:[UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0]]
                        forState:UIControlStateNormal];
    [volumeBar addSubview:_volumeSlider];
    
    
    speakerOn=[[UIImageView alloc] initWithFrame:CGRectMake(volumeBar.bounds.size.width-30,0,20,18) ] ;
    
        [speakerOn setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [speakerOn setContentMode:UIViewContentModeScaleAspectFill];
    [speakerOn setClipsToBounds:YES];
    
    
    
    [volumeBar addSubview:speakerOn];
    
    
    speakerOff=[[UIImageView alloc] initWithFrame:CGRectMake(20,2,9,13) ] ;
   
    [speakerOff setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [speakerOff setContentMode:UIViewContentModeScaleAspectFill];
    [speakerOff setClipsToBounds:YES];
    
    
    
    [volumeBar addSubview:speakerOff];
    
    [self addSubview:volumeBar];
 
    
}
-(void)setHttpON{
 
    [broadcastSwitch setOn:NO];
    [broadCastOn setHidden:YES];
    [broadCastOff setHidden:NO];

}

-(void)setHttpOFF{
    [broadcastSwitch setOn:YES];
    [broadCastOn setHidden:NO];
    [broadCastOff setHidden:YES];



}
-(void)setupSwitch{

    mySwitch3 = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 100,35)];
    mySwitch3.center = CGPointMake(self.bounds.size.width-150, self.bounds.size.height * 0.5-13);
   
    [mySwitch3 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:mySwitch3];
    visualizerOn=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20) ] ;
     [visualizerOn setContentMode:UIViewContentModeScaleAspectFill];
    [visualizerOn setClipsToBounds:YES];
            [visualizerOn setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more" ofType:@"png"]] withColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]]];
    
    
    visualizerOff=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20) ] ;
     [visualizerOff setContentMode:UIViewContentModeScaleAspectFill];
    [visualizerOff setClipsToBounds:YES];
        [self addSubview:visualizerOff];
    [self addSubview:visualizerOn];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI);
    visualizerOff.transform = trans;
    visualizerOn.hidden=YES;
    //self.view.backgroundColor = [UIColor colorWithRed:0.19f green:0.23f blue:0.33f alpha:1.00f];
    mySwitch3.thumbTintColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.00f];
    mySwitch3.activeColor = [UIColor colorWithRed:0.87f green:0.87f blue:0.87f alpha:1.00f];
    mySwitch3.inactiveColor = [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.00f];
    mySwitch3.onTintColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
    mySwitch3.borderColor = [UIColor clearColor];
    mySwitch3.shadowColor = [UIColor blackColor];
    
    broadcastSwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 100,35)];
    broadcastSwitch.center = CGPointMake(137, self.bounds.size.height * 0.5-13);
    
    [broadcastSwitch addTarget:self action:@selector(broadcastSwitch) forControlEvents:UIControlEventValueChanged];
    broadcastSwitch.thumbTintColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.00f];
    broadcastSwitch.inactiveColor = [UIColor colorWithRed:0.87f green:0.87f blue:0.87f alpha:1.00f];
    broadcastSwitch.activeColor = [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.00f];
    broadcastSwitch.onTintColor = [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.00f];
    broadcastSwitch.borderColor = [UIColor clearColor];
    broadcastSwitch.shadowColor = [UIColor blackColor];
    
    broadCastOn=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,25,25) ] ;
    [broadCastOn setContentMode:UIViewContentModeScaleAspectFill];
    [broadCastOn setClipsToBounds:YES];
    [broadCastOn setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]]];
    [broadcastSwitch setOn:YES];

    broadCastOff=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,25,25) ] ;
    [broadCastOff setContentMode:UIViewContentModeScaleAspectFill];
    [broadCastOff setClipsToBounds:YES];
    [broadCastOff setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]]];

    [self addSubview:broadcastSwitch];
    [self addSubview:broadCastOn];
    [self addSubview:broadCastOff];
    [broadCastOff setHidden:YES];

}
-(void)broadcastSwitch{

    [[imStreamer sharedInstance] startHTTPServer];

    
    
    
    
}
- (void)switchChanged:(SevenSwitch *)sender {
    if(isViusalizerHidden)
    {
        
        visualizerOn.hidden=YES;
        visualizerOff.hidden=NO;

        isViusalizerHidden=NO;
     
    
    }
    else {
        visualizerOff.hidden=YES;
        visualizerOn.hidden=NO;

        isViusalizerHidden=YES;
      
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VISUALIZER_SWITCH object:nil];

}
-(void)refreshColors{
    _volumeSlider.fillImage =       [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track_Fill" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
    _volumeSlider.trackImage =  [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Track" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
    
    [_volumeSlider setThumbImage:   [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Thumb" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]
                       forState:UIControlStateNormal];
    _volumeSlider.tintColor =[[AudioManager sharedInstance] secondaryColor];
    
    speakerOff.image=    [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SpeakerOff" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
    
    speakerOn.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SpeakerOn" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]];
    self.backgroundColor =[[AudioManager sharedInstance] bgColorDark] ;
    broadcastSwitch.thumbTintColor = [[AudioManager sharedInstance] primaryColor];
    broadcastSwitch.inactiveColor = [[AudioManager sharedInstance] bgColoLight];
    broadcastSwitch.activeColor = [[AudioManager sharedInstance] bgColor];
    broadcastSwitch.onTintColor = [[AudioManager sharedInstance] bgColor];
    mySwitch3.thumbTintColor = [[AudioManager sharedInstance] primaryColor];
    mySwitch3.activeColor = [[AudioManager sharedInstance] bgColoLight];
    mySwitch3.inactiveColor = [[AudioManager sharedInstance] bgColor];
    mySwitch3.onTintColor = [[AudioManager sharedInstance] bgColor];
   [broadCastOn setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]];
    [broadCastOff setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[[AudioManager sharedInstance] primaryColor]]];
    [visualizerOff setImage:[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_news_list" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]];
    [visualizerOn setImage: [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"more" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]];
    

  }

-(void)setupColor{
    colorButton=[[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-(60/2),5, 50 , 50 )];
    [colorButton addTarget:self action:@selector(changeAlbumCover) forControlEvents:UIControlEventTouchUpInside];
    [colorButton setImage:[[UIImage imageNamed:@"album-cover"] makeThumbnailForBGWithSize:CGSizeMake(45,45) withCornerRadius:0] forState:UIControlStateNormal];
    [self addSubview:colorButton];
  
    
}
-(void)changeAlbumCover{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TOGGLE_ALBUM_COVER object:nil userInfo:nil];


}

-(void)layoutSubviews{
    broadCastOn.center = CGPointMake(100, self.bounds.size.height * 0.5-13);
    broadCastOff.center = CGPointMake(160, self.bounds.size.height * 0.5-13);

    [broadcastSwitch setFrame: CGRectMake(0, 0, 100, 35)];

    broadcastSwitch.center =CGPointMake(130, self.bounds.size.height * 0.5-13);

     [mySwitch3 setFrame: CGRectMake(0, 0, 100, 35)];
    mySwitch3.center = CGPointMake(self.bounds.size.width-130, self.bounds.size.height * 0.5-13);
    visualizerOn.center = CGPointMake(self.bounds.size.width-200, self.bounds.size.height * 0.5-13);
     visualizerOff.center = CGPointMake(self.bounds.size.width-60, self.bounds.size.height * 0.5-13);
 
 
 
    
    [volumeBar setFrame:CGRectMake(0, self.bounds.size.height-25,self.bounds.size.width, 20)];

    
    [_volumeSlider setFrame:(CGRect){40,1,volumeBar.bounds.size.width-80,16}];
  
    [speakerOn setFrame:CGRectMake(volumeBar.bounds.size.width-30,0,20,18) ] ;
    [speakerOff setFrame:CGRectMake(20,2,9,13) ] ;
    
    
    
   
}

-(void)setupVisualizer{
    
    if(_visualizeView)
    {[_visualizeView cleanUp];
        [_visualizeView removeFromSuperview];
        _visualizeView=nil;
    }
    
    _visualizeView = [[dance alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-70/2,
                                                             5,
                                                             70,
                                                             70)  context:nil];
    
    _visualizeView.backgroundColor=  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    _visualizeView.layer.cornerRadius=70/2;
    _visualizeView.layer.masksToBounds=YES;
    _visualizeView.clipsToBounds=YES;
    
    
    
    
    
    [self addSubview:_visualizeView];
    
    
    
}
-(void)setupAlbumCoverButton{


}
@end
