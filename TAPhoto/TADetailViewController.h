//
//  TADetailViewController.h
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TADetailViewController : UIViewController <UIScrollViewDelegate> {
	UIImageView *imgView;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@end
