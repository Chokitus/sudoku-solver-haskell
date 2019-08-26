module SudokuLib  where

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

isFixed :: Cell -> Bool
isFixed (FixedCell _) = True
isFixed (OpenCell _) = False

testTime :: Int -> Int -> Int -> FilePath -> IO()
testTime num len wid filepath = do -- resolve os primeiros "num" sudokus de quadrado interno "len x wid" em "filepath"
    sudokus <- fmap (fmap (readTable (len*wid))) (take num . lines <$> readFile filepath) -- extrai os sudokus
    t1 <- getCPUTime
    let solveds = map (\x -> solve x len wid) sudokus `deepseq` "Todos os Sudokus foram resolvidos" -- força a resolução quando solveds for calculado
    putStrLn solveds -- usa o solveds, resolvendo assim os sudokus
    t2 <- getCPUTime
    printf "Computation time total: %0.6f ms\n" (diff t1 t2) -- calcula o tempo de solução dos "num" sudokus
        where diff t1 t2 = fromIntegral (t2 - t1) / (10^9) :: Double
-- para sudokus de quadrado interno 3x3 (os 9x9 usuais), temos em média 12ms por sudoku sem a otimização "-o2"

solve :: Table -> Int -> Int -> Table -- invoca a solução monádica dos sudokus
solve table len wid = fromJust $ evalState solve' (TableConfig table len wid)

solve' ::  GameState (Maybe Table)
solve' = do
    currState <- get -- pega a config atual
    let (len, wid) = (rectLen currState, rectWid currState) -- extrai suas medidas
    nextTable <- findFixPoint -- tenta resolver até não poder mais
    case nextTable of
        Nothing               -> return Nothing -- se chegou em um impasse, sudoku impossível, retorna Nothing
        (Just a) | isSolved a -> return (Just a) -- se resolveu o sudoku, retorne-o
        (Just a)  -> do
            let (next1, next2) = splitTableAtMin len wid a -- se não resolveu, inicie uma busca em profundidade
            put ( currState { currTable = next1 } ) -- guarde a primeira ramificação no config e tente resolver ela
            solve1 <- solve'
            if isJust solve1 then return solve1 else put ( currState { currTable = next2 } ) >> solve' -- se der Nothing, guarde e tente a segunda

findFixPoint :: GameState (Maybe Table) -- procura resolver até não poder mais
findFixPoint = do
    config <- get
    let table = currTable config -- extrai a tabela atual
    table' <- runTable -- runTable altera o estado, por isso pode retornar que já tá atualizado
    if isJust table' && table' /= Just table then findFixPoint else return table' -- se houve mudança, então retorna, senão, entra em recursão

runTable :: GameState (Maybe Table) -- realiza uma etapa de solução
runTable = do
    config <- get
    let (len, wid, table) = (rectLen config, rectWid config, currTable config) -- extrai o estado de config
    let table' = checkForRects len wid . checkForCols . checkForRows $ Just table -- provavelmente uma versão 3D só precisaria mexer aqui
    put ( config { currTable = fromMaybe table table' } ) -- atualiza a tabela velha com a nova
    return table' -- retorna a tabela corrigida para ser comparada

checkForRows :: Maybe Table -> Maybe Table -- limpa linhas da tabela. 
checkForRows Nothing = Nothing
checkForRows (Just table) = traverse checkRow table

checkForCols :: Maybe Table -> Maybe Table -- transforma colunas em linhas, limpa, e transforma em colunas novamente
checkForCols Nothing = Nothing
checkForCols (Just table) = transpose <$> traverse checkRow (transpose table) -- o último transpose é fmap pq tem um Maybe por fora

checkForRects :: Int -> Int -> Maybe Table -> Maybe Table -- transforma os quadrados internos "len x wid" em linhas, limpa, e transforma em quadrados novamente
checkForRects _ _ Nothing = Nothing
checkForRects len wid (Just table) = transposeRects len wid <$> traverse checkRow (transposeRects len wid table)
    where transposeRects len wid table = concat $ transpose $ map (map concat . chunksOf wid) ( transpose <$> map (chunksOf len) table )
    -- o truque é que essa transformação é sua própria inversa

checkRow :: Row -> Maybe Row -- unidade central de resolução, qualquer implementação mais profunda mexeria aqui, como procurar por pares e triplas
checkRow row = traverse checkCells row 
    where
        fixeds row = [cell | FixedCell cell <- row] -- descobre as células já fixadas dessa linha
        checkCells (FixedCell cell) = Just (FixedCell cell) -- células fixadas já estão limpas
        checkCells (OpenCell cell) = case cell \\ fixeds row of -- se limpa dos vizinhos fixados
            []     -> Nothing -- nosso primeiro nothing, que vai propagar lá pra cima
            [x]    -> Just (FixedCell x) -- desejável, garante mais um passo antes de expandir dnv
            xs     -> Just (OpenCell xs)

splitTableAtMin :: Int -> Int -> Table -> (Table, Table)
splitTableAtMin len wid table =
    let (index, cell, cell') = splitMinCell table -- descobre onde quebrar
    in (replace index cell table (len*wid), replace index cell' table (len*wid)) -- substitui a quebra

    where
        flatTable table = zip [0..] (concat table) --lineariza a tabela

        splitMinCell table = splitCell $ minCell table
        minCell table = minimumBy (compare `on` (cellSize.snd)) $ filter (not.isFixed.snd) $ flatTable table -- procura a OpenCell com menos possibilidades
        cellSize (FixedCell _) = 1
        cellSize (OpenCell xs) = length xs
        splitCell (i, FixedCell _) = error "?" -- células já fixas não são expansíveis
        splitCell (i, OpenCell [x,y]) = (i, FixedCell x, FixedCell y) -- ponto chave da busca em profundidade, fixa a primeira possibilidade e tenta resolver
        splitCell (i, OpenCell (x:xs)) = (i, FixedCell x, OpenCell xs) -- pode ter mais que uma possibilidade restante, e essa célula pode expandir novamente em outra busca

        replace index cell table size = let idXY = (quot index size, mod index size) in
            [[if (x,y) == idXY then cell else c | (c, y) <- zip row [0..] ] | (row, x) <- zip table [0..]] -- substitui uma célula alvo no tabuleiro

isSolved :: Table -> Bool -- descobre se já foi solucionado, i.e., todas as células foram fixadas
isSolved table = [] == filter (not.isFixed) (concat table)
