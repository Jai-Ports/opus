silk_clz16_in_noise_shape_analysis_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_noise_shape_analysis_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_noise_shape_analysis_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_noise_shape_analysis_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_noise_shape_analysis_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_noise_shape_analysis_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_noise_shape_analysis_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_noise_shape_analysis_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_noise_shape_analysis_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_noise_shape_analysis_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_noise_shape_analysis_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_noise_shape_analysis_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_noise_shape_analysis_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_noise_shape_analysis_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_noise_shape_analysis_flp(in_upper);
    }
}

silk_clz_frac_in_noise_shape_analysis_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_noise_shape_analysis_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_noise_shape_analysis_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_noise_shape_analysis_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_noise_shape_analysis_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_noise_shape_analysis_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_noise_shape_analysis_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_noise_shape_analysis_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_noise_shape_analysis_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_noise_shape_analysis_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_noise_shape_analysis_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_noise_shape_analysis_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_noise_shape_analysis_flp(a);
}

mm_set_ss_in_noise_shape_analysis_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_noise_shape_analysis_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_noise_shape_analysis_flp(mm_set_ss_in_noise_shape_analysis_flp(x));
}

float2_int16_in_noise_shape_analysis_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_noise_shape_analysis_flp(x);
}

float2_int24_in_noise_shape_analysis_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_noise_shape_analysis_flp(x);
}

ec_range_bytes_in_noise_shape_analysis_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_noise_shape_analysis_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_noise_shape_analysis_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_noise_shape_analysis_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_noise_shape_analysis_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_noise_shape_analysis_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_noise_shape_analysis_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_noise_shape_analysis_flp :: (x: float32) -> Int32 {
    return float2int_in_noise_shape_analysis_flp(x);
}

