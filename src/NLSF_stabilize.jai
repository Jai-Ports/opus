silk_clz16_in_nlsf_stabilize :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nlsf_stabilize :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nlsf_stabilize :: () -> s32 {
    return 0;
}

silk_nlsf_stabilize :: (nlsf_q15: *Int16, n_delta_min_q15: *Int16, L: s32) {
    i: s32 = ---;
    i_value: s32 = 0;
    k: s32 = ---;
    center_freq_q15: Int16 = ---;
    diff_q15: Int32 = ---;
    min_center_q15: Int32 = ---;
    max_center_q15: Int32 = ---;

    (n_delta_min_q15[L] >= 1);

    loops: s32 = 0;
    while loops < 20 {
        min_diff_q15 := (cast(s32) nlsf_q15[0]) - cast(s32) n_delta_min_q15[0];
        i_value = 0;

        i = 1;
        while i <= L - 1 {
            diff_q15 = (cast(s32) nlsf_q15[i]) - ((cast(s32) nlsf_q15[i - 1]) + cast(s32) n_delta_min_q15[i]);
            if diff_q15 < min_diff_q15 {
                min_diff_q15 = diff_q15;
                i_value = i;
            }
            i += 1;
        }

        diff_q15 = (cast(s32) 1) << 15 - ((cast(s32) nlsf_q15[L - 1]) + cast(s32) n_delta_min_q15[L]);
        if diff_q15 < min_diff_q15 {
            min_diff_q15 = diff_q15;
            i_value = L;
        }

        if min_diff_q15 >= 0 {
            return;
        }

        if i_value == 0 {
            nlsf_q15[0] = n_delta_min_q15[0];
        } else if i_value == L {
            nlsf_q15[L - 1] = cast,no_check(Int16) ((cast(s32) 1) << 15 - cast(s32) n_delta_min_q15[L]);
        } else {
            min_center_q15 = 0;
            k = 0;
            while k < i_value {
                min_center_q15 = cast,no_check(Int32) (min_center_q15 + cast,no_check(s32) n_delta_min_q15[k]);
                k += 1;
            }
            min_center_q15 = cast,no_check(Int32) (min_center_q15 + ((cast(s32) n_delta_min_q15[i_value]) >> 1));

            max_center_q15 = cast,no_check(Int32) (((cast(s32) 1) << 15));
            k = L;
            while k > i_value {
                max_center_q15 = cast,no_check(Int32) (max_center_q15 - cast,no_check(s32) n_delta_min_q15[k]);
                k -= 1;
            }
            max_center_q15 = cast,no_check(Int32) (max_center_q15 - ((cast(s32) n_delta_min_q15[i_value]) >> 1));

            center_freq_q15 =
                cast,no_check(Int16) ((ifx min_center_q15 > max_center_q15 then (ifx (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) + ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1) > min_center_q15 then min_center_q15 else (ifx (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) + ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1) < max_center_q15 then max_center_q15 else (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) + ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1))) else (ifx (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) +
                    ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1) > max_center_q15 then max_center_q15 else (ifx (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) + ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1) < min_center_q15 then min_center_q15 else (ifx 1 == 1 then (((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> 1) + ((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) & 1 else ((((cast,no_check(Int32) nlsf_q15[i_value - 1]) + cast,no_check(Int32) nlsf_q15[i_value]) >> (((1 - 1)) & 31)) + 1) >> 1)))));
            nlsf_q15[i_value - 1] =
                cast,no_check(Int16) ((cast(s32) center_freq_q15) -
                    (cast(s32) n_delta_min_q15[i_value]) >> 1);
            nlsf_q15[i_value] =
                cast,no_check(Int16) ((cast(s32) nlsf_q15[i_value - 1]) +
                    cast(s32) n_delta_min_q15[i_value]);
        }
        loops += 1;
    }

    if loops == 20 {
        silk_insertion_sort_increasing_all_values_int16(*nlsf_q15[0], L);

        nlsf_q15[0] =
            cast,no_check(Int16) silk_max_int_in_nlsf_stabilize(
                cast,no_check(s32) nlsf_q15[0],
                cast,no_check(s32) n_delta_min_q15[0]
            );

        i = 1;
        while i < L {
            nlsf_q15[i] =
                cast,no_check(Int16) silk_max_int_in_nlsf_stabilize(
                    cast,no_check(s32) nlsf_q15[i],
                    cast,no_check(s32) (cast,no_check(Int16) ((ifx ((cast,no_check(Int32) nlsf_q15[i - 1]) +
                    cast(Int32) n_delta_min_q15[i]) > 0x7fff then 0x7fff else (ifx ((cast,no_check(Int32) nlsf_q15[i - 1]) + cast(Int32) n_delta_min_q15[i]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (cast,no_check(Int32) nlsf_q15[i - 1]) + cast(Int32) n_delta_min_q15[i]))))
                );
            i += 1;
        }

        nlsf_q15[L - 1] =
            cast,no_check(Int16) silk_min_int_in_nlsf_stabilize(
                cast,no_check(s32) nlsf_q15[L - 1],
                (cast(s32) 1) << 15 - cast(s32) n_delta_min_q15[L]
            );

        i = L - 2;
        while i >= 0 {
            nlsf_q15[i] =
                cast,no_check(Int16) silk_min_int_in_nlsf_stabilize(
                    cast,no_check(s32) nlsf_q15[i],
                    (cast(s32) nlsf_q15[i + 1]) - cast(s32) n_delta_min_q15[i + 1]
                );
            i -= 1;
        }
    }
}

silk_min_int_in_nlsf_stabilize :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_max_int_in_nlsf_stabilize :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_ror32_in_nlsf_stabilize :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_16_in_nlsf_stabilize :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nlsf_stabilize :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nlsf_stabilize :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_16_in_nlsf_stabilize :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nlsf_stabilize :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nlsf_stabilize :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nlsf_stabilize :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nlsf_stabilize(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nlsf_stabilize(in_upper);
    }
}

silk_clz_frac_in_nlsf_stabilize :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nlsf_stabilize(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nlsf_stabilize(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nlsf_stabilize :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nlsf_stabilize(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nlsf_stabilize :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nlsf_stabilize((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nlsf_stabilize((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nlsf_stabilize :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nlsf_stabilize((ifx B32 > 0 then B32 else -B32)) - 1;
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

