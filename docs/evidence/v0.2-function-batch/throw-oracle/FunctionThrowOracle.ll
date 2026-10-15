; ModuleID = 'target/oracle/FunctionThrowOracle.ll'
source_filename = "target/oracle/FunctionThrowOracle.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx27.0.0"

%Ts6UInt32V = type <{ i32 }>
%swift.protocol = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i32, i32, i32, i32, i32, i32 }
%swift.method_descriptor = type { i32, i32 }
%objc_class = type { ptr, ptr, ptr, ptr, ptr }
%swift.opaque = type opaque
%swift.type_metadata_record = type { i32 }
%swift.type = type { i64 }
%swift.metadata_response = type { ptr, i64 }

@.str.24.__corsairs_swift_throw__ = private unnamed_addr constant [25 x i8] c"__corsairs_swift_throw__\00"
@"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp" = internal global <{ <{ i32 }>, <{ %Ts6UInt32V, %Ts6UInt32V }> }> zeroinitializer, align 4
@"$s19FunctionThrowOracle17DeliberateFailureVACs5ErrorAAWL" = linkonce_odr hidden local_unnamed_addr global ptr null, align 8
@"$ss5ErrorMp" = external global %swift.protocol, align 4
@"got.$ss5ErrorMp" = private unnamed_addr constant ptr @"$ss5ErrorMp"
@"$ss5ErrorP7_domainSSvgTq" = external global %swift.method_descriptor, align 4
@"got.$ss5ErrorP7_domainSSvgTq" = private unnamed_addr constant ptr @"$ss5ErrorP7_domainSSvgTq"
@"$ss5ErrorP5_codeSivgTq" = external global %swift.method_descriptor, align 4
@"got.$ss5ErrorP5_codeSivgTq" = private unnamed_addr constant ptr @"$ss5ErrorP5_codeSivgTq"
@"$ss5ErrorP9_userInfoyXlSgvgTq" = external global %swift.method_descriptor, align 4
@"got.$ss5ErrorP9_userInfoyXlSgvgTq" = private unnamed_addr constant ptr @"$ss5ErrorP9_userInfoyXlSgvgTq"
@"$ss5ErrorP19_getEmbeddedNSErroryXlSgyFTq" = external global %swift.method_descriptor, align 4
@"got.$ss5ErrorP19_getEmbeddedNSErroryXlSgyFTq" = private unnamed_addr constant ptr @"$ss5ErrorP19_getEmbeddedNSErroryXlSgyFTq"
@"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMcMK" = internal global [16 x ptr] zeroinitializer
@"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc" = constant { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 } { i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5ErrorMp" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc" to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 1) to i64)) to i32), i32 0, i32 196608, i32 4, i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5ErrorP7_domainSSvgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 5) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP7_domainSSvgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 6) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5ErrorP5_codeSivgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 7) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP5_codeSivgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 8) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5ErrorP9_userInfoyXlSgvgTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 9) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP9_userInfoyXlSgvgTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 10) to i64)) to i32), i32 add (i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5ErrorP19_getEmbeddedNSErroryXlSgyFTq" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 11) to i64)) to i32), i32 1), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP19_getEmbeddedNSErroryXlSgyFTW" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 12) to i64)) to i32), i16 0, i16 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMcMK" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", i32 0, i32 16) to i64)) to i32) }, section "__TEXT,__const", no_sanitize_address, align 4
@"$sBoWV" = external global ptr, align 8
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMm" = internal global %objc_class { ptr @"OBJC_METACLASS_$__TtCs12_SwiftObject", ptr @"OBJC_METACLASS_$__TtCs12_SwiftObject", ptr @_objc_empty_cache, ptr null, ptr @_METACLASS_DATA__TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload }, align 8
@"OBJC_CLASS_$__TtCs12_SwiftObject" = external global %objc_class, align 8
@_objc_empty_cache = external global %swift.opaque
@"OBJC_METACLASS_$__TtCs12_SwiftObject" = external global %objc_class, align 8
@.str.69._TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload = private unnamed_addr constant [70 x i8] c"_TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload\00", section "__TEXT,__objc_classname,cstring_literals"
@_METACLASS_DATA__TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload = internal constant { i32, i32, i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr } { i32 129, i32 40, i32 40, i32 0, ptr null, ptr @.str.69._TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload, ptr null, ptr null, ptr null, ptr null, ptr null }, section "__DATA, __objc_const", align 8
@_DATA__TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload = internal constant { i32, i32, i32, i32, ptr, ptr, ptr, ptr, ptr, ptr, ptr } { i32 128, i32 16, i32 16, i32 0, ptr null, ptr @.str.69._TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload, ptr null, ptr null, ptr null, ptr null, ptr null }, section "__DATA, __objc_const", align 8
@.str.19.FunctionThrowOracle = private constant [20 x i8] c"FunctionThrowOracle\00"
@"$s19FunctionThrowOracleMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.19.FunctionThrowOracle to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s19FunctionThrowOracleMXM", i32 0, i32 2) to i64)) to i32) }>, section "__TEXT,__constg_swiftt", align 4
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMXX" = linkonce_odr hidden constant <{ i32, i32 }> <{ i32 66, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracleMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32 }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMXX", i32 0, i32 1) to i64)) to i32) }>, section "__TEXT,__constg_swiftt", align 4
@.str.7.Payload = private constant [8 x i8] c"Payload\00"
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn" = internal constant <{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %swift.method_descriptor }> <{ i32 -2147483568, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMXX" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %swift.method_descriptor }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.7.Payload to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %swift.method_descriptor }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %swift.method_descriptor }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, %swift.method_descriptor }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn", i32 0, i32 4) to i64)) to i32), i32 0, i32 3, i32 11, i32 1, i32 0, i32 10, i32 10, i32 1, %swift.method_descriptor { i32 1, i32 0 } }>, section "__TEXT,__constg_swiftt", align 4
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMf" = internal global <{ ptr, ptr, ptr, i64, ptr, ptr, ptr, ptr, i32, i32, i32, i16, i16, i32, i32, ptr, ptr, ptr }> <{ ptr null, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCfD", ptr @"$sBoWV", i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMm" to i64), ptr @"OBJC_CLASS_$__TtCs12_SwiftObject", ptr @_objc_empty_cache, ptr null, ptr getelementptr (i8, ptr @_DATA__TtC19FunctionThrowOracleP33_DCBE2AD4AC33E06580C87F2F7FB768997Payload, i64 2), i32 2, i32 0, i32 16, i16 7, i16 0, i32 112, i32 24, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn", ptr null, ptr @swift_deletedMethodError }>, align 8
@"symbolic _____ 19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLC" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLC", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMF" = internal constant { i32, i32, i16, i16, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLC" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMF" to i64)) to i32), i32 0, i16 1, i16 12, i32 0 }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@.str.17.DeliberateFailure = private constant [18 x i8] c"DeliberateFailure\00"
@"$s19FunctionThrowOracle17DeliberateFailureVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracleMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.17.DeliberateFailure to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", i32 0, i32 4) to i64)) to i32), i32 1, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s19FunctionThrowOracle17DeliberateFailureVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, [4 x i8] }> <{ ptr null, ptr @"$sBoWV", i64 512, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", i32 0, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 19FunctionThrowOracle17DeliberateFailureV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 19FunctionThrowOracle17DeliberateFailureV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@0 = private constant [8 x i8] c"payload\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s19FunctionThrowOracle17DeliberateFailureVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 19FunctionThrowOracle17DeliberateFailureV" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 1, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLC" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @0 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32 }, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMF", i32 0, i32 7) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"_swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float"
@"_swift_FORCE_LOAD_$_swiftFoundation_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftFoundation"
@"_swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC"
@"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation"
@"_swift_FORCE_LOAD_$_swiftDispatch_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftDispatch"
@"_swift_FORCE_LOAD_$_swiftXPC_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftXPC"
@"_swift_FORCE_LOAD_$_swiftIOKit_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftIOKit"
@"_swift_FORCE_LOAD_$_swiftMetal_$_FunctionThrowOracle" = weak_odr hidden constant ptr @"_swift_FORCE_LOAD_$_swiftMetal"
@"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAHc" = private constant i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAHc" to i64)) to i32), section "__TEXT, __swift5_proto, regular", no_sanitize_address, align 4
@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMn" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@"$s19FunctionThrowOracle17DeliberateFailureVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn" to i64), i64 ptrtoint (ptr @"$s19FunctionThrowOracle17DeliberateFailureVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@"objc_classes_$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCN" = internal global ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCN", section "__DATA,__objc_classlist,regular,no_dead_strip", no_sanitize_address, align 8
@llvm.used = appending global [22 x ptr] [ptr @"$s19FunctionThrowOracle08functionB6Countss6UInt64VyF", ptr @"$s19FunctionThrowOracle17DeliberateFailureVHn", ptr @"$s19FunctionThrowOracle17DeliberateFailureVMF", ptr @"$s19FunctionThrowOracle17DeliberateFailureVMa", ptr @"$s19FunctionThrowOracle17DeliberateFailureVMn", ptr @"$s19FunctionThrowOracle17DeliberateFailureVN", ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAHc", ptr @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCHn", ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMF", ptr @__swift_reflection_version, ptr @"_swift_FORCE_LOAD_$_swiftCoreFoundation_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftDispatch_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftFoundation_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftIOKit_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftMetal_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftObjectiveC_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swiftXPC_$_FunctionThrowOracle", ptr @"_swift_FORCE_LOAD_$_swift_Builtin_float_$_FunctionThrowOracle", ptr @corsairs_function_throw_counts, ptr @corsairs_function_throw_oracle, ptr @"objc_classes_$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCN"], section "llvm.metadata"

@"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCN" = internal alias %swift.type, getelementptr inbounds (<{ ptr, ptr, ptr, i64, ptr, ptr, ptr, ptr, i32, i32, i32, i16, i16, i32, i32, ptr, ptr, ptr }>, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMf", i32 0, i32 3)
@"$s19FunctionThrowOracle17DeliberateFailureVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMf", i32 0, i32 2)

; Function Attrs: nounwind
define internal swiftcc void @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCfD"(ptr swiftself %0) #0 {
entry:
  tail call void @os_unfair_lock_lock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  %1 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 8), align 4
  %2 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %1, i32 1)
  %3 = extractvalue { i32, i1 } %2, 1
  br i1 %3, label %6, label %4, !prof !51

