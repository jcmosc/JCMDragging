# JCMDragging

JCMDragging is an iOS static library for drag and drop.

## Overview

The library has a minimal footprint, requires no set-up or initialization and leverages many existing UIKit patterns to appear as though it were a part of UIKit all along.

### JCMDragGestureRecognizer is the only concrete class

A JCMDragGestureRecognizer object recognizes a drag gesture and manages the delivery of dragging events to destination views during the lifetime of the drag.

A JCMDragGestureRecognizer object can be attached to any view, not necessarily the view to be moved during the drag gesture. In fact it is not required for any view to move position as a result of a drag gesture, although this common scenario is definitely supported.

### UIView hit-testing controls the delivery of dragging events
  
Every UIView object which can receive touch events will also receive dragging events, there is no need to individually register UIView objects as drop targets.

Use the category methods `-[UIView hitTest:withDrag:]` and `-[UIView pointInside:withDrag:]` to more precisely control the delivery of dragging events.

### The responder chain handles and forwards dragging events

Dragging events are delivered to the hit-tested view via the methods:

    - [UIResponder dragEntered:didExitView:]
    - [UIResponder dragExited:willEnterView:]
    - [UIResponder dragUpdated:]
    - [UIResponder dragDropped:]
    - [UIResponder dragCancelled:]
    
The default implementation of these methods is to forward the event to the next responder.

The border crossing event handlers receive an additional parameter indicating the corresponding destination view. This parameter can also be used to accurately interpret dragging events within complex view hierarchies.

### Share data using the UIPasteboard class

User data can be shared between a source location and a destination location using the UIPasteboard class. The library defines a new system pasteboard for this purpose, which can be accessed from the UIPasteboard class via `[UIPasteboard draggingPasteboard]`.

### UIResponder objects perform dragging commands

The library includes an informal protocol, which declares the methods `drag:` and `drop:` on the NSObject class. These methods complement those declared by the UIResponderStandardEditActions protocol, and can be used to implement commands invoked by a dragging action.

Implement the -[UIResponder canPerformAction:withSender:] to enable or disable dragging commands based on the context.

## Using JCMDragGestureRecognizer

The only requirement to use the library is to instantiate a JCMDragGestureRecognizer object and attach it to a view.

The JCMDragGestureRecognizer class is a subclass of UILongPressGestureRecognizer and can be configured accordingly. The class adds one optional method to its delegate protocol `-(UIView*)draggingViewForDragGestureRecognizer`. You must implement this method if you wish for the drag gesture to manipulate the position of view.

If implemented, the delegate method `-draggingViewForDragGestureRecognizer:` may return the view the gesture is attached to, any ancestor or descendant view of the gesture's view, or it can return a newly created view. The view returned by this method will follow the drag gesture.

Dragging events will be delivered automatically to destination views. Dragging commands will be invoked automatically on the relevant handlers.

## Code samples

### Handling dragging events

Dragging events are delivered automatically to destination views. A drag gesture enters a destination view when the gesture location enters the region defined by the UIView category method `-(BOOL)pointInside:withDrag:`. Likewise a drag gesture exists a destination view when the gesture location exits this region.

The default implementation of the dragging event handling methods is to forward the event up the responder chain. This means that if a destination view does not handle a dragging event potentially every superview or ancestor view will have the opportunity to handle the event instead. Most of the time this is the desired behaviour, however for complex view hierarchies it leads to situations where a destination view could receive extraneous entered and exited events each time the drag gesture enters or exits a subview or descendant view of the destination view.

The following example illustrates how to handle drag entered and exited events for a destination view (self) within a complex view hierarchy.

    - (void)dragEntered:(JCMDragGestureRecognizer *)drag didExitView:(UIView *)exitingView
    {
        if ([exitingView isDescendantOfView:self]) {
            
            // The gesture has entered a subview or descendant view of this view from within this view
            // You will usually simply return here since to avoid handling extraneous events
            
            return;
        }
        
        // The gesture has entered this view from outside this view
        // Change the state or appearance of this view to reflect the fact that a drag gesture is occurring within it here
    }

    - (void)dragExited:(JCMDragGestureRecognizer *)drag willEnterView:(UIView *)enteringView
    {
        if ([enteringView isDescendantOfView:self.view]) {
            
            // The gesture has exited a subview or descendant view of this view but is still within this view
            // You will usually simply return here since to avoid handling extraneous events
            
            return;
        }
        
        // The gesture has exited this view completely
        // Change the state or appearance of this view to reflect the fact that no drag gesture is occurring within it
    }

### Implementing the drag: and drop: commands

The drag: action is invoked on the source view (the view the drag gesture recogniser is originally attached to) or the next responder which can handle it. In the following example `drag:` is implemented by a UIViewController object which contains a table view.

    - (void)drag:(id)sender
    {
        // The sender is always the drag gesture recognizer
        JCMDragGestureRecognizer *drag = (JCMDragGestureRecognizer *)sender;
        
        // Determine which row (if any) the user dragged
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[drag locationInView:self.tableView]];
        if (indexPath) {
            UIPasteboard *pasteboard = [UIPasteboard draggingPasteboard];
            pasteboard.string = [self.dataModelArray objectAtIndex:indexPath.row];
            
            // In this example dragging a row represents a move operation, as opposed to a copy operation,
            // so remove the row from the table view. The actual drag gesture is represented by a newly created view
            // which was instantiated and set up in draggingViewForDragGestureRecognizer:.
            [self.dataModelArray removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            // If the drag gesture recognizer was attached to the UITableViewCell object which was just removed from the table view
            // the following method needs to be called to notify the drag gesture recognizer that its source view no longer exists
            // [sender deleteSourceView];
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
