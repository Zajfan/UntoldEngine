//
//  U4DEditorPass.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 1/29/21.
//  Copyright © 2021 Untold Engine Studios. All rights reserved.
//

#include "U4DEditorPass.h"
#include "U4DDirector.h"
#include "U4DRenderManager.h"
#include "U4DRenderPipelineInterface.h"
#include "U4DShaderProtocols.h"
#include "U4DEntity.h"
#include "U4DProfilerManager.h"
#include "U4DDebugger.h"
#include "U4DCamera.h"
#include "U4DDirectionalLight.h"
#include "U4DLogger.h"
#include "U4DScriptManager.h"
#include "U4DRenderEntity.h"
#include "U4DRenderPipelineInterface.h"
#include "U4DModelPipeline.h"
#include "U4DResourceLoader.h"
#include "U4DSceneManager.h"
#include "U4DScene.h"
#include "U4DSceneStateManager.h"
#include "U4DSceneEditingState.h"
#include "U4DScenePlayState.h"
#include "U4DEntityFactory.h"

#include "U4DWorld.h"
#include "U4DModel.h"
#include "U4DSceneConfig.h"

#include "U4DSerializer.h"
#include "U4DRay.h"
#include "U4DAABB.h"


#import <TargetConditionals.h> 
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#include "imgui.h"
#include "imgui_impl_metal.h"
#include "ImGuiFileDialog.h"
#include "ImGuizmo.h"
#include "imgui_impl_osx.h"


#endif

namespace U4DEngine{

U4DEditorPass::U4DEditorPass(std::string uPipelineName):U4DRenderPass(uPipelineName){
    
}

U4DEditorPass::~U4DEditorPass(){
    
}

void U4DEditorPass::executePass(id <MTLCommandBuffer> uCommandBuffer, U4DEntity *uRootEntity, U4DRenderPassInterface *uPreviousRenderPass){
    
    static bool ScrollToBottom=true;
    static U4DEntity *activeChild=nullptr;
    static std::string assetSelectedName;
    static std::string assetSelectedTypeName;
    static std::string animationSelectedName;
    static std::string assetSelectedPipelineName;
    static std::string scriptFilePathName;
    static std::string scriptFilePath;
    
    static bool savingScriptFile=false;
    static bool newScriptFile=false;
    
    static bool assetModelIsSelected=false;
    static bool assetAnimationIsSelected=false;
    static bool scriptFilesFound=false;
    static bool scriptLoadedSuccessfully=false;
    static bool lookingForScriptFile=false;
    static bool serialiazeFlag=false;
    static bool deserializeFlag=false;
    
    static std::string shaderFilePathName;
    static std::string shaderFilePath;
    static std::string sceneFilePath;
    static std::string sceneFilePathName;
    static bool shaderFilesFound=false;
    static bool lookingForShaderFile=false;
    
    
    U4DDirector *director=U4DDirector::sharedInstance();
    U4DLogger *logger=U4DLogger::sharedInstance();
    
    U4DSceneManager *sceneManager=U4DSceneManager::sharedInstance();
    U4DScene *scene=sceneManager->getCurrentScene();
    U4DWorld *world=scene->getGameWorld();
    U4DSceneStateManager *sceneStateManager=scene->getSceneStateManager();
    
    U4DEntityFactory *entityFactory=U4DEntityFactory::sharedInstance();
    U4DResourceLoader *resourceLoader=U4DResourceLoader::sharedInstance();
    
    U4DSceneConfig *sceneConfig=U4DSceneConfig::sharedInstance();
    
    ImGuiFileDialog gravityFileDialog;
    ImGuiFileDialog hotReloadFileDialog;
    ImGuiFileDialog serializeFileDialog;
    
    static ImGuizmo::OPERATION mCurrentGizmoOperation(ImGuizmo::TRANSLATE);
    
    U4DVector3n childPosition;
    U4DVector3n childOrientation;

    static float entityPosition[3];
    static float entityOrientation[3];
    
    static bool enableKineticsCheckboxFlag=false;
    static bool enableCollisionCheckboxFlag=false;
    
    float fps=director->getFPS();
    std::string profilerData=sceneManager->profilerData;
    
    MTLRenderPassDescriptor *mtlRenderPassDescriptor = director->getMTLView().currentRenderPassDescriptor;
           mtlRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1);
           mtlRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
           mtlRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    
    
    id <MTLRenderCommandEncoder> editorRenderEncoder =
    [uCommandBuffer renderCommandEncoderWithDescriptor:mtlRenderPassDescriptor];

