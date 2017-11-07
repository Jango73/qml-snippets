import QtQuick 2.5
import Qt3D.Core 2.0
import Qt3D.Render 2.0

Material {
    id: root
    property color ambientColor: Qt.rgba(0.05, 0.05, 0.05, 1.0)
    property color diffuseColor: Qt.rgba(1.0, 1.0, 1.0, 1.0)
    property real metallic: 0.5
    property real roughness: 0.5
    property real glossy: 0.5
    property real emission: 0.0
    property bool environmentOnly: false
    property int environmentSampleCount: 0
    property real normalMapAmount: 0
    property Texture2D diffuseMap
    property Texture2D environmentMap
    property Texture2D normalMap

    parameters: [
        Parameter { name: "ambientColor"; value: Qt.vector4d(root.ambientColor.r, root.ambientColor.g, root.ambientColor.b, root.ambientColor.a) },
        Parameter { name: "diffuseColor"; value: Qt.vector4d(root.diffuseColor.r, root.diffuseColor.g, root.diffuseColor.b, root.diffuseColor.a) },
        Parameter { name: "metallic"; value: root.metallic },
        Parameter { name: "roughness"; value: root.roughness },
        Parameter { name: "glossy"; value: root.glossy },
        Parameter { name: "emission"; value: root.emission },
        Parameter { name: "environmentOnly"; value: root.environmentOnly },
        Parameter { name: "environmentSampleCount"; value: root.environmentSampleCount },
        Parameter { name: "normalMapAmount"; value: root.normalMapAmount },
        Parameter { name: "diffuseMap"; value: root.diffuseMap },
        Parameter { name: "environmentMap"; value: root.environmentMap },
        Parameter { name: "normalMap"; value: root.normalMap }
    ]
}
