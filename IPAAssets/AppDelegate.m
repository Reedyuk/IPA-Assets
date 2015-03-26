//
//  AppDelegate.m
//  IPAAssets
//
//  Created by Andrew Reed on 13/08/2014.
//  Copyright (c) 2014 Andrew Reed. All rights reserved.
//

#import "AppDelegate.h"
#import "CarExporter.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *ipaTextfield;
@property (weak) IBOutlet NSTextField *outputTextfield;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


- (IBAction)exportFilesButtonPressed:(id)sender {
    //check we have an ipa location.
    NSString *error = [self isValidForm];
    
    if(error) {
        //need to present an error message
        [[NSAlert alertWithMessageText:@"Form Error"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                              informativeTextWithFormat:error] runModal];
        return;
    }
    
    NSString *outputLocation;
    
    if(self.outputTextfield.stringValue.length == 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        outputLocation = [path stringByAppendingString:@"/IPAAssets/"];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:outputLocation withIntermediateDirectories:YES attributes:nil error:NULL];
    } else {
        outputLocation = [self.outputTextfield.stringValue stringByAppendingString:@"/"];
    }
    
    NSString *zipLocation = [self unzipIpaWithOutputLocation:outputLocation];
    NSString *appName = [self calculateAppNameWithZipLocation:zipLocation];
    //then we need to get the car file.
    NSString *carLocation = [zipLocation stringByAppendingString:[NSString stringWithFormat:@"Payload/%@/Assets.car", appName]];
    
    //check location of carLocation
    if([[NSFileManager defaultManager] fileExistsAtPath:carLocation]) {
        outputLocation = [outputLocation stringByAppendingString:[NSString stringWithFormat:@"%@/",[appName stringByReplacingOccurrencesOfString:@".app" withString:@""]]];
        [[NSFileManager defaultManager] createDirectoryAtPath:outputLocation withIntermediateDirectories:YES attributes:nil error:NULL];
        
        [CarExporter exportImagesWithCarLocation:carLocation withOutputDirectory:outputLocation];
    } else {
        [[NSAlert alertWithMessageText:@"Error"
                         defaultButton:@"OK"
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@"Cannot locate the Car file, does it exist in this ipa?"] runModal];

    }
    
    //remove the zip output.
    NSError *removeError;
    [[NSFileManager defaultManager] removeItemAtPath:zipLocation error:&removeError];

    
}

- (NSString*)calculateAppNameWithZipLocation:(NSString*)zipLocation {
    NSString *appName = @"";
    //get the ipa name.
    NSString* file;
    NSString *payloadLocation = [zipLocation stringByAppendingString:[NSString stringWithFormat:@"Payload/"]];
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:payloadLocation];
    while (file = [enumerator nextObject])
    {
        // check if it's a directory
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",payloadLocation,file]
                                             isDirectory: &isDirectory];
        if (isDirectory)
        {
            // open your file …
            if([file rangeOfString:@".app"].length != 0 && [file rangeOfString:@"/"].length == 0) {
                appName = file;
            }
        }
    }
    
    return appName;
}

- (NSString*)unzipIpaWithOutputLocation:(NSString*)outputLocation {
    NSString *ipaLocation = self.ipaTextfield.stringValue;
    NSString *zipLocation;
    
    zipLocation = [outputLocation stringByAppendingString:@"output/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:zipLocation withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *unzip = [[NSTask alloc] init];
    [unzip setLaunchPath:@"/usr/bin/unzip"];
    [unzip setArguments:[NSArray arrayWithObjects:@"-o", @"-u", @"-d", zipLocation, ipaLocation, nil]];
    
    NSPipe *aPipe = [[NSPipe alloc] init];
    [unzip setStandardOutput:aPipe];
    
    [unzip launch];
    [unzip waitUntilExit];
    
    NSData *outputData = [[aPipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Pipe: %@", outputString);
    NSLog(@"------------- Finish -----------");
    
    return zipLocation;
    
}

- (NSString*)isValidForm {
    NSString *errorMsg;
    
    if(self.ipaTextfield.stringValue.length == 0) {
        errorMsg = @"Please enter a location where your ipa exists";
    }
    
    
    return errorMsg;
}

- (NSString*)formatUrlToString:(NSURL*)selectedFile {
    NSString *selectedFiledString = [selectedFile path];
    return [selectedFiledString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
}

- (NSOpenPanel*)createDialog {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setPrompt:@"Select"];
    
    return openDlg;
}


- (IBAction)browseIpaButtonPressed:(id)sender {
    NSOpenPanel* openDlg = [self createDialog];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    NSArray *fileTypes = @[@"ipa"];
    [openDlg setAllowedFileTypes:fileTypes];
    [openDlg beginWithCompletionHandler:^(NSInteger result) {
        NSArray *urls = openDlg.URLs;
        NSURL *selectedFile = [urls firstObject];
        if(selectedFile) {
            [self.ipaTextfield setStringValue:[self formatUrlToString:selectedFile]];
        }
    }];
    
}
- (IBAction)browseOutputButtonPressed:(id)sender {
    NSOpenPanel* openDlg = [self createDialog];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg beginWithCompletionHandler:^(NSInteger result) {
        NSArray *urls = openDlg.URLs;
        NSURL *selectedFolder = [urls firstObject];
        if(selectedFolder) {
            [self.outputTextfield setStringValue:[self formatUrlToString:selectedFolder]];
        }
    }];
}

@end
