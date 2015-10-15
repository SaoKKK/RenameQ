//
//  SettedPresetDS.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/05.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettedPresetDS : NSObject{
    IBOutlet NSTableView *tblSettedPreset;
    NSIndexSet *dragRows; //ドラッグ中の行を保持
}

@end
