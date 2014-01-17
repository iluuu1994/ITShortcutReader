//
//  ITShortcutReaderKeyView.h
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 13/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcut.h"

typedef BOOL(^ITKeyEvaluationBlock)(MASShortcut *shortcutValue);

@interface ITShortcutReaderKeyView : NSView
@property (strong) CALayer *hostedLayer;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSTextField *textField;
@property (strong) ITKeyEvaluationBlock evaluationBlock;
- (BOOL)evaluateWithShortcut:(MASShortcut *)shortcut;
@end