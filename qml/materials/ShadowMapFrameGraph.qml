
import QtQuick 2.5 as QQ2
import Qt3D.Core 2.0
import Qt3D.Render 2.0

RenderSettings {
    id: root

    property alias viewCamera: viewCameraSelector.camera
    property alias lightCamera: lightCameraSelector.camera
    readonly property Texture2D shadowTexture: depthTexture
    property int shadowTextureSize: 1024
    property alias clearColor: clearBuffers2.clearColor

    activeFrameGraph: Viewport {
        normalizedRect: Qt.rect(0.0, 0.0, 1.0, 1.0)

        RenderSurfaceSelector {
            RenderPassFilter {
                matchAny: [ FilterKey { name: "pass"; value: "shadowmap" } ]

                RenderTargetSelector {
                    target: RenderTarget {
                        attachments: [
                            RenderTargetOutput {
                                objectName: "depth"
                                attachmentPoint: RenderTargetOutput.Depth
                                texture: Texture2D {
                                    id: depthTexture
                                    width: root.shadowTextureSize
                                    height: root.shadowTextureSize
                                    format: Texture.DepthFormat
                                    generateMipMaps: false
                                    magnificationFilter: Texture.Linear
                                    minificationFilter: Texture.Linear
                                    wrapMode {
                                        x: WrapMode.ClampToEdge
                                        y: WrapMode.ClampToEdge
                                    }
                                    comparisonFunction: Texture.CompareLessEqual
                                    comparisonMode: Texture.CompareRefToTexture
                                }
                            }
                        ]
                    }

                    ClearBuffers {
                        buffers: ClearBuffers.DepthBuffer

                        CameraSelector {
                            id: lightCameraSelector
                        }
                    }
                }
            }

            RenderPassFilter {
                matchAny: [ FilterKey { name: "pass"; value: "forward" } ]

                ClearBuffers {
                    id: clearBuffers2
                    buffers: ClearBuffers.ColorDepthBuffer

                    CameraSelector {
                        id: viewCameraSelector
                    }
                }
            }

            Dithering { }
        }
    }
}
