--
-- panlunatic.lua
--
-- Copyright (c) 2016 Albert Krewinkel
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the ISC license. See LICENSE for details.

local panlunatic = {_version = "0.1.1"}

local json = require("dkjson")

local function words(str)
  local t = {}
  local function helper(word)
    table.insert(t, word)
    return ""
  end
  if not str:gsub("%w+", helper):find("%S") then
    return t
  end
end

-- Helper function to convert an attributes table into json string
local function attributes(attr)
  classes = words(attr.class)
  kv = {}
  for k,v in pairs(attr) do
    if k ~= "id" and k ~= "class" then
      table.insert(kv, {k, v})
    end
  end
  return json.encode({attr.id, classes, kv})
end

local function type_table(str)
  return {t = str}
end

local function type_str(str)
  return json.encode(type_table(str))
end

-- Blocksep is used to separate block elements.
function panlunatic.Blocksep()
  return ","
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
function panlunatic.Doc(body, metadata, variables)
  -- New API format (post 1.18)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add('"blocks":[' .. body .. ']')
  add('"pandoc-api-version":[1,17,0,4]')
  add('"meta":' .. panlunatic.Meta(metadata))
  return "{" .. table.concat(buffer,',') .. '}\n'
end

-- Old API format (pre 1.18)
function panlunatic.OldDoc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add('[{"unMeta":')
  add(panlunatic.Meta(metadata))
  add('},[')
  add(body)
  add(']]\n')
  return table.concat(buffer)
end

-- FIXME: do proper version test
if os.getenv("PANDOC_VERSION") and os.getenv("PANDOC_VERSION") <= "1.17.2" then
  panlunatic.Doc = panlunatic.OldDoc
  type_table = function (str)
    return {t = str, c={}}
  end
end

-- Convert metadata table to JSON
function panlunatic.Meta(metadata)
  local buffer = {}
  for k, v in pairs(metadata) do
    if type(v) ~= "table" or next(v) ~= nil then
      table.insert(buffer, json.encode(k) .. ':' .. panlunatic.tometa(v))
    end
  end
  return '{' .. table.concat(buffer, ',') .. '}'
end

function panlunatic.tometa(data)
  local function is_list(v)
    if type(v) ~= "table" then return false end
    for k,_ in pairs(v) do
      if type(k) ~= "number" then
        return false
      end
    end
    return true
  end

  if data == nil then
    return nil
  elseif type(data) == 'number' then
    return '{"t":"MetaString","c":"' .. tostring(data) .. '"}'
  elseif type(data) == 'string' then
    return '{"t":"MetaInlines","c":[' .. data:sub(1, -2) .. ']}'
  elseif type(data) == "bool" then
    return '{"t":"MetaBoolean","c":' .. data .. '}'
  elseif type(data) == "table" and not next(data) then
    return nil
  elseif is_list(data) then
    local m = {}
    for _,v in ipairs(data) do
      table.insert(m, panlunatic.tometa(v))
    end
    return '{"t":"MetaList","c":[' .. table.concat(m, ',') .. ']}'
  else
    local m = {}
    for k,v in pairs(data) do
      table.insert(m, json.encode(k) .. ":" .. panlunatic.tometa(v))
    end
    return '{"t":"MetaMap","c":{' .. table.concat(m, ',') .. '}}'
  end
end


-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function panlunatic.Str(s)
  return json.encode({t = 'Str', c = s}) .. ","
end

function panlunatic.Space()
  return type_str('Space') .. ","
end

function panlunatic.SoftBreak()
  return type_str('SoftBreak') .. ","
end

function panlunatic.LineBreak()
  return type_str('LineBreak') .. ","
end

function panlunatic.Emph(s)
  return '{"t":"Emph","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.Strong(s)
  return '{"t":"Strong","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.Subscript(s)
  return '{"t":"Subscript","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.Superscript(s)
  return '{"t":"Superscript","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.SmallCaps(s)
  return '{"t":"SmallCaps","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.Strikeout(s)
  return '{"t":"Strikeout","c":[' .. s:sub(1, -2) .. ']},'
end

function panlunatic.Quoted(quote, s)
  return '{"t":"Quoted","c":[' .. type_str(quote) .. ',[' .. s:sub(1,-2) .. ']]},'
end

function panlunatic.SingleQuoted(s)
  return Quoted("SingleQuote", s)
end

function panlunatic.DoubleQuoted(s)
    return Quoted("DoubleQuote", s)
end

function panlunatic.Link(s, src, tit, attr)
  srctit = json.encode(src) .. ',' .. json.encode(tit)
  return '{"t":"Link","c":[' .. attributes(attr) .. ",[" .. s:sub(1, -2) .. '],['.. srctit .. ']]},'
end

function panlunatic.Image(s, src, tit, attr)
  srctit = json.encode(src) .. ',' .. json.encode(tit)
  return '{"t":"Image","c":[' .. attributes(attr) .. ",[" .. s:sub(1, -2) .. '],['.. srctit .. ']]},'
end

function panlunatic.Code(s, attr)
  return '{"t":"Code","c":[' .. attributes(attr) .. ',' .. json.encode(s) .. ']},'
end

function panlunatic.InlineMath(s)
  return '{"t":"Math","c":[' .. type_str("InlineMath") .. ',' .. json.encode(s) .. ']},'
end

function panlunatic.DisplayMath(s)
  return '{"t":"Math","c":[' .. type_str("InlineMath") .. ',' .. json.encode(s) .. ']},'
