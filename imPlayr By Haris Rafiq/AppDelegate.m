//
//  AppDelegate.m
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//
#define kLastDownload @"lastDownload"
#define kIsFirstTime @"isFirstTime"

#import "AppDelegate.h"
#import "MTZWhatsNewGridViewController.h"
#import "imStreamer.h"
#import "AudioManager.h"
#import  "DownloadManager.h"
#import "PlaylistManager.h"
#import "imConstants.h"
 #import "DownloadViewController_iPad.h"
#import "DCSideNavViewController.h"
#import "DCNavTabView.h"
#import "iPadSongsViewController.h"
#import "DownloadViewController_iPad.h"
#import "AudioControlsView.h"
#import "BottomView.h"
#import "DZWebBrowser.h"
#import "AllPlaylistsViewController.h"
#import "NowPlayingViewController_iPad.h"
NSString * const kStyleSheetImageIconError = @"icon-error.png";
NSString * const kStyleSheetImageIconSuccess = @"icon-success.png";
NSString * const kStyleSheetImageIconInfo = @"icon-info.png";
NSString * const kStyleSheetImageIconDownload = @"download_file.png";
NSString * const kStyleSheetImagePromoDownload = @"promo.png";


@interface MessageStyleSheet : NSObject <TWMessageBarStyleSheet>

+ (MessageStyleSheet *)styleSheet;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(paymentSucceded:)
                                                 name: kInAppPurchaseManagerTransactionSucceededNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(removeAdsAlert)
                                                 name: NOTIFICATION_PURCHASE_UPGRADE
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(paymentFailed:)
                                                 name: kInAppPurchaseManagerTransactionFailedNotification
                                               object: nil];

    _purchaseManager=[InAppPurchaseManager sharedInstance];
    [_purchaseManager loadStore];

    [DownloadManager sharedInstance];
    [TWMessageBarManager sharedInstance].styleSheet = [MessageStyleSheet styleSheet];
    [playrsMemory sharedInstance];
    [AudioManager sharedInstance];
   
    
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
 