4:                                                ; preds = %entry
  %5 = extractvalue { i32, i1 } %2, 0
  store i32 %5, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 8), align 4
  tail call void @os_unfair_lock_unlock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  tail call void @swift_deallocClassInstance(ptr %0, i64 16, i64 7) #3
  ret void

6:                                                ; preds = %entry
  tail call void @llvm.trap() #9
  unreachable
}

define linkonce_odr hidden swiftcc { i64, ptr } @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP7_domainSSvgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = tail call swiftcc { i64, ptr } @"$ss5ErrorPsE7_domainSSvg"(ptr %Self, ptr %SelfWitnessTable, ptr noalias nonnull swiftself %0) #10
  ret { i64, ptr } %1
}

define linkonce_odr hidden swiftcc i64 @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP5_codeSivgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = tail call swiftcc i64 @"$ss5ErrorPsE5_codeSivg"(ptr %Self, ptr %SelfWitnessTable, ptr noalias nonnull swiftself %0) #10
  ret i64 %1
}

define linkonce_odr hidden swiftcc i64 @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP9_userInfoyXlSgvgTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = tail call swiftcc i64 @"$ss5ErrorPsE9_userInfoyXlSgvg"(ptr %Self, ptr %SelfWitnessTable, ptr noalias nonnull swiftself %0) #10
  ret i64 %1
}

