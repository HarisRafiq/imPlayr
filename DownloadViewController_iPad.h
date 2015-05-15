//
//  DownloadViewController_iPad.h
//  imPlayr By Haris Rafiq
//
//  Created by YAZ on 7/19/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadViewController_iPad : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic)   UIButton *downloadBTN;
 
@property (strong, nonatomic)   UITextField *urlField;
@property (strong, nonatomic)   UITableView * tableView;

@end
