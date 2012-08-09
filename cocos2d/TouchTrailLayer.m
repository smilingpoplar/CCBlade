/*
 * cocos2d+ext for iPhone
 *
 * Copyright (c) 2011 - Ngo Duc Hiep
 * Copyright (c) 2012 - YangLe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "TouchTrailLayer.h"
#import "CCBlade.h"

@implementation TouchTrailLayer

- (id)init
{
	self = [super init];
    if (self) {
        map = CFDictionaryCreateMutable(0,0,0,0);
        isTouchEnabled_ = YES;
    }
	return self;
}

- (void)ccTouchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
	for (UITouch *touch in touches) {
		CCBlade *blade = [CCBlade bladeWithImage:@"streak.png" stroke:4 pointLimit:50];
        CFDictionaryAddValue(map,touch,blade);
		[self addChild:blade];
 
        blade.color = ccc3(255,0,0);
        blade.opacity = 100;
        blade.drainInterval = 1.0/40;
        
        CGPoint point = [self convertTouchToNodeSpace:touch];
		[blade push:point];
	}
}

- (void)ccTouchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	for (UITouch *touch in touches) {
		CCBlade *blade = (CCBlade *)CFDictionaryGetValue(map, touch);
        CGPoint point = [self convertTouchToNodeSpace:touch];
		[blade push:point];
	}
}

- (void)ccTouchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
	for (UITouch *touch in touches) {
		CCBlade *blade = (CCBlade *)CFDictionaryGetValue(map, touch);
        [blade autoCleanup];
        CFDictionaryRemoveValue(map,touch);
	}
}

- (void)dealloc
{
    CFRelease(map);
    [super dealloc];
}

@end
