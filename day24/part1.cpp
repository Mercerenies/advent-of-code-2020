
#include <algorithm>
#include <fstream>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <string>

// Here's how we'll be storing the hexagonal grid
//
//   (01)(03)(05)
// (00)(02)(04)
//   (11)(13)(15)
// (10)(12)(14)

enum class Dir {
  E, SE, SW, W, NW, NE
};

struct Pos {
  int y;
  int x;

  Pos() : y(0) , x(0) {}
  Pos(int y, int x) : y(y) , x(x) {}

};

namespace std {
  template<>
  struct hash<Pos> {
    size_t operator()(Pos pos) const {
      return std::hash<int>()(pos.y) ^ std::hash<int>()(pos.x);
    }
  };
}

enum class Color {
  White, Black
};

Color invert(Color c) {
  if (c == Color::White)
    return Color::Black;
  else
    return Color::White;
}

class TileFloor {
private:
  int black_tiles;
  std::unordered_map<Pos, Color> tiles;
public:

  TileFloor() : black_tiles(0), tiles() {}

  Color get_color(Pos pos) {
    return tiles[pos];
  }

  void set_color(Pos pos, Color color) {
    Color prev = get_color(pos);
    if (prev == Color::Black)
      --black_tiles;
    if (color == Color::Black)
      ++black_tiles;
    tiles[pos] = color;
  }

  void flip_color(Pos pos) {
    set_color(pos, invert(get_color(pos)));
  }

  int get_black_tiles() const {
    return black_tiles;
  }

};

bool operator==(Pos a, Pos b) {
  return (a.y == b.y) && (a.x == b.x);
}

bool operator!=(Pos a, Pos b) {
  return (a.y != b.y) || (a.x != b.x);
}

int mod(int a, int b) {
  return (a % b + b) % b;
}

Dir tokenize_next(const std::string& line, int& pos) {
  if (line[pos] == 's') {
    switch (line[pos + 1]) {
    case 'w':
      pos += 2;
      return Dir::SW;
    case 'e':
      pos += 2;
      return Dir::SE;
    }
  } else if (line[pos] == 'n') {
    switch (line[pos + 1]) {
    case 'w':
      pos += 2;
      return Dir::NW;
    case 'e':
      pos += 2;
      return Dir::NE;
    }
  } else {
    switch (line[pos]) {
    case 'w':
      pos += 1;
      return Dir::W;
    case 'e':
      pos += 1;
      return Dir::E;
    }
  }
  throw "Invalid input";
}

std::vector<Dir> tokenize(const std::string& line) {
  std::vector<Dir> result;
  int pos = 0;
  while (pos < line.size()) {
    result.push_back(tokenize_next(line, pos));
  }
  return result;
}

std::vector<std::string> lines_of_file(const char* filename) {
  std::vector<std::string> result;
  std::string tmp;
  std::ifstream file(filename);
  while (getline(file, tmp)) {
    result.push_back(tmp);
  }
  return result;
}

Pos move(Pos pos, Dir dir) {
  switch (dir) {
  case Dir::E:
    return Pos(pos.y, pos.x + 2);
  case Dir::SE:
    if (mod(pos.x, 2) == 0) {
      return Pos(pos.y + 1, pos.x + 1);
    } else {
      return Pos(pos.y, pos.x + 1);
    }
  case Dir::SW:
    if (mod(pos.x, 2) == 0) {
      return Pos(pos.y + 1, pos.x - 1);
    } else {
      return Pos(pos.y, pos.x - 1);
    }
  case Dir::W:
    return Pos(pos.y, pos.x - 2);
  case Dir::NW:
    if (mod(pos.x, 2) == 0) {
      return Pos(pos.y, pos.x - 1);
    } else {
      return Pos(pos.y - 1, pos.x - 1);
    }
  case Dir::NE:
    if (mod(pos.x, 2) == 0) {
      return Pos(pos.y, pos.x + 1);
    } else {
      return Pos(pos.y - 1, pos.x + 1);
    }
  }
  throw "Logic error in move()";
}

template <typename InputIterator>
Pos move(Pos pos, InputIterator begin, InputIterator end) {
  while (begin != end) {
    pos = move(pos, *begin);
    ++begin;
  }
  return pos;
}

int main() {
  auto lines = lines_of_file("input.txt");
  std::vector< std::vector<Dir> > dirs { lines.size() };
  std::transform(lines.begin(), lines.end(), dirs.begin(), tokenize);

  TileFloor floor;
  for (const auto& line : dirs) {
    Pos pos = move(Pos(), line.begin(), line.end());
    floor.flip_color(pos);
  }
  std::cout << floor.get_black_tiles() << std::endl;

  return 0;
}
