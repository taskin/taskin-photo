//
//  TAMasterViewController.h
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPhoto.h"

@class TADetailViewController;

#import <CoreData/CoreData.h>

@interface TAMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
	TAPhoto *insertedPhoto;
}

@property (strong, nonatomic) TADetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSNumber *)nextSeq;

@end
