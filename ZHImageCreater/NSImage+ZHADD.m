//
//  NSImage+ZHADD.m
//  ZHImageCreater
//
//  Created by 吴志和 on 16/1/1.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import "NSImage+ZHADD.h"

@implementation NSImage (ZHADD)

- (NSImage *)resizedImageWithScale:(CGFloat)scale
{
    NSBitmapImageRep *rep = (NSBitmapImageRep *)self.representations.firstObject;
    // issue #56: https://github.com/rickytan/RTImageAssets/issues/56
    if (![rep isKindOfClass:[NSBitmapImageRep class]]) {
        return nil;
    }
    
    NSSize pixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    
    // issue #8: https://github.com/rickytan/RTImageAssets/issues/8
    if (pixelSize.width == 0.f || pixelSize.height == 0.f) {
        pixelSize = rep.size;
    }
    NSSize scaledSize = NSMakeSize(floorf(pixelSize.width * scale), floorf(pixelSize.height * scale));
    
    return [self resizedImageWithSize:scaledSize];
}

- (NSImage *)resizedImageWithSize:(NSSize)newSize
{
    NSBitmapImageRep *rep = (NSBitmapImageRep *)self.representations.firstObject;
    
    
    // issue #21: https://github.com/rickytan/RTImageAssets/issues/21
    rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                  pixelsWide:newSize.width
                                                  pixelsHigh:newSize.height
                                               bitsPerSample:rep.bitsPerSample
                                             samplesPerPixel:rep.samplesPerPixel
                                                    hasAlpha:rep.hasAlpha
                                                    isPlanar:rep.isPlanar
                                              colorSpaceName:rep.colorSpaceName
                                                 bytesPerRow:0
                                                bitsPerPixel:0];
    
    rep.size = newSize;

    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    
    if (!context) {
        // issue #24: https://github.com/rickytan/RTImageAssets/issues/24
        rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                      pixelsWide:newSize.width
                                                      pixelsHigh:newSize.height
                                                   bitsPerSample:8
                                                 samplesPerPixel:4
                                                        hasAlpha:YES
                                                        isPlanar:NO
                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                     bytesPerRow:0
                                                    bitsPerPixel:0];
        rep.size = newSize;
        context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    }
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [self drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)];
    [NSGraphicsContext restoreGraphicsState];
    
    return [[NSImage alloc] initWithData:[rep representationUsingType:NSPNGFileType
                                                           properties:nil]];
}

- (BOOL)saveToFile:(NSString *)filePath withType:(NSBitmapImageFileType)type
{
    NSData *data = nil;
    if (type == NSTIFFFileType) {
        data = self.TIFFRepresentation;
    }
    else {
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:self.TIFFRepresentation];
        data = [rep representationUsingType:type
                                 properties:nil];
    }
    return [data writeToFile:filePath
                  atomically:NO];
}

@end
