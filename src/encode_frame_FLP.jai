// Generated directly from C by cpp_transpiler.
silk_clz16_in_encode_frame_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_encode_frame_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_encode_frame_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_encode_frame_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_encode_frame_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_encode_frame_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_encode_frame_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_encode_frame_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_encode_frame_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_encode_frame_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_encode_frame_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_encode_frame_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_encode_frame_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_encode_frame_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_encode_frame_flp(in_upper);
    }
}

silk_clz_frac_in_encode_frame_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_encode_frame_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_encode_frame_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_encode_frame_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_encode_frame_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_encode_frame_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_encode_frame_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_encode_frame_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_encode_frame_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_encode_frame_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_encode_frame_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_encode_frame_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_encode_frame_flp(a);
}

mm_set_ss_in_encode_frame_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_encode_frame_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_encode_frame_flp(mm_set_ss_in_encode_frame_flp(x));
}

float2_int16_in_encode_frame_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_encode_frame_flp(x);
}

float2_int24_in_encode_frame_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_encode_frame_flp(x);
}

ec_range_bytes_in_encode_frame_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_encode_frame_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_encode_frame_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_encode_frame_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_encode_frame_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_encode_frame_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_sigmoid_in_encode_frame_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_encode_frame_flp :: (x: float32) -> Int32 {
    return float2int_in_encode_frame_flp(x);
}

silk_float2short_array_in_encode_frame_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_encode_frame_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_encode_frame_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_encode_frame_flp(in[k]))));
        k -= 1;
    }
}

silk_short2float_array_in_encode_frame_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2_in_encode_frame_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_encode_do_vad_flp :: (ps_enc: *Silk_Encoder_State_FLP, activity: s32) {
    ACTIVITY_THRESHOLD: s32 = cast,no_check(Int32) (cast(float64) 13.300000190734864);

    ps_enc.s_cmn.arch;
    silk_vad_get_sa_q8_c(*ps_enc.s_cmn, ps_enc.s_cmn.input_buf.data + 1);

    if activity == 0 && ps_enc.s_cmn.speech_activity_q8 >= ACTIVITY_THRESHOLD {
        ps_enc.s_cmn.speech_activity_q8 = ACTIVITY_THRESHOLD - 1;
    }

    if ps_enc.s_cmn.speech_activity_q8 < ACTIVITY_THRESHOLD {
        ps_enc.s_cmn.indices.signal_type = 0;
        ps_enc.s_cmn.no_speech_counter += 1;
        if ps_enc.s_cmn.no_speech_counter <= 10 {
            ps_enc.s_cmn.in_dtx = 0;
        } else if ps_enc.s_cmn.no_speech_counter > 20 + 10 {
            ps_enc.s_cmn.no_speech_counter = 10;
            ps_enc.s_cmn.in_dtx = 0;
        }
        ps_enc.s_cmn.vad_flags[ps_enc.s_cmn.n_frames_encoded] = 0;
    } else {
        ps_enc.s_cmn.no_speech_counter = 0;
        ps_enc.s_cmn.in_dtx = 0;
        ps_enc.s_cmn.indices.signal_type = 1;
        ps_enc.s_cmn.vad_flags[ps_enc.s_cmn.n_frames_encoded] = 1;
    }
}

