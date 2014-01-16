//
//  ITShortcutReader.h
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#pragma mark - Protocol

// Forward declaration
@class ITShortcutReader;

@protocol ITShortcutReaderDelegate <NSObject>
- (BOOL)shortcutReader:(ITShortcutReader *)shortcutReader
 shouldRegisterKeyCode:(NSUInteger)keyCode
         modifierFlags:(NSUInteger)modifierFlags;
@end



#pragma mark - Interface

@interface ITShortcutReader : NSView

@property (nonatomic) NSUInteger modifierFlags;
@property (nonatomic) NSUInteger keyCode;

@property (weak) IBOutlet id<ITShortcutReaderDelegate> delegate;

@end
