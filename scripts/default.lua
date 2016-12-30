panlunatic = require("panlunatic")
panmeta = require("panmeta")
setmetatable(_G, {__index = panlunatic})

local abstract = {}
local in_abstract = false

function Doc(body, meta, variables)
  local authors = panmeta.authors(meta)
  meta.author = {}
  for k, author in ipairs(authors) do
    if author.institute and author.institute[1] then
      local inst = panlunatic.Space()
        .. panlunatic.Str('(')
        .. author.institute[1]
        .. panlunatic.Str(')')
      meta.author[k] = author.name .. inst
    else
      meta.author[k] = author.name
    end
  end
  meta.institute = panmeta.list_institutes(authors)
  return panlunatic.Doc(body, meta, variables)
end
