//
//  AudioRenderer.m
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "AudioRenderer.h"
#import "AudioDecoder.h"
#import "AudioToolbox/AudioToolbox.h"
#import "fft.h"

#include <CoreAudio/CoreAudioTypes.h>
#include <AudioUnit/AudioUnit.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/time.h>
#include <mach/mach_time.h>
#if !TARGET_OS_IPHONE
#include <CoreAudio/CoreAudio.h>
#endif /* !TARGET_OS_IPHONE */

#if TARGET_OS_IPHONE
#include <Accelerate/Accelerate.h>
#endif /* TARGET_OS_IPHONE */

@interface AudioRenderer () {
@private
    pthread_mutex_t _mutex;
    pthread_cond_t _cond;
    
    AudioUnit outputUnit;
    AudioUnit mixerUnit;
    AudioUnit mixerUnit2;
    AUGraph _graph;
    AUNode _mixerNode;
    AUNode _mixerNode2;
    AUNode _outputNode;
    uint8_t *_buffer;
    NSUInteger _bufferByteCount;
    NSUInteger _firstValidByteOffset;
    NSUInteger _validByteCount;
    
    NSUInteger _bufferTime;
    BOOL _started;
    
    
    uint64_t _startedTime;
    uint64_t _interruptedTime;
    uint64_t _totalInterruptedInterval;
    
#if TARGET_OS_IPHONE
    double _volume;
#endif /* TARGET_OS_IPHONE */
}
@property (nonatomic, retain) fft *fftShared;

@end

@implementation AudioRenderer
@synthesize fftShared;
+ (instancetype)rendererWithBufferTime:(NSUInteger)bufferTime
{
    return [[[self class] alloc] initWithBufferTime:bufferTime];
}

- (instancetype)initWithBufferTime:(NSUInteger)bufferTime
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_mutex, NULL);
        pthread_cond_init(&_cond, NULL);
        fftShared=[fft sharedInstance];

        _bufferTime = bufferTime;
#if TARGET_OS_IPHONE
        _volume = 1.0;
#endif /* TARGET_OS_IPHONE */
        
#if !TARGET_OS_IPHONE
        [self _setupPropertyListenerForDefaultOutputDevice];
#endif /* !TARGET_OS_IPHONE */
    }
    
    return self;
}

- (void)dealloc
{
#if !TARGET_OS_IPHONE
    [self _removePropertyListenerForDefaultOutputDevice];
#endif /* !TARGET_OS_IPHONE */
    
    if (_graph != NULL) {
        [self tearDown];
    }
    
    if (_buffer != NULL) {
        free(_buffer);
    }
    
    pthread_mutex_destroy(&_mutex);
    pthread_cond_destroy(&_cond);
}

#if !TARGET_OS_IPHONE

+ (const AudioObjectPropertyAddress *)_propertyListenerAddressForDefaultOutputDevice
{
    static AudioObjectPropertyAddress address;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        address.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
        address.mScope = kAudioObjectPropertyScopeGlobal;
        address.mElement = kAudioObjectPropertyElementMaster;
    });
    
    return &address;
}

- (void)_handlePropertyListenerForDefaultOutputDevice
{
    if (_outputAudioUnit == NULL) {
        return;
    }
    
    BOOL started = _started;
    [self stop];
    
    pthread_mutex_lock(&_mutex);
    
    [self _tearDownWithoutStop];
    [self setUp];
    
    if (started) {
        AudioOutputUnitStart(_outputAudioUnit);
        _started = YES;
    }
    
    pthread_mutex_unlock(&_mutex);
}

static OSStatus property_listener_default_output_device(AudioObjectID inObjectID,
                                                        UInt32 inNumberAddresses,
                                                        const AudioObjectPropertyAddress inAddresses[],
                                                        void *inClientData)
{
    __unsafe_unretained DOUAudioRenderer *renderer = (__bridge DOUAudioRenderer *)inClientData;
    [renderer _handlePropertyListenerForDefaultOutputDevice];
    return noErr;
}

- (void)_setupPropertyListenerForDefaultOutputDevice
{
    AudioObjectAddPropertyListener(kAudioObjectSystemObject,
                                   [[self class] _propertyListenerAddressForDefaultOutputDevice],
                                   property_listener_default_output_device,
                                   (__bridge void *)self);
}

- (void)_removePropertyListenerForDefaultOutputDevice
{
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject,
                                      [[self class] _propertyListenerAddressForDefaultOutputDevice],
                                      property_listener_default_output_device,
                                      (__bridge void *)self);
}

