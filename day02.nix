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
    map
      (line:
        let
          parts = splitString ": " line;
          setsPart = last parts;
          setsAsStrings = splitString "; " setsPart;
          setsAsMultipleStrings = map (splitString ", ") setsAsStrings;
          sets = map
            (grabs:
              map
                (grab:
                  let strs = splitString " " grab;
                  in {
                    count = toInt (head strs);
                    colour = last strs;
                  }
                )
                grabs
            )
            setsAsMultipleStrings;

          drawsOfColour = colour: sets:
            (filter (s: s.colour == colour) (flatten sets));

          maxCubes = sets:
            foldl' max 0 (map (s: s.count) sets);

        in
        {
          inherit sets;
          id = toInt (last (splitString " " (head parts)));
          redMax = maxCubes (drawsOfColour "red" sets);
          blueMax = maxCubes (drawsOfColour "blue" sets);
          greenMax = maxCubes (drawsOfColour "green" sets);
        })
      (lines input);

  possibleWith = { redCount, blueCount, greenCount }: games:
    filter (game: game.redMax <= redCount && game.blueMax <= blueCount && game.greenMax <= greenCount) games;

  matchingGames = possibleWith { redCount = 12; greenCount = 13; blueCount = 14; } (games input);

  sum = foldl add 0 (map (game: game.id) matchingGames);
in
sum
