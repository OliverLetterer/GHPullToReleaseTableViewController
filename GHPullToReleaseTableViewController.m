//
//  GHPullToReleaseTableViewController.m
//  iGithub
//
//  Created by me on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullToReleaseTableViewController.h"
#import "GHTableViewCellWithLinearGradientBackgroundView.h"

static CGFloat const kGHPullToReleaseTableViewControllerDefaultAnimationDuration = 0.3f;

@implementation GHPullToReleaseTableViewController

@synthesize pullToReleaseHeaderView=_pullToReleaseHeaderView;
@synthesize pullToReleaseEnabled=_pullToReleaseEnabled;
@synthesize defaultEdgeInset=_defaultEdgeInset;
@synthesize lastUpdateDate=_lastUpdateDate;

#pragma mark - setters and getters

- (CGFloat)dragDistance {
    return kGHPullToReleaseTableHeaderViewPreferedHeaderHeight + _defaultEdgeInset.top;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    self.pullToReleaseHeaderView = [[GHPullToReleaseTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, - kGHPullToReleaseTableHeaderViewPreferedHeaderHeight - _defaultEdgeInset.top, 320.0f, kGHPullToReleaseTableHeaderViewPreferedHeaderHeight)];
    self.pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
    [self.tableView addSubview:self.pullToReleaseHeaderView];
    
    if (_isReloadingData) {
        self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateLoading;
        CGFloat dragDistance = -self.dragDistance;
        self.tableView.contentInset = UIEdgeInsetsMake(-dragDistance, 0.0f, 0.0f, 0.0f);
        [self.tableView setContentOffset:CGPointMake(0.0f, dragDistance) animated:YES];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _pullToReleaseHeaderView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark - PullImplementation

- (void)pullToReleaseTableViewReloadData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    CGFloat dragDistance = -self.dragDistance;
    
    _isReloadingData = YES;
    self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateLoading;
    
    if (!self.isViewLoaded) {
        return;
    }
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = UIEdgeInsetsMake(-dragDistance, 0.0f, 0.0f, 0.0f);
                     } 
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.tableView setContentOffset:CGPointMake(0.0f, dragDistance) animated:YES];
                         }
                     }];
}

- (void)pullToReleaseTableViewDidReloadData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    self.lastUpdateDate = [NSDate date];
    self.pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
    
    if (!self.isViewLoaded) {
        return;
    }
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = self.defaultEdgeInset;
                     } 
                     completion:^(BOOL finished) {
                         _isReloadingData = NO;
                         self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.pullToReleaseEnabled || scrollView != self.tableView) {
        return;
    }
    
    if (!_isReloadingData) {
        CGFloat dragDistance = -self.dragDistance;
        
        if (scrollView.contentOffset.y <= dragDistance) {
            [self pullToReleaseTableViewReloadData];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.pullToReleaseEnabled || scrollView != self.tableView) {
        return;
    }
    
    if (!_isReloadingData) {
        CGFloat dragDistance = -self.dragDistance;
        
        if (scrollView.contentOffset.y <= dragDistance) {
            self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateDraggedDown;
        } else {
            self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
        }
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.tableView.style forKey:@"tableViewStyle"];
    [encoder encodeBool:_pullToReleaseEnabled forKey:@"pullToReleaseEnabled"];
    [encoder encodeUIEdgeInsets:_defaultEdgeInset forKey:@"defaultEdgeInset"];
    [encoder encodeObject:_lastUpdateDate forKey:@"lastUpdateDate"];
    [encoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithStyle:[decoder decodeIntegerForKey:@"tableViewStyle"]])) {
        _pullToReleaseEnabled = [decoder decodeBoolForKey:@"pullToReleaseEnabled"];
        _defaultEdgeInset = [decoder decodeUIEdgeInsetsForKey:@"defaultEdgeInset"];
        _lastUpdateDate = [decoder decodeObjectForKey:@"lastUpdateDate"];
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
