(in-package :asdf-user)

(defsystem #:bytecurry.mocks.test
    :description "Test for bytecurry.mocks.test"
    :author "Thayne McCombs <astrothayne@gmail.com>"
    :license "MIT"
    :depends-on (:bytecurry.mocks :fiveam)
    :components ((:file "mocks-test"))
    :perform (test-op (o c)
                      (symbol-call '#:fiveam '#:run! :bytecurry.mocks.test)))
