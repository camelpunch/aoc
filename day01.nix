{ lib }:
with builtins;
with lib.strings;
with lib.lists;

let
  numberMap = {
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
    "6" = "6";
    "7" = "7";
    "8" = "8";
    "9" = "9";
    "one" = "1";
    "two" = "2";
    "three" = "3";
    "four" = "4";
    "five" = "5";
    "six" = "6";
    "seven" = "7";
    "eight" = "8";
    "nine" = "9";
  };

  input = builtins.readFile ./day01input;
  reverseString = s: concatStrings (reverseList (stringToCharacters s));
  lines = filter (line: line != "") (splitString "\n" input);
  convertedStringNumbers = map (line: "${firstNumber line}${lastNumber line}") lines;
  numbers = map (line: toInt line) convertedStringNumbers;

  toMappedInt = str: numberMap.${str};

  firstNumber = line:
    toMappedInt (firstStringNumber line stringNumbers);

  lastNumber = line: toMappedInt (lastStringNumber line);

  firstStringNumber = line: numbers:
    findFirst
      (numberStr: isList (match "^${numberStr}.*" line))
      (firstStringNumber (substring 1 (-1) line) numbers)
      numbers;

  lastStringNumber = line:
    reverseString (firstStringNumber (reverseString line) reversedStringNumbers);

  stringNumbers = attrNames numberMap;
  reversedStringNumbers = map (s: reverseString s) stringNumbers;
in
foldl (a: b: a + b) 0 numbers
