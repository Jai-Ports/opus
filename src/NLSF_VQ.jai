// Generated directly from C by cpp_transpiler.
silk_clz16_in_nlsf_vq :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nlsf_vq :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nlsf_vq :: () -> s32 {
    return 0;
}

silk_ror32_in_nlsf_vq :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nlsf_vq :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nlsf_vq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nlsf_vq :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nlsf_vq :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nlsf_vq :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nlsf_vq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nlsf_vq :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nlsf_vq :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nlsf_vq :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nlsf_vq(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nlsf_vq(in_upper);
    }
}

silk_clz_frac_in_nlsf_vq :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nlsf_vq(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nlsf_vq(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nlsf_vq :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nlsf_vq(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nlsf_vq :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nlsf_vq((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nlsf_vq((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nlsf_vq :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nlsf_vq((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nlsf_vq :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nlsf_vq :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nlsf_vq :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nlsf_vq :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nlsf_vq :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nlsf_vq :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_nlsf_vq :: (err_q24: *Int32, in_q15: *Int16, p_cb_q8: *Uint8, p_wght_q9: *Int16, K: s32, LPC_ORDER: s32) {
    m: s32 = ---;
    diff_q15: Int32 = ---;
    diffw_q24: Int32 = ---;

    (LPC_ORDER & 1 == 0);

    cb_q8_ptr := p_cb_q8;
    w_q9_ptr := p_wght_q9;
    if 0 < K {
        for i: 0..K - 1 {
            sum_error_q24: Int32 = 0;
            pred_q24: Int32 = 0;
            m = LPC_ORDER - 2;
            while m >= 0 {
                diff_q15 =
                    (cast(Int32) in_q15[m + 1]) -
                        cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) cb_q8_ptr[m + 1])) << 7);
                diffw_q24 =
                    (cast,no_check(Int32) (cast,no_check(Int16) diff_q15)) *
                        cast,no_check(Int32) w_q9_ptr[m + 1];
                sum_error_q24 =
                    sum_error_q24 +
                        (ifx diffw_q24 - pred_q24 >> 1 > 0 then diffw_q24 - pred_q24 >> 1 else -(diffw_q24 - pred_q24 >> 1));
                pred_q24 = diffw_q24;

                diff_q15 =
                    (cast(Int32) in_q15[m]) -
                        cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) cb_q8_ptr[m])) << 7);
                diffw_q24 = (cast,no_check(Int32) (cast,no_check(Int16) diff_q15)) * cast,no_check(Int32) w_q9_ptr[m];
                sum_error_q24 =
                    sum_error_q24 +
                        (ifx diffw_q24 - pred_q24 >> 1 > 0 then diffw_q24 - pred_q24 >> 1 else -(diffw_q24 - pred_q24 >> 1));
                pred_q24 = diffw_q24;
                m -= 2;
            }
            err_q24[i] = sum_error_q24;
            cb_q8_ptr += LPC_ORDER;
            w_q9_ptr += LPC_ORDER;
        }
    }
}

