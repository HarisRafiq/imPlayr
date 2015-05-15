//
//  AudioManager.m
//  imPlayr
//
//  Created by YAZ on 3/26/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "AudioManager.h"
#import "Utitlities.h"
#import "playrsTrack.h"
 #import "PlaylistManager.h"
#import "Playlist.h"
#import "FileUtilities.h"
#import "Shuffle.h"
#import "UIImage+Thumbnail.h"
#import  "LEColorPicker.h"
#import "UIColor+imPlayr.h"
#import  <AVFoundation/AVFoundation.h>
#import "playrsMemory.h"
#import "imageManager.h"
#import "imStreamer.h"
#import "NSMutableArray-MoveExtentions.h"
 
static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;
@implementation AudioManager
static AudioManager *sharedInstance=nil;

+ (AudioManager *)sharedInstance
{    static dispatch_once_t onceToken5;

    dispatch_once(&onceToken5, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[AudioManager alloc] init];
        }
        
        
    });
    return sharedInstance;}
 


- (id)init {
    self = [super init];
	if (self)
	{    [[NSNotificationCenter defaultCenter] addObserver: self
                                                  selector: @selector(checkForExitstingTracksAfterFileUpdate)
                                                      name:NOTIFICATION_DB_FILE_LIST_UPDATED
                                                    object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredForgorund:)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
        if ([self FileExists]) {
    
            _trackQueue=[[NSMutableArray alloc] initWithContentsOfFile:[self FilePath]] ;

        }
else
        _trackQueue=[[NSMutableArray alloc] init];
        isShuffleOn=NO;
         [self checkForExitstingTracksAfterFileUpdate];
        [self setBgColor:[UIColor colorWithRed:0.080039 green:0.080039 blue:0.080039 alpha:1.0]];
        [self setPrimaryColor:[UIColor colorWithRed:0.900039 green:0.900039 blue:0.900039 alpha:1.0]];
        [self setSecondaryColor:[UIColor colorWithRed:0.980039 green:0.980039 blue:0.980039 alpha:1.0]];
        [self setBgColoLight:[[self bgColor] lighterColor ]];
       
               [self setBgColorDark:[[self bgColor] darkerColor ]];
        _nowPlayingImage= [UIImage imageNamed:@"emptyQueue.png"]  ;
        _currentTrackIndex = 0;
        isFirstTime=YES;
             }
    return self;
    
}
-(void)handleEnteredBackground:(id)s{
    isBackground=YES;
}
-(void)handleEnteredForgorund:(id)s{
    isBackground=NO;
    
    [self setColorScheme];

}
- (void)_actionPlayPause:(id)sender
{
    
    
    if(![[imStreamer sharedInstance] isHTTPRunning]){
      

    if ([_streamer status] == AudioStreamerPaused ||
        [_streamer status] == AudioStreamerIdle) {
        [_streamer play];
    }
    else {
        [_streamer pause];
    }
    }
    
    else {
    
        [[imStreamer sharedInstance] togglePlayPause];
    
    }
}

- (void)_cancelStreamer
{
    if (_streamer != nil) {

         [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer pause];

         _streamer = nil;
    }
}
- (void)_resetStreamer
{
    
     [self _cancelStreamer];

    playrsTrack *track=nil;
    if(isShuffleOn&&[shuffleList count]>0)
    {
         track = [[playrsMemory sharedInstance] playrTrackFromURLstr:[shuffleList objectAtIndex:_currentTrackIndex]];
        
        
    }
    
    else
    {
        if([_trackQueue count]>0)
    track = [[playrsMemory sharedInstance] playrTrackFromURLstr:[_trackQueue objectAtIndex:_currentTrackIndex]];;
 
    }
    if(track!=nil){
        
        if([[imStreamer sharedInstance] isHTTPRunning])
        {
        
            [[imStreamer sharedInstance] setAudioFileURL:[track audioFileURL] ];
 
             [self setColorScheme];
            return;
        
        }
        
        _streamer = [AudioStreamer streamerWithAudioFileURL:[track audioFileURL] ];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
 
        [self setColorScheme];

    [_streamer play];
    [self _setupHintForStreamer];
   
         
    }
   }
- (void)streamerWithURL:(NSURL *)url{



 
    [self _cancelStreamer];
    
    
 
    _streamer = [AudioStreamer streamerWithAudioFileURL:url];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    
    
    [_streamer play];
     
}


