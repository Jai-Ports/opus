silk_clz16_in_decode_core :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decode_core :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decode_core :: () -> s32 {
    return 0;
}

silk_ror32_in_decode_core :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decode_core :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decode_core :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decode_core :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decode_core :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decode_core :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decode_core :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decode_core :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decode_core :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decode_core :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decode_core(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decode_core(in_upper);
    }
}

silk_clz_frac_in_decode_core :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decode_core(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decode_core(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decode_core :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decode_core(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decode_core :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decode_core((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decode_core((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decode_core :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decode_core((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_decode_core :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_decode_core :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_decode_core :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_decode_core :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_decode_core :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_decode_core :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_decode_core :: (
    ps_dec: *Silk_Decoder_State,
    ps_dec_ctrl: *Silk_Decoder_Control,
    xq: *Int16,
    pulses: *Int16,
    arch: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    lag: s32 = 0;
    start_idx: s32 = ---;
    a_q12_tmp: [16] Int16 = ---;
    ltp_pred_q13: Int32 = ---;
    lpc_pred_q10: Int32 = ---;
    gain_adj_q16: Int32 = ---;
    pred_lag_ptr: *Int32 = ---;

    (ps_dec.prev_gain_q16 != 0);

    s_ltp := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) ps_dec.ltp_mem_length)));
    s_ltp_q15 :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) (ps_dec.ltp_mem_length + ps_dec.frame_length))));
    res_q14 := cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) * cast,no_check(u64) ps_dec.subfr_length)));

    s_lpc_q14 :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) (ps_dec.subfr_length + 16))));

    offset_q10 :=
        cast,no_check(Int32) SILK_QUANTIZATION_OFFSETS_Q10[(cast(s32) ps_dec.indices.signal_type) >> 1][ps_dec.indices.quant_offset_type];

    nlsf_interpolation_flag: s32 = ifx cast,no_check(s32) ps_dec.indices.nlsf_interp_coef_q2 < (cast(s32) 1) << 2
        then cast(s32) 1
        else 0;

    rand_seed := cast,no_check(Int32) ps_dec.indices.seed;
    i: s32 = 0;
    while i < ps_dec.frame_length {
        rand_seed = cast,no_check(Int32) (907633515 + (cast,no_check(Uint32) rand_seed) * 196314165);
        ps_dec.exc_q14[i] = cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) pulses[i])) << 14);
        if ps_dec.exc_q14[i] > 0 {
            ps_dec.exc_q14[i] = cast,no_check(Int32) (ps_dec.exc_q14[i] - ((cast(s32) 80) << 4));
        } else if ps_dec.exc_q14[i] < 0 {
            ps_dec.exc_q14[i] = cast,no_check(Int32) (ps_dec.exc_q14[i] + ((cast(s32) 80) << 4));
        }
        ps_dec.exc_q14[i] += offset_q10 << 4;
        if rand_seed < 0 {
            ps_dec.exc_q14[i] = -ps_dec.exc_q14[i];
        }

        rand_seed = cast,no_check(Int32) ((cast,no_check(Uint32) rand_seed) + cast,no_check(Uint32) pulses[i]);
        i += 1;
    }

    copy_memory(s_lpc_q14, ps_dec.s_lpc_q14_buf.data, cast(u64) 16 * size_of(Int32));

    pexc_q14 := ps_dec.exc_q14.data;
    pxq := xq;
    s_ltp_buf_idx := ps_dec.ltp_mem_length;

    k: s32 = 0;
    while k < ps_dec.nb_subfr {
        pres_q14 := res_q14;
        a_q12 := ps_dec_ctrl.pred_coef_q12[k >> 1].data;

        copy_memory(a_q12_tmp.data, a_q12, cast,no_check(u64) ps_dec.lpc_order * size_of(Int16));
        b_q14 := ps_dec_ctrl.ltp_coef_q14.data + k * 5;
        signal_type := cast,no_check(s32) ps_dec.indices.signal_type;

        gain_q10 := ps_dec_ctrl.gains_q16[k] >> 6;
        inv_gain_q31 := silk_inverse32_var_q_in_decode_core(ps_dec_ctrl.gains_q16[k], 47);

        if ps_dec_ctrl.gains_q16[k] != ps_dec.prev_gain_q16 {
            gain_adj_q16 = silk_div32_var_q_in_decode_core(ps_dec.prev_gain_q16, ps_dec_ctrl.gains_q16[k], 16);

            i = 0;
            while i < 16 {
                s_lpc_q14[i] =
                    cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                        cast(Int64) s_lpc_q14[i]) >> 16);
                i += 1;
            }
        } else {
            gain_adj_q16 = cast,no_check(Int32) (((cast(s32) 1) << 16));
        }

        ps_dec.prev_gain_q16 = ps_dec_ctrl.gains_q16[k];

        if ps_dec.loss_cnt != 0 && ps_dec.prev_signal_type == 2 && ps_dec.indices.signal_type != 2 && k < 4 / 2 {
            fill_memory(b_q14, 0, cast(u64) 5 * size_of(Int16));
            b_q14[5 / 2] = cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 4096.5));

            signal_type = 2;
            ps_dec_ctrl.pitch_l[k] = ps_dec.lag_prev;
        }

        if signal_type == 2 {
            lag = ps_dec_ctrl.pitch_l[k];

            if k == 0 || k == 2 && nlsf_interpolation_flag != 0 {
                start_idx = ps_dec.ltp_mem_length - lag - ps_dec.lpc_order - cast,no_check(s32) ((5 / 2));

                if k == 2 {
                    copy_memory(
                        ps_dec.out_buf.data + ps_dec.ltp_mem_length,
                        xq,
                        cast,no_check(u64) (2 * ps_dec.subfr_length) * size_of(Int16)
                    );
                }

                silk_lpc_analysis_filter(
                    *s_ltp[start_idx],
                    ps_dec.out_buf.data + start_idx + k * ps_dec.subfr_length,
                    a_q12,
                    ps_dec.ltp_mem_length - start_idx,
                    ps_dec.lpc_order,
                    arch
                );

                if k == 0 {
                    inv_gain_q31 =
                        cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast(Int64) inv_gain_q31) *
                            cast,no_check(Int64) (cast,no_check(Int16) ps_dec_ctrl.ltp_scale_q14)) >> 16))) << 2);
                }
                i = 0;
                while i < lag + cast,no_check(s32) ((5 / 2)) {
                    s_ltp_q15[s_ltp_buf_idx - i - 1] =
                        cast,no_check(Int32) (((cast(Int64) inv_gain_q31) *
                            cast,no_check(Int64) s_ltp[ps_dec.ltp_mem_length - i - 1]) >> 16);
                    i += 1;
                }
            } else if gain_adj_q16 != (cast(s32) 1) << 16 {
                i = 0;
                while i < lag + cast,no_check(s32) ((5 / 2)) {
                    s_ltp_q15[s_ltp_buf_idx - i - 1] =
                        cast,no_check(Int32) (((cast,no_check(Int64) gain_adj_q16) *
                            cast(Int64) s_ltp_q15[s_ltp_buf_idx - i - 1]) >> 16);
                    i += 1;
                }
            }
        }

        if signal_type == 2 {
            pred_lag_ptr = *s_ltp_q15[s_ltp_buf_idx - lag + cast,no_check(s32) ((5 / 2))];
            i = 0;
            while i < ps_dec.subfr_length {
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

                pres_q14[i] = pexc_q14[i] + cast,no_check(Int32) ((cast,no_check(Uint32) ltp_pred_q13) << 1);

                s_ltp_q15[s_ltp_buf_idx] = cast,no_check(Int32) ((cast,no_check(Uint32) pres_q14[i]) << 1);
                s_ltp_buf_idx += 1;
                i += 1;
            }
        } else {
            pres_q14 = pexc_q14;
        }

        i = 0;
        while i < ps_dec.subfr_length {
            (ps_dec.lpc_order == 10 || ps_dec.lpc_order == 16);

            lpc_pred_q10 = ps_dec.lpc_order >> 1;
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 1]) * cast,no_check(Int64) a_q12_tmp[0]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 2]) * cast,no_check(Int64) a_q12_tmp[1]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 3]) * cast,no_check(Int64) a_q12_tmp[2]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 4]) * cast,no_check(Int64) a_q12_tmp[3]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 5]) * cast,no_check(Int64) a_q12_tmp[4]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 6]) * cast,no_check(Int64) a_q12_tmp[5]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 7]) * cast,no_check(Int64) a_q12_tmp[6]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 8]) * cast,no_check(Int64) a_q12_tmp[7]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 9]) * cast,no_check(Int64) a_q12_tmp[8]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14[16 + i - 10]) * cast,no_check(Int64) a_q12_tmp[9]) >> 16);
            if ps_dec.lpc_order == 16 {
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 11]) * cast,no_check(Int64) a_q12_tmp[10]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 12]) * cast,no_check(Int64) a_q12_tmp[11]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 13]) * cast,no_check(Int64) a_q12_tmp[12]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 14]) * cast,no_check(Int64) a_q12_tmp[13]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 15]) * cast,no_check(Int64) a_q12_tmp[14]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) s_lpc_q14[16 + i - 16]) * cast,no_check(Int64) a_q12_tmp[15]) >> 16);
            }

            s_lpc_q14[16 + i] =
                ifx (((cast,no_check(Uint32) pres_q14[i]) + cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) (pres_q14[i] & cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) != 0 then -2147483648 else pres_q14[i] +
                    cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4)) else (ifx ((cast,no_check(u32) (pres_q14[i] | cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then 0x7fffffff else pres_q14[i] + cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4));

            pxq[i] =
                cast,no_check(Int16) ((ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) +
                    (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))));
            i += 1;
        }

        copy_memory(s_lpc_q14, *s_lpc_q14[ps_dec.subfr_length], cast(u64) 16 * size_of(Int32));
        pexc_q14 += ps_dec.subfr_length;
        pxq += ps_dec.subfr_length;
        k += 1;
    }

    copy_memory(ps_dec.s_lpc_q14_buf.data, s_lpc_q14, cast(u64) 16 * size_of(Int32));
}

false__in_decode_core :: () -> s32 {
    return 0;
}

