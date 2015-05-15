//
//  DownloadViewController.h
//  FileSafe
//
//  Created by Lombardo on 14/04/13.
//
//

#import <UIKit/UIKit.h>
#import "TopPlayerView.h"

@interface DownloadViewController:UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,TopPlayerViewDelegate>
 @property (strong, nonatomic)   UIButton *downloadBTN;
@property (strong, nonatomic)   TopPlayerView *topPlayerView;

@property (strong, nonatomic)   UITextField *urlField;
@property (strong, nonatomic)   UITableView * tableView;

@end