- (void)_updateStatus
{                                     if(!isBackground){

    if([_streamer status]==AudioStreamerError ){
        dispatch_async(dispatch_get_main_queue(), ^{

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_PLAYING_ERROR object:nil];
        });
    }
    if([_streamer status]==AudioStreamerBuffering ){
        dispatch_async(dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_BUFFERING object:nil];
        });
        }
    
    if([_streamer status]==AudioStreamerPaused ){
        NSLog(@"paused");
        dispatch_async(dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_PAUSED object:nil];
        });
    }
    
    if([_streamer status]==AudioStreamerIdle ){
        dispatch_async(dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_IDLE object:nil];
    
        });
        }
    if([_streamer status]==AudioStreamerFinished ){
        dispatch_async(dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_FINISHED_PLAYING object:nil];
            
        });
        [self _actionNext];

    }
    if([_streamer status]==AudioStreamerPlaying ){
        dispatch_async(dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_STARTED_PLAYING object:nil];
        });
            NSLog(@"statusPlaying");
    }
    
}
    else
        if([_streamer status]==AudioStreamerFinished ){
        
            [self _actionNext];

        }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)_actionNext
{
    if(!isRepeatOn){
    if(isShuffleOn){
        if (++_currentTrackIndex >= [shuffleList count] ) {
            _currentTrackIndex = 0;
 
        }

    
    }
    else if(++_currentTrackIndex >= [_trackQueue count] ) {
        _currentTrackIndex = 0;
     
    }
    }
           [self _resetStreamer];

}
- (void)_actionPrev {
    
    int prevTrack=(int)_currentTrackIndex-1;
 
    if (prevTrack < 0 ) {
        _currentTrackIndex=0;
    }
       else {
        --_currentTrackIndex;

        
    }
    [self _resetStreamer];

    
}
- (void)_actionStop:(id)sender
{
    [_streamer stop];
}

- (void)_setupHintForStreamer
{
     NSUInteger nextIndex = _currentTrackIndex + 1;
    
    NSUInteger trackCount= [_trackQueue count];
    if (nextIndex >= trackCount) {
        nextIndex = 0;
    
    
        
    }
    playrsTrack *track=nil;
    

    
    if(isShuffleOn)
    {
        track = [[playrsMemory sharedInstance] playrTrackFromURLstr:[shuffleList objectAtIndex:nextIndex]];

    }
else
    track = [[playrsMemory sharedInstance] playrTrackFromURLstr:[_trackQueue objectAtIndex:nextIndex]];
    
    
    
    if(track!=nil)
    [AudioStreamer setHintWithAudioFile:[track audioFileURL]];
 
}
-(AudioStreamer *)currentStreamer{

    return _streamer;

}

-(void)setCurrentTrackIndex:(NSUInteger)i{
    _currentTrackIndex=i;


}

-(playrsTrack *)currentTrack{
    if(isShuffleOn&&[shuffleList count]>0){
    playrsTrack *p=[[playrsMemory sharedInstance] playrTrackFromURLstr:[shuffleList objectAtIndex:_currentTrackIndex]];
    
    return p;
    }
else if(!isShuffleOn &&[_trackQueue count]>0)
{
    playrsTrack *p=[[playrsMemory sharedInstance] playrTrackFromURLstr:[_trackQueue objectAtIndex:_currentTrackIndex]];
    
    return p;
}
    
    return nil;
}

- (void)enableScrubbingFromSlider:(UISlider *)slider
{
 	[slider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:self action:@selector(endSeek) forControlEvents:UIControlEventTouchUpInside| UIControlEventTouchUpOutside |UIControlEventTouchCancel];

    
    
	   
}
- (void)beginSeek
{if(_streamer){
    if([_streamer status]==AudioStreamerPlaying){

    [_streamer removeObserver:self forKeyPath:@"status"];

    
     [_streamer pause];
    }
}
}

- (void)endSeek
{if(_streamer)
{
   

          [_streamer play];
  
    
}
}

-(NSTimeInterval)currentTime{

    return [_streamer currentTime];

}