if(isIPad)
{
    UIColor *color = [UIColor grayColor];
 
    iPadSongsViewController *SongsVC=[[iPadSongsViewController alloc] initWithNibName:@"iPadSongsViewController" bundle:nil];
 
    
    
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
    _webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    _webBrowser.showProgress = NO;
    _webBrowser.allowSharing = NO;
    webNavigation=[[UINavigationController alloc] initWithRootViewController:_webBrowser];
 
    
    sideBar = [DCSideNavViewController navWithController:SongsVC];
   

    sideBar.items = @[[DCNavTab tabWithTitle:NSLocalizedString(@"Songs", nil) image:[[UIImage imageNamed:@"songs"] makeThumbnailForBGWithSize:CGSizeMake(50,50) withCornerRadius:0]  selectedImage:nil selectedColor:color viewController:[iPadSongsViewController class]],[DCNavTab tabWithTitle:NSLocalizedString(@"Playlist", nil) image: [[UIImage imageNamed:@"playlist"] makeThumbnailForBGWithSize:CGSizeMake(50,50) withCornerRadius:0] selectedImage:nil selectedColor:color viewController:[AllPlaylistsViewController class]],  [DCNavTab tabWithTitle:NSLocalizedString(@"RemoveAds", nil) image:[[UIImage imageNamed:@"store"] makeThumbnailForBGWithSize:CGSizeMake(50,50) withCornerRadius:0]  selectedImage:nil selectedColor:color viewController:nil]];
      _adController = [[CJPAdController sharedManager] initWithContentViewController:sideBar];
    
    
    
}
else{
    _downloadVC=[[DownloadViewController alloc] init];
    _songsVC= [[LibraryViewController alloc] initWithNibName:@"SongsViewController" bundle:nil];
    _playlistVC=[[PlaylistTracksViewController alloc] init];
    _mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    _circleVC=[[UINavigationController alloc] initWithRootViewController:_mainVC];
    [_circleVC setNavigationBarHidden:YES];

   
    _adController = [[CJPAdController sharedManager] initWithContentViewController:_circleVC];


    
    }
    self.window.rootViewController = _adController;
    
    [self.window makeKeyAndVisible];
      if(! [self isNotFirstTime]){
    NSDictionary *broadCast = @{
                                @"icon" : @"broadcast",
                                @"title" : NSLocalizedString(@"Broadcast", nil),
                                @"detail" :NSLocalizedString(@"Stream And Control Your Music To Any Web Browser", nil) ,
                                
                                };
    NSDictionary *download = @{
                               @"icon" : @"download",
                               @"title" :NSLocalizedString(@"Download", nil) ,
                               @"detail" : NSLocalizedString(@"Download Music Anywhere From The Web", nil),
                               
                               };
    
    NSDictionary *Playlist = @{
                               @"icon" : @"playlist",
                               @"title" :NSLocalizedString(@"Playlist", nil) ,
                               @"detail" :NSLocalizedString(@"Save And Manage Your Now Playing Queue Into Playlists", nil) ,
                               
                               };
    NSDictionary *AlbumCover = @{
                                 @"icon" : @"album-cover",
                                 @"title" :NSLocalizedString( @"Album Artcover", nil),
                                 @"detail" :NSLocalizedString(@"Change Now Playing Track's Image From The Web", nil) ,
                                 
                                 };
    
    
    NSArray *array=[NSArray arrayWithObjects:broadCast, Playlist,AlbumCover, nil];
    
    NSDictionary *feature=[NSDictionary dictionaryWithObject:array forKey:@"3"];
    MTZWhatsNewGridViewController *vc = [[MTZWhatsNewGridViewController alloc] initWithFeatures:feature];
    // Customizing the background gradient.
    vc.backgroundGradientTopColor = [UIColor colorWithRed:0.88 green:0 blue:0 alpha:1];
    vc.backgroundGradientBottomColor = [UIColor colorWithRed:0.08 green:0 blue:0 alpha:1];
        
        
    // Presenting the what's new view controller.
    [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
        
    }
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self startRemoteEvent];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFirstTime ];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showPromoMessage:@"834734645"];
    return YES;
}
-(void)startRemoteEvent{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                
                [[AudioManager sharedInstance] _actionPlayPause:nil];
                
                break;
            case UIEventSubtypeRemoteControlPause:
                
                [[AudioManager sharedInstance] _actionPlayPause:nil];
                
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[AudioManager sharedInstance] _actionPrev];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[AudioManager sharedInstance] _actionNext];
                
                break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ( [[imStreamer sharedInstance] isHTTPRunning]) {
        [self beginBackgroundProcessKeepAlive];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSTimeInterval exp = [application backgroundTimeRemaining];
            NSLog(@"Remaining time: %lf", exp);
            
            [self cancelScheduledWarningNotification];
            
            UILocalNotification *note = [[UILocalNotification alloc] init];
            _warningNotification = note;
            
            note.alertBody =NSLocalizedString(@"Broadcast is about to be ended. Please come back soon or be disconnected", nil)  ;
            note.soundName = UILocalNotificationDefaultSoundName;
            note.fireDate = [NSDate dateWithTimeIntervalSinceNow:(exp - 30.0)];
            [application scheduleLocalNotification:note];
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [self cancelScheduledWarningNotification];
 /*   if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:@[@"public.url", @"public.text"]]) {
        NSURL *pasteURL = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.url"];
        if (!pasteURL || [[pasteURL absoluteString] isEqualToString:@""]) {
            NSString *pasteString = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.text"];
            pasteURL = [NSURL URLWithString:pasteString];
        }
        
        if (pasteURL && ![[pasteURL scheme] isEqualToString:@""] && ![[pasteURL absoluteString] isEqualToString:@""]&&[self isSupportedAudioMediaFormat:[pasteURL absoluteString]]&&![[self lastDownloadedFile] isEqualToString:[pasteURL absoluteString]]){
            
            [[NSUserDefaults standardUserDefaults] setObject:[pasteURL absoluteString] forKey:kLastDownload ];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showDownloadMessage:[pasteURL absoluteString]];
            
        }
        
        
        
    }*/
}
- (BOOL)isSupportedAudioMediaFormat:(NSString *)string
{
    NSUInteger options = NSRegularExpressionSearch | NSCaseInsensitiveSearch;
    return ([string rangeOfString:kSupportedAudioFileExtensions options:options].location != NSNotFound);
}

