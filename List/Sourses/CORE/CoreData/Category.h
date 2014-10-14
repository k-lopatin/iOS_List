//
//  Category.h
//  List
//
//  Created by lk1195 on 10/14/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentId;

@end
