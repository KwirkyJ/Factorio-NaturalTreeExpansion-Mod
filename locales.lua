---Object-like structure for the storing and and random-access of
---"Chunk" positions.

local locales_has, locales_get_count, locales_add, locales_get_random

local function locales_tostr (L)
    local t = {}
    for i=1, L._n do
        local loc = L._flat[i]
        if i ==1 then
            t[i] = "("..loc.x..", "..loc.y..")"
        else
            t[i] = ", ("..loc.x..", "..loc.y..")"
        end
    end
    return table.concat (t)
end

---Create new locales "object" 
---@return Locales table-object-structure
local function init_locales ()
    local L = {_n = 0, 
               _flat = {},
               add = locales_add,
               get_random = locales_get_random,
               get_count = locales_get_count,
               has = locales_has,
              }
    setmetatable (L, {__tostring = locales_tostr})
    return L
end

--[[
---Create a new table where the chunks are sorted, least-x, least-y first
---Is expensive at present, O(x^2), but should not be called frequently
---@param T table of Chunks ({{x=n, y=m}}, e.g.)
---@return Table
local function sort_chunks (T)
    local sorted = {}
    local chunk, added
    for _=1, #T do
        added, chunk = false, table.remove (T)
        for j=1, #sorted do
            if sorted[j] and
               sorted[j].x > chunk.x 
            then
                table.insert (sorted, j, chunk)
                added = true
                break
            elseif sorted[j] and
                   sorted[j].x == chunk.x and 
                   sorted[j].y > chunk.y 
            then
                table.insert (sorted, j, chunk)
                added = true
                break
            end
        end
        if not added then
            table.insert (sorted, chunk)
        end
    end
    return sorted
end
--]]

---Add a location to the structure
---@param loc e.g., {x=0, y=32}
locales_add = function (self, loc)
    local row, x, y = self[loc.x], loc.x, loc.y
    if row then
        row[y] = true
    else
        self[x] = {[y] = true}
    end
    self._n = self._n + 1
    self._flat[self._n] = {x = x, y = y}
--    self._flat = sort_chunks (self._flat)
end

---Get count of localities in structure
---@return number (integer)
locales_get_count = function (self)
    return self._n
end

---Get a random locale in the structure
---@return nil iff structure is empty; 
---        else a table {x=number, y=number}
locales_get_random = function (self)
    if self._n > 0 then
        return self._flat[math.random (self._n)]
    end
end

---Check whether structure has (contains) a locale
---@param loc e.g., {x=0, y=32}
---@return nil iff not in structure;
---        else true
locales_has = function (self, loc)
    if not self[loc.x] then 
        return nil 
    else
        return self[loc.x][loc.y]
    end
end

return {init_locales = init_locales,
       }

