//
//  Playlist.h
//  IMP
//
//  Created by YAZ on 3/18/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "playrsTrack.h"
 #define NOW_PLAYING_QUEUE @"impnowplaying"
#define NOW_PLAYING_QUEUE @"impnowplaying"

@interface Playlist : NSObject <NSCoding> {
    
 
  
}
-(void)clear;
- (NSString *)FilePath;
-(void)removeTracksAtIndex:(NSInteger)i;
-(NSString *)trackURLStringAtIndex:(NSInteger)i;
-(void)addTrackWithURLString:(NSString *)track;
- (void) addTrackWithURLString:(NSString *)track atIndex:(NSUInteger)index
;
- (id)initWithFileName:(NSString *)name;
- (BOOL)save;
- (void) moveTrackFromIndex:(NSUInteger)initIndex toIndex:(NSUInteger)endIndex;
-(void)addTracksFromArray:(NSArray *)trackArray;
-(void)changeTitleTo:(NSString *)newTitle;
  @property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) NSString *fileName;
 
-(NSArray *)tracksFromPlaylist;

 
 @end