silk_encode_frame_flp :: (
    ps_enc: *Silk_Encoder_State_FLP,
    pn_bytes_out: *Int32,
    ps_range_enc: *Ec_Enc,
    cond_coding: s32,
    max_bits: s32,
    use_cbr: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    s_enc_ctrl: Silk_Encoder_Control_FLP = ---;
    iter: s32 = ---;
    max_iter: s32 = ---;
    found_upper: s32 = ---;
    found_lower: s32 = ---;
    ret: s32 = 0;

    res_pitch: [672] float32 = ---;
    s_range_enc_copy, s_range_enc_copy2: Ec_Enc = ---;

    seed_copy, n_bits, n_bits_lower, n_bits_upper, gain_mult_lower, gain_mult_upper: Int32 = ---;
    gains_id, gains_id_lower, gains_id_upper: Int32 = ---;
    gain_mult_q8: Int16 = ---;
    ec_prev_lag_index_copy: Int16 = ---;
    ec_prev_signal_type_copy: s32 = ---;
    last_gain_index_copy2: Int8 = ---;
    p_gains_q16: [4] Int32 = ---;
    gain_lock: [4] s32;
    best_gain_mult: [4] Int16 = ---;
    best_sum: [4] s32 = ---;

    s_nsq_copy :=
        cast(*Silk_Nsq_State) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Silk_Nsq_State))) *
            2)));

    bits_margin := (ifx use_cbr != 0 then 5 else max_bits / 4);

    last_gain_index_copy2 =
        cast,no_check(Int8) ((ifx true { assignment_3: Int32 = cast,no_check(Int32) ((ifx true { assignment_2: Int32 = cast,no_check(Int32) ((ifx true { assignment_1: Int32 = cast,no_check(Int32) ((ifx true { assignment_0: Int32 = cast,no_check(Int32) (cast(s32) 0); (gain_mult_upper) = assignment_0; assignment_0; })); (gain_mult_lower) = assignment_1; assignment_1; })); (n_bits_upper) = assignment_2; assignment_2; })); (n_bits_lower) = assignment_3; assignment_3; }));

    ps_enc.s_cmn.indices.seed = cast,no_check(Int8) (c_transpiler_post_increment(*(ps_enc.s_cmn.frame_counter)) & 3);

    x_frame := ps_enc.x_buf.data + ps_enc.s_cmn.ltp_mem_length;
    res_pitch_frame := res_pitch.data + ps_enc.s_cmn.ltp_mem_length;

    silk_lp_variable_cutoff(*ps_enc.s_cmn.s_lp, ps_enc.s_cmn.input_buf.data + 1, ps_enc.s_cmn.frame_length);

    silk_short2float_array_in_encode_frame_flp(
        x_frame + 5 * ps_enc.s_cmn.fs_k_hz,
        ps_enc.s_cmn.input_buf.data + 1,
        ps_enc.s_cmn.frame_length
    );

    i: s32 = 0;
    while i < 8 {
        x_frame[5 * ps_enc.s_cmn.fs_k_hz + i * ps_enc.s_cmn.frame_length >> 3] +=
            (cast,no_check(float32) (1 - i & 2)) *
                1.0e-6;
        i += 1;
    }

    if ps_enc.s_cmn.prefill_flag == 0 {
        (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: *float32, _: *float32, _: s32)) (cast(*void) silk_find_pitch_lags_flp))(
            ps_enc,
            *s_enc_ctrl,
            res_pitch.data,
            x_frame,
            ps_enc.s_cmn.arch
        );

        (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: *float32, _: *float32)) (cast(*void) silk_noise_shape_analysis_flp))(
            ps_enc,
            *s_enc_ctrl,
            res_pitch_frame,
            x_frame
        );

        (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: *float32, _: *float32, _: s32)) (cast(*void) silk_find_pred_coefs_flp))(
            ps_enc,
            *s_enc_ctrl,
            res_pitch_frame,
            x_frame,
            cond_coding
        );

        (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: s32)) (cast(*void) silk_process_gains_flp))(
            ps_enc,
            *s_enc_ctrl,
            cond_coding
        );

        silk_lbrr_encode_flp(ps_enc, *s_enc_ctrl, x_frame, cond_coding);

        max_iter = 6;
        gain_mult_q8 = cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 256.5));
        found_lower = 0;
        found_upper = 0;
        gains_id = silk_gains_id(ps_enc.s_cmn.indices.gains_indices.data, ps_enc.s_cmn.nb_subfr);
        gains_id_lower = -1;
        gains_id_upper = -1;

        copy_memory(*s_range_enc_copy, ps_range_enc, size_of(Ec_Enc));
        copy_memory(*s_nsq_copy[0], *ps_enc.s_cmn.s_nsq, size_of(Silk_Nsq_State));
        seed_copy = cast,no_check(Int32) ps_enc.s_cmn.indices.seed;
        ec_prev_lag_index_copy = ps_enc.s_cmn.ec_prev_lag_index;
        ec_prev_signal_type_copy = ps_enc.s_cmn.ec_prev_signal_type;
        ec_buf_copy := cast(*Uint8) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Uint8))) * 1275)));
        iter = 0;
        while true {
            if gains_id == gains_id_lower {
                n_bits = n_bits_lower;
            } else if gains_id == gains_id_upper {
                n_bits = n_bits_upper;
            } else {
                if iter > 0 {
                    copy_memory(ps_range_enc, *s_range_enc_copy, size_of(Ec_Enc));
                    copy_memory(*ps_enc.s_cmn.s_nsq, *s_nsq_copy[0], size_of(Silk_Nsq_State));
                    ps_enc.s_cmn.indices.seed = cast,no_check(Int8) seed_copy;
                    ps_enc.s_cmn.ec_prev_lag_index = ec_prev_lag_index_copy;
                    ps_enc.s_cmn.ec_prev_signal_type = ec_prev_signal_type_copy;
                }

                (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: *Side_Info_Indices, _: *Silk_Nsq_State, _: *Int8, _: *float32)) (cast(*void) silk_nsq_wrapper_flp))(
                    ps_enc,
                    *s_enc_ctrl,
                    *ps_enc.s_cmn.indices,
                    *ps_enc.s_cmn.s_nsq,
                    ps_enc.s_cmn.pulses.data,
                    x_frame
                );

                if iter == max_iter && found_lower == 0 {
                    copy_memory(*s_range_enc_copy2, ps_range_enc, size_of(Ec_Enc));
                }

                silk_encode_indices(*ps_enc.s_cmn, ps_range_enc, ps_enc.s_cmn.n_frames_encoded, 0, cond_coding);

                silk_encode_pulses(
                    ps_range_enc,
                    cast,no_check(s32) ps_enc.s_cmn.indices.signal_type,
                    cast,no_check(s32) ps_enc.s_cmn.indices.quant_offset_type,
                    ps_enc.s_cmn.pulses.data,
                    ps_enc.s_cmn.frame_length
                );

                n_bits = ec_tell_in_encode_frame_flp(ps_range_enc);

                if iter == max_iter && found_lower == 0 && n_bits > max_bits {
                    copy_memory(ps_range_enc, *s_range_enc_copy2, size_of(Ec_Enc));

                    ps_enc.s_shape.last_gain_index = s_enc_ctrl.last_gain_index_prev;
                    i = 0;
                    while i < ps_enc.s_cmn.nb_subfr {
                        ps_enc.s_cmn.indices.gains_indices[i] = 4;
                        i += 1;
                    }
                    if cond_coding != 2 {
                        ps_enc.s_cmn.indices.gains_indices[0] = s_enc_ctrl.last_gain_index_prev;
                    }
                    ps_enc.s_cmn.ec_prev_lag_index = ec_prev_lag_index_copy;
                    ps_enc.s_cmn.ec_prev_signal_type = ec_prev_signal_type_copy;

                    i = 0;
                    while i < ps_enc.s_cmn.frame_length {
                        ps_enc.s_cmn.pulses[i] = 0;
                        i += 1;
                    }

                    silk_encode_indices(*ps_enc.s_cmn, ps_range_enc, ps_enc.s_cmn.n_frames_encoded, 0, cond_coding);

                    silk_encode_pulses(
                        ps_range_enc,
                        cast,no_check(s32) ps_enc.s_cmn.indices.signal_type,
                        cast,no_check(s32) ps_enc.s_cmn.indices.quant_offset_type,
                        ps_enc.s_cmn.pulses.data,
                        ps_enc.s_cmn.frame_length
                    );

                    n_bits = ec_tell_in_encode_frame_flp(ps_range_enc);
                }

                if use_cbr == 0 && iter == 0 && n_bits <= max_bits {
                    break;
                }
            }

            if iter == max_iter {
                if found_lower != 0 && (gains_id == gains_id_lower || n_bits > max_bits) {
                    copy_memory(ps_range_enc, *s_range_enc_copy2, size_of(Ec_Enc));
                    (s_range_enc_copy2.offs <= 1275);
                    copy_memory(ps_range_enc.buf, ec_buf_copy, cast,no_check(u64) s_range_enc_copy2.offs);
                    copy_memory(*ps_enc.s_cmn.s_nsq, *s_nsq_copy[1], size_of(Silk_Nsq_State));
                    ps_enc.s_shape.last_gain_index = last_gain_index_copy2;
                }
                break;
            }

            if n_bits > max_bits {
                if found_lower == 0 && iter >= 2 {
                    s_enc_ctrl.lambda =
                        ifx c_transpiler_float_greater((s_enc_ctrl.lambda * 1.5), 1.5) then s_enc_ctrl.lambda *
                            1.5 else 1.5;

                    ps_enc.s_cmn.indices.quant_offset_type = 0;
                    found_upper = 0;
                    gains_id_upper = -1;
                } else {
                    found_upper = 1;
                    n_bits_upper = n_bits;
                    gain_mult_upper = cast,no_check(Int32) gain_mult_q8;
                    gains_id_upper = gains_id;
                }
            } else if n_bits < max_bits - bits_margin {
                found_lower = 1;
                n_bits_lower = n_bits;
                gain_mult_lower = cast,no_check(Int32) gain_mult_q8;
                if gains_id != gains_id_lower {
                    gains_id_lower = gains_id;

                    copy_memory(*s_range_enc_copy2, ps_range_enc, size_of(Ec_Enc));
                    (ps_range_enc.offs <= 1275);
                    copy_memory(ec_buf_copy, ps_range_enc.buf, cast,no_check(u64) ps_range_enc.offs);
                    copy_memory(*s_nsq_copy[1], *ps_enc.s_cmn.s_nsq, size_of(Silk_Nsq_State));
                    last_gain_index_copy2 = ps_enc.s_shape.last_gain_index;
                }
            } else {
                break;
            }

            if found_lower == 0 && n_bits > max_bits {
                j: s32 = ---;
                i = 0;
                while i < ps_enc.s_cmn.nb_subfr {
                    sum: s32 = 0;
                    j = i * ps_enc.s_cmn.subfr_length;
                    while j < (i + 1) * ps_enc.s_cmn.subfr_length {
                        sum += absolute_value(cast,no_check(s32) ps_enc.s_cmn.pulses[j]);
                        j += 1;
                    }
                    if iter == 0 || sum < best_sum[i] && gain_lock[i] == 0 {
                        best_sum[i] = sum;
                        best_gain_mult[i] = gain_mult_q8;
                    } else {
                        gain_lock[i] = 1;
                    }
                    i += 1;
                }
            }
            if found_lower & found_upper == 0 {
                if n_bits > max_bits {
                    gain_mult_q8 =
                        cast,no_check(Int16) silk_min_32_in_encode_frame_flp(
                            1024,
                            (cast(s32) gain_mult_q8) * 3 / 2
                        );
                } else {
                    gain_mult_q8 =
                        cast,no_check(Int16) silk_max_32_in_encode_frame_flp(
                            64,
                            (cast(s32) gain_mult_q8) * 4 / 5
                        );
                }
            } else {
                gain_mult_q8 =
                    cast,no_check(Int16) (gain_mult_lower +
                        (gain_mult_upper - gain_mult_lower) * (max_bits - n_bits_lower) / (n_bits_upper - n_bits_lower));

                if cast,no_check(s32) gain_mult_q8 > gain_mult_lower + (gain_mult_upper - gain_mult_lower) >> 2 {
                    gain_mult_q8 = cast,no_check(Int16) (gain_mult_lower + (gain_mult_upper - gain_mult_lower) >> 2);
                } else if cast,no_check(s32) gain_mult_q8 < gain_mult_upper - (gain_mult_upper - gain_mult_lower) >> 2 {
                    gain_mult_q8 = cast,no_check(Int16) (gain_mult_upper - (gain_mult_upper - gain_mult_lower) >> 2);
                }
            }

            i = 0;
            while i < ps_enc.s_cmn.nb_subfr {
                tmp: Int16 = ifx gain_lock[i] != 0
                    then best_gain_mult[i]
                    else gain_mult_q8;
                p_gains_q16[i] =
                    cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 8 > (cast(s32) 0x7fffffff) >> 8 then (ifx cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) * cast,no_check(Int64) tmp) >> 16) > (cast(Int32) -2147483648) >> 8 then (cast(Int32) -2147483648) >> 8 else (ifx cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) * cast,no_check(Int64) tmp) >> 16) < (cast(s32) 0x7fffffff) >> 8 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 8)) else cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) * cast,no_check(Int64) tmp) >> 16))) else (ifx cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) *
                        cast,no_check(Int64) tmp) >> 16) > (cast(s32) 0x7fffffff) >> 8 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 8)) else (ifx cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) * cast,no_check(Int64) tmp) >> 16) < (cast(Int32) -2147483648) >> 8 then (cast(Int32) -2147483648) >> 8 else cast,no_check(Int32) (((cast(Int64) s_enc_ctrl.gains_unq_q16[i]) * cast,no_check(Int64) tmp) >> 16)))))) << 8);
                i += 1;
            }

            ps_enc.s_shape.last_gain_index = s_enc_ctrl.last_gain_index_prev;
            silk_gains_quant(
                ps_enc.s_cmn.indices.gains_indices.data,
                p_gains_q16.data,
                *ps_enc.s_shape.last_gain_index,
                cast(s32) (cond_coding == 2),
                ps_enc.s_cmn.nb_subfr
            );

            gains_id = silk_gains_id(ps_enc.s_cmn.indices.gains_indices.data, ps_enc.s_cmn.nb_subfr);

            i = 0;
            while i < ps_enc.s_cmn.nb_subfr {
                s_enc_ctrl.gains[i] = (cast,no_check(float32) p_gains_q16[i]) / 65536.0;
                i += 1;
            }
            iter += 1;
        }
    }

    move_memory(
        ps_enc.x_buf.data,
        ps_enc.x_buf.data + ps_enc.s_cmn.frame_length,
        cast,no_check(u64) (ps_enc.s_cmn.ltp_mem_length + 5 * ps_enc.s_cmn.fs_k_hz) * size_of(float32)
    );

    if ps_enc.s_cmn.prefill_flag != 0 {
        pn_bytes_out.* = 0;

        return ret;
    }

    ps_enc.s_cmn.prev_lag = s_enc_ctrl.pitch_l[ps_enc.s_cmn.nb_subfr - 1];
    ps_enc.s_cmn.prev_signal_type = ps_enc.s_cmn.indices.signal_type;

    ps_enc.s_cmn.first_frame_after_reset = 0;

    pn_bytes_out.* = (ec_tell_in_encode_frame_flp(ps_range_enc) + 7) >> 3;

    return ret;
}

