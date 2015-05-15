//  Created by Haris Rafiq on 01/30/13.
//  Copyright (c) 2013 Haris Rafiq. All rights reserved.

#import "fft.h"

@implementation fft
static fft *sharedInstance = nil;
@synthesize delegate;
@synthesize samples;
@synthesize frequency;
+ (fft *)sharedInstance
{
	if (sharedInstance == nil) {
		sharedInstance = [[fft alloc] init];
	}
	
	return sharedInstance;
}


-(id)init
{
    
    self = [super init];
    [self realFFTSetup];
	return self;
    
    
}
float MagnitudeSquared(float x, float y);
float MagnitudeSquared(float x, float y) {
	return ((x*x) + (y*y));
}




- (void)realFFTSetup {
    int size = 1024;
	fftSize = size;
    fftSizeOver2 = fftSize/2;
    log2n = log2f(fftSize);			// bins
    log2nOver2 = log2n/2;
    
    in_real = (float *) malloc(fftSize * sizeof(float));
    out_real = (float *) malloc(fftSize * sizeof(float));
    split_data.realp = (float *) malloc(fftSizeOver2 * sizeof(float));
    split_data.imagp = (float *) malloc(fftSizeOver2 * sizeof(float));
    
    windowSize = size;
    window = (float *) malloc(sizeof(float) * windowSize);
    memset(window, 0, sizeof(float) * windowSize);
    vDSP_hann_window(window, windowSize, vDSP_HANN_NORM);
    
    scale = 1.0f/(float)(4.0f*fftSize);
    
    // allocate the fft object once
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    if (fftSetup == NULL || in_real == NULL || out_real == NULL ||
        split_data.realp == NULL || split_data.imagp == NULL || window == NULL)
    {
        printf("\nFFT_Setup failed to allocate enough memory.\n");
    }
    
}


-(void)doFFTReal:(int) start :(int16_t *) buffer  {
    
    if(isEnabled==NO)
        return;
    
    float weighted_total = 0.0;
    float total = 0.0;
	//multiply by window
    vDSP_vflt16((int16_t *)buffer, 1, in_real, 1, fftSize);
    
    
    vDSP_vmul(in_real, 1, window, 1, in_real, 1, fftSize);
    
    //convert to split complex format with evens in real and odds in imag
    vDSP_ctoz((COMPLEX *) in_real, 2, &split_data, 1, fftSizeOver2);
    
    //calc fft
    vDSP_fft_zrip(fftSetup, &split_data, 1, log2n, FFT_FORWARD);
    split_data.imagp[0] = 0.0;
    float scales = 0.5;
    
    vDSP_vsmul(split_data.realp, 1, &scales, split_data.realp, 1, fftSizeOver2);
    vDSP_vsmul(split_data.imagp, 1, &scales, split_data.imagp, 1, fftSizeOver2);
    vDSP_zvmags(&split_data, 1, out_real, 1, fftSizeOver2);
    
    
    for (i = 0; i < fftSizeOver2; i++)
    {
        //compute power
        
        weighted_total+=(out_real[i]/fftSizeOver2)*i;
        total+=out_real[i];
        
    }
    
    currentValue=weighted_total / total;
    // NSLog(@"VALUE:%f",currentValue);
    
}


-(CGFloat)fetchfrequency

{
    if(isnan(currentValue))
        return 0;
   else
    return (CGFloat)currentValue;

}


-(void)setIsEnabled:(BOOL)s{
    
    isEnabled=s;
}



@end
