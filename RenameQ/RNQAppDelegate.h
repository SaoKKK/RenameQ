//
//  RNQAppDelegate.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/06/17.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface RNQAppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>{
    IBOutlet NSWindow *winPref;
    IBOutlet NSBox *boxFileList;
    IBOutlet NSTabView *tabCommand;
    IBOutlet NSTableView *tbFileNameList;
    IBOutlet NSScrollView *scrviewFileList;
    IBOutlet NSButton *discDisplayFileList;
    //タブOutlet
    IBOutlet NSStepperCell *stpAddToPoint;
    IBOutlet NSStepperCell *stpAddToPoint_serialNum;
    IBOutlet NSStepperCell *stpAddToPoint_date;
    IBOutlet NSStepper *stpParLocate;
    IBOutlet NSStepper *stpStartPoint;
    IBOutlet NSStepper *stpLength;
    IBOutlet NSStepper *stpAddToPoint_par;
    IBOutlet NSStepper *stpStartPoint_num;
    IBOutlet NSStepper *stpLength_num;
    IBOutlet NSStepper *stpIncrement_num;
    IBOutlet NSStepper *stpDelSPoint;
    IBOutlet NSStepper *stpDelCntStr;
    IBOutlet NSStepper *stpFirstNum;
    IBOutlet NSStepper *stpFigure;
    IBOutlet NSStepper *stpIncrement;
    
    IBOutlet NSButton *chkAll;
    IBOutlet NSPopUpButton *popSetSortKey;
    IBOutlet NSPopUpButton *popSetSortAscending;
    IBOutlet NSButton *pshAct;
    IBOutlet NSButton *pshPreview;
    IBOutlet NSButton *pshSavePreset;
    IBOutlet NSImageView *imgEasyAct;
    IBOutlet NSTableView *errTable;
    IBOutlet NSScrollView *scrErrTable;
    IBOutlet NSTextField *lblErrTable;
    IBOutlet NSButton *pshErrDSave;
    //ログウィンドウOutlet
    IBOutlet NSTableView *logFileTable;
    IBOutlet NSTableView *logTable;
    IBOutlet NSButton *pshLogAllDel;
    //マクロパネルOutlet
    IBOutlet NSWindow *presetNameDialog;
    IBOutlet NSTextField *txtPresetName;
    IBOutlet NSTabView *tabCommands_macro;
    //ダイアログOutlet
    IBOutlet NSImageView *dialogIcon;
    IBOutlet NSTextField *dialogText;
    IBOutlet NSButton *dialogPshOK;
    IBOutlet NSButton *dialogPshCancel;
    IBOutlet NSButton *dialogPshBtn2;
    //処理終了ダイアログOutlet
    IBOutlet NSTextField *txtErrDialog;
    IBOutlet NSButton *pshEndDialogOK;
    //連ページフォルダ作成ウインドウOutlet
    IBOutlet NSWindow *winPageFolder;
    //メニューアイテム
    IBOutlet NSMenuItem *mnShowLog;
    IBOutlet NSMenuItem *mnShowMacro;
    
    NSInteger defaultWinSave;
    NSString *pathToMAcroDict;
    BOOL bCommandValidity; //コマンドリスト有効判定フラグ
    BOOL bOpenFile; //ファイルオープン中フラグ
}

