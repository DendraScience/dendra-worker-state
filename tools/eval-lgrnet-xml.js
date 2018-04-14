const fs = require('fs')
const convert = require('xml-js')
const jsonata = require('jsonata')

const exprStr = [
  "`lgrnet-config`.`data-brokers`.`data-broker` ~> |*|{",
  "  'station': _attributes.name,",
  "  'tables': $filter(table._attributes.name, function($v) {",
  "    $not($v in ['_Settings', 'DataTableInfo', 'Public', 'Status'])",
  "  })",
  "},['_attributes', 'table']|"
].join('\n')

const expr = jsonata(exprStr)

function evalXml (f) {
  const xml = fs.readFileSync(`${f}.xml`, 'utf8')
  const json = convert.xml2json(xml, {
    compact: true,
    spaces: 2
  })

  fs.writeFileSync(`${f}.xml.json`, json, {
    encoding: 'utf8'
  })

  const res = expr.evaluate(JSON.parse(json))

  fs.writeFileSync(`${f}.res.json`, JSON.stringify(res), {
    encoding: 'utf8'
  })

  const sources = []

  res.forEach(obj => {
    const tables = Array.isArray(obj.tables) ? obj.tables : [obj.tables]

    tables.forEach(table => {
      sources.push({
        "station": obj.station,
        "table": table
      })
    })
  })

  fs.writeFileSync(`${f}.sources.json`, JSON.stringify(sources), {
    encoding: 'utf8'
  })
}

evalXml('CsiLgrNet_erczo')
evalXml('CsiLgrNet_ucnrs')
