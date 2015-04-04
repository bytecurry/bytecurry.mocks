;;;; bytecurry.mocks.asd
;;;; Copyright (c) 2015 Thayne McCombs <astrothayne@gmail.com>
;;;; MIT license
(in-package :asdf-user)

(defsystem #:bytecurry.mocks
    :description "Tools to mock functions for unit tests"
    :author "Thayne McCombs <astrothayne@gmail.com>"
    :version "1.0.0"
    :license "MIT"
    :serial t
    :components ((:file "package")
                 (:file "mocks"))
    :in-order-to ((test-op (test-op :bytecurry.mocks/test))))

(defsystem #:bytecurry.mocks/test
    :description "Test for bytecurry.mocks.test"
    :author "Thayne McCombs <astrothayne@gmail.com>"
    :license "MIT"
    :depends-on (:bytecurry.mocks :fiveam)
    :components ((:file "mocks-test"))
    :perform (test-op (o c)
                      (symbol-call '#:fiveam '#:run! :bytecurry.mocks.test)))
