NSQ_Del_Dec_Struct :: struct {
    s_lpc_q14: [96] Int32;
    rand_state: [40] Int32;
    q_q10: [40] Int32;
    xq_q14: [40] Int32;
    pred_q15: [40] Int32;
    shape_q14: [40] Int32;
    s_ar2_q14: [24] Int32;
    lf_ar_q14: Int32;
    diff_q14: Int32;
    seed: Int32;
    seed_init: Int32;
    rd_q10: Int32;
}

NSQ_Sample_Struct :: struct {
    q_q10: Int32;
    rd_q10: Int32;
    xq_q14: Int32;
    lf_ar_q14: Int32;
    diff_q14: Int32;
    s_ltp_shp_q14: Int32;
    lpc_exc_q14: Int32;
}

NSQ_Sample_Pair :: [2] NSQ_Sample_Struct;

silk_clz16_in_nsq_del_dec :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nsq_del_dec :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nsq_del_dec :: () -> s32 {
    return 0;
}

silk_ror32_in_nsq_del_dec :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nsq_del_dec :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nsq_del_dec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nsq_del_dec :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nsq_del_dec :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nsq_del_dec :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nsq_del_dec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nsq_del_dec :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nsq_del_dec :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nsq_del_dec :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nsq_del_dec(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nsq_del_dec(in_upper);
    }
}

