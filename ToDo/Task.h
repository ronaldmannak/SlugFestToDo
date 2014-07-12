//
//  Task.h
//  ToDo
//
//  Created by Ronald Mannak on 7/12/14.
//  Copyright (c) 2014 Ronald Mannak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *

- (instancetype)initWithName:(NSString *)name;

@end
