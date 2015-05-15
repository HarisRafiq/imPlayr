//
//  MainViewController.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()< UIGestureRecognizerDelegate,RNGridMenuDelegate,imStreamerDelegate,imNowPlayingViewControllerDelegate>
{
    CircularSlider *slider;
    UIImageView *_bgView;
    UIView *topView;
    BOOL isVisualizerBig;
    UIImageView *back;
    BOOL isMenuOpen;
    float TB_SLIDER_SIZE;
    float IMAGE_SIZE;
    
    CAGradientLayer *gradient;
    DancingBarsView *dancingBarView;
    CustomSilderRightView *rightView;
    
    UIView *sliderView;
    UIView *labelView;
    
    UILabel *songTitle;
    UILabel *artistTitle;
    
    imNowPlayingViewController *nowPlayingQueue;
    BOOL isVisualizerSmall;
    UIView *bottomView;
    RNGridMenu *av;
    UIImageView *connectedImageView;
    BOOL isConnected;
    UIView *imageHolderView;
    UIImage *connectedImage;
    UIImageView *_albumView;

}
 

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
    
    
    if(IS_IPHONE_5)
        TB_SLIDER_SIZE =250.0;
    else         TB_SLIDER_SIZE =210.0;
    
    IMAGE_SIZE=TB_SLIDER_SIZE-TB_IMAGE_PADDING;
    
    [self setupCircularSlider];
    [self someMethod];
    
    [self setupBottomView];
    [self setupAllSongs];
    [self setupVisualizer];
    [self setupAlbumCover];
    [self setAlbumImage:[[AudioManager sharedInstance] nowPlayingImage]];
         //[self.view addSubview:songTitle];
    gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height+40);
    gradient.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:.4] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:.4] CGColor], nil];
    

     _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.width )];
         gradient.hidden=NO;

         [_bgView setContentMode:UIViewContentModeCenter];
    
    
    
    [self.view insertSubview:_bgView atIndex:0 ];
    
    [self.view.layer insertSublayer:gradient above:_bgView.layer];
    
    _imStream=[imStreamer sharedInstance];
    [_imStream setDelegate:self];
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    
    _webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    _webBrowser.showProgress = NO;
    _webBrowser.allowSharing = YES;
    _webBrowser.allowSearch = YES;

}

-(void)setAlbumImage:(UIImage *)image{
    if(_bgView.image!=image){
        _bgView.image = [[image makeThumbnailForBGWithSize:CGSizeMake(self.view.frame.size.width*1.3,(self.view.frame.size.width*1.3) ) withCornerRadius:0] stackBlur:25];
             UIGraphicsBeginImageContext(image.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
                trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, image.size.height));
                CGContextConcatCTM(ctx, trnsfrm);
                CGContextBeginPath(ctx);
                CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height));
                CGContextClip(ctx);
                CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                 _albumView.image = image  ;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    
   
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self stopTimer];
    if(_visualizeView)
        [_visualizeView handleEnteredBackground:nil];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorsChanged) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_BUFFERING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_IDLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PAUSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PLAYING_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_STARTED_PLAYING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamerPlaybackChanged) name:NOTIFICATION_STREAMER_PLAYBACK_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForgorund:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [self playbackChanged];
    [self colorsChanged];
    
    if(_visualizeView)
        [_visualizeView handleEnteredForgorund:nil];
    
    
}

-(void)handleEnteredBackground:(id)s{
    
    [self stopTimer];
    
    
}

-(void)handleEnteredForgorund:(id)s{
    
    [self playbackChanged];
    
    
}
-(void)streamerPlaybackChanged{
    
    if( [[UIApplication sharedApplication] applicationState]!=UIApplicationStateBackground )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dancingBarView playbackChanged];
        });
        
    }
}

- (void)playbackChanged
{
    if([[AudioManager sharedInstance ] currentStreamer]!=nil){
        switch ([[[AudioManager sharedInstance ] currentStreamer] status]) {
            case AudioStreamerPlaying:
                
                
                [self startTimer];
                
                break;
                
            case AudioStreamerPaused:
                
                [self stopTimer];
                
                
                break;
                
            case AudioStreamerIdle:
                
                [self stopTimer];
                
                
                break;
                
            case AudioStreamerFinished:
                
                [self stopTimer];
                
                break;
                
            case AudioStreamerBuffering:
                
                [self stopTimer];
                
                break;
                
            case AudioStreamerError:
                
                [self stopTimer];
                
                break;
        }
        
        [dancingBarView playbackChanged];
        
    }
}

