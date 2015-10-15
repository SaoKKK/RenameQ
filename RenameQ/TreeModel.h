//
//  TreeModel.h
//  106Test
//
//  Created by 河野 さおり on 2014/09/22.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface TreeModel : NSTreeNode <NSPasteboardWriting, NSPasteboardReading>

@property (readwrite,copy)NSString *name;
@property (assign)BOOL isLeaf;
@property (strong)NSMutableArray *children;
@property (assign)BOOL selectParent; //親を選択するかどうかを保存する真偽値
@property (assign)BOOL haveParent;   //親のいるグループかルート直下のグループ化を保存する真偽値
@property(readwrite, retain) NSImage *image;

- (id)initWithName:(NSString*)aName withLeaf:(BOOL)bLeaf selectParent:(BOOL)select haveParent:(BOOL)haveParent;
+ (TreeModel*)nodeDataWithName:(NSString*)aName withLeaf:(BOOL)bLeaf selectParent:(BOOL)select haveParent:(BOOL)bHaveParent;

@end
