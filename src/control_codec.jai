silk_clz16_in_control_codec :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_control_codec :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_control_codec :: () -> s32 {
    return 0;
}

silk_ror32_in_control_codec :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_control_codec :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_control_codec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_control_codec :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_control_codec :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_control_codec :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_control_codec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_control_codec :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_control_codec :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_control_codec :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_control_codec(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_control_codec(in_upper);
    }
}

silk_clz_frac_in_control_codec :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_control_codec(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_control_codec(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_control_codec :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_control_codec(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_control_codec :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_control_codec((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_control_codec((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_control_codec :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_control_codec((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_control_codec :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_control_codec :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_control_codec(a);
}

mm_set_ss_in_control_codec :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_control_codec :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_control_codec(mm_set_ss_in_control_codec(x));
}

float2_int16_in_control_codec :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_control_codec(x);
}

float2_int24_in_control_codec :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_control_codec(x);
}

ec_range_bytes_in_control_codec :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_control_codec :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_control_codec :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_control_codec :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_control_codec :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_control_codec :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_control_codec :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_control_codec :: (x: float32) -> Int32 {
    return float2int_in_control_codec(x);
}

silk_float2short_array_in_control_codec :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_control_codec(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_control_codec(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_control_codec(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_control_codec :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_control_codec :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_control_encoder :: (
    ps_enc: *Silk_Encoder_State_FLP,
    enc_control: *Silk_Enc_Control_Struct,
    ALLOW_BW_SWITCH: s32,
    CHANNEL_NB: s32,
    FORCE_FS_K_HZ: s32
) -> s32 {
    ret: s32 = 0;

    ps_enc.s_cmn.use_dtx = enc_control.use_dtx;
    ps_enc.s_cmn.use_cbr = enc_control.use_cbr;
    ps_enc.s_cmn.api_fs_hz = enc_control.api_sample_rate;
    ps_enc.s_cmn.max_internal_fs_hz = enc_control.max_internal_sample_rate;
    ps_enc.s_cmn.min_internal_fs_hz = enc_control.min_internal_sample_rate;
    ps_enc.s_cmn.desired_internal_fs_hz = enc_control.desired_internal_sample_rate;
    ps_enc.s_cmn.use_in_band_fec = enc_control.use_in_band_fec;
    ps_enc.s_cmn.n_channels_api = enc_control.n_channels_api;
    ps_enc.s_cmn.n_channels_internal = enc_control.n_channels_internal;
    ps_enc.s_cmn.allow_bandwidth_switch = ALLOW_BW_SWITCH;
    ps_enc.s_cmn.channel_nb = CHANNEL_NB;

    if ps_enc.s_cmn.controlled_since_last_payload != 0 && ps_enc.s_cmn.prefill_flag == 0 {
        if ps_enc.s_cmn.api_fs_hz != ps_enc.s_cmn.prev_api_fs_hz && ps_enc.s_cmn.fs_k_hz > 0 {
            ret += silk_setup_resamplers(ps_enc, ps_enc.s_cmn.fs_k_hz);
        }
        return ret;
    }

    fs_k_hz := silk_control_audio_bandwidth(*ps_enc.s_cmn, enc_control);
    if FORCE_FS_K_HZ != 0 {
        fs_k_hz = FORCE_FS_K_HZ;
    }

    ret += silk_setup_resamplers(ps_enc, fs_k_hz);

    ret += silk_setup_fs(ps_enc, fs_k_hz, enc_control.payload_size_ms);

    ret += silk_setup_complexity(*ps_enc.s_cmn, enc_control.complexity);

    ps_enc.s_cmn.packet_loss_perc = enc_control.packet_loss_percentage;

    ret += silk_setup_lbrr(*ps_enc.s_cmn, enc_control);

    ps_enc.s_cmn.controlled_since_last_payload = 1;

    return ret;
}

silk_setup_lbrr :: (ps_enc_c: *Silk_Encoder_State, enc_control: *Silk_Enc_Control_Struct) -> s32 {
    lbrr_in_previous_packet: s32 = ---;
    ret: s32 = 0;

    lbrr_in_previous_packet = ps_enc_c.lbrr_enabled;
    ps_enc_c.lbrr_enabled = enc_control.lbrr_coded;
    if ps_enc_c.lbrr_enabled != 0 {
        if lbrr_in_previous_packet == 0 {
            ps_enc_c.lbrr_gain_increases = 7;
        } else {
            ps_enc_c.lbrr_gain_increases =
                silk_max_int_in_control_codec(
                    7 -
                    cast,no_check(Int32) (((cast(Int64) ps_enc_c.packet_loss_perc) * cast,no_check(Int64) (cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 13107.7)))) >> 16),
                    3
                );
        }
    }

    return ret;
}

silk_setup_complexity :: (ps_enc_c: *Silk_Encoder_State, complexity: s32) -> s32 {
    ret: s32 = 0;

    (complexity >= 0 && complexity <= 10);
    if complexity < 1 {
        ps_enc_c.pitch_estimation_complexity = 0;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 52429.3);
        ps_enc_c.pitch_estimation_lpc_order = 6;
        ps_enc_c.shaping_lpc_order = 12;
        ps_enc_c.la_shape = 3 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 1;
        ps_enc_c.use_interpolated_nls_fs = 0;
        ps_enc_c.nlsf_msvq_survivors = 2;
        ps_enc_c.warping_q16 = 0;
    } else if complexity < 2 {
        ps_enc_c.pitch_estimation_complexity = 1;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 49807.86);
        ps_enc_c.pitch_estimation_lpc_order = 8;
        ps_enc_c.shaping_lpc_order = 14;
        ps_enc_c.la_shape = 5 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 1;
        ps_enc_c.use_interpolated_nls_fs = 0;
        ps_enc_c.nlsf_msvq_survivors = 3;
        ps_enc_c.warping_q16 = 0;
    } else if complexity < 3 {
        ps_enc_c.pitch_estimation_complexity = 0;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 52429.3);
        ps_enc_c.pitch_estimation_lpc_order = 6;
        ps_enc_c.shaping_lpc_order = 12;
        ps_enc_c.la_shape = 3 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 2;
        ps_enc_c.use_interpolated_nls_fs = 0;
        ps_enc_c.nlsf_msvq_survivors = 2;
        ps_enc_c.warping_q16 = 0;
    } else if complexity < 4 {
        ps_enc_c.pitch_estimation_complexity = 1;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 49807.86);
        ps_enc_c.pitch_estimation_lpc_order = 8;
        ps_enc_c.shaping_lpc_order = 14;
        ps_enc_c.la_shape = 5 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 2;
        ps_enc_c.use_interpolated_nls_fs = 0;
        ps_enc_c.nlsf_msvq_survivors = 4;
        ps_enc_c.warping_q16 = 0;
    } else if complexity < 6 {
        ps_enc_c.pitch_estimation_complexity = 1;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 48497.14);
        ps_enc_c.pitch_estimation_lpc_order = 10;
        ps_enc_c.shaping_lpc_order = 16;
        ps_enc_c.la_shape = 5 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 2;
        ps_enc_c.use_interpolated_nls_fs = 1;
        ps_enc_c.nlsf_msvq_survivors = 6;
        ps_enc_c.warping_q16 = ps_enc_c.fs_k_hz * cast,no_check(Int32) (cast(float64) 983.5399780273438);
    } else if complexity < 8 {
        ps_enc_c.pitch_estimation_complexity = 1;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 47186.42);
        ps_enc_c.pitch_estimation_lpc_order = 12;
        ps_enc_c.shaping_lpc_order = 20;
        ps_enc_c.la_shape = 5 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 3;
        ps_enc_c.use_interpolated_nls_fs = 1;
        ps_enc_c.nlsf_msvq_survivors = 8;
        ps_enc_c.warping_q16 = ps_enc_c.fs_k_hz * cast,no_check(Int32) (cast(float64) 983.5399780273438);
    } else {
        ps_enc_c.pitch_estimation_complexity = 2;
        ps_enc_c.pitch_estimation_threshold_q16 = cast,no_check(Int32) (cast(float64) 45875.7);
        ps_enc_c.pitch_estimation_lpc_order = 16;
        ps_enc_c.shaping_lpc_order = 24;
        ps_enc_c.la_shape = 5 * ps_enc_c.fs_k_hz;
        ps_enc_c.n_states_delayed_decision = 4;
        ps_enc_c.use_interpolated_nls_fs = 1;
        ps_enc_c.nlsf_msvq_survivors = 16;
        ps_enc_c.warping_q16 = ps_enc_c.fs_k_hz * cast,no_check(Int32) (cast(float64) 983.5399780273438);
    }

    ps_enc_c.pitch_estimation_lpc_order =
        silk_min_int_in_control_codec(
            ps_enc_c.pitch_estimation_lpc_order,
            ps_enc_c.predict_lpc_order
        );
    ps_enc_c.shape_win_length = 5 * ps_enc_c.fs_k_hz + 2 * ps_enc_c.la_shape;
    ps_enc_c.complexity = complexity;

    (ps_enc_c.pitch_estimation_lpc_order <= 16);
    (ps_enc_c.shaping_lpc_order <= 24);
    (ps_enc_c.n_states_delayed_decision <= 4);
    (ps_enc_c.warping_q16 <= 32767);
    (ps_enc_c.la_shape <= 5 * 16);
    (ps_enc_c.shape_win_length <= 15 * 16);

    return ret;
}

