/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include "imageloader.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Opens a .ppm P3 image file, and constructs an Image object.
// You may find the function fscanf useful.
// Make sure that you close the file with fclose before returning.
Image *readData(char *filename) {
  FILE *fp = fopen(filename, "r");

  // Initialize the image.
  char format[5];
  int cols, rows, range;

  fscanf(fp, "%s %d %d %d", format, &cols, &rows, &range);

  Image *img = (Image *)malloc(sizeof(Image));
  img->image = (Color **)malloc(sizeof(Color *) * rows);
  img->cols = cols;
  img->rows = rows;

  // Read RGB color for each row.
  int R, G, B;
  Color *pixel;
  Color *row_pixels;

  for (int i = 0; i < img->rows; i++) {
    row_pixels = (Color *)malloc(sizeof(Color) * cols);

    // Read RGB color for each pixel in the row.
    for (int j = 0; j < img->cols; j++) {
      fscanf(fp, "%d %d %d", &R, &G, &B);
      pixel = &row_pixels[j];
      pixel->R = (uint8_t)R;
      pixel->G = (uint8_t)G;
      pixel->B = (uint8_t)B;
    }
    img->image[i] = row_pixels;
  }

  fclose(fp);
  return img;
}

// Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the
// image's data.
void writeData(Image *image) {
  printf("P3\n%d %d\n255\n", image->cols, image->rows);

  Color *pixel;

  for (int i = 0; i < image->rows; i++) {
    // Print out each row.
    for (int j = 0; j < image->cols - 1; j++) {
      pixel = &image->image[i][j];
      printf("%3d %3d %3d   ", pixel->R, pixel->G, pixel->B);
    }
    // Change to the next row.
    pixel = &image->image[i][image->cols - 1];
    printf("%3d %3d %3d\n", pixel->R, pixel->G, pixel->B);
  }
}

// Frees an image
void freeImage(Image *image) {
  for (int i = 0; i < image->rows; i++) {
    free(image->image[i]);
  }
  free(image->image);
  free(image);
}
