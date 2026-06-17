package simai_parser

import simai "../simai"
import "core:strings"

import "core:fmt"
import "core:mem"
import "core:strconv"

Parser :: struct {
	// not owned
	src:           string,
	cur, row, bol: int,
}

Pos :: struct {
	row, col, span: int,
}

parser_new :: proc(data: string) -> (p: Parser, ok: bool) {
	p = {
		src = data,
		cur = 0,
		row = 1,
		bol = 0,
	}
	ok = true
	return
}

cur :: #force_inline proc(p: ^Parser) -> byte {
	return p.src[p.cur]
}

in_bounds :: #force_inline proc(p: ^Parser) -> bool {
	return p.cur < len(p.src)
}

advance :: #force_inline proc(p: ^Parser, count: int = 0) {
	p.cur += count
}

// bump up the line number given that we are on a newline
bump_newline :: proc(p: ^Parser) {
	assert(cur(p) == '\n', "bump_newline should only be called if the current char is a newline")
	p.row += 1
	advance(p)
	p.bol = p.cur
}

// Mark a position beginning `span` before the current location of the parser, and returns it
pos :: proc(p: ^Parser, span: int = 1) -> (pos: Pos) {
	return {p.row, p.cur - p.bol + 1 - span, span}
}

// Mark a position starting from the current location of the parser for span bytes, and returns it
pos_here :: proc(p: ^Parser, span: int = 1) -> (pos: Pos) {
	return {p.row, p.cur - p.bol + 1, span}
}

error_with_pos :: proc(p: ^Parser, pos: Pos, format: string, msg: ..any) {
	// TODO: add other ways to record errors
	fmt.eprintf("Error at %d, %d: ", pos.row, pos.col)
	fmt.eprintfln(format, msg)
}

error_here :: proc(p: ^Parser, format: string, msg: ..any) {
	error_with_pos(p, pos(p), format, msg)
}

error :: proc {
	error_with_pos,
	error_here,
}

expect_byte :: #force_inline proc(p: ^Parser, item: byte, desc: string) -> bool {
	if cur(p) == item {
		advance(p)
		return true
	} else {
		error(p, pos_here(p), "expected %c %s!", cur(p), desc)
		return false
	}
}

parse_bpm :: proc(p: ^Parser) -> (num: f32, ok: bool) {
	if !expect_byte(p, '(', "for BPM definition") {
		return 0, false
	}

	count: int
	num, count, ok = strconv.parse_f32_prefix(p.src[p.cur:])
	if !ok {
		error(p, pos(p, count), "could not parse number after ( in BPM definition")
		return 0, false
	}

	advance(p, count)

	if !expect_byte(p, ')', "for BPM definition") {
		return 0, false
	}

	return
}

// returns an _unfinished_ chart with only the metadata filled in, no level data
parse_meta_line :: proc(p: ^Parser, chart: ^simai.Chart) -> (ok: bool) {
	if !expect_byte(p, '&', "for line of metadata") {
		return false
	}

	begin, end: int

	begin = p.cur
	end = p.cur
	for p.src[end] != '=' {
		end += 1

		if end >= len(p.src) {
			error(p, pos(p, -1), "Unexpectedly hit EOF while parsing metadata field name")
			return false
		}
	}

	field := p.src[begin:end]
	// account for the equal
	advance(p, end + 1)

	begin = p.cur
	end = p.cur
	for p.src[end] != '\n' {
		end += 1

		if end >= len(p.src) {
			p.cur = len(p.src) - 1
			error(p, pos(p, -1), "Unexpectedly hit EOF while parsing metadata field name")
			return false
		}
	}

	value := p.src[begin:end]
	advance(p, end)
	value_pos := pos(p, len(value))
	bump_newline(p)

	switch field {
	case "title":
		if chart.title != "" {
			chart.title = strings.clone(value)
		}
		return
	case "artist":
		if chart.artist != "" {
			chart.artist = strings.clone(value)
		}
		return
	// TODO: figure out what "first" is
	case "des":
		if chart.designer != "" {
			chart.designer = strings.clone(value)
		}
		return
	case "demo_seek":
		demo_seek, ok := strconv.parse_f32(value)
		if !ok {
			error(p, value_pos, "could not parse number for demo_seek")
			return false
		}
		chart.demo_seek = demo_seek
		return
	}

	if strings.starts_with(field, "lv_") {
		// TODO: fill out level maps
	}

	if strings.starts_with(field, "des_") {
		// TODO: fill out level maps
	}

	if strings.starts_with(field, "inote_") {
		// TODO: fill out level maps
	}

	return
}

parse_level :: proc(p: ^Parser) -> (level: simai.LevelData, ok: bool) {
	return {}, false
}

parse_chart :: proc(p: ^Parser) -> (chart: simai.Chart, ok: bool) {
	return {}, false
}

parse_chart_from_string_basic :: proc(data: string) -> (c: simai.Chart, ok: bool) {
	p: Parser

	if p, ok = parser_new(data); !ok {
		return {}, false
	}

	if c, ok = parse_chart(&p); !ok {
		return {}, false
	}

	return
}
