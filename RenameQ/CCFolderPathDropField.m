//
//  CCFolderPathDropField.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/08/26.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCFolderPathDropField.h"

@implementation CCFolderPathDropField

-(void)awakeFromNib{
    flgDragging = NO;
    //Drag&Drop受付を設定
    [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
}

-(void)dealloc{
    [dropDataList release];
    [super dealloc];
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
    //受付可能オブジェクトかをチェック
    BOOL bRet = [self bAccceptable:sender];
    //フォルダのみ受付
    if (bRet !=YES){
        return NSDragOperationNone;
    }
    [self SetInDragging:YES];
    return NSDragOperationGeneric;
}

// ドロップ可能領域からドラッグ中のマウスポインタが外れた
-(void)draggingExited: (id) sender
{
    [self SetInDragging:NO];
}

//ドロップ処理の実行
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    [self setStringValue:strFilePath];
    return YES;
}

//ドロップ処理完了
- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    [self SetInDragging:NO];
    return;
}

//ペーストボードからファイルリストを取得
-(void)fileListInDraggingInfo:(id)info{
    //ペーストボードオブジェクト取得
    NSPasteboard *pasteBd = [info draggingPasteboard];
    dropDataList = [[pasteBd propertyListForType:NSFilenamesPboardType]retain];
}

//ドロップ可能オブジェクトかどうかを判定
- (BOOL)bAccceptable:(id)info{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL bRet, bDir;
    
    //ファイル一覧をdropDataListにセット
    [self fileListInDraggingInfo:info];
    //複数ファイルを拒否
    if ([dropDataList count] > 1) {
        return NO;
    }
    strFilePath = [dropDataList objectAtIndex:0];
    bRet = [fileManager fileExistsAtPath:strFilePath isDirectory:&bDir];
    //フォルダのみ受付
    if (bDir) {
        return [self judgeDefyPath:strFilePath];
    }else{
        return NO;
    }
}

//処理を拒否するファイルか判定
-(BOOL)judgeDefyPath:(NSString*)path{
    BOOL bAct = YES;
    //パッケージを拒否
    if( [[NSWorkspace sharedWorkspace]isFilePackageAtPath:path]==YES){
        bAct = NO;
    }else if ([[path pathExtension]isEqualToString:@"app"]){
        //アプリケーションを拒否
        bAct = NO;
    }else if([[[path lastPathComponent]substringToIndex:1]isEqualToString:@"."]){
        //システムファイルを拒否
        bAct = NO;
    }
    return bAct;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)aRect{
    //NSTextFieldとしての描画を実行
    [super drawRect:aRect];
    //フレーム枠強調表示
    if (flgDragging) {
        [[NSColor selectedControlColor] set];
        NSFrameRectWithWidth(aRect, 2.0);
    }
}
@end
