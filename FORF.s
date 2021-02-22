#FORF compiler
.section .data
greeting:
  .asciz "FORF: a non-standard, indirect-threaded FORTH\n"
output:
  .asciz "%d"
getline:
  .asciz "%s"
bottom:
  .int 0
top:
  .int 0
exep:
  .int 0
currentif:
  .int 0
#entry pointer
ep:
  .int ep_init
#pointer to data
dp:
  .int dp_init
padp:
  .int pad
#return stack pointer
r:
  .int return_end
ur:
  .int user_return_end
uv:
  .int user_vars
  .equ cell, 4
  .equ FALSE, 0
  .equ TRUE, -1
# word types
  .equ primitive, 1
  .equ user, 2
  .equ constant, 3
  .equ immediate, 4

  .equ NULL, 0
.macro primitive string, name
\name\()_name:
  .asciz "\string\()"
\name\()_coderef:
  .int primitive
  .int \name
  #.int NULL
.endm
.macro constant string, name, value
\name\()_name:
  .asciz "\string\()"
\name\()_coderef:
  .int constant
  .int \value
.endm
.macro entry name
  .int \name\()_name
  .int \name\()_coderef
.endm
.macro compiletime string name
\name\()_name:
  .asciz "\string\()"
.endm
compiletime "[" suspend_compile
compiletime ";" semicolon
primitive "writeC" writechar
primitive "pad" get_pad
primitive "padp" get_padp
primitive "getchar" getc
primitive "2dup" twodup
primitive "rep2*" repsall
primitive "0branch" OBranch
primitive "?branch" condBranch
primitive "2drop" twodrop
primitive "]" resume_compile
primitive "uv" get_uv
primitive "dup" dup
primitive "+" add
primitive "quit" EXIT
primitive "drop" drop
primitive "get_lexeme" get_lexeme
primitive "print" print
primitive "." period
primitive "2/" shiftr
primitive "2*" shiftl
primitive "emit" emit
primitive "@" fetch
primitive "dp" get_dp
primitive "ep" get_ep
primitive "exep" get_exep
primitive "!" set
primitive ":" colon
primitive ">r" urput
primitive "swap" swap
primitive "r>" urget
primitive "rot" rot
primitive "-" subtract
primitive "=" equal
primitive "execute" execute
primitive "lookup" lookup
primitive "write" write
primitive "number" number
primitive "/mod" divmod
primitive "and" bitwise_and
primitive ">" greater_than
primitive "tuck" tuck
primitive "*" multiply
primitive "fopen" fopen
primitive "pick" pick
primitive "nip" nip
primitive "depth" depth
/*
primitive "break" break
*/

entries_start:
  entry fopen
  entry multiply
  entry tuck
  entry greater_than
  entry bitwise_and
  entry writechar
  entry get_pad
  entry get_padp
  entry getc
  entry repsall
  entry get_uv
  entry OBranch
  entry condBranch
  entry swap
  entry emit
  entry divmod
  entry twodrop
  entry twodup
  entry dup
  entry add
  entry EXIT
  entry drop
  entry get_lexeme
  entry print
  entry period
  entry shiftr
  entry shiftl
  entry fetch
  entry get_dp
  entry get_ep
  entry get_exep
  entry set
  entry colon
  entry urput
  entry urget
  entry rot
  entry subtract
  entry equal
  entry execute
  entry lookup
  entry number
  entry resume_compile
  entry write
  entry nip
  entry pick
  entry depth
/*
  entry break
*/
  
ep_init:
entries:
  .fill 32000
dp_init:
  .fill 32768
pad:
  .fill 30000
input_buffer:
  .fill 256
return_stack:
  .fill 4096
return_end:
user_return_stack:
  .fill 1024
user_return_end:
user_vars:
  .fill 32000
block_buffers:
.section .bss
.section .text

.macro .s
  call s
.endm
.macro header
  popl %ebp
.endm
.macro exit
  pushl %ebp
  ret
.endm
.macro FUNCTION thing
\thing\():
  header
  \thing
  exit
.endm
.macro dup
  pushl (%esp)
.endm
.macro tuck
  popl %eax
  popl %ebx
  pushl %eax
  pushl %ebx
  pushl %eax
