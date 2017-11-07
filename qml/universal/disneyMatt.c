vec4 shade()
{
    vec3 diffuseColor = disney(
                materialDiffuseColor.rgb,       // baseColor
                0.1,                            // metallic
                0.1,                            // subsurface
                0.0,                            // specular
                0.6,                            // roughness
                0.0,                            // specularTint
                0.0,                            // anisotropic
                0.0,                            // sheen
                0.0,                            // sheenTint
                0.0,                            // clearcoat
                0.0                             // clearcoatGloss
                );

    return vec4(diffuseColor, 1.0);
}
