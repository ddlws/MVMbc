MVMBC
====================================

An incomplete but not terribly incorrect MoarVM bytecode parser. I wrote it to learn about vmguts, and for that it's been quite useful.

It doesn't do anything crazy like run deserialization frames or chase down dependencies, so it's somewhat limited. It'll choke on bytecode from installed modules unless you remove everything before the magic bytes.

It could possibly be made useful for debugging compiler output if such a tool doesn't exist. If nothing else, it beats running gdb just to dump bytecode.

Precompilation of opcodes.pm6 takes a long, long time. I'm sorry. Live and learn.

#### Some operands you'll see

* [R|W]reg(x) = read/written register. 'x' is an index into the frame's locals.
* int(x) / num(x) = 'x' is a literal number
* literal strings are inserted when possible
    * getattr_o( Wreg(10), Rreg(0), Rreg(8), '$!b', int16(1) )
* lex(x) = lexical, 'x' is an index into the frame's lexical values
* callsite(x) = 'x' is the callsite's index. They're at the end of the listing.

Here is a oneliner that shows it in action. Run it from the root of this repo.

`raku --target=mbc --output=helloworld.moar -e $'class hw {has $!a=\'hello\'; has $!b=\' world!\'; method gist() { $!a~$!b };}; say hw.new;'; raku -I . -e $'use MVMbc::MVMbc; MVMBC.new(\'helloworld.moar\').listing;'`

