package osyalan

import "core:math"
import rl "vendor:raylib"

View :: struct {
	// sz: size of bounding square
	// r: radius of ring
	x, y, sz, r: i32,
	padding:     f32,
}

// size of small circles on the ring
RING_CIRCLE_RADIUS :: 14
RING_THICKNESS :: 4

view_new :: proc(x, y, sz: i32, padding: f32 = 0.06) -> (v: View) {
	v = {
		x       = x,
		y       = y,
		padding = padding,
	}
	view_update_size(&v, sz)
	return v
}

view_update_size :: proc(v: ^View, new_sz: i32) {
	v.sz = new_sz
	v.r = i32((f32(v.sz) * (1 - v.padding) / 2))
}

view_draw :: proc(v: ^View) {
	rl.ClearBackground({0x0c, 0x0c, 0x0c, 0xff})
	rl.DrawFPS(20, 20)
	draw_circle(v)
}

draw_circle :: proc(v: ^View) {
	center := [2]f32{f32(v.sz / 2), f32(v.sz / 2)}
	rl.DrawRing(
		center + {f32(v.x), f32(v.y)},
		f32(v.r) - RING_THICKNESS,
		f32(v.r),
		0,
		360.0,
		250,
		rl.RAYWHITE,
	)

	circle_radius: f32 = f32(v.r) - (RING_THICKNESS / 2)
	for cur_angle: f32 = -22.5; cur_angle < 360; cur_angle += 45 {
		sin, cos := math.sincos_f32(cur_angle * f32(math.PI) / 180)
		x := v.x + i32(center[0] + circle_radius * cos)
		y := v.y + i32(center[1] + circle_radius * sin)
		rl.DrawCircle(x, y, RING_CIRCLE_RADIUS, rl.RAYWHITE)
	}

}

view_update :: proc(v: ^View) {}
