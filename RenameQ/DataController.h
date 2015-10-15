//
//  DataController.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/11.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject{
    NSString *strFilePath;
    int cntData;
}

-(void)setData:(id)info;
-(void)createData:(NSString*)filePath;
-(void)chkAll:(BOOL)state;
-(void)SortByKey:(NSInteger)key ascending:(NSInteger)asc;
-(void)setNewName;
-(void)changeFileName:(int)endAction;
-(void)restoreFileName:(NSMutableArray*)srcList;
-(void)setErrDic:(id)name errorCode:(id)errNum;
@end
