/*

Inspired by Apple Liquid Glass.


MIT License

Copyright (c) 2025 Arnold Buchmueller

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#version 320 es
precision highp float;

#include <flutter/runtime_effect.glsl>

#define PI         3.14159265359
#define BLUR_STEPS 12          // per ring
#define MAX_RECTS  4           // ← now five rectangles

/* ── Global uniforms ─────────────────────────────────────────── */
uniform vec2   u_size;             // (w,h)  px
uniform vec4   uBounds;            // [minX,minY,maxX,maxY] px

uniform float  uBlendPx;           // smooth-union width
uniform float  uRefractStrength;
uniform float  uDistortFalloffPx;
uniform float  uDistortExponent;

uniform float  uRadialBlurPx;      // px, 0 = off

uniform float  uSpecAngle;
uniform float  uSpecStrength;
uniform float  uSpecPower;
uniform float  uSpecWidthPx;

uniform float  uLightbandOffsetPx;
uniform float  uLightbandWidthPx;
uniform float  uLightbandStrength;
uniform vec3   uLightbandColor;

uniform float  uAAPx;
uniform float  uRectCount;         // actual rects in use

/* ── Per-rect data (centre.xy , size.zw), corner radii, tints ── */
uniform vec4   uRect0;  uniform float uCorner0;  uniform vec4 uTintColor0;
uniform vec4   uRect1;  uniform float uCorner1;  uniform vec4 uTintColor1;
uniform vec4   uRect2;  uniform float uCorner2;  uniform vec4 uTintColor2;
uniform vec4   uRect3;  uniform float uCorner3;  uniform vec4 uTintColor3;

uniform sampler2D u_texture_input;
out vec4 fragColor;

/* ── Helpers ─────────────────────────────────────────────────── */
#define R u_size
float px(float v) { return v / R.y; }
vec3  bg(vec2 uv){ return texture(u_texture_input, clamp(uv,0.0,1.0)).rgb; }

/* getters keep main tidy */
vec4  getRect(int i){
  return (i==0)?uRect0 :(i==1)?uRect1 :(i==2)?uRect2
       :uRect3;
}
float getCorner(int i){
  return (i==0)?uCorner0 :(i==1)?uCorner1 :(i==2)?uCorner2
       :uCorner3;
}
vec4  getTint(int i){
  return (i==0)?uTintColor0 :(i==1)?uTintColor1 :(i==2)?uTintColor2
       :uTintColor3;
}

/* rounded-rect SDF */
float sdRoundRect(vec2 p, vec2 hsz, float r){
  vec2 q = abs(p) - (hsz - vec2(r));
  return length(max(q,vec2(0.))) + min(max(q.x,q.y),0.) - r;
}
/* iq polynomial smooth-min */
float sminPoly(float a,float b,float k){
  float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
  return mix(b,a,h) - k*h*(1.0-h);
}

/* radial blur */
vec3 radialBlur(vec2 uv,float radiusPx){
  if(radiusPx<0.5) return bg(uv);
  vec3 sum = bg(uv);
  float nr = px(radiusPx);
  int cnt  = 1;
  for(int ring=1; ring<=4; ++ring){
    float rad = nr * float(ring)/4.0;
    for(int j=0; j<BLUR_STEPS; ++j){
      float a = float(j)*2.0*PI/float(BLUR_STEPS);
      sum += bg(uv + vec2(cos(a),sin(a))*rad);
      cnt++;
    }
  }
  return sum/float(cnt);
}

/* ── Main ────────────────────────────────────────────────────── */
void main(){
  vec2 fragPx = FlutterFragCoord().xy;
#ifdef IMPELLER_TARGET_OPENGLES
  fragPx.y = R.y - fragPx.y;
#endif

  /* passthrough */
  if(fragPx.x<uBounds.x||fragPx.x>uBounds.z||
     fragPx.y<uBounds.y||fragPx.y>uBounds.w){
    fragColor = texture(u_texture_input, fragPx/R);
    return;
  }

  vec2 uv0      = fragPx/R;
  vec2 uvCenter = (fragPx - 0.5*R) / R.y;

  /* union SDF + store individual distances */
  float k   = px(uBlendPx);
  int   cnt = int(uRectCount);
  float dU  = 0.0;
  float d[MAX_RECTS];

  for(int i=0;i<MAX_RECTS;++i){
    if(i>=cnt){ d[i]=1e5; continue; }
    vec4 r = getRect(i);
#ifdef IMPELLER_TARGET_OPENGLES
    r.y = R.y - r.y;
#endif
    vec2 hsz  = (r.zw*0.5)/R.y;
    vec2 posN = (r.xy - 0.5*R)/R.y;
    d[i]  = sdRoundRect(uvCenter - posN, hsz, getCorner(i)/R.y);
    dU    = (i==0)?d[i]:sminPoly(dU,d[i],k);
  }

  float mask = smoothstep(px(uAAPx),-px(uAAPx),dU);

  vec2 grad = vec2(dFdx(dU),dFdy(dU));
#ifdef IMPELLER_TARGET_OPENGLES
  grad.y = -grad.y;
#endif
  grad = normalize(grad+1e-6);

  vec2 off = grad * pow(smoothstep(-px(uDistortFalloffPx),0.0,dU),
                        uDistortExponent) * uRefractStrength * mask;
#ifdef IMPELLER_TARGET_OPENGLES
  off.y = -off.y;
#endif

  vec3 glassBase = radialBlur(uv0 + off*0.6, uRadialBlurPx);

  /* tint blend (soft-max) */
  vec3  accum = vec3(0.0);
  float wSum  = 0.0;
  for(int i=0;i<MAX_RECTS;++i){
    if(i>=cnt) break;
    float w = exp(-d[i]/k);
    vec4 tint = getTint(i);          // rgb + strength (a)
    accum += mix(glassBase, tint.rgb, tint.a) * w;
    wSum  += w;
  }
  vec3 glass = accum / wSum;

  /* specular rim */
  vec3 N3 = normalize(vec3(grad,0.6));
  vec3 L1 = normalize(vec3(cos(uSpecAngle), sin(uSpecAngle), 0.5));
  vec3 L2 = normalize(vec3(-cos(uSpecAngle),-sin(uSpecAngle),0.5));
  float rim = smoothstep(px(-uSpecWidthPx),0.0,dU);
  glass += (pow(max(dot(N3,L1),0.0),uSpecPower) +
            pow(max(dot(N3,L2),0.0),uSpecPower)) * uSpecStrength * rim;

  /* light band */
  float lb = smoothstep(0.0,px(uLightbandWidthPx),dU+px(uLightbandOffsetPx));
  glass += uLightbandColor * lb * uLightbandStrength;

  fragColor = vec4(mix(bg(uv0),glass,mask),1.0);
}
