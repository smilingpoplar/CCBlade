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

#ifndef CCBlade_CCBlade_h
#define CCBlade_CCBlade_h

#include "cocos2d.h"

typedef cocos2d::ccVertex2F CGPoint;
#define cgp(__X__, __Y__) vertex2(__X__, __Y__)

class CCBlade : public cocos2d::CCNode, public cocos2d::CCRGBAProtocol {
private:
    CC_SYNTHESIZE_RETAIN(cocos2d::CCTexture2D *, _texture, Texture);
    int _pointLimit;
    std::vector<CGPoint> _path;
    CGPoint *_vertices;
    CGPoint *_texCoords;
    bool _autoCleanup;
    // shader stuff
    GLint _uniformColor;
private:
    ~CCBlade();
    CCBlade(const char *filePath, float stroke, int pointLimit);
    void populateVertices();
    void pop(int count);
    void popLastOne(float delta);
    void draw();
public:
    CC_PROPERTY(float, _stroke, Stroke);
    CC_PROPERTY(float, _drainInterval, DrainInterval);
    // CCRGBAProtocol
    CC_PROPERTY_PASS_BY_REF(cocos2d::ccColor3B, _color, Color);
    CC_PROPERTY(GLubyte, _opacity, Opacity);
    virtual void setOpacityModifyRGB(bool bValue) {CC_UNUSED_PARAM(bValue);}
    virtual bool isOpacityModifyRGB(void) { return false;}
public:
    static CCBlade* create(const char *filePath, float stroke, int pointLimit);
    void push(const cocos2d::CCPoint &point);
    void autoCleanup();
};

#endif
