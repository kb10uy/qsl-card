#import "parts/jarl.typ": jarl-transfer-frame, jarl-frame-top, jarl-frame-right
#import "parts/report.typ": to-radio, report-table, instrument-fields, remarks-field, station-fields, closing
#import "parts/theme.typ": label-font

#let margin = 6mm

#let entries = if "data_json" in sys.inputs {
  json(sys.inputs.data_json)
} else {
  ((:),)
}

#set page(
  width: 100mm,
  height: 148mm,
  margin: margin,
)
#set text(..label-font, size: 10pt)

#for (i, entry) in entries.enumerate() {
  if i > 0 {
    pagebreak()
  }

  pad(
    top: jarl-frame-top - margin,
    right: jarl-frame-right - margin,
    align(right, jarl-transfer-frame(
      boxes: 8,
      callsign: entry.at("bureau_call", default: none),
      via: entry.at("bureau_via", default: false),
    )),
  )

  v(2mm)

  to-radio(callsign: entry.at("report_call", default: none))

  v(2mm)

  let report = (
    date: entry.at("report_date", default: none),
    time: entry.at("report_time", default: none),
    timezone: entry.at("report_timezone", default: none),
    report: entry.at("report_rst", default: none),
    freq: entry.at("report_freq", default: none),
    mode: entry.at("report_mode", default: none),
  )

  report-table(
    entries: (report,),
    received: entry.at("qsl_received", default: none),
    qsl-no: entry.at("qsl_number", default: none),
  )

  block(above: 1.5mm, instrument-fields(
    rig: entry.at("inst_rig", default: none),
    power: entry.at("inst_power", default: none),
    antenna: entry.at("inst_antenna", default: none),
    trailer: closing(),
  ))

  block(above: 1.5mm, remarks-field(remarks: entry.at("remarks", default: none)))

  block(above: 5mm, station-fields(
    operator: entry.at("op_operator", default: none),
    operator-call: entry.at("op_call", default: none),
    location: entry.at("op_location", default: none),
    shigunku: entry.at("op_jcx", default: none),
    locator: entry.at("op_grid", default: none),
  ))
}
