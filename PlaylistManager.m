//
//  PlaylistManager.m
//  IMP
//
//  Created by YAZ on 3/19/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "PlaylistManager.h"
#import "Playlist.h"
#import "FileUtilities.h"
 
@implementation PlaylistManager
-(id)init{
    
    self = [super init];
    if (self) {
        self.playlists = [[NSMutableArray alloc] init];
        [self loadAllPlaylist];
     }
    return self;
    
    
}

+(PlaylistManager*)getInstance
{
    static PlaylistManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[PlaylistManager alloc] init];
    
    });
    return sharedMyManager;
    
    
}



-(Playlist *)addPlaylistWithName:(NSString *)name{

    Playlist *p=[[Playlist alloc] init];
    p.title=name;
    
    
       NSString *basePath = [FileUtilities appPlaylistDirectory];
     CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
       NSString *finalFilePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",(__bridge NSString *)newUniqueIdString]];
    
     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:p];
    BOOL succ=[data writeToFile:finalFilePath atomically:YES];
    if(succ){
        p.fileName=(__bridge NSString *)newUniqueIdString;
        [self.playlists addObject:p];
        return p;
    
    
    }
        else return nil;
}

-(void)deletePlaylistWithName:(NSString *)name{
    
        
    NSString *basePath = [FileUtilities appPlaylistDirectory];
     NSString *finalFilePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:finalFilePath])
        [fileManager removeItemAtPath:finalFilePath error:nil];
}


-(void)loadAllPlaylist{

    int Count;
    NSString *path=[FileUtilities appPlaylistDirectory];
         NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    [self.playlists removeAllObjects];
    for (Count = 0; Count < (int)[directoryContent count]; Count++)
    {
        Playlist *p=[[Playlist alloc] initWithFileName:[directoryContent objectAtIndex:Count]];
        [p setFileName:[directoryContent objectAtIndex:Count]];
        [self.playlists addObject:p] ;
    }

}


-(Playlist *)getPlaylistAtIndex:(NSInteger)i{

    return [self.playlists objectAtIndex:i];


}




-(void)deletePlaylistAtIndex:(NSInteger)i{

    Playlist *p=[self.playlists objectAtIndex:i];
   
    [self deletePlaylistWithName:[p fileName]];

 
}
-(NSArray *)allPlaylists{


    return [_playlists copy];

}
@end
