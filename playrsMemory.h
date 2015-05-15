//
//  playrsMemory.h
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "playrsTrack.h"
#import "DownloadManager.h" 
#import "Playlist.h"

@interface playrsMemory : NSObject
+(playrsMemory *)sharedInstance;
 -(void)addTrackWithName:(NSString *)name;
-(NSArray *)checkForTracksExist:(NSArray *)p;
-(NSArray *)songsGroupedByArtist;
-(NSArray *)songsGroupedByTypeDownloads;
-(NSArray *)songsFromNSURLstrArray:(NSArray *)p;
-(playrsTrack *)playrTrackFromURLstr:(NSString *)s;
@property (nonatomic, strong) NSMutableArray *playrsTrack;
-(void)deleteTrack:(playrsTrack *)p;

 @end