    if(editorRenderEncoder!=nil){

        [editorRenderEncoder pushDebugGroup:@"Editor Comp Pass"];
        editorRenderEncoder.label = @"Editor Comp Render Pass";

        // Start the Dear ImGui frame
        ImGui_ImplMetal_NewFrame(mtlRenderPassDescriptor);
         
         ImGui_ImplOSX_NewFrame(director->getMTLView());
         
         ImGui::NewFrame();
        
        
        
        {
           ImGui::Begin("Output");
           ImGui::TextUnformatted(logger->logBuffer.begin());
           if (ScrollToBottom)
            ImGui::SetScrollHereY(1.0f);
           //ScrollToBottom = false;
           ImGui::End();

        }
        
        {
            
        ImGui::Begin("Properties");                          // Create a window called "Hello, world!" and append into it.

        ImGui::Text("FPS: %f",fps);               // Display some text (you can use a format strings too)
        ImGui::Text("Profiler:\n %s",profilerData.c_str());
        ImGui::Separator();
        //ImGui::End();
        
            
         //ImGui::Begin("World Properties");
         ImGui::Text("Camera");
         U4DCamera *camera=U4DCamera::sharedInstance();

         U4DVector3n cameraPos=camera->getAbsolutePosition();
         U4DVector3n cameraOrient=camera->getAbsoluteOrientation();

         float pos[3] = {cameraPos.x,cameraPos.y,cameraPos.z};
         float orient[3]={cameraOrient.x,cameraOrient.y,cameraOrient.z};

        if(ImGui::InputFloat3("Pos", pos)){
            sceneConfig->setScenePropsBehavior("camera", "Scene", "position", &pos[0],3);
        }

        if(ImGui::InputFloat3("Orient", orient)){
            sceneConfig->setScenePropsBehavior("camera", "Scene", "orientation", &orient[0],3);
        }
            
         camera->translateTo(pos[0], pos[1], pos[2]);
         camera->rotateTo(orient[0], orient[1], orient[2]);

         ImGui::Separator();
         ImGui::Text("Light");
         U4DDirectionalLight *dirLight=U4DDirectionalLight::sharedInstance();

         U4DVector3n lightPos=dirLight->getAbsolutePosition();
         U4DVector3n lightOrient=dirLight->getAbsoluteOrientation();
         U4DVector3n diffuseColor=dirLight->getDiffuseColor();

         float lightpos[3] = {lightPos.x,lightPos.y,lightPos.z};
         float lightorient[3]={lightOrient.x,lightOrient.y,lightOrient.z};
         float color[3] = {diffuseColor.x,diffuseColor.y,diffuseColor.z};

        if(ImGui::InputFloat3("Light Pos", lightpos)){
            sceneConfig->setScenePropsBehavior("light", "Scene", "position", &lightpos[0],3);
        }
        
        if(ImGui::InputFloat3("Light Orient", lightorient)){
            sceneConfig->setScenePropsBehavior("light", "Scene", "orientation", &lightorient[0],3);
        }
        
        if(ImGui::InputFloat3("Color", color)){
            sceneConfig->setScenePropsBehavior("light", "Scene", "color", &color[0],3);
        }

         diffuseColor=U4DVector3n(color[0],color[1],color[2]);

         dirLight->translateTo(lightpos[0], lightpos[1], lightpos[2]);
         dirLight->rotateTo(lightorient[0], lightorient[1], lightorient[2]);
         dirLight->setDiffuseColor(diffuseColor);

        
         ImGui::End();
            
        }
    
        {
            
            
        ImGui::Begin("Control");
        
        ImGui::SameLine();
            
        if (ImGui::Button("Edit")) {
            
            //reset the active child
            activeChild=nullptr;
            
            if(sceneStateManager->getCurrentState()==U4DScenePlayState::sharedInstance()){
                
                sceneConfig->removePropertyFromAllEntities();
                scene->getSceneStateManager()->changeState(U4DSceneEditingState::sharedInstance());
            
            }
            
        }
            
        ImGui::SameLine();
        //save config
        
            
        if (ImGui::Button("Play")) {
            
            //reset the active child
            activeChild=nullptr;
            
            U4DSerializer *serializer=U4DSerializer::sharedInstance();
            
                
            if(sceneStateManager->getCurrentState()==U4DSceneEditingState::sharedInstance() && serializer->serialize(sceneFilePathName)==true){
                //change scene state to edit mode
                
                scene->getSceneStateManager()->changeState(U4DScenePlayState::sharedInstance());
                
                sceneConfig->applyPropertyToAllEntities();
                
            }else if(sceneStateManager->getCurrentState()==U4DScenePlayState::sharedInstance()){
                
                scene->setPauseScene(false);
                logger->log("Game was resumed");
                
            }
        
        }
        
        
        ImGui::SameLine();
        if (ImGui::Button("Pause") && sceneStateManager->getCurrentState()==U4DScenePlayState::sharedInstance()) {
            
            //change scene state to pause
            scene->setPauseScene(true);
            
            logger->log("Game was paused");
            
        }
        
            ImGui::End();
        }
        
        {
            ImGui::Begin("Game Configs");
            
            U4DSceneManager *sceneManager=U4DSceneManager::sharedInstance();
            U4DEntityFactory *entityFactory=U4DEntityFactory::sharedInstance();
            U4DScene *scene=sceneManager->getCurrentScene();
            
            
            if (scene->getPauseScene() ) {
                
                if(ImGui::Button("Add Model")){
                
                    if (scene!=nullptr && assetModelIsSelected) {
                        
                        //search the scenegraph for current names
                        
                        U4DEntity *child=scene->getGameWorld()->next;
                        
                        int count=0;
                        
                        while (child!=nullptr) {
                            
                            //strip all characters up to the period
                            if(child->getEntityType()==U4DEngine::MODEL){
                                
                                std::string s=child->getName();
                                int n=(int)s.length();
                                int m=(int)assetSelectedName.length();
                                int stringLengthDifference=std::abs(n-m);

                                if(n<=stringLengthDifference) stringLengthDifference=n;
                                //trunk down the name
                                
                                s.erase(s.end()-stringLengthDifference, s.end());

                                if (s.compare(assetSelectedName)==0) {

                                    count++;

                                }
                            }
                            
                            child=child->next;
                            
                        }
                        
                        std::string modelNameBuffer=assetSelectedName+"."+std::to_string(count);
                        
                        //entityFactory->createModelInstance(assetSelectedName,modelNameBuffer, assetSelectedTypeName,assetSelectedPipelineName);
                        
                        entityFactory->createModelInstance(assetSelectedName,modelNameBuffer, "U4DModel","modelpipeline");
                        
                        sceneConfig->addNewEntity(modelNameBuffer,assetSelectedName);
                        
                        U4DEntity *newChild=scene->getGameWorld()->searchChild(modelNameBuffer);
                        
                        if(newChild!=nullptr){
                         
                            childPosition=newChild->getAbsolutePosition();
                            childOrientation=newChild->getAbsoluteOrientation();

                            entityPosition[0] = childPosition.x;
                            entityPosition[1] = childPosition.y;
                            entityPosition[2] = childPosition.z;

                            entityOrientation[0]=childOrientation.x;
                            entityOrientation[1]=childOrientation.y;
                            entityOrientation[2]=childOrientation.z;
                            
                            sceneConfig->setEntityBehavior(newChild->getName().c_str(), "Space", "position", &entityPosition[0],3);
                            
                            sceneConfig->setEntityBehavior(newChild->getName().c_str(), "Space", "orientation", &entityOrientation[0],3);
                            
                        }
                        
                        enableKineticsCheckboxFlag=false;
                        enableCollisionCheckboxFlag=false;
                        assetModelIsSelected=false;
                        activeChild=nullptr;
                        
                    }
                    
                }
                
                ImGui::SameLine();
                if(ImGui::Button("Add Anim")){
                    if(assetAnimationIsSelected==true && activeChild!=nullptr){
                    
                        sceneConfig->addAnimationElement(activeChild->getName().c_str(),animationSelectedName.c_str());
                        assetAnimationIsSelected=false;
                    }
                }
            
                
            
            }
//            //COMMENT OUT FOR NOW-SCRIPT FINE_TUNE SECTION
//            if (ImGui::Button("Script")){
//                lookingForScriptFile=true;
//
//                gravityFileDialog.Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".gravity", ".");
//            }
//
//            if(lookingForScriptFile){
//                // display
//                if (gravityFileDialog.Instance()->Display("ChooseFileDlgKey"))
//                {
//                  // action if OK
//                  if (gravityFileDialog.Instance()->IsOk())
//                  {
//                    scriptFilePathName = gravityFileDialog.Instance()->GetFilePathName();
//                    scriptFilePath = gravityFileDialog.Instance()->GetCurrentPath();
//                    // action
//                    scriptFilesFound=true;
//                  }else{
//                    //scriptFilesFound=false;
//                  }
//
//                  // close
//                  gravityFileDialog.Instance()->Close();
//
//                }
//
//              if (scriptFilesFound) {
//
//                  ImGui::Text("Script %s", scriptFilePathName.c_str());
//
//                  U4DScriptManager *scriptManager=U4DScriptManager::sharedInstance();
//
//                  if(ImGui::Button("Load Script")){
//
//                      if(scriptManager->loadScript(scriptFilePathName)){
//
//                          logger->log("Script was loaded.");
//
//                          //call the init function in the script
//                          //scriptManager->loadGameConfigs();
//                          scriptManager->initClosure();
//                          scriptManager->loadGameConfigs();
//                          scriptLoadedSuccessfully=true;
//                      }else{
//                          scriptLoadedSuccessfully=false;
//                      }
//
//                      //lookingForScriptFile=false;
//                  }
//
//              }
//            }
//        //END SCRIPT FINE_TUNE
            
        ImGui::End();
    }
        
        if (sceneStateManager->getCurrentState()==U4DSceneEditingState::sharedInstance()) {
            
            //panning, zooming and rotation of editor camera
            {
                U4DCamera *camera=U4DCamera::sharedInstance();
                float mouseWheelH=ImGui::GetIO().MouseWheelH;
                float mouseWheelV=ImGui::GetIO().MouseWheel;
            
                
                if(mouseWheelH!=0.0 || mouseWheelV!=0.0){
                    
                    //pan camera - Shift Key + scroll wheel
                    if(ImGui::GetIO().KeyShift==true){
                        
                        U4DVector3n dir(mouseWheelH,mouseWheelV,0.0);
                        U4DMatrix3n m=camera->getAbsoluteMatrixOrientation();
                        
                        dir=m*dir;
                        
                        camera->translateBy(dir);
                    
                    //zoom camera - Control Key + scroll wheel
                    }else if(ImGui::GetIO().KeyCtrl==true && mouseWheelH==0.0){
                        
                        U4DVector3n upVector(0.0,1.0,0.0);
                        U4DVector3n zDir(0.0,0.0,1.0);
                        
                        U4DMatrix3n m=camera->getAbsoluteMatrixOrientation();
                        
                        zDir=m*zDir;
                        
                        U4DVector3n cameraView=camera->getViewInDirection();
                        cameraView.normalize();
                        
                        U4DVector3n xDir=cameraView.cross(upVector);
                        
                        float angle=zDir.angle(cameraView);
                        
                        if (zDir.dot(xDir)<0.0) {
                            angle*=-1.0;
                        }
                        
                        U4DVector3n n=zDir.rotateVectorAboutAngleAndAxis(angle, upVector);
                        
                        if (mouseWheelV<0.0) {
                            n=n*-1.0;
                        }
                        
                        camera->translateBy(n);
                        
                    //rotate camera
                    }else{
                        
                        //rotate camera
                        //Get the delta movement of the mouse
                        U4DEngine::U4DVector2n delta(mouseWheelH,mouseWheelV);
                        
                        //the y delta should be flipped
                        delta.y*=-1.0;
                        
                        //The following snippet will determine which way to rotate the model depending on the motion of the mouse
                        float deltaMagnitude=delta.magnitude();
                        
                        delta.normalize();
                        
                        U4DEngine::U4DVector3n axis;
                        U4DEngine::U4DVector3n mouseDirection(delta.x,delta.y,0.0);
                        U4DEngine::U4DVector3n upVector(0.0,1.0,0.0);
                        U4DEngine::U4DVector3n xVector(1.0,0.0,0.0);
                        
                        //get the dot product
                        float upDot, xDot;
                        upDot=mouseDirection.dot(upVector);
                        xDot=mouseDirection.dot(xVector);
                        
                        U4DEngine::U4DVector3n v=camera->getViewInDirection();
                        v.normalize();
                        
                        if(mouseDirection.magnitude()>0){
                            //if direction is closest to upvector
                            if(std::abs(upDot)>=std::abs(xDot)){
                                //rotate about x axis
                                if(upDot>0.0){
                                    axis=v.cross(upVector);

                                }else{
                                    axis=v.cross(upVector)*-1.0;

                                }
                            }else{
                                //rotate about y axis
                                if(xDot>0.0){
                                    axis=upVector;
                                }else{
                                    axis=upVector*-1.0;
                                }
                            }
                            
                            //Once we know the angle and axis of rotation, we can rotate the camera using interpolation as shown below
                            
                            float angle=deltaMagnitude;

                            camera->rotateBy(angle,axis);
                        
                        }
                        
                        
                    }
                    
                    U4DVector3n cameraPos=camera->getAbsolutePosition();
                    U4DVector3n cameraOrient=camera->getAbsoluteOrientation();

                    float pos[3] = {cameraPos.x,cameraPos.y,cameraPos.z};
                    float orient[3]={cameraOrient.x,cameraOrient.y,cameraOrient.z};
                    
                   sceneConfig->setScenePropsBehavior("camera", "Scene", "position", &pos[0],3);

                   sceneConfig->setScenePropsBehavior("camera", "Scene", "orientation", &orient[0],3);
                    
                }
                
                
                
            }
            
            //mouse ray casting to enable the Guizmo
            {
            
            CONTROLLERMESSAGE controllerMessage=scene->getGameWorld()->controllerInputMessage;
            static bool rightMouseActive=false;
            
            if (controllerMessage.inputElementAction==U4DEngine::mouseRightButtonPressed) {
                rightMouseActive=true;
            }else if(controllerMessage.inputElementAction==U4DEngine::mouseRightButtonReleased && rightMouseActive){
                
                U4DDirector *director=U4DDirector::sharedInstance();
                
                //1. Normalize device coordinates range [-1:1,-1:1,-1:1]
                U4DVector3n ray_nds(controllerMessage.inputPosition.x,controllerMessage.inputPosition.y,1.0);
                
                //2. 4D homogeneous clip coordinates range [-1:1,-1:1,-1:1,-1:1]
                U4DVector4n ray_clip(ray_nds.x,ray_nds.y,-1.0,1.0);

                //3. 4D Eye (camera) coordinates range [-x:x,-y:y,-z:z,-w:w]
                U4DMatrix4n perspectiveProjection=director->getPerspectiveSpace();
                
                U4DVector4n ray_eye=perspectiveProjection.inverse()*ray_clip;
                
                ray_eye.z=1.0;
                ray_eye.w=0.0;

                //4. 4D world coordinates range[-x:x,-y:y,-z:z,-w:w]
                U4DCamera *camera=U4DCamera::sharedInstance();
                
                U4DEngine::U4DMatrix4n viewSpace=camera->getLocalSpace().transformDualQuaternionToMatrix4n();
                
                U4DVector4n ray_wor=viewSpace*ray_eye;
                
                U4DPoint3n rayOrigin=camera->getAbsolutePosition().toPoint();
                U4DVector3n rayDirection(ray_wor.x,ray_wor.y,ray_wor.z);
                rayDirection.normalize();

                U4DRay ray(rayOrigin,rayDirection);
                
                U4DPoint3n intPoint;
                float intTime;
                float closestTime=FLT_MAX;

                //traverse the scenegraph
               
                U4DEntity *child=world->next;

                while (child!=nullptr) {

                    if (child->getEntityType()==U4DEngine::MODEL && child->parent==world) {

                        U4DModel *model=dynamic_cast<U4DModel*>(child);
                        //create the aabb for entity in the scenegraph
                        U4DVector3n dimensions=model->getModelDimensions()/2.0;
                        U4DPoint3n position=model->getAbsolutePosition().toPoint();

                        U4DMatrix3n m=model->getAbsoluteMatrixOrientation();

                        dimensions=m*dimensions;
                        
                        U4DPoint3n maxPoint(position.x+dimensions.x,position.y+dimensions.y,position.z+dimensions.z);
                        U4DPoint3n minPoint(position.x-dimensions.x,position.y-dimensions.y,position.z-dimensions.z);
                        
                        U4DAABB aabb(maxPoint,minPoint);
                        

                        if (ray.intersectAABB(aabb, intPoint, intTime)) {
                            
                            if (intTime<closestTime) {
                                
                                closestTime=intTime;
                                
                                activeChild=model;
                                
                                //Read the behaviors set for the entity
                                enableKineticsCheckboxFlag=sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Kinetics");
                                enableCollisionCheckboxFlag=sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Collision");
                            }

                        }

                    }

                    child=child->next;

                }
                
                if (activeChild!=nullptr) {
                    
                    mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
                    
                    childPosition=activeChild->getAbsolutePosition();
                    childOrientation=activeChild->getAbsoluteOrientation();

                    entityPosition[0] = childPosition.x;
                    entityPosition[1] = childPosition.y;
                    entityPosition[2] = childPosition.z;

                    entityOrientation[0]=childOrientation.x;
                    entityOrientation[1]=childOrientation.y;
                    entityOrientation[2]=childOrientation.z;
                    
                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "position", &entityPosition[0],3);
                    
                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "orientation", &entityOrientation[0],3);
                    
                }
                
                
                rightMouseActive=false;
            }
                
            }
            
