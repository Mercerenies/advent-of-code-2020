
0 Value fd
16 Constant max-line
512 Constant max-line-count
max-line-count cells allocate throw Constant lines

: 3drop ( x y z -- )
  drop 2drop ;

: parse-line { fid -- u }
  pad dup max-line fid read-line throw
  if s>number? 2drop else drop -1 then ;

: store-in-lines ( u idx -- )
  cells lines + ! ;

: try-to-add ( u idx -- ? | Returns -1 if not found, or the product if an answer is found )
  0 +do
    i cells lines + @ 2dup + 2020 = if
      * unloop exit
    then drop
  loop drop -1 ;

: main ( -- )
  0 begin
    fd parse-line dup 0 >=
  while
    2dup swap store-in-lines
    over try-to-add dup 0 >= if
      . drop exit
    else
      drop
    then
    1 +
  repeat 3drop ;

s" input.txt" r/o open-file throw to fd

main

fd close-file throw

lines free throw