@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSButton *chkCreateFolder;
@property (strong) IBOutlet NSButton *chkProtectExt;
@property (strong) IBOutlet NSPopUpButton *popCommandList;
@property (strong) IBOutlet NSPopUpButton *popTargetRange;
@property (strong) IBOutlet NSPopUpButton *popTarget;
//指定文字列追加タブOutlet
@property (strong) IBOutlet NSTextField *txtAddStr;
@property (strong) IBOutlet NSPopUpButton *popAddToWhere;
@property (strong) IBOutlet NSPopUpButton *popAddToPoint;
@property (strong) IBOutlet NSTextField *txtAddToPoint;
@property (strong) IBOutlet NSButton *chkPermitOverlap;
//指定文字列削除タブOutlet
@property (strong) IBOutlet NSTextField *txtDelStr;
@property (strong) IBOutlet NSPopUpButton *popDelPoint;
@property (strong) IBOutlet NSButton *chkDelCase;
@property (strong) IBOutlet NSButton *chkDelWidth;
//指定文字列検索置換タブOutlet
@property (strong) IBOutlet NSTextField *txtFindStr;
@property (strong) IBOutlet NSTextField *txtReplaceStr;
@property (strong) IBOutlet NSButton *chkReplaceCase;
@property (strong) IBOutlet NSButton *chkReplaceWidth;
//文字数指定削除タブOutlet
@property (strong) IBOutlet NSPopUpButton *popDelPoint_strCnt;
@property (strong) IBOutlet NSTextField *txtDelSPoint;
@property (strong) IBOutlet NSTextField *txtDelCntStr;
//連番処理タブOutlet
@property (strong) IBOutlet NSPopUpButton *popCommandRange_serialNum;
@property (strong) IBOutlet NSPopUpButton *popAddToWhere_serialNum;
@property (strong) IBOutlet NSPopUpButton *popAddToPoint_serialNum;
@property (strong) IBOutlet NSTextField *txtAddToFront_serialNum;
@property (strong) IBOutlet NSTextField *txtAddToEnd_serialNum;
@property (strong) IBOutlet NSTextField *txtFirstNum;
@property (strong) IBOutlet NSTextField *txtFigure;
@property (strong) IBOutlet NSTextField *txtIncrement;
@property (strong) IBOutlet NSTextField *txtAddToPoint_serialNum;
@property (strong) IBOutlet NSButton *chkPermitOverlap_serialNum;
//連番増減タブOutlet
@property (strong) IBOutlet NSPopUpButton *popNumLocate;
@property (strong) IBOutlet NSTextField *txtNumStartPoint;
@property (strong) IBOutlet NSTextField *txtNumFigure;
@property (strong) IBOutlet NSTextField *txtNumIncrement;
//日付処理タブOutlet
@property (strong) IBOutlet NSPopUpButton *popCommandRange_date;
@property (strong) IBOutlet NSPopUpButton *popUsedDate;
@property (strong) IBOutlet NSPopUpButton *popAddToWhere_date;
@property (strong) IBOutlet NSPopUpButton *popAddToPoint_date;
@property (strong) IBOutlet NSTextField *txtAddToFront_date;
@property (strong) IBOutlet NSTextField *txtAddToEnd_date;
@property (strong) IBOutlet NSTextField *txtFormatter;
@property (strong) IBOutlet NSTextField *txtAddToPoint_date;
@property (strong) IBOutlet NSTextField *txtSampleDate;
@property (strong) IBOutlet NSButton *chkPermitOverlap_date;
//親フォルダタブOutlet
@property (strong) IBOutlet NSTextField *txtDirPosition;
@property (strong) IBOutlet NSPopUpButton *popUseStr;
@property (strong) IBOutlet NSPopUpButton *popUsePoint;
@property (strong) IBOutlet NSTextField *txtUseStart;
@property (strong) IBOutlet NSTextField *txtUseLength;
@property (strong) IBOutlet NSTextField *txtAddToFront_par;
@property (strong) IBOutlet NSTextField *txtAddToEnd_par;
@property (strong) IBOutlet NSPopUpButton *popAddToWhere_par;
@property (strong) IBOutlet NSPopUpButton *popAddToPoint_par;
@property (strong) IBOutlet NSTextField *txtAddToPoint_par;
@property (strong) IBOutlet NSButton *chkPermitOverlap_par;
//区切り文字タブOutlet
@property (strong) IBOutlet NSPopUpButton *popSeparator;
@property (strong) IBOutlet NSTextField *txtSeparator;
@property (assign) IBOutlet NSTextFieldCell *txtRep_sep;
//テキスト整形タブOutlet
@property (strong) IBOutlet NSPopUpButton *popFormText;
//マクロタブOutlet
@property (strong) IBOutlet NSTableView *tblSettedPreset;
@property (strong) IBOutlet NSButton *pshSelectDelPreset;
@property (strong) IBOutlet NSButton *pshAllDelPreset;
//ダイアログOutlet
@property (unsafe_unretained) IBOutlet NSWindow *genericDialog;
//ログウインドウOutlet
@property (unsafe_unretained)IBOutlet NSWindow *winLog;
@property (strong) IBOutlet NSButton *chkAll_logWin;
@property (strong) IBOutlet NSButton *pshLogSelectDel;
@property (strong) IBOutlet NSButton *pshRestore;
@property (strong) IBOutlet NSSearchField *srcField;
//フォーマット記述子一覧
@property (strong) IBOutlet NSDrawer *formatterDrawer;
//マクロパネルOutlet
@property (strong) IBOutlet NSTreeController *treeController;
@property (unsafe_unretained) IBOutlet NSPanel *winMacro;
@property (strong) IBOutlet NSOutlineView *macroView;
@property (strong) IBOutlet NSPopUpButton *M_popCommand;
//マクロパネル-指定文字列追加タブOutlet
@property (strong) IBOutlet NSTextField *M_txtAddStr;
@property (strong) IBOutlet NSPopUpButton *M_popAddToWhere;
@property (strong) IBOutlet NSPopUpButton *M_popAddToPoint;
@property (strong) IBOutlet NSTextField *M_txtAddToPoint;
@property (strong) IBOutlet NSStepper *M_stpAddToPoint;
@property (strong) IBOutlet NSButton *M_chkPermitOverlap_add;
//マクロパネル-指定文字列削除タブOutlet
@property (strong) IBOutlet NSTextField *M_txtDelStr;
@property (strong) IBOutlet NSPopUpButton *M_popDelFrom;
@property (strong) IBOutlet NSButton *M_chkDelCase;
@property (strong) IBOutlet NSButton *M_chkDelWidth;
//マクロパネル-指定文字列検索置換タブOutlet
@property (strong) IBOutlet NSTextField *M_txtFindStr;
@property (strong) IBOutlet NSTextField *M_txtReplaceStr;
@property (strong) IBOutlet NSButton *M_chkReplaceCase;
@property (strong) IBOutlet NSButton *M_chkReplaceWidth;
//マクロパネル-文字数指定削除タブOutlet
@property (strong) IBOutlet NSPopUpButton *M_popDelPoint_strCnt;
@property (strong) IBOutlet NSTextField *M_txtDelSPoint;
@property (strong) IBOutlet NSStepper *M_stpDelSpoint;
@property (strong) IBOutlet NSTextField *M_txtDelCntStr;
@property (strong) IBOutlet NSStepper *M_stpDelCntStr;
//マクロパネル-連番処理タブOutlet
@property (strong) IBOutlet NSPopUpButton *M_popCommandRange_serialNum;
@property (strong) IBOutlet NSPopUpButton *M_popAddToWhere_serialNum;
@property (strong) IBOutlet NSPopUpButton *M_popAddToPoint_serialNum;
@property (strong) IBOutlet NSTextField *M_txtAddToFront_serialNum;
@property (strong) IBOutlet NSTextField *M_txtAddToEnd_serialNum;
@property (strong) IBOutlet NSTextField *M_txtFirstNum;
@property (strong) IBOutlet NSStepper *M_stpFirstNum;
@property (strong) IBOutlet NSTextField *M_txtFigure;
@property (strong) IBOutlet NSStepper *M_stpFigure;
@property (strong) IBOutlet NSTextField *M_txtIncrement;
@property (strong) IBOutlet NSStepper *M_stpIncrement;
@property (strong) IBOutlet NSTextField *M_txtAddToPoint_serialNum;
@property (strong) IBOutlet NSStepper *M_stpAddToPoint_serialNum;
@property (strong) IBOutlet NSButton *M_chkPermitOverlap_serialNum;
//マクロパネル-連番増減タブOutlet
@property (strong) IBOutlet NSPopUpButton *M_popNumLocate;
@property (strong) IBOutlet NSTextField *M_txtNumStartPoint;
@property (assign) IBOutlet NSStepper *M_stpStartPoint_num;
@property (strong) IBOutlet NSTextField *M_txtNumFigure;
@property (assign) IBOutlet NSStepper *M_stpLength_num;
@property (strong) IBOutlet NSTextField *M_txtNumIncrement;
@property (assign) IBOutlet NSStepper *M_stpIncrement_num;
//マクロパネル-日付処理タブOutlet
@property (strong) IBOutlet NSPopUpButton *M_popCommandRange_date;
@property (strong) IBOutlet NSPopUpButton *M_popUsedDate;
@property (strong) IBOutlet NSPopUpButton *M_popAddToWhere_date;
@property (strong) IBOutlet NSPopUpButton *M_popAddToPoint_date;
@property (strong) IBOutlet NSTextField *M_txtAddToFront_date;
@property (strong) IBOutlet NSTextField *M_txtAddToEnd_date;
@property (strong) IBOutlet NSTextField *M_txtFormatter;
@property (strong) IBOutlet NSTextField *M_txtAddToPoint_date;
@property (strong) IBOutlet NSTextField *M_txtSampleDate;
@property (strong) IBOutlet NSStepper *M_stpAddToPoint_date;
@property (strong) IBOutlet NSButton *M_chkPermitOverlap_date;
//マクロパネル-親フォルダ名処理タブOutlet
@property (strong) IBOutlet NSTextField *M_txtDirPosition;
@property (assign) IBOutlet NSStepper *M_stpParLocate;
@property (strong) IBOutlet NSPopUpButton *M_popUseStr;
@property (strong) IBOutlet NSPopUpButton *M_popUsePoint;
@property (strong) IBOutlet NSTextField *M_txtUseStart;
@property (strong) IBOutlet NSStepper *M_stpUsePoint;
@property (strong) IBOutlet NSTextField *M_txtUseLength;
@property (strong) IBOutlet NSStepper *M_stpUseLength;
@property (strong) IBOutlet NSTextField *M_txtAddToFront_par;
@property (strong) IBOutlet NSTextField *M_txtAddToEnd_par;
@property (strong) IBOutlet NSPopUpButton *M_popAddToWhere_par;
@property (strong) IBOutlet NSPopUpButton *M_popAddToPoint_par;
@property (strong) IBOutlet NSTextField *M_txtAddToPoint_par;
@property (strong) IBOutlet NSStepper *M_stpAddToPoint_par;
@property (strong) IBOutlet NSButton *M_chkPermitOverlap_par;
//マクロパネル-区切り文字タブOutlet
@property (assign) IBOutlet NSPopUpButton *M_popSeparator;
@property (assign) IBOutlet NSTextField *M_txtSeparator;
@property (assign) IBOutlet NSTextField *M_txtRep_sep;
//マクロパネル-テキスト整形タブOutlet
@property (assign) IBOutlet NSPopUpButton *M_popFormTxt;
//処理終了ダイアログOutlet
@property (unsafe_unretained) IBOutlet NSWindow *winEndDialog;
//プリセット名取得ダイアログOutlet
@property (strong) IBOutlet NSButton *pshOK_presetNameDialog;
//メニューアイテムOutlet
@property (strong) IBOutlet NSMenuItem *mnLogSelectDel;
@property (strong) IBOutlet NSMenuItem *mnLogAllDel;
@property (strong) IBOutlet NSMenuItem *mnMacroSelectDel;
@property (strong) IBOutlet NSMenuItem *mnMacroAllDel;
@property (strong) IBOutlet NSMenuItem *mnMSet;
@property (strong) IBOutlet NSMenuItem *mnMUpdata;
@property (strong) IBOutlet NSMenuItem *mnMGroup;
@property (strong) IBOutlet NSMenuItem *mnMNew;
@property (strong) IBOutlet NSMenuItem *mnMCopy;
@property (strong) IBOutlet NSMenuItem *mnMDel;
@property (strong) IBOutlet NSMenuItem *mnReadPreset;
@property (strong) IBOutlet NSMenuItem *mnSavePreset;