silk_clz_frac_in_nsq_del_dec :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nsq_del_dec(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nsq_del_dec(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nsq_del_dec :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nsq_del_dec(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nsq_del_dec :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nsq_del_dec((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nsq_del_dec((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nsq_del_dec :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nsq_del_dec((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nsq_del_dec :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nsq_del_dec :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nsq_del_dec :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nsq_del_dec :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nsq_del_dec :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nsq_del_dec :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_nsq_del_dec_c :: (
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
    i: s32 = ---;
    start_idx: s32 = ---;
    winner_ind: s32 = ---;
    last_smple_idx: s32 = ---;
    r_dmin_q10: Int32 = ---;

    ps_dd: *NSQ_Del_Dec_Struct = ---;

    lag := nsq.lag_prev;

    (nsq.prev_gain_q16 != 0);

    ps_del_dec :=
        cast(*NSQ_Del_Dec_Struct) c_transpiler_alloca(cast(u64) ((size_of(NSQ_Del_Dec_Struct) *
            cast,no_check(u64) ps_enc_c.n_states_delayed_decision)));
    fill_memory(ps_del_dec, 0, cast,no_check(u64) ps_enc_c.n_states_delayed_decision * size_of(NSQ_Del_Dec_Struct));
    k: s32 = 0;
    while k < ps_enc_c.n_states_delayed_decision {
        ps_dd = *ps_del_dec[k];
        ps_dd.seed = (k + cast(s32) ps_indices.seed) & 3;
        ps_dd.seed_init = ps_dd.seed;
        ps_dd.rd_q10 = 0;
        ps_dd.lf_ar_q14 = nsq.s_lf_ar_shp_q14;
        ps_dd.diff_q14 = nsq.s_diff_shp_q14;
        ps_dd.shape_q14[0] = nsq.s_ltp_shp_q14[ps_enc_c.ltp_mem_length - 1];
        copy_memory(ps_dd.s_lpc_q14.data, nsq.s_lpc_q14.data, cast(u64) 16 * size_of(Int32));
        copy_memory(ps_dd.s_ar2_q14.data, nsq.s_ar2_q14.data, nsq.s_ar2_q14.count * size_of(Int32));
        k += 1;
    }

    offset_q10 :=
        cast,no_check(s32) SILK_QUANTIZATION_OFFSETS_Q10[(cast(s32) ps_indices.signal_type) >> 1][ps_indices.quant_offset_type];
    smpl_buf_idx: s32 = 0;

    decision_delay := silk_min_int_in_nsq_del_dec(40, ps_enc_c.subfr_length);

    if ps_indices.signal_type == 2 {
        k = 0;
        while k < ps_enc_c.nb_subfr {
            decision_delay =
                silk_min_int_in_nsq_del_dec(
                    decision_delay,
                    (pitch_l[k] - cast,no_check(s32) ((5 / 2))) - 1
                );
            k += 1;
        }
    } else if lag > 0 {
        decision_delay = silk_min_int_in_nsq_del_dec(decision_delay, (lag - cast,no_check(s32) ((5 / 2))) - 1);
    }

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
    delayed_gain_q10 := cast(*Int32) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Int32))) * 40)));

    pxq := nsq.xq.data + ps_enc_c.ltp_mem_length;
    nsq.s_ltp_shp_buf_idx = ps_enc_c.ltp_mem_length;
    nsq.s_ltp_buf_idx = ps_enc_c.ltp_mem_length;
    subfr: s32 = 0;
    k = 0;
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
                if k == 2 {
                    r_dmin_q10 = ps_del_dec[0].rd_q10;
                    winner_ind = 0;
                    i = 1;
                    while i < ps_enc_c.n_states_delayed_decision {
                        if ps_del_dec[i].rd_q10 < r_dmin_q10 {
                            r_dmin_q10 = ps_del_dec[i].rd_q10;
                            winner_ind = i;
                        }
                        i += 1;
                    }
                    i = 0;
                    while i < ps_enc_c.n_states_delayed_decision {
                        if i != winner_ind {
                            ps_del_dec[i].rd_q10 = cast,no_check(Int32) (ps_del_dec[i].rd_q10 + ((cast(s32) 0x7fffffff) >> 4));
                            (ps_del_dec[i].rd_q10 >= 0);
                        }
                        i += 1;
                    }

                    ps_dd = *ps_del_dec[winner_ind];
                    last_smple_idx = smpl_buf_idx + decision_delay;
                    i = 0;
                    while i < decision_delay {
                        last_smple_idx = (last_smple_idx - 1) % 40;
                        if last_smple_idx < 0 {
                            last_smple_idx += 40;
                        }
                        pulses[i - decision_delay] =
                            cast,no_check(Int8) ((ifx 10 == 1 then ps_dd.q_q10[last_smple_idx] >> 1 +
                                ps_dd.q_q10[last_smple_idx] & 1 else (ps_dd.q_q10[last_smple_idx] >> (((10 - 1)) & 31) + 1) >> 1));
                        pxq[i - decision_delay] =
                            cast,no_check(Int16) ((ifx (ifx 14 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> 1) +
                                (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 14 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 14 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gains_q16[1]) >> 16)) >> (((14 - 1)) & 31)) + 1) >> 1))));
                        nsq.s_ltp_shp_q14[nsq.s_ltp_shp_buf_idx - decision_delay + i] = ps_dd.shape_q14[last_smple_idx];
                        i += 1;
                    }

                    subfr = 0;
                }

                start_idx = ps_enc_c.ltp_mem_length - lag - ps_enc_c.predict_lpc_order - cast,no_check(s32) ((5 / 2));

                silk_lpc_analysis_filter(
                    *s_ltp[start_idx],
                    nsq.xq.data + start_idx + k * ps_enc_c.subfr_length,
                    a_q12,
                    ps_enc_c.ltp_mem_length - start_idx,
                    ps_enc_c.predict_lpc_order,
                    ps_enc_c.arch
                );

                nsq.s_ltp_buf_idx = ps_enc_c.ltp_mem_length;
                nsq.rewhite_flag = 1;
            }
        }

        silk_nsq_del_dec_scale_states(
            ps_enc_c,
            nsq,
            ps_del_dec,
            x16,
            x_sc_q10,
            s_ltp,
            s_ltp_q15,
            k,
            ps_enc_c.n_states_delayed_decision,
            LTP_SCALE_Q14,
            gains_q16,
            pitch_l,
            cast,no_check(s32) ps_indices.signal_type,
            decision_delay
        );

        silk_noise_shape_quantizer_del_dec(
            nsq,
            ps_del_dec,
            cast,no_check(s32) ps_indices.signal_type,
            x_sc_q10,
            pulses,
            pxq,
            s_ltp_q15,
            delayed_gain_q10,
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
            c_transpiler_post_increment(*(subfr)),
            ps_enc_c.shaping_lpc_order,
            ps_enc_c.predict_lpc_order,
            ps_enc_c.warping_q16,
            ps_enc_c.n_states_delayed_decision,
            *smpl_buf_idx,
            decision_delay,
            ps_enc_c.arch
        );

        x16 += ps_enc_c.subfr_length;
        pulses += ps_enc_c.subfr_length;
        pxq += ps_enc_c.subfr_length;
        k += 1;
    }

    r_dmin_q10 = ps_del_dec[0].rd_q10;
    winner_ind = 0;
    k = 1;
    while k < ps_enc_c.n_states_delayed_decision {
        if ps_del_dec[k].rd_q10 < r_dmin_q10 {
            r_dmin_q10 = ps_del_dec[k].rd_q10;
            winner_ind = k;
        }
        k += 1;
    }

    ps_dd = *ps_del_dec[winner_ind];
    ps_indices.seed = cast,no_check(Int8) ps_dd.seed_init;
    last_smple_idx = smpl_buf_idx + decision_delay;
    gain_q10 := gains_q16[ps_enc_c.nb_subfr - 1] >> 6;
    i = 0;
    while i < decision_delay {
        last_smple_idx = (last_smple_idx - 1) % 40;
        if last_smple_idx < 0 {
            last_smple_idx += 40;
        }

        pulses[i - decision_delay] =
            cast,no_check(Int8) ((ifx 10 == 1 then ps_dd.q_q10[last_smple_idx] >> 1 +
                ps_dd.q_q10[last_smple_idx] & 1 else (ps_dd.q_q10[last_smple_idx] >> (((10 - 1)) & 31) + 1) >> 1));
        pxq[i - decision_delay] =
            cast,no_check(Int16) ((ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> 1) +
                (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))));
        nsq.s_ltp_shp_q14[nsq.s_ltp_shp_buf_idx - decision_delay + i] = ps_dd.shape_q14[last_smple_idx];
        i += 1;
    }
    copy_memory(nsq.s_lpc_q14.data, ps_dd.s_lpc_q14.data + ps_enc_c.subfr_length, cast(u64) 16 * size_of(Int32));
    copy_memory(nsq.s_ar2_q14.data, ps_dd.s_ar2_q14.data, ps_dd.s_ar2_q14.count * size_of(Int32));

    nsq.s_lf_ar_shp_q14 = ps_dd.lf_ar_q14;
    nsq.s_diff_shp_q14 = ps_dd.diff_q14;
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

