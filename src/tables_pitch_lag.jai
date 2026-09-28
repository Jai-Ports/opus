// Generated directly from C by cpp_transpiler.
SILK_PITCH_LAG_I_CDF: [32] Uint8;

SILK_PITCH_DELTA_I_CDF: [21] Uint8;

SILK_PITCH_CONTOUR_I_CDF: [34] Uint8;

SILK_PITCH_CONTOUR_NB_I_CDF: [11] Uint8;

SILK_PITCH_CONTOUR_10_MS_I_CDF: [12] Uint8;

SILK_PITCH_CONTOUR_10_MS_NB_I_CDF: [3] Uint8;

silk_clz16_in_tables_pitch_lag :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_tables_pitch_lag :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_tables_pitch_lag :: () -> s32 {
    return 0;
}

silk_ror32_in_tables_pitch_lag :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_tables_pitch_lag :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_tables_pitch_lag :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_tables_pitch_lag :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_tables_pitch_lag :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_tables_pitch_lag :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_tables_pitch_lag :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_tables_pitch_lag :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_tables_pitch_lag :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_tables_pitch_lag :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_tables_pitch_lag(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_tables_pitch_lag(in_upper);
    }
}

silk_clz_frac_in_tables_pitch_lag :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_tables_pitch_lag(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_tables_pitch_lag(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_tables_pitch_lag :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_tables_pitch_lag(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_tables_pitch_lag :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_tables_pitch_lag((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_tables_pitch_lag((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_tables_pitch_lag :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_tables_pitch_lag((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_tables_pitch_lag :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_tables_pitch_lag :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_tables_pitch_lag :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_tables_pitch_lag :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_tables_pitch_lag :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_tables_pitch_lag :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_tables_pitch_lag: u32;
initialize_globals_for_tables_pitch_lag :: () {
    {
        state := atomic_load(*globals_initialization_state_for_tables_pitch_lag);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_tables_pitch_lag, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_tables_pitch_lag) != 2 {}
            return;
        }
    }
    SILK_PITCH_LAG_I_CDF =
        Uint8.[
            253,
            250,
            244,
            233,
            212,
            182,
            150,
            131,
            120,
            110,
            98,
            85,
            72,
            60,
            49,
            40,
            32,
            25,
            19,
            15,
            13,
            11,
            9,
            8,
            7,
            6,
            5,
            4,
            3,
            2,
            1,
            0
        ];
    SILK_PITCH_DELTA_I_CDF =
        Uint8.[
            210,
            208,
            206,
            203,
            199,
            193,
            183,
            168,
            142,
            104,
            74,
            52,
            37,
            27,
            20,
            14,
            10,
            6,
            4,
            2,
            0
        ];
    SILK_PITCH_CONTOUR_I_CDF =
        Uint8.[
            223,
            201,
            183,
            167,
            152,
            138,
            124,
            111,
            98,
            88,
            79,
            70,
            62,
            56,
            50,
            44,
            39,
            35,
            31,
            27,
            24,
            21,
            18,
            16,
            14,
            12,
            10,
            8,
            6,
            4,
            3,
            2,
            1,
            0
        ];
    SILK_PITCH_CONTOUR_NB_I_CDF =
        Uint8.[
            188,
            176,
            155,
            138,
            119,
            97,
            67,
            43,
            26,
            10,
            0
        ];
    SILK_PITCH_CONTOUR_10_MS_I_CDF =
        Uint8.[
            165,
            119,
            80,
            61,
            47,
            35,
            27,
            20,
            14,
            9,
            4,
            0
        ];
    SILK_PITCH_CONTOUR_10_MS_NB_I_CDF = Uint8.[ 113, 63, 0 ];
    atomic_store(*globals_initialization_state_for_tables_pitch_lag, 2);
}

