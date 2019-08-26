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
          isSudokuValid len wid s = True
          printSolved solved = putStrLn $ showTable solved

solveFile :: IO ()
solveFile = do
    config <- waitForAnswer "Insira as dimensões do quadrado interno" isConfigValid "Use o formato \"m x n\""
    let (len,wid) = parseConfig config
    nums <- waitForAnswer "Insira quantos sudokus possui o arquivo" (all isDigit) "Insira valor numerico"
    let num = read nums :: Int
    file <- waitForAnswer "Insira o nome do arquivo" (isFileValid (fromInteger len :: Int) (fromInteger wid :: Int)) "Arquivo inválido ou inexistente"
    
    testTime num (fromInteger len :: Int) (fromInteger wid :: Int) file
    main -- chama main para voltar pro menu
      where
        isConfigValid [m,' ','x',' ',n] = isDigit m && isDigit n
        isConfigValid _                         = False
        parseConfig [m,' ','x',' ', n] = (read [m] :: Integer, read [n] :: Integer)
        parseConfig _                               = error "?"
        isFileValid _ _ _ = True

waitForAnswer :: String -> (String -> Bool) -> String -> IO String
waitForAnswer question verify reject = do
    putStrLn question
    answer <- getLine
    if verify answer then return answer else putStrLn reject >> waitForAnswer question verify reject
