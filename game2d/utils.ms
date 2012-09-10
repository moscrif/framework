function clonePaint(paint)
{
    assert paint instanceof Paint;
    var cloned = new Paint();
    cloned.color = paint.color;
    cloned.alpha = paint.alpha;
    cloned.style = paint.style;
    cloned.strokeWidth = paint.strokeWidth;
    cloned.strokeJoin = paint.strokeJoin;
    cloned.strokeCap = paint.strokeCap;
    cloned.textSize = paint.textSize;
    cloned.typeface = paint.typeface;
    return cloned;
}