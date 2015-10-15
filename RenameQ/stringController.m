//
//  stringController.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/27.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "stringController.h"
#import "DataController.h"
#import "RNQAppDelegate.h"
#import "NSString+Jconv.h"

@implementation stringController{
    //文字列追加メソッド共用変数
    NSString *addStr,*addToFront,*addToEnd;
    NSInteger addToWhere,switchCntFrom;
    NSUInteger addToPoint;
    BOOL bPermitOverlap;
    //文字列削除メソッド使用変数
    NSString *delStr;
    NSInteger delPoint,delStartFrom;
    int delSPoint,delCnt;
    BOOL bDelCase,bDelWidth;
    //検索置換メソッド使用変数
    NSString *findStr;
    BOOL bReplaceCase,bReplaceWidth;
    //検索置換・区切り文字共用変数
    NSString *replaceStr;
    //連番・日付共用変数
    NSInteger commandRange;
    //連番処理メソッド使用変数
    int firstNum,figure,increment;
    //日付処理メソッド使用変数
    NSString *formatStr;
    NSInteger usedDate;
    //連番の増減使用変数
    NSInteger numLocate,startPoint;
    //親フォルダ処理使用変数
    NSInteger dirPosition,useStr,usePoint,useStart,useLength;
    //区切り文字処理使用変数
    NSInteger sepCommand;
    NSString *separator;
    //テキスト整形処理使用変数
    NSInteger formTxtCommand;
}
@synthesize errFlg;

//初期化
-(id)init{
    self = [super init];
    if (self){
        errFlg = NO;
    }
    return self;
}