            {
                ImGui::Begin("Assets");
                
            if (ImGui::TreeNode("Models"))
            {

                U4DResourceLoader *resourceLoader=U4DResourceLoader::sharedInstance();
                
                
                for (const auto &n : resourceLoader->getModelContainer()) {
                    
                    
                    char buf[32];
                    sprintf(buf, "%s", n.name.c_str());
                   
                    if (ImGui::Selectable(buf,n.name.compare(assetSelectedName)==0) ) {
                        assetSelectedName=n.name;
                        assetModelIsSelected=true;
                     }
                        
                }
                
                
                
                ImGui::TreePop();

            }
                
                if (ImGui::TreeNode("Animations"))
                {
                        
                        U4DResourceLoader *resourceLoader=U4DResourceLoader::sharedInstance();
                        
                        for (const auto &n : resourceLoader->getAnimationsNamesLoaded()) {
                            
                            char buf[32];
                            sprintf(buf, "%s", n.c_str());
                                
                            if (ImGui::Selectable(buf,n.compare(animationSelectedName)==0)) {
                                animationSelectedName=n;
                                assetAnimationIsSelected=true;
                             }

                    }
                    
                    ImGui::TreePop();

                }
                
            ImGui::End();

           }
            
            

            
            {
                
             ImGui::Begin("Scene Property");
             if (ImGui::TreeNode("Scenegraph"))
             {
                 
                 U4DEntity *child=world->next;
                 
                 while (child!=nullptr) {

                     if (child->getEntityType()==U4DEngine::MODEL ) {

                         char buf[32];

                         sprintf(buf, "%s", child->getName().c_str());

                         if (ImGui::Selectable(buf,activeChild==child) && child->parent==world) {
                             
                             mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
                             
                             activeChild=child;
                             
                             childPosition=activeChild->getAbsolutePosition();
                             childOrientation=activeChild->getAbsoluteOrientation();

                             entityPosition[0] = childPosition.x;
                             entityPosition[1] = childPosition.y;
                             entityPosition[2] = childPosition.z;
                             
                             entityOrientation[0]=childOrientation.x;
                             entityOrientation[1]=childOrientation.y;
                             entityOrientation[2]=childOrientation.z;
                             
                             sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "position", &entityPosition[0],3);
                             
                             sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "orientation", &entityOrientation[0],3);
                             
                             break;
                         }

                     }

                     child=child->next;

                 }

