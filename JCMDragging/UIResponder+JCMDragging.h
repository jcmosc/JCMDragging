//
//  UIResponder+JCMDragging.h
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


#import <UIKit/UIKit.h>


@class JCMDragGestureRecognizer;


@interface UIResponder (JCMDragging)

- (void)dragEntered:(JCMDragGestureRecognizer *)drag fromView:(UIView *)fromView;  // fromView is the anscestor view the drag did move from if any
- (void)dragExited:(JCMDragGestureRecognizer *)drag toView:(UIView *)toView;       // toView is the anscestor view the drag will move to if any
- (void)dragUpdated:(JCMDragGestureRecognizer *)drag;
- (void)dragDropped:(JCMDragGestureRecognizer *)drag;
- (void)dragCancelled:(JCMDragGestureRecognizer *)drag;

// TODO: Implement this so that UIScrollView can autoscroll when the user is dragging near its edges
// - (BOOL)wantsPeriodicDragUpdates;

@end


@interface NSObject (UIResponderJCMDraggingActions)     // these methods are not implemented in NSObject

/*
 This method is invoked when a drag gesture is recognized. A subclass of UIResponder typically implements this method.
 Using the methods of the UIPasteboard class, it should convert the selection into an appropriate object (if necessary)
 and write that object to a pasteboard. It may also remove the selected object from the user interface and, if applicable,
 from the application's data model. If the selected object is also the source view and it is removed, this method MUST call
 deleteSourceView on sender. The command travels from the source view up the responder chain until it is handled; it is
 ignored if no responder handles it. If a responder doesn’t handle the command in the current context, it should pass it to
 the next responder.
 
 sender: the instance of JCMDragGestureRecognizer that recognized the drag gesture
 */
- (void)drag:(id)sender;


/*
 This method is invoked when a drag gesture is completed. A subclass of UIResponder typically implements this method.
 Using the methods of the UIPasteboard class, it should read the data in the pasteboard, convert the data into an
 appropriate internal representation (if necessary), and display it in the user interface. It may restore the source view
 if the source view was deleted when the drag gesture was recognized. If it restores the source view this method MUST call
 restoreSourceView on sender with the restored source view. The command travels from the destination view up the responder chain
 until it is handled; it is ignored if no responder handles it. If a responder doesn’t handle the command in the current
 context, it should pass it to the next responder.
 
 sender: the instance of JCMDragGestureRecognizer that recognized the drag gesture
 */
- (void)drop:(id)sender;

@end