//新ファイルネームを作成
-(NSMutableString*)createNewName:(NSString*)orgName cntData:(int)cntNum{
    NSMutableString* newName = [[NSMutableString alloc]init];
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    for (NSDictionary *preset in appDelegate.commandList) {
        errFlg = NO;
        int commandCode = [[preset objectForKey:@"commandCode"] intValue];
        switch (commandCode) {
            case 0:{
                //指定文字列を追加
                addStr = [preset objectForKey:@"addStr"];
                addToWhere = [[preset objectForKey:@"addToWhere"]integerValue];
                bPermitOverlap = [[preset objectForKey:@"permitOverlap"]integerValue];
                addToPoint = [[preset objectForKey:@"addToPoint"]integerValue];
                switchCntFrom = [[preset objectForKey:@"switchCntFrom"]integerValue];
                newName = [self addString:orgName];
            }
                break;
            case 1:{
                //指定文字列を削除
                delStr = [preset objectForKey:@"delStr"];
                delPoint = [[preset objectForKey:@"delPoint"]integerValue];
                bDelCase = [[preset objectForKey:@"chkDelCase"]integerValue];
                bDelWidth = [[preset objectForKey:@"chkDelWidth"]integerValue];
                newName = [self delString:orgName];
            }
                break;
            case 2:{
                //指定文字列の検索置換
                findStr = [preset objectForKey:@"findStr"];
                replaceStr = [preset objectForKey:@"replaceStr"];
                bReplaceCase = [[preset objectForKey:@"chkReplaceCase"]integerValue];
                bReplaceWidth = [[preset objectForKey:@"chkReplaceWidth"]integerValue];
                newName = [self findAndReplace:orgName];
            }
                break;
            case 3:{
                //文字数指定削除
                delSPoint = [[preset objectForKey:@"delSPoint"]intValue];
                delCnt = [[preset objectForKey:@"delCntStr"]intValue];
                delStartFrom = [[preset objectForKey:@"delPoint_strCnt"]integerValue];
                newName = [self delByCntStr:orgName];
                break;
            }
            case 4:{
                //連番処理
                commandRange = [[preset objectForKey:@"commandRange"]integerValue];
                addToFront = [preset objectForKey:@"addToFront"];
                addToEnd = [preset objectForKey:@"addToEnd"];
                firstNum = [[preset objectForKey:@"firstNum"]intValue];
                figure = [[preset objectForKey:@"figure"]intValue];
                increment = [[preset objectForKey:@"increment"]intValue];
                addToWhere = [[preset objectForKey:@"addToWhere"]integerValue];
                bPermitOverlap = [[preset objectForKey:@"permitOverlap"]integerValue];
                addToPoint = [[preset objectForKey:@"addToPoint"]integerValue];
                switchCntFrom = [[preset objectForKey:@"switchCntFrom"]integerValue];
                newName = [self renameWithSerialNum:orgName cntData:cntNum];
                break;
            }
            case 5:
                //連番増減
                numLocate = [[preset objectForKey:@"numLocate"]integerValue];
                startPoint = [[preset objectForKey:@"startPoint"]integerValue];
                figure = [[preset objectForKey:@"figure"]intValue];
                increment = [[preset objectForKey:@"increment"]intValue];
                newName = [self inorDecleaseSerialNum:orgName];
                break;
            case 6:{
                //日付処理
                commandRange = [[preset objectForKey:@"commandRange"]integerValue];
                usedDate = [[preset objectForKey:@"usedDate"]integerValue];
                formatStr = [preset objectForKey:@"formatter"];
                addToFront = [preset objectForKey:@"addToFront"];
                addToEnd = [preset objectForKey:@"addToEnd"];
                addToWhere = [[preset objectForKey:@"addToWhere"]integerValue];
                bPermitOverlap = [[preset objectForKey:@"permitOverlap"]integerValue];
                addToPoint = [[preset objectForKey:@"addToPoint"]integerValue];
                switchCntFrom = [[preset objectForKey:@"switchCntFrom"]integerValue];
                newName = [self renameByDate:orgName cntData:cntNum];
                break;
            }
            case 7:
                //親フォルダ
                dirPosition = [[preset objectForKey:@"dirPosition"]integerValue];
                useStr = [[preset objectForKey:@"useStr"]integerValue];
                usePoint = [[preset objectForKey:@"usePointFrom"]integerValue];
                useStart = [[preset objectForKey:@"useStart"]integerValue];
                useLength = [[preset objectForKey:@"useLength"]integerValue];
                addToFront = [preset objectForKey:@"addToFront"];
                addToEnd = [preset objectForKey:@"addToEnd"];
                addToWhere = [[preset objectForKey:@"addToWhere"]integerValue];
                switchCntFrom = [[preset objectForKey:@"switchCntFrom"]integerValue];
                addToPoint = [[preset objectForKey:@"addToPoint"]integerValue];
                bPermitOverlap = [[preset objectForKey:@"permitOverlap"]integerValue];
                newName = [self renameByFolderName:orgName cntData:cntNum];
                break;
            case 8: //区切り文字処理
                sepCommand = [[preset objectForKey:@"sepCommand"]integerValue];
                separator = [preset objectForKey:@"separator"];
                replaceStr = [preset objectForKey:@"replaceStr"];
                newName = [self renameBySeparator:orgName];
                break;
            default: //テキスト整形処理
                formTxtCommand = [[preset objectForKey:@"formTxt"]integerValue];
                newName = [self formTxt:orgName];
                break;
        }
        orgName = newName;
    }

    //ファイルネームにできない文字列の場合
    if (([newName isEqualToString:@""])||([[newName substringWithRange:NSMakeRange(0, 1)]isEqualToString:@"."])) {
        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
        errFlg = YES;
    }
    return newName;
}

