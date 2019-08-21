module Lib where

import Control.Monad.State.Lazy
import Data.List.Split (chunksOf)
import Data.List
import Data.Maybe
import Data.Function (on)
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

solve :: GameState (Maybe Table)
solve = do
            nextTable <- findFixPoint
            case nextTable of
                Nothing               -> return Nothing
                (Just a) | isSolved a -> return (Just a)
                (Just a) | otherwise  -> do
                                            let (next1, next2) = splitTableAtMin a
                                            solve1 <- solve next1
                                            solve2 <- solve next2 -- Será que o lazyness cuida de só resolver o 2 se o 1 der nothing??
                                            if isNothing solve1 then return solve2 else return solve1

findFixPoint :: GameState (Maybe Table) -- aqui eu recomendo que olhe o artigo que te mandei antes de tentar entender
findFixPoint = do
    config <- get
    let table = currTable config
    table' <- runTable table -- runTable altera o estado, por isso pode retornar que já tá atualizado
    if table /= table' then findFixPoint else return table' -- nothing == nothing, aí quem chamou se vira

runTable :: Maybe Table -> GameState (Maybe Table)
runTable Nothing  = return Nothing
runTable table = do
    config <- get
    let (len, wid) = (rectLen config, rectWid config)
    let table' = checkForRects len wid $ checkForCols $ checkForRows table -- provavelmente o 3D só vai mexer aqui
    put ( config { currTable = (fromMaybe (fromJust table) table') } ) -- atualiza a tabela velha com a nova
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
splitTableAtMin a b c = (c,c)
-- splitTableAtMin len wid table =
--     let (index, cell, cell') = splitMinCell table -- descobre onde quebrar
--     in (replace index cell table (len+wid), replace index cell' table (len+wid)) -- substitui a quebra
--     where
--         flatTable table = zip [0..] (concat table)

--         splitMinCell table = splitCell $ minCell table
--         minCell table = minimumBy (compare `on` (cellSize.snd)) $ filter (not.isFixed.snd) flatTable table -- ODEIO USAR (compare `on` x)
--         cellSize (FixedCell _) = 1
--         cellSize (OpenCell xs) = length xs
--         splitCell (i, FixedCell _) = error "?" -- compilador pede, fazer oq...
--         splitCell (i, OpenCell [x,y]) = (i, FixedCell x, FixedCell y) -- ponto chave da busca em profundidade
--         splitCell (i, OpenCell (x:xs)) = (i, FixedCell x, OpenCell xs)

--         replace index cell table size = let idXY = (quot index 9, mod index 9) in
--             [[if (x,y) == idXY then cell else c | (c, y) <- zip row [0..] ] | (row, x) <- zip table [0..]] -- espero que funcione

isSolved :: Table -> Bool
isSolved table = [] == filter (not.isFixed) (concat table)
-- Falta fazer o IO agora, pra podermos começar a testar se deu certo.
-- Podemos começar a pensar no 3D também
