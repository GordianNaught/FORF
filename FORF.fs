: '   get_lexeme lookup ;
: +!   dup @ rot + swap ! ;
: allot   dp +! ;
: here   dp @ ;
: ?   @ . ;
: cell   4 ;
: con_type   3 ;
: cells  2* 2* ;
: ,   here ! cell allot ;
: ep,   ep @ ! cell ep +! ;
: uv,   uv @ ! cell uv +! ;
: con_type   3 ;
: constant   get_lexeme here dup ep, write dp ! here ep, con_type , , ;
: create   get_lexeme here dup ep, write dp ! here ep, con_type , here cell + , ;
: variable   create 0 , ;
2 constant usr_type
0 constant nil
4 constant imm_type
0 constant 0
1 constant 1
: immediate   imm_type ep @ cell - @ ! ;
: literal   uv @ , con_type uv, uv, ; immediate
: [compile]   ' , ; immediate
: if   uv @ , con_type uv, uv @ 0 uv, [ ' ?branch ] literal , ; immediate
: else   uv @ , con_type uv, uv @ 0 uv, [ ' 0branch ] literal , swap dp @ swap ! ; immediate
: then   dp @ swap ! ; immediate
: begin   dp @ ; immediate
: until   uv @ , con_type uv, uv, [ ' ?branch ] literal , ; immediate
: again   uv @ , con_type uv, uv, [ ' 0branch ] literal , ; immediate
: not   0 = ;
: 0=   0 = ;
: logand   0= swap 0= + 0= ;
: 2drop   drop drop ;
: I   r> dup >r ;
: 1+   1 + ;
: s"   getchar drop uv @ , con_type uv, padp @ uv, begin getchar dup 34 = not if padp @ writeC padp ! 0 else drop 0 padp @ writeC padp ! 1 then until ; immediate
: ."   getchar drop uv @ , con_type uv, padp @ uv, begin getchar dup 34 = not if padp @ writeC padp ! 0 else drop 0 padp @ writeC padp ! 1 then until [ ' print ] literal , ; immediate
: bdo   swap >r >r ;
: do   [ ' bdo ] literal , dp @ ; immediate
: bloop   r> 1+ r> 2dup >r >r = ;
: aloop   r> r> 2drop ;
: loop   [ ' bloop ] literal , uv @ , con_type uv, uv, [ ' ?branch ] literal , [ ' aloop ] literal , ; immediate
: tuck   dup rot swap ;
: mod   /mod drop ;
variable m 
variable g
: ordmod
  m ! dup g ! 0 swap
  begin
    swap 1+ swap g @ * m @ mod dup g @ =
  until drop
;
: postpone   ' literal , ; immediate
: case   0 >r ; immediate
: of   r> 1+ >r postpone if ; immediate
: endof   postpone else ; immediate
: endcase   r> 0 do postpone then loop ; immediate
: CR   10 emit ;
: return   0 , ; immediate
: .s   ." <" depth . ." >" depth 0= if CR return then depth 1 + 1 do ."  " depth I - pick . loop CR ;
