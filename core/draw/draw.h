#pragma once
#include "graphics.h"

fn draw_init() -> void;
fn draw_sprite(const Texture* tex, s32 sprite, Vec4 tint, const Mat4& transform) -> void;
fn draw_sprite(Vec4 tint, const Mat4& transform) -> void;
fn draw_done() -> void;
fn draw_update(f32 dt) -> void;

struct Mesh {
    Vertex_Buffer vbo;
};

fn mesh_init(Mesh* mesh, std::string_view filename) -> void;
fn mesh_done(Mesh* mesh) -> void;
fn draw_mesh(const Mesh* mesh, const Mat4& transform) -> void;