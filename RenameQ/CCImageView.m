//
//  CCImageView.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/19.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCImageView.h"
#import "DataController.h"
#import "RNQAppDelegate.h"

static const int ShowEndSheet = 200;

@implementation CCImageView

-(void)awakeFromNib{
    //Drag&Drop受付を設定
    [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    //アイコンを変数にセット
    offIcon = [NSImage imageNamed:@"icnEasyAct_off"];
    onIcon = [NSImage imageNamed:@"icnEasyAct_on"];
}

// ドロップ可能領域にドラッグ中のマウスポインタが入った
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    if (self.isEnabled) {
    [self setImage:onIcon];
    }
    return NSDragOperationGeneric;
}

// ドロップ可能領域をマウスが移動中
-(NSDragOperation)draggingUpdated: (id) sender{
    return NSDragOperationGeneric;
}

// ドロップ可能領域からドラッグ中のマウスポインタが外れた
-(void)draggingExited: (id) sender{
    [self setImage:offIcon];
}

//ドロップ処理の実行
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    if (self.isEnabled) {
        RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
        if ([appDelegate checkInput]) {
            DataController* dataController = [[DataController alloc]init];
            [dataController setData:sender];
            [dataController setNewName];
            [dataController changeFileName:ShowEndSheet];
        }
    }
    return YES;
}

//ドロップ処理完了
-(void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    [self setImage:offIcon];
    return;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
