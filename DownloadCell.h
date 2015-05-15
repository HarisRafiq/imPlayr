//
//  DownloadCell.h
//  FileSafe
//
//  Created by Lombardo on 14/04/13.
//
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell
{
    UIView *borderView;

}
@property (nonatomic, strong)   UILabel *fileName;
 @property (nonatomic, strong)   UIView *middleView;
@property (nonatomic, strong)   UILabel *percentageLabel;

@property (nonatomic, strong)   UILabel *progressLabel;

@end