-(void)colorsChanged{
    bottomView.layer.borderColor= [[AudioManager sharedInstance] primaryColor].CGColor;
    bottomView.layer.backgroundColor= [[AudioManager sharedInstance] bgColorDark].CGColor;
    
    self.view.backgroundColor =  [[AudioManager sharedInstance] bgColor]  ;
    songTitle.textColor= [[AudioManager sharedInstance] secondaryColor] ;
    artistTitle.textColor=  [[AudioManager sharedInstance] primaryColor]  ;
    [rightView refreshColors];
    sliderView.layer.backgroundColor=   [[AudioManager sharedInstance] bgColorDark].CGColor  ;
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
    
    [dancingBarView refreshColors];
    
    
    
    if(![_imStream isHTTPRunning]){
    
        if([[AudioManager sharedInstance] currentTrack
            ]!=nil){
            songTitle.text=[[[AudioManager sharedInstance] currentTrack
                             ] title];
            artistTitle.text=[[[AudioManager sharedInstance] currentTrack
                               ] artist];
        }
        
        else {
            
            songTitle.text=@"imPlayr";
            artistTitle.text=@"Tap Menu For More ->";
        }
        
        
    }
    
    else {
        songTitle.text=[[[AudioManager sharedInstance] currentTrack
                         ] title];
        _albumView.layer.borderColor=[[AudioManager sharedInstance] primaryColor].CGColor;
        
        connectedImage=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
        [connectedImageView setImage:connectedImage];
        
    }
  
    [self setAlbumImage:[[AudioManager sharedInstance] nowPlayingImage]];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:NO];
    
}
/** This function is called when Circular slider value changes **/
-(void)newValue:(CircularSlider*)sliders{
    
    if([[AudioManager sharedInstance] currentStreamer]!=nil&&[[[AudioManager sharedInstance] currentStreamer] status]==AudioStreamerPlaying){
        [self stopTimer];
        
        
    }
    float f=sliders.angle;
    if(f<=0)
    {
        f=  (360.0+f ) ;
        
    }
    [[[AudioManager sharedInstance ] currentStreamer] setCurrentTime:([[AudioManager sharedInstance ] duration ] * f)/360.0 ];
    if([[AudioManager sharedInstance] currentStreamer]!=nil&&[[[AudioManager sharedInstance] currentStreamer] status]==AudioStreamerPlaying){
        [self startTimer];
        
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [rightView updateTimeLabel];
    [dancingBarView updateTimeLabel];
}

-(void)updateTimeLabel{
    
    slider.angle=  (360*[[AudioManager sharedInstance ] currentTime ]/[[AudioManager sharedInstance ] duration ]) ;
    
    
    
    
    [slider setNeedsDisplay];
    
    
}

-(void)someMethod {
    
    topView=[[UIView alloc] initWithFrame:CGRectMake(0,TB_SLIDER_SIZE+45, self.view.bounds.size.width, 80)];
    sliderView=[[UIView alloc] initWithFrame:CGRectMake(10,5, self.view.bounds.size.width-20, 75)];
    self.slideToConfirmView=[[DESlideToConfirmView alloc] initWithFrame:CGRectMake(0,0, sliderView.bounds.size.width, 75)];
    sliderView.layer.cornerRadius=75/2;
    
    
    
    labelView=[[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width-150, 75)];
    
    songTitle=[[UILabel alloc] initWithFrame:CGRectMake(0,10, labelView.frame.size.width, 20)];
    
    songTitle.textColor=[UIColor whiteColor] ;
    
    songTitle.textAlignment=NSTextAlignmentCenter;
    
    songTitle.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:18];
    songTitle.text=@"imPlayr";
    
    songTitle.numberOfLines=1;
    songTitle.clipsToBounds=YES;
    songTitle.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    artistTitle=[[UILabel alloc] initWithFrame:CGRectMake(0,35, labelView.frame.size.width, 14)];
    artistTitle.text=@"By Haris Rafiq";
    artistTitle.textColor=[UIColor whiteColor] ;
    
    artistTitle.textAlignment=NSTextAlignmentCenter;
    
    artistTitle.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12];
    artistTitle.numberOfLines=1;
    artistTitle.clipsToBounds=YES;
    artistTitle.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    labelView.clipsToBounds=YES;
    
    [labelView addSubview:songTitle];
    [labelView addSubview:artistTitle];
    back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    back.image = [UIImage imageNamed:@"backButton2.png"];
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
    
    
    back.contentMode = UIViewContentModeScaleAspectFit;
    back.center = CGPointMake(labelView.frame.size.width/2-10,60);
    
    back.transform = CGAffineTransformMakeRotation(-M_PI/2);
    [labelView addSubview:back];
    self.slideToConfirmView.customTrackView=labelView;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleQueue)];
    [labelView addGestureRecognizer:tap];
    
    
    
    dancingBarView=[[DancingBarsView alloc] initWithFrame:CGRectMake(0,0,75, 75)];
    self.slideToConfirmView.customThumbView=dancingBarView;
    rightView=[[CustomSilderRightView alloc] initWithFrame:CGRectMake(0,0,75, 75)];
    
    self.slideToConfirmView.customThumbView2=rightView;
    
    [sliderView addSubview:self.slideToConfirmView];
    [topView addSubview:sliderView];
    
    [self.view addSubview:topView];
    
  
    __block typeof(self) bself = self;
    self.slideToConfirmView.idleBlock = ^(DESlideToConfirmView *slideView) {
        [bself updateSlideToIdleBlock];
    };
    
    self.slideToConfirmView.updateBlock = ^(DESlideToConfirmView *slideView, float percentage) {
        [bself updateSlideToUpdateBlock];
    };
    
    self.slideToConfirmView.completeBlock = ^(DESlideToConfirmView *slideView) {
        [bself updateSlideToCompleteBlock];
    };
    
    self.slideToConfirmView.idleBlock2 = ^(DESlideToConfirmView *slideView) {
        [bself updateSlideToIdleBlock2];
    };
    
    self.slideToConfirmView.updateBlock2 = ^(DESlideToConfirmView *slideView, float percentage) {
        [bself updateSlideToUpdateBlock2];
    };
    
    self.slideToConfirmView.completeBlock2 = ^(DESlideToConfirmView *slideView) {
        [bself updateSlideToCompleteBlock2];
    };
    
    
}
-(void)updateSlideToIdleBlock{
    
    if([[AudioManager sharedInstance] currentTrack
        ]!=nil){
        if(![[imStreamer sharedInstance] isHTTPRunning])
            artistTitle.text=[[[AudioManager sharedInstance] currentTrack
                               ] artist];
        songTitle.text=[[[AudioManager sharedInstance] currentTrack
                         ] title];
        
        
    }
    
    else {
        
        
        if(![[imStreamer sharedInstance] isHTTPRunning])
            artistTitle.text=@"imPlayr";
        songTitle.text=@"Empty Queue";
        
        
    }
    
    sliderView.layer.backgroundColor=   [[AudioManager sharedInstance] bgColorDark].CGColor  ;
    
    songTitle.textColor=  [[AudioManager sharedInstance] secondaryColor]  ;
    artistTitle.textColor=  [[AudioManager sharedInstance] primaryColor]  ;
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
    
    
    
}
-(void)updateSlideToUpdateBlock{
    
    sliderView.layer.backgroundColor=   [[AudioManager sharedInstance] bgColoLight].CGColor  ;
    
    songTitle.textColor=  [[AudioManager sharedInstance] bgColorDark]  ;
    artistTitle.textColor=  [[AudioManager sharedInstance] bgColorDark]  ;
    
    
    songTitle.text=@"Slide Right";
    if(![[imStreamer sharedInstance] isHTTPRunning])
        artistTitle.text=@"To Skip Track";
    
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] bgColorDark]  ];
    
}
-(void)updateSlideToCompleteBlock{
    
    songTitle.text=@"imPlayr";
    if(![[imStreamer sharedInstance] isHTTPRunning])
        artistTitle.text=@"Track Changed";
    
    
    [[AudioManager sharedInstance] _actionNext];
    
}

