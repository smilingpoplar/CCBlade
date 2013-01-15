
port hiepnd‘s CCBlade to cocos2dx-2.x, clean up code & add some properties:

### Property
    ccColor3B color;
    GLubyte opacity;
    float stroke;
    float drainInterval;

### Usage
Add *TouchTrailLayer* to your scene to see how it works.

texture size 128 x 16, texture<->blade mapping:

    textue: | 32 x 16 | 32 x 16 | 32 x 16 | 32 x 16  |
     blade: |  head   |  body   |  tail   |  unused  |
