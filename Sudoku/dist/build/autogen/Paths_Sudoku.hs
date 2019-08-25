{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_Sudoku (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/victor/.cabal/bin"
libdir     = "/home/victor/.cabal/lib/x86_64-linux-ghc-8.0.2/Sudoku-0.1.0.0-EFdkTAVUaYUJ8iLjRVLQFg"
dynlibdir  = "/home/victor/.cabal/lib/x86_64-linux-ghc-8.0.2"
datadir    = "/home/victor/.cabal/share/x86_64-linux-ghc-8.0.2/Sudoku-0.1.0.0"
libexecdir = "/home/victor/.cabal/libexec"
sysconfdir = "/home/victor/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Sudoku_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Sudoku_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Sudoku_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Sudoku_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Sudoku_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Sudoku_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
