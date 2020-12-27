
-- Note: I'll store the GameState in such a way that the current cup
-- is always at the front.

local GameState = {}

function GameState.new(cups)
  local new = {_cups = copytable(cups)}
  setmetatable(new, {__index = GameState})
  return new
end

function GameState:destination_cup_index()
  local target_cup_id = self._cups[1]
  local destination_index = nil
  while not destination_index do
    target_cup_id = target_cup_id - 1
    if target_cup_id < 1 then
      target_cup_id = 9
    end
    destination_index = indexof(self._cups, target_cup_id)
  end
  return destination_index
end

function GameState:run_once()
  local removed = {}
  local cup_count = #self._cups
  for _ = 2, 4 do
    table.insert(removed, table.remove(self._cups, 2))
  end
  local destination_index = self:destination_cup_index()
  for i = 1, 3 do
    table.insert(self._cups, destination_index + i, removed[i])
  end
  self:rotate()
end

function GameState:rotate()
  local old_current = table.remove(self._cups, 1)
  table.insert(self._cups, old_current)
end

function GameState:ordering_after_one()
  local one_index = indexof(self._cups, 1)
  local result = 0
  for i = 1, #self._cups - 1 do
    local idx = (one_index + i - 1) % #self._cups + 1
    result = result * 10 + self._cups[idx]
  end
  return result
end

function indexof(table, value)
  for k, v in ipairs(table) do
    if v == value then
      return k
    end
  end
  return nil
end

function copytable(arg)
  new_table = {}
  for k, v in ipairs(arg) do
    new_table[k] = v
  end
  return new_table
end

local input = {6, 5, 3, 4, 2, 7, 9, 1, 8}
local game = GameState.new(input)

for _ = 1, 100 do
  game:run_once()
end
print(game:ordering_after_one())
