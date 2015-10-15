//
//  CCFolderPathDropField.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/08/26.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCFolderPathDropField : NSTextField{
    NSArray *dropDataList;
    NSString *strFilePath;
    BOOL flgDragging;
}

@end
