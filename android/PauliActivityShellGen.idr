module PauliActivityShellGen

import Backend.DEX.EncodeNativeActivityShell
import System

%default covering

private
fail : String -> IO a
fail explanation = do
  putStrLn ("FAIL: " ++ explanation)
  exitFailure

main : IO ()
main = do
  result <-
    write_native_activity_shell_dex
      "Lorg/isomorphisms/pauli/PauliActivity;"
      "build/android/classes.dex"

  case result of
    Left explanation => fail explanation
    Right () =>
      putStrLn
        "PASS: direct Pauli NativeActivity classes.dex generated"
