//
//  MacroController.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/01.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "MacroController.h"
#import "RNQAppDelegate.h"
#import "Setting.h"
#import "TreeModel.h"
#import "GenericMethods.h"
#import "CCImageAndTextCell.h"

#define NodesPBoardType @"RNQNodesPBoardType"

static const int inputErr = 104;
static const int renamePreset = 105;
static const NSInteger copyPreset = 109;

@implementation MacroController

@synthesize tabCommands;

-(id)init{
    self = [super init];
    if (self) {
        orgName = @"";
        presetSelected = NO;
        selectedPresets = [[NSMutableSet set]retain];
    }
    return self;
}

- (void)dealloc{
    [orgName release];
    [selectedPresets release];
    [super dealloc];
}

- (void)awakeFromNib{
    [macroView setTarget:self];
    // ダブルクリック時に呼ばれるメソッドを指定
    [macroView setDoubleAction:@selector(doubleAction:)];
    //初期データをアウトラインビューにセット
    NSArray *entries = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"macroArray" ofType: @"array"]]retain];
    [self addEntries:entries selectParent:NO haveParent:NO];
    [macroView deselectAll:Nil];
    [macroView expandItem:nil expandChildren:YES];
    //ドラッグ＆ドロップできるデータタイプを指定
    [macroView registerForDraggedTypes:[NSArray arrayWithObjects:NodesPBoardType, nil]];
    [macroView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

#pragma mark - Window controll

//タブの切り換え
- (IBAction)popCommand:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [tabCommands selectTabViewItemAtIndex:[sender indexOfSelectedItem]];
    [appD.formatterDrawer close];
}

//各アウトレット値初期化
- (void)allClear{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appD.M_popCommand selectItem:nil];
    [tabCommands selectTabViewItemAtIndex:10];
    [appD.M_txtAddStr setStringValue:@""];
    [appD.M_popAddToWhere selectItemAtIndex:0];
    [appD.M_popAddToPoint selectItemAtIndex:0];
    [appD.M_txtAddToPoint setStringValue:@"2"];
    [appD.M_stpAddToPoint setIntValue:2];
    [appD.M_chkPermitOverlap_add setState:0];
    [self popAddToWhere:appD.M_popAddToWhere];
    //指定文字列削除タブOutlet
    [appD.M_txtDelStr setStringValue:@""];
    [appD.M_popDelFrom selectItemAtIndex:0];
    [appD.M_chkDelCase setState:1];
    [appD.M_chkDelWidth setState:1];
    //指定文字列検索置換タブOutlet
    [appD.M_txtFindStr setStringValue:@""];
    [appD.M_txtReplaceStr setStringValue:@""];
    [appD.M_chkReplaceCase setState:1];
    [appD.M_chkReplaceWidth setState:1];
    //文字数指定削除タブOutlet
    [appD.M_popDelPoint_strCnt selectItemAtIndex:0];
    [appD.M_txtDelSPoint setStringValue:@"1"];
    [appD.M_stpDelSpoint setIntValue:1];
    [appD.M_txtDelCntStr setStringValue:@"1"];
    [appD.M_stpDelCntStr setIntValue:1];
    //連番処理タブOutlet
    [appD.M_popCommandRange_serialNum selectItemAtIndex:0];
    [appD.M_popAddToWhere_serialNum selectItemAtIndex:0];
    [appD.M_popAddToPoint_serialNum selectItemAtIndex:0];
    [appD.M_txtAddToFront_serialNum setStringValue:@""];
    [appD.M_txtAddToEnd_serialNum setStringValue:@""];
    [appD.M_txtFirstNum setStringValue:@"1"];
    [appD.M_stpFirstNum setIntValue:1];
    [appD.M_txtFigure setStringValue:@"3"];
    [appD.M_stpFigure setIntValue:3];
    [appD.M_txtIncrement setStringValue:@"1"];
    [appD.M_stpIncrement setIntValue:1];
    [appD.M_txtAddToPoint_serialNum setStringValue:@"2"];
    [appD.M_stpAddToPoint_serialNum setIntValue:2];
    [appD.M_chkPermitOverlap_serialNum setState:0];
    [self popAddToWhere_serialNum:appD.M_popAddToWhere_serialNum];
    [self popCommandRange_serialNum:appD.M_popCommandRange_serialNum];
    //連番増減タブOutlet
    [appD.M_popNumLocate selectItemAtIndex:0];
    [appD.M_txtNumStartPoint setStringValue:@"1"];
    [appD.M_stpStartPoint_num setIntValue:1];
    [appD.M_txtNumFigure setStringValue:@"1"];
    [appD.M_stpLength_num setIntValue:1];
    [appD.M_txtNumIncrement setStringValue:@"1"];
    [appD.M_stpIncrement_num setIntValue:1];
    //日付処理タブOutlet
    [appD.M_popCommandRange_date selectItemAtIndex:0];
    [appD.M_popUsedDate selectItemAtIndex:0];
    [appD.M_popAddToWhere_date selectItemAtIndex:0];
    [appD.M_popAddToPoint_date selectItemAtIndex:0];
    [appD.M_txtAddToFront_date setStringValue:@""];
    [appD.M_txtAddToEnd_date setStringValue:@""];
    [appD.M_txtFormatter setStringValue:@""];
    [appD.M_txtAddToPoint_date setStringValue:@"2"];
    //現在日時から文字列を作成してセット
    [appD.M_txtSampleDate setStringValue:[GenericMethods dateString:@"yyyy年MM月dd日(E) HH時mm分ss秒"]];
    [appD.M_stpAddToPoint_date setIntValue:2];
    [appD.M_chkPermitOverlap_date setState:0];
    [self popAddToWhere_date:appD.M_popAddToWhere_date];
    [self popCommandRange_date:appD.M_popCommandRange_date];
    //親フォルダ処理タブOutlet
    [appD.M_txtDirPosition setStringValue:@"1"];
    [appD.M_stpParLocate setIntValue:1];
    [appD.M_popUseStr selectItemAtIndex:0];
    [appD.M_popUsePoint selectItemAtIndex:0];
    [appD.M_txtUseStart setStringValue:@"1"];
    [appD.M_stpUsePoint setIntValue:1];
    [appD.M_txtUseLength setStringValue:@"1"];
    [appD.M_stpUseLength setIntValue:1];
    [self popUseStr:appD.M_popUsePoint];
    [appD.M_txtAddToFront_par setStringValue:@""];
    [appD.M_txtAddToEnd_par setStringValue:@""];
    [appD.M_popAddToWhere_par selectItemAtIndex:0];
    [appD.M_popAddToPoint_par selectItemAtIndex:0];
    [appD.M_txtAddToPoint_par setStringValue:@"2"];
    [appD.M_stpAddToPoint_par setIntValue:2];
    [appD.M_chkPermitOverlap_par setState:0];
    [self popAddToWhere_par:appD.M_popAddToWhere_par];
    //区切り文字タブOutlet
    [appD.M_popSeparator selectItemAtIndex:0];
    [appD.M_txtSeparator setStringValue:@""];
    [appD.M_txtRep_sep setStringValue:@""];
    [appD.M_txtRep_sep setEnabled:YES];
    //テキスト整形タブOutlet
    [appD.M_popFormTxt selectItemAtIndex:0];
}

