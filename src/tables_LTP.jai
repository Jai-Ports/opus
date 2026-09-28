// Generated directly from C by cpp_transpiler.
SILK_LTP_PER_INDEX_I_CDF: [3] Uint8;

SILK_LTP_GAIN_I_CDF_PTRS: [3] *Uint8;

SILK_LTP_GAIN_I_CDF_2: [32] Uint8;

SILK_LTP_GAIN_I_CDF_1: [16] Uint8;

SILK_LTP_GAIN_I_CDF_0: [8] Uint8;

SILK_LTP_GAIN_BITS_Q5_PTRS: [3] *Uint8;

SILK_LTP_GAIN_BITS_Q5_2: [32] Uint8;

SILK_LTP_GAIN_BITS_Q5_1: [16] Uint8;

SILK_LTP_GAIN_BITS_Q5_0: [8] Uint8;

SILK_LTP_VQ_PTRS_Q7: [3] *Int8;

SILK_LTP_GAIN_VQ_2: [32] [5] Int8;

SILK_LTP_GAIN_VQ_1: [16] [5] Int8;

SILK_LTP_GAIN_VQ_0: [8] [5] Int8;

SILK_LTP_VQ_GAIN_PTRS_Q7: [3] *Uint8;

SILK_LTP_GAIN_VQ_2_GAIN: [32] Uint8;

SILK_LTP_GAIN_VQ_1_GAIN: [16] Uint8;

SILK_LTP_GAIN_VQ_0_GAIN: [8] Uint8;

SILK_LTP_VQ_SIZES: [3] Int8;

silk_clz16_in_tables_ltp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_tables_ltp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_tables_ltp :: () -> s32 {
    return 0;
}

silk_ror32_in_tables_ltp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_tables_ltp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_tables_ltp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_tables_ltp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_tables_ltp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_tables_ltp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_tables_ltp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_tables_ltp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_tables_ltp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_tables_ltp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_tables_ltp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_tables_ltp(in_upper);
    }
}