silk_float2short_array_in_noise_shape_analysis_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_noise_shape_analysis_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_noise_shape_analysis_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_noise_shape_analysis_flp(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_noise_shape_analysis_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_noise_shape_analysis_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_noise_shape_analysis_flp :: (
    ps_enc: *Silk_Encoder_State_FLP,
    ps_enc_ctrl: *Silk_Encoder_Control_FLP,
    pitch_res: *float32,
    x: *float32
) {
    ps_shape_st := *ps_enc.s_shape;
    k, n_samples, n_segs: s32 = ---;
    harm_shape_gain: float32 = ---;
    tilt: float32 = ---;
    nrg, log_energy, log_energy_prev, energy_variation: float32 = ---;
    b: float32 = ---;
    x_windowed: [240] float32 = ---;
    auto_corr: [25] float32 = ---;
    rc: [25] float32 = ---;
    x_ptr, pitch_res_ptr: *float32 = ---;

    x_ptr = x - ps_enc.s_cmn.la_shape;

    snr_adj_d_b := (cast,no_check(float32) ps_enc.s_cmn.snr_d_b_q7) * 0.0078125;

    ps_enc_ctrl.input_quality =
        (0.5 * cast,no_check(float32) (ps_enc.s_cmn.input_quality_bands_q15[0] + ps_enc.s_cmn.input_quality_bands_q15[1])) *
            cast(float32) 0.000030517578125;

    ps_enc_ctrl.coding_quality = silk_sigmoid_in_noise_shape_analysis_flp(0.25 * (snr_adj_d_b - 20.0));

    if ps_enc.s_cmn.use_cbr == 0 {
        b = 1.0 - (cast,no_check(float32) ps_enc.s_cmn.speech_activity_q8) * 0.00390625;
        snr_adj_d_b -= 2.0 * ps_enc_ctrl.coding_quality * (0.5 + 0.5 * ps_enc_ctrl.input_quality) * b * b;
    }

    if ps_enc.s_cmn.indices.signal_type == 2 {
        snr_adj_d_b += 2.0 * ps_enc.ltp_corr;
    } else {
        snr_adj_d_b +=
            ((((cast(float32) -0.4000000059604645) * cast,no_check(float32) ps_enc.s_cmn.snr_d_b_q7) * 0.0078125) + 6.0) *
                (1.0 - ps_enc_ctrl.input_quality);
    }

    if ps_enc.s_cmn.indices.signal_type == 2 {
        ps_enc.s_cmn.indices.quant_offset_type = 0;
    } else {
        n_samples = 2 * ps_enc.s_cmn.fs_k_hz;
        energy_variation = 0.0;
        log_energy_prev = 0.0;
        pitch_res_ptr = pitch_res;
        n_segs =
            ((cast,no_check(Int32) (cast(Int16) 5)) * cast,no_check(Int32) (cast,no_check(Int16) ps_enc.s_cmn.nb_subfr)) /
                2;
        k = 0;
        while k < n_segs {
            nrg = (cast,no_check(float32) n_samples) + cast,no_check(float32) silk_energy_flp(pitch_res_ptr, n_samples);
            log_energy = silk_log2_in_noise_shape_analysis_flp(cast,no_check(float64) nrg);
            if k > 0 {
                energy_variation +=
                    cast,no_check(float32) c_transpiler_math_fabs(
                        cast,no_check(float64) (log_energy - log_energy_prev)
                    );
            }
            log_energy_prev = log_energy;
            pitch_res_ptr += n_samples;
            k += 1;
        }

        if c_transpiler_float_greater(energy_variation, (0.6 * cast,no_check(float32) (n_segs - 1))) {
            ps_enc.s_cmn.indices.quant_offset_type = 0;
        } else {
            ps_enc.s_cmn.indices.quant_offset_type = 1;
        }
    }

    strength := 1.0e-3 * ps_enc_ctrl.pred_gain;
    bw_exp := 0.94 / (1.0 + strength * strength);

    warping := (cast,no_check(float32) ps_enc.s_cmn.warping_q16) / 65536.0 + 0.01 * ps_enc_ctrl.coding_quality;

    k = 0;
    while k < ps_enc.s_cmn.nb_subfr {
        flat_part: s32 = ---;
        flat_part = ps_enc.s_cmn.fs_k_hz * 3;
        slope_part := (ps_enc.s_cmn.shape_win_length - flat_part) / 2;

        silk_apply_sine_window_flp(x_windowed.data, x_ptr, 1, slope_part);
        shift := slope_part;
        copy_memory(x_windowed.data + shift, x_ptr + shift, cast,no_check(u64) flat_part * size_of(float32));
        shift += flat_part;
        silk_apply_sine_window_flp(x_windowed.data + shift, x_ptr + shift, 2, slope_part);

        x_ptr += ps_enc.s_cmn.subfr_length;

        if ps_enc.s_cmn.warping_q16 > 0 {
            silk_warped_autocorrelation_flp(
                auto_corr.data,
                x_windowed.data,
                warping,
                ps_enc.s_cmn.shape_win_length,
                ps_enc.s_cmn.shaping_lpc_order
            );
        } else {
            silk_autocorrelation_flp(
                auto_corr.data,
                x_windowed.data,
                ps_enc.s_cmn.shape_win_length,
                ps_enc.s_cmn.shaping_lpc_order + 1,
                ps_enc.s_cmn.arch
            );
        }

        auto_corr[0] += auto_corr[0] * 3.0e-5 + 1.0;

        nrg = silk_schur_flp(rc.data, auto_corr.data, ps_enc.s_cmn.shaping_lpc_order);
        silk_k2a_flp(ps_enc_ctrl.ar.data + k * 24, rc.data, ps_enc.s_cmn.shaping_lpc_order);
        ps_enc_ctrl.gains[k] = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) nrg);

        if ps_enc.s_cmn.warping_q16 > 0 {
            ps_enc_ctrl.gains[k] *= warped_gain(ps_enc_ctrl.ar.data + k * 24, warping, ps_enc.s_cmn.shaping_lpc_order);
        }

        silk_bwexpander_flp(ps_enc_ctrl.ar.data + k * 24, ps_enc.s_cmn.shaping_lpc_order, bw_exp);

        if ps_enc.s_cmn.warping_q16 > 0 {
            warped_true2monic_coefs(ps_enc_ctrl.ar.data + k * 24, warping, 3.999, ps_enc.s_cmn.shaping_lpc_order);
        } else {
            limit_coefs(ps_enc_ctrl.ar.data + k * 24, 3.999, ps_enc.s_cmn.shaping_lpc_order);
        }
        k += 1;
    }

    gain_mult :=
        cast,no_check(float32) c_transpiler_math_pow(
            2.0,
            cast,no_check(float64) ((cast(float32) -0.1599999964237213) * snr_adj_d_b)
        );
    gain_add := cast,no_check(float32) c_transpiler_math_pow(2.0, 0.3199999928474426);
    k = 0;
    while k < ps_enc.s_cmn.nb_subfr {
        ps_enc_ctrl.gains[k] *= gain_mult;
        ps_enc_ctrl.gains[k] += gain_add;
        k += 1;
    }

    strength =
        4.0 *
            (1.0 + 0.5 * (((cast,no_check(float32) ps_enc.s_cmn.input_quality_bands_q15[0]) * cast(float32) 0.000030517578125) - 1.0));
    strength *= (cast,no_check(float32) ps_enc.s_cmn.speech_activity_q8) * 0.00390625;
    if ps_enc.s_cmn.indices.signal_type == 2 {
        k = 0;
        while k < ps_enc.s_cmn.nb_subfr {
            b =
                (0.2 / cast,no_check(float32) ps_enc.s_cmn.fs_k_hz) +
                    3.0 / cast,no_check(float32) ps_enc_ctrl.pitch_l[k];
            ps_enc_ctrl.lf_ma_shp[k] = -1.0 + b;
            ps_enc_ctrl.lf_ar_shp[k] = 1.0 - b - b * strength;
            k += 1;
        }
        tilt =
            -0.25 -
                ((cast(float32) 0.26249998807907107) * cast,no_check(float32) ps_enc.s_cmn.speech_activity_q8) * 0.00390625;
    } else {
        b = 1.3 / cast,no_check(float32) ps_enc.s_cmn.fs_k_hz;
        ps_enc_ctrl.lf_ma_shp[0] = -1.0 + b;
        ps_enc_ctrl.lf_ar_shp[0] = 1.0 - b - b * strength * 0.6;
        k = 1;
        while k < ps_enc.s_cmn.nb_subfr {
            ps_enc_ctrl.lf_ma_shp[k] = ps_enc_ctrl.lf_ma_shp[0];
            ps_enc_ctrl.lf_ar_shp[k] = ps_enc_ctrl.lf_ar_shp[0];
            k += 1;
        }
        tilt = -0.25;
    }

    if ((cast(s32) 1) != 0) && ps_enc.s_cmn.indices.signal_type == 2 {
        harm_shape_gain = 0.3;

        harm_shape_gain += 0.2 * (1.0 - (1.0 - ps_enc_ctrl.coding_quality) * ps_enc_ctrl.input_quality);

        harm_shape_gain *= cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) ps_enc.ltp_corr);
    } else {
        harm_shape_gain = 0.0;
    }

    k = 0;
    while k < ps_enc.s_cmn.nb_subfr {
        ps_shape_st.harm_shape_gain_smth += 0.4 * (harm_shape_gain - ps_shape_st.harm_shape_gain_smth);
        ps_enc_ctrl.harm_shape_gain[k] = ps_shape_st.harm_shape_gain_smth;
        ps_shape_st.tilt_smth += 0.4 * (tilt - ps_shape_st.tilt_smth);
        ps_enc_ctrl.tilt[k] = ps_shape_st.tilt_smth;
        k += 1;
    }
}