                 ImGui::TreePop();

             }
                
                
            {
                 ImGui::Begin("Menu");

                 if (ImGui::Button("Save")) {

                     serialiazeFlag=true;
                     serializeFileDialog.Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".xml", ".");

                 }
                 ImGui::SameLine();
                 if (ImGui::Button("Open")) {

                     deserializeFlag=true;
                     serializeFileDialog.Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".xml", ".");

                 }

                 if (serialiazeFlag || deserializeFlag) {

                     if (serializeFileDialog.Instance()->Display("ChooseFileDlgKey"))
                        {
                            // action if OK
                            if (serializeFileDialog.Instance()->IsOk())
                            {

                            sceneFilePathName = serializeFileDialog.Instance()->GetFilePathName();
                                logger->log("%s",sceneFilePathName.c_str());


                                if (serialiazeFlag) {
                                    //serialize
                                    U4DSerializer *serializer=U4DSerializer::sharedInstance();

                                    serializer->serialize(sceneFilePathName);

                                }else if(deserializeFlag){
                                    //deserialize
                                    U4DSerializer *serializer=U4DSerializer::sharedInstance();

                                    serializer->deserialize(sceneFilePathName);
                                }

                            }else{

                            }

                            serialiazeFlag=false;
                            deserializeFlag=false;

                            // close
                            serializeFileDialog.Instance()->Close();

                        }

                     }
                     ImGui::End();
                 }
                
                {
                    ImGui::Begin("Entity Properties");

                    if (activeChild!=nullptr) {

                        ImGui::Text("Entity Name: %s",activeChild->getName().c_str());

                        ImGui::Text("Transform");
                        
                        if(ImGui::InputFloat3("Position", entityPosition)){
                            sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "position", &entityPosition[0],3);
                        }
                        
                        if(ImGui::InputFloat3("Orientation", entityOrientation)){
                            sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "orientation", &entityOrientation[0],3);
                        }
                        
                        activeChild->translateTo(entityPosition[0], entityPosition[1], entityPosition[2]);
                        activeChild->rotateTo(entityOrientation[0], entityOrientation[1], entityOrientation[2]);

                        //Guizmo
                        {
                            
                            if (ImGui::IsKeyPressed(84)) // t is pressed=translate
                               mCurrentGizmoOperation = ImGuizmo::TRANSLATE;
                            if (ImGui::IsKeyPressed(82)) //r is pressed= rotate
                               mCurrentGizmoOperation = ImGuizmo::ROTATE;
                              
                    
                             static ImGuizmo::MODE mCurrentGizmoMode(ImGuizmo::WORLD);
                                 
                             U4DDirector *director=U4DDirector::sharedInstance();
                             U4DCamera *camera=U4DCamera::sharedInstance();
                              
                              ImGuizmo::SetRect(0.0, 0.0, director->getDisplayWidth(),director->getDisplayHeight());
                              
                              ImGuizmo::BeginFrame();
                            
                              U4DMatrix4n cameraSpace=camera->getAbsoluteSpace().transformDualQuaternionToMatrix4n();
                              cameraSpace.invert();
                            
                              U4DMatrix4n perspectiveProjection=director->getPerspectiveSpace();
                              
                              U4DMatrix4n activeChildSpace=activeChild->getAbsoluteSpace().transformDualQuaternionToMatrix4n();
                              
                              ImGuizmo::Manipulate(cameraSpace.matrixData, perspectiveProjection.matrixData, mCurrentGizmoOperation, mCurrentGizmoMode, activeChildSpace.matrixData, NULL, NULL);
                              
                              
                              float matrixTranslation[3], matrixRotation[3], matrixScale[3];
                              ImGuizmo::DecomposeMatrixToComponents(activeChildSpace.matrixData, matrixTranslation, matrixRotation, matrixScale);
                              
                            if (ImGuizmo::IsUsing()) {
                                
                                entityPosition[0] = matrixTranslation[0];
                                entityPosition[1] = matrixTranslation[1];
                                entityPosition[2] = matrixTranslation[2];

                                entityOrientation[0]=matrixRotation[0];
                                entityOrientation[1]=matrixRotation[1];
                                entityOrientation[2]=matrixRotation[2];
                                
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "position", &entityPosition[0],3);
                                
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Space", "orientation", &entityOrientation[0],3);
                                
                                activeChild->rotateTo(matrixRotation[0], matrixRotation[1], matrixRotation[2]);
                                activeChild->translateTo(matrixTranslation[0], matrixTranslation[1], matrixTranslation[2]);
                            }
                             
                        }
                        
                        ImGui::Separator();
                        
                        {
                            ImGui::Text("Physics Properties");
                            
                            if(ImGui::Checkbox("Enable Kinetics", &enableKineticsCheckboxFlag)){
                                
                                //run enableKineticsCheckboxFlag(activeChild,enableKineticsCheckboxFlag)
                                //write xml
                                if(enableKineticsCheckboxFlag){
                                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Kinetics",enableKineticsCheckboxFlag);
                                    
                                    
                                    
                                    
                                }else{
                                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Kinetics",enableKineticsCheckboxFlag);
                                }
                                
                            }
                            
                            ImGui::Separator();
                            float gravityData[3];
                            
                            //show gravity values
                            
                            sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Kinetics", "gravity", &gravityData[0],3);
                            
                            
                            if(ImGui::InputFloat3("Gravity", gravityData)){
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Kinetics","gravity",&gravityData[0],3);
                            }
                            
                            //show mass values
                            float mass;
                            
                            sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Kinetics", "mass", &mass);
                            if(ImGui::InputFloat("mass", &mass, 0.1f, 1.0f, "%.1f")){
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Kinetics", "mass", mass);
                            }
                            
                            ImGui::Separator();
                            
                            if(ImGui::Checkbox("Enable Collision", &enableCollisionCheckboxFlag)){
                                
                                if(enableCollisionCheckboxFlag){
                                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision",enableCollisionCheckboxFlag);
                                }else{
                                    sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision",enableCollisionCheckboxFlag);
                                }
                            }
                            
                        }

                        ImGui::Separator();
                        //show coeff Restitution values
                        static float coefRestitutionData = 0.8f;
                        
                        sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Collision", "coefRestitution", &coefRestitutionData);
                        if(ImGui::InputFloat("Bounciness", &coefRestitutionData, 0.1f, 1.0f, "%.1f")){
                            sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Collision", "coefRestitution", coefRestitutionData);
                        }
                        
                        //isPlatform
                        bool isPlatform;
                        
                        sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Collision", "platform", isPlatform);
                        
                        if(ImGui::Checkbox("Platform", &isPlatform)){
                            
                            if(isPlatform){
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision","platform",isPlatform);
                                
                            }else{
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision","platform",isPlatform);
                            }
                            
                        }
                        
                        char tag[10] ={};
                        
                        sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Collision", "tag", tag,IM_ARRAYSIZE(tag));
                        
                        if(ImGui::InputTextWithHint("collision tag", "input tag here", tag, IM_ARRAYSIZE(tag))){
                            sceneConfig->setEntityBehavior(activeChild->getName().c_str(), "Collision", "tag", tag,IM_ARRAYSIZE(tag));
                        }
                        
                        //isSensor
                        static bool isSensor;
                        
                        sceneConfig->getEntityBehavior(activeChild->getName().c_str(), "Collision", "sensor", isSensor);
                        
                        if(ImGui::Checkbox("Sensor", &isSensor)){
                            
                            if(isSensor){
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision","sensor",isSensor);
                                
                            }else{
                                sceneConfig->setEntityBehavior(activeChild->getName().c_str(),"Collision","sensor",isSensor);
                            }
                            
                        }
                        

                        ImGui::Separator();
                        
                        
                        
                        //read all animations
                        std::vector<std::string> animationsAdded=sceneConfig->getAllAnimationNames(activeChild->getName().c_str());
                        
                        static std::string animationLinkedName;
                        static bool animationLinkedSelected=false;
                        
                        //show tree
                        
                        if (ImGui::TreeNode("Animations"))
                        {
                            
                            for (const auto &n : animationsAdded) {

                                char buf[32];
                                sprintf(buf, "%s", n.c_str());
                                    
                                if (ImGui::Selectable(buf,n.compare(animationLinkedName)==0)) {
                                    animationLinkedName=n;
                                    animationLinkedSelected=true;
                                 }
                                    
                            }
                            
                            ImGui::TreePop();

                        }
                        
                        if(animationLinkedSelected){
                            if(ImGui::Button("Remove Animation")){
                                sceneConfig->removeAnimationElement(activeChild->getName().c_str(),animationLinkedName.c_str());
                            }
                        }
                        
