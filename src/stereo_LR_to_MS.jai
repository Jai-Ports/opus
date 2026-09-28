silk_clz16_in_stereo_lr_to_ms :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_stereo_lr_to_ms :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_stereo_lr_to_ms :: () -> s32 {
    return 0;
}

silk_ror32_in_stereo_lr_to_ms :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_stereo_lr_to_ms :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_stereo_lr_to_ms :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_stereo_lr_to_ms :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_stereo_lr_to_ms :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_stereo_lr_to_ms :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_stereo_lr_to_ms :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_stereo_lr_to_ms :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_stereo_lr_to_ms :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_stereo_lr_to_ms :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_stereo_lr_to_ms(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_stereo_lr_to_ms(in_upper);
    }
}

silk_clz_frac_in_stereo_lr_to_ms :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_stereo_lr_to_ms(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_stereo_lr_to_ms(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_stereo_lr_to_ms :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_stereo_lr_to_ms(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_stereo_lr_to_ms :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_stereo_lr_to_ms((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_stereo_lr_to_ms((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_stereo_lr_to_ms :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_stereo_lr_to_ms((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_stereo_lr_to_ms :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_stereo_lr_to_ms :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_stereo_lr_to_ms :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_stereo_lr_to_ms :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_stereo_lr_to_ms :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_stereo_lr_to_ms :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_stereo_lr_to_ms :: (
    state: *Stereo_Enc_State,
    x1: *Int16,
    x2: *Int16,
    ix: *[3] Int8,
    mid_only_flag: *Int8,
    mid_side_rates_bps: *Int32,
    total_rate_bps: Int32,
    prev_speech_act_q8: s32,
    to_mono: s32,
    fs_k_hz: s32,
    frame_length: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    sum: Int32 = ---;
    pred_q13: [2] Int32 = ---;
    lp_ratio_q14: Int32 = ---;
    hp_ratio_q14: Int32 = ---;
    width_q14: Int32 = ---;

    mid := *x1[-2];

    side := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) (frame_length + 2))));

    n: s32 = 0;
    while n < frame_length + 2 {
        sum = (cast(Int32) x1[n - 2]) + cast,no_check(Int32) x2[n - 2];
        diff := (cast(Int32) x1[n - 2]) - cast,no_check(Int32) x2[n - 2];
        mid[n] = cast,no_check(Int16) ((ifx 1 == 1 then sum >> 1 + sum & 1 else (sum >> (((1 - 1)) & 31) + 1) >> 1));
        side[n] =
            cast,no_check(Int16) ((ifx (ifx 1 == 1 then diff >> 1 +
                diff & 1 else (diff >> (((1 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 1 == 1 then diff >> 1 + diff & 1 else (diff >> (((1 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 1 == 1 then diff >> 1 + diff & 1 else (diff >> (((1 - 1)) & 31) + 1) >> 1))));
        n += 1;
    }

    copy_memory(mid, state.s_mid.data, cast(u64) 2 * size_of(Int16));
    copy_memory(side, state.s_side.data, cast(u64) 2 * size_of(Int16));
    copy_memory(state.s_mid.data, *mid[frame_length], cast(u64) 2 * size_of(Int16));
    copy_memory(state.s_side.data, *side[frame_length], cast(u64) 2 * size_of(Int16));

    lp_mid := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) frame_length)));
    hp_mid := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) frame_length)));
    n = 0;
    while n < frame_length {
        sum =
            ifx 2 == 1 then ((((cast(Int32) mid[n]) + cast,no_check(Int32) mid[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) mid[n + 1]) << 1)) >> 1) +
                (((cast(Int32) mid[n]) + cast,no_check(Int32) mid[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) mid[n + 1]) << 1)) & 1 else (((((cast(Int32) mid[n]) + cast,no_check(Int32) mid[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) mid[n + 1]) << 1)) >> (((2 - 1)) & 31)) + 1) >> 1;
        lp_mid[n] = cast,no_check(Int16) sum;
        hp_mid[n] = cast,no_check(Int16) ((cast(Int32) mid[n + 1]) - sum);
        n += 1;
    }

    lp_side := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) frame_length)));
    hp_side := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) frame_length)));
    n = 0;
    while n < frame_length {
        sum =
            ifx 2 == 1 then ((((cast(Int32) side[n]) + cast,no_check(Int32) side[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) side[n + 1]) << 1)) >> 1) +
                (((cast(Int32) side[n]) + cast,no_check(Int32) side[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) side[n + 1]) << 1)) & 1 else (((((cast(Int32) side[n]) + cast,no_check(Int32) side[n + 2]) + cast,no_check(Int32) ((cast,no_check(Uint32) side[n + 1]) << 1)) >> (((2 - 1)) & 31)) + 1) >> 1;
        lp_side[n] = cast,no_check(Int16) sum;
        hp_side[n] = cast,no_check(Int16) ((cast(Int32) side[n + 1]) - sum);
        n += 1;
    }

    is10ms_frame := cast(s32) (frame_length == 10 * fs_k_hz);
    smooth_coef_q16: Int32 =
        (ifx is10ms_frame != 0 then cast,no_check(Int32) (cast(float64) 328.18) else cast,no_check(Int32) (cast(float64) 655.86));
    smooth_coef_q16 =
        cast,no_check(Int32) (((cast(Int64) ((cast,no_check(Int32) (cast,no_check(Int16) prev_speech_act_q8)) * cast,no_check(Int32) (cast,no_check(Int16) prev_speech_act_q8))) *
            cast,no_check(Int64) (cast,no_check(Int16) smooth_coef_q16)) >> 16);

    pred_q13[0] =
        silk_stereo_find_predictor(
            *lp_ratio_q14,
            lp_mid,
            lp_side,
            state.mid_side_amp_q0.data + 0,
            frame_length,
            smooth_coef_q16
        );
    pred_q13[1] =
        silk_stereo_find_predictor(
            *hp_ratio_q14,
            hp_mid,
            hp_side,
            state.mid_side_amp_q0.data + 2,
            frame_length,
            smooth_coef_q16
        );

    frac_q16 :=
        hp_ratio_q14 +
            (cast,no_check(Int32) (cast,no_check(Int16) lp_ratio_q14)) * cast,no_check(Int32) (cast(Int16) 3);
    frac_q16 =
        ifx frac_q16 < cast,no_check(Int32) (cast(float64) 65536.5) then frac_q16 else cast,no_check(Int32) (cast(float64) 65536.5);

    c_transpiler_compound_sub(*(total_rate_bps), ((ifx is10ms_frame != 0 then cast(s32) 1200 else 600)), s32, s32);
    if total_rate_bps < 1 {
        total_rate_bps = 1;
    }
    min_mid_rate_bps :=
        2000 +
            (cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz)) * cast,no_check(Int32) (cast(Int16) 600);

    frac_3_q16 := 3 * frac_q16;
    mid_side_rates_bps[0] =
        silk_div32_var_q_in_stereo_lr_to_ms(
            total_rate_bps,
            (cast,no_check(Int32) (cast(float64) 851968.5)) + frac_3_q16,
            cast,no_check(s32) (16 + 3)
        );

    if mid_side_rates_bps[0] < min_mid_rate_bps {
        mid_side_rates_bps[0] = min_mid_rate_bps;
        mid_side_rates_bps[1] = total_rate_bps - mid_side_rates_bps[0];

        width_q14 =
            silk_div32_var_q_in_stereo_lr_to_ms(
                (cast,no_check(Int32) ((cast,no_check(Uint32) mid_side_rates_bps[1]) << 1)) - min_mid_rate_bps,
                cast,no_check(Int32) (((cast(Int64) ((cast,no_check(Int32) (cast(float64) 65536.5)) + frac_3_q16)) *
                cast,no_check(Int64) (cast,no_check(Int16) min_mid_rate_bps)) >> 16),
                cast,no_check(s32) (14 + 2)
            );
        width_q14 =
            ifx 0 > cast,no_check(Int32) (cast(float64) 16384.5) then (ifx width_q14 > 0 then 0 else (ifx width_q14 < cast,no_check(Int32) (cast(float64) 16384.5) then cast,no_check(Int32) (cast(float64) 16384.5) else width_q14)) else (ifx width_q14 > cast,no_check(Int32) (cast(float64) 16384.5) then cast,no_check(Int32) (cast(float64) 16384.5) else (ifx width_q14 < 0 then 0 else width_q14));
    } else {
        mid_side_rates_bps[1] = total_rate_bps - mid_side_rates_bps[0];
        width_q14 = cast,no_check(Int32) (cast(float64) 16384.5);
    }

    state.smth_width_q14 =
        cast,no_check(Int16) (cast,no_check(Int32) ((cast(Int64) state.smth_width_q14) +
            ((cast(Int64) (width_q14 - cast(Int32) state.smth_width_q14)) * cast,no_check(Int64) (cast,no_check(Int16) smooth_coef_q16)) >> 16));

    mid_only_flag.* = 0;
    if to_mono != 0 {
        width_q14 = 0;
        pred_q13[0] = 0;
        pred_q13[1] = 0;
        silk_stereo_quant_pred(pred_q13.data, ix);
    } else if state.width_prev_q14 == 0 &&
        (8 * total_rate_bps < 13 * min_mid_rate_bps ||
            cast,no_check(Int32) (((cast(Int64) frac_q16) * cast,no_check(Int64) state.smth_width_q14) >> 16) < cast,no_check(Int32) (cast(float64) 819.7)) {
        pred_q13[0] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[0])) >> 14;
        pred_q13[1] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[1])) >> 14;
        silk_stereo_quant_pred(pred_q13.data, ix);

        width_q14 = 0;
        pred_q13[0] = 0;
        pred_q13[1] = 0;
        mid_side_rates_bps[0] = total_rate_bps;
        mid_side_rates_bps[1] = 0;
        mid_only_flag.* = 1;
    } else if state.width_prev_q14 != 0 &&
        (8 * total_rate_bps < 11 * min_mid_rate_bps ||
            cast,no_check(Int32) (((cast(Int64) frac_q16) * cast,no_check(Int64) state.smth_width_q14) >> 16) < cast,no_check(Int32) (cast(float64) 328.18)) {
        pred_q13[0] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[0])) >> 14;
        pred_q13[1] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[1])) >> 14;
        silk_stereo_quant_pred(pred_q13.data, ix);

        width_q14 = 0;
        pred_q13[0] = 0;
        pred_q13[1] = 0;
    } else if cast,no_check(s32) state.smth_width_q14 > cast,no_check(Int32) (cast(float64) 15565.3) {
        silk_stereo_quant_pred(pred_q13.data, ix);
        width_q14 = cast,no_check(Int32) (cast(float64) 16384.5);
    } else {
        pred_q13[0] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[0])) >> 14;
        pred_q13[1] =
            ((cast,no_check(Int32) state.smth_width_q14) *
                cast,no_check(Int32) (cast,no_check(Int16) pred_q13[1])) >> 14;
        silk_stereo_quant_pred(pred_q13.data, ix);
        width_q14 = cast,no_check(Int32) state.smth_width_q14;
    }

    if mid_only_flag.* == 1 {
        state.silent_side_len = cast,no_check(Int16) ((cast,no_check(s32) state.silent_side_len) + (frame_length - 8 * fs_k_hz));
        if cast,no_check(s32) state.silent_side_len < 5 * fs_k_hz {
            mid_only_flag.* = 0;
        } else {
            state.silent_side_len = 10000;
        }
    } else {
        state.silent_side_len = 0;
    }

    if mid_only_flag.* == 0 && mid_side_rates_bps[1] < 1 {
        mid_side_rates_bps[1] = 1;
        mid_side_rates_bps[0] = silk_max_int_in_stereo_lr_to_ms(1, total_rate_bps - mid_side_rates_bps[1]);
    }

    pred0_q13 := -(cast,no_check(s32) state.pred_prev_q13[0]);
    pred1_q13 := -(cast,no_check(s32) state.pred_prev_q13[1]);
    w_q24 := cast,no_check(Int32) ((cast,no_check(Uint32) state.width_prev_q14) << 10);
    denom_q16 := (cast,no_check(Int32) (((cast(s32) 1) << 16))) / (8 * fs_k_hz);
    delta0_q13 :=
        -((ifx 16 == 1 then (((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> 1) +
            ((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) & 1 else ((((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> (((16 - 1)) & 31)) + 1) >> 1));
    delta1_q13 :=
        -((ifx 16 == 1 then (((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> 1) +
            ((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) & 1 else ((((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> (((16 - 1)) & 31)) + 1) >> 1));
    deltaw_q24 :=
        cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast(Int64) (width_q14 - cast(Int32) state.width_prev_q14)) *
            cast,no_check(Int64) (cast,no_check(Int16) denom_q16)) >> 16))) << 10);
    n = 0;
    while n < 8 * fs_k_hz {
        pred0_q13 = cast,no_check(Int32) (pred0_q13 + delta0_q13);
        pred1_q13 = cast,no_check(Int32) (pred1_q13 + delta1_q13);
        w_q24 += deltaw_q24;
        sum =
            cast,no_check(Int32) ((cast,no_check(Uint32) (((cast(Int32) mid[n]) + cast,no_check(Int32) mid[n + 2]) +
                cast,no_check(Int32) ((cast,no_check(Uint32) mid[n + 1]) << 1))) << 9);
        sum =
            cast,no_check(Int32) ((cast(Int64) (cast,no_check(Int32) (((cast(Int64) w_q24) * cast,no_check(Int64) side[n + 1]) >> 16))) +
                ((cast(Int64) sum) * cast,no_check(Int64) (cast,no_check(Int16) pred0_q13)) >> 16);
        sum =
            cast,no_check(Int32) ((cast(Int64) sum) +
                ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) mid[n + 1])) << 11))) * cast,no_check(Int64) (cast,no_check(Int16) pred1_q13)) >> 16);
        x2[n - 1] =
            cast,no_check(Int16) ((ifx (ifx 8 == 1 then sum >> 1 +
                sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1))));
        n += 1;
    }

    pred0_q13 = -pred_q13[0];
    pred1_q13 = -pred_q13[1];
    w_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) width_q14) << 10);
    n = 8 * fs_k_hz;
    while n < frame_length {
        sum =
            cast,no_check(Int32) ((cast,no_check(Uint32) (((cast(Int32) mid[n]) + cast,no_check(Int32) mid[n + 2]) +
                cast,no_check(Int32) ((cast,no_check(Uint32) mid[n + 1]) << 1))) << 9);
        sum =
            cast,no_check(Int32) ((cast(Int64) (cast,no_check(Int32) (((cast(Int64) w_q24) * cast,no_check(Int64) side[n + 1]) >> 16))) +
                ((cast(Int64) sum) * cast,no_check(Int64) (cast,no_check(Int16) pred0_q13)) >> 16);
        sum =
            cast,no_check(Int32) ((cast(Int64) sum) +
                ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) mid[n + 1])) << 11))) * cast,no_check(Int64) (cast,no_check(Int16) pred1_q13)) >> 16);
        x2[n - 1] =
            cast,no_check(Int16) ((ifx (ifx 8 == 1 then sum >> 1 +
                sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1))));
        n += 1;
    }
    state.pred_prev_q13[0] = cast,no_check(Int16) pred_q13[0];
    state.pred_prev_q13[1] = cast,no_check(Int16) pred_q13[1];
    state.width_prev_q14 = cast,no_check(Int16) width_q14;
}

false__in_stereo_lr_to_ms :: () -> s32 {
    return 0;
}

