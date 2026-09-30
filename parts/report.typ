#import "theme.typ": label-font, value-font, data-font

#let report-columns = (
  (key: "date", label: [Date]),
  (key: "time", label: [Time]),
  (key: "report", label: [RST]),
  (key: "freq", label: [MHz]),
  (key: "mode", label: [2WAY]),
)

#let report-sample = (
  date: "0000-00-00",
  time: "00:00",
  timezone: "UTC",
  freq: "00000.000",
  mode: "PSK31",
  report: "599",
)

#let format-freq(freq) = {
  let parts = str(freq).split(".")
  let fraction = parts.at(1, default: "") + "000"
  parts.at(0) + "." + fraction.slice(0, 3)
}

#let format-value(key, entry) = {
  let value = entry.at(key, default: none)
  if value == none or value == "" {
    return none
  }
  let formatted = if key == "time" {
    [#text(size: 0.7em, entry.at("timezone", default: "")) #value.slice(0, 5)]
  } else if key == "freq" {
    format-freq(value)
  } else {
    value
  }
  box(text(..value-font, formatted))
}

#let fit-width(body, width) = {
  let natural = measure(body)
  if natural.width > width {
    box(height: natural.height, align(bottom, scale(width / natural.width * 100%, origin: bottom, reflow: true, body)))
  } else {
    body
  }
}

#let blank-line(body, width: 1fr, padding: 1mm, alignment: center, line: 0.5pt) = box(
  width: width,
  stroke: (bottom: line),
  outset: (bottom: 2pt),
  inset: (x: padding),
  layout(area => align(alignment, fit-width(body, area.width))),
)

#let present(value) = value != none and value != ""

#let format-power(power) = {
  let watts = float(power)
  if watts == calc.trunc(watts) { str(int(watts)) } else { str(watts) }
}

#let to-radio(callsign: none, size: 1.68em, line: 0.5pt) = {
  let call = text(..value-font, size: size, if present(callsign) { upper(callsign) } else { hide[X] })
  par(justify: false)[
    To Radio
    #blank-line(call, line: line)
    Confirming our QSO
  ]
}

#let field-label-width = 8mm

#let instrument-fields(
  rig: none,
  power: none,
  antenna: none,
  size: 8pt,
  value-size: 1.2em,
  power-width: 14mm,
  row-height: 5mm,
  trailer: none,
  line: 0.5pt,
) = {
  let value(v) = if present(v) { text(..data-font, size: value-size, v) }
  let watts = if present(power) { format-power(power) }

  set text(size: size)

  grid(
    columns: (field-label-width, 1fr, auto, power-width, auto),
    column-gutter: 1.5mm,
    rows: row-height,
    align: bottom,
    [Rig], blank-line(value(rig), width: 100%, alignment: left, line: line),
    pad(left: 1mm)[Power], blank-line(value(watts), width: 100%, line: line), [W],
    [Ant.], blank-line(value(antenna), width: 100%, alignment: left, line: line),
    grid.cell(colspan: 3, align: right + bottom, trailer),
  )
}

#let format-operator(name, callsign, call-size: 1em) = {
  let call = if present(callsign) { text(..value-font, size: call-size, upper(callsign)) }
  let name = if present(name) { name }
  if call != none and name != none {
    box(grid(columns: 2, column-gutter: 0.6em, align: horizon, call, name))
  } else if call != none {
    call
  } else {
    name
  }
}

#let format-shigunku(number) = {
  let number = upper(str(number))
  let prefix = if number.match(regex("^[0-9]{5}[A-Z]?$")) != none { "JCG#" } else { "JCC#" }
  prefix + number
}

#let format-locator(locator) = {
  let locator = str(locator)
  let split = calc.min(4, locator.len())
  upper(locator.slice(0, split)) + lower(locator.slice(split))
}

#let format-location-codes(shigunku, locator) = {
  let codes = ()
  if present(shigunku) { codes.push(format-shigunku(shigunku)) }
  if present(locator) { codes.push(format-locator(locator)) }
  if codes.len() > 0 { codes.join(" / ") }
}

