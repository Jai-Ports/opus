// Generated directly from C by cpp_transpiler.
silk_clz16_in_nsq :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nsq :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nsq :: () -> s32 {
    return 0;
}

silk_ror32_in_nsq :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nsq :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nsq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nsq :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nsq :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nsq :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nsq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nsq :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nsq :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nsq :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nsq(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nsq(in_upper);
    }
}

silk_clz_frac_in_nsq :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nsq(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nsq(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nsq :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nsq(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nsq :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nsq((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nsq((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nsq :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nsq((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nsq :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nsq :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nsq :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nsq :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nsq :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nsq :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_nsq_c :: (
    ps_enc_c: *Silk_Encoder_State,
    nsq: *Silk_Nsq_State,
    ps_indices: *Side_Info_Indices,
    x16: *Int16,
    pulses: *Int8,
    pred_coef_q12: *Int16,
    ltp_coef_q14: *Int16,
    ar_q13: *Int16,
    harm_shape_gain_q14: *s32,
    tilt_q14: *s32,
    lf_shp_q14: *Int32,
    gains_q16: *Int32,
    pitch_l: *s32,
    LAMBDA_Q10: s32,
    LTP_SCALE_Q14: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    start_idx: s32 = ---;

    nsq.rand_seed = cast,no_check(Int32) ps_indices.seed;

    lag := nsq.lag_prev;

    (nsq.prev_gain_q16 != 0);

    offset_q10 :=
        cast,no_check(s32) SILK_QUANTIZATION_OFFSETS_Q10[(cast(s32) ps_indices.signal_type) >> 1][ps_indices.quant_offset_type];

    lsf_interpolation_flag: s32 = ifx ps_indices.nlsf_interp_coef_q2 == 4
        then cast(s32) 0
        else 1;

    s_ltp_q15 :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) (ps_enc_c.ltp_mem_length + ps_enc_c.frame_length))));
    s_ltp :=
        cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
            cast,no_check(u64) (ps_enc_c.ltp_mem_length + ps_enc_c.frame_length))));
    x_sc_q10 :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) ps_enc_c.subfr_length)));

    nsq.s_ltp_shp_buf_idx = ps_enc_c.ltp_mem_length;
    nsq.s_ltp_buf_idx = ps_enc_c.ltp_mem_length;
    pxq := nsq.xq.data + ps_enc_c.ltp_mem_length;
    k: s32 = 0;
    while k < ps_enc_c.nb_subfr {
        a_q12 := *pred_coef_q12[k >> 1 | (1 - lsf_interpolation_flag) * 16];
        b_q14 := *ltp_coef_q14[k * 5];
        ar_shp_q13 := *ar_q13[k * 24];

        (harm_shape_gain_q14[k] >= 0);
        harm_shape_fir_packed_q14 := harm_shape_gain_q14[k] >> 2;
        harm_shape_fir_packed_q14 |= cast,no_check(Int32) ((cast,no_check(Uint32) (harm_shape_gain_q14[k] >> 1)) << 16);

        nsq.rewhite_flag = 0;
        if ps_indices.signal_type == 2 {
            lag = pitch_l[k];

            if (k & (3 - cast,no_check(Int32) ((cast,no_check(Uint32) lsf_interpolation_flag) << 1))) == 0 {
                start_idx = ps_enc_c.ltp_mem_length - lag - ps_enc_c.predict_lpc_order - cast,no_check(s32) ((5 / 2));

                silk_lpc_analysis_filter(
                    *s_ltp[start_idx],
                    nsq.xq.data + start_idx + k * ps_enc_c.subfr_length,
                    a_q12,
                    ps_enc_c.ltp_mem_length - start_idx,
                    ps_enc_c.predict_lpc_order,
                    ps_enc_c.arch
                );

                nsq.rewhite_flag = 1;
                nsq.s_ltp_buf_idx = ps_enc_c.ltp_mem_length;
            }
        }

        silk_nsq_scale_states(
            ps_enc_c,
            nsq,
            x16,
            x_sc_q10,
            s_ltp,
            s_ltp_q15,
            k,
            LTP_SCALE_Q14,
            gains_q16,
            pitch_l,
            cast,no_check(s32) ps_indices.signal_type
        );

        silk_noise_shape_quantizer(
            nsq,
            cast,no_check(s32) ps_indices.signal_type,
            x_sc_q10,
            pulses,
            pxq,
            s_ltp_q15,
            a_q12,
            b_q14,
            ar_shp_q13,
            lag,
            harm_shape_fir_packed_q14,
            tilt_q14[k],
            lf_shp_q14[k],
            gains_q16[k],
            LAMBDA_Q10,
            offset_q10,
            ps_enc_c.subfr_length,
            ps_enc_c.shaping_lpc_order,
            ps_enc_c.predict_lpc_order,
            ps_enc_c.arch
        );

        x16 += ps_enc_c.subfr_length;
        pulses += ps_enc_c.subfr_length;
        pxq += ps_enc_c.subfr_length;
        k += 1;
    }

    nsq.lag_prev = pitch_l[ps_enc_c.nb_subfr - 1];

    move_memory(
        nsq.xq.data,
        nsq.xq.data + ps_enc_c.frame_length,
        cast,no_check(u64) ps_enc_c.ltp_mem_length * size_of(Int16)
    );
    move_memory(
        nsq.s_ltp_shp_q14.data,
        nsq.s_ltp_shp_q14.data + ps_enc_c.frame_length,
        cast,no_check(u64) ps_enc_c.ltp_mem_length * size_of(Int32)
    );
}