#endif /* !TARGET_OS_IPHONE */
- (BOOL)setUp
{
    
    if (_graph != NULL)
        return YES;
#if !TARGET_OS_IPHONE
    CFRunLoopRef runLoop = NULL;
    AudioObjectPropertyAddress address = {
        kAudioHardwarePropertyRunLoop,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    status = AudioObjectSetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, sizeof(runLoop), &runLoop);
    if (status != noErr) {
        return NO;
    }
#endif
    AudioStreamBasicDescription outFormat = [AudioDecoder defaultOutputFormat];
    
    AudioComponentDescription outputDescription;
	outputDescription.componentType = kAudioUnitType_Output;
#if TARGET_OS_IPHONE
	outputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
#else
    outputDescription.componentSubType = kAudioUnitSubType_DefaultOutput;
#endif
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDescription.componentFlags = 0;
    outputDescription.componentFlagsMask = 0;
	
	// A description of the mixer unit
	AudioComponentDescription mixerDescription;
	mixerDescription.componentType = kAudioUnitType_Mixer;
	mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	mixerDescription.componentFlags = 0;
	mixerDescription.componentFlagsMask = 0;
	
    
    
    
	OSErr status = NewAUGraph(&_graph);
	if (status != noErr) {
        
        return NO;
    }
    
	status = AUGraphAddNode(_graph, &outputDescription, &_outputNode);
	if (status != noErr) {
        return NO;
    }
	
	
    
	status = AUGraphAddNode(_graph, &mixerDescription, &_mixerNode);
	if (status != noErr) {
        return NO;
    }
	
 	status = AUGraphAddNode(_graph, &mixerDescription, &_mixerNode2);
	if (status != noErr) {
        return NO;
    }
	
    AUGraphOpen(_graph);
	if (status != noErr) {
        return NO;
    }
   	status = AUGraphNodeInfo(_graph, _mixerNode, NULL, &mixerUnit);
	if (status != noErr) {
        return NO;
    }
    UInt32 maxFramesPerSlice = 4096;
    
#warning 64BIT: Inspect use of sizeof
	status = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
 	UInt32 numbuses = 1;
    
#warning 64BIT: Inspect use of sizeof
	status = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    
    
    
    
    
    AURenderCallbackStruct play_rcbs;
    play_rcbs.inputProc = au_render_callback;
    play_rcbs.inputProcRefCon =(__bridge void *)self;
    status = AUGraphSetNodeInputCallback(_graph, _mixerNode, 0, &play_rcbs);
    
    
    
    
    
    status = AUGraphNodeInfo(_graph, _mixerNode2, NULL, &mixerUnit2);
	if (status != noErr) {
        return NO;
    }
#warning 64BIT: Inspect use of sizeof
    status = AudioUnitSetProperty(mixerUnit2, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
    numbuses = 2;
#warning 64BIT: Inspect use of sizeof
    status = AudioUnitSetProperty(mixerUnit2, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    
   /* AURenderCallbackStruct network_rcbs;
    network_rcbs.inputProc = renderMsgCallback;
    network_rcbs.inputProcRefCon = ( void *)(self);
    
    // Set a callback for the specified node's specified input
    
    // equivalent to AudioUnitSetProperty(mMixer, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, i, &rcbs, sizeof(rcbs));
    
    status = AUGraphSetNodeInputCallback(_graph, _mixerNode2, 0, &network_rcbs);
    
    status = AUGraphNodeInfo(_graph, _outputNode, NULL, &outputUnit);
	if (status != noErr) {
        return NO;
    }
    */

    status = AUGraphNodeInfo(_graph, _outputNode, NULL, &outputUnit);
	if (status != noErr) {
        return NO;
    }
    
    
    
    
    
    
	
 	status = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
    
	
    
    
    
    AudioStreamBasicDescription ioASBD;
 	memset (&ioASBD, 0, sizeof (ioASBD));
	ioASBD.mSampleRate = 44100.0;
	ioASBD.mFormatID = kAudioFormatLinearPCM;
	ioASBD.mFormatFlags = kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
	ioASBD.mBytesPerPacket = 2;
	ioASBD.mFramesPerPacket = 1;
	ioASBD.mBytesPerFrame = 2;
	ioASBD.mChannelsPerFrame = 1;
	ioASBD.mBitsPerChannel = 16;
    
    
    
    
    status = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outFormat,
                                   sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &outFormat,
                                   sizeof(outFormat));
    
    
    
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outFormat,
                                   sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  1,
                                  &outFormat,
                                   sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &outFormat,
                                   sizeof(outFormat));
    
    //status = AUGraphConnectNodeInput(_graph, _mixerNode, 0, _mixerNode2, 0);
    if (status != noErr) {
        
        return NO;
    }
    
    status = AUGraphConnectNodeInput(_graph, _mixerNode, 0, _outputNode, 0);
	if (status != noErr) {
        return NO;
    }
    
    CAShow(_graph);
    status = AUGraphInitialize(_graph);
	if (status != noErr) {
		return NO;
	}
    
    
    if (_buffer == NULL) {
        _bufferByteCount = (_bufferTime * outFormat.mSampleRate / 1000) * (outFormat.mChannelsPerFrame * outFormat.mBitsPerChannel / 8);
        _firstValidByteOffset = 0;
        _validByteCount = 0;
        _buffer = (uint8_t *)calloc(1, _bufferByteCount);
    }
    
    return YES;

    
    
    
}

