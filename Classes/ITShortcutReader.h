//
//  ITShortcutReader.h
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcut.h"


#pragma mark - Interface

@interface ITShortcutReader : NSView

/// @property shortcutValue - The shortcut currently saved
@property (nonatomic) MASShortcut *shortcutValue;

@end
