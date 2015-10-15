//
//  TableViewController.m
//  RenameQ
//
//  Created by os106_06 on 2014/06/29.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "TableViewController.h"
#import "RNQAppDelegate.h"

@implementation TableViewController

- (void)awakeFromNib{
    //セルの属性を設定
    NSBrowserCell* browserCell = [[NSBrowserCell alloc]init];
    [browserCell setLeaf:YES];
    [browserCell setFont:[NSFont systemFontOfSize:11]];
    [[table tableColumnWithIdentifier:@"orgName"]setDataCell:browserCell];
    NSButtonCell* buttonCell =[[NSButtonCell alloc]init];
    [buttonCell setButtonType:NSSwitchButton];
    [buttonCell setTitle:@""];
    [[table tableColumnWithIdentifier:@"chk"]setDataCell:buttonCell];
}

#pragma mark - NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    return appDelegate.dataList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSDictionary *data = [appDelegate.dataList objectAtIndex:row];
    //アイコン画像を設定
    NSString *filePath = [data objectForKey:@"orgPath"];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSImage *icon = [workspace iconForFile:filePath];
    [icon setSize:NSMakeSize(16, 16)];
    //日付の書式を表示用に変更
    id formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yy/MM/dd HH:mm"];
    NSString *cDate, *mDate;
    cDate = [formatter stringFromDate:[data objectForKey:@"cDate"]];
    mDate = [formatter stringFromDate:[data objectForKey:@"mDate"]];
    
    if ([[tableColumn identifier]isEqualToString:@"chk"]){
        return [data objectForKey:@"chk"];
    }else if ([[tableColumn identifier] isEqualToString:@"recID"]) {
        return [data objectForKey:@"recID"];
    } else if ([[tableColumn identifier] isEqualToString:@"orgName"]) {
        [[tableColumn dataCell] setImage:icon];
        return [data objectForKey:@"orgName"];
    } else if ([[tableColumn identifier] isEqualToString:@"cDate"]) {
        return cDate;
    } else if ([[tableColumn identifier] isEqualToString:@"mDate"]) {
        return mDate;
    } else {
        return [data objectForKey:@"newName"];
    }
}

//ユーザによる更新の受付
-(void)tableView:(NSTableView*)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    RNQAppDelegate* appdelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSDictionary *data = [appdelegate.dataList objectAtIndex:row];
    if ([[tableColumn identifier]isEqualToString:@"chk"]) {
        [data setValue:object forKey:@"chk"];
    }
}

//内容によってセルの色を変える
static NSColor*	_stripeColor = nil;

- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row{
    RNQAppDelegate* appdelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    _stripeColor=[NSColor colorWithCalibratedRed:200 green:0 blue:0 alpha:0.4];
    id obj = [appdelegate.dataList objectAtIndex:row];
    // errNumに0以外がセットされていた場合
    //セルの背景色を変える
    if (([[obj objectForKey:@"errNum"]intValue]!=0)&&([[obj objectForKey:@"chk"]intValue]==1)) {
        if ([[tableColumn identifier]isEqualToString:@"newName"]) {
            [cell setDrawsBackground:YES];
            [cell setBackgroundColor:_stripeColor];
        }else{
            [cell setDrawsBackground:NO];
        }
    }else{
        [cell setDrawsBackground:NO];
    }
}
@end
