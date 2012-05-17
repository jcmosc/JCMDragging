//
//  JCMDragGestureRecognizer.m
//  JCMDragging
//
//  Created by James Moschou on 15/05/12.
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


#import <UIKit/UIGestureRecognizerSubclass.h>

#import "JCMDragGestureRecognizer.h"

#import "UIResponder+JCMDragging.h"
#import "UIView+JCMDragging.h"


@interface UIResponder (JCMDragGestureRecognizer)

- (UIResponder *)responderThatCanPerformAction:(SEL)action withSender:(id)sender;

@end


@implementation UIResponder (JCMDragGestureRecognizer)

- (UIResponder *)responderThatCanPerformAction:(SEL)action withSender:(id)sender
{
    if ([self canPerformAction:action withSender:sender]) {
        return self;
    }
    return [self.nextResponder responderThatCanPerformAction:action withSender:sender];
}

@end


@interface JCMDragGestureRecognizer ()

@property (nonatomic, readwrite, strong) UIView *sourceView;
@property (nonatomic, readwrite, strong) UIView *destinationView;
@property (nonatomic, readwrite, strong) UIView *draggingView;

@property (nonatomic) CGPoint draggingViewCenterOffset;

@property (nonatomic) BOOL deleteSourceViewPermitted;
@property (nonatomic) BOOL restoreSourceViewPermitted;

@end


@implementation JCMDragGestureRecognizer

@synthesize sourceView, destinationView, draggingView, delegate;
@synthesize draggingViewCenterOffset, deleteSourceViewPermitted, restoreSourceViewPermitted;


#pragma mark - Initialization

