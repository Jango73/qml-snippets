import Qt3D.Core 2.0
import Qt3D.Render 2.0

Effect {
    id: root

    property Texture2D shadowTexture
    property ShadowMapLight light

    // These parameters act as default values for the effect. They take
    // priority over any parameters specified in the RenderPasses below
    // (none provided in this example). In turn these parameters can be
    // overwritten by specifying them in a Material that references this
    // effect.
    // The priority order is:
    //
    // Material -> Effect -> Technique -> RenderPass -> GLSL default values
    parameters: [
        Parameter { name: "lightViewProjection"; value: root.light.lightViewProjection },
        Parameter { name: "lightPosition";  value: root.light.position },
        Parameter { name: "lightDirection";  value: root.light.lightDirection },
        Parameter { name: "lightColor";  value: root.light.lightColor },
        Parameter { name: "lightIntensity"; value: root.light.lightIntensity },
        Parameter { name: "lightDistance"; value: root.light.lightDistance },
        Parameter { name: "lightOuterAngle"; value: root.light.lightOuterAngle },
        Parameter { name: "lightIsDirectional"; value: root.light.lightIsDirectional },
        Parameter { name: "shadowMapTexture"; value: root.shadowTexture }
    ]

    techniques: [
        Technique {
            graphicsApiFilter {
                api: GraphicsApiFilter.OpenGL
                profile: GraphicsApiFilter.CoreProfile
                majorVersion: 3
                minorVersion: 2
            }

            renderPasses: [
                RenderPass {
                    filterKeys: [ FilterKey { name: "pass"; value: "shadowmap" } ]

                    shaderProgram: ShaderProgram {
                        vertexShaderCode:   loadSource(Qt.resolvedUrl("shaders/ShadowMap.vert"))
                        fragmentShaderCode: loadSource(Qt.resolvedUrl("shaders/ShadowMap.frag"))
                    }

                    renderStates: [
                        PolygonOffset { scaleFactor: 4; depthSteps: 4 },
                        DepthTest { depthFunction: DepthTest.Less }
                    ]
                },

                RenderPass {
                    filterKeys: [ FilterKey { name : "pass"; value : "forward" } ]

                    shaderProgram: ShaderProgram {
                        vertexShaderCode:   loadSource(Qt.resolvedUrl("shaders/PBR.vert"))
                        fragmentShaderCode: loadSource(Qt.resolvedUrl("shaders/PBR.frag"))
                    }
                }
            ]
        }
    ]
}
