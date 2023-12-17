**How to run :**

In order to run this on WebGL/browser please follow these steps:

● Install and open directory in vscode  ( code ./ )

● Install Extension called “Live Server” (VS code Extension store inside VS Code)

● Now launch live server by clicking here : 

<img width="662" alt="LiveServeer" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/96964ad0-f95e-48dc-9bf1-03fe9a1dddd9">

● A new browser window should open up with webgl rederer running.


**Controls :**

Left Mouse Click Drag : Rotate Camera around the object.

Right Mouse Click Drag : Pan Camera in the world.

Mouse Wheel Scroll : Zoom In/Out.


**Project Goals:**

Implement physically based rendering using Microfacet BRDF technique in GLSL
Implement Toon shading technique
Implement specular and ambient image based lighting using cubemaps.
Implement user friendly camera controls.

**Project Description:**

Physically based rendering (PBR) is a computer graphics approach that seeks to render images in a way that models the lights and surfaces with optics in the real world. It is often referred to as "Physically Based Lighting" or "Physically Based Shading". Many PBR pipelines aim to achieve photorealism. Our aim with this project is to implement “Cook-Torrance” microfacet BRDF to render PBR materials and use few other techniques like Toon shading and IBL to make things interesting.

**Specular BRDF :**

For the specular term Fr we use the following equation to model our BRDF as per Cook-Torrance method.

<img width="167" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/d384d1ad-822e-4ad0-bedf-9279af9d6913">

GLSL variant :

<img width="226" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/89ade4ba-69a0-4bfd-90a2-e7fa5f5d9b76">


Given our real time constraints we use an approximation for the three terms D, G and F. The following link  has a compiled list of various functions that can be used. 

**Normal Distribution (Specular D) :** 

The GGX distribution is a distribution with a long tailed falloff and short peak in the highlights, with a simple formulation suitable for real-time implementations. It is also a popular model, 
equivalent to the Trowbridge-Reitz distribution, in modern physically based renderers.

<img width="183" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/b2a591bf-eef1-4afc-9bbc-8855424cfa43">





GLSL Variant : 

<img width="181" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/f88abc1f-7f57-4282-9d5d-575f731ebfe4">



**Geometric Shadowing (Specular G):**

Eric Heitz showed that the smith geometric shadowing function is the correct and exact G term to use.

<img width="310" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/d106fe2c-276c-473b-bf65-3a0a5e5b9b82">


GLSL variant :

<img width="179" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/64e37305-3bfd-4580-bc9b-8648a4ee3315">



**Fresnel (Specular F) :**

The Fresnel effect plays an important role in the appearance of physically based materials. This effect models the fact that the amount of light the viewer sees reflected from a surface depends on the viewing angle and also on the index of refraction (IOR) of the material.

<img width="212" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/9fcccbc9-b12a-4609-864a-fd83db47470d">


 At normal incidence (perpendicular to the surface, or 0° angle), the amount of light reflected back is noted f0 and can be derived from the IOR. The amount of light reflected back at grazing angle is noted f90 and approaches 100% for smooth materials.

GLSL Variant : 

<img width="257" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/d1fa9606-10ff-47f1-afe4-ea784d60f718">


**Diffuse BRDF :**

The diffuse term is a Lambertian Function which we simplify into :

<img width="61" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/877fbf19-c4c7-4a9f-a9cd-d3c64bb17974">



In GLSL :

<img width="240" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/8bde89ce-ef27-4ec6-9998-e79a519f6e7c">


**Toon Shading :**

“Cel shading or toon shading is a type of non-photorealistic rendering designed to make 3-D computer graphics appear to be flat by using less shading color instead of a shade gradient or tints and shades. A cel shader is often used to mimic the style of a comic book or cartoon and/or give the render a characteristic paper-like texture.” - Wikipedia.

<img width="312" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/44d6634f-53da-453b-b489-484c83ca18c7">


Our Toon shading function calculates or chops off light into 5 different intensity bands, creating 5 cell shades on the mesh.

<img width="181" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/0c9ed9d4-628a-4602-b218-2d228be32802">


The image represents the toon shading function used as a diffuse term for rendering. Our implementation will use the Toon function for IBL specular reflections only. This will give light the artistic property of illuminating the world with cell shaded specular term.

**Image Based Lighting (Specular IBL) :**

We use Image Based lighting by sampling a cubemap. This allows us to render environment reflections on our surface. We combine IBL with our specular component of the BRDF to only get environment highlights wherever strong specular reflection occurs. We also sample IBL and use it in our ambient term.
 

<img width="167" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/d0522a78-1b90-4b2b-838d-c3024100c981">



<img width="263" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/91e44c4d-02b4-43a7-b002-203d69c20a22">


We sample our cubemap using coordinates obtained from the reflection vector of view and normal direction. Combining IBL value with the fresnel term gives us nice environment map reflections only on the grazing angles. We can see clouds being reflected at grazing angles and as we reach the center non grazing angles the environment map mimics diffuse irradiance.

**Combining All Three :** 

<img width="170" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/e38e1df9-4ae0-4351-ac19-b3607efd4bd3">


<img width="161" alt="image" src="https://github.com/VoidSiddhant/BRDF-ThreeJS/assets/25640729/78b082a5-9aa2-4a91-a42a-cdca9f625a1e">


On combining our BRDF, Toon shading and IBL we get these results. We have 2 light sources, one is our camera and the other is the environment map. We use our camera direction as our light vector which allows us to directly light the surface from any direction we are looking at. While rotating the camera around the surface we can notice IBL reflections of the cloud and Toon shaded specular highlights.
