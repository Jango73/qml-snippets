vec4 shade()
{
    float glossyFactor = ggxGlossy(0.1);
    return vec4(glossyFactor, glossyFactor, glossyFactor, 1.0);
}
