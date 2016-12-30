-- Example script to unwrap div content.
--
-- Invoke with:
--    pandoc -t undiv.lua [READER-OPTIONS] | pandoc -f json [WRITER-OPTIONS]

panlunatic = require("panlunatic")

function Div(s, attr)
  -- `s` contains a JSON string representing the div's content.
  return s
end

setmetatable(_G, {__index = panlunatic})
