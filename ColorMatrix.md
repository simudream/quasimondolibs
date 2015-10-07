# Introduction #

Yeah, one day there will be one...


# Details #

```
var colorMatrix:ColorMatrix = new ColorMatrix();
colorMatrix.adjustBrightness( 50 );
colorMatrix.rotateHue( 45 );

someBitmapData.applyFilter( someBitmapData, someBitmapData.rect, someBitmapData.rect.topLeft, colorMatrix.filter );
```