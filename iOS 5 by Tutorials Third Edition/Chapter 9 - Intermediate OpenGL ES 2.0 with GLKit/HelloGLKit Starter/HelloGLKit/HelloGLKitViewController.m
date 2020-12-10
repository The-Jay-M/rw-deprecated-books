//
//  HelloGLKitViewController.m
//  HelloGLKit
//
//  Created by Main Account on 11/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HelloGLKitViewController.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface HelloGLKitViewController ()

@end

@implementation HelloGLKitViewController {
    float _curRed;
    BOOL _increasing;
    EAGLContext * _context;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLKBaseEffect * _effect;
    float _rotation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _context = [[EAGLContext alloc] 
      initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    [self setupGL];
}

- (void)cleanup {
    [EAGLContext setCurrentContext:_context];
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);

    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
    _effect = nil;
}

- (void)dealloc {
    [self cleanup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
        [self cleanup];
    }
}

- (void)setupGL {
    [EAGLContext setCurrentContext:_context];

    glGenBuffers(1, &_vertexBuffer);  
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), 
      Vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_indexBuffer); 
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), 
      Indices, GL_STATIC_DRAW);
    
    _effect = [[GLKBaseEffect alloc] init];
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(_curRed, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer); glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, 
      GL_FALSE, sizeof(Vertex), 
      (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, 
      GL_FALSE, sizeof(Vertex), 
      (const GLvoid *) offsetof(Vertex, Color));
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), 
      GL_UNSIGNED_BYTE, 0);

}

#pragma mark - GLKViewControllerDelegate

- (void)update {
    if (_increasing) {
        _curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        _curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (_curRed >= 1.0) {
        _curRed = 1.0;
        _increasing = NO;
    }
    if (_curRed <= 0.0) {
        _curRed = 0.0;
        _increasing = YES;
    }
    float aspect =
      fabsf(self.view.bounds.size.width /
        self.view.bounds.size.height);

    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective( 
      GLKMathDegreesToRadians(65.0f), aspect, 4.0f, 10.0f);

    _effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = 
      GLKMatrix4MakeTranslation(0.0f, 0.0f, -6.0f);
    _rotation += 90 * self.timeSinceLastUpdate;
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,
                                       GLKMathDegreesToRadians(_rotation), 0, 0, 1);
    _effect.transform.modelviewMatrix = modelViewMatrix;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
    NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
    NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
    NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
    self.paused = !self.paused;
}

@end