-(void)updateSlideToIdleBlock2{
    
    
         if([[AudioManager sharedInstance] currentTrack
            ]!=nil){
            if(![[imStreamer sharedInstance] isHTTPRunning])
                artistTitle.text=[[[AudioManager sharedInstance] currentTrack
                                   ] artist];
            songTitle.text=[[[AudioManager sharedInstance] currentTrack
                             ] title];
            
            
        }
    
    else {
        
       
            if(![[imStreamer sharedInstance] isHTTPRunning])
                artistTitle.text=@"imPlayr";
            songTitle.text=@"Empty Queue";
        
        
    }
    
    sliderView.layer.backgroundColor=   [[AudioManager sharedInstance] bgColorDark].CGColor  ;
    
    songTitle.textColor=  [[AudioManager sharedInstance] secondaryColor]  ;
    artistTitle.textColor=  [[AudioManager sharedInstance] primaryColor]  ;
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];

    
}
-(void)updateSlideToUpdateBlock2{
    
    
    
    sliderView.layer.backgroundColor=   [[AudioManager sharedInstance] bgColoLight].CGColor  ;
    
    songTitle.textColor=  [[AudioManager sharedInstance] bgColorDark]  ;
    artistTitle.textColor=  [[AudioManager sharedInstance] bgColorDark]  ;
    
    songTitle.text=@"Slide Left";
    if(![[imStreamer sharedInstance] isHTTPRunning])
        artistTitle.text=@"To Skip Track";
    
    back.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backButton2" ofType:@"png"]] withColor:[[AudioManager sharedInstance] bgColorDark]  ];
    
    
}
-(void)updateSlideToCompleteBlock2{
    songTitle.text=[[[AudioManager sharedInstance] currentTrack
                     ] title];
    if(![[imStreamer sharedInstance] isHTTPRunning])
        artistTitle.text=@"Track Changed";
    
    
    [[AudioManager sharedInstance] _actionPrev];
    
}
-(void)setupAllSongs{
    
    nowPlayingQueue=[[imNowPlayingViewController alloc] initWithFrame:CGRectMake(10,30, 300,self.view.bounds.size.height-90 )];
    [self.view addSubview:nowPlayingQueue];
    
    nowPlayingQueue.delegate=self;
    nowPlayingQueue.hidden=YES;
}
-(void)dismissNowPlaying{
    
    [self toggleQueue];
}
-(void)toggleQueue{
    if(!nowPlayingQueue.hidden){
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             nowPlayingQueue.alpha=0;
                             
                             back.transform = CGAffineTransformMakeRotation(-M_PI/2);
                             
                         }  completion:^(BOOL finished){
                             nowPlayingQueue.hidden=YES;
                             
                         }];
        
        
    }
    else {
        nowPlayingQueue.alpha=0;
        nowPlayingQueue.hidden=NO;
        
        [nowPlayingQueue setTracks];
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             back.transform = CGAffineTransformMakeRotation(M_PI/2);
                             nowPlayingQueue.alpha=1;
                             
                             
                         }  completion:^(BOOL finished){
                             
                         }];
        
        
        
    }
}

 

