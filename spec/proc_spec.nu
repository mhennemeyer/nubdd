(load "spec_helper.nu")

(describe "Proc Objects"

  (it "defers evaluation of its body"
    ((proc (nonexisting sym)) should_not:(eql nil)))
    
  (describe ((proc ("hello")) evalBody)
    (it should:(eql "hello")))
  
  (describe "act as implicit progn:"
    (describe ((proc (set a "a") (set b a)) evalBody)
      (it should:(eql "a")))))

($suite run_current)