silk_noise_shape_quantizer_del_dec :: (
    nsq: *Silk_Nsq_State,
    ps_del_dec: *NSQ_Del_Dec_Struct,
    signal_type: s32,
    x_q10: *Int32,
    pulses: *Int8,
    xq: *Int16,
    s_ltp_q15: *Int32,
    delayed_gain_q10: *Int32,
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
    subfr: s32,
    shaping_lpc_order: s32,
    predict_lpc_order: s32,
    warping_q16: s32,
    n_states_delayed_decision: s32,
    smpl_buf_idx: *s32,
    decision_delay: s32,
    arch: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    j: s32 = ---;
    k: s32 = ---;

    ltp_pred_q14, lpc_pred_q14, n_ar_q14, n_ltp_q14: Int32 = ---;
    n_lf_q14: Int32 = ---;
    r_q10: Int32 = ---;
    rr_q10: Int32 = ---;
    rd1_q10: Int32 = ---;
    rd2_q10: Int32 = ---;
    q1_q0: Int32 = ---;
    q1_q10: Int32 = ---;
    q2_q10: Int32 = ---;
    exc_q14: Int32 = ---;
    lpc_exc_q14: Int32 = ---;
    xq_q14: Int32 = ---;
    tmp1, tmp2, s_lf_ar_shp_q14: Int32 = ---;
    ps_lpc_q14: *Int32 = ---;

    ps_dd: *NSQ_Del_Dec_Struct = ---;
    ps_ss: *NSQ_Sample_Struct = ---;

    ps_sample_state :=
        cast(*NSQ_Sample_Pair) c_transpiler_alloca(cast(u64) (((2 * cast(u64) size_of(NSQ_Sample_Struct)) *
            cast,no_check(u64) n_states_delayed_decision)));

    shp_lag_ptr := nsq.s_ltp_shp_q14.data + nsq.s_ltp_shp_buf_idx - lag + cast,no_check(s32) ((3 / 2));
    pred_lag_ptr := *s_ltp_q15[nsq.s_ltp_buf_idx - lag + cast,no_check(s32) ((5 / 2))];
    gain_q10 := gain_q16 >> 6;

    if 0 < length {
        for i: 0..length - 1 {
            if signal_type == 2 {
                ltp_pred_q14 = 2;
                ltp_pred_q14 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q14) +
                        ((cast(Int64) pred_lag_ptr[0]) * cast,no_check(Int64) b_q14[0]) >> 16);
                ltp_pred_q14 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q14) +
                        ((cast(Int64) pred_lag_ptr[-1]) * cast,no_check(Int64) b_q14[1]) >> 16);
                ltp_pred_q14 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q14) +
                        ((cast(Int64) pred_lag_ptr[-2]) * cast,no_check(Int64) b_q14[2]) >> 16);
                ltp_pred_q14 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q14) +
                        ((cast(Int64) pred_lag_ptr[-3]) * cast,no_check(Int64) b_q14[3]) >> 16);
                ltp_pred_q14 =
                    cast,no_check(Int32) ((cast(Int64) ltp_pred_q14) +
                        ((cast(Int64) pred_lag_ptr[-4]) * cast,no_check(Int64) b_q14[4]) >> 16);
                ltp_pred_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) ltp_pred_q14) << 1);
                pred_lag_ptr += 1;
            } else {
                ltp_pred_q14 = 0;
            }

            if lag > 0 {
                n_ltp_q14 =
                    cast,no_check(Int32) (((cast(Int64) (ifx (((cast,no_check(Uint32) shp_lag_ptr[0]) + cast,no_check(Uint32) shp_lag_ptr[-2]) & 0x80000000) == 0 then (ifx (cast,no_check(u32) (shp_lag_ptr[0] & shp_lag_ptr[-2])) & 0x80000000 != 0 then -2147483648 else shp_lag_ptr[0] + shp_lag_ptr[-2]) else (ifx (cast,no_check(u32) (shp_lag_ptr[0] | shp_lag_ptr[-2])) & 0x80000000 == 0 then 0x7fffffff else shp_lag_ptr[0] + shp_lag_ptr[-2]))) *
                        cast,no_check(Int64) (cast,no_check(Int16) harm_shape_fir_packed_q14)) >> 16);
                n_ltp_q14 =
                    cast,no_check(Int32) ((cast(Int64) n_ltp_q14) +
                        ((cast(Int64) shp_lag_ptr[-1]) * (cast,no_check(Int64) harm_shape_fir_packed_q14) >> 16) >> 16);
                n_ltp_q14 = ltp_pred_q14 - cast,no_check(Int32) ((cast,no_check(Uint32) n_ltp_q14) << 2);
                shp_lag_ptr += 1;
            } else {
                n_ltp_q14 = 0;
            }

            k = 0;
            while k < n_states_delayed_decision {
                ps_dd = *ps_del_dec[k];

                ps_ss = ps_sample_state[k].data;

                ps_dd.seed = cast,no_check(Int32) (907633515 + (cast,no_check(Uint32) ps_dd.seed) * 196314165);

                ps_lpc_q14 = ps_dd.s_lpc_q14.data + (cast,no_check(s32) ((16 - 1))) + i;

                lpc_pred_q14 =
                    silk_noise_shape_quantizer_short_prediction_c_in_nsq_del_dec(
                        ps_lpc_q14,
                        a_q12,
                        predict_lpc_order
                    );
                lpc_pred_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) lpc_pred_q14) << 4);

                (shaping_lpc_order & 1 == 0);

                tmp2 =
                    cast,no_check(Int32) ((cast(Int64) ps_dd.diff_q14) +
                        ((cast(Int64) ps_dd.s_ar2_q14[0]) * cast,no_check(Int64) (cast,no_check(Int16) warping_q16)) >> 16);

                tmp1 =
                    cast,no_check(Int32) ((cast(Int64) ps_dd.s_ar2_q14[0]) +
                        ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) ps_dd.s_ar2_q14[1]) - cast,no_check(Uint32) tmp2))) * cast,no_check(Int64) (cast,no_check(Int16) warping_q16)) >> 16);
                ps_dd.s_ar2_q14[0] = tmp2;
                n_ar_q14 = shaping_lpc_order >> 1;
                n_ar_q14 =
                    cast,no_check(Int32) ((cast(Int64) n_ar_q14) +
                        ((cast(Int64) tmp2) * cast,no_check(Int64) ar_shp_q13[0]) >> 16);

                j = 2;
                while j < shaping_lpc_order {
                    tmp2 =
                        cast,no_check(Int32) ((cast(Int64) ps_dd.s_ar2_q14[j - 1]) +
                            ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) ps_dd.s_ar2_q14[j + 0]) - cast,no_check(Uint32) tmp1))) * cast,no_check(Int64) (cast,no_check(Int16) warping_q16)) >> 16);
                    ps_dd.s_ar2_q14[j - 1] = tmp1;
                    n_ar_q14 =
                        cast,no_check(Int32) ((cast(Int64) n_ar_q14) +
                            ((cast(Int64) tmp1) * cast,no_check(Int64) ar_shp_q13[j - 1]) >> 16);

                    tmp1 =
                        cast,no_check(Int32) ((cast(Int64) ps_dd.s_ar2_q14[j + 0]) +
                            ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) ps_dd.s_ar2_q14[j + 1]) - cast,no_check(Uint32) tmp2))) * cast,no_check(Int64) (cast,no_check(Int16) warping_q16)) >> 16);
                    ps_dd.s_ar2_q14[j + 0] = tmp2;
                    n_ar_q14 =
                        cast,no_check(Int32) ((cast(Int64) n_ar_q14) +
                            ((cast(Int64) tmp2) * cast,no_check(Int64) ar_shp_q13[j]) >> 16);
                    j += 2;
                }
                ps_dd.s_ar2_q14[shaping_lpc_order - 1] = tmp1;
                n_ar_q14 =
                    cast,no_check(Int32) ((cast(Int64) n_ar_q14) +
                        ((cast(Int64) tmp1) * cast,no_check(Int64) ar_shp_q13[shaping_lpc_order - 1]) >> 16);

                n_ar_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) n_ar_q14) << 1);
                n_ar_q14 =
                    cast,no_check(Int32) ((cast(Int64) n_ar_q14) +
                        ((cast(Int64) ps_dd.lf_ar_q14) * cast,no_check(Int64) (cast,no_check(Int16) tilt_q14)) >> 16);
                n_ar_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) n_ar_q14) << 2);

                n_lf_q14 =
                    cast,no_check(Int32) (((cast(Int64) ps_dd.shape_q14[smpl_buf_idx.*]) *
                        cast,no_check(Int64) (cast,no_check(Int16) lf_shp_q14)) >> 16);
                n_lf_q14 =
                    cast,no_check(Int32) ((cast(Int64) n_lf_q14) +
                        ((cast(Int64) ps_dd.lf_ar_q14) * (cast,no_check(Int64) lf_shp_q14) >> 16) >> 16);
                n_lf_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) n_lf_q14) << 2);

                tmp1 =
                    ifx (((cast,no_check(Uint32) n_ar_q14) + cast,no_check(Uint32) n_lf_q14) & 0x80000000) == 0 then (ifx (cast,no_check(u32) (n_ar_q14 & n_lf_q14)) & 0x80000000 != 0 then -2147483648 else n_ar_q14 +
                        n_lf_q14) else (ifx (cast,no_check(u32) (n_ar_q14 | n_lf_q14)) & 0x80000000 == 0 then 0x7fffffff else n_ar_q14 + n_lf_q14);
                tmp2 = cast,no_check(Int32) ((cast,no_check(Uint32) n_ltp_q14) + cast,no_check(Uint32) lpc_pred_q14);
                tmp1 =
                    ifx (((cast,no_check(Uint32) tmp2) - cast,no_check(Uint32) tmp1) & 0x80000000) == 0 then (ifx (cast,no_check(u32) tmp2) & ((cast,no_check(u32) tmp1) ^ 0x80000000) & 0x80000000 != 0 then -2147483648 else tmp2 -
                        tmp1) else (ifx ((cast,no_check(u32) tmp2) ^ 0x80000000 & cast,no_check(u32) tmp1) & 0x80000000 != 0 then 0x7fffffff else tmp2 - tmp1);
                tmp1 = ifx 4 == 1 then tmp1 >> 1 + tmp1 & 1 else (tmp1 >> (((4 - 1)) & 31) + 1) >> 1;

                r_q10 = x_q10[i] - tmp1;

                if ps_dd.seed < 0 {
                    r_q10 = -r_q10;
                }
                r_q10 =
                    ifx -((cast(s32) 31) << 10) > (cast(s32) 30) << 10 then (ifx r_q10 > -((cast(s32) 31) << 10) then cast,no_check(Int32) (-((cast(s32) 31) << 10)) else (ifx r_q10 < (cast(s32) 30) << 10 then cast,no_check(Int32) (((cast(s32) 30) << 10)) else r_q10)) else (ifx r_q10 > (cast(s32) 30) << 10 then cast,no_check(Int32) (((cast(s32) 30) << 10)) else (ifx r_q10 < -((cast(s32) 31) << 10) then cast,no_check(Int32) (-((cast(s32) 31) << 10)) else r_q10));

                q1_q10 = r_q10 - offset_q10;
                q1_q0 = q1_q10 >> 10;
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
                    rd1_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) q1_q10)) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                    rd2_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                } else if q1_q0 == 0 {
                    q1_q10 = offset_q10;
                    q2_q10 = q1_q10 + cast,no_check(Int32) ((1024 - 80));
                    rd1_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) q1_q10)) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                    rd2_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                } else if q1_q0 == -1 {
                    q2_q10 = offset_q10;
                    q1_q10 = q2_q10 - cast,no_check(Int32) ((1024 - 80));
                    rd1_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) (-q1_q10))) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                    rd2_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) q2_q10)) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                } else {
                    q1_q10 = (cast,no_check(Int32) ((cast,no_check(Uint32) q1_q0) << 10)) + 80;
                    q1_q10 = q1_q10 + offset_q10;
                    q2_q10 = q1_q10 + 1024;
                    rd1_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) (-q1_q10))) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                    rd2_q10 =
                        (cast,no_check(Int32) (cast,no_check(Int16) (-q2_q10))) *
                            cast,no_check(Int32) (cast,no_check(Int16) lambda_q10);
                }
                rr_q10 = r_q10 - q1_q10;
                rd1_q10 =
                    (rd1_q10 +
                        (cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) * cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) >> 10;
                rr_q10 = r_q10 - q2_q10;
                rd2_q10 =
                    (rd2_q10 +
                        (cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) * cast,no_check(Int32) (cast,no_check(Int16) rr_q10)) >> 10;

                if rd1_q10 < rd2_q10 {
                    ps_ss[0].rd_q10 = ps_dd.rd_q10 + rd1_q10;
                    ps_ss[1].rd_q10 = ps_dd.rd_q10 + rd2_q10;
                    ps_ss[0].q_q10 = q1_q10;
                    ps_ss[1].q_q10 = q2_q10;
                } else {
                    ps_ss[0].rd_q10 = ps_dd.rd_q10 + rd2_q10;
                    ps_ss[1].rd_q10 = ps_dd.rd_q10 + rd1_q10;
                    ps_ss[0].q_q10 = q2_q10;
                    ps_ss[1].q_q10 = q1_q10;
                }

                exc_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) ps_ss[0].q_q10) << 4);
                if ps_dd.seed < 0 {
                    exc_q14 = -exc_q14;
                }

                lpc_exc_q14 = exc_q14 + ltp_pred_q14;
                xq_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) lpc_exc_q14) +
                        cast,no_check(Uint32) lpc_pred_q14);

                ps_ss[0].diff_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) xq_q14) -
                        cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) x_q10[i]) << 4)));
                s_lf_ar_shp_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) ps_ss[0].diff_q14) -
                        cast,no_check(Uint32) n_ar_q14);
                ps_ss[0].s_ltp_shp_q14 =
                    ifx (((cast,no_check(Uint32) s_lf_ar_shp_q14) - cast,no_check(Uint32) n_lf_q14) & 0x80000000) == 0 then (ifx (cast,no_check(u32) s_lf_ar_shp_q14) & ((cast,no_check(u32) n_lf_q14) ^ 0x80000000) & 0x80000000 != 0 then -2147483648 else s_lf_ar_shp_q14 -
                        n_lf_q14) else (ifx ((cast,no_check(u32) s_lf_ar_shp_q14) ^ 0x80000000 & cast,no_check(u32) n_lf_q14) & 0x80000000 != 0 then 0x7fffffff else s_lf_ar_shp_q14 - n_lf_q14);
                ps_ss[0].lf_ar_q14 = s_lf_ar_shp_q14;
                ps_ss[0].lpc_exc_q14 = lpc_exc_q14;
                ps_ss[0].xq_q14 = xq_q14;

                exc_q14 = cast,no_check(Int32) ((cast,no_check(Uint32) ps_ss[1].q_q10) << 4);
                if ps_dd.seed < 0 {
                    exc_q14 = -exc_q14;
                }

                lpc_exc_q14 = exc_q14 + ltp_pred_q14;
                xq_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) lpc_exc_q14) +
                        cast,no_check(Uint32) lpc_pred_q14);

                ps_ss[1].diff_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) xq_q14) -
                        cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) x_q10[i]) << 4)));
                s_lf_ar_shp_q14 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) ps_ss[1].diff_q14) -
                        cast,no_check(Uint32) n_ar_q14);
                ps_ss[1].s_ltp_shp_q14 =
                    ifx (((cast,no_check(Uint32) s_lf_ar_shp_q14) - cast,no_check(Uint32) n_lf_q14) & 0x80000000) == 0 then (ifx (cast,no_check(u32) s_lf_ar_shp_q14) & ((cast,no_check(u32) n_lf_q14) ^ 0x80000000) & 0x80000000 != 0 then -2147483648 else s_lf_ar_shp_q14 -
                        n_lf_q14) else (ifx ((cast,no_check(u32) s_lf_ar_shp_q14) ^ 0x80000000 & cast,no_check(u32) n_lf_q14) & 0x80000000 != 0 then 0x7fffffff else s_lf_ar_shp_q14 - n_lf_q14);
                ps_ss[1].lf_ar_q14 = s_lf_ar_shp_q14;
                ps_ss[1].lpc_exc_q14 = lpc_exc_q14;
                ps_ss[1].xq_q14 = xq_q14;
                k += 1;
            }

            smpl_buf_idx.* = (smpl_buf_idx.* - 1) % 40;
            if smpl_buf_idx.* < 0 {
                smpl_buf_idx.* += 40;
            }
            last_smple_idx := (smpl_buf_idx.* + decision_delay) % 40;

            r_dmin_q10 := ps_sample_state[0][0].rd_q10;
            winner_ind: s32 = 0;
            k = 1;
            while k < n_states_delayed_decision {
                if ps_sample_state[k][0].rd_q10 < r_dmin_q10 {
                    r_dmin_q10 = ps_sample_state[k][0].rd_q10;
                    winner_ind = k;
                }
                k += 1;
            }

            winner_rand_state := ps_del_dec[winner_ind].rand_state[last_smple_idx];
            k = 0;
            while k < n_states_delayed_decision {
                if ps_del_dec[k].rand_state[last_smple_idx] != winner_rand_state {
                    ps_sample_state[k][0].rd_q10 =
                        ps_sample_state[k][0].rd_q10 +
                            cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4));
                    ps_sample_state[k][1].rd_q10 =
                        ps_sample_state[k][1].rd_q10 +
                            cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4));
                    (ps_sample_state[k][0].rd_q10 >= 0);
                }
                k += 1;
            }

            r_dmax_q10 := ps_sample_state[0][0].rd_q10;
            r_dmin_q10 = ps_sample_state[0][1].rd_q10;
            r_dmax_ind: s32 = 0;
            r_dmin_ind: s32 = 0;
            k = 1;
            while k < n_states_delayed_decision {
                if ps_sample_state[k][0].rd_q10 > r_dmax_q10 {
                    r_dmax_q10 = ps_sample_state[k][0].rd_q10;
                    r_dmax_ind = k;
                }

                if ps_sample_state[k][1].rd_q10 < r_dmin_q10 {
                    r_dmin_q10 = ps_sample_state[k][1].rd_q10;
                    r_dmin_ind = k;
                }
                k += 1;
            }

            if r_dmin_q10 < r_dmax_q10 {
                copy_memory(
                    (cast(*Int32) (*ps_del_dec[r_dmax_ind])) + i,
                    (cast(*Int32) (*ps_del_dec[r_dmin_ind])) + i,
                    size_of(NSQ_Del_Dec_Struct) - (cast,no_check(u64) i) * size_of(Int32)
                );
                copy_memory(
                    ps_sample_state[r_dmax_ind].data + 0,
                    ps_sample_state[r_dmin_ind].data + 1,
                    size_of(NSQ_Sample_Struct)
                );
            }

            ps_dd = *ps_del_dec[winner_ind];
            if subfr > 0 || i >= decision_delay {
                pulses[i - decision_delay] =
                    cast,no_check(Int8) ((ifx 10 == 1 then ps_dd.q_q10[last_smple_idx] >> 1 +
                        ps_dd.q_q10[last_smple_idx] & 1 else (ps_dd.q_q10[last_smple_idx] >> (((10 - 1)) & 31) + 1) >> 1));
                xq[i - decision_delay] =
                    cast,no_check(Int16) ((ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> 1) +
                        (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) ps_dd.xq_q14[last_smple_idx]) * cast(Int64) delayed_gain_q10[last_smple_idx]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))));
                nsq.s_ltp_shp_q14[nsq.s_ltp_shp_buf_idx - decision_delay] = ps_dd.shape_q14[last_smple_idx];
                s_ltp_q15[nsq.s_ltp_buf_idx - decision_delay] = ps_dd.pred_q15[last_smple_idx];
            }
            nsq.s_ltp_shp_buf_idx += 1;
            nsq.s_ltp_buf_idx += 1;

            k = 0;
            while k < n_states_delayed_decision {
                ps_dd = *ps_del_dec[k];
                ps_ss = ps_sample_state[k].data + 0;
                ps_dd.lf_ar_q14 = ps_ss.lf_ar_q14;
                ps_dd.diff_q14 = ps_ss.diff_q14;
                ps_dd.s_lpc_q14[16 + i] = ps_ss.xq_q14;
                ps_dd.xq_q14[smpl_buf_idx.*] = ps_ss.xq_q14;
                ps_dd.q_q10[smpl_buf_idx.*] = ps_ss.q_q10;
                ps_dd.pred_q15[smpl_buf_idx.*] = cast,no_check(Int32) ((cast,no_check(Uint32) ps_ss.lpc_exc_q14) << 1);
                ps_dd.shape_q14[smpl_buf_idx.*] = ps_ss.s_ltp_shp_q14;
                ps_dd.seed =
                    cast,no_check(Int32) ((cast,no_check(Uint32) ps_dd.seed) +
                        cast,no_check(Uint32) ((ifx 10 == 1 then ps_ss.q_q10 >> 1 + ps_ss.q_q10 & 1 else (ps_ss.q_q10 >> (((10 - 1)) & 31) + 1) >> 1)));
                ps_dd.rand_state[smpl_buf_idx.*] = ps_dd.seed;
                ps_dd.rd_q10 = ps_ss.rd_q10;
                k += 1;
            }
            delayed_gain_q10[smpl_buf_idx.*] = gain_q10;
        }
    }

    k = 0;
    while k < n_states_delayed_decision {
        ps_dd = *ps_del_dec[k];
        copy_memory(ps_dd.s_lpc_q14.data, ps_dd.s_lpc_q14.data + length, cast(u64) 16 * size_of(Int32));
        k += 1;
    }
}

