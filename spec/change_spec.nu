(load "spec_helper.nu")
  

(describe "Change Matcher"
  (describe (proc (a addObject:2))
    (before 
	    (set a (array)))
    (it should:(change (a count))))
    
  (describe (proc (s replaceOccurrencesOfString:"l" 
                                     withString:"" 
                                        options:nil 
                                          range:(list 0 (s length))))
    (before 
      (set s "Hello"))
    (it should:(change s))))
      
($suite run_current)