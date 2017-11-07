
#version 150 core

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec2 vertexTexCoord;
in vec4 vertexTangent;

out vec4 positionInLightSpace;
out vec3 position;
out vec3 normal;
out vec3 normalTangent;
out vec3 normalBitangent;
out vec2 texCoord;
out mat3 tangentMatrix;
out mat3 tangentMatrixInverse;

uniform mat4 lightViewProjection;
uniform mat4 modelMatrix;
uniform mat4 modelView;
uniform mat3 modelViewNormal;
uniform mat4 mvp;

void main()
{
    const mat4 shadowMatrix = mat4(0.5, 0.0, 0.0, 0.0,
                                   0.0, 0.5, 0.0, 0.0,
                                   0.0, 0.0, 0.5, 0.0,
                                   0.5, 0.5, 0.5, 1.0);

    positionInLightSpace = shadowMatrix * lightViewProjection * modelMatrix * vec4(vertexPosition, 1.0);

    position = vec3(modelView * vec4(vertexPosition, 1.0));

    normal = normalize(modelViewNormal * vertexNormal);
    normalTangent = normalize(vec3(modelMatrix * vec4(vertexTangent.xyz, 0.0)));
    normalBitangent = cross(normal, normalTangent) * vertexTangent.w;

    tangentMatrix = mat3(
        normalTangent.x, normalBitangent.x, normal.x,
        normalTangent.y, normalBitangent.y, normal.y,
        normalTangent.z, normalBitangent.z, normal.z);

    tangentMatrixInverse = inverse(tangentMatrix);

    texCoord = vertexTexCoord;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
