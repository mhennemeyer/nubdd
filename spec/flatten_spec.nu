(load "spec_helper.nu")

(describe (flatten (list 1 2))
  (it should:(eql (list 1 2))))
  
(describe (flatten (list 1 2 3))
  (it should:(eql (list 1 2 3))))
  
(describe (flatten (list 1 (list 2 3)))
  (it should:(eql (list 1 2 3))))
  
(describe (flatten (list 1 (list 2 3) (list 4 (list 5 6 7 8) 9)))
  (it should:(eql (list 1 2 3 4 5 6 7 8 9)))

($suite run_current)