import QtQuick 2.7

QtObject {
    id: root

    property color color
    property real ignoredHue: 0
    property Component shader: ShaderEffect {
        property color color: root.color
        property real hue: root.ignoredHue
        fragmentShader: "
            uniform sampler2D source;
            uniform lowp vec4 color;
            uniform lowp float hue;
            uniform lowp float qt_Opacity;
            varying highp vec2 qt_TexCoord0;

            vec3 rgb2hsv(vec3 c)
            {
                lowp vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                lowp vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
                lowp vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

                lowp float d = q.x - min(q.w, q.y);
                lowp float e = 1.0e-10;
                return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            void main() {
                lowp vec4 c = texture2D(source, qt_TexCoord0);
                lowp vec3 hsv = rgb2hsv(c.xyz);
                if (abs(hsv.x - hue) < 0.03 || abs(hsv.x - hue) > 0.97) {
                    gl_FragColor = qt_Opacity * c;
                } else {
                    lowp float lo = min(min(c.x, c.y), c.z);
                    lowp float hi = max(max(c.x, c.y), c.z);
                    gl_FragColor = qt_Opacity * vec4(mix(vec3(lo), vec3(hi), color.xyz), c.w);
                }
            }"
    }
}
