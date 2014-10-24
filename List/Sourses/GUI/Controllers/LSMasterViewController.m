//
//  MasterViewController.m
//  List
//
//  Created by lk1195 on 10/9/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import "LSMasterViewController.h"

@implementation LSMasterViewController

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
    
    /*
     Right Navigation. Add and edit buttons;
     */    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(insertNewObject:)];    
    UIBarButtonItem *editButton = self.editButtonItem;
    NSArray *rightButtons = [[NSArray alloc]
                             initWithObjects:addButton, editButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
    
    /*
     Left Navigation. Back button;
     */    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Back Button", nil)
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(goPrevCategory:)];    
    self.navigationItem.leftBarButtonItem = backButton;    
    self.navigationItem.leftBarButtonItem.enabled = false;
    
    
    self.curCategoryId = @0;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender
{
    /*
     Add category dialog window 
     */
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:NSLocalizedString(@"Add dialog title", nil)
                           message:NSLocalizedString(@"Add dialog text", nil)
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"OK", nil)                           
                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *name = [[alertView textFieldAtIndex:0] text]; //name from input
    
    if( name.length > 1 ){
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        
        [newCategory setValue:name forKey:@"name"];
        
        //Create unique id for new element
        NSNumber *itemId = [[NSNumber alloc] initWithInt:[NSDate timeIntervalSinceReferenceDate]+self.newCategoryId ];
        [newCategory setValue:itemId forKey:@"id"];
        
        [newCategory setValue:self.curCategoryId forKey:@"parentId"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [self.curCategories insertObject:newCategory atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *tempCat = [self.curCategories objectAtIndex:indexPath.row];
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        [managedObjectContext deleteObject:tempCat];
        // remove children of this element
        [self removeChildrenById:[tempCat valueForKey:@"id"]];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.curCategories removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}

- (void) removeChildrenById:(NSNumber*)id_ {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"parentId == %d", [id_ integerValue]];
    [fetchRequest setPredicate:predicateID];
    NSMutableArray *CategoriesToRemove = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    /*
     Remove every child of the element
     */
    for(NSManagedObject *n in CategoriesToRemove){
        [self removeChildrenById:[n valueForKey:@"id"]];
        [managedObjectContext deleteObject:n];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set current category to selected 
    self.curCategoryId = [[self.curCategories objectAtIndex:indexPath.row] valueForKey:@"id"];
    
    [self updateTableView];
}


- (void)goPrevCategory:(id)sender {
    //set current category to parent 
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
    
    if([self.curCategoryId isEqual: @0]){
        self.navigationItem.title = NSLocalizedString(@"Main Title", nil);
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
