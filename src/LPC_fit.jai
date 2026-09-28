// Generated directly from C by cpp_transpiler.
silk_clz16_in_lpc_fit :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_lpc_fit :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_lpc_fit :: () -> s32 {
    return 0;
}

silk_lpc_fit :: (a_qout: *Int16, a_qin: *Int32, QOUT: s32, QIN: s32, D: s32) {
    k: s32 = ---;
    idx: s32 = 0;
    absval: Int32 = ---;
    chirp_q16: Int32 = ---;

    i: s32 = 0;
    while i < 10 {
        maxabs: Int32 = 0;
        k = 0;
        while k < D {
            absval = ifx a_qin[k] > 0 then a_qin[k] else -a_qin[k];
            if absval > maxabs {
                maxabs = absval;
                idx = k;
            }
            k += 1;
        }
        maxabs = ifx QIN - QOUT == 1 then maxabs >> 1 + maxabs & 1 else (maxabs >> (((QIN - QOUT - 1)) & 31) + 1) >> 1;

        if maxabs > 0x7fff {
            maxabs = ifx maxabs < 163838 then maxabs else 163838;
            chirp_q16 =
                (cast,no_check(Int32) (cast(float64) 65470.964)) -
                    (cast,no_check(Int32) ((cast,no_check(Uint32) (maxabs - 0x7fff)) << 14)) / (maxabs * (idx + 1)) >> 2;
            silk_bwexpander_32(a_qin, D, chirp_q16);
        } else {
            break;
        }
        i += 1;
    }

    if i == 10 {
        k = 0;
        while k < D {
            a_qout[k] =
                cast,no_check(Int16) ((ifx (ifx QIN - QOUT == 1 then a_qin[k] >> 1 +
                    a_qin[k] & 1 else (a_qin[k] >> (((QIN - QOUT - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx QIN - QOUT == 1 then a_qin[k] >> 1 + a_qin[k] & 1 else (a_qin[k] >> (((QIN - QOUT - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx QIN - QOUT == 1 then a_qin[k] >> 1 + a_qin[k] & 1 else (a_qin[k] >> (((QIN - QOUT - 1)) & 31) + 1) >> 1))));
            a_qin[k] =
                cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) a_qout[k])) << (((QIN -
                    QOUT)) & 31));
            k += 1;
        }
    } else {
        k = 0;
        while k < D {
            a_qout[k] =
                cast,no_check(Int16) ((ifx QIN - QOUT == 1 then a_qin[k] >> 1 +
                    a_qin[k] & 1 else (a_qin[k] >> (((QIN - QOUT - 1)) & 31) + 1) >> 1));
            k += 1;
        }
    }
}

silk_ror32_in_lpc_fit :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_lpc_fit :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_lpc_fit :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_lpc_fit :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_lpc_fit :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_lpc_fit :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_lpc_fit :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_lpc_fit :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_lpc_fit :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_lpc_fit :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_lpc_fit(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_lpc_fit(in_upper);
    }
}

silk_clz_frac_in_lpc_fit :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_lpc_fit(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_lpc_fit(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_lpc_fit :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_lpc_fit(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_lpc_fit :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_lpc_fit((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_lpc_fit((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_lpc_fit :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_lpc_fit((ifx B32 > 0 then B32 else -B32)) - 1;
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

