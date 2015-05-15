//
//  fft.h
//  Created by Haris Rafiq on 01/30/13.
//  Copyright (c) 2013 Haris Rafiq. All rights reserved.
#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <Accelerate/Accelerate.h>
#include <stdlib.h>
#define kBufferSize 1024
#define kBufferCount 1
#define N 10
@protocol fftDelegate;
@interface fft : NSObject
{
    id<fftDelegate> delegate;
    
	int					fftSize,
    fftSizeOver2,
    log2n,
    log2nOver2,
    windowSize,
    i;
	
    
	
    BOOL isEnabled;
	float currentValue;
	float				*in_real,
    *out_real,
    *window;
	
	float				scale;
    int16_t _sampleBuffer[1024];
    
    FFTSetup			fftSetup;
    COMPLEX_SPLIT		split_data;
}
-(CGFloat)fetchfrequency;
@property(assign) int samples ;
@property(assign) float frequency;
+ (fft *)sharedInstance;
-(void)doFFTReal:(int) start :(int16_t *) buffer;
@property (assign,readwrite )id<fftDelegate> delegate;
-(void)setIsEnabled:(BOOL)s;


@end
@protocol fftDelegate<NSObject>

- (void)fft:(fft *)ffts
didChangeFrequency:(float)frequency
;

@end