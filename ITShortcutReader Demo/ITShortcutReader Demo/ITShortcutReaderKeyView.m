//
//  ITShortcutReaderKeyView.m
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 13/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITShortcutReaderKeyView.h"

@implementation ITShortcutReaderKeyView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    self.wantsLayer = YES;
    
    NSImage *backgroundImage = [NSImage imageNamed:@"shortcutReaderKey"];
    _hostedLayer = [CALayer layer];
    _hostedLayer.delegate = self;
    _hostedLayer.contents = backgroundImage;
    
    _hostedLayer.contentsCenter = (CGRect){
        .origin.x = 4.f / backgroundImage.size.width,
        .origin.y = 0.f  / backgroundImage.size.height,
        .size.width = 16.f / backgroundImage.size.width,
        .size.height = 24.f / backgroundImage.size.height,
    };
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        _hostedLayer.contentsScale = [NSScreen mainScreen].backingScaleFactor;
    }
    
    self.layer = _hostedLayer;
    
    
    // TextFields
    NSSize textFieldSize = NSMakeSize(NSWidth(self.bounds), 16.f);
    _textField = [[NSTextField alloc] initWithFrame:(NSRect){
        .origin.x =  (NSWidth(self.bounds)/2) - (textFieldSize.width/2),
        .origin.y =  (NSHeight(self.bounds)/2)- (textFieldSize.height/2),
        .size = textFieldSize
    }];
    
    // We add it already, so it's layer backed when editing
    [self addSubview:_textField];
    
    _textField.alignment = NSCenterTextAlignment;
    [_textField setSelectable:NO];
    [_textField setEditable:NO];
    [_textField setBezeled:NO];
    [_textField setDrawsBackground:NO];
    [_textField setTextColor:[NSColor colorWithDeviceWhite:0.9f alpha:1.f]];
    [_textField setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    _textField.layer.shadowOpacity = 0.3f;
    _textField.layer.shadowColor = [NSColor colorWithDeviceWhite:1.f alpha:1.f].CGColor;
    _textField.layer.shadowOffset = (NSSize){ .width = 0.f, .height = 0.f };
    _textField.layer.shadowRadius = 1.f;
    
    return self;
}

- (NSString *)stringValue {
    return self.textField.stringValue;
}

- (void)setStringValue:(NSString *)stringValue {
    self.textField.stringValue = stringValue;
}

- (BOOL)evaluateWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags {
    if (self.evaluationBlock) return self.evaluationBlock(keyCode, modifierFlags);
    
    return NO;
}

@end
