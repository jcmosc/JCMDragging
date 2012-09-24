//
//  UIResponder+JCMDragging.m
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


#import "UIResponder+JCMDragging.h"


@implementation UIResponder (JCMDragging)


#pragma mark - Handling drag events

- (void)dragEntered:(JCMDragGestureRecognizer *)drag didExitView:(UIView *)exitingView
{
    [self.nextResponder dragEntered:drag didExitView:exitingView];
}

- (void)dragExited:(JCMDragGestureRecognizer *)drag willEnterView:(UIView *)enteringView
{
    [self.nextResponder dragExited:drag willEnterView:enteringView];
}

- (void)dragUpdated:(JCMDragGestureRecognizer *)drag
{
    [self.nextResponder dragUpdated:drag];
}

- (void)dragDropped:(JCMDragGestureRecognizer *)drag
{
    [self.nextResponder dragDropped:drag];
}

- (void)dragCancelled:(JCMDragGestureRecognizer *)drag
{
    [self.nextResponder dragCancelled:drag];
}

@end
