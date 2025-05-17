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
    // Front face (⚀)
    0, 0, 0,  1, 0, 0,  1, 1, 0,  0, 1, 0,
    // Back face (⚁)
    0, 0, 1,  1, 0, 1,  1, 1, 1,  0, 1, 1,
    // Left face (⚂)
    0, 0, 0,  0, 1, 0,  0, 1, 1,  0, 0, 1,
    // Right face (⚃)
    1, 0, 0,  1, 1, 0,  1, 1, 1,  1, 0, 1,
    // Bottom face (⚄)
    0, 0, 0,  0, 0, 1,  1, 0, 1,  1, 0, 0,
    // Top face (⚅)
    0, 1, 0,  0, 1, 1,  1, 1, 1,  1, 1, 0,
  ];

  this.normals = [
    // Front face (⚀)
    0, 0, -1,  0, 0, -1,  0, 0, -1,  0, 0, -1,
    // Back face (⚁)
    0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1,
    // Left face (⚂)
    -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0,
    // Right face (⚃)
    1, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0,
    // Bottom face (⚄)
    0, -1, 0,  0, -1, 0,  0, -1, 0,  0, -1, 0,
    // Top face (⚅)
    0, 1, 0,  0, 1, 0,  0, 1, 0,  0, 1, 0,
  ];

  this.uvCoords = [
    // Front face (⚀) - bottom left (0,0) to top right (1,1)
    0.5, 0.5,  1.0, 0.5,  1.0, 1.0,  0.5, 1.0,
    // Back face (⚁) - bottom left (0,0) to top right (1,1)
    0.5, 0.25,  1.0, 0.25,  1.0, 0.5,  0.5, 0.5,
    // Left face (⚂) - bottom left (0,0) to top right (1,1)
    0.0, 0.5,  0.5, 0.5,  0.5, 0.75,  0.0, 0.75,
    // Right face (⚃) - bottom left (0,0) to top right (1,1)
    1.0, 0.5,  1.5, 0.5,  1.5, 0.75,  1.0, 0.75,
    // Bottom face (⚄) - bottom left (0,0) to top right (1,1)
    0.0, 0.0,  0.5, 0.0,  0.5, 0.25,  0.0, 0.25,
    // Top face (⚅) - bottom left (0,0) to top right (1,1)
    0.5, 0.75,  1.0, 0.75,  1.0, 1.0,  0.5, 1.0,
  ];

  // Indices for 2 triangles per face
  this.indices = [
    0, 1, 2,  0, 2, 3, // Front face
    4, 5, 6,  4, 6, 7, // Back face
    8, 9, 10,  8, 10, 11, // Left face
    12, 13, 14,  12, 14, 15, // Right face
    16, 17, 18,  16, 18, 19, // Bottom face
    20, 21, 22,  20, 22, 23, // Top face
  ];
};




TriangleMesh.prototype.createSphere = function(numStacks, numSectors) {
  // TODO: populate unit sphere vertex positions, normals, uv coordinates, and indices
  const radius = 1.0;  // Unit sphere
  const positions = [];
  const normals = [];
  const uvCoords = [];
  const indices = [];
  
  for (let i = 0; i <= numStacks; i++) {
    let stackAngle = Math.PI / 2 - i * Math.PI / numStacks;  // Latitude angle
    let xy = radius * Math.cos(stackAngle);  // Radius in the xy-plane
    let z = radius * Math.sin(stackAngle);  // Z position

    for (let j = 0; j <= numSectors; j++) {
      let sectorAngle = j * 2 * Math.PI / numSectors;  // Longitude angle

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
  let overallTransform = Mat4.create();  // identity matrix
  // Iterate through the transform sequence and apply each transformation
  for (let transform of transformSequence) {
    if (transform.type === 'scale') {
      // Apply scaling by the given factors (sx, sy, sz)
      let scaleMatrix = Mat4.scale(transform.sx, transform.sy, transform.sz);
      overallTransform = Mat4.multiply(overallTransform, scaleMatrix);
    }
    else if (transform.type === 'translate') {
      // Apply translation by the given vector (tx, ty, tz)
      let translationMatrix = Mat4.translate(transform.tx, transform.ty, transform.tz);
      overallTransform = Mat4.multiply(overallTransform, translationMatrix);
    }
    else if (transform.type === 'rotate') {
      // Apply rotation by the given angle in degrees around an axis (ax, ay, az)
      let angleRad = Math.PI * transform.angle / 180;  // Convert to radians
      let rotationMatrix = Mat4.rotate(angleRad, transform.ax, transform.ay, transform.az);
      overallTransform = Mat4.multiply(overallTransform, rotationMatrix);
    }
  }
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
