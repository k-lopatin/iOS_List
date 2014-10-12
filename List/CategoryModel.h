//
//  CategoryModel.h
//  List
//
//  Created by lk1195 on 10/12/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryModel : NSObject

@property NSString *name;
@property NSNumber *itemId;
@property NSNumber *parentId;


- (id) initWithName:(NSString *) _nameStr itemId:(NSNumber*) itemId_ parent:(NSNumber*) parentId_;

+ (BOOL) validateName:(NSString *) name;

@end
