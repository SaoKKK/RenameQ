//
//  CreatePageFolder.m
//  RenameQ
//
//  Created by os106_06 on 2014/08/28.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CreatePageFolder.h"
#import "RNQAppDelegate.h"

static const int inputErr = 104;

@implementation CreatePageFolder

-(id)init{
    self = [super init];
    if (self) {
        pgFolders = [[NSMutableArray alloc]init];
    }
    return self;
}

//最終番号が開始番号より小さくならないよう制御
- (IBAction)StartPgEdited:(id)sender {
    [stpStartNum setIntValue:[sender intValue]];
    [self setEndNumBiggerThenStartNum];
}
- (IBAction)stpStartNum:(id)sender {
    [txtStartNum setStringValue:[NSString stringWithFormat:@"%i",[sender intValue]]];
    [self setEndNumBiggerThenStartNum];
}
- (IBAction)incrementEdited:(id)sender {
    [stpIncrement setIntValue:[sender intValue]];
    [self setEndNumBiggerThenStartNum];
}
- (IBAction)stpIncrement:(id)sender {
    [txtIncrement setStringValue:[NSString stringWithFormat:@"%i",[sender intValue]]];
    [self setEndNumBiggerThenStartNum];
}
-(void)setEndNumBiggerThenStartNum{
    int startNum = [[txtStartNum stringValue]intValue];
    increment = [[txtIncrement stringValue]intValue];
    if ([[txtEndNum stringValue]intValue] < startNum + increment) {
        [txtEndNum setStringValue:[NSString stringWithFormat:@"%i",startNum + increment]];
        [stpEndNum setIntValue:startNum + increment];
    }
    [stpEndNum setMinValue:startNum + increment];
}

//実行ボタン
- (IBAction)pshOK:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([self createPgFolders]){
        for(NSDictionary *obj in pgFolders){
            if ([[obj objectForKey:@"errNum"]intValue]==0){
                [fileManager createDirectoryAtPath:[obj objectForKey:@"path"] withIntermediateDirectories:NO attributes:nil error:NULL];
            }
        }
        RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
        NSUInteger errNum = appDelegate.errList.count;
        NSUInteger createdNum = pgFolders.count - errNum;
        NSString *endDialogText = [NSString stringWithFormat:@"処理済み：%li　エラー：%li",createdNum,errNum];
        [appDelegate showEndDialog:winPgFolder saveErr:(BOOL)NO withText:endDialogText];
        [drawer close];
    }
}

//プレビューボタン
- (IBAction)pshPreview:(id)sender {
    if ([self createPgFolders]){
    //ドロワーを表示
    [drawer openOnEdge:NSMaxXEdge];
    }
}

//キャンセルボタン
- (IBAction)pshCancel:(id)sender {
    [winPgFolder close];
    [drawer close];
}

