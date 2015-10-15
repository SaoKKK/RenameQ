//
//  RNQAppDelegate.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/06/17.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "RNQAppDelegate.h"
#import "DataController.h"
#import "CCToolButton.h"
#import "LogListDS.h"
#import "LogController.h"
#import "Setting.h"
#import "MacroController.h"
#import "TreeModel.h"
#import "GenericMethods.h"

//ダイアログの終了処理セレクタ
static const int DIALOG_END	= 0;
static const int DIALOG_LogSelectDel = 1;
static const int DIALOG_LogAllDel = 2;
static const int DIALOG_macroSave_owN = 3;
static const int DIALOG_macroSave_owY = 4;
static const int DIALOG_macroCopy_owY = 10;
static const int DIALOG_macroCopy_owN = 12;
static const int DIALOG_macroSaveAs = 5;
static const int DIALOG_macroCopyAs = 11;
static const int DIALOG_MacroSelectDel = 6;
static const int eDIALOG_SaveError = 7;
static const int eDIALOG_OK = 8;
static const int eDIALOG_pfFolderOK = 9;
static const int mDIALOG_openFileErr = 13;
static const int mNameDidChangedOK = 14;
static const int mDIALOG_SaveError = 15;

static const NSInteger nameDidChangedOK = 101;
static const NSInteger logDidRemovedOK = 102;
static const NSInteger pgFolderDidCreated =103;
static const NSInteger inputErr = 104;
static const NSInteger renamePreset = 105;
static const NSInteger SelectDel = 106;
static const NSInteger AllDel = 107;
static const NSInteger SelectDel_macro = 108;
static const NSInteger copyPreset = 109;
static const NSInteger macroSaveAs = 110;
static const NSInteger macroCopyAs = 111;
static const NSInteger macroCopyAsOK = 112;

//リネーム処理終了後のアクションコード
static const int ShowEndModal = 201;

@implementation RNQAppDelegate
@synthesize window,winLog,genericDialog,winEndDialog;
//メイン・ウインドウOutlet
@synthesize chkCreateFolder,chkProtectExt,chkAll_logWin,popTarget,popTargetRange;
@synthesize pshRestore,mnLogAllDel,mnLogSelectDel,mnMacroSelectDel,mnMacroAllDel,mnMSet,mnMUpdata,mnMGroup,mnMNew,mnMCopy,mnMDel,mnReadPreset;
@synthesize popCommandList;
//指定文字列を追加タブOutlet
@synthesize txtAddStr,popAddToWhere,popAddToPoint,txtAddToPoint,chkPermitOverlap;
//指定文字列を削除タブOutlet
@synthesize txtDelStr,popDelPoint,chkDelCase,chkDelWidth;
//指定文字列検索置換タブOutlet
@synthesize txtFindStr,txtReplaceStr,chkReplaceCase,chkReplaceWidth;
//文字数指定削除タブOutlet
@synthesize popDelPoint_strCnt,txtDelCntStr,txtDelSPoint;
//連番処理タブOutlet
@synthesize popCommandRange_serialNum,txtAddToFront_serialNum,txtAddToEnd_serialNum,txtFirstNum,txtFigure,txtIncrement,popAddToWhere_serialNum,popAddToPoint_serialNum,txtAddToPoint_serialNum,chkPermitOverlap_serialNum;
//連番増減タブOutlet
@synthesize popNumLocate,txtNumStartPoint,txtNumFigure,txtNumIncrement;
//日付処理タブOutlet
@synthesize popCommandRange_date,popUsedDate,txtAddToFront_date,txtAddToEnd_date,txtFormatter,txtSampleDate,popAddToWhere_date,popAddToPoint_date,txtAddToPoint_date,chkPermitOverlap_date,txtAddToFront_par,txtAddToEnd_par;
//親フォルダタブOutlet
@synthesize txtDirPosition,popUseStr,popUsePoint,txtUseStart,txtUseLength,popAddToWhere_par,popAddToPoint_par,txtAddToPoint_par,chkPermitOverlap_par;
//区切り文字タブOutlet
@synthesize popSeparator,txtSeparator,txtRep_sep;
//テキスト整形タブOutlet
@synthesize popFormText;
//マクロ処理タブOutlet
@synthesize tblSettedPreset,pshSelectDelPreset,pshAllDelPreset;
//フォーマッタ記述子一覧
@synthesize formatterDrawer;
//マクロパネルOutlet
@synthesize winMacro,macroView,M_popCommand,treeController;
//プリセット名取得ダイアログOutlet
@synthesize pshOK_presetNameDialog;
//その他の変数
@synthesize dataList,errList,logFileList,logList,filteredLog,formatterList,commandList,settedPresets,contents,orgPresetFile,newfName,allPresets;
@synthesize originX,originY,originW,originH,fileListPreview;
@synthesize srcField;

#pragma mark - Initialize
//初期化
-(id)init{
    self = [super init];
    if (self) {
        dataList = [[NSMutableArray array]retain];
        errList = [[NSMutableArray array]retain];
        commandList = [[NSMutableArray array]retain];
        contents = [[NSMutableArray array]retain];
        settedPresets = [[NSMutableArray array]retain];
        logFileList = [[NSMutableArray array]retain];
        allPresets = [[NSMutableArray array]retain];
        id defaults = [NSUserDefaults standardUserDefaults];
        fileListPreview = [[defaults objectForKey:@"fileListPreview"]intValue];
        bCommandValidity = [[defaults objectForKey:@"bCommandValidity"]intValue];
        if (bCommandValidity) {
            //コマンドリスト有効フラグが真であれば、コマンドリストをデータから読み込む
            commandList = [[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"savedCommand" ofType: @"array"]]retain];
        }
        bOpenFile = NO;
    }
    return self;
}

- (void)dealloc{
    [dataList release];
    [errList release];
    [commandList release];
    [settedPresets release];
    [logFileList release];
    [contents release];
    [allPresets release];
    [super dealloc];
}

