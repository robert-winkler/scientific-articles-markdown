-- Turn emphasized into strong text.
--
-- Invoke with:
--    pandoc -t emph2strong.lua [READ-OPTIONS] | pandoc -f json [WRITE-OPTIONS]

panluna = require("panlunatic")

function Emph(s)
  return panlunatic.Strong(s)
end

setmetatable(_G, {__index = panlunatic})