silk_noise_shape_quantizer :: (
    nsq: *Silk_Nsq_State,
    signal_type: s32,
    x_sc_q10: *Int32,
    pulses: *Int8,
    xq: *Int16,
    s_ltp_q15: *Int32,
    a_q12: *Int16,
    b_q14: *Int16,
    ar_shp_q13: *Int16,
    lag: s32,
    harm_shape_fir_packed_q14: Int32,
    tilt_q14: s32,
    lf_shp_q14: Int32,
    gain_q16: Int32,
    lambda_q10: s32,
    offset_q10: s32,
    length: s32,
    shaping_lpc_order: s32,
    predict_lpc_order: s32,
    arch: s32
) {
    ltp_pred_q13: Int32 = ---;
    n_ltp_q13: Int32 = ---;
    q2_q10: Int32 = ---;
    rd1_q20: Int32 = ---;
    rd2_q20: Int32 = ---;
    tmp2: Int32 = ---;
    shp_lag_ptr: *Int32 = ---;

    shp_lag_ptr = nsq.s_ltp_shp_q14.data + nsq.s_ltp_shp_buf_idx - lag + cast,no_check(s32) ((3 / 2));
    pred_lag_ptr := *s_ltp_q15[nsq.s_ltp_buf_idx - lag + cast,no_check(s32) ((5 / 2))];
    gain_q10 := gain_q16 >> 6;

    ps_lpc_q14 := nsq.s_lpc_q14.data + 16 - 1;

    if 0 < length {
        for i: 0..length - 1 {
            nsq.rand_seed = cast,no_check(Int32) (907633515 + (cast,no_check(Uint32) nsq.rand_seed) * 196314165);

            lpc_pred_q10 := silk_noise_shape_quantizer_short_prediction_c(ps_lpc_q14, a_q12, predict_lpc_order);

            if signal_type == 2 {
                ltp_pred_q13 = 2;
                ltp_pred_q13 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q13) +
                        ((cast(Int64) pred_lag_ptr[0]) * cast,no_check(Int64) b_q14[0]) >> 16);
                ltp_pred_q13 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q13) +
                        ((cast(Int64) pred_lag_ptr[-1]) * cast,no_check(Int64) b_q14[1]) >> 16);
                ltp_pred_q13 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q13) +
                        ((cast(Int64) pred_lag_ptr[-2]) * cast,no_check(Int64) b_q14[2]) >> 16);
                ltp_pred_q13 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q13) +
                        ((cast(Int64) pred_lag_ptr[-3]) * cast,no_check(Int64) b_q14[3]) >> 16);
                ltp_pred_q13 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q13) +
                        ((cast(Int64) pred_lag_ptr[-4]) * cast,no_check(Int64) b_q14[4]) >> 16);
                pred_lag_ptr += 1;
            } else {
                ltp_pred_q13 = 0;
            }

            (shaping_lpc_order & 1 == 0);
            n_ar_q12 :=
                silk_nsq_noise_shape_feedback_loop_c(
                    *nsq.s_diff_shp_q14,
                    nsq.s_ar2_q14.data,
                    ar_shp_q13,
                    shaping_lpc_order
                );

            n_ar_q12 =
                cast,no_check(Int32) ((cast(Int64) n_ar_q12) +
                    ((cast(Int64) nsq.s_lf_ar_shp_q14) * cast,no_check(Int64) (cast,no_check(Int16) tilt_q14)) >> 16);

            n_lf_q12 :=
                cast,no_check(Int32) (((cast(Int64) nsq.s_ltp_shp_q14[nsq.s_ltp_shp_buf_idx - 1]) *
                    cast,no_check(Int64) (cast,no_check(Int16) lf_shp_q14)) >> 16);
            n_lf_q12 =
                cast,no_check(Int32) ((cast(Int64) n_lf_q12) +
                    ((cast(Int64) nsq.s_lf_ar_shp_q14) * (cast,no_check(Int64) lf_shp_q14) >> 16) >> 16);

            (lag > 0 || signal_type != 2);

            tmp1 :=
                cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) lpc_pred_q10) << 2))) -
                    cast,no_check(Uint32) n_ar_q12);
            tmp1 = cast,no_check(Int32) ((cast,no_check(Uint32) tmp1) - cast,no_check(Uint32) n_lf_q12);
            if lag > 0 {
                n_ltp_q13 =
                    cast,no_check(Int32) (((cast(Int64) (ifx (((cast,no_check(Uint32) shp_lag_ptr[0]) + cast,no_check(Uint32) shp_lag_ptr[-2]) & 0x80000000) == 0 then (ifx (cast,no_check(u32) (shp_lag_ptr[0] & shp_lag_ptr[-2])) & 0x80000000 != 0 then -2147483648 else shp_lag_ptr[0] + shp_lag_ptr[-2]) else (ifx (cast,no_check(u32) (shp_lag_ptr[0] | shp_lag_ptr[-2])) & 0x80000000 == 0 then 0x7fffffff else shp_lag_ptr[0] + shp_lag_ptr[-2]))) *
                        cast,no_check(Int64) (cast,no_check(Int16) harm_shape_fir_packed_q14)) >> 16);
                n_ltp_q13 =
                    cast,no_check(Int32) ((cast(Int64) n_ltp_q13) +
                        ((cast(Int64) shp_lag_ptr[-1]) * (cast,no_check(Int64) harm_shape_fir_packed_q14) >> 16) >> 16);
                n_ltp_q13 = cast,no_check(Int32) ((cast,no_check(Uint32) n_ltp_q13) << 1);
                shp_lag_ptr += 1;

                tmp2 = ltp_pred_q13 - n_ltp_q13;
                tmp1 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) tmp2) +
                        cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) tmp1) << 1)));
                tmp1 = ifx 3 == 1 then tmp1 >> 1 + tmp1 & 1 else (tmp1 >> (((3 - 1)) & 31) + 1) >> 1;
            } else {
                tmp1 = ifx 2 == 1 then tmp1 >> 1 + tmp1 & 1 else (tmp1 >> (((2 - 1)) & 31) + 1) >> 1;
            }

            r_q10 := x_sc_q10[i] - tmp1;

            if nsq.rand_seed < 0 {
                r_q10 = -r_q10;
            }
            r_q10 =
                ifx -((cast(s32) 31) << 10) > (cast(s32) 30) << 10 then (ifx r_q10 > -((cast(s32) 31) << 10) then cast,no_check(Int32) (-((cast(s32) 31) << 10)) else (ifx r_q10 < (cast(s32) 30) << 10 then cast,no_check(Int32) (((cast(s32) 30) << 10)) else r_q10)) else (ifx r_q10 > (cast(s32) 30) << 10 then cast,no_check(Int32) (((cast(s32) 30) << 10)) else (ifx r_q10 < -((cast(s32) 31) << 10) then cast,no_check(Int32) (-((cast(s32) 31) << 10)) else r_q10));

            q1_q10 := r_q10 - offset_q10;
            q1_q0 := q1_q10 >> 10;
            if lambda_q10 > 2048 {
                rdo_offset := lambda_q10 / 2 - 512;
                if q1_q10 > rdo_offset {
                    q1_q0 = (q1_q10 - rdo_offset) >> 10;
                } else if q1_q10 < -rdo_offset {
                    q1_q0 = (q1_q10 + rdo_offset) >> 10;
                } else if q1_q10 < 0 {
                    q1_q0 = -1;
                } else {
                    q1_q0 = 0;
                }
            }
            if q1_q0 > 0 {
                q1_q10 = (cast,no_check(Int32) ((cast,no_check(Uint32) q1_q0) << 10)) - 80;
                q1_q10 = q1_q10 + offset_q10;
                q2_q10 = q1_q10 + 1024;
                rd1_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) q1_q10)) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                rd2_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
            } else if q1_q0 == 0 {
                q1_q10 = offset_q10;
                q2_q10 = q1_q10 + cast,no_check(Int32) ((1024 - 80));
                rd1_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) q1_q10)) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                rd2_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
            } else if q1_q0 == -1 {
                q2_q10 = offset_q10;
                q1_q10 = q2_q10 - cast,no_check(Int32) ((1024 - 80));
                rd1_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) (-q1_q10))) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                rd2_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
            } else {
                q1_q10 = (cast,no_check(Int32) ((cast,no_check(Uint32) q1_q0) << 10)) + 80;
                q1_q10 = q1_q10 + offset_q10;
                q2_q10 = q1_q10 + 1024;
                rd1_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) (-q1_q10))) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                rd2_q20 =
                    (cast,no_check(Int32) (cast,no_check(Int16) (-q2_q10))) *
                        cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
            }
            rr_q10 := r_q10 - q1_q10;
            rd1_q20 =
                rd1_q20 +
                    (cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) * cast,no_check(Int32) (cast,no_check(Int16) rr_q10);
            rr_q10 = r_q10 - q2_q10;
            rd2_q20 =
                rd2_q20 +
                    (cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) * cast,no_check(Int32) (cast,no_check(Int16) rr_q10);

            if rd2_q20 < rd1_q20 {
                q1_q10 = q2_q10;
            }

            pulses[i] =
                cast,no_check(Int8) ((ifx 10 == 1 then q1_q10 >> 1 +
                    q1_q10 & 1 else (q1_q10 >> (((10 - 1)) & 31) + 1) >> 1));

            exc_q14 := cast,no_check(Int32) ((cast,no_check(Uint32) q1_q10) << 4);
            if nsq.rand_seed < 0 {
                exc_q14 = -exc_q14;
            }

            lpc_exc_q14 := exc_q14 + cast,no_check(Int32) ((cast,no_check(Uint32) ltp_pred_q13) << 1);
            xq_q14 :=
                cast,no_check(Int32) ((cast,no_check(Uint32) lpc_exc_q14) +
                    cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) lpc_pred_q10) << 4)));

            xq[i] =
                cast,no_check(Int16) ((ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> 1) +
                    (cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) xq_q14) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))));

            ps_lpc_q14 += 1;
            ps_lpc_q14.* = xq_q14;
            nsq.s_diff_shp_q14 =
                cast,no_check(Int32) ((cast,no_check(Uint32) xq_q14) -
                    cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) x_sc_q10[i]) << 4)));
            s_lf_ar_shp_q14 :=
                cast,no_check(Int32) ((cast,no_check(Uint32) nsq.s_diff_shp_q14) -
                    cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) n_ar_q12) << 2)));
            nsq.s_lf_ar_shp_q14 = s_lf_ar_shp_q14;

            nsq.s_ltp_shp_q14[nsq.s_ltp_shp_buf_idx] =
                cast,no_check(Int32) ((cast,no_check(Uint32) s_lf_ar_shp_q14) -
                    cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) n_lf_q12) << 2)));
            s_ltp_q15[nsq.s_ltp_buf_idx] = cast,no_check(Int32) ((cast,no_check(Uint32) lpc_exc_q14) << 1);
            nsq.s_ltp_shp_buf_idx += 1;
            nsq.s_ltp_buf_idx += 1;

            nsq.rand_seed =
                cast,no_check(Int32) ((cast,no_check(Uint32) nsq.rand_seed) +
                    cast,no_check(Uint32) pulses[i]);
        }
    }

    copy_memory(nsq.s_lpc_q14.data, nsq.s_lpc_q14.data + length, cast(u64) 16 * size_of(Int32));
}