-(NSString *)lastDownloadedFile{
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults objectForKey:kLastDownload] ;
    
    
}
-(void)showWebBrowser{
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:webNavigation animated:NO completion:nil];
    [AppDelegate showHintMessage:nil];
 }

-(BOOL)isNotFirstTime{
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    return [standardDefaults boolForKey:kIsFirstTime] ;
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [self endBackgroundProcessKeepAlive];
    
    
}
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [DownloadManager sharedInstance];
}

#pragma mark - Background Processing

- (void)beginBackgroundProcessKeepAlive
{
    [self endBackgroundProcessKeepAlive];
    
    
    
    NSLog(@"[INFO] Trying to get an access to background processing. Remaining background timer = %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self beginBackgroundProcessKeepAlive];
        
    }];
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        NSLog(@"[ERROR] beginBackgroundTask failed.");
        self.backgroundTaskIdentifier = 0;
    } else {
        NSLog(@"[INFO] beginBackgroundTask succeeded. Remaining background timer = %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
    }
}

- (void)endBackgroundProcessKeepAlive
{
    if (self.backgroundTaskIdentifier) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = 0;
        
    }
}
-(void)showDisconnectedMessage{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Broadcast Disconnected", nil)
                                                   description:NSLocalizedString(@"Your broadcast has ended", nil)
                                                          type:TWMessageBarMessageTypeInfo
                                                      duration:3
                                                      callback:nil];
    
    
    
    
}

-(void)showErrorConnectingMessage{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Error Starting Broadcast", nil)
                                                   description:NSLocalizedString(@"Check Your Internet Connection And Try Again", nil)
                                                          type:TWMessageBarMessageTypeError
                                                      duration:3
                                                      callback:nil];
    
    
    
    
}
-(void)showSuccessMessage{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:[NSString stringWithFormat:@"http://%@",[[imStreamer sharedInstance] currentIP]]
                                                   description:NSLocalizedString(@"Type The Address In Any Web Browser Connected To The Same Network To Begin ", nil)
                                                          type:TWMessageBarMessageTypeSuccess
                                                      duration:15
                                                      callback:nil];
    
    
    
}
-(void)showDownloadMessage:(NSString *)s{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Tap To Download", nil)
                                                   description:[NSString stringWithFormat:@"You copied %@. ",s]
                                                          type:TWMessageBarMessageTypeDownload
                                                      duration:15
                                                      callback:^{
                                                          Download *download = [[DownloadManager sharedInstance] downloadForURL: [NSURL URLWithString:s] ];
                                                          
                                                          [download start];
                                                      }];
    
}
-(void)showPromoMessage:(NSString *)s{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Minoes World - A Falling Block Game", nil)
                                                   description:@"Created By Haris Rafiq.Tap To Download Now."
                                                          type:TWMessageBarMessageTypePromo
                                                      duration:15
                                                      callback:^{
                                                          NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@",s];
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];                                                      }];
    
}
+(void)showHintMessage:(NSString *)s{
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Tap And Hold On Any Image", nil)
                                                   description:NSLocalizedString(@"To Change the Now Playing Image", nil)
                                                          type:TWMessageBarMessageTypeInfo
                                                      duration:3
                                                      callback:^{
                                                          
                                                      }];
    
}

-(void)cancelScheduledWarningNotification
{
    if (_warningNotification)
        [[UIApplication sharedApplication] cancelLocalNotification:_warningNotification];
    _warningNotification = nil;
}

-(void)removeAdsAlert{
    
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"AdRemover", nil)
                                                  message:[NSString stringWithFormat:@"%@ for %@",NSLocalizedString(@"AdRemoverBody", nil),[_purchaseManager price]]
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"Buy", nil),NSLocalizedString(@"Restore", nil), nil];
    
    [alert setTag:1];
    
    [alert show];
    
    
}