// Designated initializer
- (id)init
{
    self = [super initWithTarget:self action:@selector(drag)];
    if (self) {
        
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [self init];
    [self addTarget:target action:action];
    return self;
}


#pragma mark - Dragging

- (void)drag
{
    switch (self.state) {
        case UIGestureRecognizerStateBegan: {
            
            // This will only be reached if the delegate returns YES from -gestureRecognizerShouldBegin:
            // By the end of this scope sourceView, destinationView and draggingView should all be set, or set to nil
            
            // The source view is always the view the gesture recognizer was originally attached to
            self.sourceView = self.view;
            
            // The dragging view will be nil if this delegate method is not implemented
            if ([self.delegate respondsToSelector:@selector(draggingViewForDragGestureRecognizer:)]) {
                self.draggingView = [self.delegate draggingViewForDragGestureRecognizer:self];
                NSAssert(self.draggingView, @"The view returned by delegate (%@) from method 'draggingViewForDragGestureRecognizer:' cannot be nil", self.delegate);
                NSAssert(![self.draggingView isKindOfClass:[UIWindow class]], @"The view returned by delegate (%@) from method 'draggingViewForDragGestureRecognizer:' cannot be an instance of the UIWindow class or a subclass of the UIWindow class", self.delegate);
                
                [self.draggingView addGestureRecognizer:self];
                self.draggingView.userInteractionEnabled = NO;  // So that hitTest:forDrag: does not return the dragging view
                
                CGPoint location = [self locationInView:self.draggingView.superview];
                self.draggingViewCenterOffset = CGPointMake(self.draggingView.center.x - location.x,
                                                            self.draggingView.center.y - location.y);
            }
            
            // Perform the drag logic
            // deleteSourceView may be called
            self.deleteSourceViewPermitted = YES;
            UIResponder *dragResponder = [self.sourceView responderThatCanPerformAction:@selector(drag:) withSender:self];
            [dragResponder drag:self];
            self.deleteSourceViewPermitted = NO;
            
            
            // XXX: Maybe leverage the first responder mechanism to determine whether destination views should receive drag events
            
            // XXX: Would there ever be a scenario where the key window would not contain the destination views?
            UIWindow *destinationWindow = [[UIApplication sharedApplication] keyWindow];
            self.destinationView = [destinationWindow hitTest:[self locationInView:destinationWindow] withDrag:self];
            [self.destinationView dragEntered:self fromView:nil];
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            
            // Update the dragging view position
            CGPoint location = [self locationInView:self.draggingView.superview];
            self.draggingView.center = CGPointMake(location.x + self.draggingViewCenterOffset.x, location.y + self.draggingViewCenterOffset.y);
            
            
            // Update the destination view
            UIView *initialView = self.destinationView;
            
            // Has the drag moved outside the destination view?
            UIView *toView = self.destinationView;
            while (toView && ![toView pointInside:[self locationInView:toView] withDrag:self]) {
                toView = toView.superview;
            }
            
            // The drag has moved outside the destination view
            if (toView != self.destinationView) {
                [self.destinationView dragExited:self toView:toView];
                
                // The closest anscestor or nil if none is the new destination view
                self.destinationView = toView;
            }
            
            // Has the drag moved inside a subview of the (new) destination view (or the window if no new destination view)?
            toView = [(self.destinationView ? self.destinationView : [[UIApplication sharedApplication] keyWindow]) hitTest:[self locationInView:self.destinationView] withDrag:self];
            
            // The drag has moved inside a subview of the (new) destination view
            if (toView != self.destinationView) {
                UIView *fromView = self.destinationView;
                self.destinationView = toView;
                [self.destinationView dragEntered:self fromView:fromView];
            }
            
            // The drag has just moved within the same destination view
            if (initialView == self.destinationView) {
                [self.destinationView dragUpdated:self];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            
            // Update the destination view first, since the drop: method may
            // remove it
            [self.destinationView dragDropped:self];
            
            // Perform the drop logic
            // restoreSourceView may be called
            self.restoreSourceViewPermitted = YES;
            UIResponder *dragResponder = [self.destinationView responderThatCanPerformAction:@selector(drop:) withSender:self];
            [dragResponder drop:self];
            self.restoreSourceViewPermitted = NO;
            
            // Transfer the gesture recognizer back to the source view if it exists or was restored
            if (self.sourceView) {
                [self.sourceView addGestureRecognizer:self];
            }
            
            if (self.draggingView != self.sourceView) {
                [self.draggingView removeFromSuperview];
            }
            self.draggingView = nil;
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default: {
            
            // Do not perform drop logic if the drag failed or was cancelled
            
            // Transfer the gesture recognizer back to the source view if it still exists
            // There is no opportunity to restore the source view if it was deleted, user data can still be recovered from the pasteboard, however this is not handled in a standard way
            // XXX: Perhaps there should be another delegate method that would allow the user interface to be updated in a consistent way
            if (self.sourceView) {
                [self.sourceView addGestureRecognizer:self];
            }
            
            if (self.draggingView && self.draggingView != self.sourceView) {
                [self.draggingView removeFromSuperview];
            }
            self.draggingView = nil;
            
            [self.destinationView dragCancelled:self];
        }
            break;
    }
}


#pragma mark - Deleting and restoring the source view

- (void)deleteSourceView
{
    NSAssert(self.deleteSourceViewPermitted, @"Attempting to delete sourceView from outside a 'drag:' action");
    NSAssert(self.draggingView, @"Cannot delete a source view from a drag gesture recognizer that has a nil dragging view");
    NSAssert(self.view != self.sourceView, @"Cannot delete a source view that is also the dragging view of a drag gesture recognizer");
    
    self.sourceView = nil;
}

- (void)restoreSourceView:(UIView *)newSourceView
{
    NSAssert(self.restoreSourceViewPermitted, @"Attempting to restore sourceView from outside a 'drop:' action");
    NSAssert(!self.sourceView, @"The source view must have been deleted using deleteSourceView from within a 'drag:' action first");
    NSAssert(newSourceView, @"Attempting to restore a nil source view");
    
    self.sourceView = newSourceView;
}


#pragma mark - Subclass methods

- (void)reset
{
    [super reset];
    
    self.sourceView = nil;
    self.destinationView = nil;
    self.draggingView = nil;
    
    self.draggingViewCenterOffset = CGPointZero;
    
    self.deleteSourceViewPermitted = NO;
    self.restoreSourceViewPermitted = NO;
}

@end