#pragma mark - Application Controll
//アプリケーション起動時
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    //ウインドウの初期表示を設定
    NSRect screenFrame = [[NSScreen mainScreen]visibleFrame];
    Setting *_setting = [[Setting alloc]init];
    if([_setting.tempSaveWin integerValue]==1){
        //ウインドウを前回終了時の状態に復元
        id defaults = [NSUserDefaults standardUserDefaults];
        //処理の対象
        [popTarget selectItemAtIndex:[[defaults objectForKey:@"value_popTarget"]integerValue]];
        //処理範囲
        [popTargetRange selectItemAtIndex:[[defaults objectForKey:@"value_popTargetRange"]integerValue]];
        //処理の種類
        [popCommandList selectItemAtIndex:[[defaults objectForKey:@"value_popCommandList"]integerValue]];
        if ([[defaults objectForKey:@"value_popCommandList"]integerValue] > 10) {
            [tabCommand selectTabViewItemAtIndex:10];
            [pshSavePreset setEnabled:NO];
        } else {
            [tabCommand selectTabViewItemAtIndex:[popCommandList indexOfSelectedItem]];
        }
        //拡張子を保護
        [chkProtectExt setState:[[defaults objectForKey:@"value_chkProtectExt"]integerValue]];
        //変更ファイルを別フォルダに移動
        [chkCreateFolder setState:[[defaults objectForKey:@"value_chkCreateFolder"]integerValue]];
        //指定文字列追加タブOutlet
        [txtAddStr setStringValue:[defaults objectForKey:@"value_txtAddStr"]];
        [popAddToWhere selectItemAtIndex:[[defaults objectForKey:@"value_popAddToWhere"]integerValue]];
        if([[defaults objectForKey:@"value_popAddToWhere"]integerValue]==2){
            [popAddToPoint setEnabled:YES];
            [txtAddToPoint setEnabled:YES];
            [stpAddToPoint setEnabled:YES];
        } else {
            [popAddToPoint setEnabled:NO];
            [txtAddToPoint setEnabled:NO];
            [stpAddToPoint setEnabled:NO];
        }
        [popAddToPoint selectItemAtIndex:[[defaults objectForKey:@"value_popAddToPoint"]integerValue]];
        [chkPermitOverlap setState:[[defaults objectForKey:@"value_chkPermitOverlap"]integerValue]];
        [txtAddToPoint setStringValue:[defaults objectForKey:@"value_txtAddToPoint"]];
        //指定文字列削除タブOutlet
        [txtDelStr setStringValue:[defaults objectForKey:@"value_txtDelStr"]];
        [popDelPoint selectItemAtIndex:[[defaults objectForKey:@"value_popDelPoint"]integerValue]];
        [chkDelCase setState:[[defaults objectForKey:@"value_chkDelCase"]integerValue]];
        [chkDelWidth setState:[[defaults objectForKey:@"value_chkDelWidth"]integerValue]];
        //検索置換タブOutlet
        [txtFindStr setStringValue:[defaults objectForKey:@"value_txtFindStr"]];
        [txtReplaceStr setStringValue:[defaults objectForKey:@"value_txtReplaceStr"]];
        [chkReplaceCase setState:[[defaults objectForKey:@"value_chkReplaceCase"]integerValue]];
        [chkReplaceWidth setState:[[defaults objectForKey:@"value_chkReplaceWidth"]integerValue]];
        //位置指定削除タブOutlet
        [popDelPoint_strCnt selectItemAtIndex:[[defaults objectForKey:@"value_popDelPoint_strCnt"]integerValue]];
        [txtDelSPoint setStringValue:[defaults objectForKey:@"value_txtDelSPoint"]];
        [txtDelCntStr setStringValue:[defaults objectForKey:@"value_txtDelCntStr"]];
        //連番処理タブOutlet
        [popCommandRange_serialNum selectItemAtIndex:[[defaults objectForKey:@"value_popCommandRange_serialNum"]integerValue]];
        [popAddToWhere_serialNum selectItemAtIndex:[[defaults objectForKey:@"value_popAddToWhere_serialNum"]integerValue]];
        [popAddToPoint_serialNum selectItemAtIndex:[[defaults objectForKey:@"value_popAddToPoint_serialNum"]integerValue]];
        [txtAddToPoint_serialNum setStringValue:[defaults objectForKey:@"value_txtAddToPoint_serialNum"]];
        [chkPermitOverlap_serialNum setState:[[defaults objectForKey:@"value_chkPermitOverlap_serialNum"]integerValue]];
        [txtAddToFront_serialNum setStringValue:[defaults objectForKey:@"value_txtAddToFront_serialNum"]];
        [txtAddToEnd_serialNum setStringValue:[defaults objectForKey:@"value_txtAddToEnd_serialNum"]];
        [txtFirstNum setStringValue:[defaults objectForKey:@"value_txtFirstNum"]];
        [txtFigure setStringValue:[defaults objectForKey:@"value_txtFigure"]];
        [txtIncrement setStringValue:[defaults objectForKey:@"value_txtIncrement"]];
        if ([popCommandRange_serialNum indexOfSelectedItem]==1) {
            [popAddToWhere_serialNum setEnabled:YES];
            [chkPermitOverlap_serialNum setEnabled:YES];
            if ([popAddToWhere_serialNum indexOfSelectedItem]==2) {
                [popAddToPoint_serialNum setEnabled:YES];
                [txtAddToPoint_serialNum setEnabled:YES];
                [stpAddToPoint_serialNum setEnabled:YES];
            }else{
                [popAddToPoint_serialNum setEnabled:NO];
                [stpAddToPoint_serialNum setEnabled:NO];
                [txtAddToPoint_serialNum setEnabled:NO];
            }
        }else{
            [popAddToWhere_serialNum setEnabled:NO];
            [chkPermitOverlap_serialNum setEnabled:NO];
            [popAddToPoint_serialNum setEnabled:NO];
            [stpAddToPoint_serialNum setEnabled:NO];
            [txtAddToPoint_serialNum setEnabled:NO];
            [chkPermitOverlap_serialNum setEnabled:NO];
        }
        //連番増減タブOutlet
        [popNumLocate selectItemAtIndex:[[defaults objectForKey:@"value_popNumLocate"]integerValue]];
        [txtNumStartPoint setStringValue:[defaults objectForKey:@"value_txtNumStartPoint"]];
        [txtNumFigure setStringValue:[defaults objectForKey:@"value_txtNumFigure"]];
        [txtNumIncrement setStringValue:[defaults objectForKey:@"value_txtNumIncrement"]];
        //日付処理タブOutlet
        [popCommandRange_date selectItemAtIndex:[[defaults objectForKey:@"value_popCommandRange_date"]integerValue]];
        [popAddToWhere_date selectItemAtIndex:[[defaults objectForKey:@"value_popAddToWhere_date"]integerValue]];
        [chkPermitOverlap_date setState:[[defaults objectForKey:@"value_chkPermitOverlap_date"]integerValue]];
        [popAddToPoint_date selectItemAtIndex:[[defaults objectForKey:@"value_popAddToPoint_date"]integerValue]];
        [txtAddToPoint_date setStringValue:[defaults objectForKey:@"value_txtAddToPoint_date"]];
        [popUsedDate selectItemAtIndex:[[defaults objectForKey:@"value_popUsedDate"]integerValue]];
        [txtAddToFront_date setStringValue:[defaults objectForKey:@"value_txtAddToFront_date"]];
        [txtAddToEnd_date setStringValue:[defaults objectForKey:@"value_txtAddToEnd_date"]];
        [txtFormatter setStringValue:[defaults objectForKey:@"value_txtFormatter"]];
        [txtSampleDate setStringValue:[defaults objectForKey:@"value_txtSampleDate"]];
        if ([popCommandRange_date indexOfSelectedItem]==1) {
            [popAddToWhere_date setEnabled:YES];
            [chkPermitOverlap_date setEnabled:YES];
            if ([popAddToWhere_date indexOfSelectedItem]==2){
                [popAddToPoint_date setEnabled:YES];
                [txtAddToPoint_date setEnabled:YES];
                [stpAddToPoint_date setEnabled:YES];
            }else{
                [popAddToPoint_date setEnabled:NO];
                [txtAddToPoint_date setEnabled:NO];
                [stpAddToPoint_date setEnabled:NO];
            }
        }else{
            [popAddToWhere_date setEnabled:NO];
            [chkPermitOverlap_date setEnabled:NO];
            [popAddToPoint_date setEnabled:NO];
            [stpAddToPoint_date setEnabled:NO];
            [txtAddToPoint_date setEnabled:NO];
        }
        //親フォルダタブOutlet
        [txtDirPosition setStringValue:[defaults objectForKey:@"value_txtDirPosition"]];
        [popUseStr selectItemAtIndex:[[defaults objectForKey:@"value_popUseStr"]integerValue]];
        [popUsePoint selectItemAtIndex:[[defaults objectForKey:@"value_popUsePoint"]integerValue]];
        [txtUseStart setStringValue:[defaults objectForKey:@"value_txtUseStart"]];
        [txtUseLength setStringValue:[defaults objectForKey:@"value_txtUseLength"]];
        [txtAddToFront_par setStringValue:[defaults objectForKey:@"value_txtAddToFront_par"]];
        [txtAddToEnd_par setStringValue:[defaults objectForKey:@"value_txtAddToEnd_par"]];
        [popAddToWhere_par selectItemAtIndex:[[defaults objectForKey:@"value_popAddToWhere_par"]integerValue]];
        [popAddToPoint_par selectItemAtIndex:[[defaults objectForKey:@"value_popAddToPoint_par"]integerValue]];
        [txtAddToPoint_par setStringValue:[defaults objectForKey:@"value_txtAddToPoint_par"]];
        [chkPermitOverlap_par setState:[[defaults objectForKey:@"value_chkPermitOverlap_par"]integerValue]];
        [self popUseStr:popUseStr];
        //区切り文字タブOutlet
        [popSeparator selectItemAtIndex:[[defaults objectForKey:@"value_popSeparator"]integerValue]];
        [txtSeparator setStringValue:[defaults objectForKey:@"value_txtSeparator"]];
        [txtRep_sep setStringValue:[defaults objectForKey:@"value_txtRep_sep"]];
        [self popSeparator:popSeparator];
        //テキスト整形タブOutlet
        [popFormText selectItemAtIndex:[[defaults objectForKey:@"value_popFormText"]integerValue]];
        //マクロタブOutlet
        settedPresets = [[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settedPresets" ofType: @"array"]]retain];
        [self reloadSettedMacro];
        [self popAddToWhere_par:popAddToWhere_par];
    }
    if (fileListPreview == 1) {
        originY = screenFrame.size.height - 540;
        [window setFrame:NSMakeRect(0, originY, 638, 540) display:YES];
        [window setMaxSize:NSMakeSize(2000,1000)];
        [window setMinSize:NSMakeSize(638, 540)];
        [boxFileList setHidden:NO];
        [imgEasyAct setEnabled:NO];
        [discDisplayFileList setState:NSOnState];
    } else {
        originY = screenFrame.size.height - 289;
        [window setFrame:NSMakeRect(0, originY, 638, 289) display:YES];
        [window setMaxSize:NSMakeSize(638,289)];
        [boxFileList setHidden:YES];
        [imgEasyAct setEnabled:YES];
        [discDisplayFileList setState:NSOffState];
    }
    if (! bOpenFile) {
        [window makeKeyAndOrderFront:self];
    }
}

//アプリケーション終了時
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
    Setting *_setting = [[Setting alloc]init];
    id defaults = [NSUserDefaults standardUserDefaults];
    if ([_setting.tempSaveWin integerValue] == 1){
        //各アウトレットの状態を保存
        //処理の対象
        [defaults setObject:[NSNumber numberWithInteger:[popTarget indexOfSelectedItem]] forKey:@"value_popTarget"];
        //処理範囲
        [defaults setObject:[NSNumber numberWithInteger:[popTargetRange indexOfSelectedItem]] forKey:@"value_popTargetRange"];
        //処理の種類
        [defaults setObject:[NSNumber numberWithInteger:[popCommandList indexOfSelectedItem]] forKey:@"value_popCommandList"];
        //拡張子を保護
        [defaults setObject:[NSNumber numberWithInteger:[chkProtectExt state]] forKey:@"value_chkProtectExt"];
        //変更ファイルを別フォルダに移動
        [defaults setObject:[NSNumber numberWithInteger:[chkCreateFolder state]] forKey:@"value_chkCreateFolder"];
        //指定文字列追加タブOutlet
        [defaults setObject:[txtAddStr stringValue] forKey:@"value_txtAddStr"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToWhere indexOfSelectedItem]] forKey:@"value_popAddToWhere"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToPoint indexOfSelectedItem]] forKey:@"value_popAddToPoint"];
        [defaults setObject:[txtAddToPoint stringValue] forKey:@"value_txtAddToPoint"];
        [defaults setObject:[NSNumber numberWithInteger:[chkPermitOverlap state]] forKey:@"value_chkPermitOverlap"];
        //指定文字列削除タブOutlet
        [defaults setObject:[txtDelStr stringValue] forKey:@"value_txtDelStr"];
        [defaults setObject:[NSNumber numberWithInteger:[popDelPoint indexOfSelectedItem]] forKey:@"value_popDelPoint"];
        [defaults setObject:[NSNumber numberWithInteger:[chkDelCase state]] forKey:@"value_chkDelCase"];
        [defaults setObject:[NSNumber numberWithInteger:[chkDelWidth state]] forKey:@"value_chkDelWidth"];
        //検索置換タブOutlet
        [defaults setObject:[txtFindStr stringValue] forKey:@"value_txtFindStr"];
        [defaults setObject:[txtReplaceStr stringValue] forKey:@"value_txtReplaceStr"];
        [defaults setObject:[NSNumber numberWithInteger:[chkReplaceCase state]] forKey:@"value_chkReplaceCase"];
        [defaults setObject:[NSNumber numberWithInteger:[chkReplaceWidth state]] forKey:@"value_chkReplaceWidth"];
        //位置指定削除タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popDelPoint_strCnt indexOfSelectedItem]] forKey:@"value_popDelPoint_strCnt"];
        [defaults setObject:[txtDelSPoint stringValue] forKey:@"value_txtDelSPoint"];
        [defaults setObject:[txtDelCntStr stringValue] forKey:@"value_txtDelCntStr"];
        //連番処理タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popCommandRange_serialNum indexOfSelectedItem]] forKey:@"value_popCommandRange_serialNum"];
        [defaults setObject:[txtAddToFront_serialNum stringValue] forKey:@"value_txtAddToFront_serialNum"];
        [defaults setObject:[txtAddToEnd_serialNum stringValue] forKey:@"value_txtAddToEnd_serialNum"];
        [defaults setObject:[txtFirstNum stringValue] forKey:@"value_txtFirstNum"];
        [defaults setObject:[txtFigure stringValue] forKey:@"value_txtFigure"];
        [defaults setObject:[txtIncrement stringValue] forKey:@"value_txtIncrement"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToWhere_serialNum indexOfSelectedItem]] forKey:@"value_popAddToWhere_serialNum"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToPoint_serialNum indexOfSelectedItem]] forKey:@"value_popAddToPoint_serialNum"];
        [defaults setObject:[txtAddToPoint_serialNum stringValue] forKey:@"value_txtAddToPoint_serialNum"];
        [defaults setObject:[NSNumber numberWithInteger:[chkPermitOverlap_serialNum state]] forKey:@"value_chkPermitOverlap_serialNum"];
        //連番増減タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popNumLocate indexOfSelectedItem]] forKey:@"value_popNumLocate"];
        [defaults setObject:[txtNumStartPoint stringValue] forKey:@"value_txtNumStartPoint"];
        [defaults setObject:[txtNumFigure stringValue] forKey:@"value_txtNumFigure"];
        [defaults setObject:[txtNumIncrement stringValue] forKey:@"value_txtNumIncrement"];
        //日付処理タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popCommandRange_date indexOfSelectedItem]] forKey:@"value_popCommandRange_date"];
        [defaults setObject:[NSNumber numberWithInteger:[popUsedDate indexOfSelectedItem]] forKey:@"value_popUsedDate"];
        [defaults setObject:[txtAddToFront_date stringValue] forKey:@"value_txtAddToFront_date"];
        [defaults setObject:[txtAddToEnd_date stringValue] forKey:@"value_txtAddToEnd_date"];
        [defaults setObject:[txtFormatter stringValue] forKey:@"value_txtFormatter"];
        [defaults setObject:[txtSampleDate stringValue] forKey:@"value_txtSampleDate"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToWhere_date indexOfSelectedItem]] forKey:@"value_popAddToWhere_date"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToPoint_date indexOfSelectedItem]] forKey:@"value_popAddToPoint_date"];
        [defaults setObject:[txtAddToPoint_date stringValue] forKey:@"value_txtAddToPoint_date"];
        [defaults setObject:[NSNumber numberWithInteger:[chkPermitOverlap_date state]] forKey:@"value_chkPermitOverlap_date"];
        //親フォルダタブOutlet
        [defaults setObject:[txtDirPosition stringValue] forKey:@"value_txtDirPosition"];
        [defaults setObject:[NSNumber numberWithInteger:[popUseStr indexOfSelectedItem]] forKey:@"value_popUseStr"];
        [defaults setObject:[NSNumber numberWithInteger:[popUsePoint indexOfSelectedItem]] forKey:@"value_popUsePoint"];
        [defaults setObject:[txtUseStart stringValue] forKey:@"value_txtUseStart"];
        [defaults setObject:[txtUseLength stringValue] forKey:@"value_txtUseLength"];
        [defaults setObject:[txtAddToFront_par stringValue] forKey:@"value_txtAddToFront_par"];
        [defaults setObject:[txtAddToEnd_par stringValue] forKey:@"value_txtAddToEnd_par"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToWhere_par indexOfSelectedItem]] forKey:@"value_popAddToWhere_par"];
        [defaults setObject:[NSNumber numberWithInteger:[popAddToPoint_par indexOfSelectedItem]] forKey:@"value_popAddToPoint_par"];
        [defaults setObject:[txtAddToPoint_par stringValue] forKey:@"value_txtAddToPoint_par"];
        [defaults setObject:[NSNumber numberWithInteger:[chkPermitOverlap_par state]] forKey:@"value_chkPermitOverlap_par"];
        //区切り文字タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popSeparator indexOfSelectedItem]] forKey:@"value_popSeparator"];
        [defaults setObject:[txtSeparator stringValue] forKey:@"value_txtSeparator"];
        [defaults setObject:[txtRep_sep stringValue] forKey:@"value_txtRep_sep"];
        //テキスト整形タブOutlet
        [defaults setObject:[NSNumber numberWithInteger:[popFormText indexOfSelectedItem]] forKey:@"value_popFormText"];
        //実行マクロを更新
        [settedPresets writeToFile:[[NSBundle mainBundle] pathForResource:@"settedPresets" ofType: @"array"] atomically:YES];
        //現状の設定が有効かどうかを判定してコマンドリストを作成してデータに保存
        [self checkInputUnderGround];
        [defaults setObject:[NSNumber numberWithBool:bCommandValidity] forKey:@"bCommandValidity"];
        [commandList writeToFile:[[NSBundle mainBundle] pathForResource:@"savedCommand" ofType: @"array"] atomically:YES];
    }else{
        //コマンドリスト有効フラグに偽をセットして保存
        [defaults setObject:[NSNumber numberWithInt:0] forKey:@"bCommandValidity"];
    }
    
    //MacroArrayを更新
    MacroController *macroController = [[MacroController alloc]init];
    [macroController saveMacroArray];
    //アプリを終了
    return(NSTerminateNow);
}

