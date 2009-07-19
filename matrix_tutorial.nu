(load "nubdd.nu")


; Begin Code

(macro-1 matrix (*lines)
  `(progn
    ()))

(macro-1 mult (*matrices)
  `(progn
    (set __matrixObjects (,*matrices map: (do (m) (Matrix makeMatrix:m))))))
; End Code

(mult 1 2)

; Begin Examples

(describe "Matrix"
  (describe "| Multiplication: "
    (describe (mult a b)
      (describe "where a is (1 0) (0 1)"
        (before 
          (set a (matrix ((1 0) (0 1)))))
        (describe ", and b equals a"
          (before 
            (set b a))
          (it should:(eql a))
          (it should:(eql b)))))))


; End Examples

($suite run_current)