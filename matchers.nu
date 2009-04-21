(class Matcher is NSObject
  (ivar (id) name
        (id) block
        (id) args)
  (ivar-accessors)
  
  (imethod (id) matches:(id)receiver is
    (set result ((self block) receiver self (self args)))
    (result)))


(macro-1 def_matcher (name block)
  `(function ,name (*args) 
    (set __matcher (Matcher new))
    (__matcher setName: ,name)
    (__matcher setBlock: ,block)
    (__matcher setArgs: *args)
    (__matcher)))


(def_matcher eql
  (do (receiver matcher args) 
    (eq receiver (args 0))))