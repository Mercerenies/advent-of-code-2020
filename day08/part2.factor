
USING: kernel io io.files io.encodings.utf8 sequences prettyprint
       math math.parser math.ranges splitting combinators accessors
       fry sets vectors ;

IN: part2

SINGLETONS: jmp acc nop ;
UNION: op jmp acc nop ;

SINGLETONS: infinite-loop terminated running ;
UNION: end-condition infinite-loop terminated running ;

TUPLE: instruction
    { type op initial: nop }
    { argument integer } ;

TUPLE: state
    { visited set }
    { acc integer }
    { pos integer } ;

: >op ( str -- op )
    { { "jmp" [ jmp ] } { "acc" [ acc ] } { "nop" [ nop ] } } case ;

: <instruction> ( op arg -- ins )
    \ instruction boa ;

: >instruction ( str -- ins )
    " " split [ first >op ] [ second string>number ] bi <instruction> ;

: <state> ( -- state )
    HS{ } clone 0 0 \ state boa ;

: next-instr ( state -- state )
    [ 1 + ] change-pos ;

: add-visited ( state -- state )
    [ [ pos>> ] [ visited>> ] bi adjoin ] keep ;

: visited? ( state -- ? )
    [ pos>> ] [ visited>> ] bi in? ;

: read-all-lines ( -- seq )
    [ readln dup ] [ ] produce nip ;

: read-file ( -- seq )
    "input.txt" utf8 [ read-all-lines ] with-file-reader ;

: run-instr ( state ins -- state )
    [ add-visited ] dip
    [ argument>> ] [ type>> ] bi {
        { jmp [ '[ _ + ] change-pos ] }
        { acc [ '[ _ + ] change-acc next-instr ] }
        { nop [ drop next-instr ] }
    } case ;

: run-instr-maybe ( state ins -- r )
    over visited? [
        2drop infinite-loop
    ] [
        run-instr drop running
    ] if ;

: get-instr ( code state -- ins/f )
    pos>> swap ?nth ;

: run-instr-code ( code state -- r )
    tuck get-instr [ run-instr-maybe ] [ drop terminated ] if* ;

: run-instructions ( code -- acc r )
    <state> running [ drop 2dup run-instr-code dup running? ] loop [ nip acc>> ] dip ;

! Note that transmute is an involution (i.e. [ transmute transmute ] == [ ]).
: transmute ( ins -- ins )
    [ type>> ] [ argument>> ] bi
    [ { { nop [ jmp ] } { jmp [ nop ] } { acc [ acc ] } } case ] dip <instruction> ;

: transmute-nth ( code n -- )
    swap [ transmute ] change-nth ;

: try-every-line ( code -- acc )
    dup length [0,b) [
        [ transmute-nth ] 2keep
        over run-instructions terminated?
        [ drop f ] unless [ [ transmute-nth ] keepd ] dip
    ] map-find drop nip ;

read-file [ >instruction ] map >vector try-every-line .
