//
//  Copyright (c) 2012-2013, Vadim Shpakovski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//
//  The source code in this file was borrowed from the awesome MASShortcut:
//  https://github.com/shpakovski/MASShortcut
//

#import "MASShortcut.h"
#import <Carbon/Carbon.h>

NSString *ITStringForKeyMask (NSUInteger keyMask)
{
    unichar chars[1];
    // These are in the same order as the menu manager shows them
    if (keyMask == NSControlKeyMask) chars[0] = kControlUnicode;
    else if (keyMask == NSAlternateKeyMask) chars[0] = kOptionUnicode;
    else if (keyMask == NSShiftKeyMask) chars[0] = kShiftUnicode;
    else if (keyMask == NSCommandKeyMask) chars[0] = kCommandUnicode;
    
    return [NSString stringWithCharacters:chars length:1];
}

NSString *ITStringForKeyCode (NSUInteger keyCode) {
    // Some key codes don't have an equivalent
    switch (keyCode) {
        case NSNotFound: return @"";
        case kVK_F1: return @"F1";
        case kVK_F2: return @"F2";
        case kVK_F3: return @"F3";
        case kVK_F4: return @"F4";
        case kVK_F5: return @"F5";
        case kVK_F6: return @"F6";
        case kVK_F7: return @"F7";
        case kVK_F8: return @"F8";
        case kVK_F9: return @"F9";
        case kVK_F10: return @"F10";
        case kVK_F11: return @"F11";
        case kVK_F12: return @"F12";
        case kVK_F13: return @"F13";
        case kVK_F14: return @"F14";
        case kVK_F15: return @"F15";
        case kVK_F16: return @"F16";
        case kVK_F17: return @"F17";
        case kVK_F18: return @"F18";
        case kVK_F19: return @"F19";
        case kVK_Space: return NSLocalizedString(@"Space", @"Shortcut glyph name for SPACE key");
        case kVK_Escape: return MASShortcutChar(kMASShortcutGlyphEscape);
        case kVK_Delete: return MASShortcutChar(kMASShortcutGlyphDeleteLeft);
        case kVK_ForwardDelete: return MASShortcutChar(kMASShortcutGlyphDeleteRight);
        case kVK_LeftArrow: return MASShortcutChar(kMASShortcutGlyphLeftArrow);
        case kVK_RightArrow: return MASShortcutChar(kMASShortcutGlyphRightArrow);
        case kVK_UpArrow: return MASShortcutChar(kMASShortcutGlyphUpArrow);
        case kVK_DownArrow: return MASShortcutChar(kMASShortcutGlyphDownArrow);
        case kVK_Help: return MASShortcutChar(kMASShortcutGlyphHelp);
        case kVK_PageUp: return MASShortcutChar(kMASShortcutGlyphPageUp);
        case kVK_PageDown: return MASShortcutChar(kMASShortcutGlyphPageDown);
        case kVK_Tab: return MASShortcutChar(kMASShortcutGlyphTabRight);
        case kVK_Return: return MASShortcutChar(kMASShortcutGlyphReturnR2L);
            
            // Keypad
        case kVK_ANSI_Keypad0: return @"0";
        case kVK_ANSI_Keypad1: return @"1";
        case kVK_ANSI_Keypad2: return @"2";
        case kVK_ANSI_Keypad3: return @"3";
        case kVK_ANSI_Keypad4: return @"4";
        case kVK_ANSI_Keypad5: return @"5";
        case kVK_ANSI_Keypad6: return @"6";
        case kVK_ANSI_Keypad7: return @"7";
        case kVK_ANSI_Keypad8: return @"8";
        case kVK_ANSI_Keypad9: return @"9";
        case kVK_ANSI_KeypadDecimal: return @".";
        case kVK_ANSI_KeypadMultiply: return @"*";
        case kVK_ANSI_KeypadPlus: return @"+";
        case kVK_ANSI_KeypadClear: return MASShortcutChar(kMASShortcutGlyphPadClear);
        case kVK_ANSI_KeypadDivide: return @"/";
        case kVK_ANSI_KeypadEnter: return MASShortcutChar(kMASShortcutGlyphReturn);
        case kVK_ANSI_KeypadMinus: return @"–";
        case kVK_ANSI_KeypadEquals: return @"=";
            
            // Hardcode
        case 119: return MASShortcutChar(kMASShortcutGlyphSoutheastArrow);
        case 115: return MASShortcutChar(kMASShortcutGlyphNorthwestArrow);
    }
    
    // Everything else should be printable so look it up in the current keyboard
    OSStatus error = noErr;
    NSString *keystroke = nil;
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
    if (inputSource) {
        CFDataRef layoutDataRef = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
        if (layoutDataRef) {
            UCKeyboardLayout *layoutData = (UCKeyboardLayout *)CFDataGetBytePtr(layoutDataRef);
            UniCharCount length = 0;
            UniChar  chars[256] = { 0 };
            UInt32 deadKeyState = 0;
            error = UCKeyTranslate(layoutData, (UInt16)keyCode, kUCKeyActionDisplay, 0, // No modifiers
                                   LMGetKbdType(), kUCKeyTranslateNoDeadKeysMask, &deadKeyState,
                                   sizeof(chars) / sizeof(UniChar), &length, chars);
            keystroke = ((error == noErr) && length ? [NSString stringWithCharacters:chars length:length] : @"");
        }
        CFRelease(inputSource);
    }
    
    // Validate keystroke
    if (keystroke.length) {
        static NSMutableCharacterSet *validChars = nil;
        if (validChars == nil) {
            validChars = [[NSMutableCharacterSet alloc] init];
            [validChars formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
            [validChars formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
            [validChars formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
        }
        for (NSUInteger i = 0, length = keystroke.length; i < length; i++) {
            if (![validChars characterIsMember:[keystroke characterAtIndex:i]]) {
                keystroke = @"";
                break;
            }
        }
    }
    
    // Finally, we've got a shortcut!
    return keystroke.uppercaseString;
}
