#ifdef GL_ES
precision mediump float;
#endif

uniform mediump mat4 ModelViewProjectionMatrix;
 
attribute mediump vec3 Position;
 
void main( void ) 
{
    gl_Position = ModelViewProjectionMatrix * vec4(Position, 1.0);
} 