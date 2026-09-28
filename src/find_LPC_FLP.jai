silk_clz16_in_find_lpc_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_find_lpc_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_find_lpc_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_find_lpc_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_find_lpc_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_find_lpc_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_find_lpc_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_find_lpc_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_find_lpc_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_find_lpc_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_find_lpc_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_find_lpc_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_find_lpc_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_find_lpc_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_find_lpc_flp(in_upper);
    }
}

silk_clz_frac_in_find_lpc_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_find_lpc_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_find_lpc_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_find_lpc_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_find_lpc_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_find_lpc_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_find_lpc_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_find_lpc_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_find_lpc_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_find_lpc_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_find_lpc_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_find_lpc_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_find_lpc_flp(a);
}

mm_set_ss_in_find_lpc_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_find_lpc_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_find_lpc_flp(mm_set_ss_in_find_lpc_flp(x));
}

float2_int16_in_find_lpc_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_find_lpc_flp(x);
}

float2_int24_in_find_lpc_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_find_lpc_flp(x);
}

ec_range_bytes_in_find_lpc_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_find_lpc_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_find_lpc_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_find_lpc_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_find_lpc_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_find_lpc_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_find_lpc_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_find_lpc_flp :: (x: float32) -> Int32 {
    return float2int_in_find_lpc_flp(x);
}

silk_float2short_array_in_find_lpc_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_find_lpc_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_find_lpc_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_find_lpc_flp(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_find_lpc_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_find_lpc_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_find_lpc_flp :: (ps_enc_c: *Silk_Encoder_State, nlsf_q15: *Int16, x: *float32, MIN_INV_GAIN: float32, arch: s32) {
    k: s32 = ---;
    a: [16] float32 = ---;
    res_nrg_2nd: float32 = ---;
    res_nrg_interp: float32 = ---;
    nlsf0_q15: [16] Int16 = ---;
    a_tmp: [16] float32 = ---;
    lpc_res: [384] float32 = ---;

    subfr_length := ps_enc_c.subfr_length + ps_enc_c.predict_lpc_order;

    ps_enc_c.indices.nlsf_interp_coef_q2 = 4;

    res_nrg :=
        silk_burg_modified_flp(
            a.data,
            x,
            MIN_INV_GAIN,
            subfr_length,
            ps_enc_c.nb_subfr,
            ps_enc_c.predict_lpc_order,
            arch
        );

    if ps_enc_c.use_interpolated_nls_fs != 0 && ps_enc_c.first_frame_after_reset == 0 && ps_enc_c.nb_subfr == 4 {
        res_nrg -=
            silk_burg_modified_flp(
                a_tmp.data,
                x + (cast,no_check(s32) ((4 / 2))) * subfr_length,
                MIN_INV_GAIN,
                subfr_length,
                cast,no_check(s32) (4 / 2),
                ps_enc_c.predict_lpc_order,
                arch
            );

        silk_a2_nlsf_flp(nlsf_q15, a_tmp.data, ps_enc_c.predict_lpc_order);

        res_nrg_2nd = cast(float32) 3.4028234663852887e38;
        k = 3;
        while k >= 0 {
            silk_interpolate(nlsf0_q15.data, ps_enc_c.prev_nls_fq_q15.data, nlsf_q15, k, ps_enc_c.predict_lpc_order);

            silk_nlsf2_a_flp(a_tmp.data, nlsf0_q15.data, ps_enc_c.predict_lpc_order, ps_enc_c.arch);

            silk_lpc_analysis_filter_flp(lpc_res.data, a_tmp.data, x, 2 * subfr_length, ps_enc_c.predict_lpc_order);
            res_nrg_interp =
                cast,no_check(float32) (silk_energy_flp(
                    lpc_res.data + ps_enc_c.predict_lpc_order,
                    subfr_length - ps_enc_c.predict_lpc_order
                ) + silk_energy_flp(
                    lpc_res.data + ps_enc_c.predict_lpc_order + subfr_length,
                    subfr_length - ps_enc_c.predict_lpc_order
                ));

            if c_transpiler_float_less(res_nrg_interp, res_nrg) {
                res_nrg = res_nrg_interp;
                ps_enc_c.indices.nlsf_interp_coef_q2 = cast,no_check(Int8) k;
            } else if c_transpiler_float_greater(res_nrg_interp, res_nrg_2nd) {
                break;
            }
            res_nrg_2nd = res_nrg_interp;
            k -= 1;
        }
    }

    if ps_enc_c.indices.nlsf_interp_coef_q2 == 4 {
        silk_a2_nlsf_flp(nlsf_q15, a.data, ps_enc_c.predict_lpc_order);
    }

    (ps_enc_c.indices.nlsf_interp_coef_q2 == 4 || ps_enc_c.use_interpolated_nls_fs != 0 && ps_enc_c.first_frame_after_reset == 0 && ps_enc_c.nb_subfr == 4);
}

