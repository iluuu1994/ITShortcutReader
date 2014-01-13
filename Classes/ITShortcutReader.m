//
//  ITShortcutReader.m
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITShortcutReader.h"
#import "MASShortcut.h"

#define kTextColor [NSColor colorWithDeviceWhite:0.55f alpha:1.f]
#define kFontSize 14.f
#define kTextFieldHeight 19.f
#define kTextFieldMargin 6.f
#define kKeyViewMargin 10.f
#define kKeyViewSize 24.f

#define kInactiveStringValue @"Create shortcut"
#define kActiveStringValue @"Recording..."

typedef BOOL(^ITKeyEvaluationBlock)(NSEventType eventType, NSUInteger keyCode, NSUInteger modifierFlags);

@interface ITShortcutReaderKeyView : NSView
@property (strong) CALayer *hostedLayer;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSTextField *textField;
@property (strong) ITKeyEvaluationBlock evaluationBlock;
- (BOOL)evaluateWithType:(NSEventType)eventType
                 keyCode:(NSUInteger)keyCode
           modifierFlags:(NSUInteger)modifierFlags;
@end

@implementation ITShortcutReaderKeyView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    self.wantsLayer = YES;
    
    _hostedLayer = [CALayer layer];
    NSImage *backgroundImage = [NSImage imageNamed:@"shortcutReaderKey"];
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
    [_textField setTextColor:[NSColor colorWithDeviceWhite:0.45f alpha:1.f]];
    [_textField setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    _textField.layer.shadowOpacity = 0.6f;
    _textField.layer.shadowColor = [NSColor colorWithDeviceWhite:1.f alpha:1.f].CGColor;
    _textField.layer.shadowOffset = (NSSize){ .width = 0.f, .height = 1.f };
    _textField.layer.shadowRadius = 0.f;
    
    return self;
}

- (NSString *)stringValue {
    return self.textField.stringValue;
}

- (void)setStringValue:(NSString *)stringValue {
    self.textField.stringValue = stringValue;
}

- (BOOL)evaluateWithType:(NSEventType)eventType keyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags {
    if (self.evaluationBlock) return self.evaluationBlock(eventType, keyCode, modifierFlags);
    
    return NO;
}

@end




@interface ITShortcutReader ()
@property (strong, readonly) CALayer *hostedLayer;

// Cancel button
@property (strong) NSButton *cancelButton;

// Labels
@property (strong) NSView *labelWrapper;
@property (strong, readonly) NSTextField *inactiveLabel;
@property (strong, readonly) NSTextField *activeLabel;

// Keys
@property (strong) NSView *keyViewWrapper;
@property (strong) ITShortcutReaderKeyView *controlKeyView;
@property (strong) ITShortcutReaderKeyView *altKeyView;
@property (strong) ITShortcutReaderKeyView *shiftKeyView;
@property (strong) ITShortcutReaderKeyView *commandKeyView;
@property (strong) ITShortcutReaderKeyView *keyCodeView;

// The keyCode/modifierFlags that will be displayed if there is no input
@property NSEventType eventType;
@property NSUInteger modifierFlags;
@property NSUInteger keyCode;

// The keyCode/modifierFlags that will be displayed if the user is entering stuff
@property NSEventType inputEventType;
@property NSUInteger inputModifierFlags;
@property NSUInteger inputKeyCode;
@end


@implementation ITShortcutReader

#pragma mark - Init

