//
//  ITAppDelegate.h
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITShortcutReader.h"

@interface ITAppDelegate : NSObject <NSApplicationDelegate, ITShortcutReaderDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ITShortcutReader *shortcutReader1;
@property (assign) IBOutlet ITShortcutReader *shortcutReader2;

@end
