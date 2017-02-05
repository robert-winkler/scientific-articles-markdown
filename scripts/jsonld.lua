--
-- jsonld.lua
--
-- Copyright (c) 2017 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the ISC license. See LICENSE for details.

local _version = "0.0.1"
local json = require "dkjson"
local cito = require "cito"
local panmeta = require "panmeta"

panmeta.options.json_values = false

local bibliography = nil
local citation_ids = {}
local citations_by_property = {}

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

local function bibliography(bibfilename)
  local bibfile = io.popen("pandoc-citeproc --bib2json " .. bibfilename, "r")
  local jsonstr = bibfile:read("*a")
  bibfile:close()
  return json.decode(jsonstr)
end

local function Cito (bibfile)
  local bibjson = bibliography(bibfile)
  function find_citation(id)
    -- sloooow
    for i = 1, #bibjson do
      if bibjson[i].id == id then
        return bibjson[i]
      end
    end
  end

  local res = {}
  local bibentry, citation_ld
  for citation_type, typed_citation_ids in pairs(citations_by_property) do
    for i = 1, #typed_citation_ids do
      bibentry = find_citation(typed_citation_ids[i])
      if bibentry and bibentry.DOI then
        citation_ld = {
          ["@id"] = "http://dx.doi.org/" .. bibentry.DOI
        }
        cito_type_str = "cito:" .. citation_type
        if not res[cito_type_str] then
          res[cito_type_str] = {}
        end
        table.insert(res[cito_type_str], citation_ld)
      end
    end
  end
  return res
end

local function Citations (bibfile)
  local bibjson = bibliography(bibfile)
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
      ["@context"] = {
        ["@vocab"]    = "http://schema.org/",
        ["title"]     = "headline",
        ["page"]      = "pagination",
        ["date"]      = "datePublished",
        ["publisher"] = "publisher",
        ["author"]    = "author",
      },
      ["@type"]     = type,
      ["@id"]       = record.DOI and ("http://dx.doi.org/" .. record.DOI),
      ["title"]     = record.title,
      ["author"]    = Authors(authors),
      ["date"]      = record.issued and
        record.issued["date-parts"] and
        table.concat(record.issued["date-parts"][1], "-"),
      ["publisher"] = record.publisher and
        { ["@type"] = "Organization", ["name"] = record.publisher },
      ["page"]      = record.page,
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
  local authors = panmeta.canonicalize_authors(meta.author)
  local accessible_for_free
  if type(meta.accessible_for_free) == "boolean" then
    accessible_for_free = meta.accessible_for_free
  else
    accessible_for_free = true
  end
  local context = {
    ["@vocab"]    = "http://schema.org/",
    ["cito"]      = "http://purl.org/spar/cito/",
    ["author"]    = "author",
    ["name"]      = "name",
    ["title"]     = "headline",
    ["subtitle"]  = "alternativeTitle",
    ["publisher"] = "publisher",
    ["date"]      = "datePublished",
    ["isFree"]    = "isAccessibleForFree",
    ["image"]     = "image",
    ["citation"]  = "citation",
  }

  local res = {
    ["@context"]  = context,
    ["@type"]     = "ScholarlyArticle",
    ["author"]    = Authors(authors),
    ["name"]      = meta.title,
    ["title"]     = meta.title,
    ["subtitle"]  = meta.subtitle,
    ["date"]      = meta.date or os.date("%Y-%m-%d"),
    -- ["image"]     = meta.image or default_image,
    ["isFree"]    = accessible_for_free,
    ["citation"]  = Citations(meta.bibliography),
  }
  for k, v in pairs(Cito(meta.bibliography)) do
    res[k] = v
  end
  return json.encode(res)
end

------- Inlines -------
function Cite(s, cs)
  local cito_prop, cit_id
  for i = 1, #cs do
    cito_prop, cit_id = cito.cito_components(cs[i].citationId)
    citation_ids[cit_id] = true
    if not citations_by_property[cito_prop] then
      citations_by_property[cito_prop] = {}
    end
    table.insert(citations_by_property[cito_prop], cit_id)
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

