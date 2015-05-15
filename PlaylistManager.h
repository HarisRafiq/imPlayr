//
//  PlaylistManager.h
//  IMP
//
//  Created by YAZ on 3/19/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import "Playlist.h"
@interface PlaylistManager : NSObject
+(PlaylistManager*)getInstance;
@property (nonatomic, strong) NSMutableArray *playlists;

 -(Playlist *)addPlaylistWithName:(NSString *)name;
 -(void)loadAllPlaylist;
-(Playlist *)getPlaylistAtIndex:(NSInteger)i;

-(void)deletePlaylistAtIndex:(NSInteger)i;
-(NSArray *)allPlaylists;
@end