- (void)setUp
{
    // Init layers
    self.wantsLayer = YES;
    _hostedLayer = [CALayer layer];
    _hostedLayer.delegate = self;
    self.layer = _hostedLayer;
    
    // Init the NSTextFields
    NSRect labelRect = (NSRect){
        .size.width = NSWidth(self.frame) - (kTextFieldMargin * 2) - (16.f * 2),
        .size.height = kTextFieldHeight,
        .origin.x = kTextFieldMargin,
        .origin.y = (NSHeight(self.frame) / 2) - (kTextFieldHeight / 2),
    };
    
    _labelWrapper = [[NSView alloc] initWithFrame:labelRect];
    [_labelWrapper setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
    [self addSubview:_labelWrapper];
    
    // Init the NSTextFields
    int numberOfTextFields = 2;
    __strong NSTextField **textFields[2] = { &_inactiveLabel, &_activeLabel };
    for (int i = 0; i < numberOfTextFields; i++) {
        __strong NSTextField **textField = textFields[i];
        
        *textField = [[NSTextField alloc] initWithFrame:labelRect];
        [*textField setTextColor:kTextColor];
        [*textField setBordered:NO];
        [*textField setSelectable:NO];
        [*textField setEditable:NO];
        [*textField setDrawsBackground:NO];
        [*textField setFont:[NSFont systemFontOfSize:kFontSize]];
        [(*textField).cell setLineBreakMode:NSLineBreakByTruncatingTail];
        [*textField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
        
        // We have to add the textField first, so it gets layer-backed, before we can set the shadow
        [_labelWrapper addSubview:*textField];
        
        (*textField).layer.shadowOpacity = 0.6f;
        (*textField).layer.shadowColor = [NSColor colorWithDeviceWhite:1.f alpha:1.f].CGColor;
        (*textField).layer.shadowOffset = (NSSize){ .width = 0.f, .height = 1.f };
        (*textField).layer.shadowRadius = 0.f;
        
    }
    
    _activeLabel.stringValue = kActiveStringValue;
    _activeLabel.alphaValue = 0.f;
    _inactiveLabel.stringValue = kInactiveStringValue;
    
    // Init key views
    [self saveEvent:nil permanently:NO];
    [self saveEvent:nil permanently:YES];
    
    _keyViewWrapper = [[NSView alloc] initWithFrame:self.bounds];
    [_keyViewWrapper setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self addSubview:_keyViewWrapper];
    
    NSSize size = NSMakeSize(kKeyViewSize, kKeyViewSize);
    NSRect frame = (NSRect){
        .size = size,
        .origin.x = kKeyViewMargin,
        .origin.y = NSHeight(self.frame)/2 - size.height/2
    };
    
    int numberOfKeyViews = 4;
    __strong ITShortcutReaderKeyView **keyViews[4] = { &_controlKeyView, &_altKeyView, &_shiftKeyView, &_commandKeyView };
    int modifierFlags[4] = { NSControlKeyMask, NSAlternateKeyMask, NSShiftKeyMask, NSCommandKeyMask };
    
    for (int i = 0; i < numberOfKeyViews; i++) {
        __strong ITShortcutReaderKeyView **keyView = keyViews[i];
        NSUInteger modifierFlag = modifierFlags[i];
        
        (*keyView) = [[ITShortcutReaderKeyView alloc] initWithFrame:frame];
        (*keyView).stringValue = ITStringForKeyMask(modifierFlag);
        (*keyView).alphaValue = 0.f;
        (*keyView).evaluationBlock = ^BOOL(NSEventType eventType, NSUInteger keyCode, NSUInteger modifierFlags) {
            return (modifierFlags & modifierFlag) != 0;
        };
        
        [_keyViewWrapper addSubview:*keyView];
    }
    
    frame.size.width = 50.f;
    _keyCodeView = [[ITShortcutReaderKeyView alloc] initWithFrame:frame];
    _keyCodeView.alphaValue = 0.f;
    _keyCodeView.evaluationBlock = ^BOOL(NSEventType eventType, NSUInteger keyCode, NSUInteger modifierFlags) {
        return (eventType != NSKeyUp) && (ITStringForKeyCode(keyCode).length != 0);
    };
    [_keyViewWrapper addSubview:_keyCodeView];
    
    // TODO: Move to updateLayer
    NSImage *backgroundImage = [NSImage imageNamed:@"shortcutReader"];
    _hostedLayer.contents = backgroundImage;
    _hostedLayer.contentsCenter = (CGRect){
        .origin.x = 4.f / backgroundImage.size.width,
        .origin.y = 6.f / backgroundImage.size.height,
        .size.width = 14.f / backgroundImage.size.width,
        .size.height = 12.f / backgroundImage.size.height
    };
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        _hostedLayer.contentsScale = [NSScreen mainScreen].backingScaleFactor;
    }
    
    // Cancel Button
    _cancelButton = [[NSButton alloc] initWithFrame:(NSRect){
        .origin.x = NSWidth(self.frame) - 32.f,
        .origin.y = NSHeight(self.frame)/2 - 16.f/2,
        .size.width = 16.f,
        .size.height = 16.f,
    }];
    
    [_cancelButton setBordered:NO];
    [_cancelButton setImage:[NSImage imageNamed:@"shortcutReaderCancel"]];
    [_cancelButton setAutoresizingMask:NSViewMinXMargin];
    [_cancelButton setButtonType:NSMomentaryChangeButton];
    [_cancelButton setAlphaValue:0.f];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(cancel:)];
    [self addSubview:_cancelButton];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}


#pragma mark - Rendering

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    
}


#pragma mark - Event handling

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    // Overwrites the current user input
    [self updateKeyViews:nil fromInput:YES];
    
    [NSAnimationContext beginGrouping];
    {
        [NSAnimationContext currentContext].duration = 0.2f;
        
        self.inactiveLabel.animator.alphaValue = 0.f;
        self.activeLabel.animator.alphaValue = 1.f;
        
        self.cancelButton.animator.alphaValue = 1.f;
    }
    [NSAnimationContext endGrouping];
    
    return YES;
}

