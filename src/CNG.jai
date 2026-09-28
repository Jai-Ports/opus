#load "cpp_transpiler_runtime.jai";

silk_clz16 :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32 :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch :: () -> s32 {
    return 0;
}

silk_ror32 :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32 :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64 :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32 :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64 :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64 :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32(cast,no_check(Int32) in);
    } else {
        return silk_clz32(in_upper);
    }
}

silk_clz_frac :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_cng_reset :: (ps_dec: *Silk_Decoder_State) {
    nlsf_step_q15: s32 = ---;

    nlsf_step_q15 = 0x7fff / (ps_dec.lpc_order + 1);
    nlsf_acc_q15: s32 = 0;
    i: s32 = 0;
    while i < ps_dec.lpc_order {
        nlsf_acc_q15 += nlsf_step_q15;
        ps_dec.s_cng.cng_smth_nlsf_q15[i] = cast,no_check(Int16) nlsf_acc_q15;
        i += 1;
    }
    ps_dec.s_cng.cng_smth_gain_q16 = 0;
    ps_dec.s_cng.rand_seed = 3176576;
}

silk_cng :: (ps_dec: *Silk_Decoder_State, ps_dec_ctrl: *Silk_Decoder_Control, frame: *Int16, length: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i, subfr: s32 = ---;
    lpc_pred_q10, max_gain_q16, gain_q16, gain_q10: Int32 = ---;
    a_q12: [16] Int16 = ---;
    ps_cng := *ps_dec.s_cng;

    if ps_dec.fs_k_hz != ps_cng.fs_k_hz {
        silk_cng_reset(ps_dec);

        ps_cng.fs_k_hz = ps_dec.fs_k_hz;
    }
    if ps_dec.loss_cnt == 0 && ps_dec.prev_signal_type == 0 {
        i = 0;
        while i < ps_dec.lpc_order {
            ps_cng.cng_smth_nlsf_q15[i] = cast,no_check(Int16) ((cast,no_check(s32) ps_cng.cng_smth_nlsf_q15[i]) + cast,no_check(Int32) (((cast(Int64) ((cast,no_check(Int32) ps_dec.prev_nlsf_q15[i]) - cast,no_check(Int32) ps_cng.cng_smth_nlsf_q15[i])) * cast,no_check(Int64) (cast(Int16) 16348)) >> 16));
            i += 1;
        }

        max_gain_q16 = 0;
        subfr = 0;
        i = 0;
        while i < ps_dec.nb_subfr {
            if ps_dec_ctrl.gains_q16[i] > max_gain_q16 {
                max_gain_q16 = ps_dec_ctrl.gains_q16[i];
                subfr = i;
            }
            i += 1;
        }

        move_memory(
            ps_cng.cng_exc_buf_q14.data + ps_dec.subfr_length,
            ps_cng.cng_exc_buf_q14.data,
            cast,no_check(u64) ((ps_dec.nb_subfr - 1) * ps_dec.subfr_length) * size_of(Int32)
        );
        copy_memory(
            ps_cng.cng_exc_buf_q14.data,
            ps_dec.exc_q14.data + subfr * ps_dec.subfr_length,
            cast,no_check(u64) ps_dec.subfr_length * size_of(Int32)
        );

        i = 0;
        while i < ps_dec.nb_subfr {
            ps_cng.cng_smth_gain_q16 +=
                cast,no_check(Int32) (((cast(Int64) (ps_dec_ctrl.gains_q16[i] - ps_cng.cng_smth_gain_q16)) *
                    cast,no_check(Int64) (cast(Int16) 4634)) >> 16);

            if cast,no_check(Int32) (((cast,no_check(Int64) ps_cng.cng_smth_gain_q16) * 46396) >> 16) > ps_dec_ctrl.gains_q16[i] {
                ps_cng.cng_smth_gain_q16 = ps_dec_ctrl.gains_q16[i];
            }
            i += 1;
        }
    }

    if ps_dec.loss_cnt != 0 {
        cng_sig_q14 :=
            cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
                cast,no_check(u64) (length + 16))));

        gain_q16 =
            cast,no_check(Int32) (((cast,no_check(Int64) ps_dec.s_plc.rand_scale_q14) *
                cast(Int64) ps_dec.s_plc.prev_gain_q16[1]) >> 16);
        if gain_q16 >= (cast(s32) 1) << 21 || ps_cng.cng_smth_gain_q16 > (cast(s32) 1) << 23 {
            gain_q16 = gain_q16 >> 16 * gain_q16 >> 16;
            gain_q16 =
                ps_cng.cng_smth_gain_q16 >> 16 * ps_cng.cng_smth_gain_q16 >> 16 -
                    cast,no_check(Int32) ((cast,no_check(Uint32) gain_q16) << 5);
            gain_q16 = cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx(gain_q16)) << 16);
        } else {
            gain_q16 = cast,no_check(Int32) (((cast,no_check(Int64) gain_q16) * cast(Int64) gain_q16) >> 16);
            gain_q16 =
                (cast,no_check(Int32) (((cast,no_check(Int64) ps_cng.cng_smth_gain_q16) * cast(Int64) ps_cng.cng_smth_gain_q16) >> 16)) -
                    cast,no_check(Int32) ((cast,no_check(Uint32) gain_q16) << 5);
            gain_q16 = cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx(gain_q16)) << 8);
        }
        gain_q10 = gain_q16 >> 6;

        silk_cng_exc(cng_sig_q14 + 16, ps_cng.cng_exc_buf_q14.data, length, *ps_cng.rand_seed);

        silk_nlsf2_a(a_q12.data, ps_cng.cng_smth_nlsf_q15.data, ps_dec.lpc_order, ps_dec.arch);

        copy_memory(cng_sig_q14, ps_cng.cng_synth_state.data, cast(u64) 16 * size_of(Int32));
        (ps_dec.lpc_order == 10 || ps_dec.lpc_order == 16);
        i = 0;
        while i < length {
            lpc_pred_q10 = ps_dec.lpc_order >> 1;
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 1]) * cast,no_check(Int64) a_q12[0]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 2]) * cast,no_check(Int64) a_q12[1]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 3]) * cast,no_check(Int64) a_q12[2]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 4]) * cast,no_check(Int64) a_q12[3]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 5]) * cast,no_check(Int64) a_q12[4]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 6]) * cast,no_check(Int64) a_q12[5]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 7]) * cast,no_check(Int64) a_q12[6]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 8]) * cast,no_check(Int64) a_q12[7]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 9]) * cast,no_check(Int64) a_q12[8]) >> 16);
            lpc_pred_q10 =
                cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                    ((cast(Int64) cng_sig_q14[16 + i - 10]) * cast,no_check(Int64) a_q12[9]) >> 16);
            if ps_dec.lpc_order == 16 {
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 11]) * cast,no_check(Int64) a_q12[10]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 12]) * cast,no_check(Int64) a_q12[11]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 13]) * cast,no_check(Int64) a_q12[12]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 14]) * cast,no_check(Int64) a_q12[13]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 15]) * cast,no_check(Int64) a_q12[14]) >> 16);
                lpc_pred_q10 =
                    cast,no_check(Int32) ((cast(Int64) lpc_pred_q10) +
                        ((cast(Int64) cng_sig_q14[16 + i - 16]) * cast,no_check(Int64) a_q12[15]) >> 16);
            }

            cng_sig_q14[16 + i] =
                ifx (((cast,no_check(Uint32) cng_sig_q14[16 + i]) + cast,no_check(Uint32) (cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then (ifx ((cast,no_check(u32) (cng_sig_q14[16 + i] & cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) != 0 then -2147483648 else cng_sig_q14[16 + i] +
                    cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4)) else (ifx ((cast,no_check(u32) (cng_sig_q14[16 + i] | cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4))) & 0x80000000) == 0 then 0x7fffffff else cng_sig_q14[16 + i] + cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx (cast(Int32) -2147483648) >> 4 > (cast(s32) 0x7fffffff) >> 4 then (ifx lpc_pred_q10 > (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else (ifx lpc_pred_q10 < (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else lpc_pred_q10)) else (ifx lpc_pred_q10 > (cast(s32) 0x7fffffff) >> 4 then cast,no_check(Int32) (((cast(s32) 0x7fffffff) >> 4)) else (ifx lpc_pred_q10 < (cast(Int32) -2147483648) >> 4 then (cast(Int32) -2147483648) >> 4 else lpc_pred_q10))))) << 4));

            frame[i] =
                cast,no_check(Int16) ((ifx ((cast,no_check(Int32) frame[i]) + (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1)))) > 0x7fff then 0x7fff else (ifx ((cast,no_check(Int32) frame[i]) + (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1)))) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (cast,no_check(Int32) frame[i]) +
                    (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then ((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> 1) + (cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) & 1 else (((cast,no_check(Int32) (((cast,no_check(Int64) cng_sig_q14[16 + i]) * cast(Int64) gain_q10) >> 16)) >> (((8 - 1)) & 31)) + 1) >> 1))))));
            i += 1;
        }
        copy_memory(ps_cng.cng_synth_state.data, *cng_sig_q14[length], cast(u64) 16 * size_of(Int32));
    } else {
        fill_memory(ps_cng.cng_synth_state.data, 0, cast,no_check(u64) ps_dec.lpc_order * size_of(Int32));
    }
}

