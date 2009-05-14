(load "spec_helper.nu")

(describe "raiseError Matcher:"
  (describe (proc (undefinedSymbol))
    (it should:(raiseError "NuUndefinedSymbol"))))


($suite run_current)