- (BOOL)resignFirstResponder {
    // Overwrites the current user input
    [self updateKeyViews:nil fromInput:NO];
    
    [NSAnimationContext beginGrouping];
    {
        [NSAnimationContext currentContext].duration = 0.2f;
        
        self.inactiveLabel.animator.alphaValue = 1.f;
        self.activeLabel.animator.alphaValue = 0.f;
        
        self.cancelButton.animator.alphaValue = (self.keyCode != NSNotFound)?1.f:0.f;
    }
    [NSAnimationContext endGrouping];
    
    return YES;
}

- (BOOL)hasFirstResponder {
    return (self.window.firstResponder == self);
}

- (void)keyDown:(NSEvent *)theEvent {
    [self endTypeActionWithEvent:theEvent];
    [self updateKeyViews:theEvent fromInput:YES];
}

- (void)endTypeActionWithEvent:(NSEvent *)event {
    [self saveEvent:event permanently:YES];
    
    // Resign the first responder
    [self.window makeFirstResponder:nil];
}

- (void)saveEvent:(NSEvent *)event permanently:(BOOL)permanently {
    if (!event) {
        if (permanently) {
            self.eventType = 0;
            self.keyCode = NSNotFound;
            self.modifierFlags = 0;
        } else {
            self.inputEventType = 0;
            self.inputKeyCode = NSNotFound;
            self.inputModifierFlags = 0;
        }
    } else {
        if (permanently) {
            self.eventType = event.type;
            self.keyCode = event.keyCode;
            self.modifierFlags = event.modifierFlags;
        } else {
            self.inputEventType = event.type;
            self.inputKeyCode = event.keyCode;
            self.inputModifierFlags = event.modifierFlags;
        }
    }
}

// We don't need this for now, since the action should be completed on keyDown:
//- (void)keyUp:(NSEvent *)theEvent {
//    [self updateModifierFlags:theEvent];
//}

// KeyEquivalents won't work when this control has the first responder
// Disabled when debugging, it can be pretty annoying
#if !DEBUG

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    return self.hasFirstResponder;
}

#endif

- (void)flagsChanged:(NSEvent *)event
{
    [self updateKeyViews:event fromInput:YES];
}

- (void)updateKeyViews:(NSEvent *)event fromInput:(BOOL)fromInput {
    int x = kKeyViewMargin;
    int count = 0;
    
    // Save the current input
    [self saveEvent:event permanently:NO];
    
    // Which input to use
    NSEventType eventType = (fromInput)?self.inputEventType:self.eventType;
    NSUInteger keyCode = (fromInput)?self.inputKeyCode:self.keyCode;
    NSEventType modifierFlags = (fromInput)?self.inputModifierFlags:self.modifierFlags;
    
    // Update the keyCode string
    self.keyCodeView.stringValue = ITStringForKeyCode(keyCode);
    
    // Avoid resizing when clearing the current input
    if (self.keyCodeView.stringValue.length) {
        NSRect keyCodeFrame = self.keyCodeView.frame;
        keyCodeFrame.size.width = self.keyCodeView.textField.attributedStringValue.size.width + (kKeyViewMargin * 2);
        if (keyCodeFrame.size.width < kKeyViewSize) keyCodeFrame.size.width = kKeyViewSize;
        self.keyCodeView.frame = keyCodeFrame;
    }
    
    
    [NSAnimationContext beginGrouping];
    {
        for (ITShortcutReaderKeyView *keyView in @[ self.controlKeyView, self.altKeyView, self.shiftKeyView, self.commandKeyView, self.keyCodeView ]) {
            if ([keyView evaluateWithType:eventType keyCode:keyCode modifierFlags:modifierFlags]) {
                keyView.animator.alphaValue = 1.f;
                keyView.animator.frame = (NSRect){ .size = keyView.frame.size, .origin.y = keyView.frame.origin.y, .origin.x = x };
                x += keyView.bounds.size.width + kKeyViewMargin;
                
                count++;
            } else {
                keyView.animator.alphaValue = 0.f;
                keyView.animator.frame = (NSRect){ .size = keyView.frame.size, .origin.y = keyView.frame.origin.y, .origin.x = kKeyViewMargin };
            }
        }
        
        self.labelWrapper.animator.alphaValue = (count > 0)?0.f:1.f;
    }
    [NSAnimationContext endGrouping];
}

- (IBAction)cancel:(id)sender {
    if (self.hasFirstResponder) {
        // Resign the first responder
        [self.window makeFirstResponder:nil];
    } else {
        [self saveEvent:nil permanently:YES];
        
        // Ugly fix to fade out the cancel button
        [self resignFirstResponder];
    }
    
    [self updateKeyViews:nil fromInput:NO];
}



#pragma mark - Others

// The NSTextField can block the triggering of mouseDown:.
- (NSView *)hitTest:(NSPoint)aPoint {
    if (NSPointInRect([self convertPoint:aPoint fromView:nil], self.cancelButton.frame)) return self.cancelButton;
    if (NSPointInRect(aPoint, self.frame)) return self;

    return nil;
}

@end
