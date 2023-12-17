**How to run :**

In order to run this on WebGL/browser please follow these steps:

● Install and open directory in vscode  ( code ./ )

● Install Extension called “Live Server” (VS code Extension store inside VS Code)

● Now launch live server by clicking here : 

<img width="662" alt="LiveServeer" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/e07dcf51-fe6e-4f88-9f23-c011afa6bf7c">

● A new browser window should open up with webgl rederer running.


**Project Goals:**

Implement physically based rendering using Microfacet BRDF technique in GLSL
Implement Toon shading technique
Implement specular and ambient image based lighting using cubemaps.
Implement user friendly camera controls.

**Project Description:**

Physically based rendering (PBR) is a computer graphics approach that seeks to render images in a way that models the lights and surfaces with optics in the real world. It is often referred to as "Physically Based Lighting" or "Physically Based Shading". Many PBR pipelines aim to achieve photorealism. Our aim with this project is to implement “Cook-Torrance” microfacet BRDF to render PBR materials and use few other techniques like Toon shading and IBL to make things interesting.

**Specular BRDF :**

For the specular term Fr we use the following equation to model our BRDF as per Cook-Torrance method.
<img width="173" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/734f3f6b-404e-4726-8132-aeea4e1843f3">

GLSL variant :

<img width="221" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/5bf384d4-dac5-464d-a38d-b1228790ffe5">

Given our real time constraints we use an approximation for the three terms D, G and F. The following link  has a compiled list of various functions that can be used. 

**Normal Distribution (Specular D) :** 

The GGX distribution is a distribution with a long tailed falloff and short peak in the highlights, with a simple formulation suitable for real-time implementations. It is also a popular model, 
equivalent to the Trowbridge-Reitz distribution, in modern physically based renderers.

<img width="167" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/5bfac507-c35c-49b5-bdf4-ea7349ceac16">




GLSL Variant : 

<img width="177" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/7280db5d-7cc1-4fd3-9ecd-88e308817dc8">



**Geometric Shadowing (Specular G):**

Eric Heitz showed that the smith geometric shadowing function is the correct and exact G term to use.

<img width="296" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/acc40171-ed50-4b67-aa97-27bff0be504d">

GLSL variant :

<img width="178" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/fda08d8a-ba08-4922-b434-09f28f718894">


**Fresnel (Specular F) :**

The Fresnel effect plays an important role in the appearance of physically based materials. This effect models the fact that the amount of light the viewer sees reflected from a surface depends on the viewing angle and also on the index of refraction (IOR) of the material.

<img width="195" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/7ffb0597-7000-469a-8249-8b0177d48fc0">


 At normal incidence (perpendicular to the surface, or 0° angle), the amount of light reflected back is noted f0 and can be derived from the IOR. The amount of light reflected back at grazing angle is noted f90 and approaches 100% for smooth materials.

GLSL Variant : 

<img width="257" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/1165de46-3313-4b58-a419-48d1d5a97878">


**Diffuse BRDF :**

The diffuse term is a Lambertian Function which we simplify into :

<img width="62" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/7110189e-1a7f-4575-be86-fb286963d6ed">



In GLSL :

<img width="240" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/640854ad-67cb-4548-932d-56a3acd86f00">

**Toon Shading :**

“Cel shading or toon shading is a type of non-photorealistic rendering designed to make 3-D computer graphics appear to be flat by using less shading color instead of a shade gradient or tints and shades. A cel shader is often used to mimic the style of a comic book or cartoon and/or give the render a characteristic paper-like texture.” - Wikipedia.

<img width="311" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/b4e8b88e-a37d-474a-b5b3-cbdc45d92ea6">


Our Toon shading function calculates or chops off light into 5 different intensity bands, creating 5 cell shades on the mesh.

<img width="182" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/35b1076d-b415-4a89-b5dd-9f80e373e006">


The image represents the toon shading function used as a diffuse term for rendering. Our implementation will use the Toon function for IBL specular reflections only. This will give light the artistic property of illuminating the world with cell shaded specular term.

**Image Based Lighting (Specular IBL) :**

We use Image Based lighting by sampling a cubemap. This allows us to render environment reflections on our surface. We combine IBL with our specular component of the BRDF to only get environment highlights wherever strong specular reflection occurs. We also sample IBL and use it in our ambient term.
 

<img width="167" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/1b6e973f-d1d5-4f1e-b062-6bc9e3920941">


<img width="267" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/6271246a-fc81-4be2-9177-b71bf495a6e9">

We sample our cubemap using coordinates obtained from the reflection vector of view and normal direction. Combining IBL value with the fresnel term gives us nice environment map reflections only on the grazing angles. We can see clouds being reflected at grazing angles and as we reach the center non grazing angles the environment map mimics diffuse irradiance.

**Combining All Three :** 

<img width="172" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/46e61858-5d1e-486e-b542-16dc50d6f2b7">

<img width="161" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/cc7cb62f-6f82-4cc5-80d8-4688d534ebe2">

On combining our BRDF, Toon shading and IBL we get these results. We have 2 light sources, one is our camera and the other is the environment map. We use our camera direction as our light vector which allows us to directly light the surface from any direction we are looking at. While rotating the camera around the surface we can notice IBL reflections of the cloud and Toon shaded specular highlights.

**Controls :**

Left Mouse Click Drag : Rotate Camera around the object.
Right Mouse Click Drag : Pan Camera in the world.
Mouse Wheel Scroll : Zoom In/Out.
