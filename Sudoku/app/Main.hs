module Main where

import SudokuCell
import Lib

main :: IO ()
main = do
    mode <- waitForAnswer "Insira 1 para resolver um sudoku, 2 para resolver um arquivo e 0 para sair" (`elem` ["0","1","2"]) "Tente novamente"
    if mode == "1" then solveSudoku else if mode = "2" then solveFile else return ()

solveSudoku :: IO ()
solveSudoku = do
    config <- waitForAnswer "Insira as dimensões do quadrado interno" isConfigValid "Use o formato \"m x n\""
    let config' = parseConfig config
    sudoku <- waitForAnswer "Insira um stringdoku com espaços" (isSudokuValid config') "Tente novamente"
    let solved <- uncurry (solve sudoku) config'
    printSolved solved
    main -- chama main para voltar pro menu
      where
          isConfigValid = -- está no formato "m x n" ?
          parseConfig config = -- transforma "m x n" em (m, n)
          isSudokuValid config =  -- possui m*n entradas ? Todas as entradas estão entre 1 e m*n ?
          printSolved solved = -- imprime resolvido

solveFile :: IO ()
solveFile = do
    config <- waitForAnswer "Insira as dimensões do quadrado interno e quantos sudokus possui o arquivo" isConfigValid "Use o formato \"m x n, x\""
    let config' = parseConfig config
    file <- waitForAnswer "Insira o nome do arquivo" isFileValid "Arquivo inválido ou inexistente"
    (\(len,wid,num) -> testTime num len wid file) config'
    main -- chama main para voltar pro menu
      where
        isConfigValid = -- está no formato "m x n, x" ?
        parseConfig config = -- transforma "m x n, x" em (m, n, x)
        isSudokuValid config =  -- sei lá oq faríamos aqui

waitForAnswer :: String -> (String -> Bool) -> String -> IO String
waitForAnswer question verify reject = do
    putStrLn question
    answer <- getLine
    if verify answer then return answer else putStrLn reject >> waitForAnswer question verify reject
