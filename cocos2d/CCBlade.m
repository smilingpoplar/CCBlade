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

#import "CCBlade.h"

static inline float angle(CGPoint vect)
{
    if (vect.x == 0.0 && vect.y == 0.0) {
        return 0;
    }
    if (vect.x == 0.0) {
        return vect.y > 0 ? M_PI/2 : -M_PI/2;
    }
    if (vect.y == 0.0 && vect.x < 0) {
        return -M_PI;
    }
    float angle = atan(vect.y / vect.x);
    
    return vect.x < 0 ? angle + M_PI : angle;
}

static inline void populateBorderVertices(CGPoint p1, CGPoint p2, float d, CGPoint *o1, CGPoint *o2)
{
    float l = ccpDistance(p1, p2);
    float a = angle(ccpSub(p2, p1));
    *o1 = ccpRotateByAngle(ccp(p1.x+l, p1.y+d), p1, a);
    *o2 = ccpRotateByAngle(ccp(p1.x+l, p1.y-d), p1, a);
}

static inline void CGPointSet(CGPoint *p, float x, float y)
{
    p->x = x;
    p->y = y;
}

@interface CCBlade ()
{
    CCTexture2D *_texture;
    int _pointLimit;
    NSMutableArray *_path;
    CGPoint *_vertices;
    CGPoint *_texCoords;
    BOOL _autoCleanup;
}
@end

@implementation CCBlade
@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize stroke = _stroke;
@synthesize drainInterval = _drainInterval;

- (void)dealloc
{
    [_texture release];
    [_path release];    
    free(_vertices);
    free(_texCoords);
    [super dealloc];
}

- (void)setStroke:(float)stroke
{
    _stroke = stroke * CC_CONTENT_SCALE_FACTOR();
}

#define POINT_LIMIT_MIN 3

- (id)initWithImage:(NSString *)filePath stroke:(float)stroke pointLimit:(int)pointLimit
{
    self = [super init];
    if (self) {
        _color = ccWHITE;
        _opacity = 255;
        _texture = [[[CCTextureCache sharedTextureCache] addImage:filePath] retain];
        self.stroke = stroke;
        NSAssert(pointLimit >= POINT_LIMIT_MIN, @"point limit should be >= %d", POINT_LIMIT_MIN);
        _pointLimit = pointLimit;
        _path = [[NSMutableArray alloc] initWithCapacity:pointLimit];        
        
        // head point => 1 vertex, body point => 2 vertices, tail point => 1 vertex
        int vertexCount = 2*pointLimit-2;
        _vertices = (CGPoint *)calloc(vertexCount, sizeof(CGPoint));
        _texCoords = (CGPoint *)calloc(vertexCount, sizeof(CGPoint));
    }
    return self;
}

+ (id)bladeWithImage:(NSString *)filePath stroke:(float)stroke pointLimit:(int)pointLimit
{
    return [[[self alloc] initWithImage:filePath stroke:stroke pointLimit:pointLimit] autorelease];
}

- (void)populateVertices
{
    // head
    int i = 0;
    _vertices[0] = [[_path objectAtIndex:i] CGPointValue];
    CGPointSet(&_texCoords[0], 0.0, 0.5);
    i++;

    // body
    float strokeFactor = _stroke / _path.count;
    CGPoint previous = _vertices[0];
    while (i < _path.count-1) {
        CGPoint current = [[_path objectAtIndex:i] CGPointValue];
        populateBorderVertices(previous, current, _stroke-i*strokeFactor, &_vertices[2*i-1], &_vertices[2*i]);
        CGPointSet(&_texCoords[2*i-1], 0.5, 1.0);
        CGPointSet(&_texCoords[2*i], 0.5, 0.0);

        previous = current;
        i++;
    }
    
    // modified for head
    CGPointSet(&_texCoords[1], 0.25, 1.0); 
    CGPointSet(&_texCoords[2], 0.25, 0.0);
    
    // tail
    _vertices[2*i-1] = [[_path objectAtIndex:i] CGPointValue];
    CGPointSet(&_texCoords[2*i-1], 0.75, 0.5);
}

#define DISTANCE_TO_INTERPOLATE 10

- (void)push:(CGPoint)point
{
    if (CC_CONTENT_SCALE_FACTOR() != 1.0) {
        point = ccpMult(point, CC_CONTENT_SCALE_FACTOR());
    }

    if (_path.count == 0) {
        [_path insertObject:[NSValue valueWithCGPoint:point] atIndex:0];
        return;
    }
    
    CGPoint first = [[_path objectAtIndex:0] CGPointValue];
    float distance = ccpDistance(point, first);
    if (distance < DISTANCE_TO_INTERPOLATE) {
        [_path insertObject:[NSValue valueWithCGPoint:point] atIndex:0];
    } else {
        int count = distance / DISTANCE_TO_INTERPOLATE + 1;
        CGPoint interval = ccpMult(ccpSub(point, first), 1.0/count);
        for (int i = 1; i <= count; i++) {
            [_path insertObject:[NSValue valueWithCGPoint:ccpAdd(first, ccpMult(interval, i))] atIndex:0];
        }
    }
    while (_path.count > _pointLimit) {
        [_path removeLastObject];
    }

    [self populateVertices];
}

- (void)pop:(int)count 
{
    while (_path.count > 0 && count > 0) {
        [_path removeLastObject];
        count--;
    }
    
    if (_path.count >= POINT_LIMIT_MIN) {
        [self populateVertices];
    } 
}

- (void)popLastOne:(ccTime)delta
{
    [self pop:1];
    if (_autoCleanup && _path.count < POINT_LIMIT_MIN) {
        [_path removeAllObjects];
        [self removeFromParentAndCleanup:YES];
    }
}

- (void)setDrainInterval:(float)drainInterval
{
    _drainInterval = drainInterval;
    if (drainInterval > 0) {
        [self schedule:@selector(popLastOne:) interval:drainInterval];
    } else {
        [self unschedule:@selector(popLastOne:)];
    }
}

- (void)autoCleanup
{
    _autoCleanup = YES;
    if (_drainInterval <= 0) {
        self.drainInterval = 1.0/60;
    }
}

- (void)draw
{
    if (_path.count < POINT_LIMIT_MIN) {
        return;
    }
    
    glDisableClientState(GL_COLOR_ARRAY);
//    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST); // set

    glColor4ub(_color.r, _color.g, _color.b, _opacity);
    glBindTexture(GL_TEXTURE_2D, _texture.name);
    glVertexPointer(2, GL_FLOAT, 0, _vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _texCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 2*_path.count-2);

//    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST); // reset
    glEnableClientState(GL_COLOR_ARRAY);
}

@end
