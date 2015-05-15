//
//  Playlist.m
//  IMP
//
//  Created by YAZ on 3/18/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "Playlist.h"
 #import "FileUtilities.h"
#import "playrsMemory.h"
@implementation Playlist
@synthesize fileName,tracks,title;
-(id)init{
    
    self = [super init];
    if (self) {
        tracks = [[NSMutableArray alloc] init];
 title=NSLocalizedString(@"Unknown", nil);
    }
    return self;


}
- (id)initWithFileName:(NSString *)name
{
    
     if(self=[super init] ){
        
      fileName=name;
                 if ([self FileExists]) {
                     self = [NSKeyedUnarchiver unarchiveObjectWithFile:[self FilePath]] ;
               
                 
                 }
        
        
     }
    return self;

}

- (NSString*)FilePath {
 	NSString *documentsDirectory = [FileUtilities appPlaylistDirectory];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@" ,fileName]];
	return filePath;
}

- (BOOL)FileExists {
	NSString *filePath = [self FilePath];
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
- (BOOL)save {
    NSString *file=[self FilePath];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        return  [data writeToFile:file atomically:YES];

 }

#pragma mark -
#pragma mark NSCoding
-(void)addTrackWithURLString:(NSString *)track{
    [self.tracks addObject:track];
    [self save];

}

-(void)removeTracksAtIndex:(NSInteger)i{
    [self.tracks removeObjectAtIndex:i ];


}
-(NSString *)trackURLStringAtIndex:(NSInteger)i{
    
    
    return [self.tracks objectAtIndex:i];
    
}
- (void) addTrackWithURLString:(NSString *)track atIndex:(NSUInteger)index
{
    if (track)
        [self.tracks insertObject:track atIndex:index];
}
- (void) moveTrackFromIndex:(NSUInteger)initIndex toIndex:(NSUInteger)endIndex
{
    id something = [self.tracks objectAtIndex:initIndex];
    [self.tracks removeObjectAtIndex:initIndex];
    [self.tracks insertObject:something atIndex:endIndex];
    [self save];
}
-(void)addTracksFromArray:(NSArray *)trackArray{

    [self.tracks removeAllObjects];
    
    
    for(playrsTrack *s in trackArray)
    {
        NSString *url=(NSString *)[s audioFileURLstr];
    [self.tracks addObject:url];
    }
    [self save];



}


 -(void)changeTitleTo:(NSString *)newTitle{
    self.title=newTitle;
    [self save];


}
-(void)clear{
    [self.tracks removeAllObjects];
    [self save];
}
#pragma mark NSCODER
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.tracks = [decoder decodeObjectForKey:@"tracks"];
        self.title = [decoder decodeObjectForKey:@"title"];
      }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
 
    [encoder encodeObject:self.tracks forKey:@"tracks"];
    [encoder encodeObject:self.title forKey:@"title"];
  }



-(NSArray *)tracksFromPlaylist{
if( [self.tracks count]> 0)
{
    NSArray *array=[[playrsMemory sharedInstance] songsFromNSURLstrArray:[self.tracks copy]];
    return array;
}
    
else return [[NSArray alloc] init];
}
@end
