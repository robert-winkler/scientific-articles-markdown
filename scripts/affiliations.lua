panlunatic = require("panlunatic")
panmeta = require("panmeta")
setmetatable(_G, {__index = panlunatic})

local abstract = {}
local in_abstract = false

function Doc(body, meta, variables)
  -- Fragile, handle with care.  Order matters.
  meta.author = panmeta.add_indices(panmeta.authors(meta))
  meta.institute = panmeta.add_indices(
    panmeta.as_names(panmeta.list_institutes(meta.author)))
  panmeta.set_affiliation_indices(meta.author, meta.institute)
  if next(abstract) ~= nil then
    meta.abstract = abstract
  else
    meta.abstract = panlunatic.Str("Not available")
  end
  return panlunatic.Doc(body, meta, variables)
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