silk_setup_fs :: (ps_enc: *Silk_Encoder_State_FLP, fs_k_hz: s32, packet_size_ms: s32) -> s32 {
    ret: s32 = 0;

    if packet_size_ms != ps_enc.s_cmn.packet_size_ms {
        if packet_size_ms != 10 && packet_size_ms != 20 && packet_size_ms != 40 && packet_size_ms != 60 {
            ret = -103;
        }
        if packet_size_ms <= 10 {
            ps_enc.s_cmn.n_frames_per_packet = 1;
            ps_enc.s_cmn.nb_subfr = ifx packet_size_ms == 10 then cast(s32) 2 else 1;
            ps_enc.s_cmn.frame_length =
                (cast,no_check(Int32) (cast,no_check(Int16) packet_size_ms)) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
            ps_enc.s_cmn.pitch_lpc_win_length =
                (cast,no_check(Int32) (cast,no_check(Int16) (10 + (cast(s32) 2) << 1))) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
            if ps_enc.s_cmn.fs_k_hz == 8 {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_NB_I_CDF.data;
            } else {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_I_CDF.data;
            }
        } else {
            ps_enc.s_cmn.n_frames_per_packet = packet_size_ms / cast,no_check(s32) ((5 * 4));
            ps_enc.s_cmn.nb_subfr = 4;
            ps_enc.s_cmn.frame_length =
                (cast,no_check(Int32) (cast(Int16) 20)) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
            ps_enc.s_cmn.pitch_lpc_win_length =
                (cast,no_check(Int32) (cast,no_check(Int16) (20 + (cast(s32) 2) << 1))) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
            if ps_enc.s_cmn.fs_k_hz == 8 {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_NB_I_CDF.data;
            } else {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_I_CDF.data;
            }
        }
        ps_enc.s_cmn.packet_size_ms = packet_size_ms;
        ps_enc.s_cmn.target_rate_bps = 0;
    }

    (fs_k_hz == 8 || fs_k_hz == 12 || fs_k_hz == 16);
    (ps_enc.s_cmn.nb_subfr == 2 || ps_enc.s_cmn.nb_subfr == 4);
    if ps_enc.s_cmn.fs_k_hz != fs_k_hz {
        fill_memory(*ps_enc.s_shape, 0, size_of(Silk_Shape_State_FLP));
        fill_memory(*ps_enc.s_cmn.s_nsq, 0, size_of(Silk_Nsq_State));
        fill_memory(ps_enc.s_cmn.prev_nls_fq_q15.data, 0, ps_enc.s_cmn.prev_nls_fq_q15.count * size_of(Int16));
        fill_memory(*ps_enc.s_cmn.s_lp.in_lp_state, 0, ps_enc.s_cmn.s_lp.in_lp_state.count * size_of(Int32));
        ps_enc.s_cmn.input_buf_ix = 0;
        ps_enc.s_cmn.n_frames_encoded = 0;
        ps_enc.s_cmn.target_rate_bps = 0;

        ps_enc.s_cmn.prev_lag = 100;
        ps_enc.s_cmn.first_frame_after_reset = 1;
        ps_enc.s_shape.last_gain_index = 10;
        ps_enc.s_cmn.s_nsq.lag_prev = 100;
        ps_enc.s_cmn.s_nsq.prev_gain_q16 = 65536;
        ps_enc.s_cmn.prev_signal_type = 0;

        ps_enc.s_cmn.fs_k_hz = fs_k_hz;
        if ps_enc.s_cmn.fs_k_hz == 8 {
            if ps_enc.s_cmn.nb_subfr == 4 {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_NB_I_CDF.data;
            } else {
                ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_NB_I_CDF.data;
            }
        } else if ps_enc.s_cmn.nb_subfr == 4 {
            ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_I_CDF.data;
        } else {
            ps_enc.s_cmn.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_I_CDF.data;
        }
        if ps_enc.s_cmn.fs_k_hz == 8 || ps_enc.s_cmn.fs_k_hz == 12 {
            ps_enc.s_cmn.predict_lpc_order = 10;
            ps_enc.s_cmn.ps_nlsf_cb = *SILK_NLSF_CB_NB_MB;
        } else {
            ps_enc.s_cmn.predict_lpc_order = 16;
            ps_enc.s_cmn.ps_nlsf_cb = *SILK_NLSF_CB_WB;
        }
        ps_enc.s_cmn.subfr_length = 5 * fs_k_hz;
        ps_enc.s_cmn.frame_length =
            (cast,no_check(Int32) (cast,no_check(Int16) ps_enc.s_cmn.subfr_length)) *
                cast,no_check(Int32) (cast,no_check(Int16) ps_enc.s_cmn.nb_subfr);
        ps_enc.s_cmn.ltp_mem_length =
            (cast,no_check(Int32) (cast(Int16) 20)) *
                cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
        ps_enc.s_cmn.la_pitch =
            (cast,no_check(Int32) (cast(Int16) 2)) *
                cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
        ps_enc.s_cmn.max_pitch_lag =
            (cast,no_check(Int32) (cast(Int16) 18)) *
                cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
        if ps_enc.s_cmn.nb_subfr == 4 {
            ps_enc.s_cmn.pitch_lpc_win_length =
                (cast,no_check(Int32) (cast,no_check(Int16) (20 + (cast(s32) 2) << 1))) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
        } else {
            ps_enc.s_cmn.pitch_lpc_win_length =
                (cast,no_check(Int32) (cast,no_check(Int16) (10 + (cast(s32) 2) << 1))) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
        }
        if ps_enc.s_cmn.fs_k_hz == 16 {
            ps_enc.s_cmn.pitch_lag_low_bits_i_cdf = SILK_UNIFORM8_I_CDF.data;
        } else if ps_enc.s_cmn.fs_k_hz == 12 {
            ps_enc.s_cmn.pitch_lag_low_bits_i_cdf = SILK_UNIFORM6_I_CDF.data;
        } else {
            ps_enc.s_cmn.pitch_lag_low_bits_i_cdf = SILK_UNIFORM4_I_CDF.data;
        }
    }

    (ps_enc.s_cmn.subfr_length * ps_enc.s_cmn.nb_subfr == ps_enc.s_cmn.frame_length);

    return ret;
}

