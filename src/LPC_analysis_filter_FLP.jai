silk_clz16_in_lpc_analysis_filter_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_lpc_analysis_filter_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_lpc_analysis_filter_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_lpc_analysis_filter_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_lpc_analysis_filter_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_lpc_analysis_filter_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_lpc_analysis_filter_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_lpc_analysis_filter_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_lpc_analysis_filter_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_lpc_analysis_filter_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_lpc_analysis_filter_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_lpc_analysis_filter_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_lpc_analysis_filter_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_lpc_analysis_filter_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_lpc_analysis_filter_flp(in_upper);
    }
}

silk_clz_frac_in_lpc_analysis_filter_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_lpc_analysis_filter_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_lpc_analysis_filter_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_lpc_analysis_filter_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_lpc_analysis_filter_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_lpc_analysis_filter_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_lpc_analysis_filter_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_lpc_analysis_filter_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_lpc_analysis_filter_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_lpc_analysis_filter_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_lpc_analysis_filter_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_lpc_analysis_filter_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_lpc_analysis_filter_flp(a);
}

mm_set_ss_in_lpc_analysis_filter_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_lpc_analysis_filter_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_lpc_analysis_filter_flp(mm_set_ss_in_lpc_analysis_filter_flp(x));
}

float2_int16_in_lpc_analysis_filter_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_lpc_analysis_filter_flp(x);
}

float2_int24_in_lpc_analysis_filter_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_lpc_analysis_filter_flp(x);
}

ec_range_bytes_in_lpc_analysis_filter_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_lpc_analysis_filter_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_lpc_analysis_filter_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_lpc_analysis_filter_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_lpc_analysis_filter_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_lpc_analysis_filter_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_lpc_analysis_filter_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_lpc_analysis_filter_flp :: (x: float32) -> Int32 {
    return float2int_in_lpc_analysis_filter_flp(x);
}

silk_float2short_array_in_lpc_analysis_filter_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_lpc_analysis_filter_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_lpc_analysis_filter_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_lpc_analysis_filter_flp(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_lpc_analysis_filter_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_lpc_analysis_filter_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_lpc_analysis_filter_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32, ORDER: s32) {
    if ORDER == {
        case 6;
            silk_lpc_analysis_filter6_flp(r_lpc, pred_coef, s, LENGTH);
        case 8;
            silk_lpc_analysis_filter8_flp(r_lpc, pred_coef, s, LENGTH);
        case 10;
            silk_lpc_analysis_filter10_flp(r_lpc, pred_coef, s, LENGTH);
        case 12;
            silk_lpc_analysis_filter12_flp(r_lpc, pred_coef, s, LENGTH);
        case 16;
            silk_lpc_analysis_filter16_flp(r_lpc, pred_coef, s, LENGTH);
        case;
    }

    fill_memory(r_lpc, 0, cast,no_check(u64) ORDER * size_of(float32));
}

silk_lpc_analysis_filter16_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32) {
    if 16 < LENGTH {
        for ix: 16..LENGTH - 1 {
            s_ptr := *s[ix - 1];

            lpc_pred :=
                s_ptr[0] * pred_coef[0] + s_ptr[-1] * pred_coef[1] + s_ptr[-2] * pred_coef[2] + s_ptr[-3] * pred_coef[3] + s_ptr[-4] * pred_coef[4] + s_ptr[-5] * pred_coef[5] + s_ptr[-6] * pred_coef[6] + s_ptr[-7] * pred_coef[7] +
                    s_ptr[-8] * pred_coef[8] + s_ptr[-9] * pred_coef[9] + s_ptr[-10] * pred_coef[10] + s_ptr[-11] * pred_coef[11] + s_ptr[-12] * pred_coef[12] + s_ptr[-13] * pred_coef[13] + s_ptr[-14] * pred_coef[14] + s_ptr[-15] * pred_coef[15];

            r_lpc[ix] = s_ptr[1] - lpc_pred;
        }
    }
}

silk_lpc_analysis_filter12_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32) {
    if 12 < LENGTH {
        for ix: 12..LENGTH - 1 {
            s_ptr := *s[ix - 1];

            lpc_pred :=
                s_ptr[0] * pred_coef[0] + s_ptr[-1] * pred_coef[1] + s_ptr[-2] * pred_coef[2] + s_ptr[-3] * pred_coef[3] + s_ptr[-4] * pred_coef[4] + s_ptr[-5] * pred_coef[5] +
                    s_ptr[-6] * pred_coef[6] + s_ptr[-7] * pred_coef[7] + s_ptr[-8] * pred_coef[8] + s_ptr[-9] * pred_coef[9] + s_ptr[-10] * pred_coef[10] + s_ptr[-11] * pred_coef[11];

            r_lpc[ix] = s_ptr[1] - lpc_pred;
        }
    }
}

silk_lpc_analysis_filter10_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32) {
    if 10 < LENGTH {
        for ix: 10..LENGTH - 1 {
            s_ptr := *s[ix - 1];

            lpc_pred :=
                s_ptr[0] * pred_coef[0] + s_ptr[-1] * pred_coef[1] + s_ptr[-2] * pred_coef[2] + s_ptr[-3] * pred_coef[3] + s_ptr[-4] * pred_coef[4] +
                    s_ptr[-5] * pred_coef[5] + s_ptr[-6] * pred_coef[6] + s_ptr[-7] * pred_coef[7] + s_ptr[-8] * pred_coef[8] + s_ptr[-9] * pred_coef[9];

            r_lpc[ix] = s_ptr[1] - lpc_pred;
        }
    }
}

silk_lpc_analysis_filter8_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32) {
    if 8 < LENGTH {
        for ix: 8..LENGTH - 1 {
            s_ptr := *s[ix - 1];

            lpc_pred :=
                s_ptr[0] * pred_coef[0] + s_ptr[-1] * pred_coef[1] + s_ptr[-2] * pred_coef[2] + s_ptr[-3] * pred_coef[3] +
                    s_ptr[-4] * pred_coef[4] + s_ptr[-5] * pred_coef[5] + s_ptr[-6] * pred_coef[6] + s_ptr[-7] * pred_coef[7];

            r_lpc[ix] = s_ptr[1] - lpc_pred;
        }
    }
}

silk_lpc_analysis_filter6_flp :: (r_lpc: *float32, pred_coef: *float32, s: *float32, LENGTH: s32) {
    if 6 < LENGTH {
        for ix: 6..LENGTH - 1 {
            s_ptr := *s[ix - 1];

            lpc_pred :=
                s_ptr[0] * pred_coef[0] + s_ptr[-1] * pred_coef[1] + s_ptr[-2] * pred_coef[2] +
                    s_ptr[-3] * pred_coef[3] + s_ptr[-4] * pred_coef[4] + s_ptr[-5] * pred_coef[5];

            r_lpc[ix] = s_ptr[1] - lpc_pred;
        }
    }
}