-(void)buyAction{
    
    if([[InAppPurchaseManager sharedInstance] canMakePurchases])
        [[InAppPurchaseManager sharedInstance] purchaseProUpgrade];
}
-(void)restoreAction{
    
    
    [[InAppPurchaseManager sharedInstance] restoreCompletedTransactions];
}
- (void)paymentSucceded:(NSNotification *)notification {
   
    
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"TransactionSuccessfulTitle", nil)
                                                   description:NSLocalizedString(@"TransactionSuccessful", nil)
                                                          type:TWMessageBarMessageTypeSuccess
                                                      duration:4
                                                      callback:nil];

    
}
- (void)paymentFailed:(NSNotification *)notification {
    
 
    
    
     [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"TransactionFailedTitle", nil)
                                                   description:NSLocalizedString(@"TransactionFailed", nil)
                                                          type:TWMessageBarMessageTypeError
                                                      duration:4
                                                      callback:nil];

    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
 
    
    if ([alertView tag] == 1) {    // it's the Error alert
        if (buttonIndex == 1) {
            
            [self buyAction];
            
            
            
        }
        
        
        if (buttonIndex == 2) {
            [self restoreAction];
        }
    }
    
}

@end
@implementation MessageStyleSheet

#pragma mark - Alloc/Init

+ (MessageStyleSheet *)styleSheet
{
    return [[MessageStyleSheet alloc] init];
}
#pragma mark - TWMessageBarStyleSheet

- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type
{
    UIColor *backgroundColor = nil;
    switch (type)
    {
        case TWMessageBarMessageTypePromo:
        backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.95];
        break;
        case TWMessageBarMessageTypeDownload:
            backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.95];
            break;
        case TWMessageBarMessageTypeError:
            backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.95];
            break;
            
        case TWMessageBarMessageTypeSuccess:
            backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.95];
            break;
        case TWMessageBarMessageTypeInfo:
            backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.95];
            break;
        default:
            break;
    }
    return backgroundColor;
}

- (UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type
{
    UIColor *strokeColor = nil;
    switch (type)
    
    {
        case TWMessageBarMessageTypePromo:
        strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        break;
        case TWMessageBarMessageTypeDownload:
            strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case TWMessageBarMessageTypeError:
            strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case TWMessageBarMessageTypeSuccess:
            strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        case TWMessageBarMessageTypeInfo:
            strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
            break;
        default:
            break;
    }
    return strokeColor;
}

- (UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type
{
    UIImage *iconImage = nil;
    switch (type)
    { case TWMessageBarMessageTypePromo:
        iconImage = [UIImage imageNamed:kStyleSheetImagePromoDownload];
        break;
        
        case TWMessageBarMessageTypeError:
            iconImage = [UIImage imageNamed:kStyleSheetImageIconError];
            break;
        case TWMessageBarMessageTypeSuccess:
            iconImage = [UIImage imageNamed:kStyleSheetImageIconSuccess];
            break;
        case TWMessageBarMessageTypeInfo:
            iconImage = [UIImage imageNamed:kStyleSheetImageIconInfo];
            break;
        case TWMessageBarMessageTypeDownload:
            iconImage = [UIImage imageNamed:kStyleSheetImageIconDownload];
            break;
            
        default:
            break;
    }
    return iconImage;
}

- (UIFont *)titleFontForMessageType:(TWMessageBarMessageType)type
{
    return [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:17.0f];
}

- (UIFont *)descriptionFontForMessageType:(TWMessageBarMessageType)type
{
    return [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:13.0f];
}

- (UIColor *)titleColorForMessageType:(TWMessageBarMessageType)type
{
    if(type==TWMessageBarMessageTypeDownload )
        return [UIColor blackColor];
    
    return [UIColor whiteColor];
}

- (UIColor *)descriptionColorForMessageType:(TWMessageBarMessageType)type
{
    if(type==TWMessageBarMessageTypeDownload )
        return [UIColor blackColor];
    
    return [UIColor whiteColor];
}



@end