silk_cng_exc :: (exc_q14: *Int32, exc_buf_q14: *Int32, length: s32, rand_seed: *Int32) {
    exc_mask: s32 = ---;

    exc_mask = 255;
    while exc_mask > length {
        exc_mask = exc_mask >> 1;
    }

    seed := rand_seed.*;
    if 0 < length {
        for i: 0..length - 1 {
            seed = cast,no_check(Int32) (907633515 + (cast,no_check(Uint32) seed) * 196314165);
            idx := seed >> 24 & exc_mask;

            exc_q14[i] = exc_buf_q14[idx];
        }
    }
    rand_seed.* = seed;
}

false_ :: () -> s32 {
    return 0;
}

Int32 :: s32;

Int16 :: s16;

Uint32 :: u32;

Int64 :: s64;

Ec_Ctx :: struct {
    buf: *u8;
    storage: Uint32;
    end_offs: Uint32;
    end_window: Ec_Window;
    nend_bits: s32;
    nbits_total: s32;
    offs: Uint32;
    rng: Uint32;
    val: Uint32;
    ext: Uint32;
    rem: s32;
    error: s32;
}

Silk_Decoder_State :: struct {
    prev_gain_q16: Int32 #align 8;
    exc_q14: [320] Int32 #align 1;
    s_lpc_q14_buf: [16] Int32 #align 1;
    out_buf: [480] Int16 #align 1;
    lag_prev: s32 #align 1;
    last_gain_index: Int8 #align 1;
    layout_padding_0: [3] u8 #align 1;
    fs_k_hz: s32 #align 1;
    fs_api_hz: Int32 #align 1;
    nb_subfr: s32 #align 1;
    frame_length: s32 #align 1;
    subfr_length: s32 #align 1;
    ltp_mem_length: s32 #align 1;
    lpc_order: s32 #align 1;
    prev_nlsf_q15: [16] Int16 #align 1;
    first_frame_after_reset: s32 #align 1;
    layout_padding_1: [4] u8 #align 1;
    pitch_lag_low_bits_i_cdf: *Uint8 #align 1;
    pitch_contour_i_cdf: *Uint8 #align 1;
    n_frames_decoded: s32 #align 1;
    n_frames_per_packet: s32 #align 1;
    ec_prev_signal_type: s32 #align 1;
    ec_prev_lag_index: Int16 #align 1;
    layout_padding_2: [2] u8 #align 1;
    vad_flags: [3] s32 #align 1;
    lbrr_flag: s32 #align 1;
    lbrr_flags: [3] s32 #align 1;
    layout_padding_3: [4] u8 #align 1;
    resampler_state: Silk_Resampler_State_Struct #align 1;
    ps_nlsf_cb: *Silk_NLSF_CB_Struct #align 1;
    indices: Side_Info_Indices #align 1;
    s_cng: Silk_CNG_Struct #align 1;
    loss_cnt: s32 #align 1;
    prev_signal_type: s32 #align 1;
    arch: s32 #align 1;
    s_plc: Silk_PLC_Struct #align 1;
    layout_padding_4: [4] u8 #align 1;
} #no_padding;

