{ lib
, lines
}:
with builtins;
with lib.strings;
with lib.lists;
with lib.trivial;

let
  input = readFile ./day02input;

  games = input:
    map toGame (lines input);

  toGame = line:
    let
      parts = splitString ": " line;
      setsPart = last parts;
      setsAsStrings = splitString "; " setsPart;
      setsAsMultipleStrings = map (splitString ", ") setsAsStrings;
      sets = map setFromString setsAsMultipleStrings;

      grabsOfColour = colour: sets:
        (filter (s: s.colour == colour) (flatten sets));

      maxCubes = sets: foldl max 0 (map (s: s.count) sets);

      redMax = maxCubes (grabsOfColour "red" sets);
      blueMax = maxCubes (grabsOfColour "blue" sets);
      greenMax = maxCubes (grabsOfColour "green" sets);
    in
    {
      inherit sets redMax blueMax greenMax;
      id = toInt (last (splitString " " (head parts)));
      power = redMax * blueMax * greenMax;
    };

  setFromString = map grabFromString;

  grabFromString = grab:
    let strs = splitString " " grab;
    in {
      count = toInt (head strs);
      colour = last strs;
    };

  possibleWith = candidate: game:
    game.redMax <= candidate.redCount &&
    game.blueMax <= candidate.blueCount &&
    game.greenMax <= candidate.greenCount;

  matchingGames = filter (possibleWith { redCount = 12; greenCount = 13; blueCount = 14; }) (games input);

  part1Sum = foldl add 0 (map (game: game.id) matchingGames);
  part2Sum = foldl add 0 (map (game: game.power) (games input));
in
''
  part 1: ${toString part1Sum}
  part 2: ${toString part2Sum}
''
