import QtQuick 2.5
import "../Utils.js" as Utils

/*!
    \brief This is a 2D+ material and lighting shader, using PBR algorithms.
    PBR = Physically Based Rendering. (Refer to the web for definitions)
    BRDF = Bidirectional Reflectance Distribution Function. (Refer to the web for definitions)

    The shader's actual code is contained in UniversalShader.c.
    The shader is a small rendering engine that mixes the light color with the result of one or many BRDF(s).
    The code that actually computes the diffuse material color is contained in a small c file with only one function: vec4 shade().
    The 'shade' function calls whatever BRDF(s) it wants and returns a vec4 containing the result.

    The precomputed vectors are:
    vec3 position               : the position of the current pixel
    vec3 eyePosition            : the position of the camera
    vec3 eyeDirection           : the normalized direction of the camera
    vec3 surfaceNormal          : the normal vector of the surface (which can be modified by the bump map)
    vec3 surfaceNormalTangent   : the tangent of the normal (needed by some BRDFs)
    vec3 surfaceNormalBitangent : the bitangent of the normal (needed by some BRDFs)
    vec3 lightRay               : the normalized vector that goes from the current pixel to the light
    float facing                : the more the normal is towards the camera, the higher this value
    float facingInverse;        : the inverse of facing

    Examples of a 'shade' function:

    This shade function simply calls the beckmannDiffuse BRDF using the precomputed vectors for light, eye, normal and uses a roughness of 0.6.
    vec4 shade()
    {
        float diffuseFactor = beckmannDiffuse(0.6);
        return vec4(materialDiffuseColor.rgb * diffuseFactor, 1.0);
    }

    This shading function mixes a Oren-Nayar diffuse BRDF and a GGX glossy BRDF.
    vec4 shade()
    {
        float fresnelTerm = fresnel(2.0);
        float diffuseFactor = orenNayarDiffuse(1.0);
        float glossyFactor = ggxGlossy(0.2) * fresnelTerm;
        return vec4(mix(materialDiffuseColor.rgb * diffuseFactor, materialGlossyColor.rgb * glossyFactor, 0.6), 1.0);
    }

    The available BRDFs are:

    float phongDiffuse()
    float orenNayarDiffuse(float roughness)
    float beckmannDiffuse(float roughness)
    float specularGlossy(float power, float lightIntensity)
    float cookTorranceGlossy(float roughness)
    float ggxGlossy(float roughness)

    The available uber-shaders:

    vec3 disney(...)

    Some utility functions:

    float colorLuminosity(vec4 color)
    vec4 contrastSaturationBrightness(vec4 color, float contrast, float saturation, float brightness)
*/

ShaderEffect {
    id: root

    /*!
        The position of the light source (in normalized space).
    */
    property vector3d lightPosition: Qt.vector3d(0.5, 0.5, 1.0)

    /*!
        The direction of the light source (if it is a spot or directional light).
    */
    property vector3d lightDirection: Qt.vector3d(0.0, 0.0, -1.0)

    /*!
        The intensity of the light source (like the energy of a real light).
    */
    property real lightIntensity: 1.0

    /*!
        The maximum distance that the light can reach.
    */
    property real lightDistance: 10.0

    /*!
        The outer angle for a spot light, leave to 0 for a point light.
    */
    property real lightOuterAngle: 0.0

    /*!
        The inner angle for a spot light (not used just yet).
    */
    property real lightInnerAngle: 0.0

    /*!
        The color of the light.
    */
    property color lightColor: Qt.hsva(0.0, 0.0, 1.0, 1.0)

    /*!
        The amount of lens flare effect.
    */
    property real lightFlareIntensity : 0.0

    /*!
        The number of samples to create shadows (0 = no shadows at all).
    */
    property int lightShadowSampleCount: 0

    /*!
        The radius (in normalized space) of the light.
        If greater than 0, the light becomes an area light and casts soft shadows.
    */
    property real lightAreaRadius: 0.0

    /*!
        The number of samples to create soft shadows.
        It is multiplied by lightShadowSampleCount, so go easy on those.
    */
    property int lightAreaSampleCount: 0

    /*!
        When this is \c true, the light is considered directional, like the sun.
        Meaning that all light rays are parallel to each other, given the lightDirection vector.
    */
    property bool lightIsDirectional: false

    /*!
        The material ambient color. The output won't be darker than this.
    */
    property color materialAmbientColor: Qt.hsva(0.0, 0.0, 0.0, 1.0)

    /*!
        The material glossy color.
    */
    property color materialGlossyColor: Qt.hsva(0.0, 0.0, 1.0, 1.0)

    /*!
        The number of samples for environment (don't go too high...)
    */
    property int environmentSampleCount: 0

    property bool computeBumps: true

    /*!
        When this is \c true, the bumpFloorMap must contain a 2D texture to generate floor heights.
    */
    property bool useBumpFloorMap: false

    /*!
        When this is \c true, the bumpCeilingMap must contain a 2D texture to generate ceiling heights.
    */
    property bool useBumpCeilingMap: false

    /*!
        The bump image (or any shader source item) used to generate a height field.
    */
    property variant bumpFloorMap: null

    /*!
        The bump image (or any shader source item) used to generate a height field.
    */
    property variant bumpCeilingMap: null

    /*!
        The bump image (or any shader source item) used to generate environment reflections.
    */
    property variant environmentMap: null

    /*!
        The altitude of the bump map (in normalized space).
        This means that the bottom of the bump map can "float" over the source image.
    */
    property real bumpAltitude: 0.0

    /*!
        The maximum height of the bump map (in normalized space).
    */
    property real bumpCeilingHeight: 0.2

    /*!
        The maximum height of the bump map (in normalized space).
    */
    property real bumpFloorHeight: 0.2

    /*!
        The amount of fog in the 3D space.
    */
    property real fogAmount: 0.0

    /*!
        The size of fog particles.
    */
    property real fogSize: 0.1

    /*!
        When this is \c true, output color is dithered.
    */
    property bool useDithering: false

    property string codeURL: ""

    property real xRatio: width > height ? height / width : 1.0
    property real yRatio: width > height ? 1.0 : width / height

    property real pixelDistanceX: 1.5 / width;
    property real pixelDistanceY: 1.5 / height;

    function getCode() {
        var shaderCode = Utils.openFile(Qt.resolvedUrl("./" + codeURL));
        var finalCode = Utils.openFile(Qt.resolvedUrl("./UniversalShader.c"));
        return finalCode.replace("// %shade%", shaderCode);
    }

    onCodeURLChanged: {
        fragmentShader = getCode()
    }
}
