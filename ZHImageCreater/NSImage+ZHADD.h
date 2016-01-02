//
//  NSImage+ZHADD.h
//  ZHImageCreater
//
//  Created by 吴志和 on 16/1/1.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (ZHADD)

- (NSImage *)resizedImageWithScale:(CGFloat)scale;

- (NSImage *)resizedImageWithSize:(NSSize)newSize;

- (BOOL)saveToFile:(NSString *)filePath withType:(NSBitmapImageFileType)type;

@end
