//
//  TAMasterViewController.m
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMasterViewController.h"
#import "TADetailViewController.h"

#import "TAPhotoDao.h"
#import "TAPhoto.h"

@interface TAMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TAMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"Photo List";
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto:)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (TAPhoto *)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[[NSDate date] description] forKey:@"title"];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return (TAPhoto *)newManagedObject;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.showsReorderControl = YES;
		cell.shouldIndentWhileEditing = NO;
    }

	[self configureCell:cell atIndexPath:indexPath];
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
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	
    if (indexPath.section == newIndexPath.section) {
        NSInteger start = indexPath.row;
        NSInteger end = newIndexPath.row;
        NSInteger i = 0;
        if (end < start) start = end;
        if (start > end) end = start;
        for (i = start; i <= end; i++) {
			NSIndexPath *tempPath = [NSIndexPath indexPathForRow:i inSection:newIndexPath.section];
			TAPhoto *photo = [self.fetchedResultsController objectAtIndexPath:tempPath];
			photo.sort = [NSNumber numberWithInteger:i];
			[self.managedObjectContext refreshObject:photo mergeChanges:YES];
        }
		
    }
    // Save the context.
    NSError *error;
    if (![context save:&error]) {
        // Handle the error...
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[TADetailViewController alloc] initWithNibName:@"TADetailViewController" bundle:nil];
    }
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self.tableView reloadData];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

	if ([object valueForKey:@"filePath"]) {
		NSString *imagePath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, [object valueForKey:@"filePath"]];
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
		cell.imageView.image = image;
	} else {
		cell.imageView.image = nil;
	}
	cell.detailTextLabel.text = [[object valueForKey:@"timeStamp"] description];
    cell.textLabel.text = [[object valueForKey:@"title"] description];
}



#pragma mark image picker.
- (IBAction) transferCamera:(id)sender {
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		NSLog(@"[BUG] 이러시면 안되요... 카메라를 지원하지 않는 디바이스 입니다.");
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.allowsEditing = NO;
	
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction) transferPhotoLibrary:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.allowsEditing = NO;

    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
	
	if ([mediaType isEqualToString:@"public.movie"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"동영상 지원 불가" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
	} else if ([mediaType isEqualToString:@"public.image"]){
		UIImage *pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        
		if (pickedImage) { 
			NSString *filename = [NSString stringWithFormat:@"IMG_%d.jpg", random()];
			[self saveFile:UIImageJPEGRepresentation(pickedImage, 0.7) withName:filename withDirectory:DOCUMENTS_FOLDER];
			
			TAPhoto *photo = [self insertNewObject:pickedImage];
			photo.filePath = filename;
			photo.sort = [self nextSeq];

			[self.managedObjectContext save:nil];
			double delayInSeconds = 0.5;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self insertTitle:photo];
			});
		}
	}
	[self dismissModalViewControllerAnimated:NO];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark utils.

- (NSString *)saveFile:(NSData *)content withName:(NSString *)filename withDirectory:(NSString *)direc {
	if ([filename length] <= 0) return nil;
    
	NSString *_path = [NSString stringWithFormat:@"%@/%@", direc, filename];
    NSString *directory = [_path substringToIndex: [_path length] - [[_path lastPathComponent] length] - 1 ];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:directory] ) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
        [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
    }
    
	BOOL success = [[NSFileManager defaultManager] createFileAtPath:_path contents:content attributes:nil];
	return (success) ? filename : nil;
}


#pragma mark button actions.

- (void)addPhoto:(id)sender {
	[self transferPhotoLibrary:sender];
}

- (void)insertTitle:(TAPhoto *)photo {
	insertedPhoto = photo;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo name" message:nil 
												   delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Confirm", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		insertedPhoto.title = [[alertView textFieldAtIndex:0] text];
	} else {
        [self.managedObjectContext deleteObject:insertedPhoto];
	}
	[self.managedObjectContext save:nil];
}

- (NSNumber *)nextSeq {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setResultType:NSDictionaryResultType];
	
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sort"];
	NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	
	[expressionDescription setName:@"maxSeq"];
	[expressionDescription setExpression:maxExpression];
	[expressionDescription setExpressionResultType:NSInteger64AttributeType];
	
	[request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	NSNumber *resultNum = [NSNumber numberWithInt:0];
	
	if (objects != nil && [objects count] > 0) {
		resultNum = [NSNumber numberWithLongLong:([[[objects objectAtIndex:0] valueForKey:@"maxSeq"] longLongValue]+ 1)];
	}

	return resultNum;
}

@end