//アプリケーションアイコンクリック時
- (BOOL) applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    //メイン画面を開く
    [window makeKeyAndOrderFront:self];
    return YES;
}

#pragma mark - open file

//ドックアイコンへのドラッグアンドドロップ時
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
    return YES;
}

- (void) application:(NSApplication *)sender openFiles:(NSArray *)filenames{
    NSApplication *app = [NSApplication sharedApplication];
    if (app.keyWindow == window) {
        //メインウインドウが開いている場合（通常のリネーム処理に移行）
        if ([self checkInput]) {
            [self renameData:filenames];
        }
    }else{
        bOpenFile = YES;
        if (bCommandValidity) {
            //コマンドリストが有効
            [self renameData:filenames];
        } else {
            //コマンドリスト無効ダイアログを表示して終了
            [self showModalDialog:@"有効な処理の設定がなされていません。再度処理を設定のうえ、処理を実行してください" withIcon:@"icnCaution" withTag:mDIALOG_openFileErr];
        }
    }
}

- (void)renameData:(NSArray*)filenames{
    DataController* dataController = [[DataController alloc]init];
    for (NSString* path in filenames) {
        [dataController createData:path];
    }
    [dataController setNewName];
    [dataController changeFileName:ShowEndModal];
}

#pragma mark - window controll

//マクロパネルが閉じられる際の動作
-(void)windowWillClose:(NSNotification *)aNotification {
    NSApplication *app = [NSApplication sharedApplication];
    if(app.keyWindow == winMacro){
        [self closeMacroPanel];
    }else if (app.keyWindow == winLog){
        [mnShowLog setState:NSOffState];
    }else if(app.keyWindow == window){
        //現状の設定が有効かどうかを判定してコマンドリストを作成
        [self checkInputUnderGround];
        //サブウインドウを閉じる
        [self closeMacroPanel];
        [mnShowLog setState:NSOffState];
        [formatterDrawer close];
    }
}

//ウインドウがリサイズされた
- (void)windowDidResize:(NSNotification *)notification {
    originX = [window frame].origin.x;
    originY = [window frame].origin.y;
    originW = [window frame].size.width;
    originH = [window frame].size.height;
    
    [boxFileList setFrame:NSMakeRect(7, 7, originW-14, originH-284)];
    [scrviewFileList setFrame:NSMakeRect(12, 12, originW-38, originH-349)];
}

//コマンドウインドウのタブ切り替え
- (IBAction)popCommandList:(id)sender {
    if ([sender indexOfSelectedItem] < 11) {
        [tabCommand selectTabViewItemAtIndex:[sender indexOfSelectedItem]];
        [pshSavePreset setEnabled:YES];
        [formatterDrawer close];
        [winMacro close];
        [mnMNew setEnabled:NO];
        [mnMGroup setEnabled:NO];
        [mnReadPreset setEnabled:NO];
        [mnShowMacro setState:NSOffState];
    }else{
        [self showMacroPanel];
        [formatterDrawer close];
    }
}

//ファイルリストを表示／隠す
- (IBAction)discDisplayFileList:(id)sender {
    NSRect newRect;
    int win_maxHeight = 540;
    int win_minHeight = 289;
    originX = [window frame].origin.x;
    originY = [window frame].origin.y;
    if (discDisplayFileList.state == NSOnState){
        if (originY-(win_maxHeight-win_minHeight) < 0) {
            originY = 0;
        } else {
            originY = originY-(win_maxHeight-win_minHeight);
        }
        newRect = NSMakeRect(originX, originY, 638, win_maxHeight);
        [window setFrame:newRect display:YES];
        [window setMaxSize:NSMakeSize(2000,1000)];
        [window setMinSize:NSMakeSize(638, 540)];
        [tbFileNameList setFrameSize:NSMakeSize(598, 173)];
        [boxFileList setHidden:NO];
        [imgEasyAct setEnabled:NO];
    }else{
        int win_height = [window frame].size.height;
        [window setFrame:NSMakeRect(originX, originY+win_height-win_minHeight, 638, win_minHeight) display:YES];
        [window setMaxSize:NSMakeSize(638,289)];
        [boxFileList setHidden:YES];
        [imgEasyAct setEnabled:YES];
    }
    [[sender window] display];
}

