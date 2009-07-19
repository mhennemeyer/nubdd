(load "spec_helper.nu")

(describe "He"
  (before
    (set a "Hello"))
  
  (after
    (set a nil))
    
  (it "says Hello"
    (a should:(eql "Hello")))
    
  (it "knows 1 + 1"
    ((+ 1 1) should:((eql 2))))
    
  (describe "without 'l's"
    (before
      (a replaceOccurrencesOfString:"l" 
                         withString:"" 
                            options:nil 
                              range:(list 0 (a length))))
      
    (it "says Heo"
      (a should:(eql "Heo")))
      
    (describe "One more Time"
      (it "says Heo"
        (a should:(eql "Heo")))))

  (it "won't say World"
    (a should_not:(eql "World"))))

($suite run_current)