
(global data {})
(each [line (io.lines "input.txt")]
      (table.insert data line))

(fn %-1-indexed [x y]
    (+ (% (- x 1) y) 1))

(fn at [x y]
    (let [line-length (length (. data 1))
          x1 (%-1-indexed x line-length)]
      (string.sub (. data y) x1 x1)))

(let [line-count (length data)]
  (var x 1)
  (var y 1)
  (var total 0)
  (while (<= y line-count)
         (if (= (at x y) "#")
             (set total (+ total 1)))
         (set x (+ x 3))
         (set y (+ y 1)))
  (print total))

