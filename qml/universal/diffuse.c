vec4 shade()
{
    float diffuseFactor = beckmannDiffuse(0.6);
    return vec4(materialDiffuseColor.rgb * diffuseFactor, 1.0);
}
