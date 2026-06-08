package omai

import "core:math"
import rl "vendor:raylib"

TITLE :: "omai"

close := false
win_width : i32 = 900
win_height : i32 = 900
ring_size: f32 = 0.9
ring_radius: f32 = ring_size * (cast(f32)win_height / 2)
ring_thickness: f32 = 4.0

update :: proc() {
    close = rl.WindowShouldClose()
    if rl.IsKeyPressed(rl.KeyboardKey.A) {
        close = true 
    }
}

draw :: proc() {
    rl.ClearBackground({0x0c, 0x0c, 0x0c, 0xff})
    rl.DrawFPS(20, 20)
    draw_circle()
}

draw_circle :: proc() {
    center := [2]f32{cast(f32)win_width / 2, cast(f32)win_height / 2};
    rl.DrawRing(center, ring_radius - ring_thickness, ring_radius, 0, 360.0, 250, rl.RAYWHITE)

    circle_radius: f32 = ring_radius - (ring_thickness / 2)
    for cur_angle: f32 = -22.5; cur_angle < 360; cur_angle += 45 {
        sin, cos := math.sincos_f32(cur_angle * cast(f32)math.PI / 180);
        rl.DrawCircle(i32(center[0] + circle_radius * cos), i32(center[1] + circle_radius * sin), 14, rl.RAYWHITE);
    }

}

main :: proc() {
    rl.SetConfigFlags({.MSAA_4X_HINT, .WINDOW_HIGHDPI})
    rl.InitWindow(win_width, win_height, TITLE)

    for !close {
        update()
        rl.BeginDrawing()
        draw()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}