-(NSTimeInterval)duration{
    
    return [_streamer duration];
    
}
- (void)disableScrubbingFromSlider:(UISlider *)slider
{
 	[slider removeTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
	[slider removeTarget:self action:@selector(endSeek) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |UIControlEventTouchCancel];
    

	 	 }
- (void)_actionSliderProgress:(id)sender

{
    
    
    
    if(_streamer){
         if([_streamer status]==AudioStreamerPlaying){
             [_streamer pause];
         }
        
    UISlider *playbackSlider = (UISlider*)sender;
    [_streamer setCurrentTime:[_streamer duration] * [playbackSlider value]];
     
      //  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEEKBAR_UPDATED object:nil userInfo:nil];
     
    }
    }
-(NSUInteger )currentTrackIndex
{

    return _currentTrackIndex;
}

- (void) addTrackToQueue:(playrsTrack *)newTrack toBeginning:(BOOL)beginning
{
 	if (beginning) {
		[_trackQueue insertObject:[newTrack audioFileURLstr] atIndex:0];
        _currentTrackIndex=0;
        if(isShuffleOn)
            [self shuffleList];
        [self _resetStreamer]	;

       } else {
           
		[_trackQueue addObject:[newTrack audioFileURLstr]];
           if(isShuffleOn)
               [self shuffleList];
 	}
	
        
    [self save];

	
}
- (void) moveTrackFromIndex:(NSUInteger)fromIndex toIndexPath:(NSUInteger)toIndex {
 	
	[_trackQueue moveObjectFromIndex:fromIndex
                             toIndex:toIndex];
	
	if (_currentTrackIndex == fromIndex) {
		_currentTrackIndex = toIndex;
	} else if (_currentTrackIndex == toIndex) {
		_currentTrackIndex = fromIndex;
	}
	
    [self save];

}
-(BOOL)saveQueueAsPlaylist:(NSString *)playlistName
{
    Playlist *playlist=[[PlaylistManager getInstance] addPlaylistWithName:playlistName];
    if(playlist==nil)
        return NO;
    
    
    [playlist addTracksFromArray:_trackQueue ];
    
    
    return YES;
    
}
 - (BOOL) removeSongFromQueue:(NSUInteger)index{
	if (index >= [_trackQueue count]) {
		return NO;
	}
	
 	
	[_trackQueue removeObjectAtIndex:index];
	 
	     if(isShuffleOn)
        [self shuffleList];
      return YES;
}

- (void) clearQueue
{
    if(isShuffleOn){
    [shuffleList removeAllObjects];
    
        [self toggleShuffle];
    }
	[_trackQueue removeAllObjects];
	[self _actionStop:nil];
	_currentTrackIndex = 0;
    [self save];

    
}


- (NSString*)FilePath {
 	NSString *documentsDirectory = [FileUtilities appNowPlayingDirectory];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"NowPlaying.plist"]];
	return filePath;
}

- (BOOL)FileExists {
	NSString *filePath = [self FilePath];
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
- (BOOL)save {
    NSString *file=[self FilePath];
     return  [_trackQueue writeToFile:file atomically:YES];
    
}
-(void)shuffleList{
    
    if(shuffleList!=nil)
    {
        [shuffleList removeAllObjects];
        shuffleList=nil;
        
    }
 
    shuffleList=[[NSMutableArray alloc] init];
    NSArray *newList = [Shuffle shuffleList:[NSArray arrayWithArray: _trackQueue  ]];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newList count])];
    
    [shuffleList insertObjects:newList atIndexes:indexSet];
    
    newList=nil;
    indexSet=nil;
}

-(void)shuffle{
    [self shuffleList];
     _currentTrackIndex=0;
    [self _resetStreamer];
    
}

-(void)toggleShuffle{
    
    isShuffleOn=!isShuffleOn;
    if(isShuffleOn)
        [self shuffle];
    dispatch_async(dispatch_get_main_queue(), ^{

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHUFFLE_TOGGLED object:nil userInfo:nil];
    });
}

-(BOOL)isShuffleOn{
    
    return isShuffleOn
    ;
}
-(BOOL)isRepeatOn{
    
    
    return isRepeatOn;
}
-(void)toggleRepeat{
    isRepeatOn=!isRepeatOn;
    dispatch_async(dispatch_get_main_queue(), ^{

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPEAT_TOGGLED object:nil userInfo:nil];
    });
    
    
}

-(NSArray *)playerQueue{

    NSArray *array=[[playrsMemory sharedInstance] songsFromNSURLstrArray:[_trackQueue copy]];
    return array;


}
-(void)setPlaylist:(Playlist *)p{
    _currentPlaylist=p;
if(_trackQueue!=nil)
{
    [_trackQueue removeAllObjects];
    
     [_trackQueue addObjectsFromArray:[[_currentPlaylist tracks] copy]];
    [self checkForExitstingTracksAfterFileUpdate];
}
  
}

