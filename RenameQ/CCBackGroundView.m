//
//  CCBackGroundView.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/30.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCBackGroundView.h"

@implementation CCBackGroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    //描画色の設定
    NSColor *color = [NSColor colorWithCalibratedRed:0.92 green:0.92 blue:0.92 alpha:0.85];
    [color set];
    //塗りつぶし
	[NSBezierPath fillRect:dirtyRect];
}

@end