//文字列追加タブ　追加箇所指定ブロックの使用可／不可の変更
- (IBAction)popAddToWhere:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] == 2){
        [appD.M_popAddToPoint setEnabled:YES];
        [appD.M_txtAddToPoint setEnabled:YES];
        [appD.M_stpAddToPoint setEnabled:YES];
    } else {
        [appD.M_popAddToPoint setEnabled:NO];
        [appD.M_txtAddToPoint setEnabled:NO];
        [appD.M_stpAddToPoint setEnabled:NO];
    }
}

//連番処理タブ　付加先ブロックの使用可／不可の変更
- (IBAction)popCommandRange_serialNum:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem]==1) {
        [appD.M_popAddToWhere_serialNum setEnabled:YES];
        [appD.M_chkPermitOverlap_serialNum setEnabled:YES];
        if ([appD.M_popAddToWhere_serialNum indexOfSelectedItem]==2) {
            [appD.M_popAddToPoint_serialNum setEnabled:YES];
            [appD.M_stpAddToPoint_serialNum setEnabled:YES];
            [appD.M_txtAddToPoint_serialNum setEnabled:YES];
        }else{
            [appD.M_popAddToPoint_serialNum setEnabled:NO];
            [appD.M_stpAddToPoint_serialNum setEnabled:NO];
            [appD.M_txtAddToPoint_serialNum setEnabled:NO];
        }
    }else{
        [appD.M_popAddToWhere_serialNum setEnabled:NO];
        [appD.M_chkPermitOverlap_serialNum setEnabled:NO];
        [appD.M_popAddToPoint_serialNum setEnabled:NO];
        [appD.M_stpAddToPoint_serialNum setEnabled:NO];
        [appD.M_txtAddToPoint_serialNum setEnabled:NO];
        [appD.M_chkPermitOverlap_serialNum setEnabled:NO];
    }
}

//日付処理タブ　付加先ブロックの使用可／不可の変更
- (IBAction)popCommandRange_date:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem]==1) {
        [appD.M_popAddToWhere_date setEnabled:YES];
        [appD.M_chkPermitOverlap_date setEnabled:YES];
        if ([appD.M_popAddToWhere_date indexOfSelectedItem]==2) {
            [appD.M_popAddToPoint_date setEnabled:YES];
            [appD.M_stpAddToPoint_date setEnabled:YES];
            [appD.M_txtAddToPoint_date setEnabled:YES];
        }else{
            [appD.M_popAddToPoint_date setEnabled:NO];
            [appD.M_stpAddToPoint_date setEnabled:NO];
            [appD.M_txtAddToPoint_date setEnabled:NO];
        }
    }else{
        [appD.M_popAddToWhere_date setEnabled:NO];
        [appD.M_chkPermitOverlap_date setEnabled:NO];
        [appD.M_popAddToPoint_date setEnabled:NO];
        [appD.M_stpAddToPoint_date setEnabled:NO];
        [appD.M_txtAddToPoint_date setEnabled:NO];
    }
}

//連番処理タブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_serialNum:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] == 2){
        [appD.M_popAddToPoint_serialNum setEnabled:YES];
        [appD.M_txtAddToPoint_serialNum setEnabled:YES];
        [appD.M_stpAddToPoint_serialNum setEnabled:YES];
    } else {
        [appD.M_popAddToPoint_serialNum setEnabled:NO];
        [appD.M_txtAddToPoint_serialNum setEnabled:NO];
        [appD.M_stpAddToPoint_serialNum setEnabled:NO];
    }
}

//日付処理タブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_date:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] == 2){
        [appD.M_popAddToPoint_date setEnabled:YES];
        [appD.M_txtAddToPoint_date setEnabled:YES];
        [appD.M_stpAddToPoint_date setEnabled:YES];
    } else {
        [appD.M_popAddToPoint_date setEnabled:NO];
        [appD.M_txtAddToPoint_date setEnabled:NO];
        [appD.M_stpAddToPoint_date setEnabled:NO];
    }
}

//親フォルダタブ　付加箇所ブロックの使用可／不可の変更
- (IBAction)popAddToWhere_par:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] == 2){
        [appD.M_popAddToPoint_par setEnabled:YES];
        [appD.M_txtAddToPoint_par setEnabled:YES];
        [appD.M_stpAddToPoint_par setEnabled:YES];
    } else {
        [appD.M_popAddToPoint_par setEnabled:NO];
        [appD.M_txtAddToPoint_par setEnabled:NO];
        [appD.M_stpAddToPoint_par setEnabled:NO];
    }
}

//親フォルダタブ　部分使用ブロックの使用可／不可の変更
- (IBAction)popUseStr:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] == 1) {
        [appD.M_popUsePoint setEnabled:YES];
        [appD.M_txtUseStart setEnabled:YES];
        [appD.M_stpUsePoint setEnabled:YES];
        [appD.M_txtUseLength setEnabled:YES];
        [appD.M_stpUseLength setEnabled:YES];
    }else{
        [appD.M_popUsePoint setEnabled:NO];
        [appD.M_txtUseStart setEnabled:NO];
        [appD.M_stpUsePoint setEnabled:NO];
        [appD.M_txtUseLength setEnabled:NO];
        [appD.M_stpUseLength setEnabled:NO];
    }
}

//区切り文字タブ　置換文字フィールドの使用化／不可の変更
- (IBAction)popSeparator:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([sender indexOfSelectedItem] < 2){
        [appD.M_txtRep_sep setEnabled:YES];
    }else{
        [appD.M_txtRep_sep setEnabled:NO];
    }
}

//フォーマッタ記述子一覧を開く
- (IBAction)M_showformatterWin:(id)sender {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appD.formatterDrawer setParentWindow:appD.winMacro];
    [appD.formatterDrawer openOnEdge:NSMaxXEdge];
}

#pragma mark - Preset Controll

