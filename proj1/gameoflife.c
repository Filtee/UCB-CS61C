/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#include "imageloader.h"

int isAlive(Image *image, int row, int col) {
  // Test if the the position is out of boundary.
  if (row < 0 || col < 0 || row >= image->rows || col >= image->cols) {
    return 0;
  }

  Color *color = &image->image[row][col];
  if (color->R == 255 && color->G == 255 && color->B == 255) {
    return 1;
  } else {
    return 0;
  }
}

// Get the situation of neighbors in the uint8_t format.
uint8_t getNeighbors(Image *image, int row, int col) {
  uint8_t neighbors = 0;
  int cnt = 0;
  for (int i = -1; i < 2; i++) {
    for (int j = -1; j < 2; j++, cnt++) {
      if (cnt == 4) {
        continue;
      }
      neighbors = (neighbors << 1) | isAlive(image, row + i, col + j);
    }
  }
  return neighbors;
}

// Count the number of neighbors alive neerby.
int countNeighbors(uint8_t neighbors) {
  int cnt = 0;
  for (int i = 0; i < 8; i++) {
    if ((neighbors >> i) & 1) {
      cnt++;
    }
  }
  return cnt;
}

// Determines what color the cell at the given row/col should be. This function
// allocates space for a new Color. Note that you will need to read the eight
// neighbors of the cell in question. The grid "wraps", so we treat the top row
// as adjacent to the bottom row and the left column as adjacent to the right
// column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule) {
  uint8_t neigbors = getNeighbors(image, row, col);
  int cnt = countNeighbors(neigbors);
  Color *nextColor = (Color *)malloc(sizeof(Color));

  switch (rule) {
    case (uint32_t)0x1808:

      // Whether this cell is alive...
      if (cnt == 3 || (cnt == 2 && isAlive(image, row, col))) {
        nextColor->R = 255;
        nextColor->G = 255;
        nextColor->B = 255;
      } else {
        nextColor->R = 0;
        nextColor->G = 0;
        nextColor->B = 0;
      }
      break;
  }

  return nextColor;
}

// The main body of Life; given an image and a rule, computes one iteration of
// the Game of Life. You should be able to copy most of this from
// steganography.c
Image *life(Image *image, uint32_t rule) {
  // Initialize the new image.
  Image *img = (Image *)malloc(sizeof(Image));
  img->cols = image->cols;
  img->rows = image->rows;
  img->image = (Color **)malloc(sizeof(Color *) * img->rows);

  // Convert the situation of next iteration for each cell.
  Color *cell_converted;
  Color *cell;

  for (int i = 0; i < img->rows; i++) {
    img->image[i] = (Color *)malloc(sizeof(Color) * img->cols);

    for (int j = 0; j < img->cols; j++) {
      cell = &img->image[i][j];

      cell_converted = evaluateOneCell(image, i, j, rule);
      cell->R = cell_converted->R;
      cell->G = cell_converted->G;
      cell->B = cell_converted->B;

      free(cell_converted);
    }
  }

  return img;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then
prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this
will be a string. You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you
should exit with code -1. Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
void processCLI(int argc, char **argv, char **filename, uint32_t *rule) {
  if (argc != 3) {
    printf("usage: %s filename rule\n", argv[0]);
    printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
    printf("rule is a hex number beginning with 0x; Life is 0x1808.\n");
    exit(-1);
  }
  *filename = argv[1];
  *rule = (uint32_t)strtol(argv[2], NULL, 16);
}

int main(int argc, char **argv) {
  char *filename;
  uint32_t rule;
  processCLI(argc, argv, &filename, &rule);

  Image *image = readData(filename);
  Image *newImage = life(image, rule);
  writeData(newImage);

  freeImage(image);
  freeImage(newImage);
  return 0;
}
