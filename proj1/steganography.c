/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#include "imageloader.h"

// Determines what color the cell at the given row/col should be. This should
// not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col) {
  Color *pixel = &image->image[row][col];
  Color *newColor = (Color *)malloc(sizeof(Color));

  if (pixel->B & 1) {
    newColor->R = (uint8_t)255;
    newColor->G = (uint8_t)255;
    newColor->B = (uint8_t)255;
  } else {
    newColor->R = (uint8_t)0;
    newColor->G = (uint8_t)0;
    newColor->B = (uint8_t)0;
  }

  return newColor;
}

// Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image) {
  // Initialize the new image.
  Image *img = (Image *)malloc(sizeof(Image));
  img->cols = image->cols;
  img->rows = image->rows;
  img->image = (Color **)malloc(sizeof(Color *) * img->rows);

  // Convert the hidden message from each pixel.
  Color *pixel_converted;
  Color *pixel;

  for (int i = 0; i < image->rows; i++) {
    img->image[i] = (Color *)malloc(sizeof(Color) * img->cols);

    for (int j = 0; j < image->cols; j++) {
      pixel = &img->image[i][j];

      pixel_converted = evaluateOnePixel(image, i, j);
      pixel->R = pixel_converted->R;
      pixel->G = pixel_converted->G;
      pixel->B = pixel_converted->B;
    }
  }

  return img;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with
printf) a new image, where each pixel is black if the LSB of the B channel is 0,
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not
necessarily with .ppm file extension). If the input is not correct, a malloc
fails, or any other error occurs, you should exit with code -1. Otherwise, you
should return from main with code 0. Make sure to free all memory before
returning!
*/
void processCLI(int argc, char **argv, char **filename) {
  if (argc != 2) {
    printf("usage: %s filename\n", argv[0]);
    printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
    exit(-1);
  }
  *filename = argv[1];
}

int main(int argc, char **argv) {
  char *filename;
  processCLI(argc, argv, &filename);

  Image *image = readData(filename);
  Image *newImage = steganography(image);
  writeData(newImage);

  freeImage(image);
  freeImage(newImage);
  return 0;
}
