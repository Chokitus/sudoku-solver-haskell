module Main where

import SudokuCell
import Lib
import Test.Tasty
import Test.Tasty.HUnit 

main :: IO ()
main = 
  defaultMain tests


tests :: TestTree
tests = testGroup "Testes da Atividade 4" [celulaTest, rowTest, tableTest, helperTest, effectiveTest]
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
sampleTableCol = [
                    [FixedCell 1, FixedCell 2, FixedCell 3   , FixedCell 4],
                    [FixedCell 3, FixedCell 4, OpenCell [1,2], FixedCell 2],
                    [FixedCell 2, FixedCell 1, FixedCell 4   , FixedCell 3],
                    [FixedCell 4, FixedCell 3, OpenCell [1,2], FixedCell 1]
                  ]

sampleTableRect :: Table
sampleTableRect = [
                    [FixedCell 1, FixedCell 2, FixedCell 3    , FixedCell 4   ],
                    [FixedCell 3, FixedCell 4, FixedCell 1    , FixedCell 2   ],
                    [FixedCell 2, FixedCell 1, FixedCell 4    , FixedCell 3   ],
                    [FixedCell 4, FixedCell 3, OpenCell [1,2] , OpenCell [1,2]]
                  ]

helperTest = testGroup "Métodos auxiliares"
          [
            testCase "isFixed - Open" (assertEqual "Era fixo" False (isFixed (OpenCell [1,2,3]))),
            testCase "isFixed - Fixed" (assertEqual "Não era Fixo" True (isFixed (FixedCell 1))),
            testCase "checkRow - Única possível" (assertEqual "Não encontrou a solução única" (Just sampleRowFixed) (checkRow sampleRowOpen)),
            testCase "checkRow - Filtro" (assertEqual "Não tirou as possibilidades" (Just sampleRowOpen2_after) (checkRow sampleRowOpen2)),
            testCase "checkForCols" (assertEqual "Não retirou as possibilidades ou não marcou o valor" (Just sampleTableCol) (checkForCols (Just sampleTable))),
            testCase "checkForRects" (assertEqual "Não retirou as possibilidades ou não marcou o valor" (Just sampleTableRect) (checkForRects 2 2 (Just sampleTable))),
            testCase "isSolved - Não resolvido" (assertEqual "Percebeu que estava resolvido" False (isSolved sampleTable)),
            testCase "isSolved - resolvido" (assertEqual "Percebeu que estava resolvido" True (isSolved $ readTable 4 "1 2 3 4 3 4 1 2 2 1 4 3 4 3 2 1"))
          ]
  
effectiveTest = testGroup "Método principal"
          [
            testCase "Resolver 2x2 - 1" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve sampleTable 2 2)),
            testCase "Resolver 2x2 - 2" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 4  "3 0 0 0 0 1 4 0 0 3 0 0 0 0 1 4") 2 2)),
            testCase "Resolver 2x2 - 3" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 4  "3 0 0 0 0 0 2 0 0 1 0 0 0 0 0 2") 2 2)),
            testCase "Resolver 3x3 - 1" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "0 9 0 8 0 6 0 4 5 5 7 0 2 0 1 0 9 3 0 0 4 3 0 0 7 0 6 3 4 9 0 6 0 0 1 0 0 0 0 1 0 0 0 0 9 0 0 0 0 0 5 2 7 0 0 6 0 0 0 0 9 0 0 8 0 1 4 0 7 0 5 0 0 5 2 0 0 0 0 8 0") 3 3)),
            testCase "Resolver 3x3 - 2" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "0 0 7 0 2 0 0 0 9 0 0 5 0 8 7 0 6 2 1 9 0 3 0 0 0 0 0 0 8 3 4 0 0 6 5 0 0 0 0 5 0 9 0 1 0 0 0 0 0 7 0 4 0 0 0 1 0 8 4 0 3 0 0 7 0 0 0 6 1 0 4 0 0 5 6 0 0 3 8 0 0") 3 3)),
            testCase "Resolver 3x3 - 3" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "0 2 6 0 0 4 0 3 0 0 7 0 9 0 0 1 0 8 0 0 9 0 8 0 7 2 0 0 6 0 3 0 0 0 4 5 3 0 8 0 5 1 9 0 6 0 0 7 0 0 0 0 0 0 5 0 3 0 4 0 0 9 7 0 0 0 0 0 6 0 0 0 0 1 4 8 0 9 2 0 0") 3 3)),
            testCase "Resolver 3x3 - 4" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "0 0 0 2 6 0 0 0 1 0 0 8 0 3 0 9 0 0 0 4 0 0 0 7 3 5 0 4 0 5 0 0 0 7 0 0 0 0 9 0 1 5 0 0 6 2 0 0 0 8 0 0 3 0 0 8 0 0 0 2 6 1 9 6 7 0 9 0 0 4 0 0 3 0 0 1 0 0 0 8 0") 3 3)),
            testCase "Resolver 3x3 - 5" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "7 0 0 0 0 1 3 2 0 2 6 0 0 9 5 0 0 8 1 0 8 4 0 0 0 9 0 0 1 0 8 0 0 5 0 0 4 0 3 1 5 2 0 0 6 0 9 0 7 0 0 0 4 0 0 0 0 0 0 0 0 7 3 0 0 0 0 0 6 8 0 0 0 0 0 5 3 4 0 0 1") 3 3)),
            testCase "Resolver 3x3 - 6" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 9  "7 0 0 0 0 2 9 0 5 0 2 1 4 0 0 6 0 0 0 8 0 0 3 0 0 0 0 0 0 3 0 4 0 0 7 2 0 0 0 1 9 0 0 0 4 6 5 0 0 0 8 0 1 0 4 0 7 0 0 5 1 0 0 8 0 0 0 0 0 7 2 3 9 3 0 0 8 0 0 0 6") 3 3)),
            testCase "Resolver 4x4 - 1" (assertEqual "Não foi capaz de resolver" True (isSolved $ solve (readTable 16 "0 0 0 14 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 0 0 8 0 0 9 10 0 0 16 0 0 11 0 0 0 0 0 16 15 0 0 2 0 0 8 0 0 0 8 0 0 0 0 12 11 16 0 14 0 3 0 0 0 8 0 0 7 10 0 0 0 0 14 15 16 0 0 3 0 0 0 0 0 0 0 9 0 13 0 11 0 16 0 15 14 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 15 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 10 0 14 11 0 0 1 2 0 15 1 0 15 16 3 0 6 0 0 7 0 0 0 0 12 11 9 0 0 0 0 0 0 13 0 0 16 1 0 0 4 0 0 0 0 0 0 0 2 0 6 0 0 0 0 10 8 7 0 0 0 0 12 13 15 0 3 16 0 0 0 0 5 0 0 0 0 13 0 0 0 0 7 4 5 6 10 0 0 0 0 3 0 0 0 5 0 0 0 0 9 0 0 0 13 0 6 0 4 0 0 0 0 10 0 12 0 0 2 0 0 0") 4 4))
          ]