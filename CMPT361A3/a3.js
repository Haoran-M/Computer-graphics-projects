import { Framebuffer } from './framebuffer.js';
import { Rasterizer } from './rasterizer.js';
// DO NOT CHANGE ANYTHING ABOVE HERE

////////////////////////////////////////////////////////////////////////////////
// TODO: Implement functions drawLine(v1, v2) and drawTriangle(v1, v2, v3) below.
////////////////////////////////////////////////////////////////////////////////

Rasterizer.prototype.drawLine = function(v1, v2) {
  const [x1, y1, [r1, g1, b1]] = v1;
  const [x2, y2, [r2, g2, b2]] = v2;

  let dx = x2 - x1;
  let dy = y2 - y1;

  let step = Math.abs(dx) > Math.abs(dy) ? Math.abs(dx) : Math.abs(dy);

  let xInc = dx / step;
  let yInc = dy / step;

  let x = x1;
  let y = y1;

  this.setPixel(Math.floor(x), Math.floor(y), [r1, g1, b1]);

  for (let i = 1; i <= step; i++) {
    x += xInc;
    y += yInc;

    let j = i / step;

    let r = Math.min(255, Math.max(0, Math.round((r1 + j * (r2 - r1)) * 255)));
    let g = Math.min(255, Math.max(0, Math.round((g1 + j * (g2 - g1)) * 255)));
    let b = Math.min(255, Math.max(0, Math.round((b1 + j * (b2 - b1)) * 255)));

    this.setPixel(Math.floor(x), Math.floor(y), [r, g, b]);
  }

  this.setPixel(Math.floor(x2), Math.floor(y2), [r2, g2, b2]);
};


// Helper function
Rasterizer.prototype.pointIsInsideTriangle = function(v1, v2, v3, p) {
  const [x1, y1] = v1;
  const [x2, y2] = v2;
  const [x3, y3] = v3;
  const [px, py] = p;

  const [alpha, beta, gamma] = this.barycentricCoordinates(v1, v2, v3, p);

  return (alpha >= 0 && beta >= 0 && gamma >= 0) ||
        (alpha === 0 && beta === 0 && gamma === 0);
};

//Helper function
Rasterizer.prototype.barycentricCoordinates = function(v1, v2, v3, p) {
  const [x1, y1] = v1;
  const [x2, y2] = v2;
  const [x3, y3] = v3;
  const [px, py] = p;

  const alpha = ((y2 - y3) * (px - x3) + (x3 - x2) * (py - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
  const beta = ((y3 - y1) * (px - x3) + (x1 - x3) * (py - y3)) / ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
  const gamma = 1 - alpha - beta;

  return [alpha, beta, gamma];
};


Rasterizer.prototype.drawTriangle = function(v1, v2, v3) {
  const [x1, y1, [r1, g1, b1]] = v1;
  const [x2, y2, [r2, g2, b2]] = v2;
  const [x3, y3, [r3, g3, b3]] = v3;

  const minX = Math.min(x1, x2, x3);
  const maxX = Math.max(x1, x2, x3);
  const minY = Math.min(y1, y2, y3);
  const maxY = Math.max(y1, y2, y3);

  for (let y = minY; y <= maxY; y++) {
    for (let x = minX; x <= maxX; x++) {
      const point = [x, y];
      if (this.pointIsInsideTriangle(v1, v2, v3, point)) {

        const [alpha, beta, gamma] = this.barycentricCoordinates(v1, v2, v3, point);

        const r = alpha * r1 + beta * r2 + gamma * r3;
        const g = alpha * g1 + beta * g2 + gamma * g3;
        const b = alpha * b1 + beta * b2 + gamma * b3;

  
        this.setPixel(x, y, [r, g, b]);
      }
    }
  }
};


////////////////////////////////////////////////////////////////////////////////
// EXTRA CREDIT: change DEF_INPUT to create something interesting!
////////////////////////////////////////////////////////////////////////////////
const DEF_INPUT = [
  "v,1,30,1.0,0.5,0.0;",
  "v,10,40,1.0,0.6,0.4;",
  "v,1,50,0.0,1.0,0.5;",
  "v,35,10,1.0,1.0,0.0;",
  "v,32,13,1.0,0.0,1.0;",
  "v,38,15,1.0,0.0,1.0;",
  "v,60,40,0.9,0.1,0.1;",
  "v,35,60,1.0,0.4,0.2;",
  "t,0,1,2;",
  "t,3,4,5;",
  "t,1,5,7;",
  "t,5,6,7;",
  "v,50,35,0.1,0.5,0.7;",
  "v,53,37,0.2,0.6,0.8;",
  "v,50,39,0.3,0.7,0.9;",
  "l,8,9;",
  "l,9,10;",
  "l,8,10;"
].join("\n");




// DO NOT CHANGE ANYTHING BELOW HERE
export { Rasterizer, Framebuffer, DEF_INPUT };
