;;; mocks-test.lisp
;;; Copyright (c) 2015 Thayne McCombs <astrothayne@gmail.com>
;;;

(defpackage :bytecurry.mocks.test
  (:use :cl :fiveam :bytecurry.mocks))

(in-package :bytecurry.mocks.test)

(def-suite :bytecurry.mocks)

(def-suite :bytecurry.mocks/with-mocked-functions :in :bytecurry.mocks.test)
(def-suite :bytecurry.mocks/with-added-methods :in :bytecurry.mocks.test)

(in-suite :bytecurry.mocks/with-mocked-functions)

;;; Set up some  test functions

(defun foo ()
  :foo)

(defun bar (arg)
  (format nil "Bar: ~a" arg))

(defun plus (a b)
  (+ a b))

(defun sum (&rest args)
  (reduce #'+ args))

(test single-function-foo
  (with-mocked-functions ((foo () :foo2))
    (is (eq :foo2 (foo)))))

(test two-functions
  (with-mocked-functions ((foo () :foo2)
                          (bar (arg)
                               (declare (ignorable arg))
                               "Bar"))
    (is (eq :foo2 (foo)))
    (is (string= "Bar" (bar 56)))))

(test restored-function
  (with-mocked-functions ((plus (a b)
                                (declare (ignorable a b))
                                10))
    (is (= 10 (plus 1 1))))
  (is (= 2 (plus 1 1))))

(test special-params
  (with-mocked-functions ((sum (&rest args)
                               (declare (ignorable args))
                               100))
    (is (= 100 (sum 1 2 3 4 5 6 7)))))

(test using-params
  (with-mocked-functions ((plus (a b) (cons a b)))
    (is (equal '(4 . 5) (plus 4 5)))))

(in-suite :bytecurry.mocks/with-added-methods)

(defgeneric gtest (a))

(defmethod gtest ((a t))
  "Foo")

(defmethod gtest ((a string))
  "A String")

(test new-temporary-method
  (with-added-methods ((gtest ((a (eql :foo)))
                              (declare (ignorable a))
                              :bar))
    (is (eq :bar (gtest :foo)))
    (is (string= "Foo" (gtest 5)))))

(test override-method
  (with-added-methods ((gtest ((a string))
                              a))
    (is (string= "Bar" (gtest "Bar")))
    (is (string= "Test" (gtest "Test"))))
  (skip "not implemented yet" (string= "A String" (gtest "Bar"))))

(test remove-method-afterwards
  (with-added-methods ((gtest ((a (eql :foo)))
                              :bar))
    (is (eq :bar (gtest :foo))))
  (is (eq "Foo" (gtest :foo))))