//ファイルリストセット前後のボタン等のEnabled/Disabledを制御
-(void)activateToolButton:(BOOL)status{
    [pshAct setEnabled:status];
    [pshPreview setEnabled:status];
    [popSetSortKey setEnabled:status];
    [popSetSortKey selectItemAtIndex:3];
    [popSetSortAscending setEnabled:status];
    [popSetSortAscending selectItemAtIndex:0];
    [chkAll setEnabled:status];
    if (status) {
        [chkAll setState:1];
    }
}

//文字列追加　追加箇所指定ブロックの使用可／不可の変更
- (IBAction)popAddToWhere:(id)sender {
    if ([sender indexOfSelectedItem] == 2){
        [popAddToPoint setEnabled:YES];
        [txtAddToPoint setEnabled:YES];
        [stpAddToPoint setEnabled:YES];
    } else {
        [popAddToPoint setEnabled:NO];
        [txtAddToPoint setEnabled:NO];
        [stpAddToPoint setEnabled:NO];
    }
}

//連番処理タブ　付加先ブロックの使用可／不可の変更
- (IBAction)popCommandRange_serialNum:(id)sender {
    if ([sender indexOfSelectedItem]==1) {
        [popAddToWhere_serialNum setEnabled:YES];
        [chkPermitOverlap_serialNum setEnabled:YES];
        if ([popAddToWhere_serialNum indexOfSelectedItem]==2) {
            [popAddToPoint_serialNum setEnabled:YES];
            [stpAddToPoint_serialNum setEnabled:YES];
            [txtAddToPoint_serialNum setEnabled:YES];
        }else{
            [popAddToPoint_serialNum setEnabled:NO];
            [stpAddToPoint_serialNum setEnabled:NO];
            [txtAddToPoint_serialNum setEnabled:NO];
        }
    }else{
        [popAddToWhere_serialNum setEnabled:NO];
        [chkPermitOverlap_serialNum setEnabled:NO];
        [popAddToPoint_serialNum setEnabled:NO];
        [stpAddToPoint_serialNum setEnabled:NO];
        [txtAddToPoint_serialNum setEnabled:NO];
        [chkPermitOverlap_serialNum setEnabled:NO];
    }
}

//日付処理タブ　付加先ブロックの使用可／不可の変更
- (IBAction)popCommandRange_date:(id)sender {
    if ([sender indexOfSelectedItem]==1) {
        [popAddToWhere_date setEnabled:YES];
        [chkPermitOverlap_date setEnabled:YES];
        if ([popAddToWhere_date indexOfSelectedItem]==2) {
            [popAddToPoint_date setEnabled:YES];
            [stpAddToPoint_date setEnabled:YES];
            [txtAddToPoint_date setEnabled:YES];
        }else{
            [popAddToPoint_date setEnabled:NO];
            [stpAddToPoint_date setEnabled:NO];
            [txtAddToPoint_date setEnabled:NO];
        }
    }else{
        [popAddToWhere_date setEnabled:NO];
        [chkPermitOverlap_date setEnabled:NO];
        [popAddToPoint_date setEnabled:NO];
        [stpAddToPoint_date setEnabled:NO];
        [txtAddToPoint_date setEnabled:NO];
    }
}

//連番処理タブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_serialNum:(id)sender {
    if ([sender indexOfSelectedItem] == 2){
        [popAddToPoint_serialNum setEnabled:YES];
        [txtAddToPoint_serialNum setEnabled:YES];
        [stpAddToPoint_serialNum setEnabled:YES];
    } else {
        [popAddToPoint_serialNum setEnabled:NO];
        [txtAddToPoint_serialNum setEnabled:NO];
        [stpAddToPoint_serialNum setEnabled:NO];
    }
}

//日付処理タブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_date:(id)sender {
    if ([sender indexOfSelectedItem] == 2){
        [popAddToPoint_date setEnabled:YES];
        [txtAddToPoint_date setEnabled:YES];
        [stpAddToPoint_date setEnabled:YES];
    } else {
        [popAddToPoint_date setEnabled:NO];
        [txtAddToPoint_date setEnabled:NO];
        [stpAddToPoint_date setEnabled:NO];
    }
}

//親フォルダタブ　部分使用ブロックの使用可／不可の変更
- (IBAction)popUseStr:(id)sender {
    if ([sender indexOfSelectedItem] == 1) {
        [popUsePoint setEnabled:YES];
        [txtUseStart setEnabled:YES];
        [stpStartPoint setEnabled:YES];
        [txtUseLength setEnabled:YES];
        [stpLength setEnabled:YES];
    }else{
        [popUsePoint setEnabled:NO];
        [txtUseStart setEnabled:NO];
        [stpStartPoint setEnabled:NO];
        [txtUseLength setEnabled:NO];
        [stpLength setEnabled:NO];
    }
}

//親フォルダタブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_par:(id)sender {
    if ([sender indexOfSelectedItem] == 2){
        [popAddToPoint_par setEnabled:YES];
        [txtAddToPoint_par setEnabled:YES];
        [stpAddToPoint_par setEnabled:YES];
    } else {
        [popAddToPoint_par setEnabled:NO];
        [txtAddToPoint_par setEnabled:NO];
        [stpAddToPoint_par setEnabled:NO];
    }
}

//区切り文字タブ　置換文字フィールドの使用化／不可の変更
- (IBAction)popSeparator:(id)sender {
    if ([sender indexOfSelectedItem] < 2){
        [txtRep_sep setEnabled:YES];
    }else{
        [txtRep_sep setEnabled:NO];
    }
}

//テキスト整形処理ポップアップ　変更後フォルダに移動チェックボックスのON/OFFの変更
- (IBAction)popFormTxt:(id)sender {
    if (([sender indexOfSelectedItem]>7)&&([sender indexOfSelectedItem]<11)) {
        [chkCreateFolder setState:NSOnState];
    }
}

#pragma mark - table controll
//テーブルのチェックボタン全ON/OFF
- (IBAction)chkAll:(id)sender {
    DataController* dataController = [[DataController alloc]init];
    [dataController chkAll:[sender state]];
}
- (IBAction)chkAll_logWin:(id)sender {
    for (id obj in filteredLog) {
        if ([sender state]) {
            [obj setObject:@"1" forKey:@"chk"];
        }else{
            [obj setObject:@"0" forKey:@"chk"];
        }
    }
    [self reloadLogTable];
}

//ファイルリストのソート
- (IBAction)popSetSortKey:(id)sender {
    DataController* dataController = [[DataController alloc]init];
    [dataController SortByKey:[sender indexOfSelectedItem] ascending:[popSetSortAscending indexOfSelectedItem]];
}

- (IBAction)popSortAscending:(id)sender {
    DataController* dataController = [[DataController alloc]init];
    [dataController SortByKey:[popSetSortKey indexOfSelectedItem] ascending:[sender indexOfSelectedItem]];
}

//テーブルレコード表示更新
-(void)reloadTable{
    [tbFileNameList reloadData];
}
-(void)reloadLogFileTable{
    [logFileTable reloadData];
    //ログ全削除ボタンのEnabledを更新
    if (logFileList.count>0) {
        [pshLogAllDel setEnabled:YES];
        [mnLogAllDel setEnabled:YES];
    }else{
        [pshLogAllDel setEnabled:NO];
        [mnLogAllDel setEnabled:NO];
    }
}
-(void)reloadLogTable{
    [logTable reloadData];
    //全チェックON/OFFボタンと復元ボタンのEnabledを更新
    BOOL bRestoreFile = NO;
    if (filteredLog.count==0) {
        bRestoreFile = NO;
    }else{
        //復元対象ファイルの有無をチェック
        for (id data in filteredLog) {
            if ([[data objectForKey:@"errNum"]intValue]==0) {
                bRestoreFile = YES;
                break;
            }
        }
    }
    [chkAll_logWin setEnabled:bRestoreFile];
    [pshRestore setEnabled:bRestoreFile];
}

