vec4 shade()
{
    float diffuseFactor = orenNayarDiffuse(1.0);
    float alpha = fresnel(4.0);
    vec3 color = materialDiffuseColor.rgb * diffuseFactor * vec3(1.0, 0.5, 0.5);
    return vec4(color, alpha * 0.5);
}
