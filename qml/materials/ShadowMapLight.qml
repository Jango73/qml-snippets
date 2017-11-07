
import Qt3D.Core 2.0
import Qt3D.Render 2.0

Entity {
    id: root

    property alias position: lightCamera.position
    property alias fieldOfView: lightCamera.fieldOfView
    property alias aspectRatio: lightCamera.aspectRatio
    property alias nearPlane: lightCamera.nearPlane
    property alias farPlane: lightCamera.farPlane
    property alias upVector: lightCamera.upVector
    property alias viewCenter: lightCamera.viewCenter

    property vector3d lightDirection: lightCamera.viewCenter.minus(lightCamera.position)
    property color lightColor: Qt.rgba(1.0, 1.0, 1.0, 1.0)
    property real lightIntensity: 1.0
    property real lightDistance: 10.0
    property real lightOuterAngle: 0.0
    property bool lightIsDirectional: false

    readonly property Camera lightCamera: lightCamera
    readonly property matrix4x4 lightViewProjection: lightCamera.projectionMatrix.times(lightCamera.viewMatrix)

    Camera {
        id: lightCamera
        objectName: "lightCameraLens"
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: 45
        aspectRatio: 1
        nearPlane : 10.0
        farPlane : 4000.0
        position: Qt.vector3d(0.0, 0.0, -1.0)
        viewCenter: Qt.vector3d(0.0, 0.0, 0.0)
        upVector: Qt.vector3d(0.0, 1.0, 0.0)
    }
}