#let station-fields(
  operator: none,
  operator-call: none,
  location: none,
  shigunku: none,
  locator: none,
  size: 8pt,
  value-size: 1.2em,
  call-size: 1em + 1.5pt,
  codes-size: 0.8em,
  gap: 3.5mm,
) = {
  let value(v, fit: true, header: none) = layout(area => {
    let lines = if type(v) == content { (v,) } else if present(v) { str(v).split("\n") } else { ("",) }
    let rows = lines.map(l => {
      let body = text(..data-font, size: value-size, if l == "" { hide[X] } else { l })
      if fit { fit-width(body, area.width) } else { body }
    })
    if header != none {
      rows.insert(0, text(..data-font, size: value-size, text(size: codes-size, header)))
    }
    rows.join(linebreak())
  })

  set text(size: size)

  grid(
    columns: (field-label-width, 1fr),
    column-gutter: 1.5mm,
    row-gutter: gap,
    align: left + horizon,
    [Op.], value(format-operator(operator, operator-call, call-size: call-size)),
    [QTH], value(location, fit: false, header: format-location-codes(shigunku, locator)),
  )
}

#let closing(body: [TNX FB QSO.], size: 10pt) = text(size: size, overhang: false, body)

#let remarks-field(
  remarks: none,
  lines: 2,
  trailer: none,
  size: 8pt,
  value-size: 1.2em,
  row-height: 5mm,
  line: 0.5pt,
) = {
  let texts = if present(remarks) { str(remarks).split("\n") } else { () }
  assert(texts.len() <= lines, message: "remarks has more lines than the field")

  set text(size: size)

  let row(i) = {
    let underline = blank-line(
      if i < texts.len() { text(..data-font, size: value-size, texts.at(i)) },
      width: 100%,
      alignment: left,
      line: line,
    )
    let label = if i == 0 [Rmks.]
    if i == lines - 1 and trailer != none {
      (label, underline, pad(left: 2mm, trailer))
    } else {
      (label, grid.cell(colspan: 2, underline))
    }
  }

  grid(
    columns: (field-label-width, 1fr, auto),
    column-gutter: 1.5mm,
    rows: row-height,
    align: bottom,
    ..range(lines).map(row).flatten(),
  )
}

#let qsl-status-cells(received, qsl-no, split, total, label-size, status-size, strike-line) = {
  let mark(body, struck) = if struck { strike(stroke: strike-line, body) } else { body }
  (
    table.cell(colspan: split, text(..label-font, size: status-size)[
      #mark([PSE], received == true) #h(0.8em) QSL #h(0.8em) #mark([TNX], received == false)
    ]),
    table.cell(colspan: total - split, align: left + horizon, grid(
      columns: (auto, 1fr),
      align: horizon,
      text(..label-font, size: label-size)[QSL No.],
      align(center, if qsl-no != none { text(..value-font, str(qsl-no)) }),
    )),
  )
}

#let report-table(
  entries: (),
  rows: 1,
  row-height: 7mm,
  label-size: 7pt,
  value-size: 10pt,
  status: true,
  received: none,
  qsl-no: none,
  status-size: 9pt,
  strike-line: 1pt,
  inset: 1.5mm,
  line: 0.5pt,
) = layout(size => {
  let natural = report-columns.map(c => (
    measure(text(size: value-size, format-value(c.key, report-sample))).width
  ))
  let room = size.width - 2 * inset * report-columns.len()
  let scale = calc.min(1, 0.97 * room / natural.sum())
  let widths = natural.map(w => w * scale + 2 * inset)
  let total = widths.sum()
  let count = calc.max(rows, entries.len())
  let split = report-columns.position(c => c.key == "report")

  show table.cell.where(y: 0): set text(..label-font, size: label-size)
  set text(size: value-size * scale)

  table(
    columns: widths.map(w => w / total * 1fr),
    rows: (auto, ..((row-height,) * (count + int(status)))),
    inset: inset,
    align: center + horizon,
    stroke: line,
    table.header(..report-columns.map(c => c.label)),
    ..range(count)
      .map(i => {
        let entry = entries.at(i, default: (:))
        report-columns.map(c => format-value(c.key, entry))
      })
      .flatten(),
    ..if status { qsl-status-cells(received, qsl-no, split, report-columns.len(), label-size, status-size, strike-line) },
  )
})
