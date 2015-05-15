//
//  ArtistSectionHeader.h
//  imPlayr2
//
//  Created by YAZ on 5/12/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtistSectionHeader : UITableViewHeaderFooterView{
    UILabel *totalSongs;
    UILabel *titleArtist;
    UIImageView *artistImage;
}
-(void)setTotalSongs:(NSString *)s;
-(void)setTitleArtist:(NSString *)a;
-(void)setImage:(UIImage *)s;
-(void)setColor:(UIColor *)s;
-(UIImageView *)artistImageView;
@end
