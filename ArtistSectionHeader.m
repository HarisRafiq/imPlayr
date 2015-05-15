//
//  ArtistSectionHeader.m
//  imPlayr2
//
//  Created by YAZ on 5/12/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "ArtistSectionHeader.h"
#import "AudioManager.h"
#import "UIColor+imPlayr.h"
#import "Utitlities.h"
@implementation ArtistSectionHeader
 
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
             self.contentView.backgroundColor= [[[AudioManager sharedInstance] bgColor] lighterColor];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
              artistImage=[[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(65/2), 2.5, 65, 65)];
            artistImage.layer.borderWidth=2;
            artistImage.layer.cornerRadius=65/2;
            artistImage.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
            titleArtist=[[UILabel alloc] initWithFrame:CGRectMake(5,5, (self.frame.size.width/2)-(65/2)-10, 60)];
            
            totalSongs=[[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2)+(65/2)+5,5, (self.bounds.size.width/2)-(65/2)-10, 60)];
            totalSongs.textAlignment=NSTextAlignmentCenter;
            titleArtist.textAlignment=NSTextAlignmentCenter;
            
            totalSongs.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12];
            titleArtist.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:14];
            titleArtist.numberOfLines=1;
            

        }
        
        else {
            
            
            artistImage=[[UIImageView alloc] initWithFrame:CGRectMake(15,5, 70, 70)];
            artistImage.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
            titleArtist=[[UILabel alloc] initWithFrame:CGRectMake(105,5, self.bounds.size.width-210, 70)];
            
            totalSongs=[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-90,5, 80, 70)];
            titleArtist.textColor=[UIColor colorWithRed:100.0/255.0  green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
            
            
            
            totalSongs.textAlignment=NSTextAlignmentCenter;
            titleArtist.textAlignment=NSTextAlignmentCenter;
            
            totalSongs.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:14];
            titleArtist.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:18];

        }
            titleArtist.textColor=[[[AudioManager sharedInstance] primaryColor] darkerColor] ;
            totalSongs.textColor=[[[AudioManager sharedInstance] primaryColor] darkerColor]   ;
;
            
            
        
                titleArtist.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        totalSongs.autoresizingMask =   UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
   
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews=YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
        artistImage.layer.backgroundColor= [UIColor blackColor].CGColor;
        artistImage.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin ;
        [artistImage setContentMode:UIViewContentModeScaleAspectFill];
        [artistImage setClipsToBounds:YES];
        [self addSubview:titleArtist];
        [self addSubview:totalSongs];
        [self addSubview:artistImage];
         
    }
    
    
    return self;
}
-(void)layoutSubviews

{[super layoutSubviews];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

    [titleArtist  setFrame:CGRectMake(5,5, (self.frame.size.width/2)-(65/2)-10, 60)];

    [totalSongs  setFrame:CGRectMake((self.frame.size.width/2)+(65/2)+5,5, (self.bounds.size.width/2)-(65/2)-10, 60)];
    [artistImage  setFrame:CGRectMake((self.frame.size.width/2)-(65/2), 2.5, 65, 65)];
    }
    else {
    
        [titleArtist  setFrame:CGRectMake(105,5, self.bounds.size.width-210, 70)];

        
        [totalSongs  setFrame:CGRectMake(self.bounds.size.width-90,5, 80, 70)];

        [artistImage  setFrame:CGRectMake(15,5, 70, 70)];
    
    
    }

}
-(UIImageView *)artistImageView{
    return artistImage;

}

-(void)setTotalSongs:(NSString *)s{totalSongs.text=s;}
-(void)setTitleArtist:(NSString *)a{titleArtist.text=a;}
-(void)setImage:(UIImage *)s{
    artistImage.image=s;}
 
-(void)setColor:(UIColor *)s{


    totalSongs.textColor=s;
    titleArtist.textColor=s;


}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end