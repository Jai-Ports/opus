// Generated directly from C by cpp_transpiler.
silk_clz16_in_lpc_inv_pred_gain :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_lpc_inv_pred_gain :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_lpc_inv_pred_gain :: () -> s32 {
    return 0;
}

silk_lpc_inverse_pred_gain_c :: (a_q12: *Int16, ORDER: s32) -> Int32 {
    atmp_qa: [24] Int32 = ---;
    dc_resp: Int32 = 0;

    if 0 < ORDER {
        for k: 0..ORDER - 1 {
            dc_resp += cast,no_check(Int32) a_q12[k];
            atmp_qa[k] =
                cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) a_q12[k])) << (((24 -
                    12)) & 31));
        }
    }

    if dc_resp >= 4096 {
        return 0;
    }
    return lpc_inverse_pred_gain_qa_c(atmp_qa.data, ORDER);
}

lpc_inverse_pred_gain_qa_c :: (a_qa: *Int32, ORDER: s32) -> Int32 {
    n: s32 = ---;
    inv_gain_q30: Int32 = ---;
    rc_q31: Int32 = ---;
    rc_mult1_q30: Int32 = ---;
    tmp1: Int32 = ---;
    tmp2: Int32 = ---;

    inv_gain_q30 = cast,no_check(Int32) (cast(float64) 1073741824.5);
    k := ORDER - 1;
    while k > 0 {
        if a_qa[k] > cast,no_check(Int32) (cast(float64) 16773022.196) ||
            a_qa[k] < -(cast,no_check(Int32) (cast(float64) 16773022.196)) {
            return 0;
        }

        rc_q31 = -(cast,no_check(Int32) ((cast,no_check(Uint32) a_qa[k]) << (((31 - 24)) & 31)));

        rc_mult1_q30 =
            (cast,no_check(Int32) (cast(float64) 1073741824.5)) -
                cast,no_check(Int32) (((cast,no_check(Int64) rc_q31) * cast(Int64) rc_q31) >> 32);
        (rc_mult1_q30 > (cast(s32) 1) << 15);
        (rc_mult1_q30 <= (cast(s32) 1) << 30);

        inv_gain_q30 =
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast,no_check(Int64) inv_gain_q30) *
                cast(Int64) rc_mult1_q30) >> 32))) << 2);

        (inv_gain_q30 <= (cast(s32) 1) << 30);
        if inv_gain_q30 < cast,no_check(Int32) (cast(float64) 107374.6796875) {
            return 0;
        }

        mult2_q := 32 - silk_clz32_in_lpc_inv_pred_gain((ifx rc_mult1_q30 > 0 then rc_mult1_q30 else -rc_mult1_q30));
        rc_mult2 := silk_inverse32_var_q_in_lpc_inv_pred_gain(rc_mult1_q30, mult2_q + 30);

        n = 0;
        while n < (k + 1) >> 1 {
            tmp1 = a_qa[n];
            tmp2 = a_qa[k - n - 1];
            tmp64 :=
                (ifx mult2_q == 1 then (((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp1) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp1) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp1) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) >> 1) +
                    ((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp1) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp1) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp1) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) & 1 else ((((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp1) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp1) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp1) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp1 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp2) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) >> (((mult2_q - 1)) & 63)) + 1) >> 1);
            if tmp64 > 0x7fffffff || tmp64 < cast,no_check(Int64) (cast(Int32) -2147483648) {
                return 0;
            }
            a_qa[n] = cast,no_check(Int32) tmp64;
            tmp64 =
                ifx mult2_q == 1 then (((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp2) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp2) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp2) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) >> 1) +
                    ((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp2) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp2) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp2) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) & 1 else ((((cast,no_check(Int64) ((ifx (((cast,no_check(Uint32) tmp2) - cast,no_check(Uint32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) tmp2) & ((cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) ^ 0x80000000)) & 0x80000000 != 0 then -2147483648 else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1))) else (ifx ((cast,no_check(u32) tmp2) ^ 0x80000000 & cast,no_check(u32) (cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))) & 0x80000000 != 0 then 0x7fffffff else tmp2 - cast,no_check(Int32) ((ifx 31 == 1 then (((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> 1) + ((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) & 1 else ((((cast,no_check(Int64) tmp1) * cast(Int64) rc_q31) >> (((31 - 1)) & 63)) + 1) >> 1)))))) * cast(Int64) rc_mult2) >> (((mult2_q - 1)) & 63)) + 1) >> 1;
            if tmp64 > 0x7fffffff || tmp64 < cast,no_check(Int64) (cast(Int32) -2147483648) {
                return 0;
            }
            a_qa[k - n - 1] = cast,no_check(Int32) tmp64;
            n += 1;
        }
        k -= 1;
    }

    if a_qa[k] > cast,no_check(Int32) (cast(float64) 16773022.196) ||
        a_qa[k] < -(cast,no_check(Int32) (cast(float64) 16773022.196)) {
        return 0;
    }

    rc_q31 = -(cast,no_check(Int32) ((cast,no_check(Uint32) a_qa[0]) << (((31 - 24)) & 31)));

    rc_mult1_q30 =
        (cast,no_check(Int32) (cast(float64) 1073741824.5)) -
            cast,no_check(Int32) (((cast,no_check(Int64) rc_q31) * cast(Int64) rc_q31) >> 32);

    inv_gain_q30 =
        cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast,no_check(Int64) inv_gain_q30) *
            cast(Int64) rc_mult1_q30) >> 32))) << 2);

    (inv_gain_q30 <= (cast(s32) 1) << 30);
    if inv_gain_q30 < cast,no_check(Int32) (cast(float64) 107374.6796875) {
        return 0;
    }

    return inv_gain_q30;
}

silk_inverse32_var_q_in_lpc_inv_pred_gain :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_lpc_inv_pred_gain((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_ror32_in_lpc_inv_pred_gain :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_lpc_inv_pred_gain :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_lpc_inv_pred_gain :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_lpc_inv_pred_gain :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_lpc_inv_pred_gain :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_lpc_inv_pred_gain :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_lpc_inv_pred_gain :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_lpc_inv_pred_gain :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_lpc_inv_pred_gain :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_lpc_inv_pred_gain :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_lpc_inv_pred_gain(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_lpc_inv_pred_gain(in_upper);
    }
}

silk_clz_frac_in_lpc_inv_pred_gain :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_lpc_inv_pred_gain(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_lpc_inv_pred_gain(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_lpc_inv_pred_gain :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_lpc_inv_pred_gain(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_lpc_inv_pred_gain :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_lpc_inv_pred_gain((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_lpc_inv_pred_gain((ifx B32 > 0 then B32 else -B32)) - 1;
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