silk_nsq_noise_shape_feedback_loop_c :: (data0: *Int32, data1: *Int32, coef: *Int16, order: s32) -> Int32 {
    tmp2 := data0[0];
    tmp1 := data1[0];
    data1[0] = tmp2;

    out := order >> 1;
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) tmp2) * cast,no_check(Int64) coef[0]) >> 16);

    j: s32 = 2;
    while j < order {
        tmp2 = data1[j - 1];
        data1[j - 1] = tmp1;
        out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) tmp1) * cast,no_check(Int64) coef[j - 1]) >> 16);
        tmp1 = data1[j + 0];
        data1[j + 0] = tmp2;
        out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) tmp2) * cast,no_check(Int64) coef[j]) >> 16);
        j += 2;
    }
    data1[order - 1] = tmp1;
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) tmp1) * cast,no_check(Int64) coef[order - 1]) >> 16);

    out = cast,no_check(Int32) ((cast,no_check(Uint32) out) << 1);
    return out;
}

silk_noise_shape_quantizer_short_prediction_c :: (buf32: *Int32, coef16: *Int16, order: s32) -> Int32 {
    (order == 10 || order == 16);

    out := order >> 1;
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[0]) * cast,no_check(Int64) coef16[0]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-1]) * cast,no_check(Int64) coef16[1]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-2]) * cast,no_check(Int64) coef16[2]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-3]) * cast,no_check(Int64) coef16[3]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-4]) * cast,no_check(Int64) coef16[4]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-5]) * cast,no_check(Int64) coef16[5]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-6]) * cast,no_check(Int64) coef16[6]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-7]) * cast,no_check(Int64) coef16[7]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-8]) * cast,no_check(Int64) coef16[8]) >> 16);
    out = cast,no_check(Int32) ((cast(Int64) out) + ((cast(Int64) buf32[-9]) * cast,no_check(Int64) coef16[9]) >> 16);

    if order == 16 {
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-10]) * cast,no_check(Int64) coef16[10]) >> 16);
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-11]) * cast,no_check(Int64) coef16[11]) >> 16);
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-12]) * cast,no_check(Int64) coef16[12]) >> 16);
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-13]) * cast,no_check(Int64) coef16[13]) >> 16);
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-14]) * cast,no_check(Int64) coef16[14]) >> 16);
        out =
            cast,no_check(Int32) ((cast(Int64) out) +
                ((cast(Int64) buf32[-15]) * cast,no_check(Int64) coef16[15]) >> 16);
    }
    return out;
}

