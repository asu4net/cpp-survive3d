
#ifdef VERTEX_SHADER

layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec2 a_uv;
layout(location = 2) in vec3 a_normal;
layout(location = 3) in vec4 a_color;

layout(std140, binding = 0) uniform Shader_Data {
  mat4 u_projection;
  mat4 u_transform;
  vec2 u_uv_size;
  vec2 u_uv_offset;
  vec4 u_tint;
  int u_tex_unit;
};

out vec2 v_uv;
out vec3 v_normal;
out vec3 v_frag_pos;
out vec4 v_color;
out flat int v_tex_unit; 

void main() {
    gl_Position = u_projection * u_transform * vec4(a_pos.xyz, 1.0);
    v_frag_pos = vec3(u_transform * vec4(a_pos.xyz, 1.0));
    v_tex_unit = u_tex_unit;
    v_uv = a_uv;
    // Si aplicas una transformación no uniforme la normal se distorsiona:
    // solución: transpose + inverse
    // Además quitamos la translación pasando la matriz a mat3, no la necesitamos.
    // El cálculo previo de la normal matrix no preserva la longitud del vector,
    // por eso tenemos que normalizar como último paso.
    v_normal = normalize(mat3(transpose(inverse(u_transform))) * a_normal);
    v_color = a_color;
}
#endif

#ifdef FRAGMENT_SHADER

in vec2 v_uv;
in vec3 v_normal;
in vec3 v_frag_pos;
in vec4 v_color;
in flat int v_tex_unit; 

layout(std140, binding = 1) uniform Light_Data {
  vec4 u_light_pos;
  vec4 u_light_color;
  vec4 u_view_pos;
};

layout(location = 0) out vec4 o_col;

#define MAX_TEXTURES 32

uniform sampler2D u_samplers[MAX_TEXTURES];

void main() {
  
  float ambient_strenght = 0.1;
  float specular_strenght = 0.5;
  
  vec4 ambient = ambient_strenght * u_light_color;
  vec4 obj_color = v_color * texture(u_samplers[v_tex_unit], v_uv);
  
  vec3 norm = normalize(v_normal);
  vec3 light_dir = normalize(vec3(u_light_pos) - v_frag_pos);
  float diffuse = max(dot(norm, light_dir), 0.0);
  vec4 diffuse_color = diffuse * u_light_color;

  vec3 view_dir = normalize(vec3(u_view_pos) - v_frag_pos);
  vec3 reflect_dir = reflect(-light_dir, norm);

  float specular = pow(max(dot(view_dir, reflect_dir), 0.0), 64);
  vec4 specular_color = specular * specular_strenght * u_light_color;

  vec3 res = (vec3(ambient) + vec3(diffuse_color) + vec3(specular_color))  * vec3(obj_color);
  o_col = vec4(res, 1.0);
  //o_col = vec4(v_normal * 0.5 + 0.5, 1.0);
}

#endif