limit_coefs :: (coefs: *float32, limit: float32, order: s32) {
    i: s32 = ---;
    ind: s32 = 0;
    tmp: float32 = ---;

    for iter: 0..cast(s32) 10 - 1 {
        maxabs: float32 = -1.0;
        i = 0;
        while i < order {
            tmp = cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) coefs[i]);
            if c_transpiler_float_greater(tmp, maxabs) {
                maxabs = tmp;
                ind = i;
            }
            i += 1;
        }
        if c_transpiler_float_less_equal(maxabs, limit) {
            return;
        }

        chirp := 0.99 - ((0.8 + 0.1 * cast,no_check(float32) iter) * (maxabs - limit)) / (maxabs * (ind + 1));
        silk_bwexpander_flp(coefs, order, chirp);
    }
}

warped_true2monic_coefs :: (coefs: *float32, lambda: float32, limit: float32, order: s32) {
    ind: s32 = 0;
    tmp: float32 = ---;

    i := order - 1;
    while i > 0 {
        coefs[i - 1] -= lambda * coefs[i];
        i -= 1;
    }
    gain := (1.0 - lambda * lambda) / (1.0 + lambda * coefs[0]);
    i = 0;
    while i < order {
        coefs[i] *= gain;
        i += 1;
    }

    for iter: 0..cast(s32) 10 - 1 {
        maxabs: float32 = -1.0;
        i = 0;
        while i < order {
            tmp = cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) coefs[i]);
            if c_transpiler_float_greater(tmp, maxabs) {
                maxabs = tmp;
                ind = i;
            }
            i += 1;
        }
        if c_transpiler_float_less_equal(maxabs, limit) {
            return;
        }

        i = 1;
        while i < order {
            coefs[i - 1] += lambda * coefs[i];
            i += 1;
        }
        gain = 1.0 / gain;
        i = 0;
        while i < order {
            coefs[i] *= gain;
            i += 1;
        }

        chirp := 0.99 - ((0.8 + 0.1 * cast,no_check(float32) iter) * (maxabs - limit)) / (maxabs * (ind + 1));
        silk_bwexpander_flp(coefs, order, chirp);

        i = order - 1;
        while i > 0 {
            coefs[i - 1] -= lambda * coefs[i];
            i -= 1;
        }
        gain = (1.0 - lambda * lambda) / (1.0 + lambda * coefs[0]);
        i = 0;
        while i < order {
            coefs[i] *= gain;
            i += 1;
        }
    }
}

warped_gain :: (coefs: *float32, lambda: float32, order: s32) -> float32 {
    lambda = -lambda;
    gain := coefs[order - 1];
    i := order - 2;
    while i >= 0 {
        gain = lambda * gain + coefs[i];
        i -= 1;
    }
    return 1.0 / (1.0 - lambda * gain);
}

