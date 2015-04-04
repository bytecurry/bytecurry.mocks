(in-package :cl-user)

(defpackage bytecurry.mocks
  (:nicknames :mocks)
  (:use #:cl)
  (:export #:with-mocked-functions
           #:with-added-methods)
  (:documentation "Package to provide tools to mock functions
in common lisp unit tests.

Provides WITH-MOCKED-FUNCTIONS, which acts like FLET or LABELS, but shadows functions
in the global scope, so that the function bindings are available outside of the
lexical scope of the body. See docstring for more information."))
