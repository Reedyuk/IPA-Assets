//
//  CarExporter.h
//  IPAAssets
//
//  Created by Andrew Reed on 14/08/2014.
//  Copyright (c) 2014 Andrew Reed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUICommonAssetStorage : NSObject

-(NSArray *)allAssetKeys;
-(NSArray *)allRenditionNames;

-(id)initWithPath:(NSString *)p;

-(NSString *)versionString;

@end

@interface CUINamedImage : NSObject

-(CGImageRef)image;

@end

@interface CUIRenditionKey : NSObject
@end

@interface CUIThemeFacet : NSObject

+(CUIThemeFacet *)themeWithContentsOfURL:(NSURL *)u error:(NSError **)e;

@end

@interface CUICatalog : NSObject

-(id)initWithName:(NSString *)n fromBundle:(NSBundle *)b;
-(id)allKeys;
-(CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s;
-(CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s deviceIdiom:(int)idiom;

@end

@interface CarExporter : NSObject

+ (void)saveImage:(CGImageRef)image toPath:(NSString *)path;
+ (void)exportImagesWithCarLocation:(NSString *)carLocation withOutputDirectory:(NSString *)outputDirectoryPath;

@end
