
//  DZWebBrowser.m
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZWebBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "SDURLCache.h"
#import "SDCachedURLResponse.h"
#import <objc/runtime.h>
 #import "AudioManager.h"
#import "imageManager.h"
#define kWebLoadingTimout 10.0
#define kDefaultControlsBundleName @"default-controls"

#define kImageTypeKey @"image"
#define kLinkTypeKey @"link"
#define kTypeKey @"type"
#define kTitleKey @"title"
#define kUrlKey @"url"

#define TXT_LOADING NSLocalizedString(@"TXT_LOADING",nil)
#define TXT_CLOSE NSLocalizedString(@"TXT_CLOSE",nil)
#define TXT_CANCEL NSLocalizedString(@"TXT_CANCEL",nil)
#define TXT_ACTIONSHEET_TWITTER NSLocalizedString(@"TXT_ACTIONSHEET_TWITTER",nil)
#define TXT_ACTIONSHEET_FACEBOOK NSLocalizedString(@"TXT_ACTIONSHEET_FACEBOOK",nil)
#define TXT_ACTIONSHEET_COPYLINK NSLocalizedString(@"TXT_ACTIONSHEET_COPYLINK",nil)
#define TXT_ACTIONSHEET_MAIL NSLocalizedString(@"TXT_ACTIONSHEET_MAIL",nil)
#define TXT_ACTIONSHEET_SAFARI NSLocalizedString(@"TXT_ACTIONSHEET_SAFARI",nil)
#define TXT_ACTIONSHEET_COPYIMG NSLocalizedString(@"TXT_ACTIONSHEET_COPYIMG",nil)
#define TXT_ACTIONSHEET_SAVEIMG NSLocalizedString(@"TXT_ACTIONSHEET_SAVEIMG",nil)
#define TXT_ALERT_NO_INTERNET NSLocalizedString(@"TXT_ALERT_NO_INTERNET",nil)
#define TXT_ALERT_NO_INTERNET_MESSAGE NSLocalizedString(@"TXT_ALERT_NO_INTERNET_MESSAGE",nil)
#define TXT_ALERT_NO_MAIL NSLocalizedString(@"TXT_ALERT_NO_MAIL",nil)
#define TXT_ALERT_NO_MAIL_MESSAGE NSLocalizedString(@"TXT_ALERT_NO_MAIL_MESSAGE",nil)
#define TXT_ALERT_OK NSLocalizedString(@"TXT_ALERT_OK",nil)

#define textForKey(key) [_resourceBundle localizedStringForKey:(key) value:@"" table:nil]

@interface DZLongPressGestureRecognizer : UILongPressGestureRecognizer
@end

@implementation DZLongPressGestureRecognizer
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}
@end

@interface UIActionSheet (Attachment)
@property (nonatomic, retain) NSMutableDictionary *userInfo;
@end
NSString * const kNewAttachmentKey = @"kNewAttachmentKey";
@implementation UIActionSheet (Attachment)
@dynamic userInfo;
- (void)setUserInfo:(NSMutableDictionary *)userInfo {
    objc_setAssociatedObject(self, (__bridge const void *)(kNewAttachmentKey),userInfo,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)userInfo {
    return objc_getAssociatedObject(self, (__bridge const void *)(kNewAttachmentKey));
}
@end

@interface DZWebBrowser ()
{
    UIBarButtonItem *_stopButton;
	UIBarButtonItem *_previousButton;
	UIBarButtonItem *_nextButton;
    UIBarButtonItem *_shareButton;
    
    UILabel *_titleLabel;
    UILabel *_urlLabel;
    
    UIActivityIndicatorView *_activityIndicator;
    UIProgressView *_progressView;
    
    NJKWebViewProgress *_progressProxy;
    
    NSBundle *_resourceBundle;
}
/**  */
@property(nonatomic, strong) UIImage *navBarBkgdImage;
/**  */
@property(nonatomic, strong) UIImage *toolBarBkgdImage;
/**  */
@property (nonatomic, strong) Reachability *netReach;
@end

@implementation DZWebBrowser
@synthesize webView = _webView;
@synthesize navBarBkgdImage = _navBarBkgdImage;
@synthesize toolBarBkgdImage = _toolBarBkgdImage;
@synthesize currentURL = _currentURL;
@synthesize netReach = _netReach;
 
- (id)initWebBrowserWithURL:(NSURL *)URL
{
    self = [super init];
    if (self)
    {
        _currentURL=URL;
        //Initializes the Internet reachability
        _netReach = [Reachability reachabilityForInternetConnection];
        [_netReach startNotifier];
        //Initializes the NSURLRequest Cache
        SDURLCache *cache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024 diskCapacity:1024*1024*5 diskPath:[SDURLCache defaultCachePath]];
        [NSURLCache setSharedURLCache:cache];

 
        [self loadWebView];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setToolbarItems:self.items animated:NO];
    
    
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:NO];

    
        [self.navigationItem setLeftBarButtonItem:self.closeButton animated:NO];
    
  
    UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [self.navigationItem setRightBarButtonItem:indicatorButton animated:NO];
   
    
    
    _previousButton.enabled = NO;
	_nextButton.enabled = NO;
    _shareButton.enabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    
    [self.navigationItem setLeftBarButtonItem:self.closeButton animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.toolbar setTranslucent:NO];
    [self.navigationController.toolbar setBarTintColor: [UIColor blackColor]];

    [self.navigationController.toolbar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    self.navigationController.navigationItem.titleView.tintColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor: [UIColor blackColor]];
    NSDictionary *navBarTitle=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navBarTitle];

    [self reloadWebView];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_showProgress) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
    }
    else {
        [self.navigationItem setTitleView:self.titleView];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
 
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];

    
    
    

}