-(void)toggleMenu{
    AppDelegate *jnad = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    NSInteger numberOfOptions =5;
    if([[InAppPurchaseManager sharedInstance] isAdOptOut])
    {
        numberOfOptions--;
        
    }
    
    
 
    
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"playlist"] title:NSLocalizedString(@"Playlist", nil) action:^{
                           [self.navigationController pushViewController:[jnad playlistVC] animated:YES ];

                       
                       }],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"songs"] title:NSLocalizedString(@"Songs", nil) action:^{
                           
                           [self.navigationController pushViewController:[jnad songsVC] animated:YES ];
                           
                       }],
                      
                       
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"album-cover"] title:NSLocalizedString(@"Album Cover", nil)  action:^{
                           
                           [self.navigationController pushViewController:_webBrowser animated:YES];
                           
                           [AppDelegate showHintMessage:nil];
                       }],
                       

                       
                       
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"broadcast"] title:NSLocalizedString(@"Broadcast", nil)  action:^{
                           
                           [_imStream startHTTPServer];
                       }],
                       

                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"store"] title:NSLocalizedString(@"RemoveAds", nil) action:^{
                           
                           [self storeControllerAction];
                       }]
                       
                       ];
    if(av!=nil)
        av=nil;
    av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
     av.bounces = YES;
    
    [self showGrid];
}

