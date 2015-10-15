//
//  Setting.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/06/27.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "Setting.h"
#import "RNQAppDelegate.h"
#import "GenericMethods.h"

static const NSInteger logSet = 201;

@implementation Setting

@synthesize defaultLogLocate,defaultMacroLocate,tempLogLocate,tempMacroLocate;
@synthesize defaultFileListPreview,defaultSaveWin,defaultEndDialogOff,tempFileListPreview,tempProcessLockedFile,tempSaveWin,tempEndDialogOff;

//初期化
-(id)init{
    self = [super init];
    if (self) {
        //ユーザ設定の読み込み
        id defaults = [NSUserDefaults standardUserDefaults];
        defaultLogLocate = [defaults objectForKey:@"defaultLogLocate"];
        defaultMacroLocate = [defaults objectForKey:@"defaultMacroLocate"];
        tempLogLocate = [defaults objectForKey:@"logLocate"];
        tempMacroLocate = [defaults objectForKey:@"macroLocate"];
        defaultFileListPreview = [defaults objectForKey:@"defaultFileListPreview"];
        defaultSaveWin = [defaults objectForKey:@"defaultSaveWin"];
        defaultEndDialogOff = [[defaults objectForKey:@"defaultEndDialogOff"]intValue];
        tempFileListPreview = [defaults objectForKey:@"fileListPreview"];
        tempProcessLockedFile = [defaults objectForKey:@"processLockedFile"];
        tempSaveWin = [defaults objectForKey:@"saveWin"];
        tempEndDialogOff = [[defaults objectForKey:@"endDialogOff"]intValue];
        //初期設定の作成OR取得
        if (defaultLogLocate == nil) {
            [defaults setObject:[[GenericMethods pathToAppFolder] stringByAppendingPathComponent:@"Log"] forKey:@"defaultLogLocate"];
        }
        if (defaultMacroLocate == nil){
            [defaults setObject:[[GenericMethods pathToAppFolder] stringByAppendingPathComponent:@"Macro"] forKey:@"defaultMacroLocate"];
        }
        if (defaultFileListPreview == nil) {
            [defaults setObject:[NSNumber numberWithInt:1] forKey:@"defaultFileListPreview"];
        }
        if (defaultSaveWin == nil) {
            [defaults setObject:[NSNumber numberWithInt:1] forKey:@"defaultSaveWin"];
        }
        if (! defaultEndDialogOff) {
            [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"defaultEndDialogOff"];
        }
        //ユーザ設定が空の場合は初期設定と同じ値をセットする
        if (tempLogLocate == nil) {
            tempLogLocate = [defaults objectForKey:@"defaultLogLocate"];
            [defaults setObject:tempLogLocate forKey:@"logLocate"];
        }
        if (tempMacroLocate == nil) {
            tempMacroLocate = [defaults objectForKey:@"defaultMacroLocate"];
            [defaults setObject:tempMacroLocate forKey:@"macroLocate"];
        }
        if (tempProcessLockedFile == nil) {
            tempProcessLockedFile = [defaults objectForKey:@"defaultProcessLockedFile"];
            [defaults setObject:tempProcessLockedFile forKey:@"processLockedFile"];
        }
        if (tempFileListPreview == nil) {
            tempFileListPreview = [defaults objectForKey:@"defaultFileListPreview"];
            [defaults setObject:tempFileListPreview forKey:@"fileListPreview"];
        }
        if (tempSaveWin == nil) {
            [defaults setObject:tempSaveWin forKey:@"saveWin"];
        }
        if (! tempEndDialogOff) {
            [defaults setObject:[NSNumber numberWithInteger:tempEndDialogOff] forKey:@"endDialogOff"];
        }
    }
    return self;
}

-(void)awakeFromNib{
    [txtLogLocate setStringValue:tempLogLocate];
    [txtMacroLocate setStringValue:tempMacroLocate];
    [chkFileListPreview setState:[tempFileListPreview integerValue]];
    [chkSaveWin setState:[tempSaveWin integerValue]];
    [chkEndDialogOff setState:tempEndDialogOff];
}

//ログ保管場所を設定
- (IBAction)pshSetLogLocate:(id)sender {
    [self openPanel:[sender tag]];
}

//マクロファイル保管場所を設定
- (IBAction)pshSetMacroLocate:(id)sender {
    [self openPanel:[sender tag]];
}

//設定を更新
- (IBAction)pshUpdatePref:(id)sender {
    id defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tempLogLocate forKey:@"logLocate"];
    [defaults setObject:tempMacroLocate forKey:@"macroLocate"];
    tempFileListPreview = [NSNumber numberWithInteger:[chkFileListPreview state]];
    tempSaveWin = [NSNumber numberWithInteger:[chkSaveWin state]];
    tempEndDialogOff = [chkEndDialogOff state];
    [defaults setObject:tempFileListPreview forKey:@"fileListPreview"];
    [defaults setObject:tempProcessLockedFile forKey:@"processLockedFile"];
    [defaults setObject:tempSaveWin forKey:@"saveWin"];
    [defaults setObject:[NSNumber numberWithInteger:tempEndDialogOff] forKey:@"endDialogOff"];
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate endPrefWin];
}

//キャンセルボタンの処理
- (IBAction)pshCancel:(id)sender {
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate endPrefWin];
    [txtLogLocate setStringValue:tempLogLocate];
    [txtMacroLocate setStringValue:tempMacroLocate];
    [chkFileListPreview setState:[tempFileListPreview integerValue]];
    [chkSaveWin setState:[tempSaveWin integerValue]];
    [chkEndDialogOff setState:tempEndDialogOff];
}

//初期設定に戻す
- (IBAction)pshRestore:(id)sender {
    [txtLogLocate setStringValue:defaultLogLocate];
    [txtMacroLocate setStringValue:defaultMacroLocate];
    [chkFileListPreview setState:[defaultFileListPreview integerValue]];
    [chkSaveWin setState:[defaultSaveWin integerValue]];
    [chkEndDialogOff setState:defaultEndDialogOff];
}

//フォルダ選択ダイアログを開く
-(void)openPanel:(NSInteger)aTag{
    //選択するファイルの種類の設定
    NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO]; //ファイルの選択を不可に設定
    [openPanel setCanChooseDirectories:YES]; //フォルダの選択を可能に設定
    [openPanel setCanCreateDirectories:YES]; //新規フォルダを作成できるように設定
    [openPanel setAllowsMultipleSelection:NO]; //複数選択を不可に設定
    NSInteger pressedButton = [openPanel runModal];
    if( pressedButton == NSOKButton ){
        //パスを取得
        NSURL *filePath = [openPanel URL];
        if (aTag == logSet) {
            tempLogLocate = [filePath path];
            [txtLogLocate setStringValue:tempLogLocate];
        }else{
            tempMacroLocate = [filePath path];
            [txtMacroLocate setStringValue:tempMacroLocate];
        }
    }
    
}

- (id)initWithCoder:(NSCoder *)coder {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
}

@end