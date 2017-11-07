import QtQuick 2.5
import "../../system/js/Utils.js" as Utils

/*!
     \brief This is a Free Form Deformation shader.
*/

QtObject {
    id: root

    /*
        Points are defined left to right, top to bottom
        00 ---- 01 ---- 02 ---- 03
        |       |       |       |
        |       |       |       |
        10 ---- 11 ---- 12 ---- 13
        |       |       |       |
        |       |       |       |
        20 ---- 21 ---- 22 ---- 23
        |       |       |       |
        |       |       |       |
        30 ---- 31 ---- 32 ---- 33
    */

    /*!
        If this is \c true, the more an area is deformed, the more it will be colored using deformationLightColor
    */
    property bool lightDeformations: false

    /*!
        If this is \c true, the FFD grid will be shown (for debugging purposes)
    */
    property bool showGrid: false

    /*!
        The color used under the deformed image
    */
    property color backgroundColor: Qt.hsva(0.0, 0.0, 1.0, 1.0)

    /*!
        The color used to light up the image when lightDeformations is \c true
    */
    property color deformationLightColor: Qt.hsva(0.0, 0.0, 1.0, 1.0)

    property vector3d point00: Qt.vector3d(0.00, 0.00, 0.00)
    property vector3d point01: Qt.vector3d(0.33, 0.00, 0.00)
    property vector3d point02: Qt.vector3d(0.66, 0.00, 0.00)
    property vector3d point03: Qt.vector3d(1.00, 0.00, 0.00)

    property vector3d point10: Qt.vector3d(0.00, 0.33, 0.00)
    property vector3d point11: Qt.vector3d(0.33, 0.33, 0.00)
    property vector3d point12: Qt.vector3d(0.66, 0.33, 0.00)
    property vector3d point13: Qt.vector3d(1.00, 0.33, 0.00)

    property vector3d point20: Qt.vector3d(0.00, 0.66, 0.00)
    property vector3d point21: Qt.vector3d(0.33, 0.66, 0.00)
    property vector3d point22: Qt.vector3d(0.66, 0.66, 0.00)
    property vector3d point23: Qt.vector3d(1.00, 0.66, 0.00)

    property vector3d point30: Qt.vector3d(0.00, 1.00, 0.00)
    property vector3d point31: Qt.vector3d(0.33, 1.00, 0.00)
    property vector3d point32: Qt.vector3d(0.66, 1.00, 0.00)
    property vector3d point33: Qt.vector3d(1.00, 1.00, 0.00)

    property real curvePower: 1.0

    property Component shader: ShaderEffect {
        property bool lightDeformations: root.lightDeformations
        property bool showGrid: root.showGrid
        property color backgroundColor: root.backgroundColor
        property color deformationLightColor: root.deformationLightColor

        property vector3d point00: root.point00
        property vector3d point01: root.point01
        property vector3d point02: root.point02
        property vector3d point03: root.point03

        property vector3d point10: root.point10
        property vector3d point11: root.point11
        property vector3d point12: root.point12
        property vector3d point13: root.point13

        property vector3d point20: root.point20
        property vector3d point21: root.point21
        property vector3d point22: root.point22
        property vector3d point23: root.point23

        property vector3d point30: root.point30
        property vector3d point31: root.point31
        property vector3d point32: root.point32
        property vector3d point33: root.point33

        property real curvePower: root.curvePower

        fragmentShader: getCode()

        function getCode() {
            return Utils.openFile(Qt.resolvedUrl("./FFD4x4.c"));
        }
    }
}
