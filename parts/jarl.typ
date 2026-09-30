#import "theme.typ": label-font, value-font

#let jarl-red = rgb("#e60012")

#let jarl-box-width = 6.5mm
#let jarl-box-height = 9mm
#let jarl-box-pitch = 9mm
#let jarl-frame-top = 11mm
#let jarl-frame-right = 9mm

#let jarl-transfer-frame(
  boxes: 8,
  callsign: none,
  via: false,
  color: jarl-red,
  thickness: 0.6pt,
  size: 22pt,
) = {
  assert(boxes in (6, 8), message: "boxes must be 6 or 8")

  let chars = if callsign == none { () } else { upper(callsign).clusters() }
  assert(chars.len() <= boxes, message: "callsign is longer than the frame")

  let stroke = if color == jarl-red {
    thickness + color
  } else {
    (paint: color, thickness: thickness, dash: "dashed")
  }

  let cell(c) = box(
    width: jarl-box-width,
    height: jarl-box-height,
    stroke: stroke,
    align(center + horizon, text(..value-font, size: size, top-edge: "cap-height", bottom-edge: "baseline", c)),
  )

  let frame = stack(
    dir: ltr,
    spacing: jarl-box-pitch - jarl-box-width,
    ..range(boxes).map(i => cell(chars.at(i, default: none))),
  )

  if via {
    stack(
      dir: ltr,
      spacing: 2mm,
      box(height: jarl-box-height, align(horizon, text(..label-font, size: 14pt)[VIA])),
      frame,
    )
  } else {
    frame
  }
}