- (BOOL)createPgFolders{
    NSString *dirPath = [txtPath stringValue];
    figure = [[txtFigure stringValue]intValue];
    increment = [[txtIncrement stringValue]intValue];
    addToFront = [txtAddToFront stringValue];
    addToEnd = [txtAddToEnd stringValue];
    separator = [txtSeparator stringValue];
    BOOL inputErrFlg = NO;

    //入力チェック
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([dirPath isEqualTo:@""]){
        [appDelegate showDialog:winPgFolder actionName:inputErr withText:@"作成先のパスを指定してください" withIcon:@"icnCaution"];
        return NO;
    }
    NSRange txtSearchRange = [separator rangeOfString:@":"];
    if (txtSearchRange.location != NSNotFound) {
        inputErrFlg = YES;
    }
    txtSearchRange = [addToFront rangeOfString:@":"];
    if (txtSearchRange.location != NSNotFound) {
        inputErrFlg = YES;
    }
    txtSearchRange = [addToEnd rangeOfString:@":"];
    if (txtSearchRange.location != NSNotFound) {
        inputErrFlg = YES;
    }
    if (inputErrFlg) {
        [appDelegate showDialog:winPgFolder actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
        return NO;
    }
    //ページフォルダリストを作成
    [pgFolders removeAllObjects];
    [appDelegate.errList removeAllObjects];
    int cntPg = [[txtStartNum stringValue]intValue];
    int endPg = [[txtEndNum stringValue]intValue];
    
    while (cntPg <= endPg) {
        data = [NSMutableDictionary dictionary];
        switch ([popStartSpread indexOfSelectedItem]) {
            case 0: //単ページ
                [self SinglePgName:cntPg];
                [self chkPathExist:dirPath];
                [pgFolders addObject:data];
                cntPg = cntPg + increment;
                break;
            case 1: //見開き（開始ページ単ページ）
                if (cntPg == [[txtStartNum stringValue]intValue]){
                    //開始ページフォルダ作成
                    [self SinglePgName:cntPg];
                    [self chkPathExist:dirPath];
                    [pgFolders addObject:data];
                    cntPg ++;
                } else{
                    //見開きフォルダ作成
                    if (cntPg == endPg) {
                        //最終ページ単ページ
                        [self SinglePgName:cntPg];
                        [self chkPathExist:dirPath];
                        [pgFolders addObject:data];
                    } else {
                        [self spreadPgName:cntPg toEndPg:endPg];
                        [self chkPathExist:dirPath];
                        [pgFolders addObject:data];
                    }
                    cntPg = cntPg + increment + 1;
                }
                break;
            default: //見開き（開始ページ見開き）
                if (cntPg == endPg) {
                    //最終ページ単ページ
                    [self SinglePgName:cntPg];
                    [self chkPathExist:dirPath];
                    [pgFolders addObject:data];
                } else {
                    [self spreadPgName:cntPg toEndPg:endPg];
                    [self chkPathExist:dirPath];
                    [pgFolders addObject:data];
                }
                cntPg = cntPg + increment + 1;
                break;
        }
    }
    //エラーリストを作成
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"errNum == 1"];
    appDelegate.errList = [NSMutableArray arrayWithArray:[pgFolders filteredArrayUsingPredicate:predicate]];
    [tbPgFolders reloadData];
    return YES;
}

//単ページのフォルダ名を作成
- (void)SinglePgName:(int)pgNum{
    orgName = [NSMutableString stringWithFormat:@"%i",pgNum];
    orgName = [NSMutableString stringWithFormat:@"%@%@%@",addToFront,[self fillZero:orgName],addToEnd];
}

//見開きのフォルダ名を作成
- (void)spreadPgName:(int)pgNum toEndPg:(int)endPg{
    NSMutableString *startPgStr = [NSMutableString stringWithFormat:@"%i",pgNum];
    NSMutableString *endPgStr;
    if (endPg < pgNum + increment) {
        endPgStr = [NSMutableString stringWithFormat:@"%i",endPg];
    } else {
        endPgStr = [NSMutableString stringWithFormat:@"%i",pgNum + increment];
    }
    startPgStr = [self fillZero:startPgStr];
    endPgStr = [self fillZero:endPgStr];
    orgName = [NSMutableString stringWithFormat:@"%@%@%@%@%@",addToFront,startPgStr,separator,endPgStr,addToEnd];
}

//桁数分0を埋め込み
-(NSMutableString*)fillZero:(NSMutableString*)numStr{
    while (numStr.length < figure) {
        [numStr insertString:@"0" atIndex:0];
    }
    return numStr;
}

//重複の確認
-(void)chkPathExist:(NSString*)dirPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    path = [dirPath stringByAppendingPathComponent:orgName];
    [data setObject:orgName forKey:@"orgName"];
    [data setObject:path forKey:@"path"];
    if ([fileManager fileExistsAtPath:path]){
        [data setObject:[NSNumber numberWithInt:1] forKey:@"errNum"];
        [data setObject:@"同名のフォルダ／ファイルが存在" forKey:@"errMsg"];
    }else{
        [data setObject:[NSNumber numberWithInt:0] forKey:@"errNum"];
    }
}

#pragma mark - NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView{
    return [pgFolders count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *obj = [pgFolders objectAtIndex:row];
    return [obj objectForKey:[tableColumn identifier]];
}

//エラーのセルの色を変える
static NSColor*	_stripeColor = nil;

- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row{
    _stripeColor=[NSColor colorWithCalibratedRed:200 green:0 blue:0 alpha:0.4];
    NSDictionary *obj = [pgFolders objectAtIndex:row];
    // errNumに1がセットされていた場合
    if (([[obj objectForKey:@"errNum"]intValue]!=0)) {
            [cell setDrawsBackground:YES];
            [cell setBackgroundColor:_stripeColor];
    }else{
        [cell setDrawsBackground:NO];
    }
}
@end
