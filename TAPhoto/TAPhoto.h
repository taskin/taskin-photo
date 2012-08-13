//
//  TAPhoto.h
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAPhoto : NSManagedObject {
	
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, assign) NSNumber *sort;

@end
