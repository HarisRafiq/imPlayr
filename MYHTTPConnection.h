//
//  FileResource.h
//  iChm
//
//  Created by Robin Lu on 10/17/08.
//  Copyright 2008 robinlu.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CFNetwork/CFHTTPMessage.h>
 #import "HTTPConnection.h"

@class MultipartFormDataParser;
@interface MYHTTPConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
    
    
    NSMutableArray*                 uploadedFiles;
    
}
@property (nonatomic, retain) NSFileHandle *storeFile;
@property (nonatomic, strong) NSString *shouldSendPlayCommand;
@property (nonatomic, strong) NSString *shouldSendPauseCommand;

@end