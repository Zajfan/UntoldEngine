//
//  U4DRenderer.cpp
//  MetalRendering
//
//  Created by Harold Serrano on 7/1/17.
//  Copyright © 2017 Untold Engine Studios. All rights reserved.
//


#include "U4DRenderer.h"
#include "Globals.h"
#include "U4DComponents.h"
#include "U4DMathUtils.h"
#include "U4DTransformSystem.h"
#include "U4DRenderSystem.h"
#include "U4DLoadingSystem.h"
#include "U4DShaderProtocols.h"
#include "U4DJsonReader.h"

extern float nearPlane;
extern float farPlane;
extern U4DEngine::RendererInfo renderInfo;

/// Main class performing the rendering
@implementation U4DRenderer
{
    
    //Timing properties
    CFTimeInterval timeSinceLastUpdatePreviousTime;
    NSTimeInterval timeSinceLastUpdate;
    bool firstUpdateCall;
    
    float contentScale;
    
    int frameCount;
    float timePassedSinceLastFrame;
    
    //set up the semaphores
    dispatch_semaphore_t inFlightSemaphore;
    
    
    id<MTLBuffer> uniformBuffer;
    float rotation;
}

/// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
/// mtkView object to set the pixelformat and other properties of our drawable
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        //test loading
        
        renderInfo.device=mtkView.device;
        renderInfo.commandQueue=[renderInfo.device newCommandQueue];
        renderInfo.library=[renderInfo.device newDefaultLibrary];
        renderInfo.colorPixelFormat=mtkView.colorPixelFormat;
        renderInfo.depthPixelFormat=mtkView.depthStencilPixelFormat;
        renderInfo.drawableSize=simd_make_float2(mtkView.drawableSize.width,mtkView.drawableSize.height);
        
        U4DEngine::initBuffers();
        U4DEngine::initAttachments();
        U4DEngine::initPipelines();
       
                
        camera.lookAt(simd_float3{0.0,5.0,15.0}, simd_float3{0.0,0.0,0.0}, simd_float3{0.0,1.0,0.0});
        
        float width=50.0f;
        float height=50.0f;

        light.orthoMatrix=matrix_ortho_right_hand(-width/2.0, width/2.0, -height/2.0, height/2.0, nearPlane, farPlane);
        
        light.translateTo(simd_float3{30.0,30.0,30.0});
        
        U4DEngine::EntityID voxelEntity=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity);
        scene.assign<U4DEngine::Transform>(voxelEntity);

        U4DEngine::EntityID voxelEntity2=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity2);
        scene.assign<U4DEngine::Transform>(voxelEntity2);
        
        U4DEngine::EntityID voxelEntity3=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity3);
        scene.assign<U4DEngine::Transform>(voxelEntity3);
        
        U4DEngine::EntityID voxelEntity4=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity4);
        scene.assign<U4DEngine::Transform>(voxelEntity4);
        
        U4DEngine::EntityID voxelEntity5=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity5);
        scene.assign<U4DEngine::Transform>(voxelEntity5);
        
        U4DEngine::EntityID voxelEntity6=scene.newEntity();
        scene.assign<U4DEngine::Voxel>(voxelEntity6);
        scene.assign<U4DEngine::Transform>(voxelEntity6);
        
        U4DEngine::addVoxelsToEntity(voxelEntity,"puppy.json");
        U4DEngine::translateTo(voxelEntity, simd_make_float3(0.0, 0.0, 0.0));
        
        U4DEngine::addVoxelsToEntity(voxelEntity2,"puppy2.json");
        U4DEngine::translateTo(voxelEntity2, simd_make_float3(-5.0, 0.0, 0.0));
        
        U4DEngine::addVoxelsToEntity(voxelEntity3,"puppy3.json");
        U4DEngine::translateTo(voxelEntity3, simd_make_float3(5.0, 0.0, 0.0));
        
        U4DEngine::addVoxelsToEntity(voxelEntity4,"floorchunk.json");
        U4DEngine::translateTo(voxelEntity4, simd_make_float3(0.0, -0.4, 0.0));
        
        U4DEngine::addVoxelsToEntity(voxelEntity5,"floorchunk.json");
        U4DEngine::translateTo(voxelEntity5, simd_make_float3(6.0, -0.4, 0.0));
        
        U4DEngine::addVoxelsToEntity(voxelEntity6,"floorchunk.json");
        U4DEngine::translateTo(voxelEntity6, simd_make_float3(-6.0, -0.4, 0.0));
        
    }
    
    return self;
}


#pragma mark - MTKViewDelegate methods

- (void)update{

    if (!firstUpdateCall) {
        
        //init the time properties for the update
        
        timeSinceLastUpdate= 0.0;
        
        timeSinceLastUpdatePreviousTime = CACurrentMediaTime();
        
        firstUpdateCall=true;
        
        //init fps time properties
        frameCount=0;
        timePassedSinceLastFrame=0.0;
        
    }else{
        
        // figure out the time since we last we drew
        CFTimeInterval currentTime = CACurrentMediaTime();
        
        timeSinceLastUpdate = currentTime - timeSinceLastUpdatePreviousTime;
        
        // keep track of the time interval between draws
        timeSinceLastUpdatePreviousTime = currentTime;
        
        //get fps
        timePassedSinceLastFrame+=timeSinceLastUpdate;
        
        if(timePassedSinceLastFrame>1.0){
            
            float fps=frameCount/timePassedSinceLastFrame;
            
            frameCount=0.0;
            timePassedSinceLastFrame=0.0;
            
            
        }
        
    }
    
}

/// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{

    
    renderInfo.renderPassDescriptor=view.currentRenderPassDescriptor;
    if(renderInfo.renderPassDescriptor==nil) return;
    //set the following states for the pipeline
    renderInfo.renderPassDescriptor.colorAttachments[0].loadAction=MTLLoadActionClear;
    renderInfo.renderPassDescriptor.colorAttachments[0].clearColor=MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderInfo.renderPassDescriptor.colorAttachments[0].storeAction=MTLStoreActionStore;
    
    id<MTLCommandBuffer> mtlCommandBuffer=[renderInfo.commandQueue commandBuffer];
    
    
    U4DEngine::renderGridPass(mtlCommandBuffer);
    U4DEngine::shadowPass(scene, mtlCommandBuffer);
    
    U4DEngine::renderVoxelPass(scene, mtlCommandBuffer);
    U4DEngine::compositePass(mtlCommandBuffer);
    
    [mtlCommandBuffer presentDrawable:view.currentDrawable];
    
    [mtlCommandBuffer commit];
    
    [self update];
    
}

/// Called whenever the view size changes or a relayout occurs (such as changing from landscape to
///   portrait mode)
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
    // Respond to drawable size or orientation changes here

    float aspect = size.width / (float)size.height;
    renderInfo.projectionMatrix = matrix_perspective_right_hand(65.0f * (M_PI / 180.0f), aspect, 0.01f, 1000.0f);
    
}



- (void)dealloc{
    [super dealloc];
    
}


@end
