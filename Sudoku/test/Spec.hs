module Main where

import SudokuCell
import Test.Tasty
import Test.Tasty.HUnit 

main :: IO ()
main = 
  defaultMain tests


tests :: TestTree
tests = testGroup "Testes da Atividade 4" [celulaTest, rowTest, tableTest]
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
