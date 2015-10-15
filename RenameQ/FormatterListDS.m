//
//  FormatterListDS.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/08/21.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "FormatterListDS.h"
#import "RNQAppDelegate.h"
#import "GenericMethods.h"

@implementation FormatterListDS

-(id)init{
    self = [super init];
    if (self){
        formatterList = [[NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"yyyy",@"formatterStr",@"年(4桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"yy",@"formatterStr",@"年(2桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"MM",@"formatterStr",@"月(2桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"M",@"formatterStr",@"月(1桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"dd",@"formatterStr",@"日(2桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"d",@"formatterStr",@"日(1桁表記)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"EEEE",@"formatterStr",@"曜日",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"E",@"formatterStr",@"曜日(省略形)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"a",@"formatterStr",@"午前か午後",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"hh",@"formatterStr",@"時間(12時間表記/2桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"h",@"formatterStr",@"時間(12時間表記/1桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"HH",@"formatterStr",@"時間(24時間表記/2桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"H",@"formatterStr",@"時間(12時間表記/1桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"mm",@"formatterStr",@"分(2桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"m",@"formatterStr",@"分(1桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"ss",@"formatterStr",@"秒2桁)",@"explanation",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"s",@"formatterStr",@"秒(1桁)",@"explanation",nil],

            nil]retain];
    }
    return self;
}

- (void)dealloc{
    [formatterList release];
    [super dealloc];
}

- (void)awakeFromNib
{
    //TableViewのターゲットを指定
    [tbFormatterList setTarget:self];
    // ダブルクリック時に呼ばれるメソッドを指定
    [tbFormatterList setDoubleAction:@selector(doubleAction:)];
    //テーブル表示を更新
    [tbFormatterList reloadData];
}

//行がダブルクリックされた
- (void)doubleAction:(id)sender
{
    if([tbFormatterList clickedRow]>= 0 ){
        NSString *addFormat = [[formatterList objectAtIndex:[tbFormatterList clickedRow]]objectForKey:@"formatterStr"];
        NSString *tempStr;
        //親ウインドウを取得
        RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
        if (appD.formatterDrawer.parentWindow == appD.window) {
            tempStr = [txtFormatterStr stringValue];
            [txtFormatterStr setStringValue:[tempStr stringByAppendingString:addFormat]];
            //カーソル位置をテキストフィールドの最後尾に設定
            [self setCursolToEnd:mainWin forTxtField:txtFormatterStr];
            [self updatePreview:txtFormatterStr];
        }else{
            tempStr = [appD.M_txtFormatter stringValue];
            [appD.M_txtFormatter setStringValue:[tempStr stringByAppendingString:addFormat]];
            //カーソル位置をテキストフィールドの最後尾に設定
            [self setCursolToEnd:appD.winMacro forTxtField:appD.M_txtFormatter];
            [self updatePreview:appD.M_txtFormatter];
        }
    }
}

//カーソル位置をテキストフィールドの最後尾に設定
- (void)setCursolToEnd:(NSWindow*)parentWin forTxtField:(NSTextField*)field{
    [parentWin makeFirstResponder:field];
    NSText* textEditor = [parentWin fieldEditor:YES forObject:field];
    NSRange range = {[[field stringValue] length], 0};
    [textEditor setSelectedRange:range];
}

- (IBAction)updatePreview:(id)sender {
    if (sender == txtFormatterStr) {
        dateStr = [GenericMethods dateString:[txtFormatterStr stringValue]];
        addToFront = [txtAddToFront stringValue];
        addToEnd = [txtAddToEnd stringValue];
        [txtSampleDate setStringValue:[NSString stringWithFormat:@"%@%@%@",addToFront,dateStr,addToEnd]];
    }else{
        RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
        dateStr = [GenericMethods dateString:[appD.M_txtFormatter stringValue]];
        addToFront = [appD.M_txtAddToFront_date stringValue];
        addToEnd = [appD.M_txtAddToEnd_date stringValue];
        [appD.M_txtSampleDate setStringValue:[NSString stringWithFormat:@"%@%@%@",addToFront,dateStr,addToEnd]];
    }
}

#pragma mark - NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView{
    return formatterList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* identifier = [tableColumn identifier];
    NSDictionary *data = [formatterList objectAtIndex:row];
    return [data objectForKey:identifier];
}

@end