//配列からアウトラインビュー初期コンテンツを作成
- (void)addEntries:(NSArray*)entries selectParent:(BOOL)select haveParent:(BOOL)bHaveParent{
    NSString *name;
    for (id entry in entries) {
        if ([entry objectForKey:@"name"]) {
            //グループに属さないプリセットの場合
            name = [entry objectForKey:@"name"];
            [self addPreset:name selectParent:select haveParent:(BOOL)bHaveParent];
        } else {
            //グループの場合
            name = [entry objectForKey:@"group"];
            NSArray *children = [entry objectForKey:@"entries"];
            if (bHaveParent) {
                //子のグループの場合
                [self addGroup:name selectParent:NO haveParent:(BOOL)bHaveParent];
                //子のノードを追加
                [self addEntries:children selectParent:YES haveParent:YES];
            }else{
                //ルート直下のグループの場合
                [self addGroup:name selectParent:select haveParent:(BOOL)bHaveParent];
                [self addEntries:children selectParent:YES haveParent:YES];
            }
        }
    }
}

//アウトラインビューの選択行変更時＝ボタンの使用可／不可の変更
- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([[macroView selectedRowIndexes]count] == 1) {
        //選択が1行の場合
        [pshSetPreset setEnabled:YES];
        [appD.mnMSet setEnabled:YES];
        NSTreeNode *node = [macroView itemAtRow:[macroView selectedRow]];
        TreeModel *data = [node representedObject];
        if (! data.isLeaf) {
            //グループが選択された
            presetSelected = NO;
            [appD.M_popCommand selectItem:nil];
            [tabCommands selectTabViewItemAtIndex:10];
            [pshUpdataPreset setEnabled:NO];
            [appD.mnMUpdata setEnabled:NO];
            [pshCopyPreset setEnabled:NO];
            [appD.mnMCopy setEnabled:NO];
            [appD.mnSavePreset setEnabled:NO];
        }else{
            //プリセットが選択された
            [pshCopyPreset setEnabled:YES];
            [appD.mnMCopy setEnabled:YES];
            [appD.mnSavePreset setEnabled:YES];
            NSString *name = data.name;
            presetSelected = YES;
            orgName = name;
            //マクロフォルダのパスを取得
            Setting *_setting = [[Setting alloc]init];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *path = [_setting tempMacroLocate];
            if ([fileManager fileExistsAtPath:path]) {
                path = [[path stringByAppendingPathComponent:name]stringByAppendingPathExtension:@"xml"];
                if ([fileManager fileExistsAtPath:path]) {
                    NSArray *array = [NSArray arrayWithContentsOfFile:path];
                    NSDictionary *preset = [NSDictionary dictionaryWithDictionary:[array objectAtIndex:0]];
                    //内容を表示
                    [appD.M_popCommand selectItemAtIndex:[[preset objectForKey:@"commandCode"]intValue]];
                    [tabCommands selectTabViewItemAtIndex:[[preset objectForKey:@"commandCode"]intValue]];
                    switch ([[preset objectForKey:@"commandCode"]intValue]) {
                        case 0:
                            //指定文字列を追加
                            [appD.M_txtAddStr setStringValue:[preset objectForKey:@"addStr"]];
                            [appD.M_popAddToWhere selectItemAtIndex:[[preset objectForKey:@"addToWhere"]intValue]];
                            [appD.M_popAddToPoint selectItemAtIndex:[[preset objectForKey:@"switchCntFrom"]intValue]];
                            [appD.M_txtAddToPoint setStringValue:[preset objectForKey:@"addToPoint"]];
                            [appD.M_chkPermitOverlap_add setState:[[preset objectForKey:@"permitOverlap"]intValue]];
                            [self popAddToWhere:appD.M_popAddToWhere];
                            break;
                        case 1:
                            //指定文字列を削除
                            [appD.M_txtDelStr setStringValue:[preset objectForKey:@"delStr"]];
                            [appD.M_popDelFrom selectItemAtIndex:[[preset objectForKey:@"delPoint"]intValue]];
                            [appD.M_chkDelCase setState:[[preset objectForKey:@"chkDelCase"]intValue]];
                            [appD.M_chkDelWidth setState:[[preset objectForKey:@"chkDelWidth"]intValue]];
                            break;
                        case 2:
                            //指定文字列の検索置換
                            [appD.M_txtFindStr setStringValue:[preset objectForKey:@"findStr"]];
                            [appD.M_txtReplaceStr setStringValue:[preset objectForKey:@"replaceStr"]];
                            [appD.M_chkReplaceCase setState:[[preset objectForKey:@"chkReplaceCase"]intValue]];
                            [appD.M_chkReplaceWidth setState:[[preset objectForKey:@"chkReplaceWidth"]intValue]];
                            break;
                        case 3:
                            //文字数指定削除
                            [appD.M_popDelPoint_strCnt selectItemAtIndex:[[preset objectForKey:@"delPoint_strCnt"]intValue]];
                            [appD.M_txtDelSPoint setStringValue:[preset objectForKey:@"delSPoint"]];
                            [appD.M_txtDelCntStr setStringValue:[preset objectForKey:@"delCntStr"]];
                            break;
                        case 4:
                            //連番処理
                            [appD.M_popCommandRange_serialNum selectItemAtIndex:[[preset objectForKey:@"commandRange"]intValue]];
                            [appD.M_txtAddToFront_serialNum setStringValue:[preset objectForKey:@"addToFront"]];
                            [appD.M_txtAddToEnd_serialNum setStringValue:[preset objectForKey:@"addToEnd"]];
                            [appD.M_txtFirstNum setStringValue:[preset objectForKey:@"firstNum"]];
                            [appD.M_txtFigure setStringValue:[preset objectForKey:@"figure"]];
                            [appD.M_txtIncrement setStringValue:[preset objectForKey:@"increment"]];
                            [appD.M_popAddToWhere_serialNum selectItemAtIndex:[[preset objectForKey:@"addToWhere"]intValue]];
                            [appD.M_popAddToPoint_serialNum selectItemAtIndex:[[preset objectForKey:@"switchCntFrom"]intValue]];
                            [appD.M_txtAddToPoint_serialNum setStringValue:[preset objectForKey:@"addToPoint"]];
                            [appD.M_chkPermitOverlap_serialNum setState:[[preset objectForKey:@"permitOverlap"]intValue]];
                            [self popAddToWhere_serialNum:appD.M_popAddToWhere_serialNum];
                            [self popCommandRange_serialNum:appD.M_popCommandRange_serialNum];
                            break;
                        case 5:
                            //連番の増減
                            [appD.M_popNumLocate selectItemAtIndex:[[preset objectForKey:@"numLocate"]intValue]];
                            [appD.M_txtNumStartPoint setStringValue:[preset objectForKey:@"startPoint"]];
                            [appD.M_txtNumFigure setStringValue:[preset objectForKey:@"figure"]];
                            [appD.M_txtNumIncrement setStringValue:[preset objectForKey:@"increment"]];
                            break;
                        case 6:{
                            //日付処理
                            [appD.M_popCommandRange_date selectItemAtIndex:[[preset objectForKey:@"commandRange"]intValue]];
                            [appD.M_popUsedDate selectItemAtIndex:[[preset objectForKey:@"usedDate"]intValue]];
                            [appD.M_txtAddToFront_date setStringValue:[preset objectForKey:@"addToFront"]];
                            [appD.M_txtAddToEnd_date setStringValue:[preset objectForKey:@"addToEnd"]];
                            [appD.M_txtFormatter setStringValue:[preset objectForKey:@"formatter"]];
                            [appD.M_popAddToWhere_date selectItemAtIndex:[[preset objectForKey:@"addToWhere"]intValue]];
                            [appD.M_popAddToPoint_date selectItemAtIndex:[[preset objectForKey:@"switchCntFrom"]intValue]];
                            [appD.M_txtAddToPoint_date setStringValue:[preset objectForKey:@"addToPoint"]];
                            [appD.M_chkPermitOverlap_date setState:[[preset objectForKey:@"permitOverlap"]intValue]];
                            NSString *dateStr = [GenericMethods dateString:[preset objectForKey:@"formatter"]];
                            [appD.M_txtSampleDate setStringValue:[NSString stringWithFormat:@"%@%@%@",[preset objectForKey:@"addToFront"],dateStr,[preset objectForKey:@"addToEnd"]]];
                            [self popAddToWhere_date:appD.M_popAddToWhere_date];
                            [self popCommandRange_date:appD.M_popCommandRange_date];
                            break;
                        }
                        case 7: //親フォルダ処理
                            [appD.M_txtDirPosition setStringValue:[preset objectForKey:@"dirPosition"]];
                            [appD.M_popUseStr selectItemAtIndex:[[preset objectForKey:@"useStr"]intValue]];
                            [appD.M_popUsePoint selectItemAtIndex:[[preset objectForKey:@"usePointFrom"]intValue]];
                            [appD.M_txtUseStart setStringValue:[preset objectForKey:@"useStart"]];
                            [appD.M_txtUseLength setStringValue:[preset objectForKey:@"useLength"]];
                            [appD.M_txtAddToFront_par setStringValue:[preset objectForKey:@"addToFront"]];
                            [appD.M_txtAddToEnd_par setStringValue:[preset objectForKey:@"addToEnd"]];
                            [appD.M_popAddToWhere_par selectItemAtIndex:[[preset objectForKey:@"addToWhere"]intValue]];
                            [appD.M_popAddToPoint_par selectItemAtIndex:[[preset objectForKey:@"switchCntFrom"]intValue]];
                            [appD.M_txtAddToPoint_par setStringValue:[preset objectForKey:@"addToPoint"]];
                            [appD.M_chkPermitOverlap_par setState:[[preset objectForKey:@"permitOverlap"]intValue]];
                            [self popUseStr:appD.M_popUseStr];
                            [self popAddToWhere_par:appD.M_popAddToWhere_par];
                            break;
                        case 8: //区切り文字処理
                            [appD.M_popSeparator selectItemAtIndex:[[preset objectForKey:@"sepCommand"]integerValue]];
                            [appD.M_txtSeparator setStringValue:[preset objectForKey:@"separator"]];
                            [appD.M_txtRep_sep setStringValue:[preset objectForKey:@"replaceStr"]];
                            break;
                        default: //テキスト整形処理
                            [appD.M_popFormTxt selectItemAtIndex:[[preset objectForKey:@"formTxt"]integerValue]];
                            break;
                    }
                }else{
                    //マクロファイルが存在しない場合＝各アウトレットを初期化
                    [self allClear];
                }
            }
            [pshUpdataPreset setEnabled:YES];
            [appD.mnMUpdata setEnabled:YES];
        }
    }else if ([[macroView selectedRowIndexes]count]>1){
        //選択が複数行の場合
        presetSelected = NO;
        [pshSetPreset setEnabled:YES];
        [appD.mnMSet setEnabled:YES];
        [pshUpdataPreset setEnabled:NO];
        [appD.mnMUpdata setEnabled:NO];
        [pshCopyPreset setEnabled:NO];
        [appD.mnMCopy setEnabled:NO];
        [appD.mnSavePreset setEnabled:NO];
        //各アウトレットを初期化
        [self allClear];
    }else{
        //何も選択されていない場合
        presetSelected = NO;
        [pshSetPreset setEnabled:NO];
        [appD.mnMSet setEnabled:NO];
        [pshUpdataPreset setEnabled:NO];
        [appD.mnMUpdata setEnabled:NO];
        [pshCopyPreset setEnabled:NO];
        [appD.mnMCopy setEnabled:NO];
        [appD.mnSavePreset setEnabled:NO];
        //各アウトレットを初期化
        [self allClear];
    }
}

