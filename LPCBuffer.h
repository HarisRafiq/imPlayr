//
//  LPCBuffer.h
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libkern/OSAtomic.h>

typedef struct data_segment {
    void *bytes;
    NSUInteger length;
    struct data_segment *next;
} data_segment;

@interface LPCBuffer :  NSObject{
@private
    data_segment *_segments;
    BOOL _end;
    OSSpinLock _lock;
}
 


@property (nonatomic, assign, getter = isEnd) BOOL end;

- (BOOL)readBytes:(void **)bytes length:(NSUInteger *)length;
- (void)writeBytes:(const void *)bytes length:(NSUInteger)length;

@end
