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
  "includes_quotation_from",
  "obtains_background_from",
  "uses_method_in",
}
local cito_properties = {
  method = "uses_method_in",
  method_in = "uses_method_in",
  agree_with = "agrees_with",
  as_authority = "cites_as_authority",
  authority = "cites_as_authority",
  as_evidence = "cites_as_evidence",
  evidence = "cites_as_evidence",
  as_metadata_document = "cites_as_metadata_document",
  metadata_document = "cites_as_metadata_document",
  excerpt = "includes_excerpt_from",
  excerpt_from = "includes_excerpt_from",
  quotation_from = "includes_quotation_from",
  quotation = "includes_quotation_from",
  background = "obtains_background_from",
  background_from = "obtains_background_from",
}
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
