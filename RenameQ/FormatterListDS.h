//
//  FormatterListDS.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/08/21.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatterListDS : NSObject{
    NSArray *formatterList;
    NSString *dateStr,*addToFront,*addToEnd;
    IBOutlet NSTextField *txtFormatterStr;
    IBOutlet NSTableView *tbFormatterList;
    IBOutlet NSTextField *txtSampleDate;
    IBOutlet NSWindow *mainWin;
    IBOutlet NSTextField *txtAddToFront;
    IBOutlet NSTextField *txtAddToEnd;
}

@end
