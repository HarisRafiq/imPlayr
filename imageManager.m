//
//  imageManager.m
//  imPlayr2
//
//  Created by YAZ on 6/6/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "imageManager.h"
 #import "imageManager.h"
#import "AudioManager.h"
@implementation imageManager

+(imageManager*)getInstance
{
    static imageManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[imageManager alloc] init];
        
    });
    return sharedMyManager;
    
    
}
-(id)init
{
if(self=[super init])
{

    [self loadAllImages];
    _internalDownloader = [[NSMutableDictionary alloc]init];

}
    return self;
}

-(void)loadAllImages{
    
   if([self FileExists])
    
 	_images = [[NSDictionary dictionaryWithContentsOfFile:[self FilePath]] mutableCopy];
    else
        
        _images=[[NSMutableDictionary alloc] init];


}

- (NSString*)FilePath {
 	NSString *documentsDirectory = [FileUtilities appImageDirectory];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"images.plist"]];
	return filePath;
}

- (BOOL)FileExists {
	NSString *filePath = [self FilePath];
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
- (BOOL)save {
    NSString *file=[self FilePath];
    return  [_images writeToFile:file atomically:YES];
    
}


-(void)addImageURL:(NSString *)url ForTrack:(NSString *)s{

    [_images setObject:s forKey:url];
[self save
 ];
}


-(void)removeImageForUrl:(NSArray *)a{
    
    [_images removeObjectsForKeys:a];
    
}

-(NSArray * )loadImagesForTrack:(NSString *)pList{
	NSArray* keys =[_images allKeysForObject:pList];
    return [keys copy];
}



+ (UIImage *) imageForURL:(NSString *)fileName  {
    
    
 
            UIImage *image=nil;
        
        if( [[NSFileManager defaultManager] fileExistsAtPath:fileName]){
              image =[UIImage imageWithContentsOfFile:fileName];
            
        }
    
    return image;
}

+(void)saveToFile:(UIImage *)image{
    if(image!=nil){
     NSString *basePath = [FileUtilities appImageDirectory];
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *finalFilePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",(__bridge NSString *)newUniqueIdString]];
    

     if(![[NSFileManager defaultManager] fileExistsAtPath:finalFilePath]){
        NSData *data=UIImagePNGRepresentation(image);
        [data writeToFile:finalFilePath atomically:YES];
        [[imageManager getInstance] addImageURL:finalFilePath ForTrack:[[[AudioManager sharedInstance] currentTrack] audioFileURLstr]];
         
 
         [[AudioManager sharedInstance] setColorScheme];
          
                   }

    }
}
+(void)removeFileForTrack:(NSString *)s
{

    NSArray *a=[[imageManager getInstance] loadImagesForTrack:s];
    if([a count]>0){
for(NSString *sd in a)
{     if([[NSFileManager defaultManager] fileExistsAtPath:sd]){

    [[NSFileManager defaultManager] removeItemAtPath:sd error:nil];
    

}
    [[imageManager getInstance] removeImageForUrl:a];
    [[imageManager getInstance] save];
     
}

     }
}
@end