Silk_Decoder_Control :: struct {
    pitch_l: [4] s32;
    gains_q16: [4] Int32;
    pred_coef_q12: [2] [16] Int16;
    ltp_coef_q14: [20] Int16;
    ltp_scale_q14: s32;
}

Silk_CNG_Struct :: struct {
    cng_exc_buf_q14: [320] Int32;
    cng_smth_nlsf_q15: [16] Int16;
    cng_synth_state: [16] Int32;
    cng_smth_gain_q16: Int32;
    rand_seed: Int32;
    fs_k_hz: s32;
}

Ec_Window :: Uint32;

Int8 :: s8;

Uint8 :: u8;

Silk_Resampler_State_Struct :: struct {
    s_iir: [6] Int32 #align 8;
    s_fir: Silk_Resampler_State_Struct_S_FIR #align 1;
    delay_buf: [96] Int16 #align 1;
    resampler_function: s32 #align 1;
    batch_size: s32 #align 1;
    inv_ratio_q16: Int32 #align 1;
    fir_order: s32 #align 1;
    fir_fracs: s32 #align 1;
    fs_in_k_hz: s32 #align 1;
    fs_out_k_hz: s32 #align 1;
    input_delay: s32 #align 1;
    coefs: *Int16 #align 1;
} #no_padding;

