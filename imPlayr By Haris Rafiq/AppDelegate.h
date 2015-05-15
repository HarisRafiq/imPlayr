//
//  AppDelegate.h
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 6/25/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadViewController.h"
#import "MainViewController.h"
#import   "PlaylistTracksViewController.h"
#import "LibraryViewController.h"
#import "TWMessageBarManager.h"
#import "CJPAdController.h"
#import "InAppPurchaseManager.h"
#import "DCSideNavViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UILocalNotification *_warningNotification;
    CJPAdController *_adController;
    DZWebBrowser *_webBrowser;
    DCSideNavViewController *sideBar;
    UINavigationController *webNavigation;
}
-(void)showWebBrowser;
@property (nonatomic, strong )  InAppPurchaseManager *purchaseManager;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) UINavigationController *circleVC;

@property (nonatomic, strong) DownloadViewController *downloadVC;
@property (nonatomic, strong) MainViewController *mainVC;

@property (nonatomic, strong) PlaylistTracksViewController *playlistVC;
@property (nonatomic, strong) LibraryViewController *songsVC;
 
@property (strong, nonatomic) UIWindow *window;
-(void)showSuccessMessage;
-(void)showErrorConnectingMessage;
-(void)showDisconnectedMessage;
+(void)showHintMessage:(NSString *)s;
-(BOOL)isNotFirstTime;
@end
