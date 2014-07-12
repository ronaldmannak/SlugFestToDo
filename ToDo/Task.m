//
//  Task.m
//  ToDo
//
//  Created by Ronald Mannak on 7/12/14.
//  Copyright (c) 2014 Ronald Mannak. All rights reserved.
//

#import "Task.h"

@implementation Task

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (NSString *)description
{
    return self.name;
}

@end
