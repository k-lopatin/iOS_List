//
//  MasterViewController.h
//  List
//
//  Created by lk1195 on 10/9/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *curCategories;
@property (nonatomic) int newCategoryId;
@property (nonatomic, strong) NSNumber *curCategoryId;
@property (nonatomic, strong)  NSManagedObject *curCategory;

@end
