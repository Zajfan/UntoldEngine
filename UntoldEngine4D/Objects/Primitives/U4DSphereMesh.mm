//
//  U4DSphereMesh.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 7/13/13.
//  Copyright (c) 2013 Untold Engine Studios. All rights reserved.
//

#include "U4DSphereMesh.h"
#include "U4DMatrix4n.h"

namespace U4DEngine {
    
    U4DSphereMesh::U4DSphereMesh(){
    
    }
    
    
    U4DSphereMesh::~U4DSphereMesh(){
    
    }
    
    
    U4DSphereMesh::U4DSphereMesh(const U4DSphereMesh& value){
        
        radius=value.radius;
        sphere=value.sphere;
        
    };
    
    
    U4DSphereMesh& U4DSphereMesh::operator=(const U4DSphereMesh& value){
        
        radius=value.radius;
        sphere=value.sphere;
        return *this;
        
    };
    
    void U4DSphereMesh::computeBoundingVolume(float uRadius,int uRings, int uSectors){

        radius=uRadius;
        
        sphere.setRadius(radius);
        
        float R=1.0/(uRings-1);
        float S=1.0/(uSectors-1);
        int indexLimit=uRings*uSectors-1;
        
        int r,s;
        
        
        for (r=0; r<uRings; r++) {
            
            for (s=0; s<uSectors; s++) {
                
                float uY=sin(-M_PI_2+M_PI*r*R);
                float uX=cos(2*M_PI * s * S) * sin( M_PI * r * R );
                float uZ=sin(2*M_PI * s * S) * sin( M_PI * r * R );
                
                uX*=uRadius;
                uY*=uRadius;
                uZ*=uRadius;
                
                U4DVector3n vec(uX,uY,uZ);
                
                bodyCoordinates.addVerticesDataToContainer(vec);
                
               
                //push to index
                
                int curRow=r*uSectors;
                int nextRow=(r+1)*uSectors;
                
                //make sure the index data does not call vertices which do not exist.
                if ((curRow+s)<indexLimit && (nextRow+s)<indexLimit) {
                    
                    U4DIndex index(curRow+s,nextRow+s,nextRow+(s+1));
                    bodyCoordinates.addIndexDataToContainer(index);
                    
                    U4DIndex index2(curRow+s,nextRow+s,curRow+(s+1));
                    bodyCoordinates.addIndexDataToContainer(index2);
                    
                }
                
                
            }
        }
        
        loadRenderingInformation();
        
    }
    
    void U4DSphereMesh::setRadius(float uRadius){
        
        radius=uRadius;
    }
    
    float U4DSphereMesh::getRadius(){
        
        return radius;
    }
    
    U4DPoint3n U4DSphereMesh::getMaxBoundaryPoint(){
        
        U4DPoint3n position=getAbsolutePosition().toPoint();
        
        return U4DPoint3n(position.x+radius,position.y+radius,position.z+radius);
    
    }
    
    U4DPoint3n U4DSphereMesh::getMinBoundaryPoint(){
    
        U4DPoint3n position=getAbsolutePosition().toPoint();
        
        return U4DPoint3n(position.x-radius,position.y-radius,position.z-radius);
        
    }
    
    U4DSphere& U4DSphereMesh::getSphere(){
        
        //update the sphere information with bounding sphere
        U4DPoint3n updateCenter=getAbsolutePosition().toPoint();
        
        sphere.setCenter(updateCenter);
        
        return sphere;
    }

}
