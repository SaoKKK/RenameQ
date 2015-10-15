//
//  SettedPresetDS.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/05.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "SettedPresetDS.h"
#import "RNQAppDelegate.h"

#define BasicTableViewDragAndDropDataType @"BasicTableViewDragAndDropDataType"

@implementation SettedPresetDS

- (void)awakeFromNib{
    //ドラッグアンドドロップできるデータタイプを指定
    [tblSettedPreset registerForDraggedTypes:[NSArray arrayWithObjects:BasicTableViewDragAndDropDataType, nil]];
}

//行の選択状態の変更
-(void)tableViewSelectionDidChange:(NSNotification*)aNotification{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([[tblSettedPreset selectedRowIndexes]count]!=0) {
        [appDelegate.pshSelectDelPreset setEnabled:YES];
        [appDelegate.mnMacroSelectDel setEnabled:YES];
    }else{
        [appDelegate.pshSelectDelPreset setEnabled:NO];
        [appDelegate.mnMacroSelectDel setEnabled:NO];
    }
}

#pragma mark - NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSInteger count = appDelegate.settedPresets.count;
    return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    return [appD.settedPresets objectAtIndex:row];
}

#pragma mark - Drag Operation Method

//ドラッグ（ペーストボードに書き込む）を開始
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    dragRows = rowIndexes;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType] owner:self];
    [pboard setData:data forType:BasicTableViewDragAndDropDataType];
    return YES;
}

//ドロップを確認
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    //間へのドロップのみ認証
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
    if ([info draggingSource] == tblSettedPreset) {
        return NSDragOperationMove;
    }
    return NSDragOperationEvery;
}

//ドロップ受付開始
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSUInteger index = [dragRows firstIndex];
    while(index != NSNotFound) {
        //ドロップ先にドラッグ元のオブジェクトを挿入する
        if (row > appD.settedPresets.count) {
            [appD.settedPresets addObject:[appD.settedPresets objectAtIndex:index]];
        }else{
            [appD.settedPresets insertObject:[appD.settedPresets objectAtIndex:index] atIndex:row];
        }
        //ドラッグ元のオブジェクトを削除する
        if (index > row) {
            //indexを後ろにずらす
            [appD.settedPresets removeObjectAtIndex:index + 1];
        }else{
            [appD.settedPresets removeObjectAtIndex:index];
        }
        index = [dragRows indexGreaterThanIndex:index];
        row ++;
    }
    [appD reloadSettedMacro];
    return YES;
}

@end