//プリセットを保存
-(void)saveMacro:(NSString*)path overWrite:(BOOL)bOverWrite asNewPreset:(BOOL)asNewPreset{
    //マクロフォルダのパスを取得
    [self getMacroPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dirPath]==NO) {
        //Macroフォルダが存在しない場合は作成
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSString *macroPath = [[dirPath stringByAppendingPathComponent:path]stringByAppendingPathExtension:@"xml"];
    //重複の確認
    if ((bOverWrite == NO) && ([fileManager fileExistsAtPath:macroPath])){
        [appD showDialog:appD.window actionName:renamePreset withText:@"同名のプリセットが既に存在します。上書きしますか？" withIcon:@"icnCaution"];
    }else{
        //書き出しの実行
        [appD.commandList writeToFile:macroPath atomically:YES];
        if (asNewPreset) {
            //マクロツリーを更新
            [self addPreset:path selectParent:NO haveParent:NO];
        }
    }
}

//プリセットを実行リストにセット
-(void)doubleAction:(id)sender{
    [self setSettedPresets];
}

-(void)setSettedPresets{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    //マクロフォルダのパスを取得
    [self getMacroPath];
    //選択中のプリセットをプールする配列の初期化
    [selectedPresets removeAllObjects];
    //選択中の全プリセットを取得
    NSArray *selectedNodes = [appD.treeController selectedNodes];
    [self getSelectedPresets:selectedNodes];
    //実行リストにセットしてテーブルをリロード
    [self addObjectToSettedPresets];
    [appD reloadSettedMacro];
}

