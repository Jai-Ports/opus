// Generated directly from C by cpp_transpiler.
SILK_TARGET_RATE_WB_21: [191] u8;

SILK_TARGET_RATE_MB_21: [155] u8;

SILK_TARGET_RATE_NB_21: [107] u8;

silk_clz16_in_control_snr :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_control_snr :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_control_snr :: () -> s32 {
    return 0;
}

silk_ror32_in_control_snr :: (a32: Int32, rot: s32) -> Int32 {
    x := cast,no_check(Uint32) a32;
    r := cast,no_check(Uint32) rot;
    m := cast,no_check(Uint32) (-rot);
    if rot == 0 {
        return a32;
    } else if rot < 0 {
        return cast,no_check(Int32) (x << ((m) & 31) | (x >> (((32 - m)) & 31)));
    } else {
        return cast,no_check(Int32) (x << (((32 - r)) & 31) | (x >> ((r) & 31)));
    }
}

silk_min_int_in_control_snr :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_control_snr :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_control_snr :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_control_snr :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_control_snr :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_control_snr :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_control_snr :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_control_snr :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_control_snr :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_control_snr(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_control_snr(in_upper);
    }
}

silk_clz_frac_in_control_snr :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_control_snr(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_control_snr(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_control_snr :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_control_snr(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_control_snr :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_control_snr((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_control_snr((ifx B32 > 0 then B32 else -B32)) - 1;
    b32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) B32) << ((b_headrm) & 31));

    b32_inv := (cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 2))) / b32_nrm >> 16;

    result :=
        cast,no_check(Int32) (((cast(Int64) a32_nrm) *
            cast,no_check(Int64) (cast,no_check(Int16) b32_inv)) >> 16);

    a32_nrm =
        cast,no_check(Int32) ((cast,no_check(Uint32) a32_nrm) -
            cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast,no_check(Int64) b32_nrm) * cast(Int64) result) >> 32))) << 3)));

    result =
        cast,no_check(Int32) ((cast(Int64) result) +
            ((cast(Int64) a32_nrm) * cast,no_check(Int64) (cast,no_check(Int16) b32_inv)) >> 16);

    lshift := 29 + a_headrm - b_headrm - QRES;
    if lshift < 0 {
        return cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> ((-lshift) & 31) > (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (ifx result > (cast(Int32) -2147483648) >> ((-lshift) & 31) then (cast(Int32) -2147483648) >> ((-lshift) & 31) else (ifx result < (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (cast(s32) 0x7fffffff) >> ((-lshift) & 31) else result)) else (ifx result > (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (cast(s32) 0x7fffffff) >> ((-lshift) & 31) else (ifx result < (cast(Int32) -2147483648) >> ((-lshift) & 31) then (cast(Int32) -2147483648) >> ((-lshift) & 31) else result))))) << ((-lshift) & 31));
    } else if lshift < 32 {
        return result >> ((lshift) & 31);
    } else {
        return 0;
    }
}

silk_inverse32_var_q_in_control_snr :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_control_snr((ifx B32 > 0 then B32 else -B32)) - 1;
    b32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) B32) << ((b_headrm) & 31));

    b32_inv := (cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 2))) / b32_nrm >> 16;

    result := cast,no_check(Int32) ((cast,no_check(Uint32) b32_inv) << 16);

    err_q32 :=
        cast,no_check(Int32) ((cast,no_check(Uint32) ((cast,no_check(Int32) (((cast(s32) 1) << 29))) -
            cast,no_check(Int32) (((cast(Int64) b32_nrm) * cast,no_check(Int64) (cast,no_check(Int16) b32_inv)) >> 16))) << 3);

    result = cast,no_check(Int32) ((cast(Int64) result) + ((cast,no_check(Int64) err_q32) * cast(Int64) b32_inv) >> 16);

    lshift := 61 - b_headrm - QRES;
    if lshift <= 0 {
        return cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> ((-lshift) & 31) > (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (ifx result > (cast(Int32) -2147483648) >> ((-lshift) & 31) then (cast(Int32) -2147483648) >> ((-lshift) & 31) else (ifx result < (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (cast(s32) 0x7fffffff) >> ((-lshift) & 31) else result)) else (ifx result > (cast(s32) 0x7fffffff) >> ((-lshift) & 31) then (cast(s32) 0x7fffffff) >> ((-lshift) & 31) else (ifx result < (cast(Int32) -2147483648) >> ((-lshift) & 31) then (cast(Int32) -2147483648) >> ((-lshift) & 31) else result))))) << ((-lshift) & 31));
    } else if lshift < 32 {
        return result >> ((lshift) & 31);
    } else {
        return 0;
    }
}

ec_range_bytes_in_control_snr :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_control_snr :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_control_snr :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_control_snr :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_control_snr :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_control_snr :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_control_snr :: (ps_enc_c: *Silk_Encoder_State, target_rate_bps: Int32) -> s32 {
    bound: s32 = ---;
    snr_table: *u8 = ---;

    ps_enc_c.target_rate_bps = target_rate_bps;
    if ps_enc_c.nb_subfr == 2 {
        target_rate_bps = cast,no_check(Int32) (target_rate_bps - (2000 + ps_enc_c.fs_k_hz / 16));
    }
    if ps_enc_c.fs_k_hz == 8 {
        bound = cast,no_check(s32) (SILK_TARGET_RATE_NB_21.count);
        snr_table = SILK_TARGET_RATE_NB_21.data;
    } else if ps_enc_c.fs_k_hz == 12 {
        bound = cast,no_check(s32) (SILK_TARGET_RATE_MB_21.count);
        snr_table = SILK_TARGET_RATE_MB_21.data;
    } else {
        bound = cast,no_check(s32) (SILK_TARGET_RATE_WB_21.count);
        snr_table = SILK_TARGET_RATE_WB_21.data;
    }
    id := (target_rate_bps + 200) / 400;
    id = ifx id - 10 < bound - 1 then id - 10 else bound - 1;
    if id <= 0 {
        ps_enc_c.snr_d_b_q7 = 0;
    } else {
        ps_enc_c.snr_d_b_q7 = (cast(s32) snr_table[id]) * 21;
    }
    return 0;
}

