////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DCSideNavViewController.m
//
//  Created by Dalton Cherry on 4/18/14.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "DCSideNavViewController.h"
#import "DCNavTabView.h"
#import "BottomView.h"
#import "AudioControlsView.h"
#import "NowPlayingViewController_iPad.h"
#import "imConstants.h"
#import "AudioManager.h"
@interface DCSideNavViewController (){
    BottomView *_bottomView;
    BOOL isControlsVisible;
    AudioControlsView *_audioControlsView;
}
@property(nonatomic,strong)NowPlayingViewController_iPad *nowplayingVC;

@property(nonatomic,strong)UIView *tabBarView;
@property(nonatomic,strong)NSMutableArray *tabViews;

@end

@implementation DCSideNavViewController

static CGFloat barWidth = 88;
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(instancetype)initWithNav:(UINavigationController *)navBar
{
    if(self = [super init])
    {
        self.navBar = navBar;
        [self.navBar.navigationBar setTranslucent:NO];
        isControlsVisible=YES;
        [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(toggleSwitch) name:NOTIFICATION_VISUALIZER_SWITCH object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setColorScheme) name:NOTIFICATION_COLORS_CHANGED object:nil];
        _imStream=[imStreamer sharedInstance];
        [_imStream setDelegate:self];
       
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)httpServerStartedOn:(NSString *)s{
    if([[AudioManager sharedInstance] currentStreamer]!=nil)
        [[[AudioManager sharedInstance] currentStreamer] stop];
     [[AudioManager sharedInstance] _resetStreamer];

    [_audioControlsView broadCastStartedOn: [NSString stringWithFormat:@"http://%@",s]];
    [_bottomView setHttpON];
 }
-(void)httpServerStopped{
    [_audioControlsView broadCastStartedOn:@"Off"];
    [_bottomView setHttpOFF];

 }
-(void)httpServerFailedToStart{
    
    [_audioControlsView broadCastStartedOn:@"Failed To Start"];
    [_bottomView setHttpOFF];

}

-(void)setColorScheme{
    
    
    [self.navBar.toolbar setBarTintColor: [AudioManager sharedInstance].bgColorDark];

         [self.navBar.toolbar setTintColor:[AudioManager sharedInstance].secondaryColor];
    [self.navBar.navigationBar setTintColor:[AudioManager sharedInstance].secondaryColor];
    self.navBar.navigationItem.rightBarButtonItem.tintColor=[AudioManager sharedInstance].secondaryColor;
    self.navBar.navigationItem.titleView.tintColor=[AudioManager sharedInstance].secondaryColor;
    [self.navBar.navigationBar setBarTintColor: [AudioManager sharedInstance].bgColorDark];
    NSDictionary *navBarTitle=[NSDictionary dictionaryWithObjectsAndKeys:[AudioManager sharedInstance].secondaryColor,NSForegroundColorAttributeName, nil];
    [self.navBar.navigationBar setTitleTextAttributes:navBarTitle];
    self.tabBarView.backgroundColor = [AudioManager sharedInstance].bgColorDark ;
    self.view.backgroundColor = [AudioManager sharedInstance].bgColorDark ;

    
    [self changeTabColor];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat left = 0;
    CGFloat top = 100;
    CGFloat bottom =200;
   
    
    

    self.tabBarView = [[UIView alloc] initWithFrame:CGRectMake(left, top, barWidth, self.view.frame.size.height-bottom)];
    
    self.tabBarView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tabBarView];
    left += self.tabBarView.frame.size.width;
    [self addChildViewController:self.navBar];
    [self.view addSubview:self.navBar.view];
    self.navBar.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.navBar.view.frame = CGRectMake(left, top, self.view.frame.size.width-(left), self.view.frame.size.height-bottom);
    [self layoutTabs:[[UIApplication sharedApplication] statusBarOrientation]];
  
    _bottomView=[[BottomView alloc] initWithFrame:CGRectMake(left, self.view.bounds.size.height-100, self.view.bounds.size.width-left, 100)];
    _audioControlsView=[[AudioControlsView alloc] initWithFrame:CGRectMake(left, 0, self.view.bounds.size.width-left, 100)];
    [self.view addSubview:_audioControlsView];
    [self.view addSubview:_bottomView];

    if(self.tabViews.count > 0)
    {
        DCNavTabView *tabView = self.tabViews[0];
        [tabView setSelected:YES];
    }
    
 }

