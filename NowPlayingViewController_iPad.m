//
//  NowPlayingViewController_iPad.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/20/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "NowPlayingViewController_iPad.h"
#import "AudioManager.h"
#import "dance.h"
#import "imNowPlayingViewController.h"
#import "UIImage+Thumbnail.h"
#import "imConstants.h"
#import  "UIImage+StackBlur.h"
#import "AppDelegate.h"
@interface NowPlayingViewController_iPad ()
{
 UIImageView *_albumView;
    BOOL isVisualizerSmall;
    imNowPlayingViewController *nowPlayingQueue;
    UIImageView *_bgView;
    CAGradientLayer *gradient;
    UIButton *webButton;

}
@property (strong, nonatomic) dance *visualizeView;

@end

@implementation NowPlayingViewController_iPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAlbumCover];
        [self setupAllSongs];
        
         [self addObservers];
        [self setupWebButton];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        
    }
    return self;
}

-(void)layoutSubviews{

    [nowPlayingQueue setFrame:CGRectMake(540,self.bounds.origin.y-1, 500,self.bounds.size.height)];
    [webButton setFrame:CGRectMake(540/2-25,
                                    self.bounds.origin.y+5,
                                    50,
                                    50)];

    [_albumView setFrame:CGRectMake(540/2-200,
                                    self.bounds.size.height/2-200+5,
                                    400,
                                    400)];
}

-(void)addObservers{
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorsChanged) name:NOTIFICATION_COLORS_CHANGED object:nil];
    [self colorsChanged];

}

-(void)removeObservers{

[[NSNotificationCenter defaultCenter] removeObserver:self];
    [nowPlayingQueue cleanUp];
    [nowPlayingQueue removeFromSuperview];
    [_albumView removeFromSuperview];
    
    nowPlayingQueue=nil;
    _albumView=nil;
}


-(void)setupAlbumCover{
    _albumView = [[UIImageView alloc] initWithFrame: CGRectMake(540/2-200,
                                                                self.frame.size.height/2-200,
                                                                400,
                                                                400)];
    _albumView.contentMode = UIViewContentModeScaleAspectFill;
     [_albumView setClipsToBounds:YES];
 
    [self addSubview:_albumView];
    
    
}
-(void)colorsChanged{
        self.backgroundColor =  [[AudioManager sharedInstance] bgColor]  ;
    
    [webButton setImage:      [Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"album-cover" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]]  forState:UIControlStateNormal];

    
    UIImage *image= [[AudioManager sharedInstance] nowPlayingImage]  ;
    if( _albumView.image!=image){
 
        _albumView.image=image;
    }
 }

-(void)setupAllSongs{
    
    nowPlayingQueue=[[imNowPlayingViewController alloc] initWithFrame:CGRectMake(540,-1, 500,self.bounds.size.height)];
    [self addSubview:nowPlayingQueue];
    [nowPlayingQueue switchToiPad];
    [nowPlayingQueue setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
 }
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)setupWebButton{
    webButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
      [webButton setImage:[[UIImage imageNamed:@"album-cover"] makeThumbnailForBGWithSize:CGSizeMake(45,45) withCornerRadius:0]   forState:UIControlStateNormal];
    
       [webButton addTarget:self action:@selector(showWebController) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:webButton];
}
-(void)showWebController{
    AppDelegate *app=(AppDelegate *) [[UIApplication sharedApplication] delegate];
    [app showWebBrowser];

}
@end
