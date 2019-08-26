module Main where

import SudokuCell
import SudokuLib
import Data.Char

main :: IO ()
main = do
    mode <- waitForAnswer "Insira 1 para resolver um sudoku, 2 para resolver um arquivo e 0 para sair" (`elem` ["0","1","2"]) "Tente novamente"
    if mode == "1" then solveSudoku else if mode == "2" then solveFile else return ()

solveSudoku :: IO ()
solveSudoku = do
    config <- waitForAnswer "Insira as dimensões do quadrado interno" isConfigValid "Use o formato \"m x n\""
    let (len, wid) = parseConfig config
    sudoku <- waitForAnswer "Insira um stringdoku com espaços" (isSudokuValid len wid) "Tente novamente"
    let table = readTable ((fromInteger len :: Int)*(fromInteger wid :: Int)) sudoku
    let solved = solve table (fromInteger len :: Int) (fromInteger wid :: Int)
    printSolved solved
    main -- chama main para voltar pro menu
      where
          isConfigValid [m,' ','x',' ', n] = isDigit m && isDigit n
          isConfigValid _                  = False
          parseConfig [m,' ','x',' ', n] = (read [m] :: Integer, read [n] :: Integer)
          parseConfig _                  = error "?"
          isSudokuValid len wid s = True--length (words s) == ((fromInteger len :: Int)*(fromInteger wid :: Int))**2 && all (\x -> let x' = read x in x>0 && x<=(len*wid)) (words s)
          printSolved solved = putStrLn $ showTable solved-- imprime resolvido (PRECISO DE VOCÊ NESSE)

solveFile :: IO ()
solveFile = do
    config <- waitForAnswer "Insira as dimensões do quadrado interno e quantos sudokus possui o arquivo" isConfigValid "Use o formato \"m x n, x\""
    let (len,wid,num) = parseConfig config
    file <- waitForAnswer "Insira o nome do arquivo" (isFileValid (fromInteger len :: Int) (fromInteger wid :: Int)) "Arquivo inválido ou inexistente"
    testTime (fromInteger num :: Int) (fromInteger len :: Int) (fromInteger wid :: Int) file
    main -- chama main para voltar pro menu
      where
        isConfigValid [m,' ','x',' ',n,',',' ',x] = isDigit m && isDigit n && isDigit x
        isConfigValid _                         = False
        parseConfig [m,' ','x',' ', n, ',', ' ', x] = (read [m] :: Integer, read [n] :: Integer, read [m] :: Integer)
        parseConfig _                               = error "?"
        isFileValid _ _ _ = True -- sei lá oq faríamos aqui (PRECISO DE VOCÊ NESSE)

waitForAnswer :: String -> (String -> Bool) -> String -> IO String
waitForAnswer question verify reject = do
    putStrLn question
    answer <- getLine
    if verify answer then return answer else putStrLn reject >> waitForAnswer question verify reject
