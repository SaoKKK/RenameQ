//
//  stringController.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/27.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stringController : NSObject

@property(assign,nonatomic)BOOL errFlg;

-(NSMutableString*)createNewName:(NSString*)orgName cntData:(int)cntNum;
-(NSMutableString*)addString:(NSString*)orgName;
-(NSMutableString*)delString:(NSString*)orgName;
-(NSMutableString*)findAndReplace:(NSString*)orgName;
-(NSMutableString*)delByCntStr:(NSString*)orgName;
-(NSMutableString*)renameWithSerialNum:orgName cntData:(int)cntNum;
-(NSMutableString*)renameByDate:orgName cntData:(int)cntNum;
@end