-(void)start {
    
    
    
    if (_graph == NULL)
        
        return;
	
	Boolean isRunning = NO;
	AUGraphIsRunning(_graph, &isRunning);
	if (isRunning)
		return;
    
    
    
    if(!AUGraphStart(_graph))
        return;
    
    
    
}

-(void)stop {
    
    
    
    if (_graph == NULL)
        return;
    pthread_mutex_lock(&_mutex);
    if (_started) {
        pthread_mutex_unlock(&_mutex);
        AUGraphStop(_graph);
        pthread_mutex_lock(&_mutex);
        
        [self _setShouldInterceptTiming:YES];
        _started = NO;
    }
    pthread_mutex_unlock(&_mutex);
    pthread_cond_signal(&_cond);

    
    
}
- (void)renderBytes:(const void *)bytes length:(NSUInteger)length
{
    if (_graph == NULL) {
        return;
    }
    
    while (length > 0) {
        pthread_mutex_lock(&_mutex);
        
        NSUInteger emptyByteCount = _bufferByteCount - _validByteCount;
        while (emptyByteCount == 0) {
            if (!_started) {
                if (_interrupted) {
                    pthread_mutex_unlock(&_mutex);
                    return;
                }
                
                pthread_mutex_unlock(&_mutex);
                [self start];
                pthread_mutex_lock(&_mutex);
                _started = YES;
            }
            
            struct timeval tv;
            struct timespec ts;
            gettimeofday(&tv, NULL);
            ts.tv_sec = tv.tv_sec + 1;
            ts.tv_nsec = 0;
            pthread_cond_timedwait(&_cond, &_mutex, &ts);
            emptyByteCount = _bufferByteCount - _validByteCount;
        }
        
        NSUInteger firstEmptyByteOffset = (_firstValidByteOffset + _validByteCount) % _bufferByteCount;
        NSUInteger bytesToCopy;
        if (firstEmptyByteOffset + emptyByteCount > _bufferByteCount) {
            bytesToCopy = MIN(length, _bufferByteCount - firstEmptyByteOffset);
        }
        else {
            bytesToCopy = MIN(length, emptyByteCount);
        }
        
        memcpy(_buffer + firstEmptyByteOffset, bytes, bytesToCopy);
        
        length -= bytesToCopy;
        bytes = (const uint8_t *)bytes + bytesToCopy;
        _validByteCount += bytesToCopy;
        
        pthread_mutex_unlock(&_mutex);
    }
}

