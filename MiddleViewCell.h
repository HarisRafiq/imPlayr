//
//  MiddleViewCell.h
//  imPlayr2
//
//  Created by YAZ on 6/2/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiddleViewCell : UITableViewCell{

    UIView *middleView;
    UILabel *middleLabel;

    UILabel *leftLabel;
    UILabel *rightLabel;
    UIView *borderView;

}
-(void)setLeftLabel:(NSString *)s;
-(void)setRightLabel:(NSString *)a;
-(void)setMiddleLabel:(NSString *)a;
@end
