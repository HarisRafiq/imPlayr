//
//  FileResource.m
//  iChm
//
//  Created by Robin Lu on 10/17/08.
//  Copyright 2008 robinlu.com. All rights reserved.
//
#import "MYHTTPConnection.h"
 #import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDNumber.h"
#import <AVFoundation/AVFoundation.h>
#import "HTTPServer.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPLogging.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import "imStreamer.h"
#import "AudioManager.h"
#import "imConstants.h"
static const NSInteger ddLogLevel = LOG_LEVEL_VERBOSE;
static const NSInteger httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

@implementation MYHTTPConnection
@synthesize storeFile;


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Add support for POST
    if ([method isEqualToString:@"POST"])
    {
        
            return YES;
             }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    NSDictionary  *parameters=[self parseGetParams  ];
    NSString *_method = [parameters objectForKey:@"_method"];
 
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.json"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    else return NO;
    
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
  
  
    
  
    if ([method isEqualToString:@"GET"])
	{
        if([path hasPrefix:@"/verify"] )
		{
            NSString *responseText =@"Denied";
            if( ![[imStreamer sharedInstance] isChanged] ){
                [[imStreamer sharedInstance] setChanged];
            responseText =@"Accept";
            
            
            }
            NSData *browseData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
            
            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:browseData]  ;
        }
        
          if([path hasPrefix:@"/music//"] )
		{
			NSArray *segs = [path componentsSeparatedByString:@"//"];
			if ([segs count] >= 1)
			{
				NSString *fileName = [segs objectAtIndex:1];
                  if (fileName == nil)
                {
                    [self handleResourceNotFound];
                    NSLog(@"filenotFound");
                }
                
                HTTPFileResponse *response = [[HTTPFileResponse alloc] initWithFilePath:[fileName  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forConnection:self];
                
                
                NSLog(@"response");

                
                 return response;
			}
		}
        if([path hasPrefix:@"/check//"] )
		{
            
             NSString *responseText = [[imStreamer sharedInstance] getCurrentSong];
            
            
            
            
            NSArray *segs = [path componentsSeparatedByString:@"//"];
			if ([segs count] >= 1)
			{
                
				NSString *status = [segs objectAtIndex:1];
                 if([status hasPrefix:@"true"]){
 
                    if(![[imStreamer sharedInstance] isPlaying])
                    {
                        [[imStreamer sharedInstance] setShouldPlay:YES];
                        [[imStreamer sharedInstance] setIsPlaying:YES];
                        if( [[UIApplication sharedApplication] applicationState]!=UIApplicationStateBackground )
                        {
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAMER_PLAYBACK_CHANGED object:nil];
                        
}
                    }
                }
                else  {
                    
                    if([[imStreamer sharedInstance] isPlaying])
                    {
                        [[imStreamer sharedInstance] setIsPlaying:NO];

                        if( [[UIApplication sharedApplication] applicationState]!=UIApplicationStateBackground )
                        {
                         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAMER_PLAYBACK_CHANGED object:nil];
                                                                     }
                  }
                    
                    
                }
                
            }
            NSData *browseData = [responseText dataUsingEncoding:NSUTF8StringEncoding];


            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:browseData]  ;
	}
        if([path hasPrefix:@"/get_artwork"] )
		{
            
       
            
            NSString *imageSource = [NSString stringWithFormat:@"data:image/png;base64,%@", [self base64String]];
            
            
            NSData  *responseText2 =  [imageSource dataUsingEncoding:NSUTF8StringEncoding];

            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:responseText2]  ;
        }
        if([path hasPrefix:@"/get_song_info"] )
		{
            
            NSString  *responseText =  [[[AudioManager sharedInstance] currentTrack] title] ;
            
            
            
            NSData *browseData = [responseText dataUsingEncoding:NSUTF8StringEncoding];

            
            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:browseData]  ;
        }
        
        
                if([path hasPrefix:@"/next_song"] )
		{
        
            [[AudioManager sharedInstance] _actionNext];
            
            NSString  *responseText = @"OK" ;
            
            
            
            NSData *browseData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
            
            
            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:browseData]  ;
            
            
        }
        
 
        if([path hasPrefix:@"/prev_song"] )
		{
            
            [[AudioManager sharedInstance] _actionPrev];
            
            NSString  *responseText = @"OK" ;
            
            
            
            NSData *browseData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
            
            
            // Creates a data response
            return [[HTTPDataResponse alloc] initWithData:browseData]  ;
            

        }
        
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    HTTPLogTrace();
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = (header.fields)[@"Content-Disposition"];
    NSString* filename = [(disposition.params)[@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    
    // create the path where to store the media
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* uploadDirPath = searchPaths[0];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        self.storeFile= nil;
    }
    else {
        HTTPLogVerbose(@"Saving file to %@", filePath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
            HTTPLogError(@"Could not create directory at path: %@", filePath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            HTTPLogError(@"Could not create file at path: %@", filePath);
        }
        self.storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     }
}

- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    // here we just write the output from parser to the file.
    if( self.storeFile ) {
        [self.storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
   
    [self.storeFile closeFile];
    self.storeFile = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FileDidUpload" object:nil];
 
}


- (void)actionList
{
	if (self.delegate == nil)
	{
		[self handleResourceNotFound];
		return;
	}
	
	NSMutableString *output = [[NSMutableString alloc] init];
	[output appendString:@"["];
	for(NSInteger i = 0; i<[self.delegate numberOfFiles]; ++i)
	{
		NSString* filename = [self.delegate fileNameAtIndex:i];
	 NSString* filePath = [self.delegate filePathForFileName: filename  ];
         NSURL *url=[NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] ;
        AudioFileID fileID;
        AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &fileID);
        Float64 outDataSize = 0;
#warning 64BIT: Inspect use of sizeof
        UInt32 thePropSize = sizeof(Float64);
        AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);

#warning 64BIT: Check formatting arguments
		[output appendFormat:@"{\"name\":\"%@\", \"duration\":%f},", filename, outDataSize];
        AudioFileClose(fileID);
        
        

	}
	if ([output length] > 1)
	{
		NSRange range = NSMakeRange([output length] - 1, 1);
		[output replaceCharactersInRange:range withString:@"]"];
	}
	else
	{
		[output appendString:@"]"];
	}
	
	[self sendString:output mimeType:nil];
    output=nil;
 }

- (void)actionDelete:(NSString*)fileName
{
	if (self.delegate == nil)
	{
		[self handleResourceNotFound];
		return;
	}
	
	if  ([self.delegate respondsToSelector:@selector(fileShouldDelete:)])
	{
		[self.delegate fileShouldDelete:[fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
	}
    

}
- (NSString *)base64String {
    NSData * data = [UIImagePNGRepresentation([[AudioManager sharedInstance] nowPlayingImage]) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}
@end
