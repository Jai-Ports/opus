A_FB1_20: Int16;

A_FB1_21: Int16;

silk_clz16_in_ana_filt_bank_1 :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_ana_filt_bank_1 :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_ana_filt_bank_1 :: () -> s32 {
    return 0;
}

silk_ana_filt_bank_1 :: (in: *Int16, s: *Int32, out_l: *Int16, out_h: *Int16, N: Int32) {
    n2: s32 = N >> 1;

    if 0 < n2 {
        for k: 0..n2 - 1 {
            in32 := cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) in[2 * k])) << 10);

            y := in32 - s[0];
            x := cast,no_check(Int32) ((cast(Int64) y) + ((cast(Int64) y) * cast,no_check(Int64) A_FB1_21) >> 16);
            out_1 := s[0] + x;
            s[0] = in32 + x;

            in32 = cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) in[2 * k + 1])) << 10);

            y = in32 - s[1];
            x = cast,no_check(Int32) (((cast(Int64) y) * cast,no_check(Int64) A_FB1_20) >> 16);
            out_2 := s[1] + x;
            s[1] = in32 + x;

            out_l[k] =
                cast,no_check(Int16) ((ifx (ifx 11 == 1 then (out_2 + out_1) >> 1 +
                    (out_2 + out_1) & 1 else ((out_2 + out_1) >> (((11 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 11 == 1 then (out_2 + out_1) >> 1 + (out_2 + out_1) & 1 else ((out_2 + out_1) >> (((11 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 11 == 1 then (out_2 + out_1) >> 1 + (out_2 + out_1) & 1 else ((out_2 + out_1) >> (((11 - 1)) & 31) + 1) >> 1))));
            out_h[k] =
                cast,no_check(Int16) ((ifx (ifx 11 == 1 then (out_2 - out_1) >> 1 +
                    (out_2 - out_1) & 1 else ((out_2 - out_1) >> (((11 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 11 == 1 then (out_2 - out_1) >> 1 + (out_2 - out_1) & 1 else ((out_2 - out_1) >> (((11 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 11 == 1 then (out_2 - out_1) >> 1 + (out_2 - out_1) & 1 else ((out_2 - out_1) >> (((11 - 1)) & 31) + 1) >> 1))));
        }
    }
}

silk_ror32_in_ana_filt_bank_1 :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_ana_filt_bank_1 :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_ana_filt_bank_1 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_ana_filt_bank_1 :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_ana_filt_bank_1 :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_ana_filt_bank_1 :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_ana_filt_bank_1 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_ana_filt_bank_1 :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_ana_filt_bank_1 :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_ana_filt_bank_1 :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_ana_filt_bank_1(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_ana_filt_bank_1(in_upper);
    }
}

silk_clz_frac_in_ana_filt_bank_1 :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_ana_filt_bank_1(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_ana_filt_bank_1(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_ana_filt_bank_1 :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_ana_filt_bank_1(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_ana_filt_bank_1 :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_ana_filt_bank_1((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_ana_filt_bank_1((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_ana_filt_bank_1 :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_ana_filt_bank_1((ifx B32 > 0 then B32 else -B32)) - 1;
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

globals_initialization_state_for_ana_filt_bank_1: u32;
initialize_globals_for_ana_filt_bank_1 :: () {
    {
        state := atomic_load(*globals_initialization_state_for_ana_filt_bank_1);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_ana_filt_bank_1, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_ana_filt_bank_1) != 2 {}
            return;
        }
    }
    A_FB1_20 = cast,no_check(Int16) ((cast(s32) 5394) << 1);
    A_FB1_21 = -24290;
    atomic_store(*globals_initialization_state_for_ana_filt_bank_1, 2);
}