#pragma mark - Getter Methods

- (NSString *)title
{
    return [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSString *)url
{
    return [_webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
}

- (UIWebView *)webView
{
    if (!_webView)
    {
        
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
         _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.suppressesIncrementalRendering = YES;
        _webView.scalesPageToFit = YES;
        _webView.delegate = self;
        
             DZLongPressGestureRecognizer *gesture = [[DZLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shouldPresentActionSheet:)];
            gesture.allowableMovement = 20;
            gesture.delegate = self;
            [_webView addGestureRecognizer:gesture];
                 
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.color = [UIColor whiteColor];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (UIView *)titleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self titleWidth], 44.0)];
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:self.urlLabel];
    return titleView;
}

- (CGFloat)titleWidth
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 632.0 : 188.0;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.0, [self titleWidth], 20.0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.minimumScaleFactor = 3;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor whiteColor];
         _titleLabel.shadowOffset = CGSizeMake(0, -1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)urlLabel
{
    if (!_urlLabel)
    {
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22.0, [self titleWidth], 20.0)];
        _urlLabel.backgroundColor = [UIColor clearColor];
        _urlLabel.font = [UIFont systemFontOfSize:14.0];
        _urlLabel.textColor = [UIColor blackColor];
         _urlLabel.textAlignment = NSTextAlignmentCenter;
        _urlLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _urlLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        _progressView.trackTintColor = [UIColor darkGrayColor];
        [self.navigationItem setTitleView:_progressView];
    }
    return _progressView;
}

- (UIBarButtonItem *)closeButton
{
    return [[UIBarButtonItem alloc] initWithTitle:textForKey(TXT_CLOSE) style:UIBarButtonItemStyleDone target:self action:@selector(closeAction:)];
}

- (NSArray *)items
{
    if (!_resourceBundleName) {
        [self setResourceBundleName:kDefaultControlsBundleName];
    }
    
    UIBarButtonItem *flexibleMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *margin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    margin.width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 50.0 : 15.0;
    
    UIImage *stopImg = [self imageNamed:@"stopButton" forBundleNamed:_resourceBundleName];
    UIImage *nextImg = [self imageNamed:@"nextButton" forBundleNamed:_resourceBundleName];
    UIImage *previousdImg = [self imageNamed:@"previousButton" forBundleNamed:_resourceBundleName];
    
    _stopButton = [[UIBarButtonItem alloc] initWithImage:stopImg style:UIBarButtonItemStylePlain target:self action:@selector(stopWebView)];
    _previousButton = [[UIBarButtonItem alloc] initWithImage:previousdImg style:UIBarButtonItemStylePlain target:self action:@selector(backWebView)];
    _nextButton = [[UIBarButtonItem alloc] initWithImage:nextImg style:UIBarButtonItemStylePlain target:self action:@selector(forwardWebView)];
    
    NSMutableArray *items = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? [NSMutableArray arrayWithObjects:margin, _stopButton, flexibleMargin, _previousButton, flexibleMargin, _nextButton, nil] : [NSMutableArray arrayWithObjects:margin, _stopButton, flexibleMargin, _previousButton, flexibleMargin, _nextButton, nil];
    
    if (_allowSharing) {
        [items addObject:flexibleMargin];
        _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
        [items addObject:_shareButton];
        [items addObject:margin];
    }
    else {
        [items addObject:flexibleMargin];
        [items addObject:flexibleMargin];
    }
    
    return items;
}

