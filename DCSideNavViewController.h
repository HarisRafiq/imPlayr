////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DCSideNavViewController.h
//
//  Created by Dalton Cherry on 4/18/14.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "DCNavTab.h"
#import "imStreamer.h"
#import "DZWebBrowser.h"
@interface DCSideNavViewController : UIViewController<imStreamerDelegate>
{
    UINavigationController *webNavigation;

}
-(instancetype)initWithNav:(UINavigationController*)navBar;

/**
 This is the top tab to show in the side navigation bar.
 This tab is aligned with the navigation bar.
 */
@property(nonatomic,strong)DCNavTab *headerItem;
@property(nonatomic,strong)UINavigationController *navBar;
@property(nonatomic,strong)DZWebBrowser *webBrowser;

/**
 This is the tab items to show in the side navigation bar.
 */
@property(nonatomic,strong)NSArray *items;
@property (strong, nonatomic) imStreamer *imStream;

/**
 This is the bottom tab to show in the side navigation bar.
 This tab is at the very bottom of the navigation (which is useful settings icon).
 */
@property(nonatomic,strong)DCNavTab *footerItem;

/**
 Factory method to get this party started. Assign this to your window as the rootViewController.
 @param the view controller of the first view to display (it will be placed in a navigation controller).
 @return a newly created instance of DCSideNavViewController.
 */
+(DCSideNavViewController*)navWithController:(UIViewController*)vc;

@end