static OSStatus au_render_callback(void *inRefCon,
                                   AudioUnitRenderActionFlags *inActionFlags,
                                   const AudioTimeStamp *inTimeStamp,
                                   UInt32 inBusNumber,
                                   UInt32 inNumberFrames,
                                   AudioBufferList *ioData)
{
    __unsafe_unretained AudioRenderer *renderer = (__bridge AudioRenderer *)inRefCon;
    pthread_mutex_lock(&renderer->_mutex);
    
    NSUInteger totalBytesToCopy = ioData->mBuffers[0].mDataByteSize;
    NSUInteger validByteCount = renderer->_validByteCount;
    
    if (validByteCount < totalBytesToCopy) {
         [renderer _setShouldInterceptTiming:YES];
        
        *inActionFlags = kAudioUnitRenderAction_OutputIsSilence;
        bzero(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize);
        pthread_mutex_unlock(&renderer->_mutex);
        return noErr;
    }
    else {
        [renderer _setShouldInterceptTiming:NO];
    }
    
    uint8_t *bytes = renderer->_buffer + renderer->_firstValidByteOffset;
    uint8_t *outBuffer = (uint8_t *)ioData->mBuffers[0].mData;
    NSUInteger outBufSize = ioData->mBuffers[0].mDataByteSize;
    NSUInteger bytesToCopy = MIN(outBufSize, validByteCount);
    NSUInteger firstFrag = bytesToCopy;
    
    if (renderer->_firstValidByteOffset + bytesToCopy > renderer->_bufferByteCount) {
        firstFrag = renderer->_bufferByteCount - renderer->_firstValidByteOffset;
    }
    
    if (firstFrag < bytesToCopy) {
        memcpy(outBuffer, bytes, firstFrag);
        memcpy(outBuffer + firstFrag, renderer->_buffer, bytesToCopy - firstFrag);
    }
    else {
        memcpy(outBuffer, bytes, bytesToCopy);
    }
    if(renderer->fftShared==nil)
        renderer->fftShared=[fft sharedInstance];
    
    [renderer->fftShared doFFTReal:bytesToCopy / sizeof(int16_t) :(int16_t *)outBuffer ] ;
   #if TARGET_OS_IPHONE
    if (renderer->_volume != 1.0) {
        int16_t *samples = (int16_t *)outBuffer;
        size_t samplesCount = bytesToCopy / sizeof(int16_t);
        
        float floatSamples[samplesCount];
        vDSP_vflt16(samples, 1, floatSamples, 1, samplesCount);
        
        float volume = renderer->_volume;
        vDSP_vsmul(floatSamples, 1, &volume, floatSamples, 1, samplesCount);
        
        vDSP_vfix16(floatSamples, 1, samples, 1, samplesCount);
    }
#endif /* TARGET_OS_IPHONE */
    
    if (bytesToCopy < outBufSize) {
        bzero(outBuffer + bytesToCopy, outBufSize - bytesToCopy);
    }
    
    renderer->_validByteCount -= bytesToCopy;
    renderer->_firstValidByteOffset = (renderer->_firstValidByteOffset + bytesToCopy) % renderer->_bufferByteCount;
    
    pthread_mutex_unlock(&renderer->_mutex);
    pthread_cond_signal(&renderer->_cond);
    
    return noErr;
}
+ (double)_absoluteTimeConversion
{
    static double conversion;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        conversion = 1.0e-9 * info.numer / info.denom;
    });
    
    return conversion;
}

- (void)_resetTiming
{
    _startedTime = 0;
    _interruptedTime = 0;
    _totalInterruptedInterval = 0;
}

- (NSUInteger)currentTime
{
    if (_startedTime == 0) {
        return 0;
    }
    
    double base = [[self class] _absoluteTimeConversion] * 1000.0;
    
    uint64_t interval;
    if (_interruptedTime == 0) {
        interval = mach_absolute_time() - _startedTime - _totalInterruptedInterval;
    }
    else {
        interval = _interruptedTime - _startedTime - _totalInterruptedInterval;
    }
    
    return base * interval;
}

- (void)setInterrupted:(BOOL)interrupted
{
    pthread_mutex_lock(&_mutex);
    _interrupted = interrupted;
    pthread_mutex_unlock(&_mutex);
}
- (void)_setShouldInterceptTiming:(BOOL)shouldInterceptTiming
{
    if (_startedTime == 0) {
        _startedTime = mach_absolute_time();
    }
    
    if ((_interruptedTime != 0) == shouldInterceptTiming) {
        return;
    }
    
    if (shouldInterceptTiming) {
        _interruptedTime = mach_absolute_time();
    }
    else {
        _totalInterruptedInterval += mach_absolute_time() - _interruptedTime;
        _interruptedTime = 0;
    }
}
- (void)flush
{
    [self flushShouldResetTiming:YES];
}

- (void)flushShouldResetTiming:(BOOL)shouldResetTiming
{
     
    if (_graph == NULL) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    
    _firstValidByteOffset = 0;
    _validByteCount = 0;
    if (shouldResetTiming) {
        [self _resetTiming];
    }
    
    pthread_mutex_unlock(&_mutex);
    pthread_cond_signal(&_cond);
}
- (void)tearDown
{
    if (_graph == NULL) {
        return;
    }
    
    [self stop];
    [self _tearDownWithoutStop];
}

- (void)_tearDownWithoutStop
{
    AUGraphUninitialize(_graph);
	DisposeAUGraph(_graph);
	
	_graph = NULL;
	outputUnit = NULL;
	mixerUnit = NULL;
    mixerUnit2=NULL;
    
}
@end
