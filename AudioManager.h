//
//  AudioManager.h
//  imPlayr
//
//  Created by YAZ on 3/26/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "playrsTrack.h"
#import "Playlist.h"
#import "imConstants.h"

 @interface AudioManager : NSObject {


    BOOL isShuffleOn;
    BOOL isRepeatOn;
    NSUInteger _currentTrackIndex;
      BOOL isBackground;
     NSMutableArray *shuffleList;
     BOOL isRemotePlaying;
     BOOL isFirstTime;

 }
-(void)setRemotePlaying:(BOOL)s;
-(BOOL)isRemotePlaying;

-(BOOL)isShuffleOn;
-(void)toggleShuffle;
-(void)shuffle;
-(BOOL)isRepeatOn;
-(void)toggleRepeat;
-(NSUInteger )currentTrackIndex;
-(void)setCurrentTrackIndex:(NSUInteger)i;
-(void)setCurrentArtistIndex:(NSUInteger)i;
@property (nonatomic, retain) UIImage *nowPlayingImage;
@property (nonatomic, strong) UIColor *bgColorDark;
@property (nonatomic, strong) UIColor *bgColoLight;
-(void)setPlaylist:(Playlist *)p;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) Playlist *currentPlaylist;

@property (nonatomic, strong) AudioStreamer *streamer;
 @property (nonatomic, strong) NSMutableArray *trackQueue;
+(AudioManager *)sharedInstance;
-(AudioStreamer *)currentStreamer;
- (void)_resetStreamer;
-(playrsTrack *)currentTrack;
- (void)_actionNext;
- (void)_actionPrev;
- (void)_actionPlayPause:(id)sender;
- (void)enableScrubbingFromSlider:(UISlider *)slider;
- (void)disableScrubbingFromSlider:(UISlider *)slider;
-(NSTimeInterval)currentTime;
-(NSTimeInterval)duration;
- (void)streamerWithURL:(NSURL *)url;
- (void) addTrackToQueue:(playrsTrack *)newTrack toBeginning:(BOOL)beginning;
- (BOOL) saveQueueAsPlaylist:(NSString *)playlistName;
- (void) clearQueue;
- (BOOL) removeSongFromQueue:(NSUInteger)index;
- (void) moveTrackFromIndex:(NSUInteger)fromIndex toIndexPath:(NSUInteger)toIndex;
-(NSArray *)playerQueue;
-(void)changeTrackDueToDeletion;
- (BOOL)save;
-(void)setColorScheme;
@end
