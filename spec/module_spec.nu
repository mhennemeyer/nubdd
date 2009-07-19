(load "spec_helper.nu")

(class Modules is NSObject
  (ivar (id) modules)
  (ivar-accessors)
  
  (imethod (id) addModule:(id) mod is
    (unless (self modules)
      (self setModules:(dict)))
      ;Todo add code to existing module definition. aka Reopening Module
    ((self modules) setObject:mod forKey:(mod name)))
  
  (cmethod (id) addModule:(id) mod is
    (unless $__modules_instance
      (set $__modules_instance (Modules new)))
    ($__modules_instance addModule:mod))
    
  (cmethod (id) findByName:(id) name is
    (($__modules_instance modules) objectForKey:name)))
 
  
(class Module is NSObject
  (ivar (id) body
        (id) name)
  (ivar-accessors))
    
(macro-1 module (name *body)
  `(progn
    (set __m (Module new))
    (set __name (quote ,name))
    (set __name ":#{__name}")
    (if $__current_namespace
      (set __name (+ $__current_namespace  __name)))
    (__m setName:__name)
    (__m setBody:(quote (progn ,@*body)))
    (Modules addModule:__m)))

(macro-1 importModule (*name)
  `(progn
    (set __name "")
    (set __names (quote ,*name))
    (__names each: (do (n) (set __name (+ __name ":" n))))
    (set __m (Modules findByName:__name))
    (set __namespace $__current_namespace)
    (set $__current_namespace __name)
    (eval (__m body))
    (set $__current_namespace __namespace)))
    
(describe "Namespacing with Modules"
  (before 
    (module A (set greeting "Hello")))
  (describe "not imported"
    (it "knows nothing about symbols defined in module."
      ((proc greeting) should:(raiseError))))
      
  (describe "imported"
    (it "knows symbols defined in module."
      (importModule A)
      (greeting should:(eql "Hello"))))
      
  (describe "nested"
    (before 
      (module A  
        (set a "a") 
        (module B 
          (set b "B"))))
    (it "importModule A B"
      (importModule A)
      (importModule A B)
      (b should:(eql "B")))))
  
($suite run_current)