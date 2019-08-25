{-# LANGUAGE DeriveGeneric #-}

module SudokuCell where

  import Data.List.Split
  import Data.List
  import GHC.Generics (Generic)
  import Control.DeepSeq
  import Data.Char (ord, chr)
  import Numeric
  
  -- ###################### CELL #######################################################
  data Cell = FixedCell Int | OpenCell [Int] deriving (Generic)

  instance NFData Cell where
    rnf (FixedCell a) = a `deepseq` ()
    rnf (OpenCell a)  = a `deepseq` ()
  
  newCell :: Int -> Cell
  newCell size = OpenCell [1..size] -- temos que definir quem são os nossos chars, e como informar.
  
  instance Show Cell where
      show (FixedCell a) = show a
      show (OpenCell _)  = "_"
  
  instance Eq Cell where
    (OpenCell _)  == (FixedCell _) = False
    (FixedCell _) == (OpenCell _)  = False
    (FixedCell a) == (FixedCell b) = a==b
    (OpenCell a)  == (OpenCell b)  = a==b
  
  readCell :: String -> Cell
  readCell s | s == "_" || s == "0" = OpenCell [1,2]
             |            otherwise = FixedCell (parseCell s)
  
  showOpen :: Cell -> String
  showOpen (FixedCell a) = show [a]
  showOpen (OpenCell xs) = show xs
  
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
  
  resetOpens :: Int -> Table -> Table
  resetOpens size = map (map (resetCell size))
  
  resetCell :: Int -> Cell -> Cell
  resetCell size (FixedCell a) = FixedCell a
  resetCell size _ = newCell size
  
  --           Largura
  --           da Linha    Stringdoku
  readTable ::   Int   ->   String   -> Table
  readTable size stringdoku = resetOpens size $ map readRow $ chunksOf size $ words stringdoku
  
  loadTable :: FilePath -> Int -> Int -> IO Table
  loadTable fp line width = readTable width . searchForLine line 0 . lines <$> readFile fp
  
  searchForLine ::  Int -> Int -> [String] -> String
  searchForLine i j [] = "Não encontrado"
  searchForLine i j (a:as) | i /= j = searchForLine i (j+1) as
  searchForLine i j (a:as) = a
                        
  -- loadBulkTable :: FilePath -> Int -> Int -> [IO Table]
  -- loadBulkTable fp n width = readTable width.take n.lines <$> readFile fp
  -- readTableOpen :: String -> Table -- De novo, precisa?
  -- ###################################################################################