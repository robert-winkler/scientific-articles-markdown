--
-- jsonld.lua
--
-- Copyright (c) 2017 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the ISC license. See LICENSE for details.

local _version = "0.0.1"
local json = require "dkjson"

local citation_ids = {}

local function Organizations(orgs)
  local affil_json = {}
  for i = 1, #orgs do
    affil_json[i] = {
      ["@type"] = "Organization",
      ["name"]  = orgs[i].name,
      ['url']   = orgs[i].url,
    }
  end
  return affil_json
end

local function Authors(authors)
  local authors_json = {}
  for i = 1, #authors do
    authors_json[i] = {
      ['@type']       = "Person",
      ["name"]        = authors[i].name,
      ["affiliation"] = authors[i].institute and Organizations(authors[i].institute),
      ['email']       = authors[i].email,
      ['url']         = authors[i].url,
    }
  end
  return authors_json
end

local function Citations (bibliography)
  local bibfile = io.popen("pandoc-citeproc --bib2json " .. bibliography, "r")
  local jsonstr = bibfile:read("*a")
  bibfile:close()
  local bibjson = json.decode(jsonstr)

  function find_citation(id)
    -- sloooow
    for i = 1, #bibjson do
      if bibjson[i].id == id then
        return bibjson[i]
      end
    end
  end

  function CitationSchema(record)
    local type
    if record.type == "report" then
      type = "Report"
    elseif record.type == "article-journal" then
      type = "ScholarlyArticle"
    else
      type = "Article"
    end

    local authors = {}
    if record.author then
      for i = 1, #record.author do
        local name = {
          record.author[i].family,
          record.author[i].given
        }
        authors[i] = {
          name = table.concat(name, ", ")
        }
      end
    end

    return {
      ["@type"] = type,
      ["headline"] = record.title,
      ["author"] = Authors(authors),
      ["datePublished"] = record.issued and
        record.issued["date-parts"] and
        table.concat(record.issued["date-parts"][1], "-"),
      ["publisher"] = record.publisher and
        { ["@type"] = "Organization", ["name"] = record.publisher },
      ["pagination"] = record.page,
    }
  end

  local res = {}
  for cit_id, _ in pairs(citation_ids) do
    local citation_record = find_citation(cit_id)
    if citation_record then
      res[#res + 1] = CitationSchema(citation_record)
    end
  end
  return res
end

function Doc(body, meta, vars)
  local default_image = "https://upload.wikimedia.org/wikipedia/commons/f/fa/Globe.svg"
  local authors = meta.author -- assume we are reading a canonicallized version
  local accessible_for_free
  if type(meta.accessible_for_free) == "boolean" then
    accessible_for_free = meta.accessible_for_free
  else
    accessible_for_free = true
  end
  local res = {
    ["@context"]         = "http://schema.org",
    ["@type"]            = "ScholarlyArticle",
    ["author"]           = Authors(authors),
    ["name"]             = meta.title,
    ["headline"]         = meta.title,
    ["alternativeTitle"] = meta.subtitle,
    ["datePublished"]    = meta.date or os.date("%Y-%m-%d"),
    ["image"]            = meta.image or default_image,
    ["isAccessibleForFree"] = accessible_for_free,
    ["citation"]         = Citations(meta.bibliography),
  }
  return json.encode(res)
end

------- Inlines -------
function Cite(s, cs)
  for i = 1, #cs do
    citation_ids[cs[i].citationId] = true
  end
  return s
end
function Code(s, attr)
  return s
end
function DisplayMath(s)
  return s
end
function DoubleQuoted(s)
  return '"' .. s .. '"'
end
function Emph(s)
  return s
end
function Image(s, src, tit, attr)
  return s
end
function InlineMath(s)
  return s
end
function LineBreak()
  return "\n"
end
function Link(s, src, tit, attr)
  return s
end
function Note(s)
  return ''
end
function RawInline(format, str)
  return ''
end
function SingleQuoted(s)
  return "'" .. s .. "'"
end
function SoftBreak()
  return " "
end
function Space()
  return " "
end
function Str(s)
  return s
end
function Strong(s)
  return s
end
function Strikeout(s)
  return s
end
function Superscript(s)
  return s
end
function Subscript(s)
  return s
end
function Span(s, attr)
  return s
end

------- Blocks -------
function BlockQuote(s)
  return '"' .. s .. '"'
end
function BulletList(items)
  return table.concat(items, ", ")
end
function CaptionedImage(src, tit, caption, attr)
  return tit
end
function CodeBlock(s, attr)
  return s
end
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer, k .. ": " .. v)
    end
  end
  return table.concat(buffer, '\n')
end
function Div(s, attr)
  return s
end
function Header(lev, s, attr)
  return s
end
function HorizontalRule()
  return ''
end
function LineBlock(ls)
  return table.concat(ls, "\n")
end
function OrderedList(items, num, sty, delim)
  return table.concat(items, "\n")
end
function Para(s)
  return s
end
function Plain(s)
  return s
end
function RawBlock(format, str)
  return ''
end
function Table(caption, aligns, widths, headers, rows)
  return caption
end

function Blocksep()
  return "\n\n"
end

local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)

