// Generated directly from C by cpp_transpiler.
PLC_RAND_ATTENUATE_UV_Q15: [2] Int16;

PLC_RAND_ATTENUATE_V_Q15: [2] Int16;

HARM_ATT_Q15: [2] Int16;

silk_clz16_in_plc :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_plc :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_plc :: () -> s32 {
    return 0;
}

silk_ror32_in_plc :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_plc :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_plc :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_plc :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_plc :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_plc :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_plc :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_plc :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_plc :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_plc :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_plc(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_plc(in_upper);
    }
}

silk_clz_frac_in_plc :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_plc(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_plc(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_plc :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_plc(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_plc :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_plc((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_plc((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_plc :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_plc((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_plc :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_plc :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_plc :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_plc :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_plc :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_plc :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_plc_reset :: (ps_dec: *Silk_Decoder_State) {
    ps_dec.s_plc.pitch_l_q8 = cast,no_check(Int32) ((cast,no_check(Uint32) ps_dec.frame_length) << (((8 - 1)) & 31));
    ps_dec.s_plc.prev_gain_q16[0] = cast,no_check(Int32) (cast(float64) 65536.5);
    ps_dec.s_plc.prev_gain_q16[1] = cast,no_check(Int32) (cast(float64) 65536.5);
    ps_dec.s_plc.subfr_length = 20;
    ps_dec.s_plc.nb_subfr = 2;
}

silk_plc :: (ps_dec: *Silk_Decoder_State, ps_dec_ctrl: *Silk_Decoder_Control, frame: *Int16, lost: s32, arch: s32) {
    if ps_dec.fs_k_hz != ps_dec.s_plc.fs_k_hz {
        silk_plc_reset(ps_dec);
        ps_dec.s_plc.fs_k_hz = ps_dec.fs_k_hz;
    }

    if lost != 0 {
        silk_plc_conceal(ps_dec, ps_dec_ctrl, frame, arch);

        ps_dec.loss_cnt += 1;
    } else {
        silk_plc_update(ps_dec, ps_dec_ctrl);
    }
}

silk_plc_update :: (ps_dec: *Silk_Decoder_State, ps_dec_ctrl: *Silk_Decoder_Control) {
    temp_ltp_gain_q14: Int32 = ---;
    i, j: s32 = ---;
    ps_plc := *ps_dec.s_plc;

    ps_dec.prev_signal_type = cast,no_check(s32) ps_dec.indices.signal_type;
    ltp_gain_q14: Int32 = 0;
    if ps_dec.indices.signal_type == 2 {
        j = 0;
        while j * ps_dec.subfr_length < ps_dec_ctrl.pitch_l[ps_dec.nb_subfr - 1] {
            if j == ps_dec.nb_subfr {
                break;
            }
            temp_ltp_gain_q14 = 0;
            i = 0;
            while i < 5 {
                temp_ltp_gain_q14 = cast,no_check(Int32) (temp_ltp_gain_q14 + cast,no_check(s32) ps_dec_ctrl.ltp_coef_q14[(ps_dec.nb_subfr - 1 - j) * 5 + i]);
                i += 1;
            }
            if temp_ltp_gain_q14 > ltp_gain_q14 {
                ltp_gain_q14 = temp_ltp_gain_q14;
                copy_memory(
                    ps_plc.ltp_coef_q14.data,
                    ps_dec_ctrl.ltp_coef_q14.data +
                    (cast,no_check(Int32) (cast,no_check(Int16) (ps_dec.nb_subfr - 1 - j))) * cast,no_check(Int32) (cast(Int16) 5),
                    cast(u64) 5 * size_of(Int16)
                );

                ps_plc.pitch_l_q8 =
                    cast,no_check(Int32) ((cast,no_check(Uint32) ps_dec_ctrl.pitch_l[ps_dec.nb_subfr -
                        1 - j]) << 8);
            }
            j += 1;
        }

        fill_memory(ps_plc.ltp_coef_q14.data, 0, cast(u64) 5 * size_of(Int16));
        ps_plc.ltp_coef_q14[5 / 2] = cast,no_check(Int16) ltp_gain_q14;

        if ltp_gain_q14 < 11469 {
            tmp: Int32 = cast,no_check(Int32) ((cast(Uint32) 11469) << 10);
            scale_q10 := tmp / (ifx ltp_gain_q14 > 1 then ltp_gain_q14 else 1);
            i = 0;
            while i < 5 {
                ps_plc.ltp_coef_q14[i] =
                    cast,no_check(Int16) (((cast,no_check(Int32) ps_plc.ltp_coef_q14[i]) *
                        cast,no_check(Int32) (cast,no_check(Int16) scale_q10)) >> 10);
                i += 1;
            }
        } else if ltp_gain_q14 > 15565 {
            tmp: Int32 = cast,no_check(Int32) ((cast(Uint32) 15565) << 14);
            scale_q14 := tmp / (ifx ltp_gain_q14 > 1 then ltp_gain_q14 else 1);
            i = 0;
            while i < 5 {
                ps_plc.ltp_coef_q14[i] =
                    cast,no_check(Int16) (((cast,no_check(Int32) ps_plc.ltp_coef_q14[i]) *
                        cast,no_check(Int32) (cast,no_check(Int16) scale_q14)) >> 14);
                i += 1;
            }
        }
    } else {
        ps_plc.pitch_l_q8 =
            cast,no_check(Int32) ((cast,no_check(Uint32) ((cast,no_check(Int32) (cast,no_check(Int16) ps_dec.fs_k_hz)) *
                cast,no_check(Int32) (cast(Int16) 18))) << 8);
        fill_memory(ps_plc.ltp_coef_q14.data, 0, cast(u64) 5 * size_of(Int16));
    }

    copy_memory(
        ps_plc.prev_lpc_q12.data,
        ps_dec_ctrl.pred_coef_q12[1].data,
        cast,no_check(u64) ps_dec.lpc_order * size_of(Int16)
    );
    ps_plc.prev_ltp_scale_q14 = cast,no_check(Int16) ps_dec_ctrl.ltp_scale_q14;

    copy_memory(
        ps_plc.prev_gain_q16.data,
        ps_dec_ctrl.gains_q16.data + ps_dec.nb_subfr - 2,
        cast(u64) 2 * size_of(Int32)
    );

    ps_plc.subfr_length = ps_dec.subfr_length;
    ps_plc.nb_subfr = ps_dec.nb_subfr;
}

silk_plc_conceal :: (ps_dec: *Silk_Decoder_State, ps_dec_ctrl: *Silk_Decoder_Control, frame: *Int16, arch: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;
    j: s32 = ---;
    shift1: s32 = ---;
    shift2: s32 = ---;
    energy1: Int32 = ---;
    energy2: Int32 = ---;
    ltp_pred_q12: Int32 = ---;

    a_q12: [16] Int16 = ---;

    ps_plc := *ps_dec.s_plc;
    prev_gain_q10: [2] Int32 = ---;

    s_ltp_q14 :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) (ps_dec.ltp_mem_length + ps_dec.frame_length))));

    s_ltp := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) ps_dec.ltp_mem_length)));

    prev_gain_q10[0] = ps_plc.prev_gain_q16[0] >> 6;
    prev_gain_q10[1] = ps_plc.prev_gain_q16[1] >> 6;

    if ps_dec.first_frame_after_reset != 0 {
        fill_memory(ps_plc.prev_lpc_q12.data, 0, ps_plc.prev_lpc_q12.count * size_of(Int16));
    }

    silk_plc_energy(
        *energy1,
        *shift1,
        *energy2,
        *shift2,
        ps_dec.exc_q14.data,
        prev_gain_q10.data,
        ps_dec.subfr_length,
        ps_dec.nb_subfr
    );

    rand_ptr: *Int32 = ifx energy1 >> ((shift2) & 31) < energy2 >> ((shift1) & 31)
        then ps_dec.exc_q14.data + silk_max_int_in_plc(0, (ps_plc.nb_subfr - 1) * ps_plc.subfr_length - 128)
        else ps_dec.exc_q14.data + silk_max_int_in_plc(0, ps_plc.nb_subfr * ps_plc.subfr_length - 128);

    b_q14 := ps_plc.ltp_coef_q14.data;
    rand_scale_q14 := ps_plc.rand_scale_q14;

    harm_gain_q15 :=
        cast,no_check(Int32) (HARM_ATT_Q15[silk_min_int_in_plc(cast,no_check(s32) (2 -
            1), ps_dec.loss_cnt)]);
    rand_gain_q15: Int32 = ifx ps_dec.prev_signal_type == 2
        then cast,no_check(Int32) (PLC_RAND_ATTENUATE_V_Q15[silk_min_int_in_plc(cast,no_check(s32) (2 - 1), ps_dec.loss_cnt)])
        else cast,no_check(Int32) (PLC_RAND_ATTENUATE_UV_Q15[silk_min_int_in_plc(cast,no_check(s32) (2 - 1), ps_dec.loss_cnt)]);

    silk_bwexpander(ps_plc.prev_lpc_q12.data, ps_dec.lpc_order, cast,no_check(Int32) (cast(float64) 64881.14));

    copy_memory(a_q12.data, ps_plc.prev_lpc_q12.data, cast,no_check(u64) ps_dec.lpc_order * size_of(Int16));

    if ps_dec.loss_cnt == 0 {
        rand_scale_q14 = cast,no_check(Int16) ((cast(s32) 1) << 14);

        if ps_dec.prev_signal_type == 2 {
            i = 0;
            while i < 5 {
                rand_scale_q14 = cast,no_check(Int16) ((cast,no_check(s32) rand_scale_q14) - cast,no_check(s32) b_q14[i]);
                i += 1;
            }
            rand_scale_q14 = silk_max_16_in_plc(3277, rand_scale_q14);
            rand_scale_q14 =
                cast,no_check(Int16) (((cast,no_check(Int32) rand_scale_q14) *
                    cast,no_check(Int32) ps_plc.prev_ltp_scale_q14) >> 14);
        } else {
            inv_gain_q30_value: Int32 = ---;

            inv_gain_q30_value = silk_lpc_inverse_pred_gain_c(ps_plc.prev_lpc_q12.data, ps_dec.lpc_order);

            down_scale_q30 :=
                silk_min_32_in_plc(
                    (cast,no_check(Int32) (((cast(s32) 1) << 30))) >> 3,
                    inv_gain_q30_value
                );
            down_scale_q30 = silk_max_32_in_plc((cast,no_check(Int32) (((cast(s32) 1) << 30))) >> 8, down_scale_q30);
            down_scale_q30 = cast,no_check(Int32) ((cast,no_check(Uint32) down_scale_q30) << 3);

            rand_gain_q15 =
                (cast,no_check(Int32) (((cast(Int64) down_scale_q30) *
                    cast,no_check(Int64) (cast,no_check(Int16) rand_gain_q15)) >> 16)) >> 14;
        }
    }

    rand_seed := ps_plc.rand_seed;
    lag :=
        (ifx 8 == 1 then ps_plc.pitch_l_q8 >> 1 +
            ps_plc.pitch_l_q8 & 1 else (ps_plc.pitch_l_q8 >> (((8 - 1)) & 31) + 1) >> 1);
    s_ltp_buf_idx := ps_dec.ltp_mem_length;

    idx := ps_dec.ltp_mem_length - lag - ps_dec.lpc_order - cast,no_check(s32) ((5 / 2));

    silk_lpc_analysis_filter(
        *s_ltp[idx],
        ps_dec.out_buf.data + idx,
        a_q12.data,
        ps_dec.ltp_mem_length - idx,
        ps_dec.lpc_order,
        arch
    );

    inv_gain_q30 := silk_inverse32_var_q_in_plc(ps_plc.prev_gain_q16[1], 46);
    inv_gain_q30 =
        ifx inv_gain_q30 < (cast(s32) 0x7fffffff) >> 1 then inv_gain_q30 else cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 1));
    i = idx + ps_dec.lpc_order;
    while i < ps_dec.ltp_mem_length {
        s_ltp_q14[i] = cast,no_check(Int32) (((cast(Int64) inv_gain_q30) * cast,no_check(Int64) s_ltp[i]) >> 16);
        i += 1;
    }

    k: s32 = 0;
    while k < ps_dec.nb_subfr {
        pred_lag_ptr := *s_ltp_q14[s_ltp_buf_idx - lag + cast,no_check(s32) ((5 / 2))];
        i = 0;
        while i < ps_dec.subfr_length {
            ltp_pred_q12 = 2;
            ltp_pred_q12 =
                cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) pred_lag_ptr[0]) * cast,no_check(Int64) b_q14[0]) >> 16);
            ltp_pred_q12 =
                cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) pred_lag_ptr[-1]) * cast,no_check(Int64) b_q14[1]) >> 16);
            ltp_pred_q12 =
                cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) pred_lag_ptr[-2]) * cast,no_check(Int64) b_q14[2]) >> 16);
            ltp_pred_q12 =
                cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) pred_lag_ptr[-3]) * cast,no_check(Int64) b_q14[3]) >> 16);
            ltp_pred_q12 =
                cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) pred_lag_ptr[-4]) * cast,no_check(Int64) b_q14[4]) >> 16);
            pred_lag_ptr += 1;

            rand_seed = cast,no_check(Int32) (907633515 + (cast,no_check(Uint32) rand_seed) * 196314165);
            idx = rand_seed >> 25 & cast,no_check(Int32) ((128 - 1));
            s_ltp_q14[s_ltp_buf_idx] =
                cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) ((cast(Int64) ltp_pred_q12) +
                    ((cast(Int64) rand_ptr[idx]) * cast,no_check(Int64) rand_scale_q14) >> 16))) << 2);
            s_ltp_buf_idx += 1;
            i += 1;
        }

        j = 0;
        while j < 5 {
            b_q14[j] =
                cast,no_check(Int16) (((cast,no_check(Int32) (cast,no_check(Int16) harm_gain_q15)) *
                    cast,no_check(Int32) b_q14[j]) >> 15);
            j += 1;
        }

        rand_scale_q14 =
            cast,no_check(Int16) (((cast,no_check(Int32) rand_scale_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) rand_gain_q15)) >> 15);

        ps_plc.pitch_l_q8 =
            cast,no_check(Int32) ((cast(Int64) ps_plc.pitch_l_q8) +
                ((cast(Int64) ps_plc.pitch_l_q8) * cast,no_check(Int64) (cast(Int16) 655)) >> 16);
        ps_plc.pitch_l_q8 =
            silk_min_32_in_plc(
                ps_plc.pitch_l_q8,
                cast,no_check(Int32) ((cast,no_check(Uint32) ((cast,no_check(Int32) (cast(Int16) 18)) *
                cast,no_check(Int32) (cast,no_check(Int16) ps_dec.fs_k_hz))) << 8)
            );
        lag =
            ifx 8 == 1 then ps_plc.pitch_l_q8 >> 1 +
                ps_plc.pitch_l_q8 & 1 else (ps_plc.pitch_l_q8 >> (((8 - 1)) & 31) + 1) >> 1;
        k += 1;
    }

    s_lpc_q14_ptr := *s_ltp_q14[ps_dec.ltp_mem_length - 16];

    copy_memory(s_lpc_q14_ptr, ps_dec.s_lpc_q14_buf.data, cast(u64) 16 * size_of(Int32));

    (ps_dec.lpc_order >= 10);
    i = 0;
    while i < ps_dec.frame_length {
        lpc_pred_q10 := ps_dec.lpc_order >> 1;
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 1]) * cast,no_check(Int64) a_q12[0]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 2]) * cast,no_check(Int64) a_q12[1]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 3]) * cast,no_check(Int64) a_q12[2]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 4]) * cast,no_check(Int64) a_q12[3]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 5]) * cast,no_check(Int64) a_q12[4]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 6]) * cast,no_check(Int64) a_q12[5]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 7]) * cast,no_check(Int64) a_q12[6]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 8]) * cast,no_check(Int64) a_q12[7]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 9]) * cast,no_check(Int64) a_q12[8]) >> 16);
        lpc_pred_q10 =
            cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                ((cast(Int64) s_lpc_q14_ptr[16 + i - 10]) * cast,no_check(Int64) a_q12[9]) >> 16);
        j = 10;
        while j < ps_dec.lpc_order {
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) s_lpc_q14_ptr[16 + i - j - 1]) * cast,no_check(Int64) a_q12[j]) >> 16);
            j += 1;
        }

        s_lpc_q14_ptr[16 + i] =
            ifx (((cast,no_check(Uint32) s_lpc_q14_ptr[16 + i]) + cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) (s_lpc_q14_ptr[16 + i] & cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) != 0 then -2147483648 else s_lpc_q14_ptr[16 + i] +
                cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4)) else (ifx ((cast,no_check(u32) (s_lpc_q14_ptr[16 + i] | cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then 0x7fffffff else s_lpc_q14_ptr[16 + i] + cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4));

        frame[i] =
            cast,no_check(Int16) ((ifx (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) +
                (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))) > 0x7fff then 0x7fff else (ifx (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) s_lpc_q14_ptr[16 + i]) * cast(Int64) prev_gain_q10[1]) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))))));
        i += 1;
    }

    copy_memory(ps_dec.s_lpc_q14_buf.data, *s_lpc_q14_ptr[ps_dec.frame_length], cast(u64) 16 * size_of(Int32));

    ps_plc.rand_seed = rand_seed;
    ps_plc.rand_scale_q14 = rand_scale_q14;
    i = 0;
    while i < 4 {
        ps_dec_ctrl.pitch_l[i] = lag;
        i += 1;
    }
}

