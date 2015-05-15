//
//  CJPAdController.h
//  CJPAdController 1.5.2
//
//  Created by Chris Phillips on 19/11/2011.
//  Copyright (c) 2011-2014 Chris Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

// Display iAds?
static BOOL const kUseiAd = YES;

// Display AdMob ads?
static BOOL const kUseAdMob = YES;

// Set which ads should be initially displayed and preferred ("iAd" or "AdMob")
static NSString * const kDefaultAds = @"AdMob";

// Your AdMob publisher ID
static NSString * const kAdMobID = @"ca-app-pub-7331839175310045/5717907819";

// Seconds to wait before displaying ad after the view loads (0.0 = instant)
static float const kWaitTime = 0.0;

// Where to position the ad on screen ("top" or "bottom")
static NSString * const kAdPosition = @"top";

// Comma-seperated string of device ID's for receiving test AdMob ads
static NSString * const kAdMobTestDeviceIDs = @"9ee3cc0851c21ef05aeb4b86cdbe096d";

// Use AdMob's "Smart" size banners (will fill full width of device)
// If set to NO, 320x50 ads will be used for iPhone/iPod and 728x90 for iPad
static BOOL const kUseAdMobSmartSize = YES;

// Show ad above the TabBar when ad position is set to bottom? (Only relevant if you're using a UITabBarController)
// WARNING: This functionality is currently buggy in iOS 7 (content will scroll under the ads). Therefore it is
// recommended that you leave this set to NO.
static BOOL const kAboveTabBar = YES;

// Name of UserDefaults key for if ads have been purchased (you can ignore this if you don't have an IAP to remove ads)
static NSString * const kAdsPurchasedKey = @"isAdOptOut";

// Are you testing? Setting to YES will NSLog various events
static BOOL const kAdTesting = NO;

// COPPA Compliance - by default this is left unset, but you can set the value to either 0 or 1 if you wish, based on the following guidelines:
/*
 From: https://developers.google.com/mobile-ads-sdk/docs/admob/additional-controls#coppa-setting
 If you set tagForChildDirectedTreatment to 1, you will indicate that your content should be treated as child-directed for purposes of COPPA.
 If you set tagForChildDirectedTreatment to 0, you will indicate that your content should not be treated as child-directed for purposes of COPPA.
 If you do not set tagForChildDirectedTreatment, ad requests will include no indication of how you would like your content treated with respect to COPPA.
 By setting this tag, you certify that this notification is accurate and you are authorized to act on behalf of the owner of the app. You understand that abuse of this setting may result in termination of your Google account.
*/
static NSString * const tagForChildDirectedTreatment = @"0";


@interface CJPAdController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView      *iAdView;
@property (nonatomic, strong) GADBannerView     *adMobView;
@property (nonatomic, strong) UIViewController  *contentController;
@property (nonatomic, strong) UIView            *containerView;
@property (nonatomic, assign) BOOL              showingiAd;
@property (nonatomic, assign) BOOL              showingAdMob;
@property (nonatomic, assign) BOOL              adsRemoved;
@property (nonatomic, assign) BOOL              isTabBar;

+ (CJPAdController *)sharedManager;
- (id)initWithContentViewController:(UIViewController *)contentController;
- (void)createBanner:(NSString *)adType;
- (void)removeBanner:(NSString *)adType permanently:(BOOL)permanent;
- (void)restoreBanner:(NSString *)adType;
- (void)removeAllAdsForever;
- (void)layoutAds;
- (UIViewController *)currentViewController;

@end