silk_setup_resamplers :: (ps_enc: *Silk_Encoder_State_FLP, fs_k_hz: s32) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    ret: s32 = 0;

    if ps_enc.s_cmn.fs_k_hz != fs_k_hz || ps_enc.s_cmn.prev_api_fs_hz != ps_enc.s_cmn.api_fs_hz {
        if ps_enc.s_cmn.fs_k_hz == 0 {
            ret += silk_resampler_init(*ps_enc.s_cmn.resampler_state, ps_enc.s_cmn.api_fs_hz, fs_k_hz * 1000, 1);
        } else {
            buf_length_ms := (cast,no_check(Int32) ((cast,no_check(Uint32) (ps_enc.s_cmn.nb_subfr * 5)) << 1)) + 5;
            old_buf_samples := buf_length_ms * ps_enc.s_cmn.fs_k_hz;

            new_buf_samples := buf_length_ms * fs_k_hz;
            x_buf_fix :=
                cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
                    cast,no_check(u64) (max(old_buf_samples, new_buf_samples)))));
            silk_float2short_array_in_control_codec(x_buf_fix, ps_enc.x_buf.data, old_buf_samples);

            temp_resampler_state :=
                cast(*Silk_Resampler_State_Struct) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Silk_Resampler_State_Struct))) *
                    1)));
            ret +=
                silk_resampler_init(
                    temp_resampler_state,
                    (cast,no_check(Int32) (cast,no_check(Int16) ps_enc.s_cmn.fs_k_hz)) *
                    cast,no_check(Int32) (cast(Int16) 1000),
                    ps_enc.s_cmn.api_fs_hz,
                    0
                );

            api_buf_samples := buf_length_ms * (ps_enc.s_cmn.api_fs_hz / 1000);

            x_buf_api_fs_hz :=
                cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
                    cast,no_check(u64) api_buf_samples)));
            ret += silk_resampler(temp_resampler_state, x_buf_api_fs_hz, x_buf_fix, old_buf_samples);

            ret +=
                silk_resampler_init(
                    *ps_enc.s_cmn.resampler_state,
                    ps_enc.s_cmn.api_fs_hz,
                    (cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000),
                    1
                );

            ret += silk_resampler(*ps_enc.s_cmn.resampler_state, x_buf_fix, x_buf_api_fs_hz, api_buf_samples);

            silk_short2float_array_in_control_codec(ps_enc.x_buf.data, x_buf_fix, new_buf_samples);
        }
    }

    ps_enc.s_cmn.prev_api_fs_hz = ps_enc.s_cmn.api_fs_hz;

    return ret;
}

false__in_control_codec :: () -> s32 {
    return 0;
}

