//
//  FilterViewController.h
//  Yelp
//
//  Created by Weiyan Lin on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;


@protocol FiltersViewControllerDelegate <NSObject>

-(void) filtersViewController:(FilterViewController *) filtersViewController didChangeFilters:(NSDictionary *)filters;


                               
@end
                               
@interface FilterViewController : UIViewController

@property (weak,nonatomic) id<FiltersViewControllerDelegate> delegate;


@end
