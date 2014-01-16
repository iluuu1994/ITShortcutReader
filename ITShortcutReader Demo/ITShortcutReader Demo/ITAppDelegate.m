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
    self.shortcutReader1.keyCode = 36;
    self.shortcutReader1.modifierFlags = 1048840;
}

- (BOOL)shortcutReader:(ITShortcutReader *)shortcutReader
      shouldRegisterKeyCode:(NSUInteger)keyCode
              modifierFlags:(NSUInteger)modifierFlags
{
    NSLog(@"%@", shortcutReader.identifier);
    
    int flags = 0;
    
    if (modifierFlags & NSControlKeyMask) flags++;
    if (modifierFlags & NSAlternateKeyMask) flags++;
    if (modifierFlags & NSShiftKeyMask) flags++;
    if (modifierFlags & NSCommandKeyMask) flags++;
    
    return (modifierFlags > 0);
}

@end