- (void)showGrid {
    
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}


-(void)setupVisualizer{
    
    if(_visualizeView)
    {[_visualizeView cleanUp];
        [_visualizeView.layer removeFromSuperlayer];
        _visualizeView=nil;
    }
    
    _visualizeView = [[dance alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             85,
                                                             85)  context:nil];
    
    _visualizeView.backgroundColor=  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    _visualizeView.layer.cornerRadius=85/2;
    _visualizeView.layer.masksToBounds=YES;
    _visualizeView.clipsToBounds=YES;
    
    
    
    isVisualizerSmall=YES;
    [bottomView.layer insertSublayer:_visualizeView.layer atIndex:0  ];
    
 
    
    
}
-(void)setupAlbumCover{
    _albumView = [[UIImageView alloc] initWithFrame: CGRectMake(TB_IMAGE_PADDING/2 ,
                                                                TB_IMAGE_PADDING/2 ,
                                                                IMAGE_SIZE,
                                                                IMAGE_SIZE)];
    _albumView.contentMode = UIViewContentModeScaleAspectFill;
    _albumView.layer.cornerRadius = IMAGE_SIZE/2;
    [_albumView setClipsToBounds:YES];
    
    [slider.layer insertSublayer:_albumView.layer atIndex:0];
    
    
}
-(void)change{
    if(!nowPlayingQueue.hidden){
        
        [self toggleQueue];
        return;
    }
    
    
    
    if(!isConnected){
        if(isVisualizerSmall)
        {
            
            [UIView animateWithDuration:0.1f
                                  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 _albumView.alpha=0;
                                 _visualizeView.alpha=0;
                                 
                             }
                             completion:^(BOOL finished){
                                 isVisualizerSmall=NO;
                                 [_visualizeView.layer removeFromSuperlayer];
                                 [_albumView.layer removeFromSuperlayer ];
                                 
                                 
                                 [slider.layer insertSublayer:_visualizeView.layer atIndex:0];
                                 [bottomView.layer insertSublayer:_albumView.layer atIndex:0  ];
                                 [_visualizeView.layer setFrame:CGRectMake(TB_IMAGE_PADDING/2 , TB_IMAGE_PADDING/2 , IMAGE_SIZE, IMAGE_SIZE)];
                                 [_albumView.layer setFrame:CGRectMake(0,
                                                                       0,
                                                                       85,
                                                                       85)];
                                 _visualizeView.layer.cornerRadius=IMAGE_SIZE/2;
                                 _albumView.layer.cornerRadius = 85/2;
                                 [UIView animateWithDuration:0.3f
                                                       delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _albumView.alpha=1;
                                                      _visualizeView.alpha=1;
                                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                  }];
                             }];
            
            
        }
        
        else {
            [UIView animateWithDuration:0.1f
                                  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 _albumView.alpha=0;
                                 _visualizeView.alpha=0;
                                 
                             }
                             completion:^(BOOL finished){
                                 isVisualizerSmall=YES;
                                 [_visualizeView.layer setFrame:CGRectMake(0,
                                                                           0,
                                                                           85,
                                                                           85)];
                                 _visualizeView.layer.cornerRadius=85/2;
                                 [_albumView.layer setFrame:CGRectMake(TB_IMAGE_PADDING/2 , TB_IMAGE_PADDING/2 , IMAGE_SIZE, IMAGE_SIZE)];
                                 _albumView.layer.cornerRadius = IMAGE_SIZE/2;
                                 
                                 [_visualizeView.layer removeFromSuperlayer ];
                                 [_albumView.layer removeFromSuperlayer ];
                                 
                                 [slider.layer insertSublayer:_albumView.layer atIndex:0];
                                 [bottomView.layer insertSublayer:_visualizeView.layer atIndex:0  ];
                                 
                                 [UIView animateWithDuration:0.3f
                                                       delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _albumView.alpha=1;
                                                      _visualizeView.alpha=1;
                                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                  }];
                             }];
            
            
            
            
            
            
            
        }
    }
    else {
        
        [self disconnectAlert];
        
    }
    
    
    
}

