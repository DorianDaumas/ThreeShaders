uniform float time;
uniform float progress;
uniform sampler2D texture2;
uniform sampler2D image;
uniform sampler2D displacement;
uniform vec4 resolution;
uniform vec3 mouse;
varying vec3 vPosition;
varying vec2 vUv;


void main() {

    vec4 displace = texture2D(displacement,vUv.yx);

    vec2 displaceUv = vec2(vUv.x,vUv.y);
        
    displaceUv.x = mix(vUv.x,displace.b - 0.2 * time * 2. , progress);
    displaceUv.y = mix(vUv.y,displace.b - 0.2 * time * 2. , progress);

    vec4 color = texture2D(image,displaceUv);

    // color.r = texture2D(image,displaceUv + vec2(0.,0.005)*progress).r;
    // color.b = texture2D(image,displaceUv + vec2(0.,0.002)*progress).b;
    // color.g = texture2D(image,displaceUv + vec2(0.,0.003)*progress).g;
    
    // float dist = length(vPosition - mouse);
    
    gl_FragColor = color;
}