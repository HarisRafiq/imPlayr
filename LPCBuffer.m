//
//  LPCBuffer.m
//  IMP
//
//  Created by YAZ on 3/14/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#import "LPCBuffer.h"



@implementation LPCBuffer
@synthesize end = _end;

- (id)init
{
    self = [super init];
    if (self) {
        _lock = OS_SPINLOCK_INIT;
    }
    
    return self;
}

- (void)dealloc
{
    while (_segments != NULL) {
        data_segment *next = _segments->next;
        free(_segments);
        _segments = next;
    }
}

- (void)setEnd:(BOOL)end
{
    OSSpinLockLock(&_lock);
    if (end && !_end) {
        _end = YES;
    }
    OSSpinLockUnlock(&_lock);
}

- (BOOL)readBytes:(void **)bytes length:(NSUInteger *)length
{
    *bytes = NULL;
    *length = 0;
    
    OSSpinLockLock(&_lock);
    
    if (_end && _segments == NULL) {
        OSSpinLockUnlock(&_lock);
        return NO;
    }
    
    if (_segments != NULL) {
        *length = _segments->length;
        *bytes = malloc(*length);
        memcpy(*bytes, _segments->bytes, *length);
        
        data_segment *next = _segments->next;
        free(_segments);
        _segments = next;
    }
    
    OSSpinLockUnlock(&_lock);
    
    return YES;
}
- (void)writeBytes:(const void *)bytes length:(NSUInteger)length
{
    OSSpinLockLock(&_lock);
    
    if (_end) {
        OSSpinLockUnlock(&_lock);
        return;
    }
    
    if (bytes == NULL || length == 0) {
        OSSpinLockUnlock(&_lock);
        return;
    }
    
    data_segment *segment = (data_segment *)malloc(sizeof(data_segment) + length);
    segment->bytes = segment + 1;
    segment->length = length;
    segment->next = NULL;
    memcpy(segment->bytes, bytes, length);
    
    data_segment **link = &_segments;
    while (*link != NULL) {
        data_segment *current = *link;
        link = &current->next;
    }
    
    *link = segment;
    
    OSSpinLockUnlock(&_lock);
}

@end
