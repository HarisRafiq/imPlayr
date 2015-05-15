//
//  DownloadCell.m
//  FileSafe
//
//  Created by Lombardo on 14/04/13.
//
//

#import "DownloadCell.h"
#import  "AudioManager.h"
@implementation DownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _middleView=[[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width/2)-(65/2), 2.5, 65, 65)];
        _middleView.layer.borderWidth=2;
        _middleView.layer.cornerRadius=65/2;
        _middleView.layer.borderColor=[UIColor colorWithRed:0.155098 green:0.147255 blue:0.147255 alpha:1.0].CGColor;
        [self.contentView addSubview:_middleView];
        _middleView.clipsToBounds=YES;
        
        _percentageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 65, 55)];
        _percentageLabel.textAlignment=NSTextAlignmentCenter;
        _percentageLabel.font = [UIFont fontWithName:@"Bebas" size:20.0];
        
        _percentageLabel.text=@"Shuffle";
        _percentageLabel.textColor=[UIColor blackColor];
        [_middleView addSubview:_percentageLabel];
        _fileName=[[UILabel alloc] initWithFrame:CGRectMake(10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
        _fileName.textColor= [UIColor colorWithRed:0.890196 green:0.890196 blue:0.890196 alpha:1];
        ;
        
        
        self.showsReorderControl=NO;
        _fileName.textAlignment=NSTextAlignmentCenter;
        
        _fileName.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:15];
        _fileName.numberOfLines=0;
        
        _fileName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_fileName];
        _progressLabel=[[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width/2)+(65/2)+10,5, (self.bounds.size.width/2)-(65/2)-20, 60)];
        
        
        _progressLabel.textColor= [UIColor colorWithRed:0.490196 green:0.490196 blue:0.490196 alpha:1];
        ;
        
        
        _progressLabel.textAlignment=NSTextAlignmentCenter;
        
        _progressLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12];
        _progressLabel.numberOfLines=0;
        
 
        [self.contentView addSubview:_progressLabel];
        _fileName.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        _progressLabel.autoresizingMask =   UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
        _middleView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin ;
        
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

/*
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSArray *objectsToMove = @[self.expectedBytes, self.totalBytes];
    float pixelToMove = 50.0f;
    float animationDuration = 0.3f;
    
    float delta = (editing) ? -pixelToMove : pixelToMove;
    
    void (^moveBlock)() = ^{
        for (UIView *view in objectsToMove) {
            view.center = CGPointMake(view.center.x + delta, view.center.y);
        }
    };
    
    if (editing != self.isEditing)
    {
        if (animated)
            [UIView animateWithDuration:animationDuration animations:moveBlock];
        else
            moveBlock();
    }
    
    [super setEditing:editing animated:animated];
}
*/
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.editing)
    {
        if(!self.selected){
            _middleView.layer.backgroundColor= [UIColor colorWithRed:0.0784314 green:0.0784314 blue:0.0784314 alpha:1].CGColor;
            _percentageLabel.textColor = [UIColor grayColor];
        }
        else {
            
            
            _middleView.layer.backgroundColor= [UIColor redColor].CGColor;
            _percentageLabel.textColor = [UIColor blackColor];
            
            
            
        }
        
    }
    
    else {
        _middleView.layer.backgroundColor= [[AudioManager sharedInstance] primaryColor].CGColor;
        
        
        _percentageLabel.textColor = [[AudioManager sharedInstance] bgColor] ;
        
        
        
    }
    
    
    self.backgroundColor = [[AudioManager sharedInstance] bgColor];
    
    
    self.contentView.backgroundColor=[[AudioManager sharedInstance] bgColor];
    _progressLabel.textColor = [[AudioManager sharedInstance] secondaryColor];
    
    _fileName.textColor = [[AudioManager sharedInstance] secondaryColor];
    borderView.backgroundColor=[[AudioManager sharedInstance] bgColorDark];
    
    [borderView setFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
    

}


@end
