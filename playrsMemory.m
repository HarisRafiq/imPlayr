//
//  playrsMemory.m
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "playrsMemory.h"
#import "FileUtilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "imConstants.h"
@implementation playrsMemory
static playrsMemory *sharedInstance;
+ (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		initialized = YES;
		sharedInstance = [[playrsMemory alloc] init];
	}
}
+ (playrsMemory *)sharedInstance
{
	return sharedInstance;
}

- (id)init {
    self = [super init];
	if (self)
	{  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrackAddedNotification: ) name:NOTIFICATION_TRACK_ADDED_MEMORY object:nil];
              [self musicLibraryTracks];
        
    }
    return self;
    
}

- (void)musicLibraryTracks
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playrsTrack = [NSMutableArray array];
        
        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
            if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
                continue;
            }
            
            playrsTrack *track = [[playrsTrack alloc] init];
            NSString *s=[item valueForProperty:MPMediaItemPropertyArtist];
            if(s==nil)
                s=@"Unknown Artist";
            [track setArtist:s];
            [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
            [track setAudioFileURLstr:[[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString]];
            [track setAudioFileURL: [item valueForProperty:MPMediaItemPropertyAssetURL]  ];

            NSString *a=[item valueForProperty:MPMediaItemPropertyAlbumTitle];
            
            if([a length]<=0)
                a=@"Unknown Album";
            [track setAlbum:a];
            [track setDuration:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
            
            
            
            
            [_playrsTrack addObject:track];
            
        }
        NSString *filePath=[FileUtilities appFilesDirectory];
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
        
        for (int Count = 0; Count < (int)[directoryContent count]; Count++)
        {
            
            NSString *fileName=[filePath stringByAppendingPathComponent:[directoryContent objectAtIndex:Count]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                playrsTrack *track = [[playrsTrack alloc] initItemWithFilePath:fileName];
                
                    if(track!=nil)
                    
                    [_playrsTrack addObject:track];
                
             }
             
        }
        
        
                
                  });
 }

-(NSArray *)songsGroupedByTypeDownloads{
    static NSArray *tracks = nil;
 
    NSMutableArray *sortedArray=[[NSMutableArray alloc] init];
    for (playrsTrack *item in _playrsTrack) {
        if (![[[item audioFileURL] scheme] isEqualToString:@"ipod-library"])
        [sortedArray addObject:item];
    }
    
    
    tracks = [sortedArray copy];
    [sortedArray removeAllObjects];
    sortedArray=nil;
    return tracks;
    
}

-(NSArray *)songsGroupedByArtist{
    static NSArray *tracks = nil;
//if ([[url scheme] isEqualToString:@"ipod-library"])
    NSMutableSet *artists =[[NSMutableSet alloc] init];

    for (playrsTrack *item in _playrsTrack) {
        [artists addObject:[item artist]];
        }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sorts = [artists sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    // artists=[NSMutableSet setWithArray:sorts];
    NSMutableArray *sortedArray=[[NSMutableArray alloc] init];
    for(NSString *t in sorts)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"artist ==[c] %@",t];
        NSArray *filtered  = [_playrsTrack filteredArrayUsingPredicate:predicate];
        
        
        
        [sortedArray addObject:filtered];
    }
    
    
    
    tracks = [sortedArray copy];
    [sortedArray removeAllObjects];
    sortedArray=nil;
    return tracks;

}

-(NSArray *)songsFromNSURLstrArray:(NSArray *)p{
    static NSArray *tracks = nil;
    
    
  
    NSMutableArray *sortedArray=[[NSMutableArray alloc] init];
    for(NSString *t in p)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"audioFileURLstr ==[c] %@",t];
        NSArray *filtered  = [_playrsTrack filteredArrayUsingPredicate:predicate];
        
        if([filtered count]>0)
        for(playrsTrack *p in filtered)
        [sortedArray addObject:p];
    }
    
    
    
    tracks = [sortedArray copy];
    [sortedArray removeAllObjects];
    sortedArray=nil;
    return tracks;
    
}
-(NSArray *)checkForTracksExist:(NSArray *)p{


    static NSArray *tracks = nil;
    
    
    
    NSMutableArray *sortedArray=[[NSMutableArray alloc] init];
    for(NSString *t in p)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"audioFileURLstr ==[c] %@",t];
        NSArray *filtered  = [_playrsTrack filteredArrayUsingPredicate:predicate];
        
        if([filtered count]>0)
            for(playrsTrack *p in filtered){
                NSString *i=[p audioFileURLstr];
                
                [sortedArray addObject:i];
            }
    }
    
    
    
    tracks = [sortedArray copy];
    [sortedArray removeAllObjects];
    sortedArray=nil;
    return tracks;


}


-(playrsTrack *)playrTrackFromURLstr:(NSString *)s{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"audioFileURLstr ==[c] %@",s];
    NSArray *filtered  = [_playrsTrack filteredArrayUsingPredicate:predicate];
    
    if([filtered count]>0)
        return (playrsTrack *)[filtered objectAtIndex:0]  ;

    else return nil;
}
-(void)deleteTrack:(playrsTrack *)p{
 
   
    
       NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[p audioFileURLstr]]){
        [fileManager removeItemAtPath:[p audioFileURLstr] error:nil];
 
            [_playrsTrack removeObject:p];
           
  
        
    }

    
    
    
}
-(void)addTrackWithName:(NSString *)name{
    
    
    playrsTrack *track = [[playrsTrack alloc] initItemWithFilePath:name];

    if(track){
     [_playrsTrack addObject:track];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DB_FILE_LIST_UPDATED object:nil];
    
    }
    track=nil;
    
}
- (void) newTrackAddedNotification:(NSNotification *)notification{
    NSString *theString = [[notification object] copy];
    
    [self addTrackWithName:theString];
    
}

@end
