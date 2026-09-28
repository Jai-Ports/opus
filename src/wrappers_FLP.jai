// Generated directly from C by cpp_transpiler.
silk_clz16_in_wrappers_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_wrappers_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_wrappers_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_wrappers_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_wrappers_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_wrappers_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_wrappers_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_wrappers_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_wrappers_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_wrappers_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_wrappers_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_wrappers_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_wrappers_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_wrappers_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_wrappers_flp(in_upper);
    }
}

silk_clz_frac_in_wrappers_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_wrappers_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_wrappers_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_wrappers_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_wrappers_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_wrappers_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_wrappers_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_wrappers_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_wrappers_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_wrappers_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_wrappers_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_wrappers_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_wrappers_flp(a);
}

mm_set_ss_in_wrappers_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_wrappers_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_wrappers_flp(mm_set_ss_in_wrappers_flp(x));
}

float2_int16_in_wrappers_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_wrappers_flp(x);
}

float2_int24_in_wrappers_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_wrappers_flp(x);
}

ec_range_bytes_in_wrappers_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_wrappers_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_wrappers_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_wrappers_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_wrappers_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_wrappers_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_wrappers_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_wrappers_flp :: (x: float32) -> Int32 {
    return float2int_in_wrappers_flp(x);
}

silk_float2short_array_in_wrappers_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_wrappers_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_wrappers_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_wrappers_flp(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_wrappers_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_wrappers_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_quant_ltp_gains_flp :: (
    b: *float32,
    cbk_index: *Int8,
    periodicity_index: *Int8,
    sum_log_gain_q7: *Int32,
    pred_gain_d_b: *float32,
    xx_: *float32,
    x_x: *float32,
    SUBFR_LEN: s32,
    NB_SUBFR: s32,
    arch: s32
) {
    pred_gain_d_b_q7: s32 = ---;
    b_q14: [20] Int16 = ---;
    xx_q17: [100] Int32 = ---;
    x_x_q17: [20] Int32 = ---;

    i: s32 = 0;
    while true {
        xx_q17[i] = silk_float2int_in_wrappers_flp(xx_[i] * 131072.0);
        if !(c_transpiler_pre_increment(*(i)) < NB_SUBFR * 5 * 5) break;
    }
    i = 0;
    while true {
        x_x_q17[i] = silk_float2int_in_wrappers_flp(x_x[i] * 131072.0);
        if !(c_transpiler_pre_increment(*(i)) < NB_SUBFR * 5) break;
    }

    silk_quant_ltp_gains(
        b_q14.data,
        cbk_index,
        periodicity_index,
        sum_log_gain_q7,
        *pred_gain_d_b_q7,
        xx_q17.data,
        x_x_q17.data,
        SUBFR_LEN,
        NB_SUBFR,
        arch
    );

    i = 0;
    while i < NB_SUBFR * 5 {
        b[i] = (cast,no_check(float32) b_q14[i]) * cast(float32) 0.00006103515625;
        i += 1;
    }

    pred_gain_d_b.* = (cast,no_check(float32) pred_gain_d_b_q7) * 0.0078125;
}

silk_a2_nlsf_flp :: (nlsf_q15: *Int16, p_ar: *float32, LPC_ORDER: s32) {
    a_fix_q16: [16] Int32 = ---;

    if 0 < LPC_ORDER {
        for i: 0..LPC_ORDER - 1 {
            a_fix_q16[i] = silk_float2int_in_wrappers_flp(p_ar[i] * 65536.0);
        }
    }

    silk_a2_nlsf(nlsf_q15, a_fix_q16.data, LPC_ORDER);
}

silk_nlsf2_a_flp :: (p_ar: *float32, nlsf_q15: *Int16, LPC_ORDER: s32, arch: s32) {
    a_fix_q12: [16] Int16 = ---;

    silk_nlsf2_a(a_fix_q12.data, nlsf_q15, LPC_ORDER, arch);

    if 0 < LPC_ORDER {
        for i: 0..LPC_ORDER - 1 {
            p_ar[i] = (cast,no_check(float32) a_fix_q12[i]) * cast(float32) 0.000244140625;
        }
    }
}

silk_process_nls_fs_flp :: (
    ps_enc_c: *Silk_Encoder_State,
    pred_coef: *[16] float32,
    nlsf_q15: *Int16,
    prev_nlsf_q15: *Int16
) {
    i: s32 = ---;
    pred_coef_q12: [2] [16] Int16 = ---;

    silk_process_nls_fs(ps_enc_c, pred_coef_q12.data, nlsf_q15, prev_nlsf_q15);

    for j: 0..cast(s32) 2 - 1 {
        i = 0;
        while i < ps_enc_c.predict_lpc_order {
            pred_coef[j][i] = (cast,no_check(float32) pred_coef_q12[j][i]) * cast(float32) 0.000244140625;
            i += 1;
        }
    }
}

silk_nsq_wrapper_flp :: (
    ps_enc: *Silk_Encoder_State_FLP,
    ps_enc_ctrl: *Silk_Encoder_Control_FLP,
    ps_indices: *Side_Info_Indices,
    ps_nsq: *Silk_Nsq_State,
    pulses: *Int8,
    x: *float32
) {
    j: s32 = ---;
    x16: [320] Int16 = ---;
    gains_q16: [4] Int32 = ---;
    pred_coef_q12: [2] [16] Int16 = ---;
    ltp_coef_q14: [20] Int16 = ---;

    ar_q13: [96] Int16 = ---;
    lf_shp_q14: [4] Int32 = ---;

    tilt_q14: [4] s32 = ---;
    harm_shape_gain_q14: [4] s32 = ---;

    i: s32 = 0;
    while i < ps_enc.s_cmn.nb_subfr {
        j = 0;
        while j < ps_enc.s_cmn.shaping_lpc_order {
            ar_q13[i * 24 + j] =
                cast,no_check(Int16) silk_float2int_in_wrappers_flp(
                    ps_enc_ctrl.ar[i * 24 + j] * 8192.0
                );
            j += 1;
        }
        i += 1;
    }

    i = 0;
    while i < ps_enc.s_cmn.nb_subfr {
        lf_shp_q14[i] =
            (cast,no_check(Int32) ((cast,no_check(Uint32) silk_float2int_in_wrappers_flp(ps_enc_ctrl.lf_ar_shp[i] * 16384.0)) << 16)) | cast(Int32) (cast,no_check(Uint16) silk_float2int_in_wrappers_flp(ps_enc_ctrl.lf_ma_shp[i] *
                16384.0));
        tilt_q14[i] = silk_float2int_in_wrappers_flp(ps_enc_ctrl.tilt[i] * 16384.0);
        harm_shape_gain_q14[i] = silk_float2int_in_wrappers_flp(ps_enc_ctrl.harm_shape_gain[i] * 16384.0);
        i += 1;
    }
    lambda_q10 := silk_float2int_in_wrappers_flp(ps_enc_ctrl.lambda * 1024.0);

    i = 0;
    while i < ps_enc.s_cmn.nb_subfr * 5 {
        ltp_coef_q14[i] = cast,no_check(Int16) silk_float2int_in_wrappers_flp(ps_enc_ctrl.ltp_coef[i] * 16384.0);
        i += 1;
    }

    j = 0;
    while j < 2 {
        i = 0;
        while i < ps_enc.s_cmn.predict_lpc_order {
            pred_coef_q12[j][i] =
                cast,no_check(Int16) silk_float2int_in_wrappers_flp(
                    ps_enc_ctrl.pred_coef[j][i] * 4096.0
                );
            i += 1;
        }
        j += 1;
    }

    i = 0;
    while i < ps_enc.s_cmn.nb_subfr {
        gains_q16[i] = silk_float2int_in_wrappers_flp(ps_enc_ctrl.gains[i] * 65536.0);
        (gains_q16[i] > 0);
        i += 1;
    }

    ltp_scale_q14: s32 = ifx ps_indices.signal_type == 2
        then cast,no_check(s32) SILK_LTP_SCALES_TABLE_Q14[ps_indices.ltp_scale_index]
        else 0;

    i = 0;
    while i < ps_enc.s_cmn.frame_length {
        x16[i] = cast,no_check(Int16) silk_float2int_in_wrappers_flp(x[i]);
        i += 1;
    }

    if ps_enc.s_cmn.n_states_delayed_decision > 1 || ps_enc.s_cmn.warping_q16 > 0 {
        ps_enc.s_cmn.arch;
        silk_nsq_del_dec_c(
            *ps_enc.s_cmn,
            ps_nsq,
            ps_indices,
            x16.data,
            pulses,
            pred_coef_q12[0].data,
            ltp_coef_q14.data,
            ar_q13.data,
            harm_shape_gain_q14.data,
            tilt_q14.data,
            lf_shp_q14.data,
            gains_q16.data,
            ps_enc_ctrl.pitch_l.data,
            lambda_q10,
            ltp_scale_q14
        );
    } else {
        ps_enc.s_cmn.arch;
        silk_nsq_c(
            *ps_enc.s_cmn,
            ps_nsq,
            ps_indices,
            x16.data,
            pulses,
            pred_coef_q12[0].data,
            ltp_coef_q14.data,
            ar_q13.data,
            harm_shape_gain_q14.data,
            tilt_q14.data,
            lf_shp_q14.data,
            gains_q16.data,
            ps_enc_ctrl.pitch_l.data,
            lambda_q10,
            ltp_scale_q14
        );
    }
}

