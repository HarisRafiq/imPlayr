//
//  MiddleViewCell.m
//  imPlayr2
//
//  Created by YAZ on 6/2/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "MiddleViewCell.h"
#import  "AudioManager.h"
@implementation MiddleViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        middleView=[[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width/2)-(65/2), 2.5, 65, 65)];
        middleView.layer.borderWidth=2;
        middleView.layer.cornerRadius=65/2;
        middleView.layer.borderColor=[UIColor colorWithRed:0.155098 green:0.147255 blue:0.147255 alpha:1.0].CGColor;
        [self.contentView addSubview:middleView];
        middleView.clipsToBounds=YES;
        
        middleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 65, 55)];
        middleLabel.textAlignment=NSTextAlignmentCenter;
        middleLabel.font = [UIFont fontWithName:@"Bebas" size:20.0];
        
        middleLabel.text=@"Shuffle";
        middleLabel.textColor=[UIColor blackColor];
        [middleView addSubview:middleLabel];
        
        leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
        leftLabel.textColor= [UIColor colorWithRed:0.890196 green:0.890196 blue:0.890196 alpha:1];
        ;
        
        
        self.showsReorderControl=NO;
        leftLabel.textAlignment=NSTextAlignmentCenter;
        
        leftLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
        leftLabel.numberOfLines=0;
        
        leftLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:leftLabel];
        rightLabel=[[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width/2)+(65/2)+10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
        
        
        rightLabel.textColor= [UIColor colorWithRed:0.490196 green:0.490196 blue:0.490196 alpha:1];
        ;
        
        
        rightLabel.textAlignment=NSTextAlignmentCenter;
        
        rightLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12];
        rightLabel.numberOfLines=0;
        
        middleView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin ;
        [self.contentView addSubview:rightLabel];

        leftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        rightLabel.autoresizingMask =   UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews=YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
        borderView=[[UIView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-1,self.bounds.size.width, 1)];
        
        [self.contentView addSubview:borderView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.editing)
    {
        if(!self.selected){
            middleView.layer.backgroundColor= [UIColor colorWithRed:0.0784314 green:0.0784314 blue:0.0784314 alpha:1].CGColor;
            middleLabel.textColor = [UIColor grayColor];
        }
        else {
            
            
            middleView.layer.backgroundColor= [UIColor redColor].CGColor;
            middleLabel.textColor = [UIColor blackColor];
            
            
            
        }
        
    }
    
    else {
        middleView.layer.backgroundColor= [[AudioManager sharedInstance] primaryColor].CGColor;
        
        
        middleLabel.textColor = [[AudioManager sharedInstance] bgColor] ;
        
        
        
    }
    
    
    self.backgroundColor = [[AudioManager sharedInstance] bgColor];

    self.contentView.backgroundColor=[[AudioManager sharedInstance] bgColor];
    rightLabel.textColor = [[AudioManager sharedInstance] secondaryColor];
    
    leftLabel.textColor = [[AudioManager sharedInstance] secondaryColor];
    [middleView setFrame:CGRectMake((self.bounds.size.width/2)-(65/2), 2.5, 65, 65)];
    [rightLabel setFrame:CGRectMake((self.bounds.size.width/2)+(65/2)+10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
    
    [leftLabel setFrame:CGRectMake(10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
    borderView.backgroundColor=[[AudioManager sharedInstance] bgColorDark];

     [borderView setFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
 
}
-(void)setLeftLabel:(NSString *)s{        leftLabel.text=s;
    ;


}
-(void)setRightLabel:(NSString *)a{        rightLabel.text=a;
    ;
    
    
}

-(void)setMiddleLabel:(NSString *)a{        middleLabel.text=a;
    ;
    
    
}

@end
