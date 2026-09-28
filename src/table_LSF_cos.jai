SILK_LSF_COS_TAB_FIX_Q12: [129] Int16;

silk_clz16_in_table_lsf_cos :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_table_lsf_cos :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_table_lsf_cos :: () -> s32 {
    return 0;
}

silk_ror32_in_table_lsf_cos :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_table_lsf_cos :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_table_lsf_cos :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_table_lsf_cos :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_table_lsf_cos :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_table_lsf_cos :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_table_lsf_cos :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_table_lsf_cos :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_table_lsf_cos :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_table_lsf_cos :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_table_lsf_cos(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_table_lsf_cos(in_upper);
    }
}

silk_clz_frac_in_table_lsf_cos :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_table_lsf_cos(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_table_lsf_cos(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_table_lsf_cos :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_table_lsf_cos(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_table_lsf_cos :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_table_lsf_cos((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_table_lsf_cos((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_table_lsf_cos :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_table_lsf_cos((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_table_lsf_cos :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_table_lsf_cos :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_table_lsf_cos :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_table_lsf_cos :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_table_lsf_cos :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_table_lsf_cos :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_table_lsf_cos: u32;
initialize_globals_for_table_lsf_cos :: () {
    {
        state := atomic_load(*globals_initialization_state_for_table_lsf_cos);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_table_lsf_cos, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_table_lsf_cos) != 2 {}
            return;
        }
    }
    SILK_LSF_COS_TAB_FIX_Q12 =
        Int16.[
            8192,
            8190,
            8182,
            8170,
            8152,
            8130,
            8104,
            8072,
            8034,
            7994,
            7946,
            7896,
            7840,
            7778,
            7714,
            7644,
            7568,
            7490,
            7406,
            7318,
            7226,
            7128,
            7026,
            6922,
            6812,
            6698,
            6580,
            6458,
            6332,
            6204,
            6070,
            5934,
            5792,
            5648,
            5502,
            5352,
            5198,
            5040,
            4880,
            4718,
            4552,
            4382,
            4212,
            4038,
            3862,
            3684,
            3502,
            3320,
            3136,
            2948,
            2760,
            2570,
            2378,
            2186,
            1990,
            1794,
            1598,
            1400,
            1202,
            1002,
            802,
            602,
            402,
            202,
            0,
            -202,
            -402,
            -602,
            -802,
            -1002,
            -1202,
            -1400,
            -1598,
            -1794,
            -1990,
            -2186,
            -2378,
            -2570,
            -2760,
            -2948,
            -3136,
            -3320,
            -3502,
            -3684,
            -3862,
            -4038,
            -4212,
            -4382,
            -4552,
            -4718,
            -4880,
            -5040,
            -5198,
            -5352,
            -5502,
            -5648,
            -5792,
            -5934,
            -6070,
            -6204,
            -6332,
            -6458,
            -6580,
            -6698,
            -6812,
            -6922,
            -7026,
            -7128,
            -7226,
            -7318,
            -7406,
            -7490,
            -7568,
            -7644,
            -7714,
            -7778,
            -7840,
            -7896,
            -7946,
            -7994,
            -8034,
            -8072,
            -8104,
            -8130,
            -8152,
            -8170,
            -8182,
            -8190,
            -8192
        ];
    atomic_store(*globals_initialization_state_for_table_lsf_cos, 2);
}

