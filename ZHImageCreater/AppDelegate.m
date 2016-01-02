//
//  AppDelegate.m
//  ZHImageCreater
//
//  Created by 吴志和 on 16/1/1.
//  Copyright © 2016年 吴志和. All rights reserved.
//

#import "AppDelegate.h"
#import "NSImage+ZHADD.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *pathField;

@property (weak) IBOutlet NSButton *createImageDirectorySw;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (IBAction)transFormButtonClicked:(id)sender
{
    if ([self.pathField.stringValue isEqualToString:@""]) {
        return;
    }
    
    [self dealPath:self.pathField.stringValue];
}

- (void)dealPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self zh_fileAtpath:path isKindOfFileType:NSFileTypeDirectory]) {
        
        //创建output文件夹
        NSString *outputPath = [path stringByAppendingPathComponent:@"imageoutput"];
        [fileManager createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:NULL];
        
        for (NSString *fileName in [fileManager subpathsAtPath:path]) {
            if ([fileName isEqualToString:@"imageoutput"]) {
                continue;
            }
            [fileManager copyItemAtPath:[path stringByAppendingPathComponent:fileName] toPath:[outputPath stringByAppendingPathComponent:fileName] error:NULL];
        }
        [self dealDirectoryAtPath:outputPath];
    }
    else if([self zh_fileAtpath:path isKindOfFileType:NSFileTypeRegular])
    {
        //创建output文件夹
        NSString *outputPath = [path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"imageoutput"];
        [fileManager createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSString *fileName = path.lastPathComponent;
        
         [fileManager copyItemAtPath:path toPath:[outputPath stringByAppendingPathComponent:fileName] error:NULL];
        
        [self dealDirectoryAtPath:outputPath];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSWarningAlertStyle;
        alert.messageText = @"非法路径!";
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

- (void)dealDirectoryAtPath:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *subFile in [fileManager subpathsAtPath:directoryPath]) {
        //只处理文件 不处理 目录、链接等
        if ([self zh_fileAtpath:[directoryPath stringByAppendingPathComponent:subFile] isKindOfFileType:NSFileTypeRegular]) {
            [self dealImageFileAtPath:[directoryPath stringByAppendingPathComponent:subFile]];
        }
    }
}

- (void)dealImageFileAtPath:(NSString *)imagePath
{
    if ([self zh_isImagePathDealed:imagePath]) {
        return;
    }
    
    //文件目录
    NSString *imageDirectory = imagePath.stringByDeletingLastPathComponent;
    
    NSString *imageName = [self zh_imageNameOfPath:imagePath];
    
    NSImage *oriImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    //删除老文件
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
    
    if (!oriImage) {
        return;
    }
    
    NSImage *image1x = [oriImage resizedImageWithScale:1.0 / 3];
    
    NSString *imageExtension = [imagePath pathExtension];

    [self wirteImage:image1x originPath:imageDirectory originName:imageName newName:[imageName stringByAppendingFormat:@".%@", imageExtension]];
    
    NSImage *image2x = [oriImage resizedImageWithScale:2.0 / 3];
    
    [self wirteImage:image2x originPath:imageDirectory originName:imageName newName:[imageName stringByAppendingFormat:@"@2x.%@", imageExtension]];
    
    [self wirteImage:oriImage originPath:imageDirectory originName:imageName newName:[imageName stringByAppendingFormat:@"@3x.%@", imageExtension]];
}
     
- (void)wirteImage:(NSImage *)image originPath:(NSString *)originPath originName:(NSString *)originName newName:(NSString *)newName
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
         if (self.createImageDirectorySw.state == NSOnState) {
             NSFileManager *fileManager = [NSFileManager defaultManager];
             
             NSString *outputPath = [originPath stringByAppendingPathComponent:originName];
             
             if (![fileManager fileExistsAtPath:outputPath]) {
                 [fileManager createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:NULL];
             }
             [image saveToFile:[outputPath stringByAppendingPathComponent:newName] withType:NSPNGFileType];
         }
         else
         {
             [image saveToFile:[originPath stringByAppendingPathComponent:newName] withType:NSPNGFileType];
         }
         
     });
}

- (BOOL)zh_fileAtpath:(NSString *)path isKindOfFileType:(NSString *)fileType
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDictionary *fileAttributes =  [fileManager attributesOfItemAtPath:path error:NULL];
    
    return [fileAttributes[NSFileType] isEqualToString:fileType];
}

- (BOOL)zh_isImagePathDealed:(NSString *)imagePath
{
    NSString *imageDirectory = imagePath.stringByDeletingLastPathComponent;
    
    NSString *imageName = [self zh_imageNameOfPath:imagePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:[imageDirectory stringByAppendingPathComponent:[imageName stringByAppendingFormat:@".png"] ] isDirectory:NULL] &&
    [fileManager fileExistsAtPath:[imageDirectory stringByAppendingPathComponent:[imageName stringByAppendingFormat:@"@2x.png"] ] isDirectory:NULL] &&
    [fileManager fileExistsAtPath:[imageDirectory stringByAppendingPathComponent:[imageName stringByAppendingFormat:@"@3x.png"] ] isDirectory:NULL];
}

- (NSString *)zh_imageNameOfPath:(NSString *)imagePath
{
    NSString *imageName = imagePath.lastPathComponent;
    
    //去掉@
    if ([imageName rangeOfString:@"@"].location != NSNotFound) {
        imageName = [imageName substringToIndex:[imageName rangeOfString:@"@"].location];
    }
    
    //去掉点
    if ([imageName rangeOfString:@"."].location != NSNotFound) {
        imageName = [imageName substringToIndex:[imageName rangeOfString:@"."].location];
    }
    return imageName;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