- (void)addObjectToSettedPresets{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //マクロフォルダの実在を確認
    if ([fileManager fileExistsAtPath:dirPath]) {
        for (NSString *preset in selectedPresets) {
            NSString *path = [[dirPath stringByAppendingPathComponent:preset]stringByAppendingPathExtension:@"xml"];
            //マクロファイルの実在を確認
            if ([fileManager fileExistsAtPath:path]) {
                //重複がなかったら実行リストに追加
                if ([appD.settedPresets containsObject:preset] == NO) {
                    [appD.settedPresets addObject:preset];
                }
            }
        }
    }
}

//プリセットを更新
- (void)updataPreset{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSMutableDictionary *preset = [NSMutableDictionary dictionary];
    switch ([appD.M_popCommand indexOfSelectedItem]) {
        case 0:{ //指定文字列追加
            NSString *addStr = [appD.M_txtAddStr stringValue];
            if ([addStr isEqualToString:@""]) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加文字列を入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            NSRange txtSearchRange = [addStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            if (([appD.M_txtAddToPoint isEnabled])&&([[appD.M_txtAddToPoint stringValue]intValue] < 2)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:0] forKey:@"commandCode"];
            [preset setObject:[appD.M_txtAddStr stringValue] forKey:@"addStr"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToWhere indexOfSelectedItem]] forKey:@"addToWhere"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToPoint indexOfSelectedItem]] forKey:@"switchCntFrom"];
            [preset setObject:[appD.M_txtAddToPoint stringValue] forKey:@"addToPoint"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkPermitOverlap_add state]] forKey:@"permitOverlap"];
            break;
        }
        case 1:{ //指定文字列削除
            NSString *delStr = [appD.M_txtDelStr stringValue];
            if ([delStr isEqualToString:@""]) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"削除文字列を入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:1] forKey:@"commandCode"];
            [preset setObject:[appD.M_txtDelStr stringValue] forKey:@"delStr"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popDelFrom indexOfSelectedItem]] forKey:@"delPoint"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkDelCase state]] forKey:@"chkDelCase"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkDelWidth state]] forKey:@"chkDelWidth"];
            break;
        }
        case 2:{ //指定文字列検索置換
            NSString *findStr = [appD.M_txtFindStr stringValue];
            NSString *replaceStr = [appD.M_txtReplaceStr stringValue];
            if ([findStr isEqualToString:@""]){
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"検索文字列を入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if ([replaceStr isEqualToString:@""]) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"置換文字列を入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:2] forKey:@"commandCode"];
            [preset setObject:[appD.M_txtFindStr stringValue] forKey:@"findStr"];
            [preset setObject:[appD.M_txtReplaceStr stringValue] forKey:@"replaceStr"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkReplaceCase state]] forKey:@"chkReplaceCase"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkReplaceWidth state]] forKey:@"chkReplaceWidth"];
            break;
        }
        case 3: //文字数指定削除
            if (([[appD.M_txtDelSPoint stringValue]intValue]<1)||([[appD.M_txtDelCntStr stringValue]intValue]<1)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"数値を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:3] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popDelPoint_strCnt indexOfSelectedItem]] forKey:@"delPoint_strCnt"];
            [preset setObject:[appD.M_txtDelSPoint stringValue] forKey:@"delSPoint"];
            [preset setObject:[appD.M_txtDelCntStr stringValue] forKey:@"delCntStr"];
            break;
        case 4:{ //連番処理
            NSString *addToFront = [appD.M_txtAddToFront_serialNum stringValue];
            NSString *addToEnd = [appD.M_txtAddToEnd_serialNum stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            if ([[appD.M_txtFirstNum stringValue]intValue]<1) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"最初の番号を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if ([[appD.M_txtFigure stringValue]intValue]<1) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"桁数を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if ([[appD.M_txtIncrement stringValue]intValue]<1) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"増分を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if (([appD.M_txtAddToPoint_serialNum isEnabled])&&([[appD.M_txtAddToPoint_serialNum stringValue]intValue]<2)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:4] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popCommandRange_serialNum indexOfSelectedItem]] forKey:@"commandRange"];
            [preset setObject:addToFront forKey:@"addToFront"];
            [preset setObject:addToEnd forKey:@"addToEnd"];
            [preset setObject:[appD.M_txtFirstNum stringValue] forKey:@"firstNum"];
            [preset setObject:[appD.M_txtFigure stringValue] forKey:@"figure"];
            [preset setObject:[appD.M_txtIncrement stringValue] forKey:@"increment"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToWhere_serialNum indexOfSelectedItem]] forKey:@"addToWhere"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToPoint_serialNum indexOfSelectedItem]] forKey:@"switchCntFrom"];
            [preset setObject:[appD.M_txtAddToPoint_serialNum stringValue] forKey:@"addToPoint"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkPermitOverlap_serialNum state]] forKey:@"permitOverlap"];
            break;
        }
        case 5: //連番の増減
            if (([[appD.M_txtNumStartPoint stringValue]intValue]<1)||([[appD.M_txtNumFigure stringValue]intValue]<1)||([[appD.M_txtNumIncrement stringValue]intValue]==0)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"数値を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:5] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popNumLocate indexOfSelectedItem]] forKey:@"numLocate"];
            [preset setObject:[appD.M_txtNumStartPoint stringValue] forKey:@"startPoint"];
            [preset setObject:[appD.M_txtNumFigure stringValue] forKey:@"figure"];
            [preset setObject:[appD.M_txtNumIncrement stringValue] forKey:@"increment"];
            break;
        case 6:{ //日付処理
            NSString *addToFront = [appD.M_txtAddToFront_date stringValue];
            NSString *addToEnd = [appD.M_txtAddToEnd_date stringValue];
            NSString *formatter = [appD.M_txtFormatter stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
           }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            if ([formatter isEqualToString:@""]){
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"フォーマッタを入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            txtSearchRange = [formatter rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
           }
            if (([appD.M_txtAddToPoint_date isEnabled])&&([[appD.M_txtAddToPoint_date stringValue]intValue]<2)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:6] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popCommandRange_date indexOfSelectedItem]] forKey:@"commandRange"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popUsedDate indexOfSelectedItem]] forKey:@"usedDate"];
            [preset setObject:[appD.M_txtAddToFront_date stringValue] forKey:@"addToFront"];
            [preset setObject:[appD.M_txtAddToEnd_date stringValue] forKey:@"addToEnd"];
            [preset setObject:[appD.M_txtFormatter stringValue] forKey:@"formatter"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToWhere_date indexOfSelectedItem]] forKey:@"addToWhere"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToPoint_date indexOfSelectedItem]] forKey:@"switchCntFrom"];
            [preset setObject:[appD.M_txtAddToPoint_date stringValue] forKey:@"addToPoint"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkPermitOverlap_date state]] forKey:@"permitOverlap"];
            break;
        }
        case 7:{ //親フォルダ処理
            NSString *addToFront = [appD.M_txtAddToFront_par stringValue];
            NSString *addToEnd = [appD.M_txtAddToEnd_par stringValue];
            NSRange txtSearchRange = [addToFront rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            txtSearchRange = [addToEnd rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }

            if ([[appD.M_txtDirPosition stringValue]intValue]<1) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"親フォルダの階層を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if (([appD.M_txtUseStart isEnabled])&&([[appD.M_txtUseStart stringValue]intValue]<1)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            if (([appD.M_txtUseLength isEnabled])&&([[appD.M_txtUseLength stringValue]intValue]<1)) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"追加箇所を正確に入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:7] forKey:@"commandCode"];
            [preset setObject:[appD.M_txtDirPosition stringValue] forKey:@"dirPosition"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popUseStr indexOfSelectedItem]] forKey:@"useStr"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popUsePoint indexOfSelectedItem]] forKey:@"usePointFrom"];
            [preset setObject:[appD.M_txtUseStart stringValue] forKey:@"useStart"];
            [preset setObject:[appD.M_txtUseLength stringValue] forKey:@"useLength"];
            [preset setObject:[appD.M_txtAddToFront_par stringValue] forKey:@"addToFront"];
            [preset setObject:[appD.M_txtAddToEnd_par stringValue] forKey:@"addToEnd"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToWhere_par indexOfSelectedItem]] forKey:@"addToWhere"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popAddToPoint_par indexOfSelectedItem]] forKey:@"switchCntFrom"];
            [preset setObject:[appD.M_txtAddToPoint_par stringValue] forKey:@"addToPoint"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_chkPermitOverlap_par state]] forKey:@"permitOverlap"];
            break;
            }
        case 8:{ //区切り文字処理
            NSString *separator = [appD.M_txtSeparator stringValue];
            if ([separator isEqualToString:@""]) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"区切り文字を入力して下さい" withIcon:@"icnCaution"];
                return;
            }
            NSString *replaceStr = [appD.M_txtRep_sep stringValue];
            NSRange txtSearchRange = [replaceStr rangeOfString:@":"];
            if (txtSearchRange.location != NSNotFound) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"ファイル名にコロン(:)を使用することはできません" withIcon:@"icnCaution"];
                return;
            }
            [preset setObject:[NSNumber numberWithInt:8] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popSeparator indexOfSelectedItem]] forKey:@"sepCommand"];
            [preset setObject:[appD.M_txtSeparator stringValue] forKey:@"separator"];
            [preset setObject:[appD.M_txtRep_sep stringValue] forKey:@"replaceStr"];
        }
            break;
        case 9: //テキスト整形処理
            [preset setObject:[NSNumber numberWithInt:9] forKey:@"commandCode"];
            [preset setObject:[NSNumber numberWithInteger:[appD.M_popFormTxt indexOfSelectedItem]] forKey:@"formTxt"];
            break;
        default: //未選択の場合
            [appD showDialog:appD.winMacro actionName:inputErr withText:@"プリセットの内容を設定してください" withIcon:@"icnCaution"];
            break;
    }
    //プリセットをcommandListに追加
    [appD.commandList removeAllObjects];
    [appD.commandList addObject:preset];
    //保存実処理
    NSTreeNode *node = [appD.macroView itemAtRow:[appD.macroView selectedRow]];
    TreeModel *data = [node representedObject];
    NSString *path = data.name;
    [self saveMacro:path overWrite:YES asNewPreset:NO];
}

