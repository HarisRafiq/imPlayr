//
//  imStreamer.m
//  imPlayr2
//
//  Created by YAZ on 6/11/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "imStreamer.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"
#if TARGET_IPHONE_SIMULATOR
NSString *const WifiInterfaceName = @"en1";
#else
NSString *const WifiInterfaceName = @"en0";
#endif


@implementation imStreamer
@synthesize httpServer,connection,delegate;

static imStreamer *sharedInstance;
+ (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		initialized = YES;
		sharedInstance = [[imStreamer alloc] init];
        
	}
}
+(imStreamer *)sharedInstance
{
	return sharedInstance;
}


- (void)setAudioFileURL:(NSURL *)url
{
    _shouldPlay=NO;

        _audioURL=url;
        [self _createAssetLoader];
        [_assetLoader start];

}


- (void)_assetLoaderDidComplete
{
    if ([_assetLoader isFailed]) {
        _failed=YES;
        NSLog(@"FAIled to export");
        return;
    }
    _isPlaying=NO;
     _shouldPlay=YES;
    _currentTrackPath=[_assetLoader cachedPath];
    _loaderCompleted = YES;
    NSLog(_currentTrackPath);

 }

- (void)_createAssetLoader
{
    if(_assetLoader!=nil){
        @synchronized(_assetLoader) {
            [_assetLoader setCompletedBlock:NULL];
            [_assetLoader cancel];
            _assetLoader=nil;
        }
    

    }
    _loaderCompleted = NO;
     _failed=NO;

    _assetLoader = [TrackExporter loaderWithURL:_audioURL];
    
    __weak typeof(self) weakSelf = self;
    [_assetLoader setCompletedBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _assetLoaderDidComplete];
    }];
}

#pragma mark HTTP
#pragma  mark HTTP SERVER

-(NSString *)serverAddress{
    
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSInteger success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([@(temp_addr->ifa_name) isEqualToString:WifiInterfaceName])
                    address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
    
    
    
}
-(void)startHTTPServer{
    
    if(!isHTTPRunning){
        if(httpServer)
        {
             httpServer=nil;
            
        }
        
        httpServer =  [[HTTPServer alloc] init]  ;
        [httpServer setType:@"_http._tcp."];
        [httpServer setPort:8080];
        [httpServer setName:@"AIIRX"];
        NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] stringByDeletingLastPathComponent];
        [httpServer setDocumentRoot: docRoot
         ];
        [httpServer setConnectionClass:[MYHTTPConnection class]];
        [httpServer setController:self];
        if([httpServer start:nil]&&[self serverAddress].length>0){
            
            isHTTPRunning=YES;
            _changed=NO;
            _shouldPlay=YES;
            _isPlaying=NO;
            _currentIP=[NSString stringWithFormat:@"%@:%i",[self serverAddress],[httpServer listeningPort]];
            [self.delegate httpServerStartedOn:_currentIP];
            AppDelegate *app=(AppDelegate *) [[UIApplication sharedApplication] delegate];
            [app showSuccessMessage];
        }
        else {
            [httpServer stop];
             httpServer=nil;
            isHTTPRunning=NO;
            _shouldPlay=NO;
            _isPlaying=NO;
            _currentIP=nil;
            [self.delegate httpServerFailedToStart];
            AppDelegate *app=(AppDelegate *) [[UIApplication sharedApplication] delegate];
            [app showErrorConnectingMessage];
            
        }
    }
    else
    {
        [httpServer stop];
         httpServer=nil;
        isHTTPRunning=NO;
        _changed=NO;
        _shouldPlay=NO;
        _isPlaying=NO;
        _currentIP=nil;
        [self.delegate httpServerStopped];
        AppDelegate *app=(AppDelegate *) [[UIApplication sharedApplication] delegate];
        [app showDisconnectedMessage];

    }
}
-(void)restartServer{
    
    [httpServer stop];
    [httpServer start:nil] ;
   }
-(BOOL)isHTTPRunning{
    return isHTTPRunning;
    
    
}
-(void)setChanged{

    _changed=YES;

}
-(NSString *)getCurrentSong{
if(_shouldPlay)
    return _currentTrackPath;
else return @"PAUSED";
}
-(void)togglePlayPause{

if(_shouldPlay)
{
    _shouldPlay=NO;

}
else {

    _shouldPlay=YES;

}


}
@end
