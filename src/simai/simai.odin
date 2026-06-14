package simai

import "core:mem"
import "core:strings"

Parser :: struct {}

Chart :: struct {
	title, artist: string,
	designer:      Maybe(string),
	demo_seek:     f32,
	levels:        map[int]LevelData,
}

chart_delete :: proc(c: ^Chart) {
}

LevelData :: struct {
	level:    string,
	designer: string,
	bpm:      f32,
}

NoteSet :: []Note

Note :: union {
	Tap,
	Hold,
	Touch,
	TouchHold,
	Slide,
}

Tap :: struct {
	at:    u8,
	props: NotePropertySet,
}

Hold :: struct {
	at:     u8,
	timing: LongNoteTiming,
	props:  NotePropertySet,
}

Touch :: struct {
	at:    Sensor,
	props: NotePropertySet,
}

TouchHold :: struct {
	at:     Sensor,
	timing: LongNoteTiming,
	props:  NotePropertySet,
}

Slide :: struct {
	// 1-8
	connections: []struct {
		edge:   u8,
		shape:  SlideShape,
		timing: LongNoteTiming,
	},
	end:         u8,
	begin_props: NotePropertySet,
	end_props:   NotePropertySet,
}

NoteProperty :: enum (u8) {
	Break,
	Ex,
	Firework,
}

NotePropertySet :: bit_set[NoteProperty]

// Timing for all long notes (HOLDs, SLIDEs, TOUCH-HOLDs).
LongNoteTiming :: union {
	// custom bpm, bpm divider, number of divider durations
	[3]u16,
	// bpm divider, number of divider durations
	[2]u16,
	// exact timing in seconds
	f32,
}

SlideShape :: enum (u8) {
	Straight               = '-',
	Center                 = 'v',
	EdgeAnticlockwise      = '<',
	EdgeClockwise          = '>',
	InnerLoopAnticlockwise = 'p',
	InnerLoopClockwise     = 'q',
	OuterLoopAnticlockwise = 'P',
	OuterLoopClockwise     = 'Q',
}

// too long, so we keep it at the bottom
Sensor :: enum (u8) {
	A1,
	A2,
	A3,
	A4,
	A5,
	A6,
	A7,
	A8,
	B1,
	B2,
	B3,
	B4,
	B5,
	B6,
	B7,
	B8,
	D1,
	D2,
	D3,
	D4,
	D5,
	D6,
	D7,
	D8,
	E1,
	E2,
	E3,
	E4,
	E5,
	E6,
	E7,
	E8,
	C,
}
