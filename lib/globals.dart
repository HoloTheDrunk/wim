library wim.globals;

import 'package:flutter/material.dart';

const ColorFilter greyscale = ColorFilter.matrix(
  <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //R
    0.2126, 0.7152, 0.0722, 0, 0, //G
    0.2126, 0.7152, 0.0722, 0, 0, //B
    0, 0, 0, 1, 0, //A
  ],
);

const ColorFilter inactive = ColorFilter.matrix(
  <double>[
    1, 0, 0, 0, 0, //R
    0, 1, 0, 0, 0, //G
    0, 0, 1, 0, 0, //B
    0, 0, 0, 0.5, 0, //A
  ],
);
