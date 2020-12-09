
USING: kernel io io.files io.encodings.utf8 sequences prettyprint
       math math.parser splitting combinators accessors fry sets ;

IN: part1

SINGLETONS: jmp acc nop ;
UNION: op jmp acc nop ;

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
    HS{ } 0 0 \ state boa ;

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

: run-instr-maybe ( state ins -- ? )
    over visited? [
        2drop f
    ] [
        run-instr drop t
    ] if ;

: get-instr ( code state -- ins )
    pos>> swap nth ;

: run-instr-code ( code state -- ? )
    tuck get-instr run-instr-maybe ;

: run-instructions ( code -- acc )
    <state> [ 2dup run-instr-code ] loop nip acc>> ;

read-file [ >instruction ] map run-instructions .