```
MVMbc listing
Bytecode Version: 6
HLLname: Raku
MainFrame idx: 0
Frames: 8
S.Contexts: 4
S.SCdataOffset: 3952
S.SCdataLength: 2792
ExtOps: 0
Callsites: 4
libLoadFrame idx: 8
deserializationFrame idx: 6

****Serialization-Contexts****
  D60E7C22BBEBA9D59107DF3326C1C4F559741DF5
  C824A7B5D9FB64907E102E2EBF0E8BF6DCE4F48E-0
  DEF3A95F70A72E6A2FEB8E081DCD693E256BB2BB
  3992F7E094D8028E21BF383D58BA68466D5355C6-0
****FRAME****
<unit-outer>

  ****ANNOTATIONS****
    [0] 1: -e

  ****LOCALS****
    [0] obj
    [1] obj
    [2] obj
    [3] obj

  ****OPS****
    getcode( Wreg(3), coderef(1) )
    capturelex( Rreg(3) )
    getcode( Wreg(1), coderef(1) )
    takeclosure( Wreg(1), Rreg(1) )
    checkarity( int16(0), int16(-1) )
    param_sp( Wreg(0), int16(0) )
    paramnamesused(  )
    decont( Wreg(2), Rreg(1) ) :-e
    prepargs( callsite(2) )
    invoke_o( Wreg(2), Rreg(2) )
    return_o( Rreg(2) )


****END-FRAME****

****FRAME****
<unit>

  ****ANNOTATIONS****
    [0] 1: -e
    [1] 1: -e
    [2] 1: -e
    [3] 1: -e

  ****LOCALS****
    [0] obj
    [1] obj
    [2] str
    [3] obj
    [4] int64
    [5] int64
    [6] obj
    [7] obj
    [8] obj
    [9] obj
    [10] obj

  ****LEXICALS****
    [0] obj: $¢
    [1] obj: $!
    [2] obj: $/
    [3] obj: $_
    [4] obj: GLOBALish
    [5] obj: EXPORT
    [6] obj: $?PACKAGE
    [7] obj: ::?PACKAGE
    [8] obj: $=finish
    [9] obj: hw
    [10] obj: $=pod
    [11] obj: !UNIT_MARKER

  ****SLVLS****
    MVMslv.new(idx => 0, flag => 1, SCdepidx => 0, SCobjidx => 10)
    MVMslv.new(idx => 1, flag => 1, SCdepidx => 0, SCobjidx => 8)
    MVMslv.new(idx => 2, flag => 1, SCdepidx => 0, SCobjidx => 6)
    MVMslv.new(idx => 3, flag => 1, SCdepidx => 0, SCobjidx => 4)
    MVMslv.new(idx => 4, flag => 0, SCdepidx => 0, SCobjidx => 0)
    MVMslv.new(idx => 5, flag => 0, SCdepidx => 0, SCobjidx => 1)
    MVMslv.new(idx => 6, flag => 0, SCdepidx => 0, SCobjidx => 0)
    MVMslv.new(idx => 7, flag => 0, SCdepidx => 0, SCobjidx => 0)
    MVMslv.new(idx => 8, flag => 0, SCdepidx => 1, SCobjidx => 23)
    MVMslv.new(idx => 9, flag => 0, SCdepidx => 0, SCobjidx => 12)
    MVMslv.new(idx => 10, flag => 0, SCdepidx => 0, SCobjidx => 34)
    MVMslv.new(idx => 11, flag => 0, SCdepidx => 0, SCobjidx => 35)

  ****OPS****
    getcode( Wreg(9), coderef(2) )
    capturelex( Rreg(9) )
    getcode( Wreg(7), coderef(3) )
    takeclosure( Wreg(7), Rreg(7) )
    checkarity( int16(0), int16(0) )
    paramnamesused(  )
    getcode( Wreg(0), coderef(2) )
    const_s( Wreg(2), '$*CTXSAVE' )
    getdynlex( Wreg(3), Rreg(2) )
    set( Wreg(1), Rreg(3) )
    isnull( Wreg(4), Rreg(1) )
    if_i( Rreg(4), ins(132) )
    decont( Wreg(3), Rreg(1) )
    const_s( Wreg(2), 'ctxsave' ) :-e
    can_s( Wreg(5), Rreg(3), Rreg(2) ) :-e
    unless_i( Rreg(5), ins(132) )
    decont( Wreg(6), Rreg(1) )
    findmeth( Wreg(3), Rreg(6), 'ctxsave' )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(1) )
    invoke_o( Wreg(3), Rreg(3) )
    prepargs( callsite(2) )
    invoke_v( Rreg(7) )
    const_s( Wreg(2), '&say' )
    getlexstatic_o( Wreg(6), Rreg(2) )
    decont( Wreg(6), Rreg(6) )
    wval( Wreg(8), int16(0), int16(12) )
    decont( Wreg(10), Rreg(8) )
    findmeth( Wreg(9), Rreg(10), 'new' )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(8) )
    invoke_o( Wreg(9), Rreg(9) )
    hllize( Wreg(9), Rreg(9) )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(9) )
    invoke_o( Wreg(6), Rreg(6) )
    isconcrete( Wreg(4), Rreg(6) )
    unless_i( Rreg(4), ins(274) )
    tryfindmeth( Wreg(9), Rreg(6), 'sink' )
    isnull( Wreg(4), Rreg(9) )
    if_i( Rreg(4), ins(274) )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(6) )
    invoke_v( Rreg(9) )
    wval( Wreg(6), int16(1), int16(25) )
    return_o( Rreg(6) )


****END-FRAME****

****FRAME****
BUILDALL

  ****ANNOTATIONS****
    [0] 1: -e

  ****DBGNAMES****
    [0] %_

  ****LOCALS****
    [0] obj
    [1] obj
    [2] obj
    [3] obj
    [4] obj
    [5] obj
    [6] obj
    [7] str
    [8] int64
    [9] obj
    [10] obj
    [11] obj
    [12] obj

  ****LEXICALS****
    [0] obj: %_

  ****SLVLS****
    MVMslv.new(idx => 0, flag => 0, SCdepidx => 2, SCobjidx => 4258)

  ****OPS****
    checkarity( int16(3), int16(3) )
    param_rp_o( Wreg(1), int16(0) )
    param_rp_o( Wreg(2), int16(1) )
    param_rp_o( Wreg(3), int16(2) )
    paramnamesused(  )
    wval( Wreg(5), int16(1), int16(46) )
    getattr_o( Wreg(6), Rreg(3), Rreg(5), '$!storage', int16(0) )
    set( Wreg(4), Rreg(6) )
    wval( Wreg(6), int16(0), int16(12) )
    const_s( Wreg(7), '$!a' )
    attrinited( Wreg(8), Rreg(1), Rreg(6), Rreg(7) )
    if_i( Rreg(8), ins(180) )
    wval( Wreg(6), int16(0), int16(12) )
    getattr_o( Wreg(5), Rreg(1), Rreg(6), '$!a', int16(0) )
    set( Wreg(9), Rreg(5) )
    wval( Wreg(5), int16(0), int16(15) )
    decont( Wreg(5), Rreg(5) )
    set( Wreg(10), Rreg(5) )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(9) )
    arg_o( int16(1), Rreg(10) )
    speshresolve( Wreg(5), 'assign' )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(9) )
    arg_o( int16(1), Rreg(10) )
    invoke_v( Rreg(5) )
    wval( Wreg(5), int16(0), int16(12) )
    const_s( Wreg(7), '$!b' )
    attrinited( Wreg(8), Rreg(1), Rreg(5), Rreg(7) )
    if_i( Rreg(8), ins(306) )
    wval( Wreg(5), int16(0), int16(12) )
    getattr_o( Wreg(6), Rreg(1), Rreg(5), '$!b', int16(1) )
    set( Wreg(11), Rreg(6) )
    wval( Wreg(6), int16(0), int16(18) )
    decont( Wreg(6), Rreg(6) )
    set( Wreg(12), Rreg(6) )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(11) )
    arg_o( int16(1), Rreg(12) )
    speshresolve( Wreg(6), 'assign' )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(11) )
    arg_o( int16(1), Rreg(12) )
    invoke_v( Rreg(6) )
    return_o( Rreg(1) )


****END-FRAME****

****FRAME****


  ****ANNOTATIONS****
    [0] 1: -e
    [1] 1: -e
    [2] 1: -e
    [3] 1: -e

  ****DBGNAMES****
    [0] $_

  ****LOCALS****
    [0] obj
    [1] str
    [2] obj
    [3] obj

  ****LEXICALS****
    [0] obj: $_
    [1] obj: $?PACKAGE
    [2] obj: ::?PACKAGE
    [3] obj: $?CLASS
    [4] obj: ::?CLASS

  ****SLVLS****
    MVMslv.new(idx => 0, flag => 0, SCdepidx => 2, SCobjidx => 4258)
    MVMslv.new(idx => 1, flag => 0, SCdepidx => 0, SCobjidx => 12)
    MVMslv.new(idx => 2, flag => 0, SCdepidx => 0, SCobjidx => 12)
    MVMslv.new(idx => 3, flag => 0, SCdepidx => 0, SCobjidx => 12)
    MVMslv.new(idx => 4, flag => 0, SCdepidx => 0, SCobjidx => 12)

  ****OPS****
    getcode( Wreg(3), coderef(4) )
    capturelex( Rreg(3) )
    checkarity( int16(0), int16(0) )
    paramnamesused(  )
    const_s( Wreg(1), '$_' )
    getlexouter( Wreg(2), Rreg(1) )
    set( Wreg(0), Rreg(2) )
    getcode( Wreg(2), coderef(4) )
    return(  )


****END-FRAME****

****FRAME****
gist

  ****ANNOTATIONS****
    [0] 1: -e
    [1] 1: -e

  ****DBGNAMES****
    [0] self
    [1] %_

  ****LOCALS****
    [0] obj
    [1] obj
    [2] obj
    [3] obj
    [4] obj
    [5] int64
    [6] str
    [7] obj
    [8] obj
    [9] obj
    [10] obj
    [11] obj

  ****LEXICALS****
    [0] obj: %_
    [1] obj: self
    [2] obj: $¢
    [3] obj: $!
    [4] obj: $/
    [5] obj: $*DISPATCHER
    [6] obj: $*NEXT-DISPATCHER

  ****SLVLS****
    MVMslv.new(idx => 0, flag => 0, SCdepidx => 2, SCobjidx => 4258)
    MVMslv.new(idx => 1, flag => 0, SCdepidx => 2, SCobjidx => 4258)
    MVMslv.new(idx => 2, flag => 1, SCdepidx => 0, SCobjidx => 10)
    MVMslv.new(idx => 3, flag => 1, SCdepidx => 0, SCobjidx => 8)
    MVMslv.new(idx => 4, flag => 1, SCdepidx => 0, SCobjidx => 6)
    MVMslv.new(idx => 5, flag => 0, SCdepidx => 3, SCobjidx => 459)
    MVMslv.new(idx => 6, flag => 0, SCdepidx => 1, SCobjidx => 25)

  ****OPS****
    checkarity( int16(1), int16(1) )
    param_rp_o( Wreg(2), int16(0) )
    hllize( Wreg(4), Rreg(2) )
    set( Wreg(2), Rreg(4) )
    decont( Wreg(4), Rreg(2) )
    set( Wreg(11), Rreg(4) )
    wval( Wreg(4), int16(0), int16(12) )
    istype( Wreg(5), Rreg(11), Rreg(4) )
    assertparamcheck( Rreg(5) )
    set( Wreg(0), Rreg(11) )
    param_sn( Wreg(3) )
    takedispatcher( Wreg(4) )
    isnull( Wreg(5), Rreg(4) )
    if_i( Rreg(5), ins(92) )
    bindlex( lexical(), Rreg(824) )
    const_i64( Wreg(248), int64(1407477963030533) )
    exp_n( Wreg(0), Rreg(36) )
    const_n64( Wreg(0), num64(5066575351054340) )
    no_op(  )
    getlexstatic_o( Wreg(7), Rreg(6) )
    decont( Wreg(7), Rreg(7) )
    wval( Wreg(8), int16(0), int16(12) )
    getattr_o( Wreg(9), Rreg(0), Rreg(8), '$!a', int16(0) )
    wval( Wreg(8), int16(0), int16(12) )
    getattr_o( Wreg(10), Rreg(0), Rreg(8), '$!b', int16(1) )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(9) )
    arg_o( int16(1), Rreg(10) )
    invoke_o( Wreg(7), Rreg(7) )
    set( Wreg(4), Rreg(7) )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(4) )
    speshresolve( Wreg(7), 'decontrv' )
    prepargs( callsite(1) )
    arg_o( int16(0), Rreg(4) )
    invoke_o( Wreg(7), Rreg(7) )
    return_o( Rreg(7) )


****END-FRAME****

****FRAME****
<dependencies+deserialize>

  ****LOCALS****
    [0] str
    [1] str
    [2] str
    [3] obj
    [4] obj
    [5] obj
    [6] obj
    [7] obj
    [8] obj
    [9] obj
    [10] obj
    [11] int64
    [12] str

  ****OPS****
    getcode( Wreg(10), coderef(6) )
    takeclosure( Wreg(10), Rreg(10) )
    checkarity( int16(0), int16(0) )
    paramnamesused(  )
    const_s( Wreg(0), 'ModuleLoader.moarvm' )
    loadbytecode( Wreg(0), Rreg(0) )
    const_s( Wreg(1), 'nqp' )
    const_s( Wreg(2), 'ModuleLoader' )
    gethllsym( Wreg(3), Rreg(1), Rreg(2) )
    const_s( Wreg(2), 'Perl6::ModuleLoader' )
    decont( Wreg(5), Rreg(3) )
    findmeth( Wreg(4), Rreg(5), 'load_module' )
    prepargs( callsite(3) )
    arg_o( int16(0), Rreg(3) )
    arg_s( int16(1), Rreg(2) )
    invoke_o( Wreg(4), Rreg(4) )
    getcode( Wreg(3), coderef(0) )
    const_s( Wreg(2), 'ModuleLoader' )
    getcurhllsym( Wreg(5), Rreg(2) )
    const_s( Wreg(2), 'CORE.d' )
    decont( Wreg(7), Rreg(5) )
    findmeth( Wreg(6), Rreg(7), 'load_setting' )
    prepargs( callsite(3) )
    arg_o( int16(0), Rreg(5) )
    arg_s( int16(1), Rreg(2) )
    invoke_o( Wreg(6), Rreg(6) )
    forceouterctx( Rreg(3), Rreg(6) )
    const_s( Wreg(2), 'D60E7C22BBEBA9D59107DF3326C1C4F559741DF5' )
    createsc( Wreg(6), Rreg(2) )
    set( Wreg(8), Rreg(6) )
    const_s( Wreg(2), '-e' )
    scsetdesc( Rreg(8), Rreg(2) )
    hlllist( Wreg(6) )
    create( Wreg(6), Rreg(6) )
    set( Wreg(9), Rreg(6) )
    null_s( Wreg(1) )
    null( Wreg(6) )
    prepargs( callsite(2) )
    invoke_o( Wreg(5), Rreg(10) )
    deserialize( Rreg(1), Rreg(8), Rreg(6), Rreg(5), Rreg(9) )
    elems( Wreg(11), Rreg(9) )
    unless_i( Rreg(11), ins(322) )
    wval_wide( Wreg(5), int16(2), int64(35861) )
    decont( Wreg(7), Rreg(5) )
    findmeth( Wreg(6), Rreg(7), 'resolve_repossession_conflicts' )
    prepargs( callsite(0) )
    arg_o( int16(0), Rreg(5) )
    arg_o( int16(1), Rreg(9) )
    invoke_o( Wreg(6), Rreg(6) )
    const_s( Wreg(12), 'GLOBAL' )
    wval( Wreg(5), int16(0), int16(0) )
    bindcurhllsym( Wreg(5), Rreg(12), Rreg(5) )
    return_o( Rreg(5) )


****END-FRAME****

****FRAME****


  ****LOCALS****
    [0] obj
    [1] int64
    [2] obj

  ****OPS****
    checkarity( int16(0), int16(0) )
    paramnamesused(  )
    bootarray( Wreg(0) )
    create( Wreg(0), Rreg(0) )
    const_i64_16( Wreg(1), int16(4) )
    setelemspos( Rreg(0), Rreg(1) )
    const_i64_16( Wreg(1), int16(0) )
    setelemspos( Rreg(0), Rreg(1) )
    getcode( Wreg(2), coderef(4) )
    push_o( Rreg(0), Rreg(2) )
    getcode( Wreg(2), coderef(2) )
    push_o( Rreg(0), Rreg(2) )
    getcode( Wreg(2), coderef(3) )
    push_o( Rreg(0), Rreg(2) )
    getcode( Wreg(2), coderef(1) )
    push_o( Rreg(0), Rreg(2) )
    return_o( Rreg(0) )


****END-FRAME****

****FRAME****
<load>

  ****LOCALS****
    [0] obj
    [1] obj

  ****OPS****
    checkarity( int16(0), int16(0) )
    paramnamesused(  )
    getcode( Wreg(0), coderef(0) )
    decont( Wreg(0), Rreg(0) )
    prepargs( callsite(2) )
    invoke_o( Wreg(0), Rreg(0) )
    return_o( Rreg(0) )


****END-FRAME****

****STRINGTABLE****
  5
  <unit-outer>
  -e
  4
  <unit>
  2
  BUILDALL
  $!storage
  $!a
  assign
  $!b
  $*CTXSAVE
  ctxsave
  3

  $_
  1
  gist
  &infix:<~>
  decontrv
  &say
  new
  sink
  Uninstantiable
  Raku
  P6opaque
  ACCEPTS
  DEF3A95F70A72E6A2FEB8E081DCD693E256BB2BB
  gen/moar/CORE.c.setting
  ASSIGN-KEY
  ASSIGN-POS
  AT-KEY
  AT-POS
  Array
  BIND-KEY
  BIND-POS
  BUILD_LEAST_DERIVED
  Bag
  BagHash
  Bool
  CREATE
  Capture
  DELETE-KEY
  DELETE-POS
  DUMP
  DUMP-OBJECT-ATTRS
  DUMP-PIECES
  EXISTS-KEY
  EXISTS-POS
  FLATTENABLE_HASH
  FLATTENABLE_LIST
  Hash
  List
  Map
  Mix
  MixHash
  Numeric
  Real
  Seq
  Set
  SetHash
  Slip
  Str
  Stringy
  Supply
  WALK
  WHERE
  WHICH
  WHY
  ZEN-KEY
  ZEN-POS
  all
  antipairs
  any
  append
  batch
  bless
  cache
  can
  categorize
  classify
  clone
  collate
  combinations
  deepmap
  defined
  dispatch:<!>
  dispatch:<.*>
  dispatch:<.+>
  dispatch:<.=>
  dispatch:<.?>
  dispatch:<::>
  dispatch:<hyper>
  dispatch:<var>
  does
  duckmap
  eager
  elems
  emit
  end
  first
  flat
  flatmap
  gistseen
  grep
  hash
  head
  invert
  is-lazy
  isa
  item
  iterator
  join
  keys
  kv
  lazy-if
  list
  map
  match
  max
  maxpairs
  min
  minmax
  minpairs
  nl-out
  nodemap
  none
  not
  note
  one
  pairs
  pairup
  perl
  perlseen
  permutations
  pick
  prepend
  print
  print-nl
  produce
  push
  put
  raku
  rakuseen
  reduce
  repeated
  return
  return-rw
  reverse
  roll
  rotor
  say
  self
  serial
  set_why
  skip
  so
  sort
  splice
  split
  squish
  sum
  tail
  take
  toggle
  tree
  unique
  unshift
  values
  C824A7B5D9FB64907E102E2EBF0E8BF6DCE4F48E-0
  gen/moar/BOOTSTRAP/v6c.nqp
  3992F7E094D8028E21BF383D58BA68466D5355C6-0
  gen/moar/Metamodel.nqp
  $/
  $!
  $¢
  hello
   world!
  %_
  @auto
  %init
  GLOBAL
  D709247D04237292F8D0685987174F7FE9B6AB0D-0
  gen/moar/stage2/NQPCORE.setting
  hw
  EXPORT
  d
  no_roles
  unhidden
  !UNIT_MARKER
  $class_type
  6
  <dependencies+deserialize>
  ModuleLoader.moarvm
  nqp
  ModuleLoader
  Perl6::ModuleLoader
  load_module
  CORE.d
  load_setting
  D60E7C22BBEBA9D59107DF3326C1C4F559741DF5
  7
  resolve_repossession_conflicts
  8
  <load>
  GLOBALish
  $?PACKAGE
  ::?PACKAGE
  $=finish
  $=pod
  $?CLASS
  ::?CLASS
  $*DISPATCHER
  $*NEXT-DISPATCHER
****END-STRINGTABLE****

****CALLSITES****
  [0]
    [0] - (MVM_CALLSITE_ARG_OBJ)
    [1] - (MVM_CALLSITE_ARG_OBJ)
  [1]
    [0] - (MVM_CALLSITE_ARG_OBJ)
  [2]

  [3]
    [0] - (MVM_CALLSITE_ARG_OBJ)
    [1] - (MVM_CALLSITE_ARG_OBJ)
****END-CALLSITES****
```
