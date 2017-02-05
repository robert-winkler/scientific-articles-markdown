--
-- cito.lua
--
-- Copyright (c) 2017 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the ISC license. See LICENSE for details.

local _version = "0.0.1"

local supported_properties = {
  "agrees_with",
  "citation",
  "cites",
  "cites_as_authority",
  "cites_as_data_source",
  "cites_as_evidence",
  "cites_as_metadata_document",
  "includes_excerpt_from",
  "includes_qutation_from",
  "uses_method_in",
}
local cito_properties = {}
for i = 1, #supported_properties do
  cito_properties[supported_properties[i]] = supported_properties[i]
end

local generic_cito_property = "citation"

local function cito_components(cit)
  local pattern = "(.+):(.+)"
  local cito_prop = cit:gsub(pattern, "%1")
  if cito_properties[cito_prop] then
    return cito_properties[cito_prop], cit:gsub(pattern, "%2")
  else
    return generic_cito_property, cit
  end
end

return {
  _version = _version,
  generic_cito_property = generic_cito_property,
  cito_properties = cito_properties,
  cito_components = cito_components,
}

