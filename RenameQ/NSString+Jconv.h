//
//  NSString+Jconv.h
//  StringTest2
//
//  Created by 河野 さおり on 2015/01/02.
//  Copyright (c) 2015年 Saori Kohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Jconv)

// 半角→全角
- (NSString*) stringToFullwidth;

// 全角→半角
- (NSString*) stringToHalfwidth;

// カタカナ→ひらがな
- (NSString*) stringKatakanaToHiragana;

// ひらがな→カタカナ
- (NSString*) stringHiraganaToKatakana;

// ひらがな→ローマ字
- (NSString*) stringHiraganaToLatin;

// ローマ字→ひらがな
- (NSString*) stringLatinToHiragana;

// カタカナ→ローマ字
- (NSString*) stringKatakanaToLatin;

// ローマ字→カタカナ
- (NSString*) stringLatinToKatakana;

@end
