
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
  int smallest_x;
  int largest_x;
  int smallest_y;
  int largest_y;
  std::unordered_map<Pos, Color> tiles;
public:

  TileFloor()
    : black_tiles(0), smallest_x(0), largest_x(0), smallest_y(0), largest_y(0), tiles() {}

  Color get_color(Pos pos) {
    return tiles[pos];
  }

  void set_color(Pos pos, Color color) {
    smallest_x = std::min(smallest_x, pos.x);
    largest_x = std::max(largest_x, pos.x);
    smallest_y = std::min(smallest_y, pos.y);
    largest_y = std::max(largest_y, pos.y);
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

  int get_smallest_x() const {
    return smallest_x;
  }

  int get_largest_x() const {
    return largest_x;
  }

  int get_smallest_y() const {
    return smallest_y;
  }

  int get_largest_y() const {
    return largest_y;
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

std::vector<Pos> adjacent(Pos pos) {
  static std::vector<Dir> directions { Dir::E, Dir::SE, Dir::SW, Dir::W, Dir::NW, Dir::NE };
  std::vector<Pos> result;
  for (Dir dir : directions) {
    result.push_back(move(pos, dir));
  }
  return result;
}

int count_adjacent_black(TileFloor& floor, Pos pos) {
  int count = 0;
  for (Pos p : adjacent(pos)) {
    if (floor.get_color(p) == Color::Black) {
      count += 1;
    }
  }
  return count;
}

void evaluate_one_day(TileFloor& floor) {
  int smallest_x = floor.get_smallest_x();
  int smallest_y = floor.get_smallest_y();
  int largest_x = floor.get_largest_x();
  int largest_y = floor.get_largest_y();

  std::vector<Pos> to_be_flipped;
  for (int y = smallest_y - 1; y <= largest_y + 1; y++) {
    for (int x = smallest_x - 1; x <= largest_x + 1; x++) {
      int adja = count_adjacent_black(floor, Pos(y, x));
      if (floor.get_color(Pos(y, x)) == Color::Black) {
        if ((adja == 0) || (adja > 2))
          to_be_flipped.push_back(Pos(y, x));
      } else {
        if (adja == 2)
          to_be_flipped.push_back(Pos(y, x));
      }
    }
  }

  for (Pos p : to_be_flipped) {
    floor.flip_color(p);
  }

}

void debug_print(TileFloor& floor) {
  int smallest_x = floor.get_smallest_x();
  int smallest_y = floor.get_smallest_y();
  int largest_x = floor.get_largest_x();
  int largest_y = floor.get_largest_y();

  std::vector<Pos> to_be_flipped;
  for (int y = smallest_y; y <= largest_y; y++) {
    for (int x = smallest_x; x <= largest_x; x++) {
      if ((x == 0) && (y == 0))
        std::cout << ((floor.get_color(Pos(y, x)) == Color::Black) ? "B " : "W ");
      else
        std::cout << ((floor.get_color(Pos(y, x)) == Color::Black) ? "b " : "w ");
    }
    std::cout << std::endl;
  }
}

int main() {
  auto lines = lines_of_file("input.txt");
  std::vector< std::vector<Dir> > dirs { lines.size() };
  std::transform(lines.begin(), lines.end(), dirs.begin(), tokenize);

  TileFloor floor;

  // Initialization
  for (const auto& line : dirs) {
    Pos pos = move(Pos(), line.begin(), line.end());
    floor.flip_color(pos);
  }

  for (int i = 0; i < 100; i++) {
    evaluate_one_day(floor);
  }
  std::cout << floor.get_black_tiles() << std::endl;

  return 0;
}