@property (assign,nonatomic)int originX,originY,originW,originH,fileListPreview;
@property (readwrite,retain,nonatomic) NSMutableArray *dataList;
@property (readwrite,retain,nonatomic) NSMutableArray *errList;
@property (readwrite,retain,nonatomic) NSMutableArray *commandList;
@property (readwrite,retain,nonatomic) NSMutableArray *logFileList;
@property (readwrite,retain,nonatomic) NSMutableArray *logList;
@property (readwrite,retain,nonatomic) NSArray *formatterList;
@property (readwrite,retain,nonatomic) NSMutableArray *filteredLog;
@property (readwrite,retain,nonatomic) NSString *logPath;
@property (readwrite,retain,nonatomic) NSString *orgPresetFile; //読み込みプリセットのオリジナルファイルパス保持用
@property (readwrite,assign,nonatomic) NSString *newfName; //読み込みプリセットの新ファイル名保持用
@property (readwrite,retain,nonatomic) NSMutableArray *allPresets;
@property (readwrite,retain,nonatomic) NSMutableArray *settedPresets;
@property (readwrite,retain,nonatomic) NSMutableArray *contents;

-(void)reloadTable;
-(void)reloadLogFileTable;
-(void)reloadLogTable;
-(void)reloadSettedMacro;
-(void)activateToolButton:(BOOL)status;
-(BOOL)checkInput;
-(void)showPrefWindow;
-(void)endPrefWin;
-(void)showEndDialog:(NSWindow*)parWin saveErr:(BOOL)bSaveErr withText:(NSString*)text;
-(void)showEndMDialog:(BOOL)bSaveErr withText:(NSString*)text;
-(void)showLogWin;
-(void)showDialog:(NSWindow*)parWin actionName:(NSInteger)aTag withText:(NSString*)text withIcon:(NSString*)icnName;
-(void)showGetPresetName;
-(void)filterTableData:(NSString*)filterStr;
-(void)makePresetAddStr;
-(void)makePresetDelStr;
-(void)makePresetFindAndReplace;
-(void)makePresetPointDel;
-(void)makePresetSerialNum;
-(void)makePresetDate;

@end