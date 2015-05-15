//
//  dance.h
//  HeartConnect
//
//  Created by Haris Rafiq on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
 @interface dance : GLKView
{
     CADisplayLink *_displayLink;
    NSThread *_displayLinkThread;
       CGFloat magnitudes;
  CGFloat p_magnitudes;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;

     GLfloat current_points[722];
       NSTimeInterval prev;
    GLuint _program;
     enum
    
    {UNIFORM_SC,
     UNIFORM_TIME,
        UNIFORM_RED,
        UNIFORM_BLUE,
        UNIFORM_GREEN,
        UNIFORM_RESOLUTION,
        UNIFORM_CENTER,
        UNIFORM_MODELVIEWPROJECTION_MATRIX,
        NUM_UNIFORMS
    };
    GLint uniforms[NUM_UNIFORMS];
    
    // Attribute index.
    enum
    {
        a_positon,
        
        NUM_ATTRIBUTES
    };
    EAGLContext *_context;
    GLKMatrix4 _modelViewProjectionMatrix;
    GLuint textureId;
     BOOL isColorVisible;
     BOOL isBackground;

}
-(void)colorsChanged;
 - (void)playbackChanged;
  -(void)clear;
 -(void)pause;
-(void)resume;

-(void)handleEnteredBackground:(id)s;
-(void)handleEnteredForgorund:(id)s;
-(void)cleanUp
    ;
 -(CGFloat)red;
-(CGFloat)green;
-(CGFloat)blue;
 
  @end

