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