end

function panlunatic.Note(s)
  return '{"t":"Note","c":[' .. s .. ']},'
end

function panlunatic.Span(s, attr)
  return '{"t":"Span","c":[' .. attributes(attr) .. ",[" .. s:sub(1, -2) .. ']]},'
end

function panlunatic.RawInline(format, str)
  return '{"t":"RawInline","c":[' .. json.encode(format) .. ',' .. json.encode(str) .. ']},'
end

function panlunatic.Cite(s, cs)
  -- get properties in the correct table format for json encoding
  for _,cit in ipairs(cs) do
    cit.citationMode = type_table(cit.citationMode)
    cit.citationPrefix = panlunatic.decode('[' .. cit.citationPrefix .. ']')
    cit.citationSuffix = panlunatic.decode('[' .. cit.citationSuffix .. ']')
  end
  return '{"t":"Cite","c":[' .. json.encode(cs) .. ",[" .. s:sub(1, -2) .. ']]},'
end

function panlunatic.Plain(s)
  return '{"t":"Plain","c":[' .. s:sub(1, -2) .. ']}'
end

function panlunatic.Para(s)
  return '{"t":"Para","c":[' .. s:sub(1, -2) .. ']}'
end

-- lev is an integer, the header level.
function panlunatic.Header(lev, s, attr)
  return '{"t":"Header","c":[' .. lev .. "," .. attributes(attr) .. ',[' .. s:sub(1, -2) .. ']]}'
end

function panlunatic.BlockQuote(s)
  return '{"t":"BlockQuote","c":[' .. s .. ']}'
end

function panlunatic.HorizontalRule()
  return type_str("HorizontalRule")
end

function panlunatic.LineBlock(ls)
  lines = {}
  for _,l in ipairs(ls) do
    table.insert(lines, "[" .. l:sub(1, -2) .. "]")
  end
  return '{"t":"LineBlock","c":[' .. table.concat(lines, ',') .. ']}'
end

function panlunatic.CodeBlock(s, attr)
  return '{"t":"CodeBlock","c":[' .. attributes(attr) .. "," .. json.encode(s) .. ']}'
end

function panlunatic.BulletList(items)
  buffer = {}
  for _,item in ipairs(items) do
    table.insert(buffer, '[' .. item .. ']' )
  end
  return '{"t":"BulletList","c":[' .. table.concat(buffer, ',') .. ']}'
end

function panlunatic.OrderedList(items, num, sty, delim)
  item_strings = {}
  for _,item in ipairs(items) do
    table.insert(item_strings, '[' .. item .. ']')
  end
  listAttrs = {num, type_table(sty), type_table(delim)}
  return '{"t":"OrderedList","c":[' .. json.encode(listAttrs) ..
    ',[' .. table.concat(item_strings, ',') .. ']]}'
end

function panlunatic.DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer,"[[" .. k:sub(1, -2) .. "],[[" ..
                        table.concat(v,"],[") .. "]]]")
    end
  end
  return '{"t":"DefinitionList","c":[' .. table.concat(buffer, ',') .. "]}"
end

function panlunatic.CaptionedImage(src, tit, caption, attr)
  return Para(Image(caption, src, tit, attr):sub(1, -1))
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function panlunatic.Table(caption, aligns, widths, headers, rows)
  local content = {}
  local function add(s)
    table.insert(content, s)
  end

  local function row_string(cells)
    local res = {}
    for _,h in ipairs(cells) do
      table.insert(res, '[' .. h .. ']')
    end
    return '[' .. table.concat(res, ',') .. ']'
  end

  add('[' .. caption:sub(1, -2) .. ']')

  alignsTables = {}
  for _,align in ipairs(aligns) do
    table.insert(alignsTables, type_table(align))
  end
  add(json.encode(alignsTables))

  add(json.encode(widths))

  add(row_string(headers))

  row_strings = {}
  for _, row in ipairs(rows) do
    table.insert(row_strings, row_string(row))
  end
  add('[' .. table.concat(row_strings, ',') .. ']')

  return '{"t":"Table","c":[' .. table.concat(content, ',')  .. ']}'
end

function panlunatic.RawBlock(format, str)
  return '{"t":"RawBlock","c":[' .. json.encode(format) .. ',' .. json.encode(str) .. ']}'
end

function panlunatic.Div(s, attr)
  return '{"t":"Div","c":[' .. attributes(attr) .. ',[' .. s .. ']]}'
end


local inline_types = {
  "Cite",
  "Code",
  "DisplayMath",
  "DoubleQuoted",
  "Emph",
  "Image",
  "InlineMath",
  "LineBreak",
  "Link",
  "Note",
  "RawInline",
  "SingleQuoted",
  "SmallCaps",
  "SoftBreak",
  "Space",
  "Span",
  "Str",
  "Strikeout",
  "Strong",
  "Subscript",
  "Superscript"
}

local is_inline = (function ()
  local inline_set = {}
  for _,v in ipairs(inline_types) do
    inline_set[v] = true
  end
  return function(elem)
    return inline_set[elem.t]
  end
end)()

panlunatic.encode = function(elem)
  if is_inline(elem) then
    return json.encode(elem) .. ','
  end
  return json.encode(elem)
end

panlunatic.decode = function(s)
  if s:sub(-2, -1) == ',' then
    return json.decode(s:sub(1, -2))
  end
  return json.decode(s)
end

return panlunatic