//指定文字列を追加する
-(NSMutableString*)addString:(NSString*)orgName{
    NSMutableString *newName;
    errFlg = NO;
    //挿入箇所を取得して重複をチェック
    NSString *tempStr;
    switch (addToWhere) {
        case 0: //先頭に追加
            addToPoint = 0;
            if (bPermitOverlap==NSOffState) {
                if (addStr.length <= orgName.length) {
                    tempStr = [orgName substringToIndex:addStr.length];
                    if ([tempStr isEqualToString:addStr]==YES) {
                        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
                        errFlg = YES;
                    }
                }
            }
            break;
        case 1: //末尾に追加
            addToPoint = orgName.length;
            if (bPermitOverlap==NSOffState) {
                if (addStr.length <= orgName.length) {
                    tempStr = [orgName substringFromIndex:orgName.length - addStr.length];
                    if ([tempStr isEqualToString:addStr]==YES) {
                        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
                        errFlg = YES;
                    }
                }
            }
            break;
        default: //指定位置に追加
            addToPoint = addToPoint - 1;
            if (switchCntFrom == 1) {
                addToPoint = orgName.length - addToPoint;
            }
            if (bPermitOverlap==NSOffState) {
                if (addStr.length < orgName.length - addToPoint) {
                    tempStr = [orgName substringWithRange:NSMakeRange(addToPoint, addStr.length)];
                    if ([tempStr isEqualToString:addStr]==YES) {
                        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
                        errFlg = YES;
                    } else {
                        if (addStr.length <= addToPoint) {
                            tempStr = [orgName substringWithRange:NSMakeRange(addToPoint - addStr.length, addStr.length)];
                            if ([tempStr isEqualToString:addStr]==YES) {
                                newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
                                errFlg = YES;
                            }
                        }
                    }
                }else{
                    if (addStr.length <= addToPoint) {
                        tempStr = [orgName substringWithRange:NSMakeRange(addToPoint - addStr.length, addStr.length)];
                        if ([tempStr isEqualToString:addStr]==YES) {
                            newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
                            errFlg = YES;
                        }
                    }
                }
            }
            break;
    }
    //テキストを挿入
    if (errFlg==NO) {
        newName = [NSMutableString stringWithString:orgName];
        @try {
            [newName insertString:addStr atIndex:addToPoint];
        }
        @catch (NSException *exception) {
            newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
            errFlg = YES;
        }
        @finally {
            
        }
    }
   return newName;
}

//指定文字列を削除
-(NSMutableString*)delString:(NSString*)orgName{
    NSMutableString *newName;
    //検索オプションを設定
    NSStringCompareOptions opts = 0;
    if (bDelCase == NSOffState) {
        if (bDelWidth == NSOffState) {
            opts = NSCaseInsensitiveSearch | NSWidthInsensitiveSearch;
        }else{
            opts = NSCaseInsensitiveSearch;
        }
    }else{
        if (bDelWidth == NSOffState) {
            opts = NSWidthInsensitiveSearch;
        }
    }
    //実処理
    switch (delPoint) {
        case 0: //先頭の指定文字列を削除
            newName = [NSMutableString stringWithString:[orgName stringByReplacingOccurrencesOfString:delStr withString:@"" options:opts range:NSMakeRange(0, [delStr length])]];
            break;
        case 1:{ //末尾の指定文字列を削除
            NSRange aRange = NSMakeRange([orgName length]-[delStr length],[delStr length]);
            newName = [NSMutableString stringWithString:[orgName stringByReplacingOccurrencesOfString:delStr withString:@"" options:opts range:aRange]];
            break;
        }
        default: //すべての指定文字列を削除
            newName = [NSMutableString stringWithString:[orgName stringByReplacingOccurrencesOfString:delStr withString:@"" options:opts range:NSMakeRange(0, [orgName length])]];
            break;
    }
    return newName;
}

//指定文字列検索置換
-(NSMutableString*)findAndReplace:(NSString*)orgName{
    NSMutableString *newName;
    //検索オプションを設定
    NSStringCompareOptions opts = 0;
    NSRange searchRange = NSMakeRange(0, orgName.length);
    if (bReplaceCase == NSOffState) {
        if (bReplaceWidth == NSOffState) {
            opts = NSCaseInsensitiveSearch | NSWidthInsensitiveSearch;
        }else{
            opts = NSCaseInsensitiveSearch;
        }
    }else{
        if (bReplaceWidth == NSOffState) {
            opts = NSWidthInsensitiveSearch;
        }
    }
    //実処理
    newName = [NSMutableString stringWithString:[orgName stringByReplacingOccurrencesOfString:findStr withString:replaceStr options:opts range:searchRange]];
    return newName;
}

