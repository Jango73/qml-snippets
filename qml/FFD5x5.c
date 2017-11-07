uniform sampler2D source;
uniform lowp float qt_Opacity;

uniform lowp bool lightDeformations;
uniform lowp bool showGrid;
uniform lowp vec4 backgroundColor;
uniform lowp vec4 deformationLightColor;

uniform highp vec3 point00;
uniform highp vec3 point01;
uniform highp vec3 point02;
uniform highp vec3 point03;
uniform highp vec3 point04;

uniform highp vec3 point10;
uniform highp vec3 point11;
uniform highp vec3 point12;
uniform highp vec3 point13;
uniform highp vec3 point14;

uniform highp vec3 point20;
uniform highp vec3 point21;
uniform highp vec3 point22;
uniform highp vec3 point23;
uniform highp vec3 point24;

uniform highp vec3 point30;
uniform highp vec3 point31;
uniform highp vec3 point32;
uniform highp vec3 point33;
uniform highp vec3 point34;

uniform highp vec3 point40;
uniform highp vec3 point41;
uniform highp vec3 point42;
uniform highp vec3 point43;
uniform highp vec3 point44;

uniform highp float curvePower;

varying highp vec2 qt_TexCoord0;

#define POINT_RADIUS 0.01
#define LINE_RADIUS (POINT_RADIUS * 0.01)

vec4 gridColor = vec4(1.0, 1.0, 1.0, 1.0);

// Impulse
float impulse(float k, float x)
{
    float h = k * x;
    return h * exp(1.0 - h);
}

// NOT USED FOR NOW
vec3 evaluateBezierPosition(vec3 point0, vec3 point1, vec3 point2, vec3 point3, float t)
{
    vec3 p;
    float oneMinusT = 1.0 - t;
    float b0 = oneMinusT * oneMinusT * oneMinusT;
    float b1 = 3.0 * t * oneMinusT * oneMinusT;
    float b2 = 3.0 * t * t * oneMinusT;
    float b3 = t * t * t;
    return b0 * point0 + b1 * point1 + b2 * point2 + b3 * point3;
}

vec3 moveVectorUsingFFDPoint(vec3 from, vec3 to, vec3 orignalvec, vec3 modifiedvec)
{
    vec3 move = from - to;
    float distance = clamp(distance(from, orignalvec), 0.0, 1.0);
    float weight = 1.0 - distance;
    weight = 1.0 - impulse(curvePower, 1.0 - weight);
    return modifiedvec + (move * weight);
}

vec3 moveVector(vec3 vec)
{
    vec3 result = vec;

    result = moveVectorUsingFFDPoint(vec3(0.00, 0.00, 0.0), point00, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.25, 0.00, 0.0), point01, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.50, 0.00, 0.0), point02, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.75, 0.00, 0.0), point03, vec, result);
    result = moveVectorUsingFFDPoint(vec3(1.00, 0.00, 0.0), point04, vec, result);

    result = moveVectorUsingFFDPoint(vec3(0.00, 0.25, 0.0), point10, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.25, 0.25, 0.0), point11, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.50, 0.25, 0.0), point12, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.75, 0.25, 0.0), point13, vec, result);
    result = moveVectorUsingFFDPoint(vec3(1.00, 0.25, 0.0), point14, vec, result);

    result = moveVectorUsingFFDPoint(vec3(0.00, 0.50, 0.0), point20, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.25, 0.50, 0.0), point21, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.50, 0.50, 0.0), point22, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.75, 0.50, 0.0), point23, vec, result);
    result = moveVectorUsingFFDPoint(vec3(1.00, 0.50, 0.0), point24, vec, result);

    result = moveVectorUsingFFDPoint(vec3(0.00, 0.75, 0.0), point30, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.25, 0.75, 0.0), point31, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.50, 0.75, 0.0), point32, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.75, 0.75, 0.0), point33, vec, result);
    result = moveVectorUsingFFDPoint(vec3(1.00, 0.75, 0.0), point34, vec, result);

    result = moveVectorUsingFFDPoint(vec3(0.00, 1.00, 0.0), point40, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.25, 1.00, 0.0), point41, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.50, 1.00, 0.0), point42, vec, result);
    result = moveVectorUsingFFDPoint(vec3(0.75, 1.00, 0.0), point43, vec, result);
    result = moveVectorUsingFFDPoint(vec3(1.00, 1.00, 0.0), point44, vec, result);

    return result;
}

float disc(vec3 discPosition, float discRadius, vec3 position)
{
    float dist = distance(position, discPosition);
    return dist > discRadius ? 0.0 : 1.0;
}

float line(vec3 lineStart, vec3 lineEnd, float thickness, vec3 position)
{
    vec3 v1 = lineEnd - lineStart;
    vec3 v2 = lineStart - position;
    vec3 v3 = cross(v1, v2);
    float d = distance(vec3(0.0, 0.0, 0.0), v3);

    /*
    vec2 lineDir = lineEnd.xy - lineStart.xy;
    vec2 perpDir = vec2(lineDir.y, -lineDir.x);
    vec2 dirToPt1 = lineStart.xy - position.xy;
    float d = abs(dot(normalize(perpDir), dirToPt1));
    */

    return d < thickness ? 1.0 : 0.0;
}

float distanceToSegment(vec2 a, vec2 b, vec2 p)
{
    vec2 n = b - a;
    vec2 pa = a - p;

    float c = dot(n, pa);

    // Closest point is a
    if (c > 0.0)
        return dot(pa, pa);

    vec2 bp = p - b;

    // Closest point is b
    if (dot(n, bp) > 0.0)
        return dot(bp, bp);

    // Closest point is between a and b
    vec2 e = pa - n * (c / dot(n, n));

    return dot(e, e);
}

