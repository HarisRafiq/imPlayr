//
//  imStreamer.h
//  imPlayr2
//
//  Created by YAZ on 6/11/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackExporter.h"
#import "HTTPServer.h"
#import "MYHTTPConnection.h"
@protocol imStreamerDelegate;
@protocol imStreamerDelegate <NSObject>
-(void)httpServerStartedOn:(NSString *)s;
-(void)httpServerFailedToStart;
-(void)httpServerStopped;


@end

@interface imStreamer : NSObject{
    BOOL isHTTPRunning;

    TrackExporter *_assetLoader;
    BOOL _loaderCompleted;

}
-(void)setChanged;
-(void)sendPlayPauseAction;
-(NSString *)serverAddress;
-(void)startHTTPServer;
-(BOOL) isHTTPRunning;
+(imStreamer *)sharedInstance;
- (void)setAudioFileURL:(NSURL *)url;
-(NSString *)getCurrentSong;
@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic, readwrite) BOOL shouldPlay;

-(void)togglePlayPause;
@property (nonatomic, strong) id<imStreamerDelegate> delegate;
@property (nonatomic, retain) MYHTTPConnection *connection;
@property (nonatomic, retain) HTTPServer *httpServer;
@property (nonatomic, readonly, getter = isFailed) BOOL failed;
@property (nonatomic, strong) NSString *currentTrackPath;
@property (nonatomic, readwrite, getter = isChanged) BOOL changed;
@property (nonatomic, strong) NSString *currentIP;
-(void)restartServer;

@property (nonatomic, readonly) NSURL *audioURL;
@end
