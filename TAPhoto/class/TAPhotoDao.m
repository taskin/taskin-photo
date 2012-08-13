//
//  TAPhotoDao.m
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPhotoDao.h"
#import "TAPhoto.h"

#define TADB_PATH @"TAPhoto.sqlite"


static NSString *ENTITY_TAPHOTO = @"TAPhoto";

@implementation TAPhotoDao

+ (id)sharedInstance {
	static dispatch_once_t pred;
	static TAPhotoDao *shared = nil;
	
	dispatch_once(&pred, ^{
		shared = [[TAPhotoDao alloc] init];
	});
	[shared dataContextFromStore];
	return shared;
}


-(void)dataContextFromStore {
	ctx = [NSManagedObjectContext new];
	ctx.persistentStoreCoordinator = [self getPersistentStoreCoordinator];
	ctx.undoManager = nil;
	ctx.mergePolicy = NSOverwriteMergePolicy;
}

static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;

-(NSPersistentStoreCoordinator *)getPersistentStoreCoordinator {
	@synchronized(self) {
        if (_persistentStoreCoordinator != nil) return _persistentStoreCoordinator;
		
        NSString *appDocPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *storeUrl = [NSURL fileURLWithPath: [appDocPath stringByAppendingPathComponent: TADB_PATH]];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TAPhoto" ofType:@"mom"];
		NSLog(@"db : %@", path);
        NSURL *momURL = [NSURL fileURLWithPath:path];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        NSError *error = nil;
        
        NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
        
        if (!persistentStoreCoordinator || ![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
            return nil;
        }
        
        _persistentStoreCoordinator = persistentStoreCoordinator;
    }
    
	return _persistentStoreCoordinator;
}



-(NSArray *)getPhotoList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_TAPHOTO inManagedObjectContext:ctx];
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];

	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:sortDesc, nil]];
	
    NSError *error = nil;
    NSArray *result = [ctx executeFetchRequest:request error:&error];
	
	return result;
}

-(TAPhoto *)createPhoto {
	return [[TAPhoto alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_TAPHOTO inManagedObjectContext:ctx] insertIntoManagedObjectContext:ctx];
}

-(void)deletePhoto:(TAPhoto *)photo {
	[ctx deleteObject:photo];
	[ctx save:nil];
}

@end