define linkonce_odr hidden swiftcc i64 @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAsADP19_getEmbeddedNSErroryXlSgyFTW"(ptr noalias swiftself captures(none) dereferenceable(8) %0, ptr %Self, ptr %SelfWitnessTable) #1 {
entry:
  %1 = tail call swiftcc i64 @"$ss5ErrorPsE19_getEmbeddedNSErroryXlSgyF"(ptr %Self, ptr %SelfWitnessTable, ptr noalias nonnull swiftself %0) #10
  ret i64 %1
}

define swiftcc void @corsairs_function_throw_oracle(ptr noalias sret(%swift.opaque) %0, i64 %1, ptr %2, ptr noalias swiftself %3, ptr noalias swifterror captures(none) dereferenceable(8) %4) #1 {
entry:
  %5 = or i64 sub (i64 ptrtoint (ptr @.str.24.__corsairs_swift_throw__ to i64), i64 32), -9223372036854775808
  %6 = icmp eq i64 %1, -3458764513820540904
  %7 = ptrtoint ptr %2 to i64
  %8 = icmp eq i64 %5, %7
  %or.cond = select i1 %6, i1 %8, i1 false
  br i1 %or.cond, label %12, label %9

9:                                                ; preds = %entry
  %10 = inttoptr i64 %5 to ptr
  %11 = tail call swiftcc i1 @"$ss27_stringCompareWithSmolCheck__9expectingSbs11_StringGutsV_ADs01_G16ComparisonResultOtF"(i64 %1, ptr %2, i64 -3458764513820540904, ptr nonnull %10, i8 0)
  br i1 %11, label %12, label %25