//グループのノードを作成
- (void)addGroup:(NSString*)aName selectParent:(BOOL)select haveParent:(BOOL)bHaveParent{
    TreeModel *nodeData = [TreeModel nodeDataWithName:aName withLeaf:NO selectParent:select haveParent:(BOOL)bHaveParent];
    [self addNewDataToSelection:nodeData];
}

//プリセットのノードを作成
- (void)addPreset:(NSString*)aName selectParent:(BOOL)select haveParent:(BOOL)bHaveParent{
    TreeModel *nodeData = [TreeModel nodeDataWithName:aName withLeaf:YES selectParent:select haveParent:(BOOL)bHaveParent];
    [self addNewDataToSelection:nodeData];
    //全プリセット保持用配列にセット
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    [appD.allPresets addObject:aName];
    }

//アウトラインビューにデータを追加
- (void)addNewDataToSelection:(TreeModel *)newChildData {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSIndexPath *indexPath = nil;
    TreeModel *selectedNode;
    //何も選択されていない場合
    if ([[appD.treeController selectedObjects]count] == 0) {
        indexPath = [NSIndexPath indexPathWithIndex:[appD.contents count]];
    } else {
        selectedNode = [[appD.treeController selectedObjects] objectAtIndex:0];
        if ([selectedNode isLeaf]){
            //プリセットが選択されている場合は親を選択する
            [self selectParent];
        }
        indexPath = [appD.treeController selectionIndexPath];
        if ([indexPath length] == 0) {
            //親がルートの場合(配列の最初の要素がルート直下のグループの場合ここでindexPathを設定)
            indexPath = [NSIndexPath indexPathWithIndex:[appD.contents count]];
        } else {
            if (! newChildData.haveParent && ! newChildData.selectParent) {
                //ルート直下のグループの場合(配列の後半でルート直下のグループが出てきた場合ここでindexPathを設定)
                indexPath = [NSIndexPath indexPathWithIndex:[appD.contents count]];
            }else{
                //子のグループの場合
                indexPath = [indexPath indexPathByAddingIndex:[[[[appD.treeController selectedObjects] objectAtIndex:0] children] count]];
            }
        }
    }
    //データを追加
    [appD.treeController insertObject:newChildData atArrangedObjectIndexPath:indexPath];
    if ([newChildData selectParent]) {
        [self selectParent];
    }
    //追加行を編集状態にする
    NSInteger selectedRow = [appD.macroView selectedRow];
    if (selectedRow >= 0) {
        [appD.macroView editColumn:0 row:selectedRow withEvent:nil select:YES];
    }
}

//選択行の親を選択する
- (void)selectParent{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    if ([[appD.treeController selectedNodes] count] > 0){
        NSTreeNode *selectedNode = [[appD.treeController selectedNodes] objectAtIndex:0];
        NSTreeNode *parentNode = [selectedNode parentNode];
        //親ノードを選択
        NSIndexPath *parentIndex = [parentNode indexPath];
        [appD.treeController setSelectionIndexPath:parentIndex];
    }
}

