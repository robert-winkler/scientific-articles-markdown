local panmeta = {_version = "0.1.0"}
local panlunatic = require "panlunatic"

local options = {
  json_values = true
}

local MetaObjectList = {}
function MetaObjectList:new (item_class)
  local o = {item_class = item_class}
  setmetatable(o, self)
  self.__index = self
  return o
end
function MetaObjectList:init (raw_list)
  local meta_objects = {}
  setmetatable(meta_objects, self)
  self.__index = self
  if type(raw_list) == "table" then
    for i, raw_item in ipairs(raw_list) do
      meta_objects[#meta_objects + 1] = self.item_class:canonicalize(raw_item, i)
    end
    return meta_objects
  else
    meta_objects[1] = self.item_class:canonicalize(raw_list, 1)
    return meta_objects
  end
end
function MetaObjectList:map (fn)
  local res = {}
  for k, v in ipairs(self) do
    res[k] = fn(v)
  end
  return res
end
function MetaObjectList:each (fn)
  for k, v in pairs(self) do
    fn(k, v)
  end
end

local NamedObject = {}
function NamedObject:new (o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
function NamedObject:canonicalize (raw_item, index)
  local item = self:new{index = index}
  if type(raw_item) ~= "table" then
    item.name = tostring(raw_item)
    item.abbreviation = tostring(raw_item)
  elseif raw_item.name ~= nil then
    for k, v in pairs(raw_item) do
      item[k] = v
    end
  else
    raw_name, item_attributes = next(raw_item)
    if options.json_values then
      item.name = panlunatic.Str(tostring(raw_name))
      item.abbreviation = panlunatic.Str(tostring(raw_name))
    else
      item.name = raw_name
      item.abbreviation = raw_name
    end
    if type(item_attributes) ~= "table" then
      item.name = item_attributes
    else
      for k, v in pairs(item_attributes) do
        item[k] = v
      end
    end
  end
  return item
end

local Institute = NamedObject:new()
local Institutes = MetaObjectList:new(Institute)

local Author = NamedObject:new()
local Authors = MetaObjectList:new(Author)
function Authors:resolve_institutes (institutes)
  function find_by_abbreviation(index)
    for _, v in pairs(institutes) do
      if v.abbreviation == index then
        return v
      end
    end
  end
  for i, author in ipairs(self) do
    if author.institute ~= nil then
      local authinst
      if type(author.institute) == "string" or type(author.institute) == "number" then
        authinst = {author.institute}
      else
        authinst = author.institute
      end
      local res = Institutes:init{}
      for j, inst in ipairs(authinst) do
        res[#res + 1] =
          institutes[tonumber(inst)] or
          find_by_abbreviation(inst) or
          Institute:canonicalize(inst)
      end
      author.institute = res
    end
  end
end

--- Insert a named object into a list; if an object of the same name exists
-- already, add all properties only present in the new object to the existing
-- item.
function insertMergeUniqueName (list, namedObj)
  for _, obj in pairs(list) do
    if obj.name == namedObj.name then
      for k, v in pairs(namedObj) do
        obj[k] = obj[k] or v
      end
      return obj
    end
  end
  list[#list + 1] = namedObj
  return namedObj
end

local function canonicalize_authors(raw_authors, raw_institutes)
  local authors = Authors:init(raw_authors)
  local all_institutes = Institutes:init(raw_institutes)
  authors:resolve_institutes(all_institutes)

  -- ordered affiliations
  local affiliations = Institutes:init{}
  authors:each(function (_, author)
      if not author.institute then
        author.institute = {}
      end
      for i, authinst in ipairs(author.institute) do
        author.institute[i] = insertMergeUniqueName(affiliations, authinst)
      end
  end)
  -- add indices to affiliations
  affiliations:each(function (i, affl) affl.index = i end)
  -- set institute_indices for all authors
  authors:each(function (k, author)
      author.institute_indices = author.institute:map(
        function(inst) return inst.index end
      )
  end)
  return authors, affiliations
end

return {
  Authors = Authors,
  Institutes = Institutes,
  canonicalize_authors = canonicalize_authors,
  options = options,
}
