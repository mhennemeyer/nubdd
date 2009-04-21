(load "matchers.nu")

(puts "---")

; (function untree (obj collSym)
;   (function _untree (obj collSym) 
;     ())
;   (set list ())
;   )

(class Suite is NSObject
  (ivar (id) exampleGroups)
  (ivar-accessors)
  
  (imethod (id) addExampleGroup:(id)exampleGroup is
    (unless (self exampleGroups)
      (self setExampleGroups:(NSMutableArray new)))
    ((self exampleGroups) addObject:exampleGroup))
    
  (imethod (id) run is
    (set groups (self exampleGroups)) ;untree all groups here
    (groups each: (do (eg)
      (set $current_example_group eg)
      (eg expand)
      (eg run)))))
      

(class Example is NSObject
  (ivar (id) descriptivestring
        (id) body)
  (ivar-accessors)
  
  (imethod (id) pass:(id)matcher is
    ;; ToDo Report
    (puts "-#{(self descriptivestring)}"))
    
  (imethod (id) fail:(id)matcher is
    ;; ToDo Report
    (puts "F -#{(self descriptivestring)}: FAILED")))
 
    
(class ExampleGroup is NSObject
  (ivar (id) sut
        (id) body
        (id) examples
        (id) exampleGroups
        (id) before
        (id) after
        (id) descriptiveArray)
  (ivar-accessors)
  
  (imethod (id) addDescription:(id)description is
    (unless (self descriptiveArray)
      (self setDescriptiveArray:(NSMutableArray new)))
    ((self descriptiveArray) addObject:description))
  
  (imethod (id) addExample:(id)example is
    (unless (self examples)
      (self setExamples:(NSMutableArray new)))
    ((self examples) addObject:example))
    
  (imethod (id) addExampleGroup:(id)exampleGroup is
    (unless (self exampleGroups)
      (self setExampleGroups:(NSMutableArray new)))
    ((self exampleGroups) addObject:exampleGroup))
    
  (imethod (id) addBefore:(id)body is
    (unless (self before)
      (self setBefore:body)
      (else
        (self setBefore:(append (self before) body)))))
        
  (imethod (id) addAfter:(id)body is
    (unless (self after)
      (self setAfter:body)
      (else
        (self setAfter:(append (self after) body)))))
    
  (imethod (id) expand is
    ((self body)))
    
  (imethod (id) run is
    (puts ((self sut) description))
    ((self examples) eachWithIndex:(do (e i)
      (set $current_running_example e)
      (set list (append (self before) 
                        (e body) 
                        (self after)))
      (while list
        (eval (car list))
        (set list (cdr list)))))))




(class NSObject
  (imethod (id) should:(id)matcher is
    (set result (matcher matches:self))
    (if result
      ($current_running_example pass:matcher)
      (else ($current_running_example fail:matcher))))
      
  (imethod (id) should_not:(id)matcher is
    (set result (matcher matches:self))
    (if result
      ($current_running_example fail:matcher)
      (else ($current_running_example pass:matcher)))))
      
      
(macro-1 it (descriptivestring *body)
  `(progn
    (if $current_example ($current_example release))
    (set $current_example (Example new))
    ($current_example setDescriptivestring:,descriptivestring)
    ($current_example setBody:(quote ,*body))
    ($current_example_group addExample:$current_example)))
    
(macro-1 describe (sut *body)
  `(progn
    (set __group (ExampleGroup new))
    (__group setSut:,sut)
    (__group setBody:(do () ,@*body))
    (if $current_example_group
      ($current_example_group addExampleGroup:__group))
    (set $current_example_group __group)
    (unless $suite
      (set $suite (Suite new))
      ($suite addExampleGroup:$current_example_group))))

(macro-1 before (*body)
  `($current_example_group addBefore:(quote ,*body)))
  
(macro-1 after (*body)
  `($current_example_group addAfter:(quote ,*body)))

(describe "He"
  (before
    (set a "Hello"))
  
  (after
    (set a nil))
    
  (it "says Hello"
    (a should:(eql "Hello")))
    
  (describe "without 'l's"
    (before
      (a replaceOccurrencesOfString:"l" 
                         withString:"" 
                            options:nil 
                              range:(list 0 (a length))))
      
    (it "says Heo"
      (a should:(eql "Heo"))))

  (it "won't say World"
    (a should_not:(eql "World"))))



($suite run)


; (describe A
;   (before all
;     (set a "all")
;     (s))
;   (before suite
;     (set s "suite"))
;   (before each
;     (set e "each")
;     (a)
;     (s))
;   (it "solves a lot of problems"
;     (a)
;     (e)
;     (s))
(puts "---")