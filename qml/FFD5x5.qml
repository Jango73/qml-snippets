import QtQuick 2.5
import "../../system/js/Utils.js" as Utils

/*!
     \brief This is a Free Form Deformation shader.
*/

QtObject {
    id: root

    /*
        Points are defined left to right, top to bottom
        00 ---- 01 ---- 02 ---- 03 ---- 04
        |       |       |       |       |
        |       |       |       |       |
        10 ---- 11 ---- 12 ---- 13 ---- 14
        |       |       |       |       |
        |       |       |       |       |
        20 ---- 21 ---- 22 ---- 23 ---- 24
        |       |       |       |       |
        |       |       |       |       |
        30 ---- 31 ---- 32 ---- 33 ---- 34
        |       |       |       |       |
        |       |       |       |       |
        40 ---- 41 ---- 42 ---- 43 ---- 44
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
    property vector3d point01: Qt.vector3d(0.25, 0.00, 0.00)
    property vector3d point02: Qt.vector3d(0.50, 0.00, 0.00)
    property vector3d point03: Qt.vector3d(0.75, 0.00, 0.00)
    property vector3d point04: Qt.vector3d(1.00, 0.00, 0.00)

    property vector3d point10: Qt.vector3d(0.00, 0.25, 0.00)
    property vector3d point11: Qt.vector3d(0.25, 0.25, 0.00)
    property vector3d point12: Qt.vector3d(0.50, 0.25, 0.00)
    property vector3d point13: Qt.vector3d(0.75, 0.25, 0.00)
    property vector3d point14: Qt.vector3d(1.00, 0.25, 0.00)

    property vector3d point20: Qt.vector3d(0.00, 0.50, 0.00)
    property vector3d point21: Qt.vector3d(0.25, 0.50, 0.00)
    property vector3d point22: Qt.vector3d(0.50, 0.50, 0.00)
    property vector3d point23: Qt.vector3d(0.75, 0.50, 0.00)
    property vector3d point24: Qt.vector3d(1.00, 0.50, 0.00)

    property vector3d point30: Qt.vector3d(0.00, 0.75, 0.00)
    property vector3d point31: Qt.vector3d(0.25, 0.75, 0.00)
    property vector3d point32: Qt.vector3d(0.50, 0.75, 0.00)
    property vector3d point33: Qt.vector3d(0.75, 0.75, 0.00)
    property vector3d point34: Qt.vector3d(1.00, 0.75, 0.00)

    property vector3d point40: Qt.vector3d(0.00, 1.00, 0.00)
    property vector3d point41: Qt.vector3d(0.25, 1.00, 0.00)
    property vector3d point42: Qt.vector3d(0.50, 1.00, 0.00)
    property vector3d point43: Qt.vector3d(0.75, 1.00, 0.00)
    property vector3d point44: Qt.vector3d(1.00, 1.00, 0.00)

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
        property vector3d point04: root.point04

        property vector3d point10: root.point10
        property vector3d point11: root.point11
        property vector3d point12: root.point12
        property vector3d point13: root.point13
        property vector3d point14: root.point14

        property vector3d point20: root.point20
        property vector3d point21: root.point21
        property vector3d point22: root.point22
        property vector3d point23: root.point23
        property vector3d point24: root.point24

        property vector3d point30: root.point30
        property vector3d point31: root.point31
        property vector3d point32: root.point32
        property vector3d point33: root.point33
        property vector3d point34: root.point34

        property vector3d point40: root.point40
        property vector3d point41: root.point41
        property vector3d point42: root.point42
        property vector3d point43: root.point43
        property vector3d point44: root.point44

        property real curvePower: root.curvePower

        fragmentShader: getCode()

        function getCode() {
            return Utils.openFile(Qt.resolvedUrl("./FFD5x5.c"));
        }
    }
}
