SILK_RESAMPLER_DOWN2_0_in_resampler_rom: Int16;

SILK_RESAMPLER_DOWN2_1_in_resampler_rom: Int16;

SILK_RESAMPLER_UP2_HQ_0_in_resampler_rom: [3] Int16;

SILK_RESAMPLER_UP2_HQ_1_in_resampler_rom: [3] Int16;

SILK_RESAMPLER_3_4_COEFS: [29] Int16;

SILK_RESAMPLER_2_3_COEFS: [20] Int16;

SILK_RESAMPLER_1_2_COEFS: [14] Int16;

SILK_RESAMPLER_1_3_COEFS: [20] Int16;

SILK_RESAMPLER_1_4_COEFS: [20] Int16;

SILK_RESAMPLER_1_6_COEFS: [20] Int16;

SILK_RESAMPLER_2_3_COEFS_LQ: [6] Int16;

SILK_RESAMPLER_FRAC_FIR_12: [12] [4] Int16;

silk_clz16_in_resampler_rom :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_resampler_rom :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_resampler_rom :: () -> s32 {
    return 0;
}

silk_ror32_in_resampler_rom :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_resampler_rom :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_resampler_rom :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_resampler_rom :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_resampler_rom :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_resampler_rom :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_resampler_rom :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_resampler_rom :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_resampler_rom :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_resampler_rom :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_resampler_rom(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_resampler_rom(in_upper);
    }
}

silk_clz_frac_in_resampler_rom :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_resampler_rom(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_resampler_rom(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_resampler_rom :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_resampler_rom(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_resampler_rom :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_resampler_rom((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_resampler_rom((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_resampler_rom :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_resampler_rom((ifx B32 > 0 then B32 else -B32)) - 1;
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

globals_initialization_state_for_resampler_rom: u32;
initialize_globals_for_resampler_rom :: () {
    {
        state := atomic_load(*globals_initialization_state_for_resampler_rom);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_resampler_rom, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_resampler_rom) != 2 {}
            return;
        }
    }
    SILK_RESAMPLER_DOWN2_0_in_resampler_rom = 9872;
    SILK_RESAMPLER_DOWN2_1_in_resampler_rom = cast,no_check(Int16) (39809 - 65536);
    SILK_RESAMPLER_UP2_HQ_0_in_resampler_rom = Int16.[ 1746, 14986, cast,no_check(Int16) (39083 - 65536) ];
    SILK_RESAMPLER_UP2_HQ_1_in_resampler_rom = Int16.[ 6854, 25769, cast,no_check(Int16) (55542 - 65536) ];
    SILK_RESAMPLER_3_4_COEFS =
        Int16.[
            -20694,
            -13867,
            -49,
            64,
            17,
            -157,
            353,
            -496,
            163,
            11047,
            22205,
            -39,
            6,
            91,
            -170,
            186,
            23,
            -896,
            6336,
            19928,
            -19,
            -36,
            102,
            -89,
            -24,
            328,
            -951,
            2568,
            15909
        ];
    SILK_RESAMPLER_2_3_COEFS =
        Int16.[
            -14457,
            -14019,
            64,
            128,
            -122,
            36,
            310,
            -768,
            584,
            9267,
            17733,
            12,
            128,
            18,
            -142,
            288,
            -117,
            -865,
            4123,
            14459
        ];
    SILK_RESAMPLER_1_2_COEFS =
        Int16.[
            616,
            -14323,
            -10,
            39,
            58,
            -46,
            -84,
            120,
            184,
            -315,
            -541,
            1284,
            5380,
            9024
        ];
    SILK_RESAMPLER_1_3_COEFS =
        Int16.[
            16102,
            -15162,
            -13,
            0,
            20,
            26,
            5,
            -31,
            -43,
            -4,
            65,
            90,
            7,
            -157,
            -248,
            -44,
            593,
            1583,
            2612,
            3271
        ];
    SILK_RESAMPLER_1_4_COEFS =
        Int16.[
            22500,
            -15099,
            3,
            -14,
            -20,
            -15,
            2,
            25,
            37,
            25,
            -16,
            -71,
            -107,
            -79,
            50,
            292,
            623,
            982,
            1288,
            1464
        ];
    SILK_RESAMPLER_1_6_COEFS =
        Int16.[
            27540,
            -15257,
            17,
            12,
            8,
            1,
            -10,
            -22,
            -30,
            -32,
            -22,
            3,
            44,
            100,
            168,
            243,
            317,
            381,
            429,
            455
        ];
    SILK_RESAMPLER_2_3_COEFS_LQ =
        Int16.[
            -2797,
            -6507,
            4697,
            10739,
            1567,
            8276
        ];
    SILK_RESAMPLER_FRAC_FIR_12 =
        [4] Int16.[
            Int16.[ 189, -600, 617, 30567 ],
            Int16.[ 117, -159, -1070, 29704 ],
            Int16.[ 52, 221, -2392, 28276 ],
            Int16.[ -4, 529, -3350, 26341 ],
            Int16.[ -48, 758, -3956, 23973 ],
            Int16.[ -80, 905, -4235, 21254 ],
            Int16.[ -99, 972, -4222, 18278 ],
            Int16.[ -107, 967, -3957, 15143 ],
            Int16.[ -103, 896, -3487, 11950 ],
            Int16.[ -91, 773, -2865, 8798 ],
            Int16.[ -71, 611, -2143, 5784 ],
            Int16.[ -46, 425, -1375, 2996 ]
        ];
    atomic_store(*globals_initialization_state_for_resampler_rom, 2);
}

