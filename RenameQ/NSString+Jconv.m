//
//  NSString+Jconv.m
//  StringTest2
//
//  Created by 河野 さおり on 2015/01/02.
//  Copyright (c) 2015年 Saori Kohno. All rights reserved.
//

#import "NSString+Jconv.h"

@implementation NSString (Jconv)

- (NSString*) stringTransformWithTransform:(CFStringRef)transform reverse:(Boolean)reverse {
    NSMutableString* retStr = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)retStr, NULL, transform, reverse);
    return retStr;
}

- (NSString*) stringToFullwidth {
    return [self stringTransformWithTransform:kCFStringTransformFullwidthHalfwidth
                                      reverse:true];
}

- (NSString*) stringToHalfwidth {
    return [self stringTransformWithTransform:kCFStringTransformFullwidthHalfwidth
                                      reverse:false];
}

- (NSString*) stringKatakanaToHiragana {
    return [self stringTransformWithTransform:kCFStringTransformHiraganaKatakana
                                      reverse:true];
}

- (NSString*) stringHiraganaToKatakana {
    return [self stringTransformWithTransform:kCFStringTransformHiraganaKatakana
                                      reverse:false];
}

- (NSString*) stringHiraganaToLatin {
    return [self stringTransformWithTransform:kCFStringTransformLatinHiragana
                                      reverse:true];
}

- (NSString*) stringLatinToHiragana {
    return [self stringTransformWithTransform:kCFStringTransformLatinHiragana
                                      reverse:false];
}

- (NSString*) stringKatakanaToLatin {
    return [self stringTransformWithTransform:kCFStringTransformLatinKatakana
                                      reverse:true];
}

- (NSString*) stringLatinToKatakana {
    return [self stringTransformWithTransform:kCFStringTransformLatinKatakana
                                      reverse:false];
}

@end
