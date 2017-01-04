-- Use org-ref to output citations
--
-- Invoke with:
--    pandoc -t orgref.lua [READER-OPTIONS] | pandoc -f json [WRITER-OPTIONS]

panlunatic = require("panlunatic")

function Cite(s, cs)
  local res = {}
  for _, cit in ipairs(cs) do
    if cit.citationMode == "AuthorInText" then
      cite_type = "cite"
    elseif cit.citationMode == "NormalCitation" then
      cite_type = "citep"
    else -- cit.citationMode == "SuppressAuthor"
      cite_type = "citeyear"
    end
    local prefix = panlunatic.decode('[' .. cit.citationPrefix .. ']')
    local suffix = panlunatic.decode('[' .. cit.citationSuffix .. ']')
    if #prefix > 0 or #suffix > 0 then
      local prefix_str = inlines_list_to_str(prefix)
      local suffix_str = inlines_list_to_str(suffix)
      local preraw = panlunatic.RawInline('org', '[[' .. cite_type .. ':' .. cit.citationId .. '][')
      local midraw = panlunatic.RawInline('org', '::')
      local postraw = panlunatic.RawInline('org', ']]')
      table.insert(res, preraw .. prefix_str .. midraw .. suffix_str .. postraw)
    else
      table.insert(res, RawInline('org', cite_type .. ':' .. cit.citationId))
    end
  end
  return panlunatic.Cite(table.concat(res), cs)
end

function inlines_list_to_str(inlines)
  local res = {}
  for _, inline in ipairs(inlines) do
    table.insert(res, panlunatic.encode(inline))
  end
  return table.concat(res)
end

setmetatable(_G, {__index = panlunatic})
