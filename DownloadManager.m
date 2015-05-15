//
//  DownloadManager.m
//  imPlayr2
//
//  Created by YAZ on 5/23/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "DownloadManager.h"
#import "FileUtilities.h"
#import "Download.h"
#import "imConstants.h"
static DownloadManager *sharedInstance = nil;
static NSString *kDownloadManagerBackgroundSessionIdentifier = @"com.imPlayr.backgroundSession";
static NSString *kDownloadUserDefaultsObject = @"kDownloadUserDefaultsObject";

@interface Download (Private)

- (id)initPrivate;
- (void)cancelPrivate;
@property (weak, nonatomic, readwrite) id downloadTask;
@property (strong, nonatomic, readwrite) NSURL *url;

@end

@interface DownloadManager ()

@property (weak, nonatomic) NSURLSession *backgroundSession;
@property (copy, nonatomic, readwrite) NSMutableDictionary *tasks;

@end

@implementation DownloadManager
+(id)sharedInstance
{
    static dispatch_once_t onceToken5;
    dispatch_once(&onceToken5, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] initPrivate];
        }
       
    });
    return sharedInstance;
}
- (id)init {
    
        return nil;
}

-(id)initPrivate{
    
    self = [super init];
    if (self) {
        _backgroundSession = nil;
        _tasks = nil;
        
        [self tasks];
        
        // create the session
        [self createSession];
        

        
     }
    return self;
    
    
}
-(NSDictionary *)tasks
{
    if (!_tasks)
    {
        NSDictionary *loadedDownload = nil;
        
        @try {
            NSData *downloadData = [[NSUserDefaults standardUserDefaults] objectForKey:kDownloadUserDefaultsObject];
            loadedDownload = [NSKeyedUnarchiver unarchiveObjectWithData:downloadData];
        }
        @catch (NSException *exception) {
            // clean NSUserDefaults
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDownloadUserDefaultsObject];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        if (!loadedDownload || ![loadedDownload isKindOfClass:[NSDictionary class]])
        {
            _tasks = [NSMutableDictionary dictionary];
        } else {
            _tasks = [loadedDownload mutableCopy];
        }
    }
    
    return [[NSDictionary alloc] initWithDictionary:_tasks];
}


- (NSString*)FilePath:(NSString *)fileName {
 	NSString *documentsDirectory = [FileUtilities appFilesDirectory];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@" ,fileName]];
	return filePath;
}
 -(NSString *)changeNameIfFileAtPathExists:(NSString *)filePathComplete
{
        NSString *finalFilePath = filePathComplete;
    NSString *fileName = [finalFilePath lastPathComponent];
    NSString *fileNameWithoutExtension = [fileName stringByDeletingPathExtension];
    NSString *fileExtension = [fileName pathExtension];
    NSString *fileDirectory = [finalFilePath stringByDeletingLastPathComponent];
    NSString *thePoint = @".";
    
    // the main counter
    int counter = 0;
    
    // loop to increase the counter everytime an existent file is found
    while ([[NSFileManager defaultManager] fileExistsAtPath:finalFilePath]) {
        counter++;
        fileName = [NSString stringWithFormat:@"%@(%i)%@%@", fileNameWithoutExtension, counter, thePoint, fileExtension];
        finalFilePath = [fileDirectory stringByAppendingPathComponent:fileName];
    }
    
    return finalFilePath;
    // ---------------------------- FILENAME CHECK END ---------------------------- //
}

-(void)createSession
{
    // ensure that the session identifier is unique adding the name of the application
    NSString *sessionIdentifier = [kDownloadManagerBackgroundSessionIdentifier stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:sessionIdentifier];
    configuration.HTTPMaximumConnectionsPerHost = 10;
    
    self.backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // get a list of the downloadTasks associated to this session
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] > 0)
        {
            
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                // there are outstanding tasks - reset the tasks dictionary
                // check if the tasks are correctly loaded from the saved dictionary, if there is some incongrouence delete the task
                
                Download *associatedTask = [_tasks objectForKey:task.originalRequest.URL];
                
                if (associatedTask)
                {
                    associatedTask.downloadTask = task;
                } else {
                    [task cancel];
                }
            }
            
            [self saveDownloads];
        } else {
            // restart outstanding tasks. Use a delay to permit the delivery of delegate messages if the app has been awaken by the system
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if ([_tasks count] > 0){
                    // if there are outstanding tasks not associated with a session, start them
                    // note: when the system wake up the app because a download have been finished
                    
                    for (Download *task in [_tasks allValues]) {
                        
                        NSURLRequest *request = [NSURLRequest requestWithURL:task.url];
                        
                        NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
                        
                        task.downloadTask = downloadTask;
                    }
                }
                
            });
        }
    }];
}

/**
 Save the download list to the disk
 */
