//
//  DataController.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/11.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "DataController.h"
#import "RNQAppDelegate.h"
#import "stringController.h"
#import "LogController.h"
#import "Setting.h"

static const int ShowEndSheet = 200;
static const int ShowEndModal = 201;

@implementation DataController

-(id)init{
    self = [super init];
    if(self){
        cntData = 0;
    }
    return self;
}

-(void)setData:(id)info{
    strFilePath = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath;
    NSArray *tempDir;
    BOOL bDir;
    
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSMutableArray *dropDataSource;
    dropDataSource = [[NSMutableArray alloc]init];
    //ペーストボードオブジェクト取得
    NSPasteboard *pasteBd = [info draggingPasteboard];
    dropDataSource = [pasteBd propertyListForType:NSFilenamesPboardType];
    //dataListを初期化
    [appDelegate.dataList removeAllObjects];
    //新dataList作成
    for (int i=0; i<[dropDataSource count]; i++) {
        strFilePath = [dropDataSource objectAtIndex:i];
        //処理を拒否するファイルか判定
        if([self judgeDefyPath:strFilePath]==YES){
            [fileManager fileExistsAtPath:strFilePath isDirectory:&bDir];
            switch ([appDelegate.popTarget indexOfSelectedItem]) {
                case 0: //ファイルのみ
                    if (bDir==NO) {
                        [self createData:strFilePath];
                    }else{
                        if ([appDelegate.popTargetRange indexOfSelectedItem] == 1) {
                            tempDir = [fileManager contentsOfDirectoryAtPath:strFilePath error:nil];
                            for (int j=0; j<[tempDir count]; j++) {
                                tempPath = [strFilePath stringByAppendingPathComponent:[tempDir objectAtIndex:j]];
                                if ([self judgeDefyPath:tempPath]) {
                                    [fileManager fileExistsAtPath:tempPath isDirectory:&bDir];
                                    if (bDir==NO) {
                                        if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                            [self createData:tempPath];
                                        }
                                    }
                                }
                            }
                        }else if ([appDelegate.popTargetRange indexOfSelectedItem] == 2){
                            NSDirectoryEnumerator *dir_enum = [fileManager enumeratorAtPath:strFilePath];
                            while (tempPath = [dir_enum nextObject]) {
                                tempPath = [strFilePath stringByAppendingPathComponent:tempPath];
                                if ([self judgeDefyPath:tempPath]) {
                                    [fileManager fileExistsAtPath:tempPath isDirectory:&bDir];
                                    if (bDir==NO) {
                                        if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                            [self createData:tempPath];
                                        }
                                    }
                                }
                            }
                        }
                    }
                    break;
                case 1: //フォルダのみ
                    if (bDir==YES) {
                        [self createData:strFilePath];
                        if([appDelegate.popTargetRange indexOfSelectedItem] == 1){
                            tempDir = [fileManager contentsOfDirectoryAtPath:strFilePath error:nil];
                            for (int j=0; j<[tempDir count]; j++) {
                                tempPath = [strFilePath stringByAppendingPathComponent:[tempDir objectAtIndex:j]];
                                if ([self judgeDefyPath:tempPath]) {
                                    [fileManager fileExistsAtPath:tempPath isDirectory:&bDir];
                                    if (bDir==YES) {
                                        if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                            [self createData:tempPath];
                                        }
                                    }
                                }
                            }
                        }else if ([appDelegate.popTargetRange indexOfSelectedItem] == 2){
                            NSDirectoryEnumerator *dir_enum = [fileManager enumeratorAtPath:strFilePath];
                            while (tempPath=[dir_enum nextObject]) {
                                tempPath = [strFilePath stringByAppendingPathComponent:tempPath];
                                if ([self judgeDefyPath:tempPath]) {
                                    [fileManager fileExistsAtPath:tempPath isDirectory:&bDir];
                                    if (bDir==YES) {
                                        if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                            [self createData:tempPath];
                                        }
                                    }
                                }
                            }
                        }
                    }
                    break;
                default: //ファイルとフォルダ
                    if (bDir==YES) {
                        [self createData:strFilePath];
                        if([appDelegate.popTargetRange indexOfSelectedItem] == 1){
                            tempDir = [fileManager contentsOfDirectoryAtPath:strFilePath error:nil];
                            for (int j=0; j<[tempDir count]; j++) {
                                tempPath = [strFilePath stringByAppendingPathComponent:[tempDir objectAtIndex:j]];
                                if ([self judgeDefyPath:tempPath]) {
                                    if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                        [self createData:tempPath];
                                    }
                                }
                            }
                        }else if ([appDelegate.popTargetRange indexOfSelectedItem] == 2){
                            NSDirectoryEnumerator *dir_enum = [fileManager enumeratorAtPath:strFilePath];
                            while (tempPath=[dir_enum nextObject]) {
                                tempPath = [strFilePath stringByAppendingPathComponent:tempPath];
                                if ([self judgeDefyPath:tempPath]) {
                                    if ([dropDataSource indexOfObject:tempPath] == NSNotFound) {
                                        [self createData:tempPath];
                                    }
                                }
                            }
                        }
                    }else{
                        [self createData:strFilePath];
                    }
                    break;
            }
        }
    }
    if (appDelegate.dataList.count != 0) {
        [appDelegate activateToolButton:YES];
    }else{
        [appDelegate activateToolButton:NO];
    }
}

