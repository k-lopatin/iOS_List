//
//  MasterViewController.m
//  List
//
//  Created by lk1195 on 10/9/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () {
    //NSMutableDictionary *categories;
    
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *editButton = self.editButtonItem;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goPrevCategory:)];
    
    NSArray *rightButtons = [[NSArray alloc] initWithObjects:addButton, editButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
    
    self.navigationItem.leftBarButtonItem = backButton;    
    self.navigationItem.leftBarButtonItem.enabled = false;
    
    
    self.curCategoryId = @0;
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    /*NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"parentId == %d", 0];
    [fetchRequest setPredicate:predicateID];
    curCategories = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];*/
    [self updateTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Add"
                           message:@"Enter a category name, please."
                           delegate:self
                           cancelButtonTitle:@"OK"                           
                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *name = [[alertView textFieldAtIndex:0] text];
    if( name.length > 1 ){
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        // Create a new managed object
        NSManagedObject *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        [newCategory setValue:name forKey:@"name"];
        NSNumber *itemId = [[NSNumber alloc] initWithInt:[NSDate timeIntervalSinceReferenceDate]+self.newCategoryId ];
        [newCategory setValue:itemId forKey:@"id"];
        [newCategory setValue:self.curCategoryId forKey:@"parentId"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
       
        
        /*CategoryModel *tempCategory = [[CategoryModel alloc] initWithName:name itemId:[NSNumber numberWithInt:newCategoryId] parent:curCategoryId ];
        [categories setObject:tempCategory forKey:[NSNumber numberWithInt:newCategoryId]];*/
        [self.curCategories insertObject:newCategory atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.newCategoryId++;
    }    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.curCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSManagedObject *category = [self.curCategories objectAtIndex:indexPath.row];
    NSString *text = [category valueForKey:@"name"];
    cell.textLabel.text = text;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *tempCat = [self.curCategories objectAtIndex:indexPath.row];
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        [managedObjectContext deleteObject:tempCat];
        [self removeChildrenById:<#(NSNumber *)#>]
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.curCategories removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}

- (void) removeChildrenById:(NSNumber*)id_ {
    /*[categories removeObjectForKey:id_];
    NSMutableArray *arrToRemove = [NSMutableArray new];
    for(NSNumber *i in categories){
        if([[[categories objectForKey:i] parentId] integerValue] == [id_ integerValue]){
            [arrToRemove insertObject:i atIndex:0];            
        }
    }
    for(int i=0; i<[arrToRemove count]; i++){
        [self removeChildrenById:[arrToRemove objectAtIndex:i] ];
    }*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.curCategoryId = [[self.curCategories objectAtIndex:indexPath.row] valueForKey:@"id"];
    
    [self updateTableView];
}


- (void)goPrevCategory:(id)sender {
    self.curCategoryId = [ self.curCategory valueForKey:@"parentId" ];
    [self updateTableView];
}

-(void) updateTableView {
    
    [self.curCategories removeAllObjects];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"parentId == %d", [self.curCategoryId integerValue]];
    [fetchRequest setPredicate:predicateID];
    self.curCategories = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
    
    if([self.curCategoryId integerValue] == 0){
        self.navigationItem.title = @"Categories";
        self.navigationItem.leftBarButtonItem.enabled = false;
    } else {
        NSPredicate *predicateForCurCatID = [NSPredicate predicateWithFormat:@"id == %d", [self.curCategoryId integerValue]];
        [fetchRequest setPredicate:predicateForCurCatID];
        NSArray *curCategoryTempArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
        self.curCategory = [curCategoryTempArray objectAtIndex:0];
        self.curCategoryId = [self.curCategory valueForKey:@"id"];
        self.navigationItem.title = [self.curCategory valueForKey:@"name"];        
        self.navigationItem.leftBarButtonItem.enabled = true;
    }
    
    /*for(NSNumber *catId in categories){
        if([[[categories objectForKey:catId] parentId] integerValue] == [curCategoryId integerValue]){
            if([curCategories count] > 0 && [[[curCategories objectAtIndex:[curCategories count]-1] itemId] integerValue] < [[[categories objectForKey:catId] itemId] integerValue]){
                [curCategories insertObject:[categories objectForKey:catId] atIndex:0];
            } else {
                [curCategories insertObject:[categories objectForKey:catId] atIndex:[curCategories count] ];
            }
            
        }
    }
    
    */
        
    [self.tableView reloadData];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}




@end
