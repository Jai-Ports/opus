// Generated directly from C by cpp_transpiler.
SILK_PULSES_PER_BLOCK_I_CDF: [10] [18] Uint8;

SILK_PULSES_PER_BLOCK_BITS_Q5: [9] [18] Uint8;

SILK_RATE_LEVELS_I_CDF: [2] [9] Uint8;

SILK_RATE_LEVELS_BITS_Q5: [2] [9] Uint8;

SILK_MAX_PULSES_TABLE: [4] Uint8;

SILK_SHELL_CODE_TABLE0: [152] Uint8;

SILK_SHELL_CODE_TABLE1: [152] Uint8;

SILK_SHELL_CODE_TABLE2: [152] Uint8;

SILK_SHELL_CODE_TABLE3: [152] Uint8;

SILK_SHELL_CODE_TABLE_OFFSETS: [17] Uint8;

SILK_SIGN_I_CDF: [42] Uint8;

silk_clz16_in_tables_pulses_per_block :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_tables_pulses_per_block :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_tables_pulses_per_block :: () -> s32 {
    return 0;
}

silk_ror32_in_tables_pulses_per_block :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_tables_pulses_per_block :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_tables_pulses_per_block :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_tables_pulses_per_block :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_tables_pulses_per_block :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_tables_pulses_per_block :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_tables_pulses_per_block :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_tables_pulses_per_block :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_tables_pulses_per_block :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_tables_pulses_per_block :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_tables_pulses_per_block(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_tables_pulses_per_block(in_upper);
    }
}