Silk_NLSF_CB_Struct :: struct {
    n_vectors: Int16;
    order: Int16;
    quant_step_size_q16: Int16;
    inv_quant_step_size_q6: Int16;
    cb1_nlsf_q8: *Uint8;
    cb1_wght_q9: *Int16;
    cb1_i_cdf: *Uint8;
    pred_q8: *Uint8;
    ec_sel: *Uint8;
    ec_i_cdf: *Uint8;
    ec_rates_q5: *Uint8;
    delta_min_q15: *Int16;
}

Side_Info_Indices :: struct {
    gains_indices: [4] Int8;
    ltp_index: [4] Int8;
    nlsf_indices: [17] Int8;
    lag_index: Int16;
    contour_index: Int8;
    signal_type: Int8;
    quant_offset_type: Int8;
    nlsf_interp_coef_q2: Int8;
    per_index: Int8;
    ltp_scale_index: Int8;
    seed: Int8;
}

Silk_PLC_Struct :: struct {
    pitch_l_q8: Int32;
    ltp_coef_q14: [5] Int16;
    prev_lpc_q12: [16] Int16;
    last_frame_lost: s32;
    rand_seed: Int32;
    rand_scale_q14: Int16;
    conc_energy: Int32;
    conc_energy_shift: s32;
    prev_ltp_scale_q14: Int16;
    prev_gain_q16: [2] Int32;
    fs_k_hz: s32;
    nb_subfr: s32;
    subfr_length: s32;
    enable_deep_plc: s32;
}

Silk_Resampler_State_Struct_S_FIR :: union {
    i32: [36] Int32;
    i16: [36] Int16;
}

