
# void game_physics_load_triangles(struct game *game) {
#     {
#         game->physics.hole_triangles.length = 0;
#         for (int i = 0; i < game->hole.terrain_entities.length; i++) {
            mat4 transform = terrain_entity_get_transform(entity);
            for (int i = 0; i < model->faces.length; i++) {
                struct terrain_model_face face = model->faces.data[i];
                assert(face.num_points == 3 || face.num_points == 4);

                vec3 p0 = vec3_apply_mat4(model->points.data[face.x], 1.0f, transform);
                vec3 p1 = vec3_apply_mat4(model->points.data[face.y], 1.0f, transform);
                vec3 p2 = vec3_apply_mat4(model->points.data[face.z], 1.0f, transform);
                struct physics_triangle tri = physics_triangle_create(p0, p1, p2, face.cor, face.friction,
                                                                      face.vel_scale);
                array_push(&game->physics.hole_triangles, tri);
                if (face.num_points == 4) {
                    vec3 p3 = vec3_apply_mat4(model->points.data[face.w], 1.0f, transform);
                    struct physics_triangle tri = physics_triangle_create(p2, p3, p0, face.cor, face.friction,
                                                                          face.vel_scale);
                    array_push(&game->physics.hole_triangles, tri);
                }
            }
        }
    }