-(void)changeTabColor{
    for(DCNavTabView *view in self.tabViews){
    
        view.tab.image=[Utitlities imageNamed:view.tab.image withColor:[[AudioManager sharedInstance] secondaryColor]];
    view.titleLabel.textColor=[[AudioManager sharedInstance] secondaryColor];
    }
    
    

}
-(void)toggleSwitch{
    if(isControlsVisible){
    
        [self switchToMainView];
    
    }
    else {
    
        [self switchBackToControlView];
    }
    isControlsVisible=!isControlsVisible;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutTabs:toInterfaceOrientation];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutTabs:(UIInterfaceOrientation)orient
{
    for(UIView *view in self.tabViews)
        [view removeFromSuperview];
    if(!self.tabViews)
        self.tabViews = [NSMutableArray new];
    CGFloat pad = 15;
    if(UIInterfaceOrientationIsLandscape(orient) && self.items.count > 8 && self.footerItem) //too many tabs...
        pad = 5;
    CGFloat top = 0;
     CGFloat left = 0;
    CGFloat tabHeight = barWidth/2 + 20;
    if(self.headerItem)
    {
        top = 120;
        DCNavTabView *headerView = [self createTabView:self.headerItem];
        headerView.frame = CGRectMake(left, top, barWidth, tabHeight-top);
    }
    top = tabHeight + top;
    for(DCNavTab *tab in self.items)
    {
        DCNavTabView *tabView = [self createTabView:tab];
        tabView.frame = CGRectMake(left, top, barWidth, tabHeight);
        top += tabHeight + pad;
    }
    if(self.footerItem)
    {
        top = self.view.frame.size.height;
        if(UIInterfaceOrientationIsLandscape(orient))
            top = self.view.frame.size.width;
        DCNavTabView *footerView = [self createTabView:self.footerItem];
        footerView.frame = CGRectMake(left, top-tabHeight, barWidth, tabHeight);
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(DCNavTabView*)createTabView:(DCNavTab*)tab
{
    DCNavTabView *view = [DCNavTabView new];
    view.tab = tab;
    [self.tabBarView addSubview:view];
    [self.tabViews addObject:view];
    [view.buttonView addTarget:self action:@selector(didTapTab:) forControlEvents:UIControlEventTouchUpInside];
    if(view.customView)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTab:)];
        [view.customView addGestureRecognizer:tap];
    }
    return view;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didTapTab:(id)sender
{
    DCNavTabView *tabView = nil;
    if([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        UIView *view = [sender view];
        tabView = (DCNavTabView*)view.superview;
    }
    else
    {
        UIButton *button = sender;
        tabView = (DCNavTabView*)button.superview;
        
    }
    for(DCNavTabView *view in self.tabViews)
        [view setSelected:NO];
    
    [tabView setSelected:YES];
    if( tabView.tab.vcClass!=nil){
     UIViewController *vc = [[tabView.tab.vcClass alloc] init];
    [self switchTab:vc];
    }
    else {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PURCHASE_UPGRADE object:nil];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)switchTab:(UIViewController*)vc
{
    [self.navBar removeFromParentViewController];
    [self.navBar.view removeFromSuperview];
    UINavigationController *newNavBar = [[UINavigationController alloc] initWithRootViewController:vc];
    self.navBar = newNavBar;
    [self addChildViewController:self.navBar];
    [self.view addSubview:self.navBar.view];
    self.navBar.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self setColorScheme];
    CGFloat left = self.tabBarView.frame.size.width;
    CGFloat top = 100;
    CGFloat bottom =200;
    
    CGRect frame = self.view.frame;
    
    self.navBar.view.frame = CGRectMake(left, top, frame.size.width-(left), frame.size.height-bottom);
    [self.navBar.navigationBar setTranslucent:NO];

}
-(void)switchToMainView{
    
    _nowplayingVC= [[NowPlayingViewController_iPad alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-200)];
  
    [_nowplayingVC setFrame : CGRectMake(self.view.frame.size.width,100, self.view.frame.size.width, self.view.frame.size.height-200)];
     [self.view addSubview:_nowplayingVC];
    [ _nowplayingVC setAutoresizingMask:UIViewAutoresizingFlexibleHeight];

    [UIView animateWithDuration:0.1f
                          delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        [self.navBar.view setFrame:CGRectMake(-self.view.frame.size.width,100, self.view.frame.size.width, self.view.frame.size.height-200)];
                         [_nowplayingVC setFrame:CGRectMake(0,100, self.view.frame.size.width, self.view.frame.size.height-200)];
                         
                         [_bottomView setFrame:CGRectMake(0, self.view.bounds.size.height-100, self.view.bounds.size.width, 100)];
                         [_audioControlsView setFrame:CGRectMake(0, 0, self.view.bounds.size.width , 100)];
 
                     }
                     completion:^(BOOL finished){
                      

                     }];

}
-(void)switchBackToControlView{

    [UIView animateWithDuration:0.1f
                          delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.navBar.view setFrame:CGRectMake(self.tabBarView.frame.size.width,100, self.view.frame.size.width-self.tabBarView.frame.size.width, self.view.frame.size.height-200)];
                         [_nowplayingVC setFrame: CGRectMake(self.view.frame.size.width,100, self.view.frame.size.width, self.view.frame.size.height-200)];
                         [_bottomView setFrame:CGRectMake(self.tabBarView.frame.size.width, self.view.bounds.size.height-100, self.view.bounds.size.width-self.tabBarView.frame.size.width, 100)];
                         [_audioControlsView setFrame:CGRectMake(self.tabBarView.frame.size.width, 0, self.view.bounds.size.width-self.tabBarView.frame.size.width , 100)];
                         
                     }
                     completion:^(BOOL finished){
                         [_nowplayingVC removeObservers];
                          [_nowplayingVC removeFromSuperview];
                         _nowplayingVC=nil;
                     }];


}


////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setHeaderItem:(DCNavTab *)headerItem
{
    _headerItem = headerItem;
    _headerItem.isHeader = YES;
    [self layoutTabs:[[UIApplication sharedApplication] statusBarOrientation]];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFooterItem:(DCNavTab *)footerItem
{
    _footerItem = footerItem;
    _footerItem.isHeader = NO;
    [self layoutTabs:[[UIApplication sharedApplication] statusBarOrientation]];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setItems:(NSArray *)items
{
    _items = items;
    for(DCNavTab *tab in items)
        tab.isHeader = NO;
    [self layoutTabs:[[UIApplication sharedApplication] statusBarOrientation]];
    if(self.tabViews.count > 0)
    {
        DCNavTabView *tabView = self.tabViews[0];
        [tabView setSelected:YES];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - factory methods
////////////////////////////////////////////////////////////////////////////////////////////////////
+(DCSideNavViewController*)navWithController:(UIViewController*)vc
{
    UINavigationController *newNavBar = [[UINavigationController alloc] initWithRootViewController:vc];
    DCSideNavViewController *side = [[DCSideNavViewController alloc] initWithNav:newNavBar];
    return side;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showWebBrowser{



}
@end
