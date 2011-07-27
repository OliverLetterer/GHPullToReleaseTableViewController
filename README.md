# GHPullToReleaseTableViewController

**GHPullToReleaseTableViewController** is a *UITableViewController* subclass that supports pull to release/refresh like seen in Twitter.app.

## Why another Pull to release UITableViewController subclass?

* **GHPullToReleaseTableViewController** lets you _disable_ the the pull to release feature by just setting the property

    ```objective-c
    @property (nonatomic, assign) BOOL pullToReleaseEnabled;
    ```

* **GHPullToReleaseTableViewController** lets you specify a _defaultEdgeInset_

    ```objective-c
    @property (nonatomic, assign) UIEdgeInsets defaultEdgeInset;
    ```

If you have a shadow view that you are using as the header or footer view in a UITableView, you would want to specify the contentInset of the tableView. Current implementations of pull to release ViewController could not handle this.

## What you need to do

* Provide a the following Image in your Project

    PullToRefreshArrow.png

* subclass **GHPullToReleaseTableViewController** and implement the following instance method

```objective-c
- (void)pullToReleaseTableViewReloadData {
    // don't forget to call super
    [super pullToReleaseTableViewReloadData];
    // now reload your data
    ...
    // call
    // [self pullToReleaseTableViewDidReloadData];
    // when you have your data
}
```