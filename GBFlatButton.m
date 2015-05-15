//
//  GBFlatButton.m
//  GBFlatButtonExample
//
//  Created by Gustavo Barbosa on 4/15/14.
//  Copyright (c) 2014 Gustavo Barbosa. All rights reserved.
//

#import "GBFlatButton.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioManager.h"
static CGFloat const kHorizontalPadding = 14.0f;

@implementation GBFlatButton

#pragma mark - Constructors

- (id)init
{
    self = [super init];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

#pragma mark - Appearance

- (void)customizeAppearance
{
    BOOL containsEdgeInsets = ! UIEdgeInsetsEqualToEdgeInsets(self.contentEdgeInsets, UIEdgeInsetsZero);
    self.contentEdgeInsets = containsEdgeInsets ? self.contentEdgeInsets : UIEdgeInsetsMake(0, kHorizontalPadding, 0, kHorizontalPadding);
    self.layer.borderWidth = self.layer.borderWidth ?: 1.0f;
    self.layer.cornerRadius = self.layer.cornerRadius ?: CGRectGetHeight(self.frame) / 2.0f;
    self.clipsToBounds = YES;
 }

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
 
}

- (void)drawRect:(CGRect)rect
{
    
    
    self.backgroundColor =[[AudioManager sharedInstance] bgColoLight];
    self.layer.backgroundColor =[[AudioManager sharedInstance] bgColoLight].CGColor;
    self.layer.borderColor = [[AudioManager sharedInstance] bgColoLight].CGColor;
    [self setTitleColor:[[AudioManager sharedInstance] secondaryColor]
               forState:UIControlStateNormal];
    [self setTitleColor:[[AudioManager sharedInstance] secondaryColor]
               forState:UIControlStateSelected];
}

#pragma mark - Acessors

- (UIColor *)buttonColor
{
    return _buttonColor ;
}

@end
