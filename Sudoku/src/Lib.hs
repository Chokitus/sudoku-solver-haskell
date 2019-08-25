module Lib  where

import Control.Monad.State.Lazy
import Control.DeepSeq 
import Data.List.Split (chunksOf)
import Data.List
import Data.Maybe
import Text.Printf
import Data.Function (on)
import System.CPUTime
import SudokuCell

type GameState = State TableConfig
-- State TableConfig a :: TableConfig -> (a, TableConfig)
-- GameState a         :: TableConfig -> (a, TableConfig)
--              a <- (a, _)
-- get          (_, s) = (s, s)
-- put x        (_, s) = ( () , x)
-- return x     (_, s) = (x, s)

isFixed :: Cell -> Bool -- duh
isFixed (FixedCell _) = True
isFixed (OpenCell _) = False

testTime' :: Int -> IO()
testTime' num = do
    sudokus <- fmap (fmap (readTable 9)) (take num . lines <$> readFile "sudoku_puzzle.txt")
    t1 <- getCPUTime

    let solveds = map (\x -> solve x 3 3 `deepseq` solve x 3 3) sudokus `deepseq` "Todos os Sudokus foram resolvidos"
    putStrLn solveds
    t2 <- getCPUTime
    printf "Computation time total: %0.6f ms\n" (diff t1 t2)
        where diff t1 t2 = fromIntegral (t2 - t1) / (10^9) :: Double


solve :: Table -> Int -> Int -> Table
solve table len wid = fromJust $ evalState solve' (TableConfig table len wid)

solve' ::  GameState (Maybe Table)
solve' = do
    currState <- get
    let (len, wid) = (rectLen currState, rectWid currState)
    nextTable <- findFixPoint
    case nextTable of
        Nothing               -> return Nothing
        (Just a) | isSolved a -> return (Just a)
        (Just a)  -> do
            let (next1, next2) = splitTableAtMin len wid a
            put ( currState { currTable = next1 } )
            solve1 <- solve'
            if isJust solve1 then return solve1 else put ( currState { currTable = next2 } ) >> solve'

findFixPoint :: GameState (Maybe Table) -- aqui eu recomendo que olhe o artigo que te mandei antes de tentar entender
findFixPoint = do
    config <- get
    let table = currTable config
    table' <- runTable -- runTable altera o estado, por isso pode retornar que já tá atualizado
    if isJust table' && table' /= Just table then findFixPoint else return table'

runTable :: GameState (Maybe Table)
runTable = do
    config <- get
    let (len, wid, table) = (rectLen config, rectWid config, currTable config)
    let table' = checkForRects len wid . checkForCols . checkForRows $ Just table -- provavelmente o 3D só vai mexer aqui
    put ( config { currTable = fromMaybe table table' } ) -- atualiza a tabela velha com a nova
    return table' -- devolve como parâmetro. Se não quisesse comparar, poderia ter sido return ()

checkForRows :: Maybe Table -> Maybe Table -- traverse f x nada mais é que (sequence $ map f x)
checkForRows Nothing = Nothing
checkForRows (Just table) = traverse checkRow table

checkForCols :: Maybe Table -> Maybe Table
checkForCols Nothing = Nothing
checkForCols (Just table) = transpose <$> traverse checkRow (transpose table) -- o último transpose é fmap pq tem um Maybe por fora

checkForRects :: Int -> Int -> Maybe Table -> Maybe Table -- esse é o corno que deu trabalho
checkForRects _ _ Nothing = Nothing
checkForRects len wid (Just table) = transposeRects len wid <$> traverse checkRow (transposeRects len wid table)
    where transposeRects len wid table = concat $ transpose $ map (map concat . chunksOf wid) ( transpose <$> map (chunksOf len) table )
    -- esse transposeRects é uma ótima função pros testes de propriedade que ele pede: garantir que ele é sua própria inversa

checkRow :: Row -> Maybe Row
checkRow row = traverse checkCells row -- por enquanto ta fazendo um passo só. Logo implemento o segundo
    where
        fixeds row = [cell | FixedCell cell <- row]
        checkCells (FixedCell cell) = Just (FixedCell cell)
        checkCells (OpenCell cell) = case cell \\ fixeds row of -- se limpa dos vizinhos fixados
            []     -> Nothing -- nosso primeiro nothing, que vai propagar lá pra cima
            [x]    -> Just (FixedCell x) -- desejável, garante mais um passo antes de expandir dnv
            xs     -> Just (OpenCell xs)

splitTableAtMin :: Int -> Int -> Table -> (Table, Table)
splitTableAtMin len wid table =
    let (index, cell, cell') = splitMinCell table -- descobre onde quebrar
    in (replace index cell table (len*wid), replace index cell' table (len*wid)) -- substitui a quebra

    where
        flatTable table = zip [0..] (concat table)

        splitMinCell table = splitCell $ minCell table
        minCell table = minimumBy (compare `on` (cellSize.snd)) $ filter (not.isFixed.snd) $ flatTable table -- ODEIO USAR (compare `on` x)
        cellSize (FixedCell _) = 1
        cellSize (OpenCell xs) = length xs
        splitCell (i, FixedCell _) = error "?" -- compilador pede, fazer oq...
        splitCell (i, OpenCell [x,y]) = (i, FixedCell x, FixedCell y) -- ponto chave da busca em profundidade
        splitCell (i, OpenCell (x:xs)) = (i, FixedCell x, OpenCell xs)

        replace index cell table size = let idXY = (quot index size, mod index size) in
            [[if (x,y) == idXY then cell else c | (c, y) <- zip row [0..] ] | (row, x) <- zip table [0..]] -- espero que funcione

isSolved :: Table -> Bool
isSolved table = [] == filter (not.isFixed) (concat table)
-- Falta fazer o IO agora, pra podermos começar a testar se deu certo.
-- Podemos começar a pensar no 3D também
