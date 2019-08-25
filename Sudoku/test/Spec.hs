module Main where

import SudokuCell
import Lib
import Test.Tasty
import Test.Tasty.HUnit 

main :: IO ()
main = 
  defaultMain tests


tests :: TestTree
tests = testGroup "Testes da Atividade 4" [celulaTest, rowTest, tableTest, helperTest]
--SudokuCell
-- test_e1_1 = TestCase (do
--                      x <- diff "test/1.txt" "test/2.txt"
--                      assertEqual "Exercicio 1, teste 1" False x)

-- produtoEscalarTest = testGroup "produtoEscalar" 
--         [testCase "test1" (assertEqual "Test 1" 0 (produtoEscalar [0,0,0] [0,0,0] )),
--         testCase "test2" (assertEqual "Test 2" 0 (produtoEscalar [0,0,0] [1,1,1] )),
--         testCase "test2" (assertEqual "Test 3" 3 (produtoEscalar [1,1,1] [1,1,1] ))
--          ]

-- SudokuCell
celulaTest = testGroup "Leitura e escrita de Célula" 
        [
          testCase "Leitura - Celula Aberta" (assertEqual "Celula Aberta" (OpenCell []) (readCell "0")),
          testCase "Leitura - Celula Fechada" (assertEqual "Celula Fechada" (FixedCell 1) (readCell "1")),
          testCase "Escrita - Celula Aberta" (assertEqual "Celula Aberta" (show $ FixedCell 1) "1"),
          testCase "Escrita - Celula Fechada" (assertEqual "Celula Fechada" (show $ OpenCell [1,2,3]) "_")
        ]
rowTest = testGroup "Leitura e escrita de Linha" 
        [
          testCase "Leitura - Linha" (assertEqual "Linha" [OpenCell [], OpenCell [], FixedCell 5] (readRow ["0", "0", "5"])),
          testCase "Escrita - Linha" (assertEqual "Linha" "_ _ 5 \n" (showRow $ readRow ["0", "0", "5"]))
        ]
tableTest = testGroup "Leitura e escrita de Tabelas" 
        [
          testCase "Leitura - Tabela - Resize de OpenCell" 
          (assertEqual "Table" 
                [
                  [OpenCell [1,2,3], OpenCell [1,2,3],FixedCell 3],
                  [OpenCell [1,2,3],FixedCell 2, FixedCell 1]
                ] 
                (readTable 3 "0 0 3 0 2 1")),
          testCase "Escrita - Tabela" 
          (assertEqual "Table" 
                (showTable (readTable 3 "0 0 3 0 2 1"))
                "_ _ 3 \n_ 2 1 \n")
        ]

-- Lib

sampleRowOpen :: Row
sampleRowOpen = [OpenCell [5,4,3,2,1], FixedCell 1, FixedCell 2, FixedCell 3, FixedCell 4]

sampleRowOpen2 :: Row
sampleRowOpen2 = [OpenCell [5,4,3,2,1], OpenCell [5,4,3,2,1], FixedCell 2, FixedCell 3, FixedCell 4]

sampleRowOpen2_after :: Row
sampleRowOpen2_after = [OpenCell [5,1], OpenCell [5,1], FixedCell 2, FixedCell 3, FixedCell 4]

sampleRowFixed :: Row
sampleRowFixed = [FixedCell 5, FixedCell 1, FixedCell 2, FixedCell 3, FixedCell 4]

sampleTable :: Table
sampleTable = readTable 4 "0 2 3 4 3 4 0 2 2 1 4 3 4 3 0 0"

sampleTableCol :: Table
sampleTableCol = [[FixedCell 1, FixedCell 2, FixedCell 3     , FixedCell 4],
                  [FixedCell 3, FixedCell 4, OpenCell [1,2], FixedCell 2],
                  [FixedCell 2, FixedCell 1, FixedCell 4     , FixedCell 3],
                  [FixedCell 4, FixedCell 3, OpenCell [1,2], FixedCell 1]]

helperTest = testGroup "Métodos auxiliares"
          [
            testCase "isFixed - Open" (assertEqual "Não é fixo" False (isFixed (OpenCell [1,2,3]))),
            testCase "isFixed - Fixed" (assertEqual "É fixo" True (isFixed (FixedCell 1))),
            testCase "checkRow - Única possível" (assertEqual "Encontrou única célula sem solução e resolveu" (Just sampleRowFixed) (checkRow sampleRowOpen)),
            testCase "checkRow - Filtro" (assertEqual "Somente tirou possibilidades incongruentes" (Just sampleRowOpen2_after) (checkRow sampleRowOpen2)),
            testCase "checkForCols" (assertEqual "Retirou possibilidades e marcou um valor" (Just sampleTableCol) (checkForCols (Just sampleTable)))
          ]