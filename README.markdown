# NuBdd

    (describe NuBdd
			(it should:(be "a lightweight Testing Framework for Nu")))

NuBdd is a lightweight Testing Framework for the [Nu Programming Language](http://programming.nu).   
It is heavily inspired by [RSpec](http://rspec.info).


## Installation

For now:   
  Just Copy the nubdd.nu file to an appropriate location inside your project.
  

## Usage

Say there is a project _myProject_ and the source code to test lives in `myProject/lib/myProject.nu`.

* Create a "spec"-Folder inside your project: myProject/spec
* Create a `spec_helper.nu` file in myProject/spec.
* Load the code that you want to test. In `spec_helper.nu`: `(load "../lib/myProject.nu")`
* Create a spec file: `myProject/spec/myProject_spec.nu`
* Load the `spec_helper.nu` file in any spec file at first.
* If you want to run the test suite with the plain Nu Interpreter, 
  you have to add `($suite run_current)` as the last statement in each of your spec files.
  If you are using TextMate, you can run all tests in a file 
  by hitting Cmd-R and you will be shown a result window.


## Features:

### Matcher System

* Build Expectations by sending an object the 'should' or 'should_not' Messages.
* Use NuBdd's built in Matchers: change, eql, `raise_error`
* Build your own custom matchers for special cases. This can save you   
  from writing hundreds of lines of meaningless test-setUp code.

### Nested Example Group

* You can build a tree strucure of example groups, where all setup and teardown code will
  be executed in the obvious order. (The very same way it is done in RSpec)

### Implicit (magical) SUT facility

Inside an example group you can directly refer to the system under test, that is
given as the first argument to the example group: 

	(describe (+ 1 1)
	  (it should:(eql 2)))
	
You can even specify placeholders inside the SUT:

	(describe (+ x 1)
	  (it "returns 2 for x == 1"
	    (set x 1)
	    (sut should:(eql 2)))
    (it "returns 5 for x == 4"
	    (set x 4)
	    (sut should:(eql 5))))

## Built in matchers - Quick ShowCase

### eql 

	(1 should:(eql 1))
	(1 should_not:(eql 2))

### change

	(describe (proc (a addObject:2))
    (before 
	    (set a (array)))
    (it should:(change (a count))))

### `raise_error`

	(describe "raiseError Matcher:"
	  (describe (proc (undefinedSymbol))
	    (it should:(raiseError "NuUndefinedSymbol"))))

## Custom Matchers

Custom matchers are easily made with the matcher macro.

### Example: eql-Matcher

    (matcher eql
		  (do (receiver matcher args)
		    (matcher setPositiveMessage:"Expected #{(args 0)}, but was #{receiver}")
		    (matcher setNegativeMessage:"Expected not #{(args 0)}")
		    (eq receiver (args 0))))
      
## Thanks to

* Tim Burks for the Nu Programming Language.
* John McCarthy for Lisp.
* Brad Cox for Objective C.
* Yukihiro Matsumoto for Ruby.
* David Chelimsky, Dave Astels, Dan North, Pat Maddox, Steven Baker, Aslak Hellesoy et.al. for RSpec.
* Aslak Hellesoy, David Chelimsky and Dan North for RBehave/RSpecUserStories/Cucumber.
* Dan North for BDD.
* Kent Beck for TDD.

## Links

* [Nu](http://programming.nu)
* [RSpec](http://rspec.info)
* [Cucumber](http://cukes.info)
* [behaviour-driven](http://behaviour-driven.org/)
* [Dan North. Introducing BDD](http://dannorth.net/introducing-bdd)



## License

(The MIT License)

Copyright (c) Matthias Hennemeyer

Permission is hereby granted, free of charge, to any person obtaining   
a copy of this software and associated documentation files (the   
'Software'), to deal in the Software without restriction, including   
without limitation the rights to use, copy, modify, merge, publish,   
distribute, sublicense, and/or sell copies of the Software, and to   
permit persons to whom the Software is furnished to do so, subject to   
the following conditions:

The above copyright notice and this permission notice shall be   
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,   
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE   
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.