//プリセットを複製
-(void)copyPreset{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSTreeNode *node = [appD.macroView itemAtRow:[appD.macroView selectedRow]];
    TreeModel *data = [node representedObject];
    orgName = data.name;
    NSString *newName = [NSString stringWithFormat:@"%@のコピー",orgName];
    [self addPreset:newName selectParent:NO haveParent:NO];
    //プリセットデータを複製
    //マクロフォルダのパスを取得
    [self getMacroPath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //マクロフォルダの実在を確認
    if ([fileMgr fileExistsAtPath:dirPath]) {
        //オリジナルデータの実在を確認
        NSString *orgPath = [[dirPath stringByAppendingPathComponent:orgName]stringByAppendingPathExtension:@"xml"];
        if ([fileMgr fileExistsAtPath:orgPath]) {
            [fileMgr copyItemAtPath:orgPath toPath:[[dirPath stringByAppendingPathComponent:newName]stringByAppendingPathExtension:@"xml"] error:nil];
        }
    }
}

//プリセットを削除
- (void)deleteSelections {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSArray *selectedNodes = [appD.treeController selectedNodes];
    //選択中のプリセットをプールする配列の初期化
    [selectedPresets removeAllObjects];
    //選択中の全プリセットを取得
    [self getSelectedPresets:selectedNodes];
    //プリセットを削除する
    [self deletePresets:selectedPresets];
    //アウトラインビューから項目を削除する
    [appD.treeController remove:selectedNodes];
}

//プリセットファイルを削除
- (void)deletePresets:(NSMutableSet*)pathSet{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //マクロフォルダのパスを取得
    [self getMacroPath];
    if ([fileManager fileExistsAtPath:dirPath]) {
        for (NSString* name in pathSet) {
            //全プリセット保持配列から削除
            NSUInteger arrIndex = [appD.allPresets indexOfObject:name];
            [appD.allPresets removeObjectAtIndex:arrIndex];
            if (![appD.allPresets containsObject:name]) {
                //同名のプリセットが他にない場合はマクロファイルを削除
                NSString *path = [[dirPath stringByAppendingPathComponent:name]stringByAppendingPathExtension:@"xml"];
                //マクロファイルの実在を確認して削除
                if ([fileManager fileExistsAtPath:path]) {
                    [fileManager removeItemAtPath:path error:nil];
                    //実行リストからプリセットを削除
                    [appD.settedPresets removeObject:name];
                    [appD reloadSettedMacro];
                }
            }
        }
    }
}

//選択中の全プリセットを取得
- (void)getSelectedPresets:(NSArray*)selectedNodes{
    TreeModel *selectedPreset;
    for (NSTreeNode *selectedNode in selectedNodes) {
        selectedPreset = [selectedNode representedObject];
        if ([selectedPreset isLeaf]) {
            //プリセットの場合
            [selectedPresets addObject:selectedPreset.name];
        } else {
            //グループの場合＝子のプリセットを全て取得
            [self getSelectedPresets:[selectedNode childNodes]];
        }
    }
}

//マクロフォルダのパスを取得
- (void)getMacroPath{
    Setting *_setting = [[Setting alloc]init];
    dirPath = [_setting tempMacroLocate];
}

//アウトラインビューのソース配列を保存
- (void)saveMacroArray{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSMutableArray *entries = [NSMutableArray array];
    entries = [NSMutableArray arrayWithArray:[self arrayFromTreeNode:appD.contents]];
    [entries writeToFile:[[NSBundle mainBundle] pathForResource:@"macroArray" ofType: @"array"] atomically:YES];
}
//ツリーノードから配列を作成
- (NSArray*)arrayFromTreeNode:(NSArray*)nodes{
    NSMutableDictionary *entry;
    NSMutableArray *children = [NSMutableArray array];
    for (TreeModel* node in nodes) {
        if ([node isLeaf]) {
            //プリセットの場合
            entry = [NSMutableDictionary dictionary];
            [entry setObject:node.name forKey:@"name"];
        }else{
            //グループの場合
            entry = [NSMutableDictionary dictionary];
            [entry setObject:node.name forKey:@"group"];
            [entry setObject:[self arrayFromTreeNode:[node children]] forKey:@"entries"];
        }
        [children addObject:entry];
    }
    return children;
}

//プリセットの書き出し
- (void)savePreset{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *selectedNodes = [appD.treeController selectedNodes];
    TreeModel *selectedNode = [[selectedNodes objectAtIndex:0]representedObject];
    //マクロフォルダのパスを取得して実在を確認
    [self getMacroPath];
    if ([fileMgr fileExistsAtPath:dirPath]) {
        //マクロファイルの実在を確認
        NSString *fName = [NSString stringWithFormat:@"%@.xml",selectedNode.name];
        NSString *presetPath = [dirPath stringByAppendingPathComponent:fName];
        if ([fileMgr fileExistsAtPath:presetPath]) {
            NSSavePanel *savePanel	= [NSSavePanel savePanel];
            NSArray *FileType=[NSArray arrayWithObjects:@"xml",nil];
            [savePanel setAllowedFileTypes:FileType];
            [savePanel setExtensionHidden:NO];
            [savePanel setNameFieldStringValue:fName];
            [savePanel setCanCreateDirectories:YES]; //フォルダ作成を可能に設定
            NSInteger pressedButton = [savePanel runModal];
            if (pressedButton == NSOKButton){
                //パスを取得
                NSString *filePath = [[savePanel URL]path];
                [fileMgr copyItemAtPath:presetPath toPath:filePath error:nil];
            }
        }else{
            [appD showDialog:appD.winMacro actionName:inputErr withText:@"プリセットファイルが実在しません。処理内容を入力してプリセットを更新してください" withIcon:@"icnCaution"];
        }
    }
}

//プリセットの読み込み
- (void)readPreset{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    //選択するファイルの種類の設定
    NSArray *FileType=[NSArray arrayWithObjects:@"xml",nil];
    [openPanel setAllowedFileTypes:FileType];
    [openPanel setCanChooseFiles:YES]; //ファイルの選択を可能に設定
    [openPanel setCanChooseDirectories:NO]; //フォルダの選択を不可に設定
    [openPanel setAllowsMultipleSelection:NO]; //複数選択を不可に設定
    NSInteger pressedButton = [openPanel runModal];
    if(pressedButton == NSOKButton){
        //パスを取得
        NSURL *filePath = [openPanel URL];
        appD.orgPresetFile = [[filePath path]retain]; //ソースファイルパス保持用変数にセット
        appD.newfName = [[appD.orgPresetFile lastPathComponent]retain]; //コピー後のファイル名保持用変数にセット
        //有効なマクロファイルか判定
        NSArray *array = [NSArray arrayWithContentsOfURL:filePath];
        if (array) {
            NSDictionary *preset = [array objectAtIndex:0];
            @try {
                if ([preset objectForKey:@"commandCode"]) {
                    //マクロフォルダのパスを取得して実在を確認
                    [self getMacroPath];
                    if ([fileMgr fileExistsAtPath:dirPath]) {
                        //マクロフォルダの実在を確認
                    }else{
                        //マクロフォルダがない場合は作成
                        [fileMgr createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:NULL];
                    }
                    //ファイルをマクロフォルダにコピー
                    [self copyPresetData:NO];
                    //アウトラインビューに項目を追加
                    NSString *presetName = [appD.newfName stringByDeletingPathExtension];
                    [self addPreset:presetName selectParent:NO haveParent:YES];
                }
            }
            @catch (NSException *exception) {
                [appD showDialog:appD.winMacro actionName:inputErr withText:@"選択されたファイルは有効なマクロファイルではありません" withIcon:@"icnCaution"];
            }
            @finally {
                
            }
        }else{
            [appD showDialog:appD.winMacro actionName:inputErr withText:@"選択されたファイルは有効なマクロファイルではありません" withIcon:@"icnCaution"];
        }
    }
}

//プリセットデータの取り込み実処理
- (void)copyPresetData:(BOOL)bOverWrite{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [self getMacroPath];
    NSString *newPath = [dirPath stringByAppendingPathComponent:appD.newfName];
    //重複の処理
    if ((bOverWrite == NO) && ([fileMgr fileExistsAtPath:newPath])) {
        [appD showDialog:appD.winMacro actionName:copyPreset withText:@"同名のプリセットが既に存在します。上書きしますか？" withIcon:@"icnCaution"];
    }else{
        //重複ファイルを消去
        if ((bOverWrite) && ([fileMgr fileExistsAtPath:newPath])){
            [fileMgr removeItemAtPath:newPath error:nil];
        }
        //コピー実処理
        [fileMgr copyItemAtPath:appD.orgPresetFile toPath:newPath error:nil];
    }
}

#pragma mark - NSOutlineView data source

//アイコンをセット
- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSTreeNode *aNode = [item representedObject];
    NSImage *icon;
    if (aNode){
        if ([item isLeaf]){
            icon = [NSImage imageNamed:@"iconPreset"];
        }else{
            icon = [NSImage imageNamed:@"NSFolder"];
        }
    }
    [[tableColumn dataCell] setImage:icon];
}