-(void)saveDownloads
{
    if ([self.tasks count] > 0)
    {
        NSData *notFinishedDownloads = [NSKeyedArchiver archivedDataWithRootObject:[_tasks copy]];
        
        [[NSUserDefaults standardUserDefaults] setObject:notFinishedDownloads forKey:kDownloadUserDefaultsObject];
        
        
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDownloadUserDefaultsObject];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(Download *)downloadForURL:(NSURL *)url
{
    
    return [self downloadForURL:url withResumeData:nil];
}

-(Download *)downloadForURL:(NSURL *)url withResumeData:(NSData *)data
{  if ([self.tasks objectForKey:url])
    return [self.tasks objectForKey:url];
    
    Download *task = [[Download alloc] initPrivate];
    task.url = url;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = nil;
    
    if (data)
    {
        downloadTask = [self.backgroundSession downloadTaskWithResumeData:data];
    }
    else
    {
        downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    }
    
    task.downloadTask = downloadTask;
    if(task!=nil&&url!=nil){
    // add the task to the dictionary
    [_tasks setObject:task forKey:url];
    
    [self saveDownloads];
    }
        return task;
        
}

-(Download *)downloadForURLRequest:(NSURLRequest *)request
{
    if ([self.tasks objectForKey:request.URL])
        return [self.tasks objectForKey:request.URL];
    
    Download *task = [[Download alloc] initPrivate];
    task.url = request.URL;
    
    NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    
    
    task.downloadTask = downloadTask;
    
    // add the task to the dictionary
    [_tasks setObject:task forKey:request.URL];
    
    [self saveDownloads];
    
    return task;
}

-(BOOL)cancelDownloadForURL:(NSURL *)url
{ Download *task = [_tasks objectForKey:url];
    
    if (task)
    {
        [task cancelPrivate];
        if (url)
        {
            [_tasks removeObjectForKey:url];
        }
        [self saveDownloads];
        return YES;
    }
    
    return NO;
 }

-(NSURL *)urlForNSURLSessionDownloadTask:(NSURLSessionDownloadTask *)task
{
    return task.originalRequest.URL;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    Download *task = [self.tasks objectForKey:[self urlForNSURLSessionDownloadTask:downloadTask]];
    
    NSError *error = nil;
    
    NSString *finalLocation = [[FileUtilities appFilesDirectory] stringByAppendingPathComponent:task.fileName];
    
    finalLocation = [self changeNameIfFileAtPathExists:finalLocation];
    
    NSString *locationString = [location path];
    
    NSLog(@"Moving: %@ to: %@", locationString, finalLocation);
    
    // move the file
    BOOL success = NO;
    
    if (locationString && finalLocation)
    {
        success = [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:finalLocation error:&error];
    } else {
        @try {
            // if the finalLocation is nil, maybe the default filename is not ok. Use a default one
            finalLocation = [[FileUtilities appFilesDirectory] stringByAppendingPathComponent:@"mp3"];
            success = [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:finalLocation error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Error moving file after task finished: source or destination is nil");
        }
    }
    
    // remove the task
    if (task.url) {
        [_tasks removeObjectForKey:task.url];
    }
    
    [self saveDownloads];
    
    if (!success)
    {
        NSLog(@"Error moving file: %@ to destination %@. Error: %@", locationString, finalLocation, error.description);
        if (task.completionBlock)
            task.completionBlock(NO, error);
    } else {
        if (task.completionBlock)
            task.completionBlock(YES, nil);
        
        NSLog(@"File moved to: %@", finalLocation);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TRACK_ADDED_MEMORY object:finalLocation];
    }
    

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    Download *task = [self.tasks objectForKey:[self urlForNSURLSessionDownloadTask:downloadTask]];
    
    if (task.progressBlock)
        task.progressBlock(downloadTask.originalRequest.URL, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"Session %@ with task %@ finished with error %@", session, task, error);
    
    if ([task isKindOfClass:[NSURLSessionUploadTask class]])
    {
        Download *theTask = [_tasks objectForKey:task.originalRequest.URL];
        
        if (error)
        {
            NSLog(@"Error uploading file");
            if (theTask.completionBlock)
                theTask.completionBlock(NO, error);
        } else {
            if (theTask.completionBlock)
                theTask.completionBlock(YES, nil);
        }
        
        // remove the task
        if (task.originalRequest.URL) {
            [_tasks removeObjectForKey:task.originalRequest.URL];
        }
        
        [self saveDownloads];
    }
    
    
    if (error)
    {
        // check if resume data are available
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData])
        {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            NSString *urlString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
            
            if ([self.tasks objectForKey:[NSURL URLWithString:urlString]])
            {
                Download *task = [self.tasks objectForKey:[NSURL URLWithString:urlString]];
                task.downloadTask = [self.backgroundSession downloadTaskWithResumeData:resumeData];
                [task start];
            }
            
        }
        
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

 - (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
 
    if ([_tasks count] == 0) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"All files have been downloaded!";
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        
    }
    
    
}
@end
