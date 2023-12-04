module Main

import Data.List1
import Data.Nat
import Data.String
import Data.Vect
import Debug.Trace
import System.File

Coords : Type
Coords = Pair Integer Integer

Line : Type
Line = List Char

IndexedLine : Type
IndexedLine = List (Char, Coords)

Schematic : Type
Schematic = List IndexedLine

Group : Type
Group = List1 (Char, Coords)

PositionedInt : Type
PositionedInt = (Int, Coords, Coords)

PositionedIntsWithPartNumberSymbols : Type
PositionedIntsWithPartNumberSymbols = List (PositionedInt, Maybe (Char, Coords))

GroupOfPositionedIntsWithPartNumberSymbols : Type
GroupOfPositionedIntsWithPartNumberSymbols = List1 (PositionedInt, Maybe (Char, Coords))

Interpolation Integer where
  interpolate = show

Interpolation Coords where
  interpolate (x, y) = "(\{x}, \{y})"

Interpolation Char where
  interpolate = singleton

addCoords : Integer -> IndexedLine -> Char -> IndexedLine
addCoords y wipLine char =
  case last' wipLine of
       Nothing => wipLine ++ [(char, (0, y))]
       Just (c, (x, _)) => wipLine ++ [(char, (x + 1, y))]

indexLine : Line -> Integer -> IndexedLine
indexLine line y = foldl (addCoords y) [] line

toLines : String -> List Line
toLines = (map unpack) . lines

isNumber : Char -> Bool
isNumber char = ord char >= 48 && ord char <= 57

groupByWhetherNumber : IndexedLine -> List Group
groupByWhetherNumber line =
  groupBy (\(char1, _), (char2, _) => isNumber char1 && isNumber char2) line

isNumberGroup : Group -> Bool
isNumberGroup group = let (char, coords) = head group in isNumber char

numberGroups : IndexedLine -> List Group
numberGroups line =
  filter isNumberGroup (groupByWhetherNumber line)

toInt : String -> Int
toInt = fromMaybe 9999999 . parseInteger

groupInt : Group -> Int
groupInt group =
  let (char ::: otherChars) = map fst group
      chars = (char :: otherChars)
  in toInt (pack chars)

groupToPositionedInteger : Group -> PositionedInt
groupToPositionedInteger group =
  (groupInt group, (snd (head group), snd (last group)))

numbersInLine : IndexedLine -> List PositionedInt
numbersInLine =
  (map groupToPositionedInteger) . numberGroups

flatten : List (List a) -> List a
flatten [] = []
flatten (x :: xs) = x ++ flatten xs

isSymbol : Char -> Bool
isSymbol char = not (isNumber char) && char /= '.'

isAdjacent : Coords -> Coords -> Coords -> Bool
isAdjacent (startX, startY) (finishX, finishY) (x, y) =
  x >= startX -1 &&
  x <= finishX +1 &&
  y >= startY - 1 &&
  y <= finishY + 1

isAdjacentSymbol : Coords -> Coords -> (Char, Coords) -> Bool
isAdjacentSymbol start finish (char, coords) =
  isSymbol char &&
  isAdjacent start finish coords

isAdjacentAsterisk : Coords -> Coords -> (Char, Coords) -> Bool
isAdjacentAsterisk start finish ('*', coords) =
  isAdjacentSymbol start finish ('*', coords)
isAdjacentAsterisk _ _ _ = False

partNumberSymbol : Schematic -> PositionedInt -> Maybe (Char, Coords)
partNumberSymbol schematic (_, start, finish) =
  let positionedChars = flatten schematic
  in find (isAdjacentSymbol start finish) positionedChars

allPositionedInts : Schematic -> List PositionedInt
allPositionedInts schematic =
  flatten (map numbersInLine schematic)

annotated : Schematic -> PositionedIntsWithPartNumberSymbols
annotated schematic =
  map (\pi => (pi, partNumberSymbol schematic pi)) $ allPositionedInts schematic

onlyAsterisks : Schematic -> PositionedIntsWithPartNumberSymbols
onlyAsterisks s = filter (\(pi, indexedChar) => case indexedChar of
                                                     Just ('*', _) => True
                                                     _ => False) (annotated s)

sortedSchematic : Schematic -> PositionedIntsWithPartNumberSymbols
sortedSchematic s = sortBy (\(_, a), (_, b) => compare a b) (onlyAsterisks s)

gearGroups : Schematic -> List GroupOfPositionedIntsWithPartNumberSymbols
gearGroups s = filter (\group => length group == 2) $ groupBy (\(_, a), (_, b) => a == b) (sortedSchematic s)

gearPartNumbersFromGroups : List GroupOfPositionedIntsWithPartNumberSymbols -> List (List1 Int)
gearPartNumbersFromGroups groups =
  map (\group => map (\((n, _, _), _) => n) group) groups

gearPartNumbersFromSchematic : Schematic -> List (List1 Int)
gearPartNumbersFromSchematic s =
  gearPartNumbersFromGroups (gearGroups s)

gearRatios : Schematic -> List Int
gearRatios s =
  map (\l => foldl (*) 1 l) (gearPartNumbersFromSchematic s)

partNumbersInIndexedLine : Schematic -> IndexedLine -> List PositionedInt
partNumbersInIndexedLine schematic line =
  let numbers = numbersInLine line
  in filter (isJust . partNumberSymbol schematic) numbers

toSchematic : String -> Schematic
toSchematic str =
  let (result, _) = foldl (\(finished, y), line => (finished ++ [indexLine line y], y + 1)) ([], 0) (toLines str)
  in result

partNumbers : String -> List Int
partNumbers str =
  let schematic = toSchematic str
      partNumbersIndexed = map (partNumbersInIndexedLine schematic) schematic
  in map (\(n, _, _) => n) (flatten partNumbersIndexed)

main : IO ()
main = do
  file <- readFile "day03input"
  case file of
       Right content => putStrLn "part 1: \{show (sum (partNumbers content))}\npart 2: \{show $ sum (gearRatios (toSchematic content))}"
       Left err => printLn err

fixture : Schematic
fixture = toSchematic """
          467..114..
          ...*......
          ..35..633.
          ......#...
          617*......
          .....+.58.
          ..592.....
          ......755.
          ...$.*....
          .664.598..
          """

fixture2 : String
fixture2 = """
           .........232.633.......................803..........................361................192............539.................973.221...340.....
           .............*..............#.....256.#.........329....................*313............*.......766.......*..........472..-...........+..249.
           """

fixture3 : String
fixture3 = """
          467..114..
          ...*......
          ..35..633.
          """

