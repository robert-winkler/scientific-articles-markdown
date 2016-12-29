panlunatic = require("panlunatic")
setmetatable(_G, {__index = panlunatic})

local abstract = {}
local in_abstract = false

function Doc(body, metadata, variables)
  -- Fragile, handle with care.  Order matters.
  metadata.author = add_indices(authors(metadata))
  metadata.institute = add_indices(as_names(list_institutes(metadata.author)))
  set_affiliation_indices(metadata.author, metadata.institute)
  if next(abstract) ~= nil then
    metadata.abstract = abstract
  else
    metadata.abstract = panlunatic.Str("Not available")
  end
  return panlunatic.Doc(body, metadata, variables)
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


function as_names(strings)
  local objects = {}
  for _, str in ipairs(strings) do
    table.insert(objects, {name = str})
  end
  return objects
end

-- Add indices to entries
function add_indices(objects)
  for i, obj in ipairs(objects) do
    obj.index = i
  end
  return objects
end

-- author objects
function authors(metadata)
  local authors = {}
  for _, author in ipairs(metadata.author) do
    if type(author) == "string" then
      author = {name = author}
    end

    local institute = names(author.institute)
    if #institute > 0 then
      author.institute = institute
    end
    table.insert(authors, author)
  end
  return authors
end

function names(objects)
  -- FIXME: warn when no name could be found
  if type(objects) == "string" then return {objects} end
  if type(objects) ~= "table" then return {} end
  if objects.name then return {objects.name} end
  local res = {}
  for _, obj in ipairs(objects) do
    concat_table(res, names(obj))
  end
  return res
end

function concat_table(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

function set_affiliation_indices(authors, institutes)
  local affiliations = {}
  function institute_index(needle)
    for _, institute in pairs(institutes) do
      if is_equal(needle, institute.name) then
        return institute.index
      end
    end
    error("Could not find instititute.  This should never happen.")
  end

  for ia, author in ipairs(authors) do
    author.institute_indices = {}
    for ii, institute in ipairs(author.institute) do
      table.insert(author.institute_indices, institute_index(institute))
    end
  end
  return authors
end

function list_institutes(authors)
  local institutes = {}
  function add_institute(institute)
    for _, inst in ipairs(institutes) do
      if is_equal(inst, institute) then
        return
      end
    end
    table.insert(institutes, institute)
  end

  for _, author in ipairs(authors) do
    if author.institute and next(author.institute) ~= nil then
      for _, institute in ipairs(author.institute) do
        add_institute(institute)
      end
    end
  end
  return institutes
end

function is_equal(x, y)
  local tx = type(x)
  local ty = type(y)
  if tx ~= "table" and ty ~= "table" then return x == y end
  if tx ~= ty then return false end
  if x == y then return true end
  if not contains(x, y) then return false end
  if not contains(y, x) then return false end
  return true
end

function contains(x, y)
  for kx, vx in pairs(x) do
    local vy = y[k1]
    if vy == nil or not contains(vx, vy) then return false end
  end
end
