(require :parenscript)

(defparameter *include-paths* ())
(defparameter *verbose* nil)

;; add 'load' to parenscript compiler
(ps:defpsmacro load (file)
  (let (code)
    (catch 'found
      (dolist (include-path *include-paths*)
        (let ((path (concatenate 'string (directory-namestring include-path) file)))
          (when (probe-file path)
            (with-open-file (f path)
              (do
               ((form (read f nil) (read f nil)))
               ((not form))
                (push form code)))
            (throw 'found (cons 'progn (nreverse code))))))
      (format *error-output* "sigil: Cannot find load file: ~A~%" file))))

(defun repl ()
  (let* ((node (run-program "node" '("-i") :search t :input :stream :output :stream :wait nil))
         (node-input (process-input node))
         (node-output (process-output node)))
    (loop
      (format *error-output* "> ")
      (force-output *error-output*)
      (read-char node-output) ; eat initial prompt
      (handler-case
          (let ((form (read)))
            (format node-input "~A~%" (ps:ps* form))
            (force-output node-input)
            (loop
              (let ((c (read-char node-output)))
                (when (and (char= #\Newline c)
                           (char= #\> (peek-char nil node-output)))
                  (read-char node-output)
                  (fresh-line)
                  (return))
                (princ c)
                (force-output))))
        (sb-sys:interactive-interrupt () (sb-ext:exit))
        (end-of-file () (sb-ext:exit))
        ))))

(defun printv (item &optional (cr 0))
  (when *verbose*
    (format t "/* --eval ~A~% */" item)
    (dotimes (i cr) ;; Add some carriage returns on request
      (terpri)))
  item)

(defun handle-case-change (name)
  (let ((rtcase (member name '(:upcase :downcase :preserve :invert) :test #'string-equal)))
    (unless rtcase
      (error "Readtable case must be one of: upcase downcase preserve invert"))
    (setf (readtable-case *readtable*) (car rtcase))))

(defun eval-lisp (code)
  (in-package :ps)
  (eval (printv (read-from-string code))))

(defun eval-ps (code)
  (ps:ps* (printv (read-from-string code))))

(defun ps2js (fh)
  (in-package :ps)
  (loop
    for form = (read fh nil 'eof)
    until (eq form 'eof)
    do (format t "~a~%~%" (ps:ps* (printv form 2)))))

(defun process-file (fname)
  (let ((fpath (probe-file fname)))
    (when fpath
      (let ((*include-paths* (cons (directory-namestring fpath) *include-paths*)))
        (with-open-file (fh fname)
          (handler-bind
              ((error
                 (lambda (e)
                   (format *error-output* "~a~%" e)
                   (sb-ext:exit :code 1))))
            (ps2js fh)))))))

(defun main (argv)
  (push (probe-file ".") *include-paths*)
  (if (cdr argv)
      (loop
        initially (pop argv)
        until (not argv)
        for arg = (pop argv)
        do (cond
             ((string= arg "-v") (setf *verbose* t))
             ((string= arg "-I") (push (probe-file (pop argv)) *include-paths*))
             ((string= arg "-i") (repl))
             ((string= arg "-C") (handle-case-change (pop argv)))
             ((string= arg "--eval") (eval-lisp (pop argv)))
             ((string= arg "--pseval") (eval-ps (pop argv)))
             (t (process-file arg))))
      (repl)))
