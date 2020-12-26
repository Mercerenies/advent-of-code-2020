
# I am now eating my words :)

import re
from collections import defaultdict
from itertools import *

IMAGE_SIZE = 12
CELL_SIZE = 10
COLLAGE_SIZE = IMAGE_SIZE * (CELL_SIZE - 2)

class Orientable:

    def all_orientations(self):
        r = self
        for _j in range(2):
            for _i in range(4):
                yield r
                r = r.rotate_right()
            r = r.flip()

class Tile(Orientable):

    def __init__(self, tile_id, body):
        self.tile_id = tile_id
        self.body = body

    def __getitem__(self, idx):
        return self.body[idx[0]][idx[1]]

    def sides(self):
        return [self.top_side, self.bottom_side, self.left_side, self.right_side]

    @property
    def top_side(self):
        return Side(self.body[0])

    @property
    def bottom_side(self):
        return Side(self.body[-1])

    @property
    def left_side(self):
        return Side(''.join(map(lambda x: x[0], self.body)))

    @property
    def right_side(self):
        return Side(''.join(map(lambda x: x[-1], self.body)))

    def flip(self):
        new_body = list(reversed(self.body))
        return Tile(self.tile_id, new_body)

    def rotate_right(self, n=1):
        if n == 0:
            return self
        else:
            new_body = [''.join(self[CELL_SIZE-j-1, i] for j in range(CELL_SIZE)) for i in range(CELL_SIZE)]
            return Tile(self.tile_id, new_body).rotate_right(n - 1)

    def __str__(self):
        return '\n'.join(self.body)

    def __hash__(self):
        return hash((self.tile_id, tuple(self.body)))

    def __eq__(self, other):
        return self.tile_id == other.tile_id and self.body == other.body

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

class CollageLike(Orientable):

    def flip(self):
        return CollageFlipView(self)

    def rotate_right(self, n=1):
        if n == 0:
            return self
        else:
            return CollageRotateRightView(self).rotate_right(n - 1)

class Collage(CollageLike):

    def __init__(self, picture):
        self.picture = picture

    def __getitem__(self, idx):
        y, x = idx
        # -2 to remove the borders
        tile_y, tile_x = y // (CELL_SIZE-2), x // (CELL_SIZE-2)
        cell_y, cell_x = y % (CELL_SIZE-2), x % (CELL_SIZE-2)
        return self.picture[tile_y][tile_x][cell_y+1, cell_x+1]

# Transform the collage without actually allocating any new lists
class CollageRotateRightView(CollageLike):

    def __init__(self, collage):
        self.collage = collage

    def __getitem__(self, idx):
        y, x = idx
        y1 = COLLAGE_SIZE - x - 1
        x1 = y
        return self.collage[y1, x1]

class CollageFlipView(CollageLike):

    def __init__(self, collage):
        self.collage = collage

    def __getitem__(self, idx):
        y, x = idx
        return self.collage[COLLAGE_SIZE - y - 1, x]

def all_orientations(ts):
    return chain.from_iterable(map(Tile.all_orientations, tiles))

SEA_MONSTER = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ",
]
SEA_MONSTER_WIDTH = len(SEA_MONSTER[0])
SEA_MONSTER_HEIGHT = len(SEA_MONSTER)

def has_sea_monster_at(collage, y, x):
    for j in range(SEA_MONSTER_HEIGHT):
        for i in range(SEA_MONSTER_WIDTH):
            if SEA_MONSTER[j][i] == '#' and collage[y + j, x + i] != '#':
                return False
    return True

def has_sea_monster(collage):
    for y in range(COLLAGE_SIZE - SEA_MONSTER_HEIGHT):
        for x in range(COLLAGE_SIZE - SEA_MONSTER_WIDTH):
            if has_sea_monster_at(collage, y, x):
                return True
    return False

def mark_sea_monsters(collage, sea_monster_cells):
    for y in range(COLLAGE_SIZE - SEA_MONSTER_HEIGHT):
        for x in range(COLLAGE_SIZE - SEA_MONSTER_WIDTH):
            if has_sea_monster_at(collage, y, x):
                for j in range(SEA_MONSTER_HEIGHT):
                    for i in range(SEA_MONSTER_WIDTH):
                        if SEA_MONSTER[j][i] == '#':
                            sea_monster_cells[y+j][x+i] = True

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

# Make the full picture
used_orientations = set()
picture = [[None for i in range(IMAGE_SIZE)] for j in range(IMAGE_SIZE)]

# Find a corner for the top-left
for tile in all_orientations(tiles):
    if tile.tile_id in used_orientations:
        continue
    if sides[tile.left_side] == sides[tile.top_side] == 1:
        picture[0][0] = tile
        used_orientations.add(tile.tile_id)
        break

# First row
for i in range(1, IMAGE_SIZE):
    to_left = picture[0][i-1]
    for tile in all_orientations(tiles):
        if tile.tile_id in used_orientations:
            continue
        if tile.left_side.string == to_left.right_side.string and sides[tile.top_side] == 1:
            picture[0][i] = tile
            used_orientations.add(tile.tile_id)
            break

# Remaining rows
for j in range(1, IMAGE_SIZE):
    # First column
    above = picture[j-1][0]
    for tile in all_orientations(tiles):
        if tile.tile_id in used_orientations:
            continue
        if sides[tile.left_side] == 1 and tile.top_side.string == above.bottom_side.string:
            picture[j][0] = tile
            used_orientations.add(tile.tile_id)
            break
    # Rest of columns
    for i in range(1, IMAGE_SIZE):
        above = picture[j-1][i]
        to_left = picture[j][i-1]
        for tile in all_orientations(tiles):
            if tile.tile_id in used_orientations:
                continue
            if tile.left_side.string == to_left.right_side.string and tile.top_side.string == above.bottom_side.string:
                picture[j][i] = tile
                used_orientations.add(tile.tile_id)
                break

collage = Collage(picture)
sea_monster_cells = [[False for i in range(COLLAGE_SIZE)] for j in range(COLLAGE_SIZE)]

# Orient the image correctly
oriented_collage = None
for c in collage.all_orientations():
    if has_sea_monster(c):
        oriented_collage = c
        break

# Now find and mark all sea monsters
mark_sea_monsters(collage, sea_monster_cells)

# Then count non- sea monster hash signs
count = 0
for j in range(COLLAGE_SIZE):
    for i in range(COLLAGE_SIZE):
        if collage[j, i] == '#' and not sea_monster_cells[j][i]:
            count += 1
print(count)