//メニュー処理
#pragma mark - menu action
//環境設定
- (IBAction)showPrefWin:(id)sender {
    [self showPrefWindow];
}
//ファイル-処理設定を開く
- (IBAction)mnOpenMeinWin:(id)sender {
    [window makeKeyAndOrderFront:self];
}
//編集-クリア
- (IBAction)crearWin:(id)sender {
    //処理の対象
    [popTarget selectItemAtIndex:0];
    //処理範囲
    [popTargetRange selectItemAtIndex:0];
    //拡張子を保護
    [chkProtectExt setState:1];
    //変更ファイルを別フォルダに移動
    [chkCreateFolder setState:0];
    //指定文字列追加タブOutlet
    [txtAddStr setStringValue:@""];
    [popAddToWhere selectItemAtIndex:0];
    [popAddToPoint setEnabled:NO];
    [txtAddToPoint setEnabled:NO];
    [stpAddToPoint setEnabled:NO];
    [popAddToPoint selectItemAtIndex:0];
    [chkPermitOverlap setState:0];
    [txtAddToPoint setStringValue:@"2"];
    [stpAddToPoint setIntValue:2];
    //指定文字列削除タブOutlet
    [txtDelStr setStringValue:@""];
    [popDelPoint selectItemAtIndex:0];
    [chkDelCase setState:1];
    [chkDelWidth setState:1];
    //検索置換タブOutlet
    [txtFindStr setStringValue:@""];
    [txtReplaceStr setStringValue:@""];
    [chkReplaceCase setState:1];
    [chkReplaceWidth setState:1];
    //位置指定削除タブOutlet
    [popDelPoint_strCnt selectItemAtIndex:0];
    [txtDelSPoint setStringValue:@"1"];
    [stpDelSPoint setIntValue:1];
    [txtDelCntStr setStringValue:@"1"];
    [stpDelCntStr setIntValue:1];
    //連番処理タブOutlet
    [popCommandRange_serialNum selectItemAtIndex:0];
    [popAddToWhere_serialNum selectItemAtIndex:0];
    [popAddToPoint_serialNum selectItemAtIndex:0];
    [txtAddToFront_serialNum setStringValue:@""];
    [txtAddToEnd_serialNum setStringValue:@""];
    [txtFirstNum setStringValue:@"1"];
    [stpFirstNum setIntValue:1];
    [txtFigure setStringValue:@"3"];
    [stpFigure setIntValue:3];
    [txtIncrement setStringValue:@"1"];
    [stpIncrement setIntValue:1];
    [txtAddToPoint_serialNum setStringValue:@"2"];
    [stpAddToPoint_serialNum setIntValue:2];
    [chkPermitOverlap_serialNum setState:0];
    [popAddToPoint_serialNum setEnabled:NO];
    [txtAddToPoint_serialNum setEnabled:NO];
    [stpAddToPoint_serialNum setEnabled:NO];
    //連番増減タブOutlet
    [popNumLocate selectItemAtIndex:0];
    [txtNumStartPoint setStringValue:@"1"];
    [stpStartPoint_num setIntValue:1];
    [txtNumFigure setStringValue:@"1"];
    [stpLength_num setIntValue:1];
    [txtNumIncrement setStringValue:@"1"];
    [stpIncrement_num setIntValue:1];
    //日付処理タブOutlet
    [popCommandRange_date selectItemAtIndex:0];
    [popAddToWhere_date selectItemAtIndex:0];
    [popAddToPoint_date selectItemAtIndex:0];
    [popUsedDate selectItemAtIndex:0];
    [txtFormatter setStringValue:@""];
    [txtAddToFront_date setStringValue:@""];
    [txtAddToEnd_date setStringValue:@""];
    [txtAddToPoint_date setStringValue:@"2"];
    [stpAddToPoint_date setIntValue:2];
    [chkPermitOverlap_date setState:0];
    [popAddToPoint_date setEnabled:NO];
    [txtAddToPoint_date setEnabled:NO];
    [stpAddToPoint_date setEnabled:NO];
    //現在日時から文字列を作成
    [txtSampleDate setStringValue:[GenericMethods dateString:@"yyyy年MM月dd日(E) HH時mm分ss秒"]];
    //親フォルダタブOutlet
    [txtDirPosition setStringValue:@"1"];
    [stpParLocate setIntValue:1];
    [popUseStr selectItemAtIndex:0];
    [popUsePoint selectItemAtIndex:0];
    [txtUseStart setStringValue:@"1"];
    [stpStartPoint setIntValue:1];
    [txtUseLength setStringValue:@"1"];
    [stpLength setIntValue:1];
    [popUsePoint setEnabled:NO];
    [txtUseStart setEnabled:NO];
    [stpStartPoint setEnabled:NO];
    [txtUseLength setEnabled:NO];
    [stpLength setEnabled:NO];
    [txtAddToFront_par setStringValue:@""];
    [txtAddToEnd_par setStringValue:@""];
    [popAddToWhere_par selectItemAtIndex:0];
    [popAddToPoint_par selectItemAtIndex:0];
    [txtAddToPoint_par setStringValue:@"2"];
    [stpAddToPoint_par setIntValue:2];
    [chkPermitOverlap_par setState:0];
    [popAddToPoint_par setEnabled:NO];
    [txtAddToPoint_par setEnabled:NO];
    [stpAddToPoint_par setEnabled:NO];
    //区切り文字タブOutlet
    [popSeparator selectItemAtIndex:0];
    [txtSeparator setStringValue:@""];
    [txtRep_sep setStringValue:@""];
    [txtRep_sep setEnabled:YES];
    //テキスト整形タブOutlet
    [popFormText selectItemAtIndex:0];
    //マクロタブOutlet
    [settedPresets removeAllObjects];
    [self reloadSettedMacro];
}

//ログ管理-ログファイルの選択削除
- (IBAction)log_selectDell:(id)sender {
    [self showDialog:winLog actionName:SelectDel withText:@"この操作は取り消しできません。実行してよろしいですか？" withIcon:@"icnCaution"];
}
//ログ管理-ログファイルの全削除
- (IBAction)log_AllDel:(id)sender {
    [self showDialog:winLog actionName:AllDel withText:@"この操作は取り消しできません。実行してよろしいですか？" withIcon:@"icnCaution"];
}
//マクロ-マクロパネルを表示
- (IBAction)macro_showMacroPanel:(id)sender {
    [self showMacroPanel];
}
//マクロ-プリセットを実行リストにセット
- (IBAction)mnMSet:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MSet"];
}
//マクロ-プリセットを更新
- (IBAction)mnMUpdata:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MUpdata"];
}
//マクロ-新規プリセットグループ
- (IBAction)mnMGroup:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MGroup"];
}
//マクロ-新規プリセット
- (IBAction)mnMNew:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MNew"];
}
//マクロ-プリセットを複製
- (IBAction)mnMCopy:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MCopy"];
}
//マクロ-プリセットを削除
- (IBAction)mnMDel:(id)sender {
    CCToolButton *toolBtn = [[CCToolButton alloc]init];
    [toolBtn btnAction:@"MDel"];
}
//マクロ-プリセットを読み込み
- (IBAction)mnReadPreset:(id)sender {
    MacroController *macroController = [[MacroController alloc]init];
    [macroController readPreset];
}
//マクロ-プリセットを書き出し
- (IBAction)mnSavePreset:(id)sender {
    MacroController *macroController = [[MacroController alloc]init];
    [macroController savePreset];
}
//マクロ-実行待機プリセット選択削除
- (IBAction)macro_selectDel:(id)sender {
    NSIndexSet *indexes = [tblSettedPreset selectedRowIndexes];
    NSUInteger index = [indexes firstIndex];
    NSMutableArray *deleteList = [NSMutableArray array];
    while(index != NSNotFound) {
        [deleteList addObject:[settedPresets objectAtIndex:index]];
        index = [indexes indexGreaterThanIndex:index];
    }
    for (NSString *data in deleteList) {
        [settedPresets removeObject:data];
    }
    [self reloadSettedMacro];
}

//マクロ-実行待機プリセット全削除
- (IBAction)macro_allDel:(id)sender {
    [settedPresets removeAllObjects];
    [self reloadSettedMacro];
}

//その他の処理-連ページフォルダ作成
- (IBAction)other_ShowPageFolderWin:(id)sender {
    [winPageFolder makeKeyAndOrderFront:self];
}

//ウインドウ-ログ管理画面を開く
- (IBAction)showLogWin:(id)sender {
    LogController *logController = [[LogController alloc]init];
    [logController setLogFileList];
    [self showLogWin];
}

//キーウインドウ変更イベント=メニュー選択削除のショートカットの変更
-(void)windowDidBecomeKey:(NSNotification *)notification{
    NSApplication *app = [NSApplication sharedApplication];
    if (app.keyWindow == window){
        [mnLogSelectDel setKeyEquivalent:@""];
        [mnMDel setKeyEquivalent:@""];
        [mnMacroSelectDel setKeyEquivalentModifierMask:NSCommandKeyMask];
        [mnMacroSelectDel setKeyEquivalent:[NSString stringWithFormat:@"%c", 0x08]];
    }else if (app.keyWindow == winLog){
        [mnMacroSelectDel setKeyEquivalent:@""];
        [mnMDel setKeyEquivalent:@""];
        [mnLogSelectDel setKeyEquivalentModifierMask:NSCommandKeyMask];
        [mnLogSelectDel setKeyEquivalent:[NSString stringWithFormat:@"%c", 0x08]];
    }else{
        [mnLogSelectDel setKeyEquivalent:@""];
        [mnMacroSelectDel setKeyEquivalent:@""];
        [mnMDel setKeyEquivalentModifierMask:NSCommandKeyMask];
        [mnMDel setKeyEquivalent:[NSString stringWithFormat:@"%c", 0x08]];
    }
}

#pragma mark - make presets

