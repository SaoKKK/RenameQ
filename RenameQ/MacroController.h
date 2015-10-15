//
//  MacroController.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/01.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeModel;

@interface MacroController : NSObject<NSOutlineViewDelegate> {
    NSString *dirPath;
    NSString *orgName;
    NSMutableSet *selectedPresets;
    BOOL presetSelected;
    //アウトライビューボタンOutlet
    IBOutlet NSButton *pshSetPreset;
    IBOutlet NSButton *pshUpdataPreset;
    IBOutlet NSButton *pshCopyPreset;
    IBOutlet NSButton *pshDelPreset;
    IBOutlet NSOutlineView *macroView;
    IBOutlet NSTreeController *treeController;
}

@property (strong) IBOutlet NSTabView *tabCommands;
@property (strong) NSArray *dragNodesArray; //ドラッグ中のノードを保持

- (void)saveMacro:(NSString*)path overWrite:(BOOL)bOverWrite asNewPreset:(BOOL)asNewPreset;
- (void)addGroup:(NSString*)aName selectParent:(BOOL)select haveParent:(BOOL)bHaveParent;
- (void)addPreset:(NSString*)aName selectParent:(BOOL)select haveParent:(BOOL)bHaveParent;
- (void)copyPresetData:(BOOL)bOverWrite;
- (void)setSettedPresets;
- (void)updataPreset;
- (void)copyPreset;
- (void)deleteSelections;
- (void)saveMacroArray;
- (void)savePreset;
- (void)readPreset;
@end
