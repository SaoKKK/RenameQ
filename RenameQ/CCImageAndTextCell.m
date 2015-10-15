//
//  CCImageAndTextCell.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/10.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCImageAndTextCell.h"
#import <AppKit/NSCell.h>

@implementation CCImageAndTextCell

- (id)init {
    if ((self = [super init])) {
        [self setLineBreakMode:NSLineBreakByTruncatingTail];
        [self setSelectable:YES];
    }
    return self;
}

- (void)dealloc {
    [_image release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    CCImageAndTextCell *cell = (CCImageAndTextCell *)[super copyWithZone:zone];
    cell->_image = [_image retain];
    return cell;
}

@synthesize image = _image;

- (NSSize)_imageSize {
    return NSMakeSize(16, 16);
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame {
    NSRect result;
    if (_image != nil) {
        result.size = [self _imageSize];
        result.origin = cellFrame.origin;
        result.origin.x += 3;
        result.origin.y += ceil((cellFrame.size.height - result.size.height) / 2);
    } else {
        result = NSZeroRect;
    }
    return result;
}

// We could manually implement expansionFrameWithFrame:inView: and drawWithExpansionFrame:inView: or just properly implement titleRectForBounds to get expansion tooltips to automatically work for us
- (NSRect)titleRectForBounds:(NSRect)cellFrame {
    NSRect result;
    if (_image != nil) {
        CGFloat imageWidth = [self _imageSize].width;
        result = cellFrame;
        result.origin.x += (3 + imageWidth);
        result.size.width -= (3 + imageWidth);
    } else {
        result = [super titleRectForBounds:cellFrame];
    }
    return result;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    [super editWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    [super selectWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if (_image != nil) {
        NSRect imageFrame = [self imageRectForBounds:cellFrame];
        [_image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        NSInteger newX = NSMaxX(imageFrame) + 3;
        cellFrame.size.width = NSMaxX(cellFrame) - newX;
        cellFrame.origin.x = newX;
    }
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
    if (_image != nil) {
        cellSize.width += [self _imageSize].width;
    }
    cellSize.width += 3;
    return cellSize;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    // If we have an image, we need to see if the user clicked on the image portion.
    if (_image != nil) {
        // This code closely mimics drawWithFrame:inView:
        NSSize imageSize = [self _imageSize];
        NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        // If the point is in the image rect, then it is a content hit
        if (NSMouseInRect(point, imageFrame, [controlView isFlipped])) {
            // We consider this just a content area. It is not trackable, nor it it editable text. If it was, we would or in the additional items.
            // By returning the correct parts, we allow NSTableView to correctly begin an edit when the text portion is clicked on.
            return NSCellHitContentArea;
        }
    }
    // At this point, the cellFrame has been modified to exclude the portion for the image. Let the superclass handle the hit testing at this point.
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}


@end