- (CGSize)windowSize
{
    CGSize size;
    size.width = [[_webView stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[_webView stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (UIImage *)imageNamed:(NSString *)imgName forBundleNamed:(NSString *)bundleName
{
    NSString *path = [NSString stringWithFormat:@"%@.bundle/images/%@",bundleName,imgName];
    return [UIImage imageNamed:path];
}

#pragma mark - Setter Methods

- (void)setNavBarBkgdImage:(UIImage *)image
{
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setToolBarBkgdImage:(UIImage *)image
{
    [self.navigationController.toolbar setBackgroundImage:image forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}

- (void)setResourceBundleName:(NSString *)name
{
    _resourceBundleName = name;
    
    if (!_resourceBundle) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:_resourceBundleName ofType:@"bundle"];
        _resourceBundle = [NSBundle bundleWithPath:bundlePath];
    }
}

- (void)setLoadingTitle
{
    _titleLabel.text = textForKey(TXT_LOADING);
    
    CGRect rect = _titleLabel.frame;
    rect.origin.y = 12.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _titleLabel.frame = rect;
                         _urlLabel.alpha = 0;
                     }
                     completion:NULL];
}

- (void)setDocumentTitle
{
    _titleLabel.text = [self title];
    _urlLabel.text = [self url];
    
    CGRect rect = _titleLabel.frame;
    rect.origin.y = 2.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _titleLabel.frame = rect;
                         _urlLabel.alpha = 1.0;
                     }
                     completion:NULL];
}

- (void)showLoadingIndicator:(BOOL)show
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
    
    if (!_showProgress) {
        if (show) {
            [self setLoadingTitle];
            [_activityIndicator startAnimating];
        }
        else {
            [self setDocumentTitle];
            [_activityIndicator stopAnimating];
        }
    }
}


#pragma mark - WebViewController Methods

- (void)stopWebView
{
	[_webView stopLoading];
    [self showLoadingIndicator:NO];
}

- (void)backWebView
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (void)forwardWebView
{
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)loadWebView
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:_currentURL]];
}

- (void)reloadWebView
{
    [self.webView reload];
}

- (void)shareAction:(id)sender
{
    [self ripAction:self];}

