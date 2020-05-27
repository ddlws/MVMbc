use MVMbc::Opcodes;

sub i($n) is export {' ' x (2 * $n) }
constant \nl = "\n";
constant \types = {   1  => 'int8',
                            2  => 'int16',
                            3  => 'int32',
                            4  => 'int64',
                            5  => 'num32',
                            6  => 'num64',
                            7  => 'str',
                            8  => 'obj',
                            17 => 'uint8',
                            18 => 'uint16',
                            19 => 'uint32',
                            20 => 'uint64' };
enum opertype ('UINT64', 'INT64', 'UINT32', 'INT32', 'NUM64', 'NUM32', 'UINT16', 'INT16', 'UINT8', 'INT8', 'OBJ', 'CODEREF', 'CALLSITE', 'TYPEVAL', 'STR', 'INS', 'REGISTER', 'LEXICAL');

constant \bs is export = {
                            'UINT64' => opertype::UINT64,
                            'INT64' =>  opertype::INT64,
                            'UINT32' =>  opertype::UINT32,
                            'INT32' =>  opertype::INT32,
                            'NUM64' => opertype::NUM64,
                            'NUM32' => opertype::NUM32,
                            'UINT16' => opertype::UINT16,
                            'INT16' => opertype::INT16,
                            'UINT8' =>  opertype::UINT8,
                            'INT8' => opertype::INT8,
                            'OBJ' =>  opertype::OBJ,
                            'CODEREF' => opertype::CODEREF,
                            'CALLSITE' => opertype::CALLSITE,
                            'TYPEVAL' =>  opertype::TYPEVAL,
                            'STR' =>  opertype::STR,
                            'INS' =>  opertype::INS,
                            'REGISTER' =>  opertype::REGISTER,
                            'LEXICAL' =>  opertype::LEXICAL,
}

enum inout <READ WRITE>;
class operand {
    has $.type;
    has $.val = '';
    has $.io = Nil;
}
#`(class op {
    has uint16 $.opcode;
    has Str $.name;
    has uint16 $.numoperands;
    has Bool $.pure;
    has Bool $.deopt_point;
    has Bool $.may_cause_deopt;
    has Bool $.logged;
    has Bool $.no_inline;
    has Bool $.jittitivity;
    has Bool $.uses_hll;
    has Bool $.specializable;
    has operand @.operands;
}             )
class MVMextOp {
    has uint32 $.stringheapidx;
    has uint8 @.opdesc[8];
}
class bin8 {
    has buf8 $.bs handles(<elems push pop append prepend shift unshift read-uint32 read-uint16 AT-POS EXISTS-POS subbuf>);
    method ri8() { my $tmp = $!bs.read-int8($!os); $!os+=1; return $tmp; }
    method ru8() { my $tmp = $!bs.read-uint8($!os); $!os+=1; return $tmp; }
    method ri16() { my $tmp = $!bs.read-int16($!os); $!os+=2; return $tmp; }
    method ru16() { my $tmp = $!bs.read-uint16($!os); $!os+=2; return $tmp; }
    method ri32() { my $tmp = $!bs.read-int32($!os); $!os+=4; return $tmp; }
    method ru32() { my $tmp = $!bs.read-uint32($!os); $!os+=4; return $tmp; }
    method ri64() { my $tmp = $!bs.read-int64($!os); $!os+=8; return $tmp; }
    method ru64() { my $tmp = $!bs.read-uint64($!os); $!os+=8; return $tmp; }
    method ri128() { my $tmp = $!bs.read-int128($!os); $!os+=16; return $tmp; }
    method ru128() { my $tmp = $!bs.read-uint128($!os); $!os+=16; return $tmp; }
    has $.os is rw = 0;
    submethod new($b) { self.bless(:bs($b)) }
}
enum csflags (
    #/* Argument is an object. */
    MVM_CALLSITE_ARG_OBJ => 1,
    #/* Argument is a native integer, signed. */
    MVM_CALLSITE_ARG_INT => 2,
    #/* Argument is a native floating point number. */
    MVM_CALLSITE_ARG_NUM => 4,
    #/* Argument is a native NFG string (MVMString REPR). */
    MVM_CALLSITE_ARG_STR => 8,
    #/* Argument is named. The name is placed in the MVMCallsite. */
    MVM_CALLSITE_ARG_NAMED => 32,
    # /* Argument is flattened. What this means is up to the target. */
    MVM_CALLSITE_ARG_FLAT => 64,
    # /* Argument is flattened and named. */
    MVM_CALLSITE_ARG_FLAT_NAMED => 128
);
class callsite {
    has uint16 $.numflags;
    has uint8 @.flags;
    has int32 @.shp-idx;
}
class MVMinstruction {
    has uint16 $.opcode;
    has operand @.operands;
    has $.annotation;
    has $.offset; # this is an offset in the frame's bytecode section. only for debugging atm

    method name() { return @opcodes[$!opcode]{'name'}; }
}
class MVMhandler {
    has uint32 $.protstart;
    has uint32 $.protend;
    has uint32 $.categorymask;
    has uint16 $.action;
    has uint16 $.reg;
    has uint32 $.handleroffset;
}
class MVMslv {
    has uint16 $.idx;
    has uint16 $.flag;
    has uint32 $.SCdepidx;
    has uint32 $.SCobjidx;
}
class MVMdbgnames {
    has uint16 $.idx;
    has uint32 $.stringidx;
    has Str $.Str;
}
class lexical {
    has int16 $.type;
    has int32 $.nameidx;
}

class SC {
    has uint32 $.shp-idx;
    has Str $.sc-uid;
}

class annotation {
    has uint32 $.offset;
    has uint32 $.shp-idx;
    has uint32 $.lnum;
    has $.content;
}
