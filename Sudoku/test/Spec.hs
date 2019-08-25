module Main where

    import SudokuCell
    import Test.Tasty
    import Test.Tasty.HUnit 
    
    main :: IO ()
    main = defaultMain tests

    tests :: TestTree
    tests = testGroup "Testes" [produtoEscalarTest]
    
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
    produtoEscalarTest = testGroup "Leitura de Célula" 
            [
              testCase "Celula Aberta" (assertEqual "Celula Aberta" (OpenCell []) (readCell "0"))
            ]