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
    :perform (test-op (o c)
                      (load-system :bytecurry.mocks.test)
                      (perform 'test-op :bytecurry.mocks.test)))
