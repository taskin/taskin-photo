//
//  TADetailViewController.m
//  TAPhoto
//
//  Created by Seong Jin Kim on 12 7 16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TADetailViewController.h"

#define NAVIGATION_HEIGHT 20
#define IMAGE_PADDING 0
#define MAX_ZOOM_SCALE 6
#define MIN_ZOOM_SCALE 1


@interface TADetailViewController ()
- (void)configureView;
@end

@implementation TADetailViewController

@synthesize detailItem = _detailItem;
@synthesize imgView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

	if (self.detailItem) {
		self.title = [self.detailItem valueForKey:@"title"];

		if ([self.detailItem valueForKey:@"filePath"]) {
			NSString *imagePath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, [self.detailItem valueForKey:@"filePath"]];
			UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
			if (!image) return;

			if (image.size.width > image.size.height) {
				image = [[UIImage alloc] initWithCGImage: image.CGImage
																	 scale: 1.0
															   orientation: UIImageOrientationRight];
			}
			imgView.image = image;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.imgView = nil;
}

@end
