//
//  U4DShaderHelperFunctions.h
//  UntoldEngine
//
//  Created by Harold Serrano on 10/22/19.
//  Copyright © 2019 Untold Engine Studios. All rights reserved.
//

#ifndef U4DShaderHelperFunctions_h
#define U4DShaderHelperFunctions_h

struct Light{
    
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float4 position;
    float constantAttenuation;
    float linearAttenuation;
    float expAttenuation;
    float energy;
    float falloutDistance;
    
};

struct Material{
    
    float3 ambientMaterialColor;
    float3 diffuseMaterialColor;
    float3 specularMaterialColor;
    float specularReflectionPower;
};

//This is used for shadows
constant float2 poissonDisk[16]={float2( 0.282571, 0.023957 ),
    float2( 0.792657, 0.945738 ),
    float2( 0.922361, 0.411756 ),
    float2( 0.165838, 0.552995 ),
    float2( 0.566027, 0.216651),
    float2( 0.335398,0.783654),
    float2( 0.0190741,0.318522),
    float2( 0.647572,0.581896),
    float2( 0.916288,0.0120243),
    float2( 0.0278329,0.866634),
    float2( 0.398053,0.4214),
    float2( 0.00289926,0.051149),
    float2( 0.517624,0.989044),
    float2( 0.963744,0.719901),
    float2( 0.76867,0.018128),
    float2( 0.684194,0.167302)
};

/**
 @brief computes the light color for the 3d object
 @param uLightPosition light position
 @param uVerticesInMVSpace verts in Model-View Space
 @param uNormalInMVSpace normal vectors in Model-View Space
 @param uMaterial Material properties
 @param uLightColor light color properties
 */
float4 computeLightColor(float4 uVerticesInMVSpace, float3 uNormalInMVSpace, Material uMaterial, Light uLight);

float4 computePointLightColor(float4 uVerticesInMVSpace, float3 uNormalInMVSpace, Material uMaterial, Light uLight);

float3 fresnelSchlick(float cosTheta,float3 F0);

float D_GGX(float NoH,float roughness);

float G1_GGX_Schlick(float NoV, float roughness);

float G_smith(float NoV, float NoL,float roughness);

// Cook-Torrance BRDF function
float3 cookTorranceBRDF(float3 incomingLightDir, float3 surfaceNormal, float3 viewDir, float3 diffuseColor, float3 specularColor, float roughness, float metallic, float reflectance);





#endif /* U4DShaderHelperFunctions_h */
