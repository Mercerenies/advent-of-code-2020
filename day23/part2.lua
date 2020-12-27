
-- So the approach we used in Part 1 is *definitely* not going to
-- scale. I have an idea with linked lists. Here we go.

local Node = {}

function Node.new(value)
  local new = {value = value, next_clockwise = nil, next_numerical = nil}
  setmetatable(new, {__index = Node})
  return new
end

function Node:remove_following()
  local next = self.next_clockwise
  self.next_clockwise = next.next_clockwise
  next.next_clockwise = nil
  return next
end

function Node:insert_after_self(other)
  local next = self.next_clockwise
  self.next_clockwise = other
  other.next_clockwise = next
end

function Node:find_present_predecessor()
  -- The immediate numerical predecessor may not be in the cycle
  -- currently (i.e. if we just removed it), so we may have to
  -- traverse a bit to find it.
  local curr = self.next_numerical
  while not curr.next_clockwise do
    curr = curr.next_numerical
  end
  return curr
end

function normalize(idx, len)
  return (idx - 1) % len + 1
end

function run_game_step(head)
  -- Remove three nodes
  local removed = {}
  for _ = 1, 3 do
    table.insert(removed, head:remove_following())
  end
  -- Find the place to put them
  local target = head:find_present_predecessor()
  -- Then put them there
  for i = 1, 3 do
    target:insert_after_self(removed[i])
    target = removed[i]
  end
  return head.next_clockwise
end

local input = {6, 5, 3, 4, 2, 7, 9, 1, 8}
for i = 10, 1000000 do
  table.insert(input, i)
end

-- Create several empty nodes
local nodes = {}
for i = 1, #input do
  local new = Node.new(i)
  table.insert(nodes, new)
end

-- Link up the nodes pointers
nodes[1].next_numerical = nodes[#nodes]
for i = 2, #nodes do
  nodes[i].next_numerical = nodes[i - 1]
end

-- Link up the clockwise pointers
for i = 1, #nodes do
  local curr = input[i]
  local next = input[normalize(i + 1, #input)]
  nodes[curr].next_clockwise = nodes[next]
end

-- Now run the game
local head = nodes[input[1]]
local one = nodes[1]
for _ = 1, 10000000 do
  head = run_game_step(head)
end

print(one.next_clockwise.value * one.next_clockwise.next_clockwise.value)
