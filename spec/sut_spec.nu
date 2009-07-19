(load "spec_helper.nu")

(describe (+ 1 1)
  (it should:(eql 2)))

(describe (+ x 1)
  (it "returns 2 for x == 1"
    (set x 1)
    (sut should:(eql 2))))
    
(describe (+ x 1)
  (describe "with x == 1"
    (before
      (set x 1))
    (it should:(eql 2)))

  (describe "with x == 2"
    (before
      (set x 2))
    (it should:(eql 3))))
($suite run_current)