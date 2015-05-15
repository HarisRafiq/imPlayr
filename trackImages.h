//
//  trackImages.h
//  imPlayr2
//
//  Created by YAZ on 6/6/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface trackImages :  NSObject{
	CGImageRef image;
	CGSize imageSize;
}

@property CGImageRef image;
@property CGSize imageSize;

@end