.endm
.macro nip
  popl %eax
  movl %eax, (%esp)
.endm
.macro pick
  popl %eax
  pushl (%eax)
.endm
.macro rot
  popl %eax
  popl %ebx
  popl %edx
  pushl %ebx
  pushl %eax
  pushl %edx
.endm
.macro add
  popl %eax
  addl %eax, (%esp)
.endm
.macro subtract
  popl %eax
  subl %eax, (%esp)
.endm
.macro shiftl
  popl %eax
  sall %eax
  pushl %eax
.endm
.macro repsall
  popl %ecx
  popl %eax
  sall %cl, %eax
  pushl %eax
.endm
.macro shiftr
  popl %eax
  sarl %eax
  pushl %eax
.endm
.macro urput
  subl $cell, ur
  movl ur, %eax
  popl (%eax)
.endm
.macro urget
  movl ur, %eax
  addl $cell, ur
  pushl (%eax)
.endm
.macro bitwise_and
  popl %eax
  andl %eax, (%esp)
.endm
.macro rput
  subl $cell, r
  movl r, %eax
  popl (%eax)
.endm
.macro rget
  movl r, %eax
  addl $cell, r
  pushl (%eax)
.endm
.macro drop
  addl $cell, %esp
.endm
greater_than:
  header
  popl %eax
  popl %ebx
  cmpl %eax, %ebx
  jg greater_than_true
  pushl $0
  exit
greater_than_true:
  pushl $-1
  exit
EXIT:
  call exit
.macro fetch
  popl %eax
  pushl (%eax)
.endm
.macro getc
  call getchar
  pushl %eax
.endm
.macro depth
  movl top, %eax
  subl %esp, %eax
  sarl $2, %eax
  pushl %eax
.endm
.macro swap
  popl %eax
  pushl (%esp)
  movl %eax, 4(%esp)
.endm
.macro print
  call printf
  addl $cell, %esp
.endm
.macro get_lexeme
  pushl $input_buffer
  pushl $getline
  call scanf
  drop
.endm
.macro input_buffer
  pushl $input_buffer
.endm
/*
int f(int i) { return i ? 0 : -1; } => cmpl $1, 4(%esp); sbbl 
                %eax, %eax.
Subtract-with-borrow, so eax -= eax + carry. (The "eax - eax" 
                part is 0, so it's 0 or -1 depending on carry.)
*/

.macro number
  call atoi
  movl %eax, (%esp)
.endm
.macro equal
  subtract
  cmpl $1, (%esp)
  sbbl %eax, %eax
  movl %eax, (%esp)
.endm
.macro Cfetch
  movl (%esp), %esi
  xor %eax, %eax
  lodsb
  drop
  pushl %eax;
.endm
.macro twodrop
  addl $8, %esp
.endm
.macro period
  pushl $output
  call printf
  addl $8, %esp
.endm
.macro set
  popl %eax
  popl (%eax)
.endm
.macro emit
  call putchar
  drop
.endm
.macro twodup
  pushl 4(%esp)
  pushl 4(%esp)
.endm
.macro writechar
  popl %edi
  popl %eax
  movb %al, (%edi)
  inc %edi
  pushl %edi
.endm
.macro multiply
  popl %eax
  popl %ebx
  imull %eax, %ebx
  pushl %ebx
.endm
.macro fopen
  call fopen
.endm
FUNCTION pick
FUNCTION nip
FUNCTION fopen
FUNCTION multiply
FUNCTION tuck
FUNCTION bitwise_and
FUNCTION writechar
FUNCTION getc
FUNCTION twodrop
FUNCTION twodup
FUNCTION repsall
FUNCTION emit
FUNCTION dup
FUNCTION rot
FUNCTION add
FUNCTION shiftl
FUNCTION shiftr
FUNCTION urput
FUNCTION drop
FUNCTION urget
FUNCTION depth
FUNCTION swap
FUNCTION period
FUNCTION get_lexeme
FUNCTION print
FUNCTION fetch
FUNCTION set
FUNCTION subtract
FUNCTION equal
FUNCTION number
get_dp:
  header
  pushl $dp
  exit
