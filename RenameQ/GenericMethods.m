//
//  GenericMethods.m
//  RenameQ
//
//  Created by 河野 さおり on 2014/09/09.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "GenericMethods.h"

@implementation GenericMethods

// Return the path to application folder
+ (NSString*)pathToAppFolder{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pathToAppFolder = [[bundle bundlePath]stringByDeletingLastPathComponent];
    return pathToAppFolder;
}

// Return date string formatted by sended formatter
+ (NSString*)dateString:(NSString*)formatterStr{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter= [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatterStr];
    return [formatter stringFromDate:date];
}
@end
