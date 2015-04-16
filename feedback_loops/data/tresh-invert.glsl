#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float threshold;
uniform float thresholdSmooth;

void main(void)
{
  vec2 st = vertTexCoord.st;
  vec4 cola = texture2D(texture, st);
  vec3 col = cola.rgb;
  float alpha = cola.a;

  // thresh color
  float v = dot(vec3(1.0, 1.0, 1.0), col);
  v = v / 3.0;
  v = smoothstep(threshold - thresholdSmooth, threshold + thresholdSmooth, v);
  col = vec3(v, v, v);

  // tresh alpha
  alpha = smoothstep(threshold - thresholdSmooth, threshold + thresholdSmooth, alpha);

  // negate
  col = vec3(1.0, 1.0, 1.0) - col;

  gl_FragColor = vec4(col, alpha);
}
