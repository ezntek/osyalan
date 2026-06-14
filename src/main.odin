package osyalan

import rl "vendor:raylib"

TITLE :: "osyalan"

close := false
view: View
win_width: i32 = 900
win_height := win_width

update :: proc() {
	close = rl.WindowShouldClose()
	view_update(&view)

	if rl.IsWindowResized() {
		s := rl.GetWindowScaleDPI()
		win_width = i32(f32(rl.GetRenderWidth()) / s[0])
		win_height = i32(f32(rl.GetRenderHeight()) / s[1])

		view_update_size(&view, win_height if win_height < win_width else win_width)
		view.x = (win_width / 2) - (view.sz / 2)
		view.y = (win_height / 2) - (view.sz / 2)
	}
}

draw :: proc() {
	view_draw(&view)
}

init :: proc() {
	rl.SetConfigFlags({.MSAA_4X_HINT, .WINDOW_HIGHDPI, .WINDOW_RESIZABLE})
	rl.InitWindow(win_width, win_height, TITLE)
	view = view_new(0, 0, win_height)
}

deinit :: proc() {
	rl.CloseWindow()
}

main :: proc() {
	init()
	defer deinit()

	for !close {
		update()
		rl.BeginDrawing()
		draw()
		rl.EndDrawing()
	}
}
