vec4 shade()
{
    float fresnelTerm = fresnel(5.0);
    float diffuseFactor = orenNayarDiffuse(1.0);
    float glossyFactor = cookTorranceGlossy(0.2) * fresnelTerm;
    return vec4(mix(materialDiffuseColor.rgb * diffuseFactor, materialDiffuseColor.rgb * glossyFactor, 0.7), 1.0);
}