//入力チェックとコマンドリストの作成（処理保存／実行時）
-(BOOL)checkInput{
    switch ([popCommandList indexOfSelectedItem]) {
        case 0:{
            //指定文字列を追加
            NSString *addStr = [txtAddStr stringValue];
            if ([addStr isEqualToString:@""]) {
                [self showDialog:window actionName:inputErr withText:@"追加文字列を入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            NSRange txtSearchRange = [addStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            if (([txtAddToPoint isEnabled])&&([[txtAddToPoint stringValue]intValue] < 2)) {
                [self showDialog:window actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetAddStr]; //コマンドリストセット
        }
            break;
        case 1:{
            //指定文字列を削除
            NSString *delStr = [txtDelStr stringValue];
            if ([delStr isEqualToString:@""]) {
                [self showDialog:window actionName:inputErr withText:@"削除文字列を入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetDelStr]; //コマンドリストセット
            break;
        }
        case 2:{
            //指定文字列の検索置換
            NSString *findStr = [txtFindStr stringValue];
            NSString *replaceStr = [txtReplaceStr stringValue];
            if ([findStr isEqualToString:@""]){
                [self showDialog:window actionName:inputErr withText:@"検索文字列を入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            if ([replaceStr isEqualToString:@""]) {
                [self showDialog:window actionName:inputErr withText:@"置換文字列を入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetFindAndReplace]; //コマンドリストセット
            break;
        }
        case 3: //文字数指定削除
            if (([[txtDelSPoint stringValue]intValue]<1)||([[txtDelCntStr stringValue]intValue]<1)) {
                [self showDialog:window actionName:inputErr withText:@"数値を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetPointDel];
            break;
        case 4:{ //連番処理
            NSString *addToFront = [txtAddToFront_serialNum stringValue];
            NSString *addToEnd = [txtAddToEnd_serialNum stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            if ([[txtFirstNum stringValue]intValue]<1) {
                [self showDialog:window actionName:inputErr withText:@"最初の番号を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            if ([[txtFigure stringValue]intValue]<1) {
                [self showDialog:window actionName:inputErr withText:@"桁数を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            if ([[txtIncrement stringValue]intValue]<1) {
                [self showDialog:window actionName:inputErr withText:@"増分を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            if (([txtAddToPoint_serialNum isEnabled])&&([[txtAddToPoint_serialNum stringValue]intValue]<2)) {
                [self showDialog:window actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetSerialNum];
            break;
        }
        case 5: //連番の増減
            if (([[txtNumStartPoint stringValue]intValue]<1)||([[txtNumFigure stringValue]intValue]<1)||([[txtNumIncrement stringValue]intValue]==0)) {
                [self showDialog:window actionName:inputErr withText:@"数値を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetNumInorDecrease];
            break;
        case 6:{ //日付処理
            NSString *addToFront = [txtAddToFront_date stringValue];
            NSString *addToEnd = [txtAddToEnd_date stringValue];
            NSString *formatter = [txtFormatter stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            if ([formatter isEqualToString:@""]){
                [self showDialog:window actionName:inputErr withText:@"フォーマッタを入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            txtSearchRange = [formatter rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            if (([txtAddToPoint_date isEnabled])&&([[txtAddToPoint_date stringValue]intValue]<2)) {
                [self showDialog:window actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetDate];
            break;
        }
        case 7:{ //親フォルダ処理
            NSString *addToFront = [txtAddToFront_par stringValue];
            NSString *addToEnd = [txtAddToEnd_par stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            if ([[txtDirPosition stringValue]intValue]<1) {
                [self showDialog:window actionName:inputErr withText:@"親フォルダの階層を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;

            }
            if (([txtUseStart isEnabled])&&([[txtUseStart stringValue]intValue]<1)) {
                [self showDialog:window actionName:inputErr withText:@"使用箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            if (([txtUseLength isEnabled])&&([[txtUseLength stringValue]intValue]<1)) {
                [self showDialog:window actionName:inputErr withText:@"使用箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetParentFolder];
            break;
        case 8:{ //区切り文字処理
            NSString *separator = [txtSeparator stringValue];
            if ([separator isEqualToString:@""]) {
                [self showDialog:window actionName:inputErr withText:@"区切り文字を入力して下さい" withIcon:@"icnCaution"];
                return NO;
            }
            NSString *replaceStr = [txtRep_sep stringValue];
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [self showDialog:window actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetSeparator];
            }
            break;
        case 9: //テキスト整形処理
            [self makePresetFormTxt];
            break;
        case 11: //マクロ処理
            if (settedPresets.count == 0) {
                [self showDialog:window actionName:inputErr withText:@"使用するプリセットを設定してください" withIcon:@"icnCaution"];
                return NO;
            }
            [self makePresetMacro]; //コマンドリストセット
            break;
        }
        default:
            break;
    }
    return YES;
}

//入力チェックとコマンドリストの作成（設定画面終了時）
-(void)checkInputUnderGround{
    switch ([popCommandList indexOfSelectedItem]) {
        case 0:{
            //指定文字列を追加
            NSString *addStr = [txtAddStr stringValue];
            if ([addStr isEqualToString:@""]) {
                bCommandValidity = NO;
                return;
            }
            NSRange txtSearchRange = [addStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            if (([txtAddToPoint isEnabled])&&([[txtAddToPoint stringValue]intValue] < 2)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetAddStr]; //コマンドリストセット
        }
            break;
        case 1:{
            //指定文字列を削除
            NSString *delStr = [txtDelStr stringValue];
            if ([delStr isEqualToString:@""]) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetDelStr]; //コマンドリストセット
            break;
        }
        case 2:{
            //指定文字列の検索置換
            NSString *findStr = [txtFindStr stringValue];
            NSString *replaceStr = [txtReplaceStr stringValue];
            if ([findStr isEqualToString:@""]){
                bCommandValidity = NO;
                return;
            }
            if ([replaceStr isEqualToString:@""]) {
                bCommandValidity = NO;
                return;
            }
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetFindAndReplace]; //コマンドリストセット
            break;
        }
        case 3: //文字数指定削除
            if (([[txtDelSPoint stringValue]intValue]<1)||([[txtDelCntStr stringValue]intValue]<1)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetPointDel];
            break;
        case 4:{ //連番処理
            NSString *addToFront = [txtAddToFront_serialNum stringValue];
            NSString *addToEnd = [txtAddToEnd_serialNum stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            if ([[txtFirstNum stringValue]intValue]<1) {
                bCommandValidity = NO;
                return;
            }
            if ([[txtFigure stringValue]intValue]<1) {
                bCommandValidity = NO;
                return;
            }
            if ([[txtIncrement stringValue]intValue]<1) {
                bCommandValidity = NO;
                return;
            }
            if (([txtAddToPoint_serialNum isEnabled])&&([[txtAddToPoint_serialNum stringValue]intValue]<2)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetSerialNum];
            break;
        }
        case 5: //連番の増減
            if (([[txtNumStartPoint stringValue]intValue]<1)||([[txtNumFigure stringValue]intValue]<1)||([[txtNumIncrement stringValue]intValue]==0)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetNumInorDecrease];
            break;
        case 6:{ //日付処理
            NSString *addToFront = [txtAddToFront_date stringValue];
            NSString *addToEnd = [txtAddToEnd_date stringValue];
            NSString *formatter = [txtFormatter stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            if ([formatter isEqualToString:@""]){
                bCommandValidity = NO;
                return;
            }
            txtSearchRange = [formatter rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            if (([txtAddToPoint_date isEnabled])&&([[txtAddToPoint_date stringValue]intValue]<2)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetDate];
            break;
        }
        case 7:{ //親フォルダ処理
            NSString *addToFront = [txtAddToFront_par stringValue];
            NSString *addToEnd = [txtAddToEnd_par stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            if ([[txtDirPosition stringValue]intValue]<1) {
                bCommandValidity = NO;
                return;
                
            }
            if (([txtUseStart isEnabled])&&([[txtUseStart stringValue]intValue]<1)) {
                bCommandValidity = NO;
                return;
            }
            if (([txtUseLength isEnabled])&&([[txtUseLength stringValue]intValue]<1)) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetParentFolder];
            break;
        case 8:{ //区切り文字処理
            NSString *separator = [txtSeparator stringValue];
            if ([separator isEqualToString:@""]) {
                bCommandValidity = NO;
                return;
            }
            NSString *replaceStr = [txtRep_sep stringValue];
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetSeparator];
        }
            break;
        case 9: //テキスト整形処理
            [self makePresetFormTxt];
            break;
        case 11: //マクロ処理
            if (settedPresets.count == 0) {
                bCommandValidity = NO;
                return;
            }
            [self makePresetMacro]; //コマンドリストセット
            break;
        }
        default:
            break;
    }
    bCommandValidity = YES;
    }


//プリセット作成
//指定文字列追加プリセット
-(void)makePresetAddStr{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:0] forKey:@"commandCode"];
    [preset setObject:[txtAddStr stringValue] forKey:@"addStr"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToWhere indexOfSelectedItem]] forKey:@"addToWhere"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToPoint indexOfSelectedItem]] forKey:@"switchCntFrom"];
    [preset setObject:[txtAddToPoint stringValue] forKey:@"addToPoint"];
    [preset setObject:[NSNumber numberWithInteger:[chkPermitOverlap state]] forKey:@"permitOverlap"];
    [commandList addObject:preset];
}
//指定文字列削除プリセット
-(void)makePresetDelStr{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:1] forKey:@"commandCode"];
    [preset setObject:[txtDelStr stringValue] forKey:@"delStr"];
    [preset setObject:[NSNumber numberWithInteger:[popDelPoint indexOfSelectedItem]] forKey:@"delPoint"];
    [preset setObject:[NSNumber numberWithInteger:[chkDelCase state]] forKey:@"chkDelCase"];
    [preset setObject:[NSNumber numberWithInteger:[chkDelWidth state]] forKey:@"chkDelWidth"];
    [commandList addObject:preset];
}
//指定文字列検索置換プリセット
-(void)makePresetFindAndReplace{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:2] forKey:@"commandCode"];
    [preset setObject:[txtFindStr stringValue] forKey:@"findStr"];
    [preset setObject:[txtReplaceStr stringValue] forKey:@"replaceStr"];
    [preset setObject:[NSNumber numberWithInteger:[chkReplaceCase state]] forKey:@"chkReplaceCase"];
    [preset setObject:[NSNumber numberWithInteger:[chkReplaceWidth state]] forKey:@"chkReplaceWidth"];
    [commandList addObject:preset];
}
//位置指定文字列削除プリセット
-(void)makePresetPointDel{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:3] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popDelPoint_strCnt indexOfSelectedItem]] forKey:@"delPoint_strCnt"];
    [preset setObject:[txtDelSPoint stringValue] forKey:@"delSPoint"];
    [preset setObject:[txtDelCntStr stringValue] forKey:@"delCntStr"];
    [commandList addObject:preset];
}
//連番処理プリセット
-(void)makePresetSerialNum{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:4] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popCommandRange_serialNum indexOfSelectedItem]] forKey:@"commandRange"];
    [preset setObject:[txtAddToFront_serialNum stringValue] forKey:@"addToFront"];
    [preset setObject:[txtAddToEnd_serialNum stringValue] forKey:@"addToEnd"];
    [preset setObject:[txtFirstNum stringValue] forKey:@"firstNum"];
    [preset setObject:[txtFigure stringValue] forKey:@"figure"];
    [preset setObject:[txtIncrement stringValue] forKey:@"increment"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToWhere_serialNum indexOfSelectedItem]] forKey:@"addToWhere"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToPoint_serialNum indexOfSelectedItem]] forKey:@"switchCntFrom"];
    [preset setObject:[txtAddToPoint_serialNum stringValue] forKey:@"addToPoint"];
    [preset setObject:[NSNumber numberWithInteger:[chkPermitOverlap_serialNum state]] forKey:@"permitOverlap"];
    [commandList addObject:preset];
}
//連番増減プリセット
- (void)makePresetNumInorDecrease{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:5] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popNumLocate indexOfSelectedItem]] forKey:@"numLocate"];
    [preset setObject:[txtNumStartPoint stringValue] forKey:@"startPoint"];
    [preset setObject:[txtNumFigure stringValue] forKey:@"figure"];
    [preset setObject:[txtNumIncrement stringValue] forKey:@"increment"];
    [commandList addObject:preset];
}
//日付処理プリセット
-(void)makePresetDate{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:6] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popCommandRange_date indexOfSelectedItem]] forKey:@"commandRange"];
    [preset setObject:[NSNumber numberWithInteger:[popUsedDate indexOfSelectedItem]] forKey:@"usedDate"];
    [preset setObject:[txtAddToFront_date stringValue] forKey:@"addToFront"];
    [preset setObject:[txtAddToEnd_date stringValue] forKey:@"addToEnd"];
    [preset setObject:[txtFormatter stringValue] forKey:@"formatter"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToWhere_date indexOfSelectedItem]] forKey:@"addToWhere"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToPoint_date indexOfSelectedItem]] forKey:@"switchCntFrom"];
    [preset setObject:[txtAddToPoint_date stringValue] forKey:@"addToPoint"];
    [preset setObject:[NSNumber numberWithInteger:[chkPermitOverlap_date state]] forKey:@"permitOverlap"];
    [commandList addObject:preset];
}
//親フォルダプリセット
- (void)makePresetParentFolder{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:7] forKey:@"commandCode"];
    [preset setObject:[txtDirPosition stringValue] forKey:@"dirPosition"];
    [preset setObject:[NSNumber numberWithInteger:[popUseStr indexOfSelectedItem]] forKey:@"useStr"];
    [preset setObject:[NSNumber numberWithInteger:[popUsePoint indexOfSelectedItem]] forKey:@"usePointFrom"];
    [preset setObject:[txtUseStart stringValue] forKey:@"useStart"];
    [preset setObject:[txtUseLength stringValue] forKey:@"useLength"];
    [preset setObject:[txtAddToFront_par stringValue] forKey:@"addToFront"];
    [preset setObject:[txtAddToEnd_par stringValue] forKey:@"addToEnd"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToWhere_par indexOfSelectedItem]] forKey:@"addToWhere"];
    [preset setObject:[NSNumber numberWithInteger:[popAddToPoint_par indexOfSelectedItem]] forKey:@"switchCntFrom"];
    [preset setObject:[txtAddToPoint_date stringValue] forKey:@"addToPoint"];
    [preset setObject:[NSNumber numberWithInteger:[chkPermitOverlap_par state]] forKey:@"permitOverlap"];
    [commandList addObject:preset];
}
//区切り文字処理
-(void)makePresetSeparator{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:8] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popSeparator indexOfSelectedItem]] forKey:@"sepCommand"];
    [preset setObject:[txtSeparator stringValue] forKey:@"separator"];
    [preset setObject:[txtRep_sep stringValue] forKey:@"replaceStr"];
    [commandList addObject:preset];
}
//テキスト整形処理
-(void)makePresetFormTxt{
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    [commandList removeAllObjects]; //コマンドリストをクリア
    [preset setObject:[NSNumber numberWithInt:9] forKey:@"commandCode"];
    [preset setObject:[NSNumber numberWithInteger:[popFormText indexOfSelectedItem]] forKey:@"formTxt"];
    [commandList addObject:preset];
}
//マクロプリセット
-(void)makePresetMacro{
    [commandList removeAllObjects]; //コマンドリストをクリア
    //マクロフォルダのパスを取得
    Setting *_setting = [[Setting alloc]init];
    NSString *dirPath = [_setting tempMacroLocate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path;
    NSArray *macroArray;
    //マクロフォルダの実在を確認
    if ([fileManager fileExistsAtPath:dirPath]) {
        for (NSString *name in settedPresets) {
            //マクロファイルの実在を確認
            path = [[dirPath stringByAppendingPathComponent:name]stringByAppendingPathExtension:@"xml"];
            if ([fileManager fileExistsAtPath:path]) {
                macroArray = [NSArray arrayWithContentsOfFile:path];
                [commandList addObject:[macroArray objectAtIndex:0]];
            }
        }
    }
}

#pragma mark - sub window, panel controll
//フォーマッタ記述子一覧を開く
- (IBAction)showFormatterWin:(id)sender {
    [formatterDrawer setParentWindow:window];
    [formatterDrawer openOnEdge:NSMaxXEdge];
}

//環境設定ウインドウの制御
-(void)showPrefWindow{
    [[NSApplication sharedApplication] beginSheet:winPref modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)endPrefWin{
    [winPref close];
    [[NSApplication sharedApplication] endSheet:winPref returnCode:0];
}

#pragma mark - End Dialog Controll
//処理終了ダイアログの制御(シート)
-(void)showEndDialog:(NSWindow*)parWin saveErr:(BOOL)bSaveErr withText:(NSString*)text{
    if (parWin == window) {
        [pshEndDialogOK setTag:nameDidChangedOK];
    }else if (parWin == winLog){
        [pshEndDialogOK setTag:logDidRemovedOK];
    }else{
        [pshEndDialogOK setTag:pgFolderDidCreated];
    }
    [pshErrDSave setTag:eDIALOG_SaveError];
    [self drawErrTable:bSaveErr withText:text];
    [[NSApplication sharedApplication] beginSheet:winEndDialog modalForWindow:parWin modalDelegate:self didEndSelector:@selector(endDialogDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

//処理終了ダイアログの制御(モダルダイアログ)
- (void)showEndMDialog:(BOOL)bSaveErr withText:(NSString*)text{
    [self drawErrTable:bSaveErr withText:text];
    [pshEndDialogOK setTag:mNameDidChangedOK];
    [pshErrDSave setTag:mDIALOG_SaveError];
    [[NSApplication sharedApplication]runModalForWindow:winEndDialog];
    [winEndDialog orderOut:self];
}

//エラーリストの描画
- (void)drawErrTable:(BOOL)bSaveErr withText:(NSString*)text{
    [txtErrDialog setStringValue:text];
    if (errList.count == 0){
        [scrErrTable setHidden:YES];
        [lblErrTable setHidden:YES];
        [pshErrDSave setHidden:YES];
        [winEndDialog setFrame:NSMakeRect(0, 0, 500, 130) display:YES];
    }else{
        [scrErrTable setHidden:NO];
        [lblErrTable setHidden:NO];
        if (bSaveErr) {
            [pshErrDSave setHidden:NO];
        }else{
            [pshErrDSave setHidden:YES];
        }
        [winEndDialog setFrame:NSMakeRect(0, 0, 500, 300) display:YES];
        [errTable reloadData];
    }
}

-(void)endDialogDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo{
    [winEndDialog orderOut:self];
    if (returnCode == eDIALOG_OK) {
        //ログ削除処理終了ダイアログでOKボタンが押された
        LogController *logController = [[LogController alloc]init];
        [logController setLogFileList];
        [self reloadLogFileTable];
        [self reloadLogTable];
        [logFileTable deselectAll:Nil];
        [winEndDialog close];
    }else if(returnCode == eDIALOG_SaveError){
        //ファイルネーム変更処理終了ダイアログでエラー書き出しボタンが押された
        LogController *logController = [[LogController alloc]init];
        if ([logController saveErrorLog]){
            [self reloadLogTable];
            [winEndDialog close];
        }
    //ページフォルダ作成終了ダイアログでOKボタンが押された
    }else if(returnCode == eDIALOG_pfFolderOK){
        [winEndDialog close];
        [winPageFolder close];
    }else{
        return;
    }
}

- (IBAction)pshEndDialogOK:(id)sender {
    if ([sender tag] == logDidRemovedOK) {
        [[NSApplication sharedApplication] endSheet:winEndDialog returnCode:eDIALOG_OK];
    } else if ([sender tag] == pgFolderDidCreated){
        [[NSApplication sharedApplication] endSheet:winEndDialog returnCode:eDIALOG_pfFolderOK];
    } else if ([sender tag] == mNameDidChangedOK){
        //モダルダイアログを閉じる
        [[NSApplication sharedApplication]stopModal];
        [winEndDialog close];
    } else {
        [[NSApplication sharedApplication] endSheet:winEndDialog returnCode:DIALOG_END];
    }
}
- (IBAction)pshSaveErr:(id)sender {
    if ([sender tag] == eDIALOG_SaveError) {
        [[NSApplication sharedApplication] endSheet:winEndDialog returnCode:eDIALOG_SaveError];
    }else if ([sender tag] == mDIALOG_SaveError){
        //エラーを保存してモダルダイアログを閉じる
        LogController *logController = [[LogController alloc]init];
        if ([logController saveErrorLog]){
            [self reloadLogTable];
            [[NSApplication sharedApplication]stopModal];
            [winEndDialog close];
        }
    }
}

#pragma mark - Generic Dialog Controll
//汎用モダルダイアログの制御
-(void)showModalDialog:(NSString*)text withIcon:(NSString*)icnName withTag:(int)aTag{
    [dialogText setStringValue:text];
    [dialogIcon setImage:[NSImage imageNamed:icnName]];
    [dialogPshOK setTitle:@"OK"];
    [dialogPshBtn2 setHidden:YES];
    [dialogPshCancel setHidden:YES];
    [dialogPshOK setTag:aTag];
    [[NSApplication sharedApplication]runModalForWindow:genericDialog];
}

//汎用シートダイアログの制御
-(void)showDialog:(NSWindow*)parWin actionName:(NSInteger)aTag withText:(NSString*)text withIcon:(NSString*)icnName{
    if (aTag == inputErr) {
        [dialogPshBtn2 setHidden:YES];
        [dialogPshCancel setHidden:YES];
        [dialogPshOK setTitle:@"OK"];
    }else if ((aTag == renamePreset)||(aTag == copyPreset)){
        //マクロ-プリセット名重複警告
        [dialogPshBtn2 setHidden:NO];
        [dialogPshCancel setHidden:NO];
        [dialogPshCancel setKeyEquivalent:@"\r"];
        [dialogPshOK setTitle:@"上書き"];
        [dialogPshOK setKeyEquivalent:@""];
    }else{
        [dialogPshBtn2 setHidden:YES];
        [dialogPshCancel setHidden:NO];
        [dialogPshOK setTitle:@"OK"];
    }
    if (aTag == renamePreset) {
        [dialogPshBtn2 setTag:macroSaveAs];
    }else if (aTag == copyPreset){
        [dialogPshBtn2 setTag:macroCopyAs];
    }
    [dialogText setStringValue:text];
    [dialogIcon setImage:[NSImage imageNamed:icnName]];
    [dialogPshOK setTag:aTag];

    [[NSApplication sharedApplication] beginSheet:genericDialog modalForWindow:parWin modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo{
    [sheet orderOut:self];
    LogController *logController = [[LogController alloc]init];
    NSMutableArray *delFileList = [NSMutableArray array];
    if(returnCode == DIALOG_LogSelectDel) {
        //選択削除から呼ばれたダイアログでOKが押された
        NSIndexSet *indexes = [logFileTable selectedRowIndexes];
        NSUInteger index = [indexes firstIndex];
        NSDictionary *data = [NSDictionary dictionary];
        while(index != NSNotFound) {
            data = [logFileList objectAtIndex:index];
            [delFileList addObject:[data objectForKey:@"filePath"]];
            index = [indexes indexGreaterThanIndex:index];
        }
        [logController removeLog:delFileList];
        return;
    }else if(returnCode == DIALOG_LogAllDel) {
        //全削除から呼ばれたダイアログでOKが押された
        for (id data in logFileList) {
            [delFileList addObject:[data objectForKey:@"filePath"]];
        }
        [logController removeLog:delFileList];
        return;
    }else if (returnCode == DIALOG_macroSave_owY){
        //プリセット名重複ダイアログで上書きが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController saveMacro:[txtPresetName stringValue] overWrite:YES asNewPreset:NO];
        return;
    }else if (returnCode == DIALOG_macroCopy_owY){
        //プリセット読み込み／プリセット名重複ダイアログで上書きが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController copyPresetData:YES];
        return;
    }else if (returnCode == DIALOG_macroSave_owN){
        //プリセット名入力ダイアログでOKが押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController saveMacro:[txtPresetName stringValue] overWrite:NO asNewPreset:YES];
        return;
    }else if (returnCode == DIALOG_macroSaveAs){
        //プリセット名重複ダイアログで別名で保存が押された
        [pshOK_presetNameDialog setTag:0];
        [[NSApplication sharedApplication] beginSheet:presetNameDialog modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }else if (returnCode == DIALOG_macroCopyAs){
        //プリセット読み込み／プリセット名重複ダイアログで別名で保存が押された
        [pshOK_presetNameDialog setTag:macroCopyAsOK];
        [[NSApplication sharedApplication] beginSheet:presetNameDialog modalForWindow:winMacro modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }else if (returnCode == DIALOG_macroCopy_owN){
        //プリセット読み込み／プリセット別名入力ダイアログでOKが押された
        MacroController *macroController = [[MacroController alloc]init];
        newfName = [[[txtPresetName stringValue]stringByAppendingPathExtension:@"xml"]retain];
        [macroController copyPresetData:NO];
    }else if (returnCode == DIALOG_MacroSelectDel){
        //マクロパネルで選択削除が押された
        MacroController *macroController = [[MacroController alloc]init];
        [macroController deleteSelections];
    }
}
- (IBAction)dialogOK:(id)sender {
    if ([sender tag] == SelectDel) {
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_LogSelectDel];
    }else if ([sender tag] == AllDel){
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_LogAllDel];
    }else if ([sender tag] == renamePreset){
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_macroSave_owY];
    }else if ([sender tag] == copyPreset){
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_macroCopy_owY];
    }else if ([sender tag] == SelectDel_macro){
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_MacroSelectDel];
    }else if ([sender tag] == mDIALOG_openFileErr){
        //モダルダイアログを閉じてメイン画面を開く
        [[NSApplication sharedApplication]stopModal];
        [genericDialog close];
        [window makeKeyAndOrderFront:self];
    }else{
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_END];
    }
}
- (IBAction)dialogCancel:(id)sender {
    [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_END];
}
- (IBAction)dialogSaveAs:(id)sender {
    if ([sender tag]==macroSaveAs) {
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_macroSaveAs];
    }else{
        [[NSApplication sharedApplication] endSheet:genericDialog returnCode:DIALOG_macroCopyAs];
    }
}

#pragma mark - Macro Name Input Dialog Controll
//マクロプリセット名入力ダイアログの制御
-(void)showGetPresetName{
    [txtPresetName setStringValue:@""];
    [[NSApplication sharedApplication] beginSheet:presetNameDialog modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)getPresetName:(id)sender {
    if ([sender tag] == 0) {
        [[NSApplication sharedApplication] endSheet:presetNameDialog returnCode:DIALOG_macroSave_owN];
    }else{
        [[NSApplication sharedApplication] endSheet:presetNameDialog returnCode:DIALOG_macroCopy_owN];
    }
}

- (IBAction)getPresetNameCancel:(id)sender {
    [[NSApplication sharedApplication] endSheet:presetNameDialog returnCode:DIALOG_END];
}

#pragma mark - Macro Panel Controll
//マクロパネルの制御
-(void)showMacroPanel{
    if (mnShowMacro.state == NSOffState) {
        [popCommandList selectItemAtIndex:11];
        [tabCommand selectTabViewItemAtIndex:10];
        [pshSavePreset setEnabled:NO];
        [macroView reloadData];
        [macroView expandItem:nil expandChildren:YES];
        [macroView deselectAll:Nil];
        [M_popCommand selectItem:nil];
        [tabCommands_macro selectTabViewItemAtIndex:10];
        [formatterDrawer close];
        [mnMNew setEnabled:YES];
        [mnMGroup setEnabled:YES];
        [mnReadPreset setEnabled:YES];
        int panelY = window.frame.origin.y+window.frame.size.height-332; //モニタのサイズを取得
        NSRect monitor = [[window screen]visibleFrame];
        if (panelY + 600 > monitor.size.width){
            panelY = monitor.size.width - 600;
        }
        [winMacro setFrameOrigin:NSMakePoint(window.frame.origin.x+window.frame.size.width, panelY)];
        [winMacro makeKeyAndOrderFront:self];
        [mnShowMacro setState:NSOnState];
    }else{
        [winMacro close];
        [mnShowMacro setState:NSOffState];
    }
}

//マクロパネルを閉じる
- (void)closeMacroPanel{
    [macroView deselectAll:Nil];
    [formatterDrawer close];
    [mnMNew setEnabled:NO];
    [mnMGroup setEnabled:NO];
    [mnReadPreset setEnabled:NO];
    [mnShowMacro setState:NSOffState];
}

//マクロタブの制御
//実行リストの更新
-(void)reloadSettedMacro{
    [tblSettedPreset reloadData];
    [tblSettedPreset deselectAll:Nil];
    if (settedPresets.count > 0) {
        [pshAllDelPreset setEnabled:YES];
        [mnMacroAllDel setEnabled:YES];
    }else{
        [pshAllDelPreset setEnabled:NO];
        [mnMacroAllDel setEnabled:NO];
    }
}

#pragma mark - Log Window Controll
//ログウインドウの制御
-(void)showLogWin{
    if (mnShowLog.state == NSOffState) {
        [self reloadLogFileTable];
        [self reloadLogTable];
        [logFileTable deselectAll:Nil];
        [srcField setStringValue:@""];
        [winLog makeKeyAndOrderFront:self];
        [mnShowLog setState:NSOnState];
    } else {
        [winLog close];
        [mnShowLog setState:NSOffState];
    }
}

//ログリストの検索
- (IBAction)searchField:(id)sender {
    NSString* filterStr = [sender stringValue];
    [self filterTableData:filterStr];
}

- (void)filterTableData:(NSString*)filterStr{
    if ([filterStr isEqualToString:@""]) {
        //searchFieldが空の場合、filteredListを初期化
        filteredLog = [[NSMutableArray arrayWithArray:logList]retain];
    }else{
        //searchFieldの文字列でフィルター処理
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(orgName CONTAINS %@) OR (newName CONTAINS %@)",filterStr,filterStr];
        filteredLog = [[NSMutableArray arrayWithArray:[logList filteredArrayUsingPredicate:predicate]]retain];
    }
    [self reloadLogTable];
}

@end
