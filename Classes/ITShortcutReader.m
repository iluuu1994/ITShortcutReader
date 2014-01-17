//
//  ITShortcutReader.m
//  ITShortcutReader Demo
//
//  Created by Ilija Tovilo on 12/01/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITShortcutReader.h"
#import "ITShortcutReaderKeyView.h"

#define kTextColor [NSColor colorWithDeviceWhite:0.55f alpha:1.f]
#define kFontSize 14.f
#define kTextFieldHeight 19.f
#define kTextFieldMargin 6.f
#define kKeyViewMargin 10.f
#define kKeyViewSize 24.f

#define kInactiveStringValue @"Create shortcut"
#define kActiveStringValue @"Recording..."


@interface ITShortcutReader ()

@property (strong, readonly) CALayer *hostedLayer;
@property (readonly) BOOL hasFirstResponder;

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

// The keyCode/modifierFlags that will be displayed if the user is entering stuff
@property MASShortcut *inputShortcutValue;

@end


@implementation ITShortcutReader

#pragma mark - Init

- (void)setUp
{
    // -----------------------------------
    // ----------- Init layers -----------
    // -----------------------------------
    self.wantsLayer = YES;
    _hostedLayer = [CALayer layer];
    _hostedLayer.delegate = self;
    self.layer = _hostedLayer;
    
    // -----------------------------------
    // ------ Init the NSTextFields ------
    // -----------------------------------
    NSRect labelRect = (NSRect){
        .size.width = NSWidth(self.frame) - (kTextFieldMargin * 2) - (16.f * 2),
        .size.height = kTextFieldHeight,
        .origin.x = kTextFieldMargin,
        .origin.y = (NSHeight(self.frame) / 2) - (kTextFieldHeight / 2),
    };
    
    _labelWrapper = [[NSView alloc] initWithFrame:labelRect];
    [_labelWrapper setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin];
    [self addSubview:_labelWrapper];
    
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
    
    // -----------------------------------
    // ---------- Init KeyViews ----------
    // -----------------------------------
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
        
        // TODO: This is a very quick solution, make this better :P
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:0 modifierFlags:modifierFlag];
        
        (*keyView).stringValue = shortcut.modifierFlagsString;
        (*keyView).alphaValue = 0.f;
        (*keyView).evaluationBlock = ^BOOL(MASShortcut *shortcut) {
            return (shortcut.modifierFlags & modifierFlag) != 0;
        };
        
        [_keyViewWrapper addSubview:*keyView];
    }
    
    frame.size.width = 50.f;
    _keyCodeView = [[ITShortcutReaderKeyView alloc] initWithFrame:frame];
    _keyCodeView.alphaValue = 0.f;
    _keyCodeView.evaluationBlock = ^BOOL(MASShortcut *shortcut) {
        return (shortcut.keyCodeString.length != 0);
    };
    [_keyViewWrapper addSubview:_keyCodeView];
    
    
    // -----------------------------------
    // ---------- Cancel Button ----------
    // -----------------------------------
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
    
    
    // TODO: Move to `updateLayer` method
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
    _hasFirstResponder = YES;
    
    [self saveEvent:nil permanently:NO];
    [self updateKeyViews];
    
    return YES;
}

- (BOOL)resignFirstResponder {
    _hasFirstResponder = NO;
    
    [self saveEvent:nil permanently:NO];
    [self updateKeyViews];
    
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    MASShortcut *shortcut = [MASShortcut shortcutWithEvent:theEvent];
    
    if (shortcut.isValid)
    {
        // Verify that shortcut is not used
        NSError *error = nil;
        if (![shortcut isTakenError:&error])
        {
            // Save the new shortcut data
            [self saveEvent:theEvent permanently:YES];
            
            // Discard the input data
            [self saveEvent:nil permanently:NO];
            
            // Resign the first responder
            [self.window makeFirstResponder:nil];
        } else {
            NSString *format = NSLocalizedString(@"The key combination %@ cannot be used",
                                                 @"Title for alert when shortcut is already used");
            NSRunCriticalAlertPanel([NSString stringWithFormat:format, shortcut], error.localizedDescription,
                                    NSLocalizedString(@"OK", @"Alert button when shortcut is already used"),
                                    nil, nil);
            
            // Discard the invalid shortcut data
            [self saveEvent:nil permanently:NO];
        }
    }
    else {
        NSBeep();
        
        // Discard the invalid shortcut data
        [self saveEvent:nil permanently:NO];
    }
    
    [self updateKeyViews];
}

