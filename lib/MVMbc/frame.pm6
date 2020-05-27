use MVMbc::Opcodes;
use MVMbc::Common;

class MVMframe {
    has uint32 $.bcoffset = 0;
    has uint32 $.bclength = 0;
    has uint32 $.numlocregs = 0;
    has uint32 $.numlexicals = 0;
    has uint32 $.cuuid = 0;
    has uint32 $.name = 0;
    has uint16 $.outer = 0;
    has uint32 $.annotationoffset = 0;
    has uint32 $.numannotations = 0;
    has uint32 $.numhandlers = 0;
    has uint16 $.flagbits = 0;
    has uint16 $.numstatlexicals = 0;
    has uint32 $.objSCdepIDX = 0;
    has uint32 $.scobjIDX = 0;
    has uint32 $.numlocaldbgmaps = 0;

    has @.locals;
    has @.lexicals;
    has MVMhandler @.handlers;
    has MVMslv @.staticvalues;
    has MVMdbgnames @.dbgnames;
    has MVMinstruction @.bytecode;
    has annotation  @.annotations;
    has Bool $.did-i-finish = True;

    submethod TWEAK(:$bc) {
        for ^$!numlocregs { @!locals.push($bc.b.ru16); }
        for ^$!numlexicals { @!lexicals.push( %(type=>$bc.b.ru16,idx=>$bc.b.ru32)); }
        for ^$!numhandlers { @!handlers.push( MVMhandler.new(
                                                        :protstart($bc.b.ru32),
                                                        :protend($bc.b.ru32),
                                                        :categorymask($bc.b.ru32),
                                                        :action($bc.b.ru16),
                                                        :reg($bc.b.ru16),
                                                        :handleroffset($bc.b.ru32)) );
        }

        for ^$!numstatlexicals {
            @!staticvalues.push( MVMslv.new(
                                            :idx($bc.b.ru16),
                                            :flag($bc.b.ru16),
                                            :SCdepidx($bc.b.ru32),
                                            :SCobjidx($bc.b.ru32)));
        }

        for ^$!numlocaldbgmaps {
            my $idx = $bc.b.ru16;
            my $stringidx = $bc.b.ru32;
            my $Str = $bc.strings[$stringidx];
            @!dbgnames.push(MVMdbgnames.new(:$idx, :$stringidx, :$Str));
        }

        #annotations
        my $offsaved = $bc.b.os;
        $bc.b.os = $bc.annotationOffset + $!annotationoffset;
        for ^$!numannotations {
            my $offset = $bc.b.ru32;
            my $shp-idx = $bc.b.ru32;
            my $lnum = $bc.b.ru32;
            my $content = $bc.strings[$shp-idx];
            @!annotations.push( annotation.new( :$offset, :$shp-idx, :$lnum, :$content) );
        }
        $bc.b.os = $offsaved;
        self.parse(:$bc);
    }
    method parse(:$bc) {
        my $offsaved = $bc.b.os;
        $bc.b.os = $!bcoffset + $bc.bytecodeOffset;
        my $limit = $bc.bytecodeOffset + $!bcoffset + $!bclength;
        while $bc.b.os < $limit {
            my $offset = $bc.b.os - $bc.bytecodeOffset;
            my $oc = $bc.b.ru16;
            my @operands;
            my $annotation = Nil;
            if ?@opcodes[$oc]<operands> { for |(@opcodes[$oc]<operands>) {
                given $_ {
                    when /([r||w])l\(/ {#lexical. 2 bytes
                        my $i = $bc.b.ru16;
                        my $idx = $bc.b.ru32;
                        my $val = $bc.strings[$idx] ?? $bc.strings[$idx] !! '';
                        @operands.push(operand.new(:type(opertype::LEXICAL), :$val, :io( $0.Str eq 'r' ?? READ !! WRITE) ));
                    }
                    when /([r||w])\(/ {#local. 2 bytes
                        my $i = $bc.b.ru16;
                        @operands.push(operand.new(:type(opertype::REGISTER), :val($i), :io( $0.Str eq 'r' ?? READ !! WRITE) ) )
                    }
                    when /^(uint64 || uint32 || num64 || num32)$/ { @operands.push(operand.new(:type(bs{$/.Str.uc}), :val($bc.b.ru64)) ) } #8 bytes
                    when /^(int64 || int32)$/ { @operands.push(operand.new(:type(bs{$/.Str.uc}), :val($bc.b.ri64)) ) } #8 bytes
                    when /^(uint16 || uint8 || obj || coderef || callsite)$/ { @operands.push(operand.new(:type(bs{$/.Str.uc}), :val($bc.b.ru16)) ) } # 2 bytes
                    when /^(int16 || int8)$/ { @operands.push(operand.new(:type(bs{$/.Str.uc}), :val($bc.b.ri16)) ) } # 2 bytes
                    when /^(\`1)$/ { @operands.push(operand.new(:type(TYPEVAL), :val($bc.b.ru16)) ) } #going with 2 bytes because that's what it's writing in lib/MAST/Ops.nqp
                    when /^(str || ins)$/ {@operands.push(operand.new(:type(bs{$/.Str.uc}), :val($bc.b.ru32)) ) } # 4 bytes
                    default { die 'i thought we were passed all this...' }
               }
            }}
            #if the opcode has a mark, compare $offset to the annotations, and assign it. something ain't right...
            #if ?@opcodes[$oc]<mark>.defined {  for @!annotations { if $_.offset == $offset { $annotation = $_; } } }
            for @!annotations { if $_.offset == $offset { $annotation = $_; } }
            my MVMinstruction $ins .= new(:opcode($oc), :@operands, :$annotation, :$offset);
            if ?@opcodes[$oc] { @!bytecode.push($ins); }
            #not supporting extops
            else { $!did-i-finish = False; last}
        }
        if $bc.b.os != $limit && $!did-i-finish == True {
            say '$bc.bytecodeOffset: ' ~ $bc.bytecodeOffset;
            say '$!bcoffset: ' ~ $!bcoffset;
            say '$!bclength: ' ~ $!bclength;
            say 'limit: ' ~ $limit;
            say '$bc.b.os: ' ~ $bc.b.os;
            die ｢you'll get the operand sizes right one day｣;
        }
        $bc.b.os = $offsaved;
    }
    method listing($bc) {

        my &printops = -> operand @a {
            my @b;
            for ^@a {
                my $i = $_;
                given @a[$_].type {
                    when REGISTER {
                        my $s = @a[$i].io == READ ?? 'R' !! 'W';
                        @b.push: $s~'reg' ~'('~ @a[$i].val~')';
                    }
                    when LEXICAL {
                        my $s = @a[$i].io == READ ?? 'R' !! 'W';
                        @b.push: $s~'lex' ~'('~ @a[$i].val~')';
                    }
                    when STR {
                        #treat val as index into string table
                        if $bc.strings[@a[$i].val].defined { @b.push('\''~$bc.strings[@a[$i].val] ~ '\'') }
                        else { @b.push: '(str)' }
                    }
                    default { @b.push: @a[$i].type.Str.lc ~'('~ @a[$i].val~')'; }
                }
            }
            print '( ' ~ @b.join(', ') ~ ' )';
        }

        say i(0)~'****FRAME****';
        print i(0) ~ $bc.strings[$!name] ~ (nl x 2);

        for ^@!annotations {
            FIRST { say i(1)~'****ANNOTATIONS****'; }
            print i(2) ~ '['~$_~'] ' ;
            say @!annotations[$_].lnum ~ ': '~ @!annotations[$_].content;
            LAST {print nl;}
        }

        for ^@!dbgnames {
            FIRST {say i(1)~'****DBGNAMES****';}
            print i(2) ~ '['~$_~'] ' ~ @!dbgnames[$_].Str ~ nl;
            LAST { print nl;}
        }

        for ^@!locals {
            FIRST {say i(1)~'****LOCALS****';}
            print i(2) ~ '['~$_~'] ';
            say ?types{@!locals[$_]} ?? types{@!locals[$_]} !! 'unknown type';
            LAST { print nl;}
        }

        for ^@!lexicals {
            FIRST {say i(1)~'****LEXICALS****';}
            print i(2)~'['~$_~'] ' ;
            print ?types{@!lexicals[$_]<type>} ?? types{@!lexicals[$_]<type>} !! 'unk';
            print ': ';
            say ?$bc.strings[@!lexicals[$_]<idx>] ?? $bc.strings[@!lexicals[$_]<idx>] !! 'not in string table';
            LAST { print nl;}
        }


        for ^@!staticvalues {
            FIRST {say i(1)~'****SLVLS****';};
            say i(2)~@!staticvalues[$_].perl;
            LAST { print nl;}
        }

        say i(1)~'****OPS****';
        for @!bytecode -> $op {
            print i(2) ~ $op.name();
            &printops($op.operands);
            if ?$op.annotation { print ' :' ~ $op.annotation.content  }
            print nl;
        }

        unless $!did-i-finish { say i(1)~'BAILED out due to extops.'}
        print nl;

        for ^$!numhandlers {
            FIRST {say i(1)~'****HANDLERS****';}
            say i(2)~@!handlers[$_]
        }
        print nl;
        say i(0)~'****END-FRAME****'~nl;
    }
}
