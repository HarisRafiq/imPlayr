//
//  dance.m
//  HeartConnect
//
//  Created by Haris Rafiq on 3/28/13.
//
//

#import "dance.h"
#import "fft.h"
#import "Utitlities.h"
#include <tgmath.h>
#import "imConstants.h"
#import "AudioPlayer.h"

#import "AudioManager.h"
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI) 
@implementation dance

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
 
 
    _context=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    self = [super initWithFrame:frame context:_context];
    if (self) {

          [EAGLContext setCurrentContext:_context];
  glEnable(GL_DEPTH_TEST);
         glEnable ( GL_BLEND );

        glBlendFunc (GL_SRC_ALPHA , GL_SRC_COLOR);

   
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        prev=[NSDate timeIntervalSinceReferenceDate];
        current_points[0] = 0.0;
        current_points[1] = 0.0;
      
                      for(NSInteger i = 0; i < 360*2; i+=2) {
                          current_points[i+2]   =(cos(DEGREES_TO_RADIANS(i/2)) * 1);
                          current_points[i+3] =(sin(DEGREES_TO_RADIANS(i/2)) * 1);
        }
        current_points[719] = 0.0;
        current_points[720] = 1.0;
    
 
        [self loadShaders];
        
          isBackground=NO;
         [[fft sharedInstance] setIsEnabled:YES];
        [self _setupDisplayLink];
      
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self pause];
        [self startReceveingNotifications];

        
    }
    return self;
}
-(void)startReceveingNotifications{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_BUFFERING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_IDLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PAUSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_PLAYING_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackChanged) name:NOTIFICATION_TRACK_STARTED_PLAYING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForgorund:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorsChanged) name:NOTIFICATION_COLORS_CHANGED object:nil];

}


-(void)removeAllNotifications{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
-(void)colorsChanged{
    [EAGLContext setCurrentContext:_context];

         [[[AudioManager sharedInstance] bgColor]   getRed:&red green:&green blue:&blue alpha:nil];

     
    CGFloat colorBrightness = ((red * 0.3) + (green * 0.59) + (blue * 0.11)) ;
    if (colorBrightness <= 0.7)
    {
 
        glBlendFunc (GL_SRC_ALPHA , GL_SRC_COLOR);
 
        [[[AudioManager sharedInstance] bgColorDark]   getRed:&red green:&green blue:&blue alpha:nil];
        
        
        
        
        
        [[[AudioManager sharedInstance] bgColorDark]   getRed:&red2 green:&green2 blue:&blue2 alpha:nil];
    }
    else
    {

        glBlendFunc ( GL_DST_COLOR, GL_SRC_COLOR);
 
        [[[AudioManager sharedInstance] primaryColor]   getRed:&red green:&green blue:&blue alpha:nil];
        
        
        
        
        
        [[[AudioManager sharedInstance] bgColorDark]   getRed:&red2 green:&green2 blue:&blue2 alpha:nil];
    }
    
    
        
    
}
- (void)playbackChanged
{
    if([[AudioManager sharedInstance ] currentStreamer]!=nil){
        switch ([[[AudioManager sharedInstance ] currentStreamer] status]) {
            case AudioStreamerPlaying:
                
                
                [self resume];
                
                break;
                
            case AudioStreamerPaused:
                
                [self pause];
                
                
                break;
                
            case AudioStreamerIdle:
                
                [self pause];
                
                
                break;
                
            case AudioStreamerFinished:
                
                [self pause];
                
                break;
                
            case AudioStreamerBuffering:
                
                [self pause];
                
                break;
                
            case AudioStreamerError:
                
                [self pause];
                
                break;
        }
    }
    
}

 - (void)_setupDisplayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(_displayLinkCallback:)];
    [_displayLink setPaused:NO];
    [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }

-(void)pause{
[[fft sharedInstance] setIsEnabled:NO];
    glFinish();

    [_displayLink setPaused:YES];

}
-(void)resume
{[[fft sharedInstance] setIsEnabled:YES];
      [_displayLink setPaused:NO];
 }
- (void)_displayLinkCallback:(CADisplayLink *)displayLink
{
       [self setNeedsDisplay];
    
}


- (void)drawRect:(CGRect)rect
{
    @autoreleasepool {
        
    [EAGLContext setCurrentContext:_context];
     magnitudes=[[fft sharedInstance ] fetchfrequency] ;
        
        
        
    CGFloat aspect = fabs(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0f), aspect, 0.1f, 100.0f);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    
    //magnitudes =  (magnitudes-p_magnitudes)  *utime ;
    
         _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        glClearColor(red2,green2, blue2,magnitudes);

      glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
        
    // Use the program object
    glUseProgram (_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
   
    
    
    
    glVertexAttribPointer(a_positon,2, GL_FLOAT, 0, 0, current_points);
    glEnableVertexAttribArray(a_positon);
    
     
         CGFloat  vec[2];
    vec[0]=self.bounds.size.width;
    vec[1]=self.bounds.size.height;
 glUniform2fv (uniforms[ UNIFORM_RESOLUTION],1,  vec);
    glUniform1f (uniforms[ UNIFORM_TIME],  p_magnitudes );
    glUniform1f (uniforms[ UNIFORM_SC],  magnitudes );
     glUniform1f (uniforms[UNIFORM_RED],  red );
        glUniform1f (uniforms[UNIFORM_GREEN],  green );
        glUniform1f (uniforms[UNIFORM_BLUE],  blue );
        
      
    glDrawArrays(GL_TRIANGLE_FAN,0,361);
      p_magnitudes=magnitudes;
        
               }
    }


- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program,a_positon, "a_position");
    
    // Link program.
    if (![self linkProgram:_program]) {
#warning 64BIT: Check formatting arguments
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    uniforms[UNIFORM_RED] = glGetUniformLocation (_program, "u_red" );
     uniforms[UNIFORM_GREEN] = glGetUniformLocation (_program, "u_green" );
     uniforms[UNIFORM_BLUE] = glGetUniformLocation (_program, "u_blue" );
    uniforms[UNIFORM_TIME] = glGetUniformLocation (_program, "u_time" );
    uniforms[UNIFORM_SC] = glGetUniformLocation (_program, "u_sc" );
    uniforms[UNIFORM_RESOLUTION] = glGetUniformLocation (_program, "resolution" );
        // Get the uniform locations
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "mvp_matrix");
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
-(void)cleanUp{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[fft sharedInstance] setIsEnabled:NO];
     [EAGLContext setCurrentContext:_context];
    [_displayLink setPaused:YES];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
 [_displayLink invalidate];
     _displayLink =nil;
glDeleteProgram(_program);
    glDeleteBuffers(1, &textureId);
    glDeleteTextures(1, &textureId);
     
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
     
        [EAGLContext setCurrentContext:nil];
    _context=nil;
     
}
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)handleEnteredForgorund:(id)s{
    [self removeAllNotifications];

    [self playbackChanged];


    [self startReceveingNotifications];
    [self colorsChanged];

}
-(void)handleEnteredBackground:(id)s{
 
    [self pause];
    [self removeAllNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForgorund:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];

    }



@end
