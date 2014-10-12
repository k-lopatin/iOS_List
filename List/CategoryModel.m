//
//  CategoryModel.m
//  List
//
//  Created by lk1195 on 10/12/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

- (id) initWithName:(NSString *) _nameStr itemId:(NSNumber*) itemId_ parent:(NSNumber*) parentId_  {
    self = [super init];
    if (self) {
        self.name = _nameStr;
        self.itemId = itemId_;
        self.parentId = parentId_;
    }
    return self;
}

+ (BOOL) validateName:(NSString *) name {
    return (name.length > 1);
}

@end