silk_plc_energy :: (
    energy1: *Int32,
    shift1: *s32,
    energy2: *Int32,
    shift2: *s32,
    exc_q14: *Int32,
    prev_gain_q10: *Int32,
    subfr_length: s32,
    nb_subfr: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    exc_buf := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) (2 * subfr_length))));

    exc_buf_ptr := exc_buf;
    for k: 0..cast(s32) 2 - 1 {
        i = 0;
        while i < subfr_length {
            exc_buf_ptr[i] =
                cast,no_check(Int16) ((ifx ((cast,no_check(Int32) (((cast,no_check(Int64) exc_q14[i + (k + nb_subfr - 2) * subfr_length]) *
                    cast(Int64) prev_gain_q10[k]) >> 16)) >> 8) > 0x7fff then 0x7fff else (ifx ((cast,no_check(Int32) (((cast,no_check(Int64) exc_q14[i + (k + nb_subfr - 2) * subfr_length]) * cast(Int64) prev_gain_q10[k]) >> 16)) >> 8) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (cast,no_check(Int32) (((cast,no_check(Int64) exc_q14[i + (k + nb_subfr - 2) * subfr_length]) * cast(Int64) prev_gain_q10[k]) >> 16)) >> 8)));
            i += 1;
        }
        exc_buf_ptr += subfr_length;
    }

    silk_sum_sqr_shift(energy1, shift1, exc_buf, subfr_length);
    silk_sum_sqr_shift(energy2, shift2, *exc_buf[subfr_length], subfr_length);
}

