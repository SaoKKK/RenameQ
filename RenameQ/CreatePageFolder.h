//
//  CreatePageFolder.h
//  RenameQ
//
//  Created by os106_06 on 2014/08/28.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreatePageFolder : NSObject{
    NSMutableArray *pgFolders;
    int figure;
    int increment;
    NSMutableString *orgName;
    NSString *path;
    NSString *addToFront, *addToEnd, *separator;
    NSMutableDictionary *data;
    IBOutlet NSWindow *winPgFolder;
    IBOutlet NSDrawer *drawer;
    IBOutlet NSTextField *txtPath;
    IBOutlet NSTextField *txtAddToFront;
    IBOutlet NSTextField *txtAddToEnd;
    IBOutlet NSPopUpButton *popStartSpread;
    IBOutlet NSTextField *txtSeparator;
    IBOutlet NSTextField *txtStartNum;
    IBOutlet NSTextField *txtEndNum;
    IBOutlet NSTextField *txtFigure;
    IBOutlet NSTextField *txtIncrement;
    IBOutlet NSTableView *tbPgFolders;
    IBOutlet NSStepper *stpStartNum;
    IBOutlet NSStepper *stpIncrement;
    IBOutlet NSStepper *stpEndNum;
}
@end
