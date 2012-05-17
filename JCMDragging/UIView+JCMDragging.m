//
//  UIView+JCMDragging.m
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


#import "UIView+JCMDragging.h"


@class JCMDragGestureRecognizer;


@implementation UIView (JCMDragging)


#pragma mark - Hit testing in a view

/*
 The rationale for implementing these methods instead of using the already
 existing -hitTest:withEvent: and pointInside:withEvent: is that applications
 may wish to specify a different dragging area than the area within which the
 view receives touch events. For example a UIButton object may extend its
 tappable area beyond its bounds, but then would only respond to dragging within
 its bounds.
 
 In order to use the ...withEvent: methods there would need to be a way to
 distinguish between ordinary touch events and dragging events from the UIEvent
 object.
 */

- (UIView *)hitTest:(CGPoint)point withDrag:(JCMDragGestureRecognizer *)drag
{
    // XXX: Some UIKit view classes override this method to return self. This
    //      behavior should be mirrored here.
    
    for (UIView *subview in self.subviews) {
        
        // Same as in -hitTest:withEvent:
        if (subview.hidden || !subview.userInteractionEnabled || subview.alpha < 0.01) {
            continue;
        }
        
        CGPoint subviewPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:subviewPoint withDrag:drag]) {
            return [subview hitTest:subviewPoint withDrag:drag];
        }
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withDrag:(JCMDragGestureRecognizer *)drag
{
    return CGRectContainsPoint(self.bounds, point);
}

@end