//更新の受付
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    TreeModel *nodeData = [item representedObject];
    nodeData.name = object;
    //プリセット名が変更された＝プリセットデータを名称変更
    if (presetSelected) {
        //全プリセット保持配列のプリセット名称を変更
        NSUInteger arrIndex = [appD.allPresets indexOfObject:orgName];
        [appD.allPresets replaceObjectAtIndex:arrIndex withObject:object];
        //マクロフォルダのパスを取得
        [self getMacroPath];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        //マクロフォルダの実在を確認
        if ([fileMgr fileExistsAtPath:dirPath]) {
            //オリジナルデータの実在を確認
            NSString *orgPath = [[dirPath stringByAppendingPathComponent:orgName]stringByAppendingPathExtension:@"xml"];
            if ([fileMgr fileExistsAtPath:orgPath]) {
                [fileMgr moveItemAtPath:orgPath toPath:[[dirPath stringByAppendingPathComponent:nodeData.name]stringByAppendingPathExtension:@"xml"] error:nil];
            }
        }
        //実行リストにセットされている場合は実行リストも更新
        NSUInteger index = [appD.settedPresets indexOfObject:orgName];
        if (index != NSNotFound) {
            [appD.settedPresets replaceObjectAtIndex:index withObject:nodeData.name];
            [appD reloadSettedMacro];
        }
    }
}

#pragma mark - Drag Operation Method

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal{
    return NSDragOperationMove;
}

// ドラッグ（ペーストボードに書き込む）を開始
- (BOOL)outlineView:(NSOutlineView *)ov writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard{
    [pboard setData:[NSData data] forType:NodesPBoardType];
    self.dragNodesArray = items;
    
    return YES;
}

//ドロップを確認
- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    NSDragOperation result = NSDragOperationNone;
    if (!item){
        //ドロップアイテムがない場合
        result = NSDragOperationGeneric;
    }else {
        if (index == -1){
            //子へのドロップを拒否
            result = NSDragOperationNone;
        } else {
            //グループへのドロップ
            result = NSDragOperationMove;
        }
    }
    return result;
}

- (void)handleInternalDrops:(NSPasteboard *)pboard withIndexPath:(NSIndexPath *)indexPath {
    NSArray* newNodes = self.dragNodesArray;
    //項目を移動
    NSInteger idx;
    for (idx = ([newNodes count] - 1); idx >= 0; idx--) {
        [treeController moveNode:[newNodes objectAtIndex:idx] toIndexPath:indexPath];
    }
    //移動中の項目の選択状態を維持
    NSMutableArray *indexPathList = [NSMutableArray array];
    for (NSUInteger i = 0; i < [newNodes count]; i++) {
        [indexPathList addObject:[[newNodes objectAtIndex:i] indexPath]];
    }
    [treeController setSelectionIndexPaths: indexPathList];
}

//ドロップ受付開始
- (BOOL)outlineView:(NSOutlineView*)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(NSInteger)index{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    // note that "targetItem" is a NSTreeNode proxy
    BOOL result = NO;
    
    // find the index path to insert our dropped object(s)
    NSIndexPath *indexPath;
    if (targetItem) {
        // drop down inside the tree node:
        // feth the index path to insert our dropped node
        indexPath = [[targetItem indexPath] indexPathByAddingIndex:index];
    } else {
        // drop at the top root level
        if (index == -1)	// drop area might be ambibuous (not at a particular location)
            indexPath = [NSIndexPath indexPathWithIndex:appD.contents.count]; // drop at the end of the top level
        else
            indexPath = [NSIndexPath indexPathWithIndex:index]; // drop at a particular place at the top level
    }
    NSPasteboard *pboard = [info draggingPasteboard];	//ペーストボードを取得
    //ドラッグ中のデータタイプを確認
    if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NodesPBoardType]]){
        [self handleInternalDrops:pboard withIndexPath:indexPath];
        result = YES;
    }
    return result;
}

@end
