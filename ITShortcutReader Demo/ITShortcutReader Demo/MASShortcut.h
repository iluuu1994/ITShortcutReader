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


#import <Foundation/Foundation.h>

//enum {
//    kShiftUnicode                 = 0x21E7, /* Unicode UPWARDS WHITE ARROW*/
//    kControlUnicode               = 0x2303, /* Unicode UP ARROWHEAD*/
//    kOptionUnicode                = 0x2325, /* Unicode OPTION KEY*/
//    kCommandUnicode               = 0x2318, /* Unicode PLACE OF INTEREST SIGN*/
//    kPencilUnicode                = 0x270E, /* Unicode LOWER RIGHT PENCIL; actually pointed left until Mac OS X 10.3*/
//    kPencilLeftUnicode            = 0xF802, /* Unicode LOWER LEFT PENCIL; available in Mac OS X 10.3 and later*/
//    kCheckUnicode                 = 0x2713, /* Unicode CHECK MARK*/
//    kDiamondUnicode               = 0x25C6, /* Unicode BLACK DIAMOND*/
//    kBulletUnicode                = 0x2022, /* Unicode BULLET*/
//    kAppleLogoUnicode             = 0xF8FF /* Unicode APPLE LOGO*/
//};

#define MASShortcutChar(char) [NSString stringWithFormat:@"%C", (unsigned short)(char)]
#define MASShortcutClear(flags) (flags & (NSControlKeyMask | NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask))
#define MASShortcutCarbonFlags(cocoaFlags) (\
(cocoaFlags & NSCommandKeyMask ? cmdKey : 0) | \
(cocoaFlags & NSAlternateKeyMask ? optionKey : 0) | \
(cocoaFlags & NSControlKeyMask ? controlKey : 0) | \
(cocoaFlags & NSShiftKeyMask ? shiftKey : 0))

// These glyphs are missed in Carbon.h
enum {
    kMASShortcutGlyphEject = 0x23CF,
    kMASShortcutGlyphClear = 0x2715,
	kMASShortcutGlyphDeleteLeft = 0x232B,
	kMASShortcutGlyphDeleteRight = 0x2326,
    kMASShortcutGlyphLeftArrow = 0x2190,
	kMASShortcutGlyphRightArrow = 0x2192,
	kMASShortcutGlyphUpArrow = 0x2191,
	kMASShortcutGlyphDownArrow = 0x2193,
	kMASShortcutGlyphEscape = 0x238B,
	kMASShortcutGlyphHelp = 0x003F,
    kMASShortcutGlyphPageDown = 0x21DF,
	kMASShortcutGlyphPageUp = 0x21DE,
	kMASShortcutGlyphTabRight = 0x21E5,
	kMASShortcutGlyphReturn = 0x2305,
	kMASShortcutGlyphReturnR2L = 0x21A9,
	kMASShortcutGlyphPadClear = 0x2327,
	kMASShortcutGlyphNorthwestArrow = 0x2196,
	kMASShortcutGlyphSoutheastArrow = 0x2198,
} MASShortcutGlyph;

NSString *ITStringForKeyMask (NSUInteger keyMask);
NSString *ITStringForKeyCode (NSUInteger keyCode);