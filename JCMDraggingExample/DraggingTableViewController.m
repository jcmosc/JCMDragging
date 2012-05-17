//
//  DraggingTableViewController.m
//  JCMDragging
//
//  Created by James Moschou on 17/05/12.
//  Copyright (c) 2012 James Moschou <james.moschou@gmail.com>
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//   
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//


#import "DraggingTableViewController.h"


static const NSUInteger DraggingTableViewControllerInitialItemsCount = 6;


@interface DraggingTableViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@end


@implementation DraggingTableViewController

@synthesize cellTitle;
@synthesize items;


#pragma mark - Managing the view

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JCMDragGestureRecognizer *dragGestureRecognizer = [[JCMDragGestureRecognizer alloc] init];
    dragGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:dragGestureRecognizer];
}


#pragma mark - Accessing the items array

- (NSMutableArray *)items
{
    if (!items) {
        items = [[NSMutableArray alloc] initWithCapacity:DraggingTableViewControllerInitialItemsCount];
        for (NSUInteger i = 0; i < DraggingTableViewControllerInitialItemsCount; i++) {
            [items addObject:[NSString stringWithFormat:@"%@ %d", self.cellTitle, i]];
        }
    }
    return items;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Drag gesture recognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // Since the gesture recognizer is attached to the table view, it must only
    // begin if the user drags an actual row and not empty space
    return (nil != [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]]);
}

- (UIView *)draggingViewForDragGestureRecognizer:(JCMDragGestureRecognizer *)dragGestureRecognizer
{
    // See: http://www.scott-sherwood.com/?p=514
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[dragGestureRecognizer locationInView:self.tableView]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // Create the dragging view, remove the cell
    UIGraphicsBeginImageContext(cell.contentView.bounds.size);
    [cell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *draggingView = [[UIView alloc] initWithFrame:imageView.frame];
    imageView.frame = draggingView.bounds;
    [draggingView addSubview:imageView];
    draggingView.backgroundColor = [UIColor blueColor];
    CGPoint center = [cell.superview convertPoint:cell.center toView:self.view.superview];
    [draggingView setCenter:center];
    
    [self.view.superview addSubview:draggingView];
    
    return draggingView;
}


#pragma mark - Dragging

- (void)drag:(id)sender
{
    JCMDragGestureRecognizer *drag = (JCMDragGestureRecognizer *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[drag locationInView:self.tableView]];
    if (indexPath) {
        UIPasteboard *pasteboard = [UIPasteboard draggingPasteboard];
        pasteboard.string = [self.items objectAtIndex:indexPath.row];
        
        [self.items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // This would be called here if the drag gesture recognizer was attached to the cell,
        // but instead it is attached to the table view
        // [drag deleteSourceView];
    }
}

- (void)drop:(id)sender
{
    JCMDragGestureRecognizer *drag = (JCMDragGestureRecognizer *)sender;
    
    NSString *item = [[UIPasteboard draggingPasteboard] string];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[drag locationInView:self.tableView]];
    if (indexPath) {
        [self.items insertObject:item atIndex:indexPath.row];
    } else {
        [self.items addObject:item];
    }
    [self.tableView reloadData];
}


#pragma mark - Responding to dragging events

- (void)dragEntered:(JCMDragGestureRecognizer *)drag fromView:(UIView *)fromView
{
    // Ignore drag entered events for subviews of the table view
    if ([fromView isDescendantOfView:self.view]) {
        return;
    }
    
    self.view.layer.borderWidth = 4.0f;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)dragExited:(JCMDragGestureRecognizer *)drag toView:(UIView *)toView
{
    // Ignore drag exited events for subviews of the table view
    if ([toView isDescendantOfView:self.view]) {
        return;
    }
    
    self.view.layer.borderWidth = 0.0f;
    self.view.layer.borderColor = NULL;
}

- (void)dragDropped:(JCMDragGestureRecognizer *)drag
{
    self.view.layer.borderWidth = 0.0f;
    self.view.layer.borderColor = NULL;
}


#pragma mark - view controller

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