-(void)changeTrackDueToDeletion{
if([_trackQueue count]==1)
    _currentTrackIndex=-1;
    
 if([_trackQueue count]>0)
     [self _resetStreamer];


}
-(void)setColorScheme{
  
        if([self currentTrack
            ]!=nil){
            NSArray *a=[[imageManager getInstance] loadImagesForTrack:[[self currentTrack
                                                                        ] audioFileURLstr]];
            if([a count]>0)
            {    NSString *key = [a objectAtIndex:0];
                UIImage *                                         finalImage=[UIImage imageNamed:@"emptyQueue.png"];

                finalImage=[imageManager imageForURL:key ];
                if(_nowPlayingImage)
                    _nowPlayingImage=nil;
                _nowPlayingImage=[finalImage copy];
                
                [Utitlities setNowPlayingInfo:0];

                if(!isBackground){
                    LEColorScheme * _artworkColorScheme=[[LEColorScheme alloc] init];
                    LEColorPicker * picker = [LEColorPicker new];
                    _artworkColorScheme = [picker colorSchemeFromImage:[_nowPlayingImage makeThumbnailWithSize:CGSizeMake(50, 50) withCornerRadius:25]];
                    
                    [self setBgColor:_artworkColorScheme.backgroundColor];
                    [self setPrimaryColor:_artworkColorScheme.primaryTextColor];
                    [self setSecondaryColor:_artworkColorScheme.secondaryTextColor];
                    [self setBgColoLight: [_artworkColorScheme.backgroundColor lighterColor]];
                    [self setBgColorDark:  [_artworkColorScheme.backgroundColor darkerColor]  ];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COLORS_CHANGED object:nil];
                    });
                    
                }
            
            }
                else {
            AVAsset *asset = [AVURLAsset URLAssetWithURL:[[self currentTrack
                                                          ] audioFileURL] options:nil];
            [asset loadValuesAsynchronouslyForKeys:@[@"commonMetadata"]
                                 completionHandler:^{
                                     UIImage *                                         finalImage=[UIImage imageNamed:@"emptyQueue.png"];
                                      

 
                                     NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                                                        withKey:AVMetadataCommonKeyArtwork
                                                                                       keySpace:AVMetadataKeySpaceCommon];
                                     for (AVMetadataItem *item in artworks)
                                     {
                                         if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                                         {
                                             NSDictionary *dict = [item.value copyWithZone:nil];
                                             
                                              finalImage = [UIImage imageWithData:[dict objectForKey:@"data"]];
                                         }
                                         if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                                         {
                                              finalImage= [UIImage imageWithData:[item.value copyWithZone:nil]];
                                         }
                                         
                                     }
                                     if(_nowPlayingImage)
                                         _nowPlayingImage=nil;
                                     _nowPlayingImage=[finalImage copy];
                                     [Utitlities setNowPlayingInfo:0];

                                     if(!isBackground){
                                         LEColorScheme * _artworkColorScheme=[[LEColorScheme alloc] init];
                                         LEColorPicker * picker = [LEColorPicker new];
                                         _artworkColorScheme = [picker colorSchemeFromImage:[_nowPlayingImage makeThumbnailWithSize:CGSizeMake(50, 50) withCornerRadius:25]];
                                         
                                         [self setBgColor:_artworkColorScheme.backgroundColor];
                                         [self setPrimaryColor:_artworkColorScheme.primaryTextColor];
                                         [self setSecondaryColor:_artworkColorScheme.secondaryTextColor];
                                         [self setBgColoLight: [_artworkColorScheme.backgroundColor lighterColor]];
                                         [self setBgColorDark:  [_artworkColorScheme.backgroundColor darkerColor]  ];
                                         
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COLORS_CHANGED object:nil];
                                         });
                                         
                                     }
                                     
                                     
                                     
                                     
                                     
                                                                   }];
                    
                    
                    
               }
        
     
    
    
           

        }



}



-(void)checkForExitstingTracksAfterFileUpdate{

 NSArray *array=[[playrsMemory sharedInstance] checkForTracksExist:[_trackQueue copy]];
    if(array!=nil){
    [_trackQueue removeAllObjects];
    [_trackQueue addObjectsFromArray:array];
    }
}
-(BOOL)isRemotePlaying{


    return isRemotePlaying;
}

-(void)setRemotePlaying:(BOOL)s{

    isRemotePlaying=s;

}
@end
