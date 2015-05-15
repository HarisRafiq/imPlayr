//
//  QueueTableCell.h
//  imPlayr2
//
//  Created by YAZ on 5/31/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "playrsTrack.h"
@interface QueueTableCell : UITableViewCell
@property (weak, nonatomic) playrsTrack * track;
 - (void)setTrack:(playrsTrack *)track;
-(void)setTrackIndex:(NSInteger)i;
-(void)setNotPlaying;
-(void)setIsPlaying;
@end
