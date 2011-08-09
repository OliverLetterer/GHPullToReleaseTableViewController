//
//  GHPullToReleaseTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPullToReleaseTableHeaderView.h"

@interface GHPullToReleaseTableViewController : UITableViewController {
@private
    GHPullToReleaseTableHeaderView *_pullToReleaseHeaderView;
    
    BOOL _isReloadingData;
    BOOL _pullToReleaseEnabled;
    
    UIEdgeInsets _defaultEdgeInset;
    
    NSDate *_lastUpdateDate;
}

@property (nonatomic, readonly, retain) GHPullToReleaseTableHeaderView *pullToReleaseHeaderView;

@property (nonatomic, assign) BOOL pullToReleaseEnabled;

@property (nonatomic, assign) UIEdgeInsets defaultEdgeInset;

@property (nonatomic, retain) NSDate *lastUpdateDate;

- (void)pullToReleaseTableViewReloadData;           // override
- (void)pullToReleaseTableViewDidReloadData;        // call when done

@end
