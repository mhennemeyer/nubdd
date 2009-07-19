(load "spec_helper.nu")

(class Mocking is NSObject
  (cmethod (id) setExpectationOnObject:(id) obj
                                   msg:(id) msgSym
                              withArgs:(id) argsList
                             andReturn:(id) returnValue
                                 times:(id) times
                                    is ()
    ))

(class NSObject
  (imethod (id) shouldReceive:(id) msg 
                     withArgs:(id) argsList
                    andReturn:(id) returnValue
                        times:(id) times is 
    (Mocking setExpectationOnObject:self
                                msg:msg
                           withArgs:argsList
                          andReturn:returnValue
                              times:times)
    ))

(describe "Mocking"
  (it "should stub the method"
    (set arr (array 1))
    (arr shouldReceive:'helloArray
              withArgs:()
             andReturn:"Hello Example"
                 times:'any)
    ((arr helloArray) should:(eql "Hello Example"))))
    
($suite run_current)