//文字数指定削除
-(NSMutableString*)delByCntStr:(NSString*)orgName{
    NSMutableString *newName;
    NSRange delRange;
    //実処理
    switch (delStartFrom) {
        case 0: //先頭から数える場合
            delRange = NSMakeRange(delSPoint-1, delCnt);
            break;
        default: //末尾から数える場合
            delRange = NSMakeRange(orgName.length-delSPoint+1-delCnt, delCnt);
            break;
    }
    newName = [NSMutableString stringWithString:orgName];
    @try {
        [newName deleteCharactersInRange:delRange];
    }
    @catch (NSException *exception) {
        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
        errFlg = YES;
    }
    @finally {
        
    }
    return newName;
}

//連番処理
-(NSMutableString*)renameWithSerialNum:(NSString*)orgName cntData:(int)cntNum{
    NSMutableString *newName;
    int serialNum = firstNum + (increment * cntNum);
    newName = [NSMutableString stringWithFormat:@"%i",serialNum];
    while (newName.length < figure) {
        [newName insertString:@"0" atIndex:0];
    }
    newName = [NSMutableString stringWithFormat:@"%@%@%@",addToFront,newName,addToEnd];
    switch (commandRange) {
        case 1:
            addStr = newName;
            newName = [self addString:orgName];
            break;
        default:
            break;
    }
    return newName;
}

//連番の増減処理
-(NSMutableString*)inorDecleaseSerialNum:(NSString*)orgName{
    NSMutableString *newName;
    NSMutableString *numStr; //文字列の数値部分
    NSString *frontStr = @"";      //文字列の数値より前の部分
    NSString *endStr = @"";        //文字列の数値より後ろの部分
    //指定箇所の文字列を取得
    if (numLocate == 0) {
        //先頭からカウントする場合
        numStr = [NSMutableString stringWithString:[orgName substringWithRange:NSMakeRange(startPoint-1, figure)]];
        if (startPoint != 1) {
            frontStr = [orgName substringToIndex:startPoint-1];
        }
        if (startPoint + figure - 1 < [orgName length]) {
            endStr = [orgName substringFromIndex:startPoint + figure - 1];
        }
    }else{
        //末尾からカウントする場合
        numStr = [NSMutableString stringWithString:[orgName substringWithRange:NSMakeRange([orgName length]-startPoint-figure+1, figure)]];
        frontStr = [orgName substringToIndex:[orgName length]-startPoint-figure+1];
        if (startPoint != 1) {
            endStr = [orgName substringFromIndex:[orgName length]-startPoint+1];
        }
        if ([orgName length]-startPoint-figure+1 > 0) {
            frontStr = [orgName substringToIndex:[orgName length]-startPoint-figure+1];
        }
    }
    int newNum = [numStr intValue]+increment;
    if (newNum > 0) {
        numStr = [NSMutableString stringWithFormat:@"%i",newNum];
        while (numStr.length < figure) {
            [numStr insertString:@"0" atIndex:0];
        }
        newName = [NSMutableString stringWithFormat:@"%@%@%@",frontStr,numStr,endStr];
    }else{
        newName = [NSMutableString stringWithString:@""];
    }
    return newName;
}

