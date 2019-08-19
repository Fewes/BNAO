# BNAO
![alt text](https://raw.githubusercontent.com/Fewes/BNAO/master/Example.png)
![alt text](https://raw.githubusercontent.com/Fewes/BNAO/master/UI.png)

# Features
* Supports baking ambient occlusion or bent normal maps from low-poly geometry, right in the editor.
* Bakes textures for selected objects and automatically groups meshes into same output textures based on material usage (with option for overriding grouping).
* Can bake tangent, object and world-space bent normal maps.
* Automatically uses normal maps present in original materials for a higher quality result.
* Can bake objects with or without occlusion from other scene objects.

# What are bent normals?
![alt text](https://raw.githubusercontent.com/Fewes/BNAO/master/BentNormalsExample.gif)  
Bent normal maps store the direction of least occlusion in a texture. They can be used to occlude cubemap reflections based on the view direction in a much more realistic way than just multiplying with an ambient occlusion term. They can also be used to get an ambient color value which more closesly resembles a ray traced result.  
For details on how to implement these effects in your own shader, see the file "Shader Implementation Example.txt".

# Can I specify a max distance for the ambient occlusion?
No. The baker uses depth textures (similar to shadow mapping) to determine ray intersections, which makes it impossible to bias the result based on distance.
