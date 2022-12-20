//
//  U4DShaderProtocols.h
//  UntoldEngine
//
//  Created by Harold Serrano on 7/14/17.
//  Copyright © 2017 Untold Engine Studios. All rights reserved.
//

#ifndef U4DShaderProtocols_h
#define U4DShaderProtocols_h

#include <simd/simd.h>

typedef enum VertexBufferIndices{
    
    viAttributeBuffer= 0,
    viSpaceBuffer = 1,
    viModelRenderFlagBuffer=2,
    viBoneBuffer=3,
    viModelShaderPropertyBuffer=4,
    viGlobalDataBuffer=5,
    viDirLightPropertiesBuffer=6,
    viParticlesPropertiesBuffer=7,
    
}VertexBufferIndices;

typedef enum FragmentBufferIndices{
    
    fiMaterialBuffer=0,
    fiModelRenderFlagsBuffer=1,
    fiModelShaderPropertyBuffer=2,
    fiGlobalDataBuffer=3,
    fiDirLightPropertiesBuffer=4,
    fiShadowPropertiesBuffer=5,
    fiParticleSysPropertiesBuffer=6,
    fiShaderEntityPropertyBuffer=7,
    fiGeometryBuffer=8,
    fiPointLightsPropertiesBuffer=9,
    fiSpaceBuffer=10
    
}FragmentBufferIndices;

typedef enum FragmentTextureIndices{
    
    fiTexture0=0,
    fiTexture1=1,
    fiTexture2=2,
    fiTexture3=3,
    fiNormalTexture=4,
    fiDepthTexture=5,
    
}FragmentTextureIndices;

typedef enum FragmentSamplerIndices{
    
    fiSampler0=0,
    fiSampler1=1,
    fiSampler2=2,
    fiSampler3=3,
    fiNormalSampler=4,
    
}FragmentSamplerIndices;

typedef struct{
    matrix_float4x4 modelSpace;
    matrix_float4x4 modelViewProjectionSpace;
    matrix_float4x4 modelViewSpace;
    matrix_float4x4 projectionSpace;
    matrix_float4x4 viewSpace;
    matrix_float3x3 normalSpace;
} UniformSpace;

typedef struct{
    
    float time;
    vector_float2 resolution;
    int numberOfPointLights;
    
}UniformGlobalData;

typedef struct{
    
    bool hasTexture;
    bool enableNormalMap;
    bool hasArmature;
    
}UniformModelRenderFlags;

typedef struct{
    
    float biasDepth;
    
}UniformShadowProperties;

typedef struct{
    
    vector_float4 lightPosition;
    vector_float3 diffuseColor;
    vector_float3 specularColor;
    float energy;
    matrix_float4x4 lightShadowProjectionSpace;
    
}UniformDirectionalLightProperties;

typedef struct{
    
    vector_float4 lightPosition;
    vector_float3 diffuseColor;
    vector_float3 specularColor;
    float constantAttenuation;
    float linearAttenuation;
    float expAttenuation;
    float energy;
    float falloutDistance;
    
}UniformPointLightProperties;

typedef struct{
    
    vector_float4 diffuseMaterialColor[10];
    vector_float4 specularMaterialColor[10];
    float diffuseMaterialIntensity[10];
    float specularMaterialIntensity[10];
    float specularMaterialHardness[10];
    
}UniformModelMaterial;

typedef struct{
    
    vector_float4 color;
    float scaleFactor;
    float rotationAngle;
    
}UniformParticleProperty;

typedef struct{
    
    bool hasTexture;
    bool enableNoise;
    float noiseDetail;
    
}UniformParticleSystemProperty;

typedef struct{
    
    float time;
    
}UniformParticleAnimation;

typedef struct{
    
    matrix_float4x4 boneSpace[60];
    
}UniformBoneSpace;

typedef struct{
    
    bool changeImage;
    
}UniformMultiImageState;

typedef struct{
    
    vector_float2 offset;
    
}UniformSpriteProperty;

typedef struct{
    
    vector_float4 lineColor;
    
}UniformGeometryProperty;

typedef struct{
    
    vector_float4 shaderParameter[60];
    bool hasTexture;
    
}UniformShaderEntityProperty;

typedef struct{
    
    vector_float4 shaderParameter[60];
    
}UniformModelShaderProperty;

#endif /* U4DShaderProtocols_h */
