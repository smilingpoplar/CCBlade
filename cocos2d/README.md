
refactor hiepnd‘s CCBlade for cocos2d-1.x, clean up code && add some properties:

    @property ccColor3B color;
    @property GLubyte opacity;
    @property float stroke;
    @property float drainInterval;

### Usage
Add *TouchTrailLayer* to your scene to see how it works.

texture size 128 x 16, texture<->blade mapping:

    textue: | 32 x 16 | 32 x 16 | 32 x 16 | 32 x 16  |
     blade: |  head   |  body   |  tail   |  unused  |