get_ep:
  header
  pushl $ep
  exit
get_pad:
  header
  pushl $pad
  exit
get_padp:
  header
  pushl $padp
  exit
get_exep:  # for use in user definitions
  header
  rget  # get execute's return address
  rget  # get state of interpretter for user defined word
  dup   # duplicate to keep a copy
  subl $cell, (%esp)  # will be added back after jump
  urput
  rput  # fix interpretter return stack
  rput  
  urget # put state on user stack
  exit
get_uv:
  header
  pushl $uv
  exit

  # while (*a == *b) { if (!*a) { return true; } a++; b++ } return false;

compare:
  header
  popl %esi    # string 1
  popl %edi    # string 2
  cld
compare_loop:
  cmpsb
  jne compare_not_equal  # if characters not equal
                           # jmp to not equal
  cmpb $NULL, (%esi)     # if string 1 at end
  je compare_end_one       # push 1
  pushl $FALSE           # else push 0
compare_second:
  cmpb $NULL, (%edi)     # if string 2 at end
  je compare_end_two       # push 1
  pushl $FALSE           # else push 0
after_checked_ends:
  add                    # find number of words at end
  popl %eax
  cmpl $2, %eax          # if both words at end
  je compare_equal         # equal
  cmpl $1, %eax          # if one word at end
  je compare_not_equal     # not equal
  jmp compare_loop       # else check next character
compare_end_one:
  pushl $1
  jmp compare_second
compare_end_two:
  pushl $1
  jmp after_checked_ends

compare_equal:      # if strings equal
  pushl $TRUE         # push -1
  exit
compare_not_equal:  # if strings not equal
  pushl $FALSE        # push 0
  exit

.macro compare
  call compare
.endm

lookup:
  header
  movl ep, %eax  # make %eax hold the entry address
lookup_loop:
  subl $8, %eax  # move to next name pointer

  pushl %eax
  rput           # protect %eax from dup
  dup            # duplicate given word's address
  rget           # retrieve %eax after dup
  popl %eax

  pushl (%eax)   # put name address on stack

  pushl %eax     # protect %eax from compare
  rput
  pushl %ebp
  rput           # protect %ebp from compare
  compare        # compare to name of word given
  rget
  popl %ebp      # retrieve %ebp after compare
  rget
  popl %eax      # retrieve %eax after compare

  cmpl $TRUE, (%esp)         # if compare returns equal
  je lookup_found              # lookup success
                             # else
  drop                         # drop false from stack
  cmpl $entries_start, %eax
                             # if not at end of entries
  jne lookup_loop              # check next entry
                             # otherwise (failed lookup)
  drop                         # consume argument
  pushl $FALSE                 # put false on stack
  exit                         # exit
lookup_found:
  drop                       # drop true from stack
  drop                       # drop given word's address
  addl $cell, %eax           # make %eax hold code pointer
  pushl (%eax)               # put code pointer on stack
  exit

.macro lookup
  call lookup
.endm
execute:
  rput        # protect return address
  popl exep

  movl exep, %eax
  cmpl $primitive, (%eax)    # if primitive
  je execute_primitive         # execute as primitive
  cmpl $user, (%eax)         # if user_defined
  je execute_user_defined      # execute as user_defined
  cmpl $constant, (%eax)     # if constant
  je execute_constant          # execute as constant
  cmpl $immediate, (%eax)    # if immediate
  je execute_user_defined      # execute as if user_defined
execute_primitive:
  addl $cell, exep
  movl exep, %eax            # put adress of function address in %eax
  call *(%eax)               # call function
  rget                       # return
  ret
execute_constant:
  addl $cell, exep
  movl exep, %eax
  pushl (%eax)               # push value of constant
  rget                       # return
  ret
execute_user_defined:
loop_execute_user_defined:
  addl $cell, exep
  movl exep, %eax
  cmpl $NULL, (%eax)             # if NULL
  je execute_return                # jump to execute return
  pushl (%eax)                   # push thing to execute
  pushl exep
  rput                           # protect execution pointer
  call execute                   # call execute
  rget
  popl exep                      # retrieve execution pointer
  jmp loop_execute_user_defined  # execute next part
