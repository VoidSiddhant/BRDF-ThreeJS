
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUvs;

const float PI = 3.14159265359;

uniform float ior;

uniform samplerCube envMap;
uniform sampler2D baseMap;
uniform sampler2D normalMap;
uniform sampler2D metallicMap;
uniform sampler2D roughnessMap;

struct Surface{
vec3  kd;
vec3  ks ;
float specPower;
};

struct SurfacePBR
{
  vec3 kd;
  vec3 ks;
  float metallic; // 0.0 dielectric 1.0 metals
  float roughness;
  float reflectance; // fresnel ref 0.0-1.0
};

Surface surface;
SurfacePBR surfacePbr;

vec3 lin2rgb(vec3 lin)
{
  return pow(lin,vec3(1.0/2.2));
}

vec3 rgb2lin(vec3 rgb)
{
  return pow(rgb,vec3(2.2));
}

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 linearTosRGB(vec3 value ) {
  vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308)));
  
  vec3 v1 = value * 12.92;
  vec3 v2 = pow(value.xyz, vec3(0.41666)) * 1.055 - vec3(0.055);

	return mix(v2,v1,lt);
}


float D_DistributionGGX(float NoH, float a)
{
float a2 = a*a;
float NdotH2 = NoH*NoH;
float nom = a2;
float denom = (NdotH2 * (a2 - 1.0) + 1.0);
denom = PI * denom * denom;
return nom / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
  float alpha = roughness * roughness;
  float k = alpha / 2.0;
  float nom = NdotV;
  float denom = NdotV * (1.0 - k) + k;
  return nom / denom;
}
float G_GeometrySmith(float NoL, float NoV, float k)
{
  float ggx1 = GeometrySchlickGGX(NoV, k);
  float ggx2 = GeometrySchlickGGX(NoL, k);
  return ggx1 * ggx2;
}

vec3 F_Schlick(float cosTheta, vec3 F0)
{
return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

float F_Schlick(float cosTheta, float F0)
{
  return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}



vec3 Toon(vec3 v, vec3 n)
{
  vec3 finalColor = vec3(0.0);
  int divisions =5;
  float edge = max(dot(v,n),0.0);
  float valueIncrements = 1.0 / float(divisions);

  // Check in which division the value of edge belongs
  for(int i=1;i<=divisions;i++)
  {
    if(edge <= (valueIncrements * float(i)) && edge > valueIncrements * float((i-1)))
    {
      finalColor = vec3(valueIncrements * float(i));
      return finalColor;
    }
  }
  return finalColor;
}


vec3 brdfMicrofacet(in vec3 L, in vec3 V, in vec3 N, in float metallic,in float roughness,in vec3 baseColor,in float reflectance)
{

  vec3 H = normalize(V+L);

  float NoV = clamp(dot(N,V),0.0,1.0);
  float NoL = clamp(dot(N,L),0.0,1.0);
  float NoH = clamp(dot(N,H),0.0,1.0);
  float VoH = clamp(dot(V,H),0.0,1.0);

  vec3 f0 = vec3(0.04  * (reflectance * reflectance));
  f0 = mix(f0, baseColor, metallic);
  float D = D_DistributionGGX(NoH,roughness);
  float G = G_GeometrySmith(NoV,NoL,roughness);
  vec3 F = F_Schlick(NoH,f0);

  vec3 spec = (D * G * F) / max(4.0 * NoV * NoL, 0.001);

  vec3 rhoD = vec3(0.0);
  rhoD = vec3(1.0) - F;   // Only transmitted part is used for diffuse
  rhoD *= (1.0 - metallic); // for metallic diffuse = 0
  vec3 diff = (baseColor / PI);

  //Toon Shade
    vec3 toon = Toon(L,N);

  //IBL spec
    vec3 iblCoord = normalize(reflect(-V,N));
    vec3 iblSample = textureCube(envMap, iblCoord).xyz;
    spec += iblSample*toon * F ;
 
  vec3 finalColor =  (diff * rhoD  + spec * toon);
  
  return  finalColor;
}



vec3 Rim(vec3 v, vec3 n,vec3 rimColor,float rimFactor)
{
  vec3 finalColor = vec3(0.0);
  float rim = max(dot(v,n),0.0);

  if(rim < rimFactor)
    finalColor = rimColor * (1.0 - rim) ;

    return finalColor;
}


void main() {

surfacePbr.kd = texture2D(baseMap,vUvs).rgb;
surfacePbr.ks = vec3(1.0);
surfacePbr.metallic = texture2D(metallicMap,vUvs).r;
surfacePbr.roughness = texture2D(roughnessMap,vUvs).r;
surfacePbr.reflectance = 1.0;

  vec3 baseColor = vec3(1.0,1.0,1.0);
  vec3 emissionColor = vec3(1.0,0.0,0.0);
  vec3 lighting = vec3(0.0);
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(cameraPosition - vPosition);
  vec3 finalColor = vec3(0.0);
  

  // Diffuse lighting
  vec3 lightPos = vec3(-4.0,1.0,3.0);
  vec3 lightDirU = cameraPosition - vPosition;
  float dst = length(lightDirU);
  vec3 lightDir = normalize(lightDirU);
  //float attenuation = 1.0 / (1.0 + 0.09 * distance + 0.032 * (distance * distance));
      vec3 iblCoord = normalize(reflect(-viewDir,normal));
    vec3 iblSample = textureCube(envMap, iblCoord).xyz;
  vec3 lightColor = vec3(1.0,1.0,1.0) * 0.8;
  vec3 H = normalize(viewDir + lightDir);
  vec3 Fr = F_Schlick(max(dot(normal,viewDir),0.0),vec3(0.04));

  vec3 ambient = iblSample * 0.1 *(Fr) ;


  //BRDF

  //Implementing Irradiance
  float r = dst;

  vec3 irradiance = vec3(0.0) ;
  float flux = 100.0;
  float radiance = max(dot(lightDir,normal),0.0) * flux / (4.0 * PI * r * r) ;


  vec3 brdf = brdfMicrofacet(lightDir,viewDir,normal,
                            surfacePbr.metallic,surfacePbr.roughness,
                            surfacePbr.kd,surfacePbr.reflectance);
                            
  irradiance =  brdf * vec3(radiance) * lightColor+ ambient;

  finalColor.rgb = linearTosRGB(irradiance );

    gl_FragColor = vec4(finalColor , 1.0);



}