globals_initialization_state_for_control_snr: u32;
initialize_globals_for_control_snr :: () {
    {
        state := atomic_load(*globals_initialization_state_for_control_snr);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_control_snr, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_control_snr) != 2 {}
            return;
        }
    }
    SILK_TARGET_RATE_NB_21 =
        u8.[
            0,
            15,
            39,
            52,
            61,
            68,
            74,
            79,
            84,
            88,
            92,
            95,
            99,
            102,
            105,
            108,
            111,
            114,
            117,
            119,
            122,
            124,
            126,
            129,
            131,
            133,
            135,
            137,
            139,
            142,
            143,
            145,
            147,
            149,
            151,
            153,
            155,
            157,
            158,
            160,
            162,
            163,
            165,
            167,
            168,
            170,
            171,
            173,
            174,
            176,
            177,
            179,
            180,
            182,
            183,
            185,
            186,
            187,
            189,
            190,
            192,
            193,
            194,
            196,
            197,
            199,
            200,
            201,
            203,
            204,
            205,
            207,
            208,
            209,
            211,
            212,
            213,
            215,
            216,
            217,
            219,
            220,
            221,
            223,
            224,
            225,
            227,
            228,
            230,
            231,
            232,
            234,
            235,
            236,
            238,
            239,
            241,
            242,
            243,
            245,
            246,
            248,
            249,
            250,
            252,
            253,
            255
        ];
    SILK_TARGET_RATE_MB_21 =
        u8.[
            0,
            0,
            28,
            43,
            52,
            59,
            65,
            70,
            74,
            78,
            81,
            85,
            87,
            90,
            93,
            95,
            98,
            100,
            102,
            105,
            107,
            109,
            111,
            113,
            115,
            116,
            118,
            120,
            122,
            123,
            125,
            127,
            128,
            130,
            131,
            133,
            134,
            136,
            137,
            138,
            140,
            141,
            143,
            144,
            145,
            147,
            148,
            149,
            151,
            152,
            153,
            154,
            156,
            157,
            158,
            159,
            160,
            162,
            163,
            164,
            165,
            166,
            167,
            168,
            169,
            171,
            172,
            173,
            174,
            175,
            176,
            177,
            178,
            179,
            180,
            181,
            182,
            183,
            184,
            185,
            186,
            187,
            188,
            188,
            189,
            190,
            191,
            192,
            193,
            194,
            195,
            196,
            197,
            198,
            199,
            200,
            201,
            202,
            203,
            203,
            204,
            205,
            206,
            207,
            208,
            209,
            210,
            211,
            212,
            213,
            214,
            214,
            215,
            216,
            217,
            218,
            219,
            220,
            221,
            222,
            223,
            224,
            224,
            225,
            226,
            227,
            228,
            229,
            230,
            231,
            232,
            233,
            234,
            235,
            236,
            236,
            237,
            238,
            239,
            240,
            241,
            242,
            243,
            244,
            245,
            246,
            247,
            248,
            249,
            250,
            251,
            252,
            253,
            254,
            255
        ];
    SILK_TARGET_RATE_WB_21 =
        u8.[
            0,
            0,
            0,
            8,
            29,
            41,
            49,
            56,
            62,
            66,
            70,
            74,
            77,
            80,
            83,
            86,
            88,
            91,
            93,
            95,
            97,
            99,
            101,
            103,
            105,
            107,
            108,
            110,
            112,
            113,
            115,
            116,
            118,
            119,
            121,
            122,
            123,
            125,
            126,
            127,
            129,
            130,
            131,
            132,
            134,
            135,
            136,
            137,
            138,
            140,
            141,
            142,
            143,
            144,
            145,
            146,
            147,
            148,
            149,
            150,
            151,
            152,
            153,
            154,
            156,
            157,
            158,
            159,
            159,
            160,
            161,
            162,
            163,
            164,
            165,
            166,
            167,
            168,
            169,
            170,
            171,
            171,
            172,
            173,
            174,
            175,
            176,
            177,
            177,
            178,
            179,
            180,
            181,
            181,
            182,
            183,
            184,
            185,
            185,
            186,
            187,
            188,
            189,
            189,
            190,
            191,
            192,
            192,
            193,
            194,
            195,
            195,
            196,
            197,
            198,
            198,
            199,
            200,
            200,
            201,
            202,
            203,
            203,
            204,
            205,
            206,
            206,
            207,
            208,
            209,
            209,
            210,
            211,
            211,
            212,
            213,
            214,
            214,
            215,
            216,
            216,
            217,
            218,
            219,
            219,
            220,
            221,
            221,
            222,
            223,
            224,
            224,
            225,
            226,
            226,
            227,
            228,
            229,
            229,
            230,
            231,
            232,
            232,
            233,
            234,
            234,
            235,
            236,
            237,
            237,
            238,
            239,
            240,
            240,
            241,
            242,
            243,
            243,
            244,
            245,
            246,
            246,
            247,
            248,
            249,
            249,
            250,
            251,
            252,
            253,
            255
        ];
    atomic_store(*globals_initialization_state_for_control_snr, 2);
}

