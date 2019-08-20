data Cell = FixedCell Int | OpenCell [Int]
instance Show Cell where
  show (FixedCell a) = show a
  show (OpenCell _)  = "_"

type Row = [Cell]

showRow :: Row -> String
showRow [] = ""
showRow xs = concatMap ((++ " ") . show) xs ++ "\n"

type Table = [Row]
data TableConfig = TableConfig {currTable :: Table, rectLen :: Int, rectWid :: Int} -- nosso estado