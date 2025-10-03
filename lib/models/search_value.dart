import 'package:flutter/material.dart';

class SearchValues {
  String? destination;
  DateTimeRange? range;
  int adults, children, rooms;
  bool pets;

  SearchValues({
    this.destination,
    this.range,
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
    this.pets = false,
  });
}
