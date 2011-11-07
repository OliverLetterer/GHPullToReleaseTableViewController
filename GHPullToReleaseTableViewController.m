//
//  GHPullToReleaseTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullToReleaseTableViewController.h"
#import "GHTableViewCellWithLinearGradientBackgroundView.h"

static CGFloat const kGHPullToReleaseTableViewControllerDefaultAnimationDuration = 0.3f;

@interface GHPullToReleaseTableViewController ()

@property (nonatomic, readonly) CGFloat minimumDragDistance;

@end



@implementation GHPullToReleaseTableViewController
@synthesize pullToReleaseHeaderView=_pullToReleaseHeaderView, pullToReleaseEnabled=_pullToReleaseEnabled, defaultEdgeInset=_defaultEdgeInset;
@synthesize lastUpdateDate=_lastUpdateDate;

#pragma mark - setters and getters

- (CGFloat)minimumDragDistance {
    return kGHPullToReleaseTableHeaderViewPreferedHeaderHeight + _defaultEdgeInset.top;
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate {
    if (lastUpdateDate != _lastUpdateDate) {
        _lastUpdateDate = lastUpdateDate;
        
        _pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    _pullToReleaseHeaderView = [[GHPullToReleaseTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, - kGHPullToReleaseTableHeaderViewPreferedHeaderHeight - _defaultEdgeInset.top, 320.0f, kGHPullToReleaseTableHeaderViewPreferedHeaderHeight)];
    [self.tableView addSubview:_pullToReleaseHeaderView];
    
    if (_isReloadingData) {
        self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateLoading;
        CGFloat dragDistance = -self.minimumDragDistance;
        self.tableView.contentInset = UIEdgeInsetsMake(-dragDistance, 0.0f, 0.0f, 0.0f);
        [self.tableView setContentOffset:CGPointMake(0.0f, dragDistance) animated:YES];
    } else {
        self.pullToReleaseHeaderView.lastUpdateDate = self.lastUpdateDate;
        self.tableView.contentInset = self.defaultEdgeInset;
        self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
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
    
    CGFloat dragDistance = -self.minimumDragDistance;
    
    _isReloadingData = YES;
    self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateLoading;
    
    if (!self.isViewLoaded) {
        return;
    }
    
    BOOL shouldScrollToTop = CGRectGetMinY(self.tableView.bounds) == -_defaultEdgeInset.top;
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = UIEdgeInsetsMake(-dragDistance, 0.0f, 0.0f, 0.0f);
                         if (shouldScrollToTop) {
                             self.tableView.contentOffset = CGPointMake(0.0f, dragDistance);
                         }
                     } completion:nil];
}

- (void)pullToReleaseTableViewDidReloadData {
    if (!self.pullToReleaseEnabled) {
        return;
    }
    
    self.lastUpdateDate = [NSDate date];
    
    if (!self.isViewLoaded) {
        _isReloadingData = NO;
        return;
    }
    
    [UIView animateWithDuration:kGHPullToReleaseTableViewControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.tableView.contentInset = self.defaultEdgeInset;
                     } 
                     completion:^(BOOL finished) {
                         _isReloadingData = NO;
                         self.pullToReleaseHeaderView.state = GHPullToReleaseTableHeaderViewStateNormal;
                         self.tableView.contentInset = self.defaultEdgeInset;
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.pullToReleaseEnabled || scrollView != self.tableView) {
        return;
    }
    
    if (!_isReloadingData) {
        CGFloat dragDistance = -self.minimumDragDistance;
        
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
        CGFloat dragDistance = -self.minimumDragDistance;
        
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
