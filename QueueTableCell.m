//
//  QueueTableCell.m
//  imPlayr2
//
//  Created by YAZ on 5/31/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "QueueTableCell.h"
#import "Utitlities.h"
#import "AudioManager.h"

@implementation QueueTableCell
{
    UILabel * _trackNumber;
    UILabel * _trackName;
    UILabel *_trackDuration;
    
    UIView *middleView;
    UIView *borderView;
    UIImageView * _nowPlayingImage;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
     if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
           self.backgroundColor = [UIColor clearColor];
         self.shouldIndentWhileEditing=NO;
         self.showsReorderControl=NO;
         
         self.contentView.backgroundColor=[UIColor clearColor];
        middleView=[[UIView alloc] initWithFrame:CGRectMake(2.5,10,self.frame.size.height-20, self.frame.size.height-20)];
         middleView.layer.cornerRadius=middleView.frame.size.height/2;
        middleView.layer.borderColor=[UIColor colorWithRed:0.155098 green:0.147255 blue:0.147255 alpha:1.0].CGColor;
        [self.contentView addSubview:middleView];
        middleView.clipsToBounds=YES;
        
        _trackNumber=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, middleView.bounds.size.height, middleView.bounds.size.height)];
        _trackNumber.textAlignment=NSTextAlignmentCenter;
        _trackNumber.font = [UIFont fontWithName:@"Bebas" size:10.0];
        
        _trackNumber.text=@"Shuffle";
        _trackNumber.textColor=[UIColor blackColor];
        [middleView addSubview:_trackNumber];
        
        _trackName=[[UILabel alloc] initWithFrame:CGRectMake(middleView.frame.size.width+5 ,0,self.frame.size.width - middleView.frame.size.height-45     , self.bounds.size.height)];
        _trackName.textColor= [UIColor colorWithRed:0.890196 green:0.890196 blue:0.890196 alpha:1];
        ;
        
        
         _trackName.textAlignment=NSTextAlignmentCenter;
        
        _trackName.font = [UIFont fontWithName:@"Ubuntu Condensed" size:15];
        _trackName.numberOfLines=1;
        
        _trackName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_trackName];
        _trackDuration=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40  ,0,35, self.frame.size.height)];
        
        
        _trackDuration.textColor= [UIColor colorWithRed:0.490196 green:0.490196 blue:0.490196 alpha:1];
        ;
        
        
        _trackDuration.textAlignment=NSTextAlignmentLeft;
        
        _trackDuration.font = [UIFont fontWithName:@"Bebas" size:10];
        _trackDuration.numberOfLines=1;
         [self.contentView addSubview:_trackDuration];

        _nowPlayingImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 13, 16, 16)];
        _nowPlayingImage.hidden = YES;
         
        [self.contentView addSubview:_nowPlayingImage];
         self.contentView.clipsToBounds=YES;
         self.clipsToBounds=YES;
         self.selectionStyle=UITableViewCellSelectionStyleNone;
         borderView=[[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
         
         [self.contentView addSubview:borderView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (self.editing)
    {
        
        if(!selected){
            middleView.layer.backgroundColor= [UIColor colorWithRed:0.0784314 green:0.0784314 blue:0.0784314 alpha:1].CGColor;
            _trackNumber.textColor = [UIColor grayColor];
        }
        else {
            
            
            middleView.layer.backgroundColor= [UIColor redColor].CGColor;
            _trackNumber.textColor = [UIColor blackColor];
            
            
            
        }
        
    }
    
    else {
        middleView.layer.backgroundColor= [UIColor clearColor].CGColor;
        
        
        _trackNumber.textColor = [[AudioManager sharedInstance] secondaryColor] ;
        
        
        
    }
    

}
- (void)setTrack:(playrsTrack *)track
{
    _track = track;
    _trackName.text = _track.title;
    _trackDuration.text =[Utitlities convertTimeFromSeconds: [_track.duration stringValue]];
    [self setNeedsLayout];
}
-(void)setTrackIndex:(NSInteger)i{
    
    _trackNumber.text = [NSString stringWithFormat:@"%.2d",i];
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.editing)
    {

        if(!self.selected){
            middleView.layer.backgroundColor= [UIColor colorWithRed:0.0784314 green:0.0784314 blue:0.0784314 alpha:1].CGColor;
            _trackNumber.textColor = [UIColor grayColor];
        }
        else {
            
            
            middleView.layer.backgroundColor= [UIColor redColor].CGColor;
            _trackNumber.textColor = [UIColor blackColor];
            
            
            
        }

    }
    
    else {
        middleView.layer.backgroundColor= [UIColor clearColor].CGColor;
        
        
        _trackNumber.textColor = [[AudioManager sharedInstance] secondaryColor] ;
        
        
        
    }
    
 

    _trackDuration.textColor = [[AudioManager sharedInstance] secondaryColor];
    
    _trackName.textColor = [[AudioManager sharedInstance] secondaryColor];
borderView.backgroundColor=[[AudioManager sharedInstance] bgColorDark];
    self.backgroundColor=[UIColor clearColor];
    
    [middleView setFrame:CGRectMake(2.5,10,self.frame.size.height-20, self.frame.size.height-20)];
[_trackNumber setFrame:CGRectMake(0, 0, middleView.bounds.size.height, middleView.bounds.size.height)];
    [_trackName setFrame:CGRectMake(middleView.frame.size.width+5 ,0,self.frame.size.width - middleView.frame.size.height-45     , self.bounds.size.height)];
    [_nowPlayingImage setFrame:CGRectMake(11, 13, 16, 16)];
    [borderView setFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
    [_trackDuration setFrame:CGRectMake(self.frame.size.width-40  ,0,35, self.frame.size.height)];


}
-(void)setIsPlaying{

    middleView.hidden=YES;
    _nowPlayingImage.hidden=NO;
 

         _nowPlayingImage.image=[Utitlities imageNamed:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"now-playing" ofType:@"png"]] withColor:[[AudioManager sharedInstance] secondaryColor]  ];
    
    
}
-(void)setNotPlaying{

    middleView.hidden=NO;
    _nowPlayingImage.hidden=YES;
    


}

@end