float segment(vec3 lineStart, vec3 lineEnd, float thickness, vec3 position)
{
    float dist = distanceToSegment(lineStart.xy, lineEnd.xy, position.xy);

    // return dist < thickness ? 1.0 : 0.0;
    return dist > thickness ? 0.0 : (thickness - dist) / thickness;
}

float gridPoints(vec3 position)
{
    float result = 0.0;

    result += disc(point00, POINT_RADIUS, position);
    result += disc(point01, POINT_RADIUS, position);
    result += disc(point02, POINT_RADIUS, position);
    result += disc(point03, POINT_RADIUS, position);
    result += disc(point04, POINT_RADIUS, position);

    result += disc(point10, POINT_RADIUS, position);
    result += disc(point11, POINT_RADIUS, position);
    result += disc(point12, POINT_RADIUS, position);
    result += disc(point13, POINT_RADIUS, position);
    result += disc(point14, POINT_RADIUS, position);

    result += disc(point20, POINT_RADIUS, position);
    result += disc(point21, POINT_RADIUS, position);
    result += disc(point22, POINT_RADIUS, position);
    result += disc(point23, POINT_RADIUS, position);
    result += disc(point24, POINT_RADIUS, position);

    result += disc(point30, POINT_RADIUS, position);
    result += disc(point31, POINT_RADIUS, position);
    result += disc(point32, POINT_RADIUS, position);
    result += disc(point33, POINT_RADIUS, position);
    result += disc(point34, POINT_RADIUS, position);

    result += disc(point40, POINT_RADIUS, position);
    result += disc(point41, POINT_RADIUS, position);
    result += disc(point42, POINT_RADIUS, position);
    result += disc(point43, POINT_RADIUS, position);
    result += disc(point44, POINT_RADIUS, position);

    return result;
}

float gridLines(vec3 position)
{
    float result = 0.0;

    // Horizontal lines

    result += segment(point00, point01, LINE_RADIUS, position);
    result += segment(point01, point02, LINE_RADIUS, position);
    result += segment(point02, point03, LINE_RADIUS, position);
    result += segment(point03, point04, LINE_RADIUS, position);

    result += segment(point10, point11, LINE_RADIUS, position);
    result += segment(point11, point12, LINE_RADIUS, position);
    result += segment(point12, point13, LINE_RADIUS, position);
    result += segment(point13, point14, LINE_RADIUS, position);

    result += segment(point20, point21, LINE_RADIUS, position);
    result += segment(point21, point22, LINE_RADIUS, position);
    result += segment(point22, point23, LINE_RADIUS, position);
    result += segment(point23, point24, LINE_RADIUS, position);

    result += segment(point30, point31, LINE_RADIUS, position);
    result += segment(point31, point32, LINE_RADIUS, position);
    result += segment(point32, point33, LINE_RADIUS, position);
    result += segment(point33, point34, LINE_RADIUS, position);

    result += segment(point40, point41, LINE_RADIUS, position);
    result += segment(point41, point42, LINE_RADIUS, position);
    result += segment(point42, point43, LINE_RADIUS, position);
    result += segment(point43, point44, LINE_RADIUS, position);

    // Vertical lines

    result += segment(point00, point10, LINE_RADIUS, position);
    result += segment(point10, point20, LINE_RADIUS, position);
    result += segment(point20, point30, LINE_RADIUS, position);
    result += segment(point30, point40, LINE_RADIUS, position);

    result += segment(point01, point11, LINE_RADIUS, position);
    result += segment(point11, point21, LINE_RADIUS, position);
    result += segment(point21, point31, LINE_RADIUS, position);
    result += segment(point31, point41, LINE_RADIUS, position);

    result += segment(point02, point12, LINE_RADIUS, position);
    result += segment(point12, point22, LINE_RADIUS, position);
    result += segment(point22, point32, LINE_RADIUS, position);
    result += segment(point32, point42, LINE_RADIUS, position);

    result += segment(point03, point13, LINE_RADIUS, position);
    result += segment(point13, point23, LINE_RADIUS, position);
    result += segment(point23, point33, LINE_RADIUS, position);
    result += segment(point33, point43, LINE_RADIUS, position);

    result += segment(point04, point14, LINE_RADIUS, position);
    result += segment(point14, point24, LINE_RADIUS, position);
    result += segment(point24, point34, LINE_RADIUS, position);
    result += segment(point34, point44, LINE_RADIUS, position);

    return result;
}

void main()
{
    vec3 pixel = vec3(qt_TexCoord0.x, qt_TexCoord0.y, 0.0);
    vec3 vec = moveVector(pixel);
    vec4 color;

    if (vec.x >= 0.0 && vec.y >= 0.0 && vec.x < 1.0 && vec.y < 1.0)
    {
        color = texture2D(source, vec.xy);

        if (lightDeformations)
        {
            float factor = distance(vec, pixel) * 0.75;
            color.r += deformationLightColor.r * factor;
            color.g += deformationLightColor.g * factor;
            color.b += deformationLightColor.b * factor;
        }

        if (showGrid)
        {
            color += gridPoints(pixel) * 0.5 * gridColor;
            color += gridLines(pixel) * 0.5 * gridColor;
        }
    }
    else
    {
        color = backgroundColor;
    }

    gl_FragColor = vec4(color.rgb, color.a * qt_Opacity);
}