silk_clz_frac_in_tables_ltp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_tables_ltp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_tables_ltp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_tables_ltp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_tables_ltp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_tables_ltp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_tables_ltp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_tables_ltp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_tables_ltp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_tables_ltp((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_tables_ltp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_tables_ltp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_tables_ltp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_tables_ltp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_tables_ltp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_tables_ltp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_tables_ltp: u32;
initialize_globals_for_tables_ltp :: () {
    {
        state := atomic_load(*globals_initialization_state_for_tables_ltp);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_tables_ltp, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_tables_ltp) != 2 {}
            return;
        }
    }
    SILK_LTP_PER_INDEX_I_CDF = Uint8.[ 179, 99, 0 ];
    SILK_LTP_GAIN_I_CDF_0 =
        Uint8.[
            71,
            56,
            43,
            30,
            21,
            12,
            6,
            0
        ];
    SILK_LTP_GAIN_I_CDF_1 =
        Uint8.[
            199,
            165,
            144,
            124,
            109,
            96,
            84,
            71,
            61,
            51,
            42,
            32,
            23,
            15,
            8,
            0
        ];
    SILK_LTP_GAIN_I_CDF_2 =
        Uint8.[
            241,
            225,
            211,
            199,
            187,
            175,
            164,
            153,
            142,
            132,
            123,
            114,
            105,
            96,
            88,
            80,
            72,
            64,
            57,
            50,
            44,
            38,
            33,
            29,
            24,
            20,
            16,
            12,
            9,
            5,
            2,
            0
        ];
    SILK_LTP_GAIN_BITS_Q5_0 =
        Uint8.[
            15,
            131,
            138,
            138,
            155,
            155,
            173,
            173
        ];
    SILK_LTP_GAIN_BITS_Q5_1 =
        Uint8.[
            69,
            93,
            115,
            118,
            131,
            138,
            141,
            138,
            150,
            150,
            155,
            150,
            155,
            160,
            166,
            160
        ];
    SILK_LTP_GAIN_BITS_Q5_2 =
        Uint8.[
            131,
            128,
            134,
            141,
            141,
            141,
            145,
            145,
            145,
            150,
            155,
            155,
            155,
            155,
            160,
            160,
            160,
            160,
            166,
            166,
            173,
            173,
            182,
            192,
            182,
            192,
            192,
            192,
            205,
            192,
            205,
            224
        ];
    SILK_LTP_GAIN_I_CDF_PTRS =
        *Uint8.[ SILK_LTP_GAIN_I_CDF_0.data, SILK_LTP_GAIN_I_CDF_1.data, SILK_LTP_GAIN_I_CDF_2.data ];
    SILK_LTP_GAIN_BITS_Q5_PTRS =
        *Uint8.[ SILK_LTP_GAIN_BITS_Q5_0.data, SILK_LTP_GAIN_BITS_Q5_1.data, SILK_LTP_GAIN_BITS_Q5_2.data ];
    SILK_LTP_GAIN_VQ_0 =
        [5] Int8.[
            Int8.[ 4, 6, 24, 7, 5 ],
            Int8.[ 0, 0, 2, 0, 0 ],
            Int8.[ 12, 28, 41, 13, -4 ],
            Int8.[ -9, 15, 42, 25, 14 ],
            Int8.[ 1, -2, 62, 41, -9 ],
            Int8.[ -10, 37, 65, -4, 3 ],
            Int8.[ -6, 4, 66, 7, -8 ],
            Int8.[ 16, 14, 38, -3, 33 ]
        ];
    SILK_LTP_GAIN_VQ_1 =
        [5] Int8.[
            Int8.[ 13, 22, 39, 23, 12 ],
            Int8.[ -1, 36, 64, 27, -6 ],
            Int8.[ -7, 10, 55, 43, 17 ],
            Int8.[ 1, 1, 8, 1, 1 ],
            Int8.[ 6, -11, 74, 53, -9 ],
            Int8.[ -12, 55, 76, -12, 8 ],
            Int8.[ -3, 3, 93, 27, -4 ],
            Int8.[ 26, 39, 59, 3, -8 ],
            Int8.[ 2, 0, 77, 11, 9 ],
            Int8.[ -8, 22, 44, -6, 7 ],
            Int8.[ 40, 9, 26, 3, 9 ],
            Int8.[ -7, 20, 101, -7, 4 ],
            Int8.[ 3, -8, 42, 26, 0 ],
            Int8.[ -15, 33, 68, 2, 23 ],
            Int8.[ -2, 55, 46, -2, 15 ],
            Int8.[ 3, -1, 21, 16, 41 ]
        ];
    SILK_LTP_GAIN_VQ_2 =
        [5] Int8.[
            Int8.[ -6, 27, 61, 39, 5 ],
            Int8.[ -11, 42, 88, 4, 1 ],
            Int8.[ -2, 60, 65, 6, -4 ],
            Int8.[ -1, -5, 73, 56, 1 ],
            Int8.[ -9, 19, 94, 29, -9 ],
            Int8.[ 0, 12, 99, 6, 4 ],
            Int8.[ 8, -19, 102, 46, -13 ],
            Int8.[ 3, 2, 13, 3, 2 ],
            Int8.[ 9, -21, 84, 72, -18 ],
            Int8.[ -11, 46, 104, -22, 8 ],
            Int8.[ 18, 38, 48, 23, 0 ],
            Int8.[ -16, 70, 83, -21, 11 ],
            Int8.[ 5, -11, 117, 22, -8 ],
            Int8.[ -6, 23, 117, -12, 3 ],
            Int8.[ 3, -8, 95, 28, 4 ],
            Int8.[ -10, 15, 77, 60, -15 ],
            Int8.[ -1, 4, 124, 2, -4 ],
            Int8.[ 3, 38, 84, 24, -25 ],
            Int8.[ 2, 13, 42, 13, 31 ],
            Int8.[ 21, -4, 56, 46, -1 ],
            Int8.[ -1, 35, 79, -13, 19 ],
            Int8.[ -7, 65, 88, -9, -14 ],
            Int8.[ 20, 4, 81, 49, -29 ],
            Int8.[ 20, 0, 75, 3, -17 ],
            Int8.[ 5, -9, 44, 92, -8 ],
            Int8.[ 1, -3, 22, 69, 31 ],
            Int8.[ -6, 95, 41, -12, 5 ],
            Int8.[ 39, 67, 16, -4, 1 ],
            Int8.[ 0, -6, 120, 55, -36 ],
            Int8.[ -13, 44, 122, 4, -24 ],
            Int8.[ 81, 5, 11, 3, 7 ],
            Int8.[ 2, 0, 9, 10, 88 ]
        ];
    SILK_LTP_VQ_PTRS_Q7 =
        *Int8.[ SILK_LTP_GAIN_VQ_0[0].data + 0, SILK_LTP_GAIN_VQ_1[0].data +
            0, SILK_LTP_GAIN_VQ_2[0].data + 0 ];
    SILK_LTP_GAIN_VQ_0_GAIN =
        Uint8.[
            46,
            2,
            90,
            87,
            93,
            91,
            82,
            98
        ];
    SILK_LTP_GAIN_VQ_1_GAIN =
        Uint8.[
            109,
            120,
            118,
            12,
            113,
            115,
            117,
            119,
            99,
            59,
            87,
            111,
            63,
            111,
            112,
            80
        ];
    SILK_LTP_GAIN_VQ_2_GAIN =
        Uint8.[
            126,
            124,
            125,
            124,
            129,
            121,
            126,
            23,
            132,
            127,
            127,
            127,
            126,
            127,
            122,
            133,
            130,
            134,
            101,
            118,
            119,
            145,
            126,
            86,
            124,
            120,
            123,
            119,
            170,
            173,
            107,
            109
        ];
    SILK_LTP_VQ_GAIN_PTRS_Q7 =
        *Uint8.[ SILK_LTP_GAIN_VQ_0_GAIN.data +
            0, SILK_LTP_GAIN_VQ_1_GAIN.data + 0, SILK_LTP_GAIN_VQ_2_GAIN.data + 0 ];
    SILK_LTP_VQ_SIZES = Int8.[ 8, 16, 32 ];
    atomic_store(*globals_initialization_state_for_tables_ltp, 2);
}

