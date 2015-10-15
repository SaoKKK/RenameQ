//
//  CCToolButton.h
//  RenameQ
//
//  Created by 河野 さおり on 2014/07/29.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCToolButton : NSButton{
    NSString *icnName;
    BOOL enterFlg;
}

-(void)iconSet:(NSString*)buttonName status:(NSString*)btnStatus;
-(void)btnAction:(NSString*)actionName;
@end
