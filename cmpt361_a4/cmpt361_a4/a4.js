import { Mat4 } from './math.js';
import { Parser } from './parser.js';
import { Scene } from './scene.js';
import { Renderer } from './renderer.js';
import { TriangleMesh } from './trianglemesh.js';
// DO NOT CHANGE ANYTHING ABOVE HERE

////////////////////////////////////////////////////////////////////////////////
// TODO: Implement createCube, createSphere, computeTransformation, and shaders
////////////////////////////////////////////////////////////////////////////////

// Example two triangle quad
const quad = {
  positions: [-1, -1, -1, 1, -1, -1, 1, 1, -1, -1, -1, -1, 1,  1, -1, -1,  1, -1],
  normals: [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
  uvCoords: [0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1]
}

TriangleMesh.prototype.createCube = function() {
  this.positions = [
    0, 0, 0,  1, 0, 0,  1, 1, 0,  0, 1, 0,
    0, 0, 1,  1, 0, 1,  1, 1, 1,  0, 1, 1,
    0, 0, 0,  0, 1, 0,  0, 1, 1,  0, 0, 1,
    1, 0, 0,  1, 1, 0,  1, 1, 1,  1, 0, 1,
    0, 0, 0,  0, 0, 1,  1, 0, 1,  1, 0, 0,
    0, 1, 0,  0, 1, 1,  1, 1, 1,  1, 1, 0,
  ];

  this.normals = [
    0, 0, -1,  0, 0, -1,  0, 0, -1,  0, 0, -1,
    0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1,
    -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0,
    1, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0,
    0, -1, 0,  0, -1, 0,  0, -1, 0,  0, -1, 0,
    0, 1, 0,  0, 1, 0,  0, 1, 0,  0, 1, 0,
  ];

  this.uvCoords = [
    0,2/3, 0.5, 2/3,  0.5, 1, 0, 1,
    0, 1/3, 0.5,1/3, 0.5,2/3, 0,2/3,
    0,0, 0.5,0, 0.5,1/3, 0,1/3,
    0.5,2/3, 1, 2/3, 1,1, 0.5,1,
    0.5,1/3, 1, 1/3, 1,2/3, 0.5,2/3,
    0.5,0, 1,0, 1,1/3, 0.5,1/3,
  ];

  this.indices = [
    0, 1, 2,  0, 2, 3,
    4, 5, 6,  4, 6, 7,
    8, 9, 10,  8, 10, 11,
    12, 13, 14,  12, 14, 15,
    16, 17, 18,  16, 18, 19,
    20, 21, 22,  20, 22, 23,
  ];
};





TriangleMesh.prototype.createSphere = function(numStacks, numSectors) {
  // TODO: populate unit sphere vertex positions, normals, uv coordinates, and indices
  const radius = 1.0;
  const positions = [];
  const normals = [];
  const uvCoords = [];
  const indices = [];
  
  for (let i = 0; i <= numStacks; i++) {
    let stackAngle = Math.PI / 2 - i * Math.PI / numStacks; 
    let xy = radius * Math.cos(stackAngle); 
    let z = radius * Math.sin(stackAngle); 
    for (let j = 0; j <= numSectors; j++) {
      let sectorAngle = j * 2 * Math.PI / numSectors; 

      let x = xy * Math.cos(sectorAngle);
      let y = xy * Math.sin(sectorAngle);

      positions.push(x, y, z);
      normals.push(x, y, z);

      let u = j / numSectors;
      let v = i / numStacks;
      uvCoords.push(u, v);
    }
  }

  for (let i = 0; i < numStacks; i++) {
    for (let j = 0; j < numSectors; j++) {
      let first = (i * (numSectors + 1)) + j;
      let second = first + numSectors + 1;

      indices.push(first, second, first + 1);
      indices.push(second, second + 1, first + 1);
    }
  }

  this.positions = positions;
  this.normals = normals;
  this.uvCoords = uvCoords;
  this.indices = indices;
}

Scene.prototype.computeTransformation = function(transformSequence) {
  // Initialize overallTransform as identity matrix (4x4)
  let overallTransform = Mat4.create();  // identity matrix
  
  // Loop through each transformation in the sequence
  for (let i = 0; i < transformSequence.length; i++) {
    let transform = transformSequence[i];
    
    if (transform.type === "T") {  // Translation
      let [tx, ty, tz] = transform.values;
      // Create the translation matrix
      let T = Mat4.create();
      Mat4.translate(T, T, [tx, ty, tz]);
      overallTransform = Mat4.multiply(overallTransform, overallTransform, T);
      
    } else if (transform.type === "R") {  // Rotation
      let [axis, angleDeg] = transform.values;
      let angleRad = angleDeg * Math.PI / 180;  // Convert degrees to radians
      
      // Create the rotation matrix based on the axis
      let R = Mat4.create();
      if (axis === 'x') {
        Mat4.rotateX(R, R, angleRad);
      } else if (axis === 'y') {
        Mat4.rotateY(R, R, angleRad);
      } else if (axis === 'z') {
        Mat4.rotateZ(R, R, angleRad);
      }
      overallTransform = Mat4.multiply(overallTransform, overallTransform, R);
      
    } else if (transform.type === "S") {  // Scaling
      let [sx, sy, sz] = transform.values;
      // Create the scaling matrix
      let S = Mat4.create();
      Mat4.scale(S, S, [sx, sy, sz]);
      overallTransform = Mat4.multiply(overallTransform, overallTransform, S);
    }
  }
  
  // Return the final overall transformation matrix
  return overallTransform;
}




Renderer.prototype.VERTEX_SHADER = `
precision mediump float;
attribute vec3 position, normal;
attribute vec2 uvCoord;
uniform mat4 modelMatrix, viewMatrix, projectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;
uniform vec3 cameraPosition;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vViewDir;
varying vec2 vTexCoord;

void main() {
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vNormal = normalize(normalMatrix * normal);
  vLightDir = normalize(lightPosition - worldPosition.xyz);
  vViewDir = normalize(cameraPosition - worldPosition.xyz);
  vTexCoord = uvCoord;

  gl_Position = projectionMatrix * viewMatrix * worldPosition;
}
`;

Renderer.prototype.FRAGMENT_SHADER = `
precision mediump float;
uniform vec3 ka, kd, ks, lightIntensity;
uniform float shininess;
uniform sampler2D uTexture;
uniform bool hasTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vViewDir;
varying vec2 vTexCoord;

void main() {
  // Ambient component
  vec3 ambient = ka * lightIntensity;
  
  // Lambertian diffuse component
  float diff = max(dot(vNormal, vLightDir), 0.0);
  vec3 diffuse = kd * diff * lightIntensity;
  
  // Specular component (Blinn-Phong)
  vec3 halfVec = normalize(vLightDir + vViewDir);
  float spec = pow(max(dot(vNormal, halfVec), 0.0), shininess);
  vec3 specular = ks * spec * lightIntensity;
  
  // Combine the components
  vec3 color = ambient + diffuse + specular;
  
  // If the object has a texture, modulate the color by the texture
  if (hasTexture) {
    vec4 textureColor = texture2D(uTexture, vTexCoord);
    color *= textureColor.rgb;
  }
  
  gl_FragColor = vec4(color, 1.0);
}
`;

////////////////////////////////////////////////////////////////////////////////
// EXTRA CREDIT: change DEF_INPUT to create something interesting!
////////////////////////////////////////////////////////////////////////////////
const DEF_INPUT = [
  "c,myCamera,perspective,5,5,5,0,0,0,0,1,0;",
  "l,myLight,point,0,5,0,2,2,2;",
  "p,unitCube,cube;",
  "p,unitSphere,sphere,20,20;",
  "m,redDiceMat,0.3,0,0,0.7,0,0,1,1,1,15,dice.jpg;",
  "m,grnDiceMat,0,0.3,0,0,0.7,0,1,1,1,15,dice.jpg;",
  "m,bluDiceMat,0,0,0.3,0,0,0.7,1,1,1,15,dice.jpg;",
  "m,globeMat,0.3,0.3,0.3,0.7,0.7,0.7,1,1,1,5,globe.jpg;",
  "o,rd,unitCube,redDiceMat;",
  "o,gd,unitCube,grnDiceMat;",
  "o,bd,unitCube,bluDiceMat;",
  "o,gl,unitSphere,globeMat;",
  "X,rd,Rz,75;X,rd,Rx,90;X,rd,S,0.5,0.5,0.5;X,rd,T,-1,0,2;",
  "X,gd,Ry,45;X,gd,S,0.5,0.5,0.5;X,gd,T,2,0,2;",
  "X,bd,S,0.5,0.5,0.5;X,bd,Rx,90;X,bd,T,2,0,-1;",
  "X,gl,S,1.5,1.5,1.5;X,gl,Rx,90;X,gl,Ry,-150;X,gl,T,0,1.5,0;",
].join("\n");

// DO NOT CHANGE ANYTHING BELOW HERE
export { Parser, Scene, Renderer, DEF_INPUT };
