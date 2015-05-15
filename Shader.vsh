attribute vec2 a_position;
varying highp float red;
varying highp float green;
varying highp float blue;
 varying highp float sc;
 varying highp vec2 vPos;
 uniform mat4 mvp_matrix;
uniform float u_sc;
 uniform float u_red;
uniform float u_green;
uniform float u_blue;
void main()
{

    gl_Position  = mvp_matrix*vec4(a_position.xy, -1.0 ,1.0);
        vPos=a_position.xy;
            sc= u_sc;
    red=u_red;
    green=u_green;
    blue=u_blue;
}




