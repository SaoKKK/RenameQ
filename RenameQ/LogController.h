//
//  LogController.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/28.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogController : NSObject{
    IBOutlet NSTableView *logFileTable;
}
-(BOOL)createNewLog;
-(void)removeLog:(NSMutableArray*)removeFiles;
-(void)setLogFileList;
-(BOOL)saveErrorLog;
@end