- (void)shouldPresentActionSheet:(DZLongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self stopWebView];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"js"];
        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView stringByEvaluatingJavaScriptFromString:script];
        
        CGPoint point = [gesture locationInView:_webView];
        
        //// Get the URL link at the touch location
        NSString *function = [NSString stringWithFormat:@"script.getElement(%li,%li);", (long)point.x, (long)point.y];
         NSString *result = [_webView stringByEvaluatingJavaScriptFromString:function];
        
        NSData *JSONData = [result dataUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil]];
        
        gesture.view.accessibilityActivationPoint = point;
        
        if (!dict || dict.count == 0) {
            [self presentActionSheetFromView:gesture.view];
        }
        else {
            [self presentActionSheetFromView:gesture.view withUserInfo:dict];
        }
        
      
    }
}
-(void)ripAction:(id)sender{
  


}
- (void)closeAction:(id)sender
{
    [self browserWillClose];
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    if(isIPad)
    {
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)browserWillClose
{
    [self showLoadingIndicator:NO];
    
    [_webView stopLoading];
    
    [[SDURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)presentActionSheetFromView:(UIView *)view
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:kLinkTypeKey,kTypeKey,[self title],kTitleKey,[self url],kUrlKey,nil];
    [self presentActionSheetFromView:view withUserInfo:dict];
}

- (void)presentActionSheetFromView:(UIView *)view withUserInfo:(NSMutableDictionary *)userInfo
{
    NSString *type = [userInfo objectForKey:kTypeKey];
    NSString *title = [userInfo objectForKey:kTitleKey];
    NSString *url = [userInfo objectForKey:kUrlKey];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.userInfo = userInfo;
  

    if ([type isEqualToString:kImageTypeKey]) {
         [actionSheet addButtonWithTitle:textForKey(TXT_ACTIONSHEET_SAVEIMG)];
        
        [actionSheet addButtonWithTitle:textForKey(TXT_CANCEL)];
        actionSheet.cancelButtonIndex = 1;
        [actionSheet.userInfo setObject:url forKey:kImageTypeKey];

    }
    else {
        [actionSheet addButtonWithTitle:textForKey(TXT_ACTIONSHEET_COPYLINK)];
        
        [actionSheet addButtonWithTitle:textForKey(TXT_CANCEL)];
        actionSheet.cancelButtonIndex = 1;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([view isKindOfClass:[UIBarButtonItem class]]) {
            [actionSheet showFromBarButtonItem:(UIBarButtonItem *)view animated:YES];
        }
        else if ([view isEqual:_webView]) {
            CGPoint point = view.accessibilityActivationPoint;
            [actionSheet showFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.view animated:YES];
        }
        else {
            [actionSheet showFromRect:view.frame inView:self.view animated:YES];
        }
    }
    else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
    
   }


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    self.currentURL = request.URL;
    _stopButton.enabled = YES;
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview
{
	[self showLoadingIndicator:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    _stopButton.enabled = NO;
    _previousButton.enabled = [webview canGoBack];
    _nextButton.enabled = [webview canGoForward];
    _shareButton.enabled = YES;
    
    [self showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webview];
    [self showLoadingIndicator:NO];
}


#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
    
    if (progress == 1.0) {
        _progressView = nil;
        [self.navigationItem setTitleView:self.titleLabel];
        _titleLabel.text = [self title];
    }
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[DZLongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *attachment = [actionSheet.userInfo objectForKey:kImageTypeKey];
     NSString *url = [actionSheet.userInfo objectForKey:kUrlKey];
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:textForKey(TXT_ACTIONSHEET_SAVEIMG)])
    {
        
        
        if(attachment!=nil){
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:attachment]];
                UIImage *image =  [UIImage imageWithData:data] ;
                if(image!=nil){
                    [imageManager removeFileForTrack:[[[AudioManager sharedInstance] currentTrack] audioFileURLstr]];
                    [imageManager saveToFile:image];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self closeAction:nil];
                        
                    });
                }
            });
            
            
            
            [self closeAction:nil];
        }
    }
     else if ([buttonTitle isEqualToString:textForKey(TXT_ACTIONSHEET_COPYLINK)])
    {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:url];
    }
  

   }


#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Reachability Notification

- (void)reachabilityChanged8
{
    if (![self networkReachable])
    {
        [_webView stopLoading];
        
        _nextButton.enabled = NO;
        _shareButton.enabled = NO;
        
        UIAlertView *alertNoInternet = [[UIAlertView alloc] initWithTitle:textForKey(TXT_ALERT_NO_INTERNET)
                                                                  message:textForKey(TXT_ALERT_NO_INTERNET_MESSAGE)
                                                                 delegate:nil
                                                        cancelButtonTitle:textForKey(TXT_ALERT_OK)
                                                        otherButtonTitles:nil];
        [alertNoInternet show];
    }
}

- (BOOL)networkReachable
{
	NetworkStatus netStatus = [self.netReach currentReachabilityStatus];
	BOOL connectionRequired = [self.netReach connectionRequired];
	
	if (((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN)) && (!connectionRequired)) {
		return YES;
	}
	return NO;
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _currentURL = [NSURL URLWithString:[self url]];
    
    [_webView removeFromSuperview];
    [self setWebView:nil];
    
    [self loadWebView];

    [[SDURLCache sharedURLCache] removeAllCachedResponses];

}

- (void)viewWillUnload
{
    [super viewWillUnload];
    [[SDURLCache sharedURLCache] removeAllCachedResponses];

 }

- (void)dealloc
{
    [self setWebView:nil];
    [self setCurrentURL:nil];
    [self setResourceBundleName:nil];
    [self setNavBarBkgdImage:nil];
    [self setToolBarBkgdImage:nil];
    [self setNetReach:nil];
    [[SDURLCache sharedURLCache] removeAllCachedResponses];

}

@end
