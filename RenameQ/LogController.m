//
//  LogController.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/28.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "LogController.h"
#import "Setting.h"
#import "RNQAppDelegate.h"

@implementation LogController

-(BOOL)createNewLog{
    //ログデータのファイル名を作成
    Setting *_setting = [[Setting alloc]init];
    id dirPath = [_setting tempLogLocate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dirPath]==NO) {
        //Logフォルダが存在しない場合は作成
       [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    NSString *fName = [NSString stringWithFormat:@"%@_log",[self createDateStr]];
    id path = [[dirPath stringByAppendingPathComponent:fName]stringByAppendingPathExtension:@"xml"];
    //ファイル名に重複があった場合はなくなるまでファイル名に連番を追加していく
    NSString *newfName = fName;
    int i = 1;
    while ([fileManager fileExistsAtPath:path]) {
        newfName = [NSString stringWithFormat:@"%@-%i",fName,i];
        path = [[dirPath stringByAppendingPathComponent:newfName]stringByAppendingPathExtension:@"xml"];
        i++;
    }
    //書き出しの実行
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate.dataList writeToFile:path atomically:YES];
    //データリストをクリア
    [appDelegate.dataList removeAllObjects];
    [appDelegate reloadTable];
    return YES;
}

-(void)setLogFileList{
    //ログリストを初期化
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate.logFileList removeAllObjects];
    [appDelegate.logList removeAllObjects];
    [appDelegate.filteredLog removeAllObjects];
    //ログフォルダのパスを取得
    Setting *_setting = [[Setting alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[_setting tempLogLocate]]) {
        NSString *logFile;
        //全ログファイルを取得
        NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:[_setting tempLogLocate] error:nil];
        for (logFile in logFiles) {
            //システムファイルを拒否
            if ([[logFile substringToIndex:1]isEqualToString:@"."]==NO) {
                NSMutableDictionary *logDic = [NSMutableDictionary dictionary];
                [logDic setObject:logFile forKey:@"fileName"];
                [logDic setObject:[[_setting tempLogLocate]stringByAppendingPathComponent:logFile] forKey:@"filePath"];
                [appDelegate.logFileList insertObject:logDic atIndex:0];
            }
        }
    }
}

//ログファイルの消去
-(void)removeLog:(NSMutableArray*)removeFiles{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    //エラーリストを初期化
    [appDelegate.errList removeAllObjects];
    BOOL bDone;
    int removedNum = 0;
    int errNum = 0;
    NSString *fileName;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in removeFiles) {
        bDone = [fileManager removeItemAtPath:filePath error:nil];
        //削除に失敗した場合エラーリストに追加処理
        if (bDone) {
            removedNum ++;
        } else {
            errNum ++;
            fileName = [filePath lastPathComponent];
            [data setObject:fileName forKey:@"orgName"];
            [data setObject:[NSNumber numberWithInt:5] forKey:@"errNum"];
            [data setObject:@"指定のパスが存在しない、その他" forKey:@"errMsg"];
            [appDelegate.errList addObject:data];
        }
    }
    NSString *endDialogText = [NSString stringWithFormat:@"削除済み：%i　エラー：%i",removedNum,errNum];
    [appDelegate showEndDialog:appDelegate.winLog saveErr:(BOOL)NO withText:endDialogText];
}

//エラー書き出し
-(BOOL)saveErrorLog{
    //デフォルトファイル名を作成
    NSString *fName = [NSString stringWithFormat:@"%@_err",[self createDateStr]];
    Setting *_setting = [[Setting alloc]init];
    //セーブパネルを開く
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSArray *FileType=[NSArray arrayWithObjects:@"xml",nil];
    [savePanel setAllowedFileTypes:FileType];
    [savePanel setDirectoryURL:[NSURL fileURLWithPath:_setting.tempLogLocate]];
    [savePanel setExtensionHidden:NO];
    [savePanel setNameFieldStringValue:fName];
    [savePanel setCanCreateDirectories:YES]; //フォルダ作成を可能に設定
    NSInteger pressedButton = [savePanel runModal];
    if( pressedButton == NSOKButton ){
        //パスを取得
        NSURL *filePath = [savePanel URL];
        RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
        [appDelegate.errList writeToFile:[filePath path] atomically:YES];
        return YES;
    }else{
        return NO;
    }
}

//日付文字列の作成
-(NSString*)createDateStr{
    //現在日時を取得
    NSDate *date = [NSDate date];
    //カスタム・フォーマッタ文字列を作成
    NSString *formatStr = @"yyyy-MM-dd HH-mm-ss";
    //日付フォーマッタを取得
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    //現在日時を文字列化する
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}
@end
