;; NuBDD is a lightweight Testing Framework for 
;; the Nu Programming Language

;; Helpers
;; Helper Functions

(function flatten (l)
  (if (atom l)
    l
    (else (if (atom (car l)) 
            (cons (car l) (flatten (cdr l)))
            (else (append (flatten (car l)) (flatten (cdr l))))))))

(function untree (arr)
  (set arr (arr list))
  (function iter (eg)
    (set groups (eg exampleGroups))
    (if (eq groups nil) 
      eg
      (else 
        (cons eg 
              ((groups map:iter) list)))))
  (flatten (arr map: (do (e) (iter e)))))
  
; END Helper Functions

; Helper Classes

(class Proc is NSObject
  (ivar (id) body)
  (ivar-accessors)
    
  (imethod (id) evalBody is
    (eval (self body))))


(macro-0 proc
  (progn
    (set __p (Proc new)) ;todo mm
    (__p setBody: (append '(progn (unquote (car margs))) (cdr margs)))
    __p))

;; END Helper Classes


;; END Helpers


;; Matchersystem
;todo buildMatcher
(class Matcher is NSObject
  (ivar (id) name
        (id) block
        (id) args
        (id) expectation
        (id) negativeMessage
        (id) positiveMessage
        (id) sut)
  (ivar-accessors)
  
  (imethod (id) message is
    (if (eq (self expectation) 'should) (self positiveMessage)
      (else (self negativeMessage))))
  
  (imethod (id) matches:(id) receiver is
    ((self block) receiver self (self args))))

;Define simple matchers with matcher   
(macro-0 matcher 
  (function (unquote (car margs)) (*args) 
    (set __matcher (Matcher new)) ;todo mm
    (__matcher setName: (unquote (car margs)))
    (__matcher setBlock: (unquote (car (cdr margs))))
    (__matcher setArgs: *args)
    (__matcher)))
; END Matchersystem


; Matcherdefinitions

; eql
; (1 should:(eql 1))
(matcher eql
  (do (receiver matcher args)
    (matcher setPositiveMessage:"Expected #{(args 0)}, but was #{receiver}")
    (matcher setNegativeMessage:"Expected not #{(args 0)}")
    (eq receiver (args 0))))
    
; change matcher is a macro,
; to prevent the applied expression from 
; beeing evaluated.
; Examples:
;  ((proc (a addObject:1)) should:(change (a count)))
(macro-0 change
  (progn
    (set __block 
      (do (receiver matcher args)
        (set subject (args 0))
        (set action (receiver body))
        (set before ((eval subject) copy))
        (set after ((progn (eval action) (eval subject)) copy))
        (matcher setPositiveMessage:"#{(cdr action)} didn't change #{subject}.")
        (matcher setNegativeMessage:"#{(cdr action)} changed #{subject} unexpectedly.")
        (not (eq before after))))
    (set __m (Matcher new))
    (__m setName: change)
    (__m setBlock: __block)
    (__m setArgs: '(unquote margs))
    __m))
  

; raiseError
; Examples
;   ((proc undefinedSymbol) should:raiseError "NuUndefinedSymbol")
(matcher raiseError
  (do (receiver matcher args)
    (set e ())
    (try
      (receiver evalBody)
      (catch (e) (set __blew e)))
    (matcher setPositiveMessage:"Expected #{(args 0)} to raise an Error")
    (matcher setNegativeMessage:"#{(receiver body)} blew up: #{(e name)}")
    (if (args 0)
      (eq (e name) (args 0))
      (else e))))

;; END Matcherdefinitions


;; Extensions
(class NSObject
  (imethod (id) should:(id) matcher is
    (matcher setExpectation:'should)
    (set result (matcher matches:self))
    (if result
      ($current_running_example pass:matcher)
      (else ($current_running_example fail:matcher))))
      
  (imethod (id) should_not:(id) matcher is
    (matcher setExpectation:'should_not)
    (set result (matcher matches:self))
    (if result
      ($current_running_example fail:matcher)
      (else ($current_running_example pass:matcher)))))
; END Extensions      


;; Fundamental Classes
(class Suite is NSObject
  (ivar (id) exampleGroups)
  (ivar-accessors)
  
  (imethod (id) group? is ())
  
  (imethod (id) descriptionList is ())
  
  (imethod (id) currentSut is ())
  
  (imethod (id) addExampleGroup:(id) exampleGroup is
    (unless (self exampleGroups)
      (self setExampleGroups:(array)))
    ((self exampleGroups) addObject:exampleGroup)
    (exampleGroup addParent:self))
    
  (imethod (id) run_current is
    (set groups (self exampleGroups))
    (groups each: (do (eg)
      (set $current_example_group eg)
      (eg expand)))
    ((untree groups) each: (do (eg) (eg run)))))
      
      
(class Example is NSObject
  (ivar (id) descriptiveStringOrExpectation
        (id) body)
  (ivar-accessors)
  
  (imethod (id) pass:(id) matcher is
    ;; ToDo Report
    (puts "  * #{(self descriptiveStringOrExpectation)}"))
    
  (imethod (id) fail:(id) matcher is
    ;; ToDo Report
    (puts "  F  #{(self descriptiveStringOrExpectation)}: FAILED : #{(matcher message)}")))

    
(class ExampleGroup is NSObject
  (ivar (id) sut   ; System Under Test
        (id) body
        (id) examples
        (id) exampleGroups
        (id) parent
        (id) before
        (id) after
        (id) descriptiveArray)
  (ivar-accessors)
  
  ; Todo Remove
  (imethod (id) addDescription:(id) description is
    (unless (self descriptiveArray)
      (self setDescriptiveArray:(array)))
    ((self descriptiveArray) addObject:description))
  
  (imethod (id) addExample:(id) example is
    (unless (self examples)
      (self setExamples:(array)))
    ((self examples) addObject:example))
    
  (imethod (id) addExampleGroup:(id) exampleGroup is
    (unless (self exampleGroups)
      (self setExampleGroups:(array)))
    ((self exampleGroups) addObject:exampleGroup)
    (exampleGroup addParent:self))
  
  (imethod (id) group? is t)
  
  (imethod (id) currentSut is
    (if (/^\((.*)\)/ findInString:"#{(self sut)}") 
          (self sut)
          (else ((self parent) currentSut))))
  
  (imethod (id) descriptionList is
    (append ((self parent) descriptionList) (list (self sut))))
  
  (imethod (id) addParent:(id) parent is
    (self setParent:parent)
    (if (parent group?)
      (self addBefore:(parent before))
      (self addAfter:(parent after)))
    (self addDescription:(self sut)))
      
  (imethod (id) addBefore:(id) body is
    (unless (self before)
      (self setBefore:body)
      (else
        (self setBefore:(append (self before) body)))))
        
  (imethod (id) addAfter:(id) body is
    (unless (self after)
      (self setAfter:body)
      (else
        (self setAfter:(append (self after) body)))))
    
  (imethod (id) expand is
    (eval (self body))
    ((self exampleGroups) each: (do (eg)
      (set $current_example_group eg)
      (eg expand))))
    
  (imethod (id) run is
    (if (self examples) 
      (puts (self descriptionList)) ; Report
      ((self examples) each:(do (e)
        (set $current_running_example e)
        (set __list (list 'progn (self before)
                          (if (eq "should:" ((e descriptiveStringOrExpectation) description))
                            (e setDescriptiveStringOrExpectation:(cdr (e body)))
                            (parse "(#{(self currentSut)} should:#{(cdr (e body))})" )
                            (else (e body)))
                          (self after)))
        (eval __list) )))))
; END Fundamental Classes


;;  DSL    

(macro-0 it
  (progn
    (set $current_example (Example new))
    ($current_example setDescriptiveStringOrExpectation:'(unquote (car margs)))
    ($current_example setBody:(append '(progn (unquote  (car (cdr margs))))  (cdr (cdr margs))))
    ($current_example_group addExample:$current_example)))

(macro-0 sut
    (eval (parse "((eval (self sut)) #{(car margs)}#{(cdr margs)})")))

(macro-0 describe
  (progn
    (set __group (ExampleGroup new))
    (__group setSut:'(unquote (car margs)))
    (set __body (append '(progn (unquote (car (cdr margs)))) (cdr (cdr margs))))
    (__group setBody:__body)
    (unless $suite
      (set $suite (Suite new)))
    (if $current_example_group
      ($current_example_group addExampleGroup:__group)
      (else ($suite addExampleGroup:__group)))))

(macro-0 before
  ($current_example_group addBefore:(append '(progn (unquote  (car margs)))  (cdr margs))))
  
(macro-0 after
  ($current_example_group addAfter:(append '(progn (unquote  (car margs)))  (cdr margs))))
;; END DSL