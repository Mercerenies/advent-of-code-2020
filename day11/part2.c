
#include <stdio.h>
#include <stdlib.h>

static char* table;
static int width;
static int height;

void read_file() {
  FILE* file = fopen("input.txt", "r");

  // Check the size of the room
  int line_width = 0;
  int width = -1;
  int height = 0;
  while (1) {
    int code = fgetc(file);
    if (code == EOF) {
      break;
    } else if (code == '\n') {
      if (width < 0)
        width = line_width;
      height += 1;
    } else {
      line_width += 1;
    }
  }

  ::width = width;
  ::height = height;

  table = (char*)calloc(width * height, sizeof(char));
  fseek(file, 0, SEEK_SET);
  int idx = 0;
  while (1) {
    int code = fgetc(file);
    if (code == EOF) {
      break;
    } else if (code != '\n') {
      table[idx++] = (char)code;
    }
  }

  fclose(file);
}

int count_occupied_neighbors(int y, int x) {
  int count = 0;

  for (int dy = - 1; dy <= 1; dy++) {
     for (int dx = - 1; dx <= 1; dx++) {
       if ((dx != 0) || (dy != 0)) {
         int v = 1;
         while (1) {
           int i = x + dx * v;
           int j = y + dy * v;
           if ((j < 0) || (j >= height) || (i < 0) || (i >= width)) {
             break;
           } else if (table[j * width + i] == '#') {
             count += 1;
             break;
           } else if (table[j * width + i] == 'L') {
             break;
           }
           v += 1;
         }
       }
     }
  }

  return count;
}

// Returns 0 if we're done.
int run_one_step() {
  char* new_table = (char*)calloc(width * height, sizeof(char));
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int occupied = count_occupied_neighbors(y, x);
      char value = table[y * width + x];
      switch (value) {
      case 'L':
        if (occupied == 0)
          value = '#';
        break;
      case '#':
        if (occupied >= 5)
          value = 'L';
        break;
      }
      new_table[y * width + x] = value;
    }
  }

  // See if the old and new tables are the same
  int return_value = 0;
  for (int i = 0; i < width * height; i++) {
    if (table[i] != new_table[i])
      return_value = 1;
  }

  free(table);
  table = new_table;
  return return_value;

}

int count_occupied() {
  int count = 0;
  for (int i = 0; i < width * height; i++) {
    if (table[i] == '#')
      count += 1;
  }
  return count;
}

int main() {
  read_file();

  while (run_one_step());
  printf("%d\n", count_occupied());

  free(table);
  return 0;
}
