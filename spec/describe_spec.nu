(load "spec_helper.nu")
;(class A is NSObject)

(describe (+ x 1)
  (before
    (set x 1))
    
  (it "returns 2 for x == 1"
    (sut should:(eql 2))))

($suite run_current)