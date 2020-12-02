
0 Value fd
16 Constant max-line
512 Constant max-line-count
max-line-count cells allocate throw Constant lines

: 3drop ( x y z -- )
  drop 2drop ;

: 3dup ( x y z -- x y z x y z )
  dup >r >r 2dup r> -rot r> ;

: parse-line { fid -- u }
  pad dup max-line fid read-line throw
  if s>number? 2drop else drop -1 then ;

: store-in-lines ( u idx -- )
  cells lines + ! ;

: try-to-add-2 ( u1 u2 idx -- ? | Returns -1 if not found, or the product if an answer is found )
  0 +do
    i cells lines + @ 3dup + + 2020 = if
      * * unloop exit
    then drop
  loop 2drop -1 ;

: try-to-add ( u idx -- ? | Returns -1 if not found, or the product if an answer is found )
  0 +do
    i cells lines + @ 2dup i try-to-add-2 dup 0 >= if
      unloop exit
    then 2drop
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