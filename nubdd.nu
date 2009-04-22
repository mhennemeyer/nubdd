;; NuBDD is a lightweight BDD Framework for 
;; the Nu Programming Language

;; Matchersystem
(class Matcher is NSObject
  (ivar (id) name
        (id) block
        (id) args
        (id) expectation
        (id) negativeMessage
        (id) positiveMessage)
  (ivar-accessors)
  
  (imethod (id) message is
    (if (eq (self expectation) 'should) (self positiveMessage)
      (else (self negativeMessage))))
  
  (imethod (id) matches:(id)receiver is
    ((self block) receiver self (self args))))
    
(macro-1 def_matcher (name block)
  `(function ,name (*args) 
    (set __matcher (Matcher new))
    (__matcher setName: ,name)
    (__matcher setBlock: ,block)
    (__matcher setArgs: *args)
    (__matcher)))
;; END Matchersystem


;; Matcherdefinitions
(def_matcher eql
  (do (receiver matcher args)
    (matcher setPositiveMessage:"Expected #{receiver} to eql #{(args 0)}")
    (matcher setNegativeMessage:"Expected #{receiver} not to eql #{(args 0)}")
    (eq receiver (args 0))))
;; END Matcherdefinitions


;; Helpers


; (function untree (obj collSym)
;   (function _untree (obj collSym) 
;     ())
;   (set list ())
;   )

;; END Helpers


;; Extensions
(class NSObject
  (imethod (id) should:(id)matcher is
    (matcher setExpectation:'should)
    (set result (matcher matches:self))
    (if result
      ($current_running_example pass:matcher)
      (else ($current_running_example fail:matcher))))
      
  (imethod (id) should_not:(id)matcher is
    (matcher setExpectation:'should_not)
    (set result (matcher matches:self))
    (if result
      ($current_running_example fail:matcher)
      (else ($current_running_example pass:matcher)))))
;; END Extensions      


;; Fundamental Classes
(class Suite is NSObject
  (ivar (id) exampleGroups)
  (ivar-accessors)
  
  (imethod (id) addExampleGroup:(id)exampleGroup is
    (unless (self exampleGroups)
      (self setExampleGroups:(NSMutableArray new)))
    ((self exampleGroups) addObject:exampleGroup))
    
  (imethod (id) run_current is
    (set groups (self exampleGroups)) ;untree all groups here
    (groups each: (do (eg)
      (set $current_example_group eg)
      (eg expand)
      (eg run)))))
      
      
(class Example is NSObject
  (ivar (id) descriptiveStringOrExpectation
        (id) body)
  (ivar-accessors)
  
  (imethod (id) pass:(id)matcher is
    ;; ToDo Report
    (puts "  * #{(self descriptiveStringOrExpectation)}"))
    
  (imethod (id) fail:(id)matcher is
    ;; ToDo Report
    (puts "  F  #{(self descriptiveStringOrExpectation)}: FAILED #{(matcher message)}")))

    
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
    (puts (self sut))
    ((self examples) eachWithIndex:(do (e i)
      (set $current_running_example e)
      (set list (append (self before)
                        (if (eq "should:" ((e descriptiveStringOrExpectation) description))
                          (e setDescriptiveStringOrExpectation:(car (e body)))
                          (parse "(#{(self sut)} should:#{(car (e body))})" )
                          (else (e body)))
                        (self after)))
      (while list
        (eval (car list))
        (set list (cdr list)))))))
;; END Fundamental Classes


;; DSL    
(macro-1 it (descriptiveStringOrExpectation *body)
  `(progn
    (if $current_example ($current_example release))
    (set $current_example (Example new))
    ($current_example setDescriptiveStringOrExpectation:(quote ,descriptiveStringOrExpectation))
    ($current_example setBody:(quote ,*body))
    ($current_example_group addExample:$current_example)))

(macro-1 sut (*body)
  `(progn
    (puts "Hello")))
        
(macro-1 describe (sut *body)
  `(progn
    (set __group (ExampleGroup new))
    (__group setSut:(quote ,sut))
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
;; END DSL