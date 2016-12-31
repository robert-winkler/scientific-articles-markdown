local panmeta = {_version = "0.1.0"}

local is_equal -- forward declaration

function panmeta.as_names(strings)
  local objects = {}
  for _, str in ipairs(strings) do
    table.insert(objects, {name = str})
  end
  return objects
end

-- Add indices to entries
function panmeta.add_indices(objects)
  for i, obj in ipairs(objects) do
    obj.index = i
  end
  return objects
end

-- author objects
function panmeta.authors(metadata)
  local authors = {}
  for _, author in ipairs(metadata.author) do
    if type(author) == "string" then
      author = {name = author}
    end

    local institute = panmeta.names(author.institute)
    if #institute > 0 then
      author.institute = institute
    end
    table.insert(authors, author)
  end
  return authors
end

function panmeta.names(objects)
  -- FIXME: warn when no name could be found
  if type(objects) == "string" then return {objects} end
  if type(objects) ~= "table" then return {} end
  if objects.name then return {objects.name} end
  local res = {}
  for _, obj in ipairs(objects) do
    panmeta.concat_table(res, names(obj))
  end
  return res
end

function panmeta.set_affiliation_indices(authors, institutes)
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

function panmeta.list_institutes(authors)
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

function panmeta.concat_table(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

is_equal = function (x, y)
  local tx = type(x)
  local ty = type(y)
  if tx ~= "table" and ty ~= "table" then return x == y end
  if tx ~= ty then return false end
  if x == y then return true end
  if not are_keys_equal(x, y) then return false end
  if not are_keys_equal(y, x) then return false end
  return true
end

local function are_keys_equal(x, y)
  for kx, vx in pairs(x) do
    local vy = y[k1]
    if vy == nil or not is_equal(vx, vy) then return false end
  end
end

return panmeta