silk_plc_glue_frames :: (ps_dec: *Silk_Decoder_State, frame: *Int16, length: s32) {
    energy_shift: s32 = ---;
    energy: Int32 = ---;
    ps_plc := *ps_dec.s_plc;

    if ps_dec.loss_cnt != 0 {
        silk_sum_sqr_shift(*ps_plc.conc_energy, *ps_plc.conc_energy_shift, frame, length);

        ps_plc.last_frame_lost = 1;
    } else {
        if ps_dec.s_plc.last_frame_lost != 0 {
            silk_sum_sqr_shift(*energy, *energy_shift, frame, length);

            if energy_shift > ps_plc.conc_energy_shift {
                ps_plc.conc_energy = ps_plc.conc_energy >> (((energy_shift - ps_plc.conc_energy_shift)) & 31);
            } else if energy_shift < ps_plc.conc_energy_shift {
                energy = energy >> (((ps_plc.conc_energy_shift - energy_shift)) & 31);
            }

            if energy > ps_plc.conc_energy {
                lz := silk_clz32_in_plc(ps_plc.conc_energy);
                lz = lz - 1;
                ps_plc.conc_energy = cast,no_check(Int32) ((cast,no_check(Uint32) ps_plc.conc_energy) << ((lz) & 31));
                energy = energy >> ((silk_max_32_in_plc(24 - lz, 0)) & 31);

                frac_q24 := ps_plc.conc_energy / (ifx energy > 1 then energy else 1);

                gain_q16 := cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx_in_plc(frac_q24)) << 4);
                slope_q16 := ((cast,no_check(Int32) (((cast(s32) 1) << 16))) - gain_q16) / length;

                slope_q16 = cast,no_check(Int32) ((cast,no_check(Uint32) slope_q16) << 2);

                if 0 < length {
                    for i: 0..length - 1 {
                        frame[i] =
                            cast,no_check(Int16) (cast,no_check(Int32) (((cast(Int64) gain_q16) *
                                cast,no_check(Int64) frame[i]) >> 16));
                        gain_q16 += slope_q16;
                        if gain_q16 > (cast(s32) 1) << 16 {
                            break;
                        }
                    }
                }
            }
        }
        ps_plc.last_frame_lost = 0;
    }
}

false__in_plc :: () -> s32 {
    return 0;
}

globals_initialization_state_for_plc: u32;
initialize_globals_for_plc :: () {
    {
        state := atomic_load(*globals_initialization_state_for_plc);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_plc, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_plc) != 2 {}
            return;
        }
    }
    HARM_ATT_Q15 = Int16.[ 32440, 31130 ];
    PLC_RAND_ATTENUATE_V_Q15 = Int16.[ 31130, 26214 ];
    PLC_RAND_ATTENUATE_UV_Q15 = Int16.[ 32440, 29491 ];
    atomic_store(*globals_initialization_state_for_plc, 2);
}

