(load "spec_helper.nu")

(describe "untree"
  (before
    (class ClassWithColl is NSObject
      (ivar (id) coll)
      (ivar-accessors)
      (imethod (id) addObj:(id)obj is
        (unless (self coll)
          (self setColl:(array nil)))
        ((self coll) addObject:obj)))
    (set objWithColl (ClassWithColl new)))
  (it "returns (a b c) for (untree obj 'coll) and (obj coll) => (a b c)"
    ('(a b c) each: (do (obj) 
      (objWithColl addObj:obj)))
    ()))
    
    
($suite run_current)

(function flatten (l)
  (if (atom l)
    l
    (else (if (atom (car l)) 
            (cons (car l) (flatten (cdr l)))
            (else (append (flatten (car l)) (flatten (cdr l))))))))
    

(puts (flatten (list (list 1 2) (list 6 7 (list 1 2)) 3 (list 4 5) 6)))

(function untree (arr)
  (set arr (arr list))
  (function iter (eg)
    (set groups (eg groups))
    (if (eq groups nil) 
      eg
      (else 
        (cons eg 
              ((groups map:iter) list)))))
  (flatten (arr map: (do (e) (iter e)))))
    
(class EG is NSObject
  (ivar (id) groups)
  (ivar-accessors)
  (imethod (id) addGroup:(id)group is
    (unless (self groups)
      (self setGroups:(NSMutableArray new)))
    ((self groups) addObject:group)))
      
(set eg1 (EG new))
(3 times: (do (i) (eg1 addGroup:(EG new))))
((eg1 groups) each: (do (eg) 
  (3 times: (do (i) (eg addGroup:(EG new))))))

(puts (untree (array eg1)))