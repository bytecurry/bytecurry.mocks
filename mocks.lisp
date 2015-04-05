(in-package :bytecurry.mocks)

(defun %get-binding-names (binding)
  (cons (gensym) (car binding)))

(defun %let-expr (names)
  "Get the let binding for a mock function binding"
  (destructuring-bind (temp-name . fn-name) names
    `(,temp-name (symbol-function ',fn-name))))

(defun %setf-for-binding (binding)
  "Store the mocked function."
  (destructuring-bind (name &rest fn-expr) binding
    `(setf (symbol-function ',name) (lambda ,@fn-expr))))

(defun %setf-for-original (names)
  (destructuring-bind (temp-name . fn-name) names
    `(setf (symbol-function ',fn-name) ,temp-name)))


;; This was inspired by the Stackoverflow answer at http://stackoverflow.com/a/4085713/2543666
(defmacro with-mocked-functions (bindings &body body)
  (declare (list bindings))
  "Execute BODY with some functions mocked up.

BINDINGS is a list of function bindings, similar to those in FLET or LABELS.
Before executing BODY, the bindings are used to replace the definitions of functions,
and after BODY has finished, the original function definitions are restored.

You can use this macro to mock funtions for unit tests. For example, if function A calls
function B, you can replace the definition of B while testing A, to isolate the test on just
the behavior of A.

There are two things to note when using this macro:
1. You can't mock functions in a locked package (such as CL)
2. The compiler may inline function calls, in which case changing the definition will have
   no effect."
  (let ((names (mapcar #'%get-binding-names bindings)))
    `(let (,@(mapcar #'%let-expr names))
       ,@(mapcar #'%setf-for-binding bindings)
       (prog1 (progn ,@body)
         ,@(mapcar #'%setf-for-original names)))))


(defmacro with-added-methods (bindings &body body)
  (declare (list bindings))
  "Execute BODY with some extra methods.

This works similarly to WITH-MOCKED-FUNCTIONS. But defines methods instead of functions.
The bindings should look like DEFMETHOD definitions without the defmethod symbol.

One particularly useful scenario is to mock up an instance of a class by using eql specializers
for a local variable.

For now, it only supports adding new methods, not replacing existing methods, since it doesn't restored the previous method. (mostly because I don't know a good way to extract the specifiers from the definition form.)"
  (let ((temp-names (loop for binding in bindings
                       collect (gensym))))
    `(let (,@(loop for temp-name in temp-names
                for binding in bindings
                collect `(,temp-name (defmethod ,@binding))))
       (prog1 (progn ,@body)
         ,@(loop for temp-name in temp-names
              for binding in bindings
              collect `(remove-method (function ,(first binding)) ,temp-name))))))