silk_noise_shape_quantizer_short_prediction_c_in_nsq_del_dec :: (buf32: *Int32, coef16: *Int16, order: s32) -> Int32 {
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

silk_nsq_del_dec_scale_states :: (
    ps_enc_c: *Silk_Encoder_State,
    nsq: *Silk_Nsq_State,
    ps_del_dec: *NSQ_Del_Dec_Struct,
    x16: *Int16,
    x_sc_q10: *Int32,
    s_ltp: *Int16,
    s_ltp_q15: *Int32,
    subfr: s32,
    n_states_delayed_decision: s32,
    LTP_SCALE_Q14: s32,
    gains_q16: *Int32,
    pitch_l: *s32,
    SIGNAL_TYPE: s32,
    DECISION_DELAY_: s32
) {
    gain_adj_q16: Int32 = ---;
    ps_dd: *NSQ_Del_Dec_Struct = ---;

    lag := pitch_l[subfr];
    inv_gain_q31 := silk_inverse32_var_q_in_nsq_del_dec((ifx gains_q16[subfr] > 1 then gains_q16[subfr] else 1), 47);

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
        gain_adj_q16 = silk_div32_var_q_in_nsq_del_dec(nsq.prev_gain_q16, gains_q16[subfr], 16);

        i = nsq.s_ltp_shp_buf_idx - ps_enc_c.ltp_mem_length;
        while i < nsq.s_ltp_shp_buf_idx {
            nsq.s_ltp_shp_q14[i] =
                cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                    cast(Int64) nsq.s_ltp_shp_q14[i]) >> 16);
            i += 1;
        }

        if SIGNAL_TYPE == 2 && nsq.rewhite_flag == 0 {
            i = nsq.s_ltp_buf_idx - lag - cast,no_check(s32) ((5 / 2));
            while i < nsq.s_ltp_buf_idx - DECISION_DELAY_ {
                s_ltp_q15[i] =
                    cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                        cast(Int64) s_ltp_q15[i]) >> 16);
                i += 1;
            }
        }

        if 0 < n_states_delayed_decision {
            for k: 0..n_states_delayed_decision - 1 {
                ps_dd = *ps_del_dec[k];

                ps_dd.lf_ar_q14 =
                    cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                        cast(Int64) ps_dd.lf_ar_q14) >> 16);
                ps_dd.diff_q14 =
                    cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                        cast(Int64) ps_dd.diff_q14) >> 16);

                i = 0;
                while i < 16 {
                    ps_dd.s_lpc_q14[i] =
                        cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                            cast(Int64) ps_dd.s_lpc_q14[i]) >> 16);
                    i += 1;
                }
                i = 0;
                while i < 24 {
                    ps_dd.s_ar2_q14[i] =
                        cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                            cast(Int64) ps_dd.s_ar2_q14[i]) >> 16);
                    i += 1;
                }
                i = 0;
                while i < 40 {
                    ps_dd.pred_q15[i] =
                        cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                            cast(Int64) ps_dd.pred_q15[i]) >> 16);
                    ps_dd.shape_q14[i] =
                        cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                            cast(Int64) ps_dd.shape_q14[i]) >> 16);
                    i += 1;
                }
            }
        }

        nsq.prev_gain_q16 = gains_q16[subfr];
    }
}

false__in_nsq_del_dec :: () -> s32 {
    return 0;
}

silk_nsq_noise_shape_feedback_loop_c_in_nsq_del_dec :: (
    data0: *Int32,
    data1: *Int32,
    coef: *Int16,
    order: s32
) -> Int32 {
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

