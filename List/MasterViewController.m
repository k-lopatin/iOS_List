//
//  MasterViewController.m
//  List
//
//  Created by lk1195 on 10/9/14.
//  Copyright (c) 2014 lk1195. All rights reserved.
//

#import "MasterViewController.h"
#import "CategoryModel.h"

@interface MasterViewController () {
    NSMutableDictionary *categories;
    NSMutableArray *curCategories;
    int newCategoryId;
    NSNumber *curCategoryId;
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!categories) {
        categories = [[NSMutableDictionary alloc] init];
        curCategories = [[NSMutableArray alloc] init];
    }
    
    if(!newCategoryId){
        newCategoryId = 1;
        curCategoryId = @0;
    }
    
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
    if( [CategoryModel validateName:name] ){
        CategoryModel *tempCategory = [[CategoryModel alloc] initWithName:name itemId:[NSNumber numberWithInt:newCategoryId] parent:curCategoryId ];
        [categories setObject:tempCategory forKey:[NSNumber numberWithInt:newCategoryId]];
        [curCategories insertObject:tempCategory atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        newCategoryId++;
    }    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return curCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];    
    NSString *text = [ [curCategories objectAtIndex:indexPath.row] name];
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
        NSNumber *tempCatId = [[curCategories objectAtIndex:indexPath.row] itemId];
        [curCategories removeObjectAtIndex:indexPath.row];
        [self removeChildrenById:tempCatId];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void) removeChildrenById:(NSNumber*)id_ {
    [categories removeObjectForKey:id_];
    NSMutableArray *arrToRemove = [NSMutableArray new];
    for(NSNumber *i in categories){
        if([[[categories objectForKey:i] parentId] integerValue] == [id_ integerValue]){
            [arrToRemove insertObject:i atIndex:0];            
        }
    }
    for(int i=0; i<[arrToRemove count]; i++){
        [self removeChildrenById:[arrToRemove objectAtIndex:i] ];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
 */


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    curCategoryId = [[curCategories objectAtIndex:indexPath.row] itemId];
    
    [self updateTableView];
}


- (void)goPrevCategory:(id)sender {
    curCategoryId = [ [categories objectForKey:curCategoryId] parentId];
    [self updateTableView];
}

-(void) updateTableView {
    
    [curCategories removeAllObjects];
    
    for(NSNumber *catId in categories){
        if([[[categories objectForKey:catId] parentId] integerValue] == [curCategoryId integerValue]){
            if([curCategories count] > 0 && [[[curCategories objectAtIndex:[curCategories count]-1] itemId] integerValue] < [[[categories objectForKey:catId] itemId] integerValue]){
                [curCategories insertObject:[categories objectForKey:catId] atIndex:0];
            } else {
                [curCategories insertObject:[categories objectForKey:catId] atIndex:[curCategories count] ];
            }
            
        }
    }
    if([curCategoryId integerValue] == 0){
        self.navigationItem.title = @"Categories";
        self.navigationItem.leftBarButtonItem.enabled = false;
    } else { 
        self.navigationItem.title = [[categories objectForKey:curCategoryId] name];
        self.navigationItem.leftBarButtonItem.enabled = true;
    }
    
        
    [self.tableView reloadData];
}




@end
