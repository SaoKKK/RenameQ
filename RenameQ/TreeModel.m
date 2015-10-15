//
//  TreeModel.m
//  106Test
//
//  Created by 河野 さおり on 2014/09/22.
//  Copyright (c) 2014年 Saori Kohno. All rights reserved.
//

#import "TreeModel.h"

@implementation TreeModel

@synthesize name,isLeaf,children,selectParent,haveParent,image;

- (id)init{
    self = [super init];
    name = @"名称未設定";
    [self setChildren:[NSMutableArray array]];
    isLeaf = NO;
    selectParent = NO;
    haveParent = YES;
    return self;
}

- (id)initWithName:(NSString*)aName withLeaf:(BOOL)bLeaf selectParent:(BOOL)select haveParent:(BOOL)bHaveParent{
    self = [self init];
    self.name = aName;
    self.isLeaf = bLeaf;
    self.selectParent = select;
    self.haveParent = bHaveParent;
    return self;
}

+ (TreeModel*)nodeDataWithName:(NSString*)aName withLeaf:(BOOL)bLeaf selectParent:(BOOL)select haveParent:(BOOL)bHaveParent{
    return [[[TreeModel alloc]initWithName:aName withLeaf:bLeaf selectParent:select haveParent:(BOOL)bHaveParent]autorelease];
}

- (void)dealloc{
    [name release];
    [super dealloc];
}

#pragma mark - NSPasteboardWriting support

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // These are the types we can write.
    NSArray *ourTypes = [NSArray arrayWithObjects:NSPasteboardTypeString, nil];
    // Also include the images on the pasteboard too!
    NSArray *imageTypes = [self.image writableTypesForPasteboard:pasteboard];
    if (imageTypes) {
        ourTypes = [ourTypes arrayByAddingObjectsFromArray:imageTypes];
    }
    return ourTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return 0;
    }
    // Everything else is delegated to the image
    if ([self.image respondsToSelector:@selector(writingOptionsForType:pasteboard:)]) {
        return [self.image writingOptionsForType:type pasteboard:pasteboard];
    }
    
    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return self.name;
    } else {
        return [self.image pasteboardPropertyListForType:type];
    }
}

#pragma mark - NSPasteboardReading support
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    // We allow creation from URLs so Finder items can be dragged to us
    return [NSArray arrayWithObjects:(id)kUTTypeURL, NSPasteboardTypeString, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:NSPasteboardTypeString] || UTTypeConformsTo((CFStringRef)type, kUTTypeURL)) {
        return NSPasteboardReadingAsString;
    } else {
        return NSPasteboardReadingAsData;
    }
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    // See if an NSURL can be created from this type
    if (UTTypeConformsTo((CFStringRef)type, kUTTypeURL)) {
        // It does, so create a URL and use that to initialize our properties
        NSURL *url = [[[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type]autorelease];
        self = [super init];
        self.name = [url lastPathComponent];
        // Make sure we have a name
        if (self.name == nil) {
            self.name = [url path];
            if (self.name == nil) {
                self.name = @"Untitled";
            }
        }
        
        // See if the URL was a container; if so, make us marked as a container too
        NSNumber *value;
        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && [value boolValue]) {
            self.isLeaf = NO;
        } else {
            self.isLeaf = YES;
        }
        
        NSImage *localImage;
        if ([url getResourceValue:&localImage forKey:NSURLEffectiveIconKey error:NULL] && localImage) {
            self.image = localImage;
        }
        
    } else if ([type isEqualToString:NSPasteboardTypeString]) {
        self = [super init];
        self.name = propertyList;
    } else {
        NSAssert(NO, @"internal error: type not supported");
    }
    return self;
}

@end
