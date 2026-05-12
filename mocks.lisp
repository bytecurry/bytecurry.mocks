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
       (unwind-protect (progn ,@body)
         (progn ,@(mapcar #'%setf-for-original names))))))


(defun %find-method-expr (binding)
  (declare (list binding))
  "Generate expression for finding an existing method for a binding"
  (labels ((get-specializers (args)
             (declare (list args))
             "Convert method argument list to list of specializers"
             (loop for arg in args
                   ; Exit once we find the first keyword that starts with "&"
                   until (and (symbolp arg) (char= (char (symbol-name arg) 0) #\&))
                   ; If the argument is a cons, the second argument is the speicalizer,
                   ; otherwise the specializer is t
                   if (consp arg) collect (second arg)
                   else collect t))
           (build-spec (args)
             (declare (list args))
             "Return a list containing the qualifiers and specializers as lists"
             (loop for arg in args
                   if (listp arg) return `(',qualifiers ',(get-specializers arg))
                   else collect arg into qualifiers)))
    (destructuring-bind (name &rest args) binding
      `(find-method (function ,name) ,.(build-spec args) nil))))





; (defun %method-exprs (binding)
;   (declare (list binding))
;   "Create an expression for a pair that contains the old definition of the method
; and a new defition of the method, defined using defmethod on binding.
; The old definition may be nil if there was no method for those qualifiers before."
;   (

(defmacro with-added-methods (bindings &body body)
  (declare (list bindings))
  "Execute BODY with some extra methods.

This works similarly to WITH-MOCKED-FUNCTIONS. But defines methods instead of functions.
The bindings should look like DEFMETHOD definitions without the defmethod symbol.

One particularly useful scenario is to mock up an instance of a class by using eql specializers
for a local variable.

This restores the state of the methods to what it was before calling. If a method is overridden, then the original
method will be restored. If a new method is added, it will be removed."
  (let ((temp-names (loop for binding in bindings
                       collect (gensym))))
    `(let (,@(loop for temp-name in temp-names
                for binding in bindings
                collect `(,temp-name (list (function ,(first binding))
                                           ,(%find-method-expr binding)
                                           ; Muffle any redefinition warnings
                                           (handler-bind ((warning #'muffle-warning)) (defmethod ,@binding))))))
       (unwind-protect (progn ,@body)
         (progn
           ,@(loop for temp-name in temp-names
              collect `(destructuring-bind (f orig new) ,temp-name
                         (if orig
                           ; Replace the method with the old version
                           (add-method f orig)
                           ; Otherwise, remove the new method we added
                           (remove-method f new)))))))))
