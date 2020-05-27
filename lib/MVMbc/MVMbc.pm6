use MVMbc::Frame;
use MVMbc::Common;

#`(
# from rakudo/src/core.c/CompUnit/PrecompilationStore/File.pm6
       method save-to(IO::Path $precomp-file) {
            my $handle := $precomp-file.open(:w);
            $handle.print($!checksum ~ "\n");
            $handle.print($!source-checksum ~ "\n");
            $handle.print($_.serialize ~ "\n") for @!dependencies;
            $handle.print("\n");
            $handle.write($!bytecode);
            $handle.close;
            $!path := $precomp-file;
        }
)
class MVMBC {
    has uint8 @.magic[8];
    has uint32 $.Version = 0;
    has uint32 $.SCtableOffset = 0;
    has uint32 $.numSCentries = 0;
    has uint32 $.extOPsOffset = 0;
    has uint32 $.numExtOps = 0;
    has uint32 $.framesOffset = 0;
    has uint32 $.numFrames = 0;
    has uint32 $.callsitesOffset = 0;
    has uint32 $.numCallsites = 0;
    has uint32 $.stringsOffset = 0;
    has uint32 $.numStrings = 0;
    has uint32 $.SCdataOffset = 0;
    has uint32 $.SCdataLength = 0;
    has uint32 $.bytecodeOffset = 0;
    has uint32 $.bytecodeLength = 0;
    has uint32 $.annotationOffset = 0;
    has uint32 $.annotationLength = 0;
    has uint32 $.HLLnameIDX = 0;
    has uint32 $.MainFrameIDX = 0;
    has uint32 $.libLoadFrameIDX = 0;
    has uint32 $.deserializationFrameIDX = 0;