silk_clz_frac_in_tables_pulses_per_block :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_tables_pulses_per_block(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_tables_pulses_per_block(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_tables_pulses_per_block :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_tables_pulses_per_block(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_tables_pulses_per_block :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_tables_pulses_per_block((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_tables_pulses_per_block((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_tables_pulses_per_block :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_tables_pulses_per_block((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_tables_pulses_per_block :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_tables_pulses_per_block :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_tables_pulses_per_block :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_tables_pulses_per_block :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_tables_pulses_per_block :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_tables_pulses_per_block :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_tables_pulses_per_block: u32;
initialize_globals_for_tables_pulses_per_block :: () {
    {
        state := atomic_load(*globals_initialization_state_for_tables_pulses_per_block);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_tables_pulses_per_block, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_tables_pulses_per_block) != 2 {}
            return;
        }
    }
    SILK_MAX_PULSES_TABLE = Uint8.[ 8, 10, 12, 16 ];
    SILK_PULSES_PER_BLOCK_I_CDF =
        [18] Uint8.[
            Uint8.[ 125, 51, 26, 18, 15, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ],
            Uint8.[ 198, 105, 45, 22, 15, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ],
            Uint8.[ 213, 162, 116, 83, 59, 43, 32, 24, 18, 15, 12, 9, 7, 6, 5, 3, 2, 0 ],
            Uint8.[ 239, 187, 116, 59, 28, 16, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 ],
            Uint8.[ 250, 229, 188, 135, 86, 51, 30, 19, 13, 10, 8, 6, 5, 4, 3, 2, 1, 0 ],
            Uint8.[ 249, 235, 213, 185, 156, 128, 103, 83, 66, 53, 42, 33, 26, 21, 17, 13, 10, 0 ],
            Uint8.[ 254, 249, 235, 206, 164, 118, 77, 46, 27, 16, 10, 7, 5, 4, 3, 2, 1, 0 ],
            Uint8.[ 255, 253, 249, 239, 220, 191, 156, 119, 85, 57, 37, 23, 15, 10, 6, 4, 2, 0 ],
            Uint8.[ 255, 253, 251, 246, 237, 223, 203, 179, 152, 124, 98, 75, 55, 40, 29, 21, 15, 0 ],
            Uint8.[ 255, 254, 253, 247, 220, 162, 106, 67, 42, 28, 18, 12, 9, 6, 4, 3, 2, 0 ]
        ];
    SILK_PULSES_PER_BLOCK_BITS_Q5 =
        [18] Uint8.[
            Uint8.[ 31, 57, 107, 160, 205, 205, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ],
            Uint8.[ 69, 47, 67, 111, 166, 205, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ],
            Uint8.[ 82, 74, 79, 95, 109, 128, 145, 160, 173, 205, 205, 205, 224, 255, 255, 224, 255, 224 ],
            Uint8.[ 125, 74, 59, 69, 97, 141, 182, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ],
            Uint8.[ 173, 115, 85, 73, 76, 92, 115, 145, 173, 205, 224, 224, 255, 255, 255, 255, 255, 255 ],
            Uint8.[ 166, 134, 113, 102, 101, 102, 107, 118, 125, 138, 145, 155, 166, 182, 192, 192, 205, 150 ],
            Uint8.[ 224, 182, 134, 101, 83, 79, 85, 97, 120, 145, 173, 205, 224, 255, 255, 255, 255, 255 ],
            Uint8.[ 255, 224, 192, 150, 120, 101, 92, 89, 93, 102, 118, 134, 160, 182, 192, 224, 224, 224 ],
            Uint8.[ 255, 224, 224, 182, 155, 134, 118, 109, 104, 102, 106, 111, 118, 131, 145, 160, 173, 131 ]
        ];
    SILK_RATE_LEVELS_I_CDF =
        [9] Uint8.[
            Uint8.[ 241, 190, 178, 132, 87, 74, 41, 14, 0 ],
            Uint8.[ 223, 193, 157, 140, 106, 57, 39, 18, 0 ]
        ];
    SILK_RATE_LEVELS_BITS_Q5 =
        [9] Uint8.[
            Uint8.[ 131, 74, 141, 79, 80, 138, 95, 104, 134 ],
            Uint8.[ 95, 99, 91, 125, 93, 76, 123, 115, 123 ]
        ];
    SILK_SHELL_CODE_TABLE0 =
        Uint8.[
            128,
            0,
            214,
            42,
            0,
            235,
            128,
            21,
            0,
            244,
            184,
            72,
            11,
            0,
            248,
            214,
            128,
            42,
            7,
            0,
            248,
            225,
            170,
            80,
            25,
            5,
            0,
            251,
            236,
            198,
            126,
            54,
            18,
            3,
            0,
            250,
            238,
            211,
            159,
            82,
            35,
            15,
            5,
            0,
            250,
            231,
            203,
            168,
            128,
            88,
            53,
            25,
            6,
            0,
            252,
            238,
            216,
            185,
            148,
            108,
            71,
            40,
            18,
            4,
            0,
            253,
            243,
            225,
            199,
            166,
            128,
            90,
            57,
            31,
            13,
            3,
            0,
            254,
            246,
            233,
            212,
            183,
            147,
            109,
            73,
            44,
            23,
            10,
            2,
            0,
            255,
            250,
            240,
            223,
            198,
            166,
            128,
            90,
            58,
            33,
            16,
            6,
            1,
            0,
            255,
            251,
            244,
            231,
            210,
            181,
            146,
            110,
            75,
            46,
            25,
            12,
            5,
            1,
            0,
            255,
            253,
            248,
            238,
            221,
            196,
            164,
            128,
            92,
            60,
            35,
            18,
            8,
            3,
            1,
            0,
            255,
            253,
            249,
            242,
            229,
            208,
            180,
            146,
            110,
            76,
            48,
            27,
            14,
            7,
            3,
            1,
            0
        ];
    SILK_SHELL_CODE_TABLE1 =
        Uint8.[
            129,
            0,
            207,
            50,
            0,
            236,
            129,
            20,
            0,
            245,
            185,
            72,
            10,
            0,
            249,
            213,
            129,
            42,
            6,
            0,
            250,
            226,
            169,
            87,
            27,
            4,
            0,
            251,
            233,
            194,
            130,
            62,
            20,
            4,
            0,
            250,
            236,
            207,
            160,
            99,
            47,
            17,
            3,
            0,
            255,
            240,
            217,
            182,
            131,
            81,
            41,
            11,
            1,
            0,
            255,
            254,
            233,
            201,
            159,
            107,
            61,
            20,
            2,
            1,
            0,
            255,
            249,
            233,
            206,
            170,
            128,
            86,
            50,
            23,
            7,
            1,
            0,
            255,
            250,
            238,
            217,
            186,
            148,
            108,
            70,
            39,
            18,
            6,
            1,
            0,
            255,
            252,
            243,
            226,
            200,
            166,
            128,
            90,
            56,
            30,
            13,
            4,
            1,
            0,
            255,
            252,
            245,
            231,
            209,
            180,
            146,
            110,
            76,
            47,
            25,
            11,
            4,
            1,
            0,
            255,
            253,
            248,
            237,
            219,
            194,
            163,
            128,
            93,
            62,
            37,
            19,
            8,
            3,
            1,
            0,
            255,
            254,
            250,
            241,
            226,
            205,
            177,
            145,
            111,
            79,
            51,
            30,
            15,
            6,
            2,
            1,
            0
        ];
    SILK_SHELL_CODE_TABLE2 =
        Uint8.[
            129,
            0,
            203,
            54,
            0,
            234,
            129,
            23,
            0,
            245,
            184,
            73,
            10,
            0,
            250,
            215,
            129,
            41,
            5,
            0,
            252,
            232,
            173,
            86,
            24,
            3,
            0,
            253,
            240,
            200,
            129,
            56,
            15,
            2,
            0,
            253,
            244,
            217,
            164,
            94,
            38,
            10,
            1,
            0,
            253,
            245,
            226,
            189,
            132,
            71,
            27,
            7,
            1,
            0,
            253,
            246,
            231,
            203,
            159,
            105,
            56,
            23,
            6,
            1,
            0,
            255,
            248,
            235,
            213,
            179,
            133,
            85,
            47,
            19,
            5,
            1,
            0,
            255,
            254,
            243,
            221,
            194,
            159,
            117,
            70,
            37,
            12,
            2,
            1,
            0,
            255,
            254,
            248,
            234,
            208,
            171,
            128,
            85,
            48,
            22,
            8,
            2,
            1,
            0,
            255,
            254,
            250,
            240,
            220,
            189,
            149,
            107,
            67,
            36,
            16,
            6,
            2,
            1,
            0,
            255,
            254,
            251,
            243,
            227,
            201,
            166,
            128,
            90,
            55,
            29,
            13,
            5,
            2,
            1,
            0,
            255,
            254,
            252,
            246,
            234,
            213,
            183,
            147,
            109,
            73,
            43,
            22,
            10,
            4,
            2,
            1,
            0
        ];
    SILK_SHELL_CODE_TABLE3 =
        Uint8.[
            130,
            0,
            200,
            58,
            0,
            231,
            130,
            26,
            0,
            244,
            184,
            76,
            12,
            0,
            249,
            214,
            130,
            43,
            6,
            0,
            252,
            232,
            173,
            87,
            24,
            3,
            0,
            253,
            241,
            203,
            131,
            56,
            14,
            2,
            0,
            254,
            246,
            221,
            167,
            94,
            35,
            8,
            1,
            0,
            254,
            249,
            232,
            193,
            130,
            65,
            23,
            5,
            1,
            0,
            255,
            251,
            239,
            211,
            162,
            99,
            45,
            15,
            4,
            1,
            0,
            255,
            251,
            243,
            223,
            186,
            131,
            74,
            33,
            11,
            3,
            1,
            0,
            255,
            252,
            245,
            230,
            202,
            158,
            105,
            57,
            24,
            8,
            2,
            1,
            0,
            255,
            253,
            247,
            235,
            214,
            179,
            132,
            84,
            44,
            19,
            7,
            2,
            1,
            0,
            255,
            254,
            250,
            240,
            223,
            196,
            159,
            112,
            69,
            36,
            15,
            6,
            2,
            1,
            0,
            255,
            254,
            253,
            245,
            231,
            209,
            176,
            136,
            93,
            55,
            27,
            11,
            3,
            2,
            1,
            0,
            255,
            254,
            253,
            252,
            239,
            221,
            194,
            158,
            117,
            76,
            42,
            18,
            4,
            3,
            2,
            1,
            0
        ];
    SILK_SHELL_CODE_TABLE_OFFSETS =
        Uint8.[
            0,
            0,
            2,
            5,
            9,
            14,
            20,
            27,
            35,
            44,
            54,
            65,
            77,
            90,
            104,
            119,
            135
        ];
    SILK_SIGN_I_CDF =
        Uint8.[
            254,
            49,
            67,
            77,
            82,
            93,
            99,
            198,
            11,
            18,
            24,
            31,
            36,
            45,
            255,
            46,
            66,
            78,
            87,
            94,
            104,
            208,
            14,
            21,
            32,
            42,
            51,
            66,
            255,
            94,
            104,
            109,
            112,
            115,
            118,
            248,
            53,
            69,
            80,
            88,
            95,
            102
        ];
    atomic_store(*globals_initialization_state_for_tables_pulses_per_block, 2);
}

