//
//  CCToolButton.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/29.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "CCToolButton.h"
#import "RNQAppDelegate.h"
#import "DataController.h"
#import "Setting.h"
#import "LogController.h"
#import "MacroController.h"

static const int SelectDel = 106;
static const int AllDel = 107;
static const NSInteger SelectDel_macro = 108;
static const int ShowEndSheet = 200;

@implementation CCToolButton

-(id)init{
    self = [super init];
    if (self){
        enterFlg = NO;
    }
    return self;
}

-(void)awakeFromNib{
    [self createTrackingArea];
}

//マウスが領域内に入った
-(void)mouseEntered:(NSEvent *)theEvent{
    if ([self isEnabled]){
        [self iconSet:[self title] status:@"on"];
        [self setImage:[NSImage imageNamed:icnName]];
        enterFlg = YES;
    }
}

//マウスが領域内を出た
-(void)mouseExited:(NSEvent *)theEvent{
    [self iconSet:[self title] status:@"off"];
    [self setImage:[NSImage imageNamed:icnName]];
    enterFlg = NO;
}

//マウスダウン
-(void)mouseDown:(NSEvent *)theEvent{
    if ([self isEnabled]){
        [self iconSet:[self title] status:@"down"];
        [self setImage:[NSImage imageNamed:icnName]];
    }
}

//マウスアップ
-(void)mouseUp:(NSEvent *)theEvent{
    if (enterFlg) {
        [self btnAction:self.title];
    }
}
//ボタンアクション実処理
-(void)btnAction:(NSString*)actionName{
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([actionName isEqualToString:@"Preview"]) {
        //プレビューボタンが押された
        //入力チェック
        if ([appDelegate checkInput]) {
            //実処理
            DataController* dataController = [[DataController alloc]init];
            [dataController setNewName];
        }
    }else if ([actionName isEqualToString:@"Act"]){
        //実行ボタンが押された
        //入力チェック
        if ([appDelegate checkInput]) {
            //実処理
            DataController* dataController = [[DataController alloc]init];
            [dataController setNewName];
            [dataController changeFileName:ShowEndSheet];
        }
    }else if ([actionName isEqualToString:@"Prefr"]){
        //環境設定ボタンが押された
        [appDelegate showPrefWindow];
    }else if([actionName isEqualToString:@"Log"]){
        //ログ管理ボタンが押された
        LogController *logController = [[LogController alloc]init];
        [logController setLogFileList];
        [appDelegate showLogWin];
    }else if ([actionName isEqualToString:@"Save"]){
        //処理保存ボタンが押された
        //入力チェック
        if ([appDelegate checkInput]) {
            [appDelegate.pshOK_presetNameDialog setTag:0];
            [appDelegate showGetPresetName];
        }
    }else if ([actionName isEqualToString:@"SelectDel"]){
        //選択削除ボタンが押された
        [appDelegate showDialog:appDelegate.winLog actionName:SelectDel withText:@"この操作は取り消しできません。実行してよろしいですか？" withIcon:@"icnCaution"];
    }else if ([actionName isEqualToString:@"AllDel"]){
        //全消去ボタンが押された
        [appDelegate showDialog:appDelegate.winLog actionName:AllDel withText:@"この操作は取り消しできません。実行してよろしいですか？" withIcon:@"icnCaution"];
    }else if ([actionName isEqualToString:@"Restore"]){
        //復元ボタンが押された
        DataController* dataController = [[DataController alloc]init];
        [dataController restoreFileName:appDelegate.filteredLog];
    } else if ([actionName isEqualToString:@"MSet"]){
        //マクロパネル-セットボタンが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController setSettedPresets];
    } else if ([actionName isEqualToString:@"MUpdata"]){
        //マクロパネル-更新ボタンが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController updataPreset];
    } else if ([actionName isEqualToString:@"MGroup"]){
        //マクロパネル-グループ作成ボタンが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController addGroup:@"名称未設定" selectParent:NO haveParent:YES];
    } else if ([actionName isEqualToString:@"MNew"]){
        //マクロパネル-新規プリセット作成ボタンが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController addPreset:@"名称未設定" selectParent:NO haveParent:YES];
    } else if ([actionName isEqualToString:@"MCopy"]){
        //マクロパネル-プリセット複製ボタンが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController copyPreset];
    } else if ([actionName isEqualToString:@"MDel"]){
        //マクロパネル-プリセット削除ボタンが押された
        [appDelegate showDialog:appDelegate.winMacro actionName:SelectDel_macro withText:@"この操作は取り消しできません。実行してよろしいですか？" withIcon:@"icnCaution"];
    }
    [self iconSet:actionName status:@"off"];
    [self setImage:[NSImage imageNamed:icnName]];
}


//アイコン変更処理
- (void)iconSet:(NSString*)buttonName status:(NSString*)btnStatus{
    icnName = [NSString stringWithFormat:@"icn%@_%@",buttonName,btnStatus];
}

//トラッキング・エリアを設定
-(void)createTrackingArea{
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp;
    focusTrackingAreaOptions |= NSTrackingMouseEnteredAndExited;
    focusTrackingAreaOptions |= NSTrackingAssumeInside;
    focusTrackingAreaOptions |= NSTrackingInVisibleRect;
    
    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:focusTrackingAreaOptions owner:self userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
