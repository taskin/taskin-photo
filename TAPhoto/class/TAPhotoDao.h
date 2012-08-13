//
//  TAPhotoDao.h
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TAPhoto;

@interface TAPhotoDao : NSObject {
	NSManagedObjectContext *ctx;
}

+(id)sharedInstance;
-(void)dataContextFromStore;
-(NSPersistentStoreCoordinator *)getPersistentStoreCoordinator;



-(NSArray *) getPhotoList;
-(TAPhoto *)createPhoto;
-(void)deletePhoto:(TAPhoto *)photo;

@end
