

varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUvs;


void main() {	
  vUvs = uv;
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  vPosition = (modelMatrix * vec4(position, 1.0)).xyz;
}