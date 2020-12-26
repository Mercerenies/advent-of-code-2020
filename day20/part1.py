
# I may end up eating these words when I see Part 2. But for now, we
# don't actually need to calculate everything. All we need is the four
# corners. And corners can be identified as the nodes which have two
# sides incompatible with everything else.

import re
from collections import defaultdict

class Tile:

    def __init__(self, tile_id, body):
        self.tile_id = tile_id
        self.body = body

    def __getitem__(self, idx):
        return self.body[idx[0]][idx[1]]

    def sides(self):
        sides = []
        # Top
        sides.append(Side(self.body[0]))
        # Bottom
        sides.append(Side(self.body[-1]))
        # Left
        sides.append(Side(''.join(map(lambda x: x[0], self.body))))
        # Right
        sides.append(Side(''.join(map(lambda x: x[-1], self.body))))
        return sides

    @staticmethod
    def parse(f):
        tile_line = f.readline()
        if tile_line == "":
            # EOF
            return None
        match = re.compile(r'Tile (\d+):').match(tile_line)
        tile_id = int(match.group(1))

        body = []
        curr = f.readline()
        while curr != "\n":
            body.append(curr.rstrip())
            curr = f.readline()

        return Tile(tile_id, body)

class Side:

    def __init__(self, string):
        self.string = string

    def __str__(self):
        return self.string

    def __hash__(self):
        rev = ''.join(reversed(self.string))
        return hash(frozenset({self.string, rev}))

    def __eq__(self, other):
        oth_rev = ''.join(reversed(other.string))
        return self.string == other.string or self.string == oth_rev

tiles = []
with open("input.txt", "r") as f:
    tile = Tile.parse(f)
    while tile:
        tiles.append(tile)
        tile = Tile.parse(f)

# Take a note of all of the sides, considering orientation
sides = defaultdict(lambda: 0)
for tile in tiles:
    for side in tile.sides():
        sides[side] += 1

# Now look for corners
corner_product = 1
for tile in tiles:
    compatible_sides = 0
    for side in tile.sides():
        if sides[side] > 1:
            compatible_sides += 1
    if compatible_sides == 2:
        corner_product *= tile.tile_id
print(corner_product)
