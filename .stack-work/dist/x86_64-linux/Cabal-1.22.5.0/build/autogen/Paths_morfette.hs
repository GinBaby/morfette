module Paths_morfette (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,4,3] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/jmo/projects/morfette/.stack-work/install/x86_64-linux/lts-6.14/7.10.3/bin"
libdir     = "/home/jmo/projects/morfette/.stack-work/install/x86_64-linux/lts-6.14/7.10.3/lib/x86_64-linux-ghc-7.10.3/morfette-0.4.3-4EpJNyEuuQ63WeqBn9w2Vs"
datadir    = "/home/jmo/projects/morfette/.stack-work/install/x86_64-linux/lts-6.14/7.10.3/share/x86_64-linux-ghc-7.10.3/morfette-0.4.3"
libexecdir = "/home/jmo/projects/morfette/.stack-work/install/x86_64-linux/lts-6.14/7.10.3/libexec"
sysconfdir = "/home/jmo/projects/morfette/.stack-work/install/x86_64-linux/lts-6.14/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "morfette_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "morfette_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "morfette_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "morfette_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "morfette_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
