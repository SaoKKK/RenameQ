//
//  CCImageAndTextCell.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/10.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCImageAndTextCell : NSTextFieldCell{
@private
    NSImage *_image;
}

@property(readwrite, retain) NSImage *image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
