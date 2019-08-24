module SudokuCell where

import Data.List.Split
import Data.List
import Data.Char (ord, chr)
import Numeric

-- ###################### CELL #######################################################
data Cell = FixedCell Int | OpenCell [Int] -- TEREMOS QUE USAR CHAR EM VEZ DE INT SE QUISERMOS ALGO MAIOR QUE 9x9

newCell :: Cell
newCell = OpenCell [1..9] -- temos que definir quem são os nossos chars, e como informar.

instance Show Cell where
    show (FixedCell a) = show a
    show (OpenCell _)  = "_"

instance Eq Cell where
  (FixedCell _) == (OpenCell _)  = False
  (FixedCell a) == (FixedCell b) = a==b
  (OpenCell a)  == (OpenCell b)  = a==b

readCell :: String -> Cell
readCell s | s == "_" || s == "0" = newCell
           |            otherwise = FixedCell (parseCell s)

showOpen :: Cell -> String
showOpen (FixedCell a) = show [a]
showOpen (OpenCell xs) = show xs

parseCellMapKey :: String
parseCellMapKey = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

parseCellMapValue :: [Int]
parseCellMapValue = [1..]

parseCellMap :: [(Char, Int)]
parseCellMap = zip parseCellMapKey parseCellMapValue

parseCell :: String -> Int
parseCell s = read s :: Int

-- ###################### ROW ########################################################
type Row = [Cell]

showRow :: Row -> String
showRow [] = ""
showRow xs = concatMap ((++ " ") . show) xs ++ "\n"

showRowOpen :: Row -> String
showRowOpen [] = ""
showRowOpen xs = concatMap ((++ " ") . showOpen) xs ++ "\n"

readRow :: [String] -> Row -- TODO
readRow xs = [readCell cellString | cellString <- xs]

-- readRowOpen :: String -> Row -- TODO -- Precisa? showRowOpen é estritamente de DEBUG
-- ###################################################################################

data TableConfig = TableConfig {currTable :: Table, rectLen :: Int, rectWid :: Int}
type Table = [Row]

showTable :: Table -> String
showTable = concatMap showRow

showTableOpen :: Table -> String
showTableOpen = concatMap showRowOpen

--           Largura
--           da Linha    Stringdoku
readTable ::   Int   ->   String   -> Table
readTable size stringdoku = map readRow $ chunksOf size $ words stringdoku

loadTable :: FilePath -> Int -> Int -> IO Table
loadTable fp line width = readTable width . searchForLine line 0 . lines <$> readFile fp

searchForLine ::  Int -> Int -> [String] -> String
searchForLine i j [] = "Não encontrado"
searchForLine i j (a:as) | i /= j = searchForLine i (j+1) as
searchForLine i j (a:as) = a

-- readTableOpen :: String -> Table -- De novo, precisa?
-- ###################################################################################
