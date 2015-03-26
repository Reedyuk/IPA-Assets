//
//  CarExporter.m
//  IPAAssets
//
//  Created by Andrew Reed on 14/08/2014.
//  Copyright (c) 2014 Andrew Reed. All rights reserved.
//

#import "CarExporter.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


#define kiPhone 1
#define kiPad 2


@implementation CarExporter

+ (void)exportImagesWithCarLocation:(NSString *)carLocation withOutputDirectory:(NSString *)outputDirectoryPath
{
    NSError *error = nil;
    outputDirectoryPath = [outputDirectoryPath stringByExpandingTildeInPath];
    CUIThemeFacet *facet = [CUIThemeFacet themeWithContentsOfURL:[NSURL fileURLWithPath:carLocation] error:&error];
    
    if(error) {
        [[NSAlert alertWithMessageText:@"Path Error"
                         defaultButton:@"OK"
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:error.description] runModal];
    } else {
        CUICatalog *catalog = [[CUICatalog alloc] init];
        
        [catalog setValue:facet forKey:@"_storageRef"];
        
        CUICommonAssetStorage *storage = [[NSClassFromString(@"CUICommonAssetStorage") alloc] initWithPath:carLocation];
        
        for (NSString *key in [storage allRenditionNames])
        {
            NSLog(@"%s\n", [key UTF8String]);
            
            CGImageRef iphone = [[catalog imageWithName:key scaleFactor:1.0 deviceIdiom:kiPhone] image];
            CGImageRef iphoneRetina = [[catalog imageWithName:key scaleFactor:2.0 deviceIdiom:kiPhone] image];
            CGImageRef ipad = [[catalog imageWithName:key scaleFactor:1.0 deviceIdiom:kiPad] image];
            CGImageRef ipadRetina = [[catalog imageWithName:key scaleFactor:2.0 deviceIdiom:kiPad] image];
            
            if (iphone) {
                [CarExporter saveImage:iphone toPath:[outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~iphone.png", key]]];
            }
            
            if (iphoneRetina) {
                [CarExporter saveImage:iphoneRetina toPath:[outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~iphone@2x.png", key]]];
            }
            
            if (ipad && ipad != iphone) {
                [CarExporter saveImage:ipad toPath:[outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~ipad.png", key]]];
            }
            
            if (ipadRetina && ipadRetina != iphoneRetina) {
                [CarExporter saveImage:ipadRetina toPath:[outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~ipad@2x.png", key]]];
            }
        }
        
        [[NSAlert alertWithMessageText:@"Export Success"
                         defaultButton:@"OK"
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:[NSString stringWithFormat:@"Successfully exported %lu files",(unsigned long)[storage allRenditionNames].count]] runModal];

    }
}

+ (void)saveImage:(CGImageRef)image toPath:(NSString *)path
{
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Unable to save image to %@", path);
    }
    
    CFRelease(destination);
}

@end

