data Cell = FixedCell Char | OpenCell [Char] -- TEREMOS QUE USAR CHAR EM VEZ DE INT SE QUISERMOS ALGO MAIOR QUE 9x9

newCell :: OpenCell
newCell = [0..maxChar] -- temos que definir quem são os nossos chars, e como informar.

instance Show Cell where
    show (FixedCell a) = [a]
    show (OpenCell _)  = "_"

instance Read Cell where
    read s | s == "_"       = newCell
    read s | length s == 1  = FixedCell (head s)
    read s                  = OpenCell s

showOpen :: Cell -> String
showOpen (FixedCell a) = [a]
showOpen (OpenCell xs) = xs

readOpen :: String -> Cell -- TODO talvez todos os read_Opens precisem informar tamanho

type Row = [Cell]

showRow :: Row -> String
showRow [] = ""
showRow xs = concatMap ((++ " ") . show) xs ++ "\n"

showRowOpen :: Row -> String
showRowOpen [] = ""
showRowOpen xs = concatMap ((++ " ") . showOpen) xs ++ "\n"

readRow :: String -> Row -- TODO
readRowOpen :: String -> Row -- TODO

type Table = [Row]

showTable :: Table -> String
showTableOpen :: Table -> String
readTable :: String -> Table
readTableOpen :: String -> Table

data TableConfig = TableConfig {currTable :: Table, rectLen :: Int, rectWid :: Int}