silk_nsq_scale_states :: (
    ps_enc_c: *Silk_Encoder_State,
    nsq: *Silk_Nsq_State,
    x16: *Int16,
    x_sc_q10: *Int32,
    s_ltp: *Int16,
    s_ltp_q15: *Int32,
    subfr: s32,
    LTP_SCALE_Q14: s32,
    gains_q16: *Int32,
    pitch_l: *s32,
    SIGNAL_TYPE: s32
) {
    gain_adj_q16: Int32 = ---;

    lag := pitch_l[subfr];
    inv_gain_q31 := silk_inverse32_var_q_in_nsq((ifx gains_q16[subfr] > 1 then gains_q16[subfr] else 1), 47);

    inv_gain_q26 :=
        (ifx 5 == 1 then inv_gain_q31 >> 1 +
            inv_gain_q31 & 1 else (inv_gain_q31 >> (((5 - 1)) & 31) + 1) >> 1);
    i: s32 = 0;
    while i < ps_enc_c.subfr_length {
        x_sc_q10[i] = cast,no_check(Int32) (((cast,no_check(Int64) x16[i]) * cast(Int64) inv_gain_q26) >> 16);
        i += 1;
    }

    if nsq.rewhite_flag != 0 {
        if subfr == 0 {
            inv_gain_q31 =
                cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast(Int64) inv_gain_q31) *
                    cast,no_check(Int64) (cast,no_check(Int16) LTP_SCALE_Q14)) >> 16))) << 2);
        }
        i = nsq.s_ltp_buf_idx - lag - cast,no_check(s32) ((5 / 2));
        while i < nsq.s_ltp_buf_idx {
            (i < (cast,no_check(s32) ((5 * 4))) * 16);
            s_ltp_q15[i] = cast,no_check(Int32) (((cast(Int64) inv_gain_q31) * cast,no_check(Int64) s_ltp[i]) >> 16);
            i += 1;
        }
    }

    if gains_q16[subfr] != nsq.prev_gain_q16 {
        gain_adj_q16 = silk_div32_var_q_in_nsq(nsq.prev_gain_q16, gains_q16[subfr], 16);

        i = nsq.s_ltp_shp_buf_idx - ps_enc_c.ltp_mem_length;
        while i < nsq.s_ltp_shp_buf_idx {
            nsq.s_ltp_shp_q14[i] =
                cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                    cast(Int64) nsq.s_ltp_shp_q14[i]) >> 16);
            i += 1;
        }

        if SIGNAL_TYPE == 2 && nsq.rewhite_flag == 0 {
            i = nsq.s_ltp_buf_idx - lag - cast,no_check(s32) ((5 / 2));
            while i < nsq.s_ltp_buf_idx {
                s_ltp_q15[i] =
                    cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                        cast(Int64) s_ltp_q15[i]) >> 16);
                i += 1;
            }
        }

        nsq.s_lf_ar_shp_q14 =
            cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                cast(Int64) nsq.s_lf_ar_shp_q14) >> 16);
        nsq.s_diff_shp_q14 =
            cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                cast(Int64) nsq.s_diff_shp_q14) >> 16);

        i = 0;
        while i < 16 {
            nsq.s_lpc_q14[i] =
                cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                    cast(Int64) nsq.s_lpc_q14[i]) >> 16);
            i += 1;
        }
        i = 0;
        while i < 24 {
            nsq.s_ar2_q14[i] =
                cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                    cast(Int64) nsq.s_ar2_q14[i]) >> 16);
            i += 1;
        }

        nsq.prev_gain_q16 = gains_q16[subfr];
    }
}

false__in_nsq :: () -> s32 {
    return 0;
}