- (void)saveEvent:(NSEvent *)event permanently:(BOOL)permanently {
    if (!event) {
        if (permanently) {
            _shortcutValue = [MASShortcut new];
            _shortcutValue.keyCode = NSNotFound;
        } else {
            _inputShortcutValue = [MASShortcut new];
            _inputShortcutValue.keyCode = NSNotFound;
        }
    } else {
        if (permanently) {
            _shortcutValue = [MASShortcut shortcutWithEvent:event];
        } else {
            _inputShortcutValue = [MASShortcut shortcutWithEvent:event];
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
    [self saveEvent:event permanently:NO];
    [self updateKeyViews];
}

- (void)updateKeyViews {
    int x = kKeyViewMargin;
    int count = 0;
    
    // Which input to use
    MASShortcut *shortcut = (self.hasFirstResponder)?_inputShortcutValue:_shortcutValue;
    
    // Update the keyCode string
    self.keyCodeView.stringValue = shortcut.keyCodeString;
    
    // Avoid resizing when clearing the current input
    if (self.keyCodeView.stringValue.length) {
        NSRect keyCodeFrame = self.keyCodeView.frame;
        keyCodeFrame.size.width = self.keyCodeView.textField.attributedStringValue.size.width + (kKeyViewMargin * 2);
        if (keyCodeFrame.size.width < kKeyViewSize) keyCodeFrame.size.width = kKeyViewSize;
        self.keyCodeView.frame = keyCodeFrame;
    }
    
    [NSAnimationContext beginGrouping];
    {
        // Animate keys
        for (ITShortcutReaderKeyView *keyView in @[ self.controlKeyView, self.altKeyView, self.shiftKeyView, self.commandKeyView, self.keyCodeView ]) {
            if ([keyView evaluateWithShortcut:shortcut]) {
                keyView.animator.alphaValue = 1.f;
                keyView.animator.frame = (NSRect){ .size = keyView.frame.size, .origin.y = keyView.frame.origin.y, .origin.x = x };
                x += keyView.bounds.size.width + kKeyViewMargin;
                
                count++;
            } else {
                keyView.animator.alphaValue = 0.f;
                keyView.animator.frame = (NSRect){ .size = keyView.frame.size, .origin.y = keyView.frame.origin.y, .origin.x = kKeyViewMargin };
            }
        }
        
        // Animate labels
        self.labelWrapper.animator.alphaValue = (count > 0)?0.f:1.f;
        self.inactiveLabel.animator.alphaValue = (!self.hasFirstResponder)?1.f:0.f;
        self.activeLabel.animator.alphaValue = (self.hasFirstResponder)?1.f:0.f;
        
        // Animate cancel button
        self.cancelButton.animator.alphaValue = (!self.hasFirstResponder && count == 0)?0.f:1.f;
    }
    [NSAnimationContext endGrouping];
}



#pragma mark - Accessors

- (void)setShortcutValue:(MASShortcut *)shortcutValue {
    [self willChangeValueForKey:@"shortcutValue"];
    {
        _shortcutValue = shortcutValue;
    }
    [self didChangeValueForKey:@"shortcutValue"];
    
    [self updateKeyViews];
}



#pragma mark - Others

- (IBAction)cancel:(id)sender {
    if (self.hasFirstResponder) {
        [self.window makeFirstResponder:nil];
    } else {
        [self saveEvent:nil permanently:YES];
        [self updateKeyViews];
    }
    
    [self updateKeyViews];
}

// The NSTextField can block the triggering of mouseDown:.
- (NSView *)hitTest:(NSPoint)aPoint {
    if (NSPointInRect([self convertPoint:aPoint fromView:nil], self.cancelButton.frame)) return self.cancelButton;
    if (NSPointInRect(aPoint, self.frame)) return self;

    return nil;
}

@end