//日付処理
-(NSMutableString*)renameByDate:(NSString*)orgName cntData:(int)cntNum{
    NSMutableString *newName;
    RNQAppDelegate *appDelegate = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSDate *date;
    //使用する日付を取得
    if (usedDate == 0) {
        //作成日を使用
        date = [[appDelegate.dataList objectAtIndex:cntNum]objectForKey:@"cDate"];
    }else{
        //変更日を使用
        date = [[appDelegate.dataList objectAtIndex:cntNum]objectForKey:@"mDate"];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    //現在日時を文字列化する
    NSString *dateStr = [NSString stringWithFormat:@"%@%@%@",addToFront,[formatter stringFromDate:date],addToEnd];
    switch (commandRange) {
        case 0:
            newName = [NSMutableString stringWithString:dateStr];
            break;
        case 1:
            addStr = dateStr;
            newName = [self addString:orgName];
            break;
        default:
            break;
    }
    return newName;
}

//親フォルダ処理
-(NSMutableString*)renameByFolderName:(NSString*)orgName cntData:(int)cntNum{
    RNQAppDelegate *appD = (RNQAppDelegate*)[[NSApplication sharedApplication]delegate];
    NSMutableString *newName;
    NSString *parName;
    NSString *orgPath = [[appD.dataList objectAtIndex:cntNum]objectForKey:@"orgPath"];
    NSArray *dirRoot = [orgPath pathComponents];
    BOOL rangeErr = NO;
    if (dirRoot.count - dirPosition > 1) {
        parName = [dirRoot objectAtIndex:dirRoot.count - dirPosition - 1];
        if (useStr == 1) {
            //一部の文字を使用する場合
            if (usePoint == 0) {
                //先頭からカウントする場合
                if(useStart + useLength -1 <= parName.length){
                    parName = [parName substringWithRange:NSMakeRange(useStart - 1, useLength)];
                } else {
                    rangeErr = YES;
                }
            }else{
                //末尾からカウントする場合
                long rangeX = parName.length - useStart - useLength + 1;
                long rangeY = parName.length - useStart - useLength + useLength;
                if ((rangeX >= 0) && (rangeY <= parName.length)) {
                    parName = [parName substringWithRange:NSMakeRange(parName.length - useStart - useLength + 1, useLength)];
                }else{
                    rangeErr = YES;
                }
            }
           if (rangeErr) {
                parName = @"";
            }
        }
        if ([parName isEqualToString:@""]) {
            addStr = @"";
        }else{
            addStr = [NSMutableString stringWithFormat:@"%@%@%@",addToFront,parName,addToEnd];
        }
    }else{
        //ルートより上の階層を指定された場合
        addStr = @"";
    }
    newName = [self addString:orgName];
    return newName;
}

//区切り文字処理
-(NSMutableString*)renameBySeparator:(NSString*)orgName{
    NSMutableString *newName;
    NSRange range;
    @try {
        switch (sepCommand) {
            case 0: //区切り文字より前を置換
                range = [orgName rangeOfString:separator];
                newName = [NSMutableString stringWithFormat:@"%@%@",replaceStr,[newName substringFromIndex:range.location]];
                break;
            case 1: //区切り文字より後ろを置換
                range = [orgName rangeOfString:separator options:NSBackwardsSearch];
                newName = [NSMutableString stringWithFormat:@"%@%@",[newName substringToIndex:range.location+1],replaceStr];
                break;
            case 2: //区切り文字より前を削除
                range = [orgName rangeOfString:separator];
                newName = [NSMutableString stringWithString:[newName substringFromIndex:range.location+1]];
                break;
            default: //区切り文字より後ろを削除
                range = [orgName rangeOfString:separator options:NSBackwardsSearch];
                newName = [NSMutableString stringWithString:[newName substringToIndex:range.location]];
                break;
        }
    }
    @catch (NSException *exception) {
        newName = [NSMutableString stringWithString:@"##FILE NAME ERROR##"];
        errFlg = YES;
    }
    @finally {
        
    }
    return newName;
}

//テキスト整形処理
-(NSMutableString*)formTxt:(NSString*)orgName{
    NSMutableString *newName;
    NSArray *fullChrs,*halfChrs;
    switch (formTxtCommand) {
        case 0: //数字をすべて半角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullDecimalChrs];
            halfChrs = [self halfDecimalChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[fullChrs objectAtIndex:i] withString:[halfChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 1: //数字をすべて全角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullDecimalChrs];
            halfChrs = [self halfDecimalChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[halfChrs objectAtIndex:i] withString:[fullChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 2: //英数字をすべて半角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullAlphanumericChrs];
            halfChrs = [self halfAlphanumericChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[fullChrs objectAtIndex:i] withString:[halfChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 3: //英数字をすべて全角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullAlphanumericChrs];
            halfChrs = [self halfAlphanumericChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[halfChrs objectAtIndex:i] withString:[fullChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 4: //カタカナをすべて半角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullKatakanaChrs];
            halfChrs = [self halfKatakanaChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[fullChrs objectAtIndex:i] withString:[halfChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 5: //カタカナをすべて全角に
            newName = [NSMutableString stringWithString:orgName];
            fullChrs = [self fullKatakanaChrs];
            halfChrs = [self halfKatakanaChrs];
            for (int i = 0; i < fullChrs.count; i++){
                [newName replaceOccurrencesOfString:[halfChrs objectAtIndex:i] withString:[fullChrs objectAtIndex:i] options:0 range:NSMakeRange(0, newName.length)];
            }
            break;
        case 6: //すべての文字を半角に
            newName = [NSMutableString stringWithString:[orgName stringToHalfwidth]];
            break;
        case 7: //すべての文字を全角に
            newName = [NSMutableString stringWithString:[orgName stringToFullwidth]];
            break;
        case 8: //英字をすべて大文字に
            newName = [NSMutableString stringWithString:[orgName uppercaseString]];
            break;
        case 9: //英字をすべて小文字に
            newName = [NSMutableString stringWithString:[orgName lowercaseString]];
            break;
        case 10: //キャピタライズ
            newName = [NSMutableString stringWithString:[orgName capitalizedString]];
            break;
        case 11: //ひらがなをローマ字に変換
            newName = [NSMutableString stringWithString:[orgName stringHiraganaToLatin]];
            break;
        case 12: //ローマ字をひらがなに変換
            newName = [NSMutableString stringWithString:[orgName stringLatinToHiragana]];
            break;
        case 13: //カタカナをローマ字に変換
            newName = [NSMutableString stringWithString:[orgName stringKatakanaToLatin]];
            break;
        case 14: //ローマ字をカタカナに変換
            newName = [NSMutableString stringWithString:[orgName stringLatinToKatakana]];
            break;
        default:{ //先頭末尾のスペースを削除
            NSCharacterSet *chrSet = [NSCharacterSet whitespaceCharacterSet];
            newName = [NSMutableString stringWithString:[orgName stringByTrimmingCharactersInSet:chrSet]];
            }
            break;
    }
    return newName;
}

//chrSetに半角数字をセットして返す
-(NSArray*)halfDecimalChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    return chrSet;
}
//chrSetに全角数字をセットして返す
-(NSArray*)fullDecimalChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"０", @"１", @"２", @"３", @"４", @"５", @"６", @"７", @"８", @"９", nil];
    return chrSet;
}
//chrSetに半角英数字をセットして返す
-(NSArray*)halfAlphanumericChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"!",@"\"",@"#",@"$",@"%",@"&",@"'",@"(",@")",@"*",@"+",@",",@"-",@".",@"/",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@":",@";",@"<",@"=",@">",@"?",@"@",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"[",@"\\",@"]",@"^",@"_",@"`",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"{",@"|",@"}",@"~", nil];
    return chrSet;
}
//chrSetに全角英数字をセットして返す
-(NSArray*)fullAlphanumericChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"！",@"＂",@"＃",@"＄",@"％",@"＆",@"＇",@"（",@"）",@"＊",@"＋",@"，",@"－",@"．",@"／",@"０",@"１",@"２",@"３",@"４",@"５",@"６",@"７",@"８",@"９",@"：",@"；",@"＜",@"＝",@"＞",@"？",@"＠",@"Ａ",@"Ｂ",@"Ｃ",@"Ｄ",@"Ｅ",@"Ｆ",@"Ｇ",@"Ｈ",@"Ｉ",@"Ｊ",@"Ｋ",@"Ｌ",@"Ｍ",@"Ｎ",@"Ｏ",@"Ｐ",@"Ｑ",@"Ｒ",@"Ｓ",@"Ｔ",@"Ｕ",@"Ｖ",@"Ｗ",@"Ｘ",@"Ｙ",@"Ｚ",@"［",@"＼",@"］",@"＾",@"＿",@"｀",@"ａ",@"ｂ",@"ｃ",@"ｄ",@"ｅ",@"ｆ",@"ｇ",@"ｈ",@"ｉ",@"ｊ",@"ｋ",@"ｌ",@"ｍ",@"ｎ",@"ｏ",@"ｐ",@"ｑ",@"ｒ",@"ｓ",@"ｔ",@"ｕ",@"ｖ",@"ｗ",@"ｘ",@"ｙ",@"ｚ",@"｛",@"｜",@"｝",@"～", nil];
    return chrSet;
}
//chrSetに半角カタカナをセットして返す
-(NSArray*)halfKatakanaChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"",@"ｶﾞ",@"ｷﾞ",@"ｸﾞ",@"ｹﾞ",@"ｺﾞ",@"ｻﾞ",@"ｼﾞ",@"ｽﾞ",@"ｾﾞ",@"ｿﾞ",@"ﾀﾞ",@"ﾁﾞ",@"ﾂﾞ",@"ﾃﾞ",@"ﾄﾞ",@"ﾊﾞ",@"ﾋﾞ",@"ﾌﾞ",@"ﾍﾞ",@"ﾎﾞ",@"ﾊﾟ",@"ﾋﾟ",@"ﾌﾟ",@"ﾍﾟ",@"ﾎﾟ",@"ｱ",@"ｲ",@"ｳ",@"ｴ",@"ｵ",@"ｶ",@"ｷ",@"ｸ",@"ｹ",@"ｺ",@"ｻ",@"ｼ",@"ｽ",@"ｾ",@"ｿ",@"ﾀ",@"ﾁ",@"ﾂ",@"ﾃ",@"ﾄ",@"ﾅ",@"ﾆ",@"ﾇ",@"ﾈ",@"ﾉ",@"ﾊ",@"ﾋ",@"ﾌ",@"ﾍ",@"ﾎ",@"ﾏ",@"ﾐ",@"ﾑ",@"ﾒ",@"ﾓ",@"ﾔ",@"ﾕ",@"ﾖ",@"ﾗ",@"ﾘ",@"ﾙ",@"ﾚ",@"ﾛ",@"ﾜ",@"ｵ",@"ﾝ", @"ｧ",@"ｨ",@"ｩ",@"ｪ",@"ｫ",@"ｯ",@"ｬ",@"ｭ",@"ｮ", nil];
    return chrSet;
}
//chrSetに全角カタカナをセットして返す
-(NSArray*)fullKatakanaChrs{
    NSArray *chrSet;
    chrSet = [NSArray arrayWithObjects:@"ヴ",@"ガ",@"ギ",@"グ",@"ゲ",@"ゴ",@"ザ",@"ジ",@"ズ",@"ゼ",@"ゾ",@"ダ",@"ヂ",@"ヅ",@"デ",@"ド",@"バ",@"ビ",@"ブ",@"ベ",@"ボ",@"パ",@"ピ",@"プ",@"ペ",@"ポ",@"ア",@"イ",@"ウ",@"エ",@"オ",@"カ",@"キ",@"ク",@"ケ",@"コ",@"サ",@"シ",@"ス",@"セ",@"ソ",@"タ",@"チ",@"ツ",@"テ",@"ト",@"ナ",@"ニ",@"ヌ",@"ネ",@"ノ",@"ハ",@"ヒ",@"フ",@"ヘ",@"ホ",@"マ",@"ミ",@"ム",@"メ",@"モ",@"ヤ",@"ユ",@"ヨ",@"ラ",@"リ",@"ル",@"レ",@"ロ",@"ワ",@"オ",@"ン", @"ァ",@"ィ",@"ゥ",@"ェ",@"ォ",@"ッ",@"ャ",@"ュ",@"ョ", nil];
    return chrSet;
}

@end
