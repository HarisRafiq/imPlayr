//
//  playrsTrack.m
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "playrsTrack.h"
#import <AVFoundation/AVFoundation.h>

@implementation playrsTrack
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _audioFileURLstr = [aDecoder decodeObjectForKey:@"url"];
        _artist = [aDecoder decodeObjectForKey:@"artist"];
        _duration = [aDecoder decodeObjectForKey:@"duration"];
        _album = [aDecoder decodeObjectForKey:@"album"];
 
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_audioFileURLstr forKey:@"url"];
    [aCoder encodeObject:_artist forKey:@"artist"];
    [aCoder encodeObject:_duration forKey:@"duration"];
    [aCoder encodeObject:_album forKey:@"album"];
    
}


 
-(id)initItemWithFilePath:(NSString *)filePath {
    self=[super init];
    if( self){
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        AudioFileID fileID = nil;
        OSStatus err = noErr;
        
        err = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0, &fileID);
        if (err != noErr) {
            return nil;
        }
        
        UInt32 id3DataSize = 0;
        err = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL);
        if (err != noErr) {
            return nil;
        }
        
        CFDictionaryRef piDict = nil;
#warning 64BIT: Inspect use of sizeof
        UInt32 piDataSize = sizeof(piDict);
        
        //  Populates a CFDictionary with the ID3 tag properties
        err = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
        //  Toll free bridge the CFDictionary so that we can interact with it via objc
        NSDictionary* nsDict = (__bridge NSDictionary*)piDict;
        
        NSString *artistStr=[nsDict objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
        if(artistStr==nil)
            artistStr=NSLocalizedString(@"Unknown", nil);
        
        NSString *titleStr=[nsDict objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_Title]];
        if(titleStr==nil)
            titleStr=[filePath lastPathComponent];
        
        NSString *durationStr=[nsDict objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_ApproximateDurationInSeconds]];
        if(durationStr==nil)
            durationStr=@"0:00";
        NSString *albumStr=[nsDict objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_Album]];
        if(albumStr==nil)
            albumStr=NSLocalizedString(@"Unknown", nil);
        
        _album=albumStr;
        _title=titleStr;
        _artist=artistStr;
        _duration=[NSNumber numberWithInteger:[durationStr integerValue]];
        _audioFileURLstr=filePath;
        _audioFileURL=fileURL;
        
        AudioFileClose(fileID);
        if(piDict)
            CFRelease(piDict);
        nsDict = nil;
        
    }
    
    
    return self;
}

@end
