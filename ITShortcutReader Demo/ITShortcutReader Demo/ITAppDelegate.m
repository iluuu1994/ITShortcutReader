//
//  ITAppDelegate.m
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITAppDelegate.h"

@implementation ITAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.shortcutReader1.shortcutValue = [MASShortcut shortcutWithKeyCode:36 modifierFlags:1048840];
}

@end