//                        ImGui::Text("Render Entity");
//                        U4DRenderEntity *renderEntity=activeChild->getRenderEntity();
//                        U4DRenderPipelineInterface *pipeline=renderEntity->getPipeline(U4DEngine::finalPass);
//                        ImGui::Text("Final-Pass Pipeline Name %s",pipeline->getName().c_str());
//                        ImGui::Text("Vertex Name %s",pipeline->getVertexShaderName().c_str());
//                        ImGui::Text("Fragment Name %s",pipeline->getFragmentShaderName().c_str());
//
//                        ImGui::Separator();
//
//                        if (scene->getPauseScene()) {
//
//                            ImGui::Text("Hot-Reload Shader");
//
//                            // open Dialog Simple
//                            if (ImGui::Button("Open Shader")){
//                                lookingForShaderFile=true;
//                                hotReloadFileDialog.Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".metal", ".");
//                            }
//
//                            if (lookingForShaderFile) {
//
//                                // display
//                                if (hotReloadFileDialog.Instance()->Display("ChooseFileDlgKey"))
//                                {
//                                  // action if OK
//                                  if (hotReloadFileDialog.Instance()->IsOk())
//                                  {
//                                    shaderFilePathName = hotReloadFileDialog.Instance()->GetFilePathName();
//                                    shaderFilePath = hotReloadFileDialog.Instance()->GetCurrentPath();
//                                    // action
//                                    shaderFilesFound=true;
//                                  }else{
//                                    shaderFilesFound=false;
//                                  }
//
//                                  // close
//
//                                   hotReloadFileDialog.Instance()->Close();
//                                }
//
//                              if (shaderFilesFound) {
//
//                                  ImGui::Text("Shader %s", shaderFilePathName.c_str());
//
//                                  if(ImGui::Button("Hot-Reload")){
//
//                                      pipeline->hotReloadShaders(shaderFilePathName.c_str(), pipeline->getVertexShaderName().c_str(), pipeline->getFragmentShaderName().c_str());
//                                      lookingForShaderFile=false;
//                                  }
//
//                              }
//
//                            }
//
//                        }
                        
                        ImGui::Separator();
                        
                        if(ImGui::Button("Remove Entity")){
                            
                            U4DEntity *parent=activeChild->getParent();
                            
                            //leaving it here until the issue #359 is fixed.
                            //activeChild->removeAndDeleteAllChildren();
                            
                            parent->removeChild(activeChild);
                            
                            U4DModel *model=dynamic_cast<U4DModel*>(activeChild);
                            
                            delete model;
                            
                            activeChild=nullptr;
                            
                        }
                        
                        ImGui::Separator();
                        
                        static char modelNameBuffer[64] = "";
                        //std::strcpy(modelNameBuffer, &activeChild->getName()[0]);
                        ImGui::InputText("New Model Name", modelNameBuffer, 64);
                        
                        if(ImGui::Button("Rename Model")){
                            
                            std::string previousModelName=activeChild->getName();
                            activeChild->setName(modelNameBuffer);
                            
                            //clear the char array
                            memset(modelNameBuffer, 0, sizeof(modelNameBuffer));
                            
                        }
                    }

                    ImGui::End();

                }

             ImGui::End();

            }
                  
        }
        
        
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, uCommandBuffer, editorRenderEncoder);

        [editorRenderEncoder popDebugGroup];
        //end encoding
        [editorRenderEncoder endEncoding];

    }
    
}


}