//ファイル情報ディクショナリを作成
-(void)createData:(NSString*)filePath{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSDictionary *fileInfo;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    //チェックボタンをON（デフォルト）にセット
    [data setObject:@"1" forKey:@"chk"];
    //IDをセット
    [data setObject:[NSNumber numberWithInt:cntData] forKey:@"recID"];
    //オリジナルファイルのフルパスをセット
    [data setObject:filePath forKey:@"orgPath"];
    //オリジナルファイル名をセット
    [data setObject:[filePath lastPathComponent] forKey:@"orgName"];
    //拡張子をセット
    [data setObject:[filePath pathExtension] forKey:@"extension"];
    //拡張子を除いたファイル名をセット
    [data setObject:[[filePath stringByDeletingPathExtension]lastPathComponent] forKey:@"dName"];
    //親パスをセット
    [data setObject:[filePath stringByDeletingLastPathComponent] forKey:@"parDir"];
    //ファイル作成日・更新日を取得
    fileInfo = [fileManager attributesOfItemAtPath:filePath error:nil];
    [data setObject:[fileInfo objectForKey:NSFileCreationDate] forKey:@"cDate"];
    [data setObject:[fileInfo objectForKey:NSFileModificationDate] forKey:@"mDate"];
    //エラー番号をセット
    [data setObject:@"0" forKey:@"errNum"];
    
    cntData += 1;
    [appDelegate.dataList addObject:data];
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

//テーブルのチェックボタン全ON/OFF
-(void)chkAll:(BOOL)state{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    for (id obj in appDelegate.dataList) {
        if (state) {
            [obj setObject:@"1" forKey:@"chk"];
        }else{
            [obj setObject:@"0" forKey:@"chk"];
        }
    }
    [appDelegate reloadTable];
}

//ファイルリストをソート
-(void)SortByKey:(NSInteger)key ascending:(NSInteger)asc{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSArray* keyArray = [NSArray arrayWithObjects:@"orgName",@"cDate",@"mDate",@"recID",nil];
    BOOL bAsc = YES;
    if (asc == 1) {bAsc = NO;}
    //ソート記述クラスを作成
    NSSortDescriptor* sortDesc;
    sortDesc = [[NSSortDescriptor alloc]initWithKey:[keyArray objectAtIndex:key] ascending:bAsc];
    //ソート記述クラスを配列にセット
    NSArray* sortDescArray;
    sortDescArray = [NSArray arrayWithObject:sortDesc];
    //ソート実行
    [appDelegate.dataList sortUsingDescriptors:sortDescArray];
    [appDelegate reloadTable];
}

//新ファイルネームを作成してファイルリストにセットする
-(void)setNewName{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    stringController* _stringController = [[stringController alloc]init];
    id cntNewPath = [NSCountedSet set];
    
    for (int i=0; i<[appDelegate.dataList count]; i++){
        NSMutableDictionary *data = [appDelegate.dataList objectAtIndex:i];
        //処理対象データか判定
        if ([[data objectForKey:@"chk"] intValue]==1) {
            //新ファイルネームを作成
            NSString *newName;
            if ([appDelegate.chkProtectExt state]) {
                newName = [_stringController createNewName:[data objectForKey:@"dName"] cntData:i];
                if (_stringController.errFlg==NO) {
                    if ([[data objectForKey:@"extension"]isNotEqualTo:@""]) {
                        newName = [newName stringByAppendingPathExtension:[data objectForKey:@"extension"]];
                    }
                }
            } else {
                newName = [_stringController createNewName:[data objectForKey:@"orgName"] cntData:i];
            }
            //新ファイルパスを作成
            NSString *parDir = [data objectForKey:@"parDir"];
            if ([appDelegate.chkCreateFolder state]) {
                //ファイル名変更後フォルダのパスを作成
                parDir = [parDir stringByAppendingPathComponent:@"ファイル名変更後"];
            }
            NSString *newPath = [parDir stringByAppendingPathComponent:newName];
            //新ファイルネームとパスをファイルリストにセット
            [data setObject:newName forKey:@"newName"];
            [data setObject:newPath forKey:@"newPath"];
            if ([_stringController errFlg]) {
                [data setObject:@"1" forKey:@"errNum"];
            }else{
                [data setObject:@"0" forKey:@"errNum"];
            }
            [cntNewPath addObject:newPath];
        }else{
            [data setObject:@"" forKey:@"newName"];
            [data setObject:@"" forKey:@"newPath"];
            [data setObject:@"" forKey:@"errNum"];
        }
    }
    
    //新ファイル間での重複をチェック
    for (id obj in appDelegate.dataList) {
        id newPath = [obj objectForKey:@"newPath"];
        if ([cntNewPath countForObject:newPath]==1){
            if ([fileManager fileExistsAtPath:newPath]){
                [obj setObject:[NSNumber numberWithInt:3] forKey:@"errNum"];
            }else{
                if ([[obj objectForKey:@"errNum"]isEqualToString:@""]) {
                    [obj setObject:[NSNumber numberWithInt:0] forKey:@"errNum"];
                }
            }
        }else{
            if ([[obj objectForKey:@"chk"]intValue]==1) {
                [obj setObject:[NSNumber numberWithInt:3] forKey:@"errNum"];
            }
        }
    }
    [appDelegate reloadTable];
}

//ファイル名変更処理
-(void)changeFileName:(int)endAction{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString *orgPath, *newPath;
    BOOL bHasChanged = NO;
    int errNum = 0;
    int changedNum = 0;
    //エラーリストを初期化
    [appDelegate.errList removeAllObjects];
    for (id obj in appDelegate.dataList){
        //処理対象ファイルかを判定
        if ([[obj objectForKey:@"chk"]intValue]==1){
            //エラー値をチェック
            if ([[obj objectForKey:@"errNum"]intValue]!=0) {
                [self setErrDic:[obj objectForKey:@"orgName"] errorCode:[obj objectForKey:@"errNum"]];
                errNum ++;
            }else{
                orgPath = [obj objectForKey:@"orgPath"];
                newPath = [obj objectForKey:@"newPath"];
                //別フォルダに移動の場合は移動先フォルダを作成
                if ([appDelegate.chkCreateFolder state]) {
                    id newDirPath = [[obj objectForKey:@"parDir"]stringByAppendingPathComponent:@"ファイル名変更後"];
                    if ([fileManager fileExistsAtPath:newDirPath]==NO) {
                        [fileManager createDirectoryAtPath:newDirPath withIntermediateDirectories:NO attributes:nil error:NULL];
                    }
                }
                if ([fileManager fileExistsAtPath:orgPath]) {
                    bHasChanged = [fileManager moveItemAtPath:orgPath toPath:newPath error:nil];
                } else {
                    [obj setObject:[NSNumber numberWithInt:2] forKey:@"errNum"];
                }
                if (bHasChanged == NO) {
                    errNum ++;
                    [obj setObject:[NSNumber numberWithInt:4] forKey:@"errNum"];
                }else{
                    changedNum ++;
                    [obj setObject:[NSNumber numberWithInt:0] forKey:@"errNum"];
                }
            }
        }else{
            [obj setObject:[NSNumber numberWithInt:4] forKey:@"errNum"];
            [self setErrDic:[obj objectForKey:@"orgName"] errorCode:[obj objectForKey:@"errNum"]];
        }
    }
    //ログデータ書き出しとファイルリストクリア
    LogController *logController = [[LogController alloc]init];
    [logController createNewLog];
    [appDelegate activateToolButton:NO];
    //終了処理-ダイアログの環境設定を読み込み
    Setting *_setting = [[Setting alloc]init];
    if (_setting.tempEndDialogOff == 0 || appDelegate.errList.count > 0) {
        NSString *endDialogText = [NSString stringWithFormat:@"リネーム済み：%i　エラー：%i",changedNum,errNum];
        if (endAction == ShowEndSheet) {
            //処理終了ダイアログシートを表示
            [appDelegate showEndDialog:appDelegate.window saveErr:YES withText:endDialogText];
        }else if (endAction == ShowEndModal){
            //処理終了モダルダイアログを表示
            [appDelegate showEndMDialog:YES withText:endDialogText];
        }
    }
}

//ファイル名復元処理
-(void)restoreFileName:(NSMutableArray*)srcList{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString *orgPath, *newPath;
    int errNum = 0;
    int changedNum = 0;
    //エラーリストを初期化
    [appDelegate.errList removeAllObjects];
    for (id obj in appDelegate.filteredLog){
        //処理対象ファイルかを判定
        if ([[obj objectForKey:@"chk"]intValue]==1){
            if ([[obj objectForKey:@"errNum"]intValue]!=0) {
                [self setErrDic:[obj objectForKey:@"newName"] errorCode:[NSNumber numberWithInt:5]];
                errNum ++;
            }else{
                orgPath = [obj objectForKey:@"orgPath"];
                newPath = [obj objectForKey:@"newPath"];
                //変更処理
                BOOL bHasChanged = NO;
                int index = [[obj objectForKey:@"recID"]intValue];
                if ([fileManager fileExistsAtPath:newPath]) {
                    bHasChanged = [fileManager moveItemAtPath:newPath toPath:orgPath error:nil];
                } else {
                    [obj setObject:[NSNumber numberWithInt:6] forKey:@"errNum"];
                    [[appDelegate.logList objectAtIndex:index]setObject:[NSNumber numberWithInt:6] forKey:@"errNum"];
                    [self setErrDic:[obj objectForKey:@"newName"] errorCode:[obj objectForKey:@"errNum"]];
                }
                if (bHasChanged == NO) {
                    errNum ++;
                }else{
                    [obj setObject:[NSNumber numberWithInt:5] forKey:@"errNum"];
                    [[appDelegate.logList objectAtIndex:index]setObject:[NSNumber numberWithInt:5] forKey:@"errNum"];
                    changedNum ++;
                }
            }
        }
    }
    //ログデータ書き出しとファイルリストクリア。
    [appDelegate.logList writeToFile:appDelegate.logPath atomically:YES];
    //終了ダイアログの表示
    NSString *endDialogText = [NSString stringWithFormat:@"リネーム済み：%i　エラー：%i",changedNum,errNum];
    [appDelegate showEndDialog:appDelegate.winLog saveErr:(BOOL)YES withText:endDialogText];
}

//エラーディクショナリに値をセット
-(void)setErrDic:(id)name errorCode:(id)errNum{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSMutableDictionary *errDic = [NSMutableDictionary dictionary];
    [errDic setObject:name forKey:@"orgName"];
    [errDic setObject:errNum forKey:@"errNum"];
    NSString *errMessage;
    switch ([errNum integerValue]) {
        case 1:
            errMessage = @"ファイル名に関するエラーです";
            break;
        case 2:
            errMessage = @"指定のパスが存在しません";
            break;
        case 3:
            errMessage = @"ファイル名が重複しています";
            break;
        case 5:
            errMessage = @"復元対象外のファイル";
            break;
        case 6:
            errMessage = @"復元時ファイルパスエラー";
            break;
        default: //4の場合
            errMessage = @"ユーザキャンセル、その他";
            break;
    }
    [errDic setObject:errMessage forKey:@"errMsg"];
    [appDelegate.errList addObject:errDic];
}
@end