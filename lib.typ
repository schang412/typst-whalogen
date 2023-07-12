#import "@preview/xarrow:0.1.1": xarrow

#let _quote(t) = {
  return "\"" + t + "\""
}

#let _split_and_insert(l, split: " ", insert: []) = {  // array(str|content) -> array(str|content)
  let result = ()
  for item in l {
    if type(item) != "string" {
      result.push(item)
      continue
    }
    for item_split in item.split(split) {
      result.push(item_split)
      result.push(insert)
    }
    result.pop()
  }
  return result
}

#let sym_map = (
  "<-->": sym.arrows.lr,
  "<->": sym.arrow.l.r,
  "->": sym.arrow.r,
  "<-": sym.arrow.l
)

#let _parse_isotope(t) = {
  let res = t.match(regex("@(\w+),([\d-]+),([\d-]+)@"))
  if res != none {
    return "attach(\"" + res.captures.at(0) + "\", tl: " + res.captures.at(1) + ", bl: "+ res.captures.at(2) +")"
  }
  return _quote(t)
}

// describes what to write to the output when a certain state ends
// return result should be written to output. buffer should be cleared after running this function
#let _flush_ce_buffer(_state, _buffer) = {
  return (
    "letter": _quote(_buffer),
    "num_script": "_" + _quote(_buffer),
    "": _buffer,
    "num": _buffer,
    "charge": "^" + _quote(_buffer.replace("-", sym.dash.en)),
    "caret": "^" + _quote(_buffer.replace("^", "", count: 1).replace("-", sym.dash.en)),
    "underscore": "_" + _quote(_buffer.replace("_", "", count: 1)),
    "code": _buffer,
    "punctuation": _buffer,
    "leading_punctuation": _buffer,
    "isotope?": _parse_isotope(_buffer),
  ).at(_state)
}

#let _parse_ce(_state, _char_in, _buffer) = { // returns next_state, commit, buffer
  let _out = ""

  // end previous states on whitespace
  if _char_in.contains(regex("\s")) {
    _out = _flush_ce_buffer(_state, _buffer)
    _buffer = ""
    _state = ""
  }
  if _char_in == "#" {
    _out = _flush_ce_buffer(_state, _buffer)
    _buffer = ""
    _state = "code"
  }

  // on letter flush buffer (unless already is letter)
  if _char_in.contains(regex("[A-Za-z]")) {
    (_state, _out, _buffer) = (
      "letter": ("letter", _out, _buffer),
      "isotope?": ("isotope?", _out, _buffer),
      "code": ("code", _out, _buffer),
      "caret": ("caret", _out, _buffer),
    ).at(_state, default: ("letter", _flush_ce_buffer(_state, _buffer), ""))
  }

  // on digit
  if _char_in.contains(regex("\d")) {
    (_state, _out, _buffer) = (
      "letter": ("num_script", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("num_script", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("num_script", _out, _buffer)
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on plus/minus
  if _char_in.contains(regex("[+-]")) {
    (_state, _out, _buffer) = (
      "letter": ("charge", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("charge", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on caret
  if _char_in.contains("^") {
    (_state, _out, _buffer) = (
      "letter": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("caret", _flush_ce_buffer(_state, _buffer), ""),
      "underscore": ("caret", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on underscore
  if _char_in.contains("_") {
    (_state, _out, _buffer) = (
      "letter": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "punctuation": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "num_script": ("underscore", _flush_ce_buffer(_state, _buffer), ""),
      "caret": ("underscore", _flush_ce_buffer(_state, _buffer), "")
    ).at(_state, default: (_state, _out, _buffer))
  }

  // on closing brackets...
  if _char_in.contains(regex("[)}\]]")) {
    (_state, _out, _buffer) = (
      "_": ("", "", "")
    ).at(_state, default: ("punctuation", _flush_ce_buffer(_state, _buffer), ""))
  }

  // on opening brackets...
  if _char_in.contains(regex("[\[({]")) {
    (_state, _out, _buffer) = (
      "_": ("", "", "")
    ).at(_state, default: ("leading_punctuation", _flush_ce_buffer(_state, _buffer), ""))
  }

  // isotope parsing
  if _char_in.contains(regex("@")) {
    (_state, _out, _buffer) = (
      "isotope?": ("", _flush_ce_buffer(_state, _buffer + _char_in), "")
    ).at(_state, default: ("isotope?", _out, _buffer))
    if _state != "isotope?" {
      return (_state, _out, _buffer)
    }
  }

  _buffer = _buffer + _char_in
  return (_state, _out, _buffer)
}

#let _extend_arrows(s) = {  // (str) -> array(str | content)
  let result = (s,)
  for symbol in sym_map.values() {
    result = _split_and_insert(result, split: symbol, insert: [
      #xarrow(sym: symbol, margin: 0.8em, [])
    ])
  }
  return result
}

#let _extract_ce_substrs(msg) = { // (str) -> array(str | content)
  let did_push = false
  let finish = ()
  for (index, result_str) in msg.enumerate() {
    for symbol in sym_map.values() {
      let sym_match_result = result_str.match(regex("(.*)" + symbol + "\[([^\]]+)\]" + "(.*)"))
      if sym_match_result != none {
        finish += _extract_ce_substrs((sym_match_result.captures.at(0), ))
        finish.push(h(0.2em))
        finish.push(xarrow(sym: symbol, margin: 0.5em, [
          $upright(#eval("$" + sym_match_result.captures.at(1) + "$"))$
        ]))
        finish.push(h(0.2em))  // correct for horizontal spacing error introduced by xarrow
        finish += _extract_ce_substrs((sym_match_result.captures.at(2), ))
        did_push = true
      }
    }
    if not did_push {
      finish += _extend_arrows(result_str)
    }
  }
  return finish
}

#let ce(t, debug: false) = { // (str, bool) -> content
  assert(type(t) == "string", message: "ce: argument must be of type `string`")
  let state = ""

  for (pattern, result) in sym_map {
    t = t.replace(regex(pattern), " " + result)
  }

  t = t + " "
  let buffer = ""
  let out = ""
  let result = ""
  // iterate through the string
  for c in t.codepoints() {
    (state, out, buffer) = _parse_ce(state, c, buffer)
    result += out
  }

  if debug {
    return raw(result)
  }

  // convert string to content
  for result_sub_str in _extract_ce_substrs((result,)) {
    if type(result_sub_str) == "string" {
      result_sub_str = "$" + result_sub_str + "$"
      $upright(#eval(result_sub_str))$
    } else if type(result_sub_str) == "content" {
      result_sub_str
    }
  }
}
