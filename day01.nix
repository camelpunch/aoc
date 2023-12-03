{ lib
, lines
}:
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

  input = readFile ./day01input;
  reverseString = s: concatStrings (reverseList (stringToCharacters s));
  convertedStringNumbers = map firstAndLast (lines input);
  numbers = map toInt convertedStringNumbers;

  firstAndLast = line: "${firstNumber line}${lastNumber line}";

  toMappedStringNumber = str: numberMap.${str};

  firstNumber = line:
    toMappedStringNumber (firstStringNumber line stringNumbers);

  lastNumber = line: toMappedStringNumber (lastStringNumber line);

  firstStringNumber = line: numbers:
    findFirst
      (startsWith line)
      (firstStringNumber (substring 1 (-1) line) numbers)
      numbers;

  startsWith = str: testStr: isList (match "^${testStr}.*" str);

  lastStringNumber = line:
    reverseString (firstStringNumber (reverseString line) reversedStringNumbers);

  stringNumbers = attrNames numberMap;
  reversedStringNumbers = map reverseString stringNumbers;
in
foldl add 0 numbers
