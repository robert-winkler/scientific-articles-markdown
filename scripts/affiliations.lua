panlunatic = require("panlunatic")
panmeta = require("panmeta")
cito = require "cito"
setmetatable(_G, {__index = panlunatic})

local abstract = {}
local in_abstract = false

function Doc(body, meta, variables)
  meta.author, meta.institute =
    panmeta.canonicalize_authors(meta.author, meta.institute)
  if next(abstract) ~= nil then
    meta.abstract = abstract
  else
    meta.abstract = panlunatic.Str("Not available")
  end
  return panlunatic.Doc(body, meta, variables)
end

function Cite (c, cs)
  for i = 1, #cs do
    _, cs[i].citationId = cito.cito_components(cs[i].citationId)
  end
  return panlunatic.Cite(c, cs)
end

function Header(lev, s, attr)
  in_abstract = (attr.id == "abstract")
  if in_abstract then
    return panlunatic.Plain(panlunatic.Str(' '))
  end
  return panlunatic.Header(lev, s, attr)
end

function Para(s)
  if in_abstract then
    table.insert(abstract, s)
    return panlunatic.Para(panlunatic.Str(' '))
  end
  return panlunatic.Para(s)
end
