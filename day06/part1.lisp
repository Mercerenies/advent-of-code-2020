
;; Returns the input backward because it's more efficient with linked
;; lists. This challenge doesn't really care what order the input is
;; in.
(defun read-file (stream)
  (loop with groups = nil
        with people = nil
        for line = (read-line stream nil)
        while line
        do (if (equal line "")
               (progn (push people groups)
                      (setf people nil))
               (push line people))
        finally (progn
                  (push people groups)
                  (return groups))))

(defun consolidate-answers (group)
  (flet ((union (x y)
           (union (coerce x 'list) (coerce y 'list) :test #'eql)))
    (reduce #'union group)))

(let ((data (with-open-file (file "input.txt")
              (read-file file))))
  (format t "~A~%"
          (loop for group in data
                sum (length (consolidate-answers group)))))