execute_return:
  rget                           # retreive return address
  ret                            # return

.macro write
  popl %edi
  popl %esi
  movsb
1:
  movsb
  cmpb $NULL, -1(%esi)
  jne 1b
  pushl %edi
.endm
FUNCTION write
.macro compile_name        # ( src dest --)
  movl ep, %eax            # move entry pointer to %eax
  movl dp, %ebx
  movl %ebx, (%eax)        # make entry pointer point to
                           #  the destination of the word
                           #   being compiled
  pushl dp                 # push destination
  write                    # write name to destination
  popl %edi
  movl %edi, dp            # advance data pointer
.endm
.macro new_entry_part
  addl $cell, ep           # advance entry pointer
  movl ep, %eax
  movl dp, %edx
  movl %edx, (%eax)        # make ep point to next part of data
  addl $cell, ep           # advance ep to normal boundary
.endm
.macro compile immediate
  movl dp, %eax
  movl $\immediate, (%eax)
  addl $cell, dp
.endm
.macro compile_code
  movl dp, %eax
  popl (%eax)
  addl $cell, dp
.endm

resume_compile:
  drop
  jmp colon_loop
divmod:
  rput
  popl %ebx
  popl %eax
  cwd
  xor %edx, %edx
  idivl %ebx
  pushl %edx
  pushl %eax
  rget
  ret

condBranch:
  header
  popl %ebx
  popl %ecx
  cmpl $FALSE, %ecx
  je if_cond_false
  exit
if_cond_false:
  rget
  rget
  subl $cell, %ebx
  movl %ebx, (%esp)
  rput
  rput
  exit

OBranch:
  header
  popl %ebx
  rget
  rget
  subl $cell, %ebx
  movl %ebx, (%esp)
  rput
  rput
  exit

suspend_compile_compile:
  drop
  jmp masterloop

.macro compilecheck thing
  dup
  pushl $\thing\()_name
  compare
  popl %eax
  cmpl $TRUE, %eax
  je \thing\()_compile
.endm

colon:
  rput                   # protect return address
  get_lexeme             # get name of word
  compile_name           # compile name of word
  new_entry_part         # second entry part
  compile user           # compile type
colon_loop:
  get_lexeme             # get next lexeme
  dup                    # duplicate lexeme address
  pushl $semicolon_name  # check if semicolon
  compare
  popl %eax
  cmpl $TRUE, %eax       # if semicolon
  je colon_done            # then done
  compilecheck suspend_compile
  dup
  lookup                 # lookup lexeme
  cmpl $FALSE, (%esp)
  je colon_word_not_found
  movl (%esp), %eax      # checking for immediate
  movl (%eax), %ebx
  cmpl $immediate, %ebx  # if immediate
  jne not_immediate
  swap
  drop                     # destroy lexeme
  call execute             # execute immediate
  jmp colon_loop
not_immediate:
  compile_code           # compile code of lexeme
  drop                   # drop lexeme
  jmp colon_loop         # get next lexeme
colon_word_not_found:
  drop
  number
  movl uv, %eax
  movl dp, %ebx
  movl %eax, (%ebx)

  movl $constant, (%eax)
  addl $cell, %eax
  popl (%eax)
  addl $cell, dp
  addl $8, uv
  jmp colon_loop
colon_done:
  compile NULL    # compile NULL termination
  drop
  rget            # retrieve return address
  ret             # return

.macro greeting
  pushl $greeting
  call printf
  drop
.endm

.globl main
main:
  movl %esp, top
  greeting
masterloop:
  get_lexeme           # --lexadr)
  dup                  # --lexadr lexadr)
  lookup               # -- lexadr 0|exeptr)
  cmpl $FALSE, (%esp)  # if not found
  je faillookup          # failed lookup
                       # else (if found)
  nip                    # ( lexadr exeptr--exeptr)
  call execute           # execute (assumed to consume argument)
                         # ( --)
  jmp masterloop       # interpret next lexeme
faillookup:            # if failed lookup
  drop                   # drop false from stack
  number                 # interpret as number
  jmp masterloop       # interpret next lexeme

  call exit
