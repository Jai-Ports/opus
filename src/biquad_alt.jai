silk_clz16_in_biquad_alt :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_biquad_alt :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_biquad_alt :: () -> s32 {
    return 0;
}

silk_biquad_alt_stride1 :: (in: *Int16, b_q28: *Int32, a_q28: *Int32, s: *Int32, out: *Int16, LEN: Int32) {
    a0_l_q28: Int32 = ---;

    a0_l_q28 = -a_q28[0] & 0x3fff;
    a0_u_q28 := -a_q28[0] >> 14;
    a1_l_q28 := -a_q28[1] & 0x3fff;
    a1_u_q28 := -a_q28[1] >> 14;

    k: s32 = 0;
    while k < LEN {
        inval := cast,no_check(Int32) in[k];
        out32_q14 :=
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) b_q28[0]) * cast,no_check(Int64) (cast,no_check(Int16) inval)) >> 16))) << 2);

        s[0] =
            s[1] +
                (ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> 1) + (cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1);
        s[0] =
            cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a0_u_q28)) >> 16);
        s[0] =
            cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) b_q28[1]) * cast,no_check(Int64) (cast,no_check(Int16) inval)) >> 16);

        s[1] =
            ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> 1) +
                (cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1;
        s[1] =
            cast,no_check(Int32) ((cast(Int64) s[1]) +
                ((cast(Int64) out32_q14) * cast,no_check(Int64) (cast,no_check(Int16) a1_u_q28)) >> 16);
        s[1] =
            cast,no_check(Int32) ((cast(Int64) s[1]) +
                ((cast(Int64) b_q28[2]) * cast,no_check(Int64) (cast,no_check(Int16) inval)) >> 16);

        out[k] =
            cast,no_check(Int16) ((ifx (((out32_q14 + cast,no_check(Int32) (((cast(s32) 1) << 14))) -
                1) >> 14) > 0x7fff then 0x7fff else (ifx (((out32_q14 + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else ((out32_q14 + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14)));
        k += 1;
    }
}

silk_biquad_alt_stride2_c :: (in: *Int16, b_q28: *Int32, a_q28: *Int32, s: *Int32, out: *Int16, LEN: Int32) {
    a0_l_q28: Int32 = ---;
    out32_q14: [2] Int32 = ---;

    a0_l_q28 = -a_q28[0] & 0x3fff;
    a0_u_q28 := -a_q28[0] >> 14;
    a1_l_q28 := -a_q28[1] & 0x3fff;
    a1_u_q28 := -a_q28[1] >> 14;

    k: s32 = 0;
    while k < LEN {
        out32_q14[0] =
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) b_q28[0]) * cast,no_check(Int64) in[2 * k + 0]) >> 16))) << 2);
        out32_q14[1] =
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) ((cast(Int64) s[2]) +
                ((cast(Int64) b_q28[0]) * cast,no_check(Int64) in[2 * k + 1]) >> 16))) << 2);

        s[0] =
            s[1] +
                (ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> 1) + (cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1);
        s[2] =
            s[3] +
                (ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> 1) + (cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a0_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1);
        s[0] =
            cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a0_u_q28)) >> 16);
        s[2] =
            cast,no_check(Int32) ((cast(Int64) s[2]) +
                ((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a0_u_q28)) >> 16);
        s[0] =
            cast,no_check(Int32) ((cast(Int64) s[0]) +
                ((cast(Int64) b_q28[1]) * cast,no_check(Int64) in[2 * k + 0]) >> 16);
        s[2] =
            cast,no_check(Int32) ((cast(Int64) s[2]) +
                ((cast(Int64) b_q28[1]) * cast,no_check(Int64) in[2 * k + 1]) >> 16);

        s[1] =
            ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> 1) +
                (cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1;
        s[3] =
            ifx 14 == 1 then ((cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> 1) +
                (cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) & 1 else (((cast,no_check(Int32) (((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a1_l_q28)) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1;
        s[1] =
            cast,no_check(Int32) ((cast(Int64) s[1]) +
                ((cast(Int64) out32_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) a1_u_q28)) >> 16);
        s[3] =
            cast,no_check(Int32) ((cast(Int64) s[3]) +
                ((cast(Int64) out32_q14[1]) * cast,no_check(Int64) (cast,no_check(Int16) a1_u_q28)) >> 16);
        s[1] =
            cast,no_check(Int32) ((cast(Int64) s[1]) +
                ((cast(Int64) b_q28[2]) * cast,no_check(Int64) in[2 * k + 0]) >> 16);
        s[3] =
            cast,no_check(Int32) ((cast(Int64) s[3]) +
                ((cast(Int64) b_q28[2]) * cast,no_check(Int64) in[2 * k + 1]) >> 16);

        out[2 * k + 0] =
            cast,no_check(Int16) ((ifx (((out32_q14[0] + cast,no_check(Int32) (((cast(s32) 1) << 14))) -
                1) >> 14) > 0x7fff then 0x7fff else (ifx (((out32_q14[0] + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else ((out32_q14[0] + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14)));
        out[2 * k + 1] =
            cast,no_check(Int16) ((ifx (((out32_q14[1] + cast,no_check(Int32) (((cast(s32) 1) << 14))) -
                1) >> 14) > 0x7fff then 0x7fff else (ifx (((out32_q14[1] + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else ((out32_q14[1] + cast,no_check(Int32) (((cast(s32) 1) << 14))) - 1) >> 14)));
        k += 1;
    }
}

silk_ror32_in_biquad_alt :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_biquad_alt :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_biquad_alt :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_biquad_alt :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_biquad_alt :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_biquad_alt :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_biquad_alt :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_biquad_alt :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_biquad_alt :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_biquad_alt :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_biquad_alt(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_biquad_alt(in_upper);
    }
}

silk_clz_frac_in_biquad_alt :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_biquad_alt(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_biquad_alt(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_biquad_alt :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_biquad_alt(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_biquad_alt :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_biquad_alt((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_biquad_alt((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_biquad_alt :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_biquad_alt((ifx B32 > 0 then B32 else -B32)) - 1;
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