12:                                               ; preds = %entry, %9
  %13 = tail call swiftcc %swift.metadata_response @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMa"(i64 poison) #11
  %14 = extractvalue %swift.metadata_response %13, 0
  %15 = tail call noalias ptr @swift_allocObject(ptr %14, i64 16, i64 7) #3
  tail call void @os_unfair_lock_lock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  %16 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 4), align 4
  %17 = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %16, i32 1)
  %18 = extractvalue { i32, i1 } %17, 1
  br i1 %18, label %29, label %19, !prof !51

19:                                               ; preds = %12
  %20 = extractvalue { i32, i1 } %17, 0
  store i32 %20, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 4), align 4
  tail call void @os_unfair_lock_unlock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  %21 = tail call ptr @"$s19FunctionThrowOracle17DeliberateFailureVACs5ErrorAAWl"() #11
  %22 = tail call swiftcc { ptr, ptr } @swift_allocError(ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMf", i64 16), ptr %21, ptr null, i1 false) #3
  %23 = extractvalue { ptr, ptr } %22, 0
  %24 = extractvalue { ptr, ptr } %22, 1
  store ptr %15, ptr %24, align 8
  store ptr %23, ptr %4, align 8
  tail call swiftcc void @swift_willThrow(ptr swiftself undef, ptr noalias nonnull readonly swifterror captures(none) dereferenceable(8) %4) #3
  br label %27

25:                                               ; preds = %9
  tail call swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque) %0, i64 %1, ptr %2, ptr noalias swiftself %3, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %4)
  %26 = load ptr, ptr %4, align 8
  %.not = icmp eq ptr %26, null
  br i1 %.not, label %common.ret, label %27

common.ret:                                       ; preds = %25, %27
  ret void

27:                                               ; preds = %25, %19
  %28 = phi ptr [ %23, %19 ], [ %26, %25 ]
  store ptr %28, ptr %4, align 8
  br label %common.ret

29:                                               ; preds = %12
  tail call void @llvm.trap() #9
  unreachable
}

declare swiftcc i1 @"$ss27_stringCompareWithSmolCheck__9expectingSbs11_StringGutsV_ADs01_G16ComparisonResultOtF"(i64, ptr, i64, ptr, i8) local_unnamed_addr #1

declare swiftcc void @"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF"(ptr noalias sret(%swift.opaque), i64, ptr, ptr noalias swiftself, ptr noalias swifterror captures(none) dereferenceable(8)) local_unnamed_addr #1

