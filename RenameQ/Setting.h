//
//  Setting.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/06/27.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Setting : NSObject<NSCoding>{
    NSString *strAdd;
    IBOutlet NSTextField *txtLogLocate;
    IBOutlet NSTextField *txtMacroLocate;
    IBOutlet NSButton *chkFileListPreview;
    IBOutlet NSButton *chkSaveWin;
    IBOutlet NSButton *chkEndDialogOff;
}

@property(assign,nonatomic)id defaultLogLocate;
@property(assign,nonatomic)id defaultMacroLocate;
@property(retain,nonatomic)id tempLogLocate;
@property(retain,nonatomic)id tempMacroLocate;
@property(assign,nonatomic)NSNumber *defaultFileListPreview;
@property(assign,nonatomic)NSNumber *defaultSaveWin;
@property(assign,nonatomic)NSInteger defaultEndDialogOff;
@property(assign,nonatomic)NSNumber *tempProcessLockedFile;
@property(assign,nonatomic)NSNumber *tempFileListPreview;
@property(assign,nonatomic)NSNumber *tempSaveWin;
@property(assign,nonatomic)NSInteger tempEndDialogOff;

@end