    has Str         @.strings;
    has MVMframe    @.frames;
    has MVMextOp    @.extops;
    has callsite    @.callsites;
    has SC          @.scontexts;
    has bin8 $.b;
    method !addCallsites() {
        $!b.os = $!callsitesOffset;
        for ^$!numCallsites {
            my $numflags;
            my @flags;
            my @shp-idx;
            $numflags =  $!b.ru16;
            for ^$numflags {
                my $t = $!b.ru8;
                if $t +& MVM_CALLSITE_ARG_NAMED { @shp-idx[$_]=1 }
                else { @shp-idx[$_]=0 }
                @flags[$_] = $t
            }
            if $numflags % 2 == 1 { $!b.os++ }  #docs say 16-bit alignment
            for ^$numflags {
                if @shp-idx[$_] == 1 { @shp-idx[$_] = $!b.ri32 }
            }
            @!callsites.push( callsite.new(:$numflags, :@flags, :@shp-idx) );
        }
    }
    method !addStrings() {
        $!b.os = $!stringsOffset;
        for ^$.numStrings {
            # test the lsb. 1=utf8 and 0=latin-1
            my $length = $!b.ru32;
            my $enc = $length +& 1 ?? 'utf8' !! 'latin-1';
            $length +>= 1;

            # subbuf, decode, push to @.strings, move offset
            @.strings.push($!b.subbuf($!b.os,$length).decode($enc));
            $!b.os += $length;
            $!b.os += ($!b.os % 4) ?? (4 - ($!b.os % 4) ) !! 0; #alignment
        }
    }
    method !addFrames() {
        $!b.os = $!framesOffset;
        for ^$!numFrames {
            @!frames.push(MVMframe.new(
                :bcoffset($!b.ru32),
                :bclength($!b.ru32),
                :numlocregs($!b.ru32),
                :numlexicals($!b.ru32),
                :cuuid($!b.ru32),
                :name($!b.ru32),
                :outer($!b.ru16),
                :annotationoffset($!b.ru32),
                :numannotations($!b.ru32),
                :numhandlers($!b.ru32),
                :flagbits($!b.ru16),
                :numstatlexicals($!b.ru16),
                :objSCdepIDX($!b.ru32),
                :scobjIDX($!b.ru32),
                :numlocaldbgmaps($!b.ru32),
                :bc(self)
                ));
        }
    }
    method !addExtops() {
        $!b.os = $!extOPsOffset;
        for ^$!numExtOps {
            @!extops.push( MVMextOp.new(
                :stringheapidx($!b.ru32),
                :opdesc( for ^8 { $!b.ru8 } ),
                ));
        }
    }
    method !addSCs() {
        $!b.os = $!SCtableOffset;
        for ^$!numSCentries {
            my $shp-idx = $!b.ru32;
            my $sc-uid = @!strings[$shp-idx];
            @!scontexts.push( SC.new( :$shp-idx, :$sc-uid) );
        }
    }
    multi submethod new(Str $path) {
        my bin8 $b .= new($path.IO.slurp(:bin));
        self.new($b);
    }
    multi submethod new(bin8 $b) {
        self.bless( :magic(for ^8 { $b.ru8 }),
                    :Version($b.ru32),
                    :SCtableOffset($b.ru32),
                    :numSCentries($b.ru32),
                    :extOPsOffset($b.ru32),
                    :numExtOps($b.ru32),
                    :framesOffset($b.ru32),
                    :numFrames($b.ru32),
                    :callsitesOffset($b.ru32),
                    :numCallsites($b.ru32),
                    :stringsOffset($b.ru32),
                    :numStrings($b.ru32),
                    :SCdataOffset($b.ru32),
                    :SCdataLength($b.ru32),
                    :bytecodeOffset($b.ru32),
                    :bytecodeLength($b.ru32),
                    :annotationOffset($b.ru32),
                    :annotationLength($b.ru32),
                    :HLLnameIDX($b.ru32),
                    :MainFrameIDX($b.ru32),
                    :libLoadFrameIDX($b.ru32),
                    :deserializationFrameIDX($b.ru32),
                    :$b);
    }
    submethod TWEAK() {
        self!addStrings();
        self!addExtops();
        self!addFrames();
        self!addCallsites();
        self!addSCs();
    }
    method hll() { return @!strings[$!HLLnameIDX]; }
    method listing() {
        my &i = -> $n { ' ' x (2 * $n) };

        say 'MVMbc listing';
        printf('Bytecode Version: %d'~nl,$!Version);
        printf('HLLname: %s'~nl,@!strings[$!HLLnameIDX]);
        printf('MainFrame idx: %d'~nl,$!MainFrameIDX);
        printf('Frames: %d'~nl,$!numFrames);
        printf('S.Contexts: %d'~nl,$!numSCentries);
        printf('S.SCdataOffset: %d'~nl,$!SCdataOffset);
        printf('S.SCdataLength: %d'~nl,$!SCdataLength);
        printf('ExtOps: %d'~nl,$!numExtOps);
        printf('Callsites: %d'~nl,$!numCallsites);
        printf('libLoadFrame idx: %d'~nl,$!libLoadFrameIDX);
        printf('deserializationFrame idx: %d'~nl,$!deserializationFrameIDX);
        print nl;

        say &i(0)~'****Serialization-Contexts****';
        for @!scontexts { say &i(1) ~ $_.sc-uid }

        for @!frames { $_.listing(self); }
        say &i(0)~'****STRINGTABLE****';
        for @!strings { say &i(1) ~ $_ }
        say &i(0)~'****END-STRINGTABLE****'~nl;
        say &i(0)~'****CALLSITES****';
        my &parse-csf = -> $f {
            my SetHash $s;
            given $f {
                when $_ +& MVM_CALLSITE_ARG_OBJ { $s<MVM_CALLSITE_ARG_OBJ>++ }
                when $_ +& MVM_CALLSITE_ARG_INT { $s<MVM_CALLSITE_ARG_INT>++ }
                when $_ +& MVM_CALLSITE_ARG_NUM { $s<MVM_CALLSITE_ARG_NUM>++ }
                when $_ +& MVM_CALLSITE_ARG_STR { $s<MVM_CALLSITE_ARG_STR>++ }
                when $_ +& MVM_CALLSITE_ARG_NAMED { $s<MVM_CALLSITE_ARG_NAMED>++ }
                when $_ +& MVM_CALLSITE_ARG_FLAT { $s<MVM_CALLSITE_ARG_FLAT>++ }
                when $_ +& MVM_CALLSITE_ARG_FLAT_NAMED { $s<MVM_CALLSITE_ARG_FLAT_NAMED>++ }
            }
            $s;
        }
        for ^@!callsites {
            my $c = @!callsites[$_];
            say &i(1) ~ '['~$_~'] ';
            unless $c.flags { say '' }
            for ^$c.flags {
                if ?$c.shp-idx[$_] != 0 { say &i(2) ~'\''~ @!strings[$c.shp-idx[$_]] ~ '\''; }
                say &i(2) ~'['~$_~'] - ('~ &parse-csf($_).keys.join(', ')~') ';
            }
        }
        say &i(0)~'****END-CALLSITES****'~nl;
    }
}