silk_lbrr_encode_flp :: (
    ps_enc: *Silk_Encoder_State_FLP,
    ps_enc_ctrl: *Silk_Encoder_Control_FLP,
    xfw: *float32,
    cond_coding: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    k: s32 = ---;
    gains_q16: [4] Int32 = ---;
    temp_gains: [4] float32 = ---;
    ps_indices_lbrr := ps_enc.s_cmn.indices_lbrr.data + ps_enc.s_cmn.n_frames_encoded;
    s_nsq_lbrr: *Silk_Nsq_State = ---;

    if ps_enc.s_cmn.lbrr_enabled != 0 &&
        ps_enc.s_cmn.speech_activity_q8 > cast,no_check(Int32) (cast(float64) 77.30000305175781) {
        s_nsq_lbrr =
            cast(*Silk_Nsq_State) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Silk_Nsq_State))) *
                1)));

        ps_enc.s_cmn.lbrr_flags[ps_enc.s_cmn.n_frames_encoded] = 1;

        copy_memory(*s_nsq_lbrr[0], *ps_enc.s_cmn.s_nsq, size_of(Silk_Nsq_State));
        copy_memory(ps_indices_lbrr, *ps_enc.s_cmn.indices, size_of(Side_Info_Indices));

        copy_memory(
            temp_gains.data,
            ps_enc_ctrl.gains.data,
            cast,no_check(u64) ps_enc.s_cmn.nb_subfr * size_of(float32)
        );

        if ps_enc.s_cmn.n_frames_encoded == 0 || ps_enc.s_cmn.lbrr_flags[ps_enc.s_cmn.n_frames_encoded - 1] == 0 {
            ps_enc.s_cmn.lbr_rprev_last_gain_index = ps_enc.s_shape.last_gain_index;

            ps_indices_lbrr.gains_indices[0] = cast,no_check(Int8) ((cast,no_check(s32) ps_indices_lbrr.gains_indices[0]) + ps_enc.s_cmn.lbrr_gain_increases);
            ps_indices_lbrr.gains_indices[0] =
                cast,no_check(Int8) silk_min_int_in_encode_frame_flp(
                    cast,no_check(s32) ps_indices_lbrr.gains_indices[0],
                    cast,no_check(s32) (64 - 1)
                );
        }

        silk_gains_dequant(
            gains_q16.data,
            ps_indices_lbrr.gains_indices.data,
            *ps_enc.s_cmn.lbr_rprev_last_gain_index,
            cast(s32) (cond_coding == 2),
            ps_enc.s_cmn.nb_subfr
        );

        k = 0;
        while k < ps_enc.s_cmn.nb_subfr {
            ps_enc_ctrl.gains[k] = (cast,no_check(float32) gains_q16[k]) * cast(float32) 0.0000152587890625;
            k += 1;
        }

        (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Encoder_Control_FLP, _: *Side_Info_Indices, _: *Silk_Nsq_State, _: *Int8, _: *float32)) (cast(*void) silk_nsq_wrapper_flp))(
            ps_enc,
            ps_enc_ctrl,
            ps_indices_lbrr,
            *s_nsq_lbrr[0],
            ps_enc.s_cmn.pulses_lbrr[ps_enc.s_cmn.n_frames_encoded].data,
            xfw
        );

        copy_memory(
            ps_enc_ctrl.gains.data,
            temp_gains.data,
            cast,no_check(u64) ps_enc.s_cmn.nb_subfr * size_of(float32)
        );
    }
}

false__in_encode_frame_flp :: () -> s32 {
    return 0;
}

Silk_Encoder_Control_FLP :: struct {
    gains: [4] float32;
    pred_coef: [2] [16] float32;
    ltp_coef: [20] float32;
    ltp_scale: float32;
    pitch_l: [4] s32;
    ar: [96] float32;
    lf_ma_shp: [4] float32;
    lf_ar_shp: [4] float32;
    tilt: [4] float32;
    harm_shape_gain: [4] float32;
    lambda: float32;
    input_quality: float32;
    coding_quality: float32;
    pred_gain: float32;
    lt_pred_cod_gain: float32;
    res_nrg: [4] float32;
    gains_unq_q16: [4] Int32;
    last_gain_index_prev: Int8;
}