-(void)setupCircularSlider{
    
    
    
         slider = [[CircularSlider alloc]initWithFrame:CGRectMake(((self.view.frame.size.width)/2)-(TB_SLIDER_SIZE/2),30, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
 
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
    
    [slider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin];
    
}
-(void)httpServerStartedOn:(NSString *)s{
    
    [dancingBarView changeItToConnectedView];
    [artistTitle setText:s];
    
    [self setupRemoteControlView];
}
-(void)httpServerStopped{
    
    [self removePlayrControl];
}
-(void)httpServerFailedToStart{
    
    
    [self removePlayrControl];
    
}
-(void)setupBottomView{
    self.tapreog=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change)];
    self.tapreog.delegate = self;
    
    bottomView=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-85/2,
                                                        topView.frame.size.height+slider.frame.size.height+52,
                                                        85,
                                                        85)];
    [bottomView addGestureRecognizer:self.tapreog];
    bottomView.layer.cornerRadius=85/2;
    bottomView.layer.masksToBounds=YES;
    bottomView.clipsToBounds=YES;
    bottomView.layer.borderWidth=1;
    bottomView.layer.borderColor=  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    [self.view addSubview:bottomView];
    
}
-(void)setupRemoteControlView{
    if(!isConnected){
        connectedImage=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broadcast" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
        
        if(_visualizeView)
        {[_visualizeView cleanUp];
            [_visualizeView.layer removeFromSuperlayer];
            _visualizeView=nil;
        }
        
        if(slider)
        {[slider removeFromSuperview];
            slider=nil;
        }
        if(_albumView)
        {
            [_albumView.layer removeFromSuperlayer];
            _albumView=nil;
        }
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _albumView = [[UIImageView alloc] initWithFrame: CGRectMake(((self.view.frame.size.width)/2)-(TB_SLIDER_SIZE/2),30, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
             
         }
         else {
         
             _albumView = [[UIImageView alloc] initWithFrame: CGRectMake(((self.view.frame.size.width)/2)-(TB_SLIDER_SIZE/2),self.view.frame.size.height/2-TB_SLIDER_SIZE/2, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];

         
         
         }
        _albumView.contentMode = UIViewContentModeScaleAspectFill;
        _albumView.layer.cornerRadius = TB_SLIDER_SIZE/2;
        [_albumView setClipsToBounds:YES];
        
        [self.view addSubview:_albumView];
        

        connectedImageView=[[UIImageView alloc] initWithFrame:CGRectMake(15,
                                                                         15,
                                                                         55,
                                                                         55)];
        
        connectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        _albumView.layer.borderWidth=5;
        
        [connectedImageView setClipsToBounds:YES];
        [bottomView.layer insertSublayer:connectedImageView.layer atIndex:0  ];
        
        [connectedImageView setImage:connectedImage];
        isConnected=YES;
        if([[AudioManager sharedInstance] currentStreamer]!=nil)
            [[[AudioManager sharedInstance] currentStreamer] stop];
        [self.view bringSubviewToFront:nowPlayingQueue];
        [rightView changeItToConnectedView];
        [[AudioManager sharedInstance] _resetStreamer];
    }
}

- (void)disconnectAlert
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Broadcast", nil)
                                                         message:NSLocalizedString(@"Do You Want To Stop?", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                               otherButtonTitles:NSLocalizedString(@"YES", nil)
, nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    alertView.delegate = self;
    alertView.tag=1;
    
    [alertView show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        if(alertView.tag==1){
            if([_imStream isHTTPRunning])
            {
                [_imStream startHTTPServer];
            }
        }
    }
}
-(void)removePlayrControl{
    if(isConnected){
        if(connectedImageView){
            [connectedImageView.layer removeFromSuperlayer];
            connectedImageView=nil;
        }
        if(_albumView)
        {
            [_albumView removeFromSuperview];
            
            [_albumView.layer removeFromSuperlayer];
            _albumView=nil;
        }
        
        [self setupCircularSlider];
        [self setupVisualizer];
        [self setupAlbumCover];
        [dancingBarView changeItBackToPlayr];
        isConnected=NO;
        [self.view bringSubviewToFront:nowPlayingQueue];
    }
    [self colorsChanged];
    
}
-(void)storeControllerAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PURCHASE_UPGRADE object:nil];
}
@end
