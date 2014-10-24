//
//  LSRestController.m
//  List
//
//  Created by lk1195 on 10/24/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import "LSRestController.h"

@implementation LSRestController

- (void *) fetchCategoryById: (NSString *) catId;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchCategoryByIdInBackground:catId];
    });
}

- (void) fetchCategoryByIdInBackground: (NSString *) catId; {
    NSString *serverName = @"http://server-name/list/";
    NSURL *url = [NSURL
                  URLWithString:[NSString stringWithFormat:@"%@/%@/", serverName, catId] ];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *categoryObj = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:NULL];
             [self.category setId:[ [NSNumber alloc]
                                   initWithInt:[ [categoryObj objectForKey:@"id"] integerValue ] ] ];
             [self.category setParentId:[ [NSNumber alloc]
                                         initWithInt:[ [categoryObj objectForKey:@"parentId"] integerValue ] ] ];
             
             [self.category setName:[categoryObj objectForKey:@"name"] ];
         }
     }];
}

@end