; Function Attrs: nofree noinline nosync nounwind memory(none)
define internal swiftcc %swift.metadata_response @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMa"(i64 %0) #2 {
entry:
  %1 = tail call ptr @objc_opt_self(ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle7Payload33_DCBE2AD4AC33E06580C87F2F7FB76899LLCMf", i64 24)) #3
  %2 = insertvalue %swift.metadata_response undef, ptr %1, 0
  %3 = insertvalue %swift.metadata_response %2, i64 0, 1
  ret %swift.metadata_response %3
}

; Function Attrs: nounwind
declare ptr @swift_allocObject(ptr, i64, i64) local_unnamed_addr #3

; Function Attrs: nounwind optsize
declare void @os_unfair_lock_lock(ptr noundef) local_unnamed_addr #4

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32) #5

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #6

; Function Attrs: nounwind optsize
declare void @os_unfair_lock_unlock(ptr noundef) local_unnamed_addr #4

; Function Attrs: nofree noinline nosync nounwind memory(none)
define linkonce_odr hidden ptr @"$s19FunctionThrowOracle17DeliberateFailureVACs5ErrorAAWl"() local_unnamed_addr #2 {
entry:
  %0 = load ptr, ptr @"$s19FunctionThrowOracle17DeliberateFailureVACs5ErrorAAWL", align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = tail call ptr @swift_getWitnessTable(ptr nonnull @"$s19FunctionThrowOracle17DeliberateFailureVs5ErrorAAMc", ptr nonnull getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMf", i64 16), ptr undef) #12
  store atomic ptr %2, ptr @"$s19FunctionThrowOracle17DeliberateFailureVACs5ErrorAAWL" release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %3 = phi ptr [ %0, %entry ], [ %2, %cacheIsNull ]
  ret ptr %3
}

; Function Attrs: nofree nounwind memory(read)
declare ptr @swift_getWitnessTable(ptr, ptr, ptr) local_unnamed_addr #7

; Function Attrs: nounwind
declare swiftcc { ptr, ptr } @swift_allocError(ptr, ptr, ptr, i1) local_unnamed_addr #3

; Function Attrs: nounwind
declare swiftcc void @swift_willThrow(ptr swiftself, ptr swifterror) local_unnamed_addr #3

; Function Attrs: nounwind
define i64 @corsairs_function_throw_counts() #0 {
entry:
  tail call void @os_unfair_lock_lock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp") #10
  %0 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 4), align 4
  %1 = zext i32 %0 to i64
  %2 = shl nuw i64 %1, 32
  %3 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 8), align 4
  %4 = zext i32 %3 to i64
  %5 = or disjoint i64 %2, %4
  tail call void @os_unfair_lock_unlock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp") #10
  ret i64 %5
}

; Function Attrs: nounwind
define swiftcc i64 @"$s19FunctionThrowOracle08functionB6Countss6UInt64VyF"() #0 {
entry:
  tail call void @os_unfair_lock_lock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  %0 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 4), align 4
  %1 = zext i32 %0 to i64
  %2 = shl nuw i64 %1, 32
  %3 = load i32, ptr getelementptr inbounds nuw (i8, ptr @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp", i64 8), align 4
  %4 = zext i32 %3 to i64
  %5 = or disjoint i64 %2, %4
  tail call void @os_unfair_lock_unlock(ptr nonnull @"$s19FunctionThrowOracle13payloadCounts33_DCBE2AD4AC33E06580C87F2F7FB76899LL15Synchronization5MutexVys6UInt32V7created_AH9destroyedtGvp")
  ret i64 %5
}

; Function Attrs: nounwind
declare void @swift_deletedMethodError() #3

; Function Attrs: nounwind
declare ptr @objc_opt_self(ptr) local_unnamed_addr #3

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s19FunctionThrowOracle17DeliberateFailureVMa"(i64 %0) #8 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, [4 x i8] }>, ptr @"$s19FunctionThrowOracle17DeliberateFailureVMf", i32 0, i32 2), i64 0 }
}

declare extern_weak void @"_swift_FORCE_LOAD_$_swift_Builtin_float"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftObjectiveC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftCoreFoundation"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftDispatch"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftXPC"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftIOKit"()

