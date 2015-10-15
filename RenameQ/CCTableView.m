//
//  CCTableView.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/06/30.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCTableView.h"
#import "DataController.h"

@implementation CCTableView

- (void)awakeFromNib{
    //Drag&Drop受付を設定
    [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    //インスタンス変数を初期化
    flgDragging = NO;
    
}

//フィールド上をドロップ可能なオブジェクトがドラッグ中かを判定
- (void)SetInDragging:(BOOL)flg{
    //ドラッグ中フラグを立てる
    flgDragging = flg;
    //強調表示制御のため強制再描画を要求
    [self setNeedsDisplay:YES];
}

// ドロップ可能領域にドラッグ中のマウスポインタが入った
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    [self SetInDragging:YES];
    return NSDragOperationGeneric;
}

// ドロップ可能領域をマウスが移動中
-(NSDragOperation)draggingUpdated: (id) sender{
    return NSDragOperationGeneric;
}

// ドロップ可能領域からドラッグ中のマウスポインタが外れた
-(void)draggingExited: (id) sender{
    [self SetInDragging:NO];
}

//ドロップ処理の実行
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    DataController* dataController = [[DataController alloc]init];
    [dataController setData:sender];
    [self reloadData];
    return YES;
}

//ドロップ処理完了
-(void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    [self SetInDragging:NO];
    return;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
        //フレーム枠強調表示
    if (flgDragging == YES) {
        [[NSColor selectedControlColor] set];
        NSFrameRectWithWidth(dirtyRect, 3.0);
    }
}

@end