declare extern_weak void @"_swift_FORCE_LOAD_$_swiftMetal"()

; Function Attrs: nounwind
declare void @swift_deallocClassInstance(ptr, i64, i64) local_unnamed_addr #3

declare swiftcc i64 @"$ss5ErrorPsE19_getEmbeddedNSErroryXlSgyF"(ptr, ptr, ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc i64 @"$ss5ErrorPsE9_userInfoyXlSgvg"(ptr, ptr, ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc i64 @"$ss5ErrorPsE5_codeSivg"(ptr, ptr, ptr noalias swiftself) local_unnamed_addr #1

declare swiftcc { i64, ptr } @"$ss5ErrorPsE7_domainSSvg"(ptr, ptr, ptr noalias swiftself) local_unnamed_addr #1

attributes #0 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { nofree noinline nosync nounwind memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { nounwind }
attributes #4 = { nounwind optsize "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #7 = { nofree nounwind memory(read) }
attributes #8 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #9 = { nomerge }
attributes #10 = { noinline }
attributes #11 = { nounwind memory(none) }
attributes #12 = { nounwind memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!swift.module.flags = !{!12}
!llvm.linker.options = !{!13, !14, !15, !16, !17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44, !45, !46, !47, !48, !49, !50}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Objective-C Class Properties", i32 64}
!6 = !{i32 1, !"Objective-C Enforce ClassRO Pointer Signing", i8 0}
!7 = !{i32 1, !"wchar_size", i32 4}
!8 = !{i32 8, !"PIC Level", i32 2}
!9 = !{i32 7, !"uwtable", i32 1}
!10 = !{i32 7, !"frame-pointer", i32 1}
!11 = !{i32 1, !"Swift Version", i32 7}
!12 = !{!"standard-library", i1 false}
!13 = !{!"-lswiftSynchronization"}
!14 = !{!"-lswiftCore"}
!15 = !{!"-lswiftDarwin"}
!16 = !{!"-lswift_DarwinFoundation2"}
!17 = !{!"-lswift_DarwinFoundation1"}
!18 = !{!"-lswift_Builtin_float"}
!19 = !{!"-lswift_DarwinFoundation3"}
!20 = !{!"-framework", !"CoreAI"}
!21 = !{!"-lswift_StringProcessing"}
!22 = !{!"-lswift_Concurrency"}
!23 = !{!"-framework", !"CoreAIDelegates"}
!24 = !{!"-lswiftFoundation"}
!25 = !{!"-framework", !"Foundation"}
!26 = !{!"-lswiftSystem"}
!27 = !{!"-lswiftObservation"}
!28 = !{!"-lswiftObjectiveC"}
!29 = !{!"-lswiftCoreFoundation"}
!30 = !{!"-framework", !"CoreFoundation"}
!31 = !{!"-lswiftDispatch"}
!32 = !{!"-framework", !"Combine"}
!33 = !{!"-framework", !"CoreServices"}
!34 = !{!"-framework", !"Security"}
!35 = !{!"-lswiftXPC"}
!36 = !{!"-framework", !"CFNetwork"}
!37 = !{!"-framework", !"DiskArbitration"}
!38 = !{!"-lswiftIOKit"}
!39 = !{!"-framework", !"IOKit"}
!40 = !{!"-framework", !"CoreAIRuntime"}
!41 = !{!"-lswiftMetal"}
!42 = !{!"-framework", !"Metal"}
!43 = !{!"-framework", !"IOSurface"}
!44 = !{!"-framework", !"CoreVideo"}
!45 = !{!"-framework", !"CoreGraphics"}
!46 = !{!"-framework", !"OpenGL"}
!47 = !{!"-framework", !"CoreAICommon"}
!48 = !{!"-framework", !"CoreAICompiler"}
!49 = !{!"-framework", !"CoreAIAsset"}
!50 = !{!"-lobjc"}
!51 = !{!"branch_weights", !"expected", i32 1, i32 2000}
