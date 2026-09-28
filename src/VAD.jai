// Generated directly from C by cpp_transpiler.
TILT_WEIGHTS: [4] Int32;

silk_clz16_in_vad :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_vad :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_vad :: () -> s32 {
    return 0;
}

silk_ror32_in_vad :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_vad :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_vad :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_vad :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_vad :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_vad :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_vad :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_vad :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_vad :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_vad :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_vad(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_vad(in_upper);
    }
}

silk_clz_frac_in_vad :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_vad(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_vad(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_vad :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_vad(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_vad :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_vad((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_vad((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_vad :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_vad((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_vad :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_vad :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_vad :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_vad :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_vad :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_vad :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_vad_init :: (ps_silk_vad: *Silk_VAD_State) -> s32 {
    ret: s32 = 0;

    fill_memory(ps_silk_vad, 0, size_of(Silk_VAD_State));

    for b: 0..cast(s32) 4 - 1 {
        ps_silk_vad.noise_level_bias[b] = silk_max_32_in_vad(50 / (b + 1), 1);
    }

    for b: 0..cast(s32) 4 - 1 {
        ps_silk_vad.nl[b] = 100 * ps_silk_vad.noise_level_bias[b];
        ps_silk_vad.inv_nl[b] = 0x7fffffff / ps_silk_vad.nl[b];
    }
    ps_silk_vad.counter = 15;

    for b: 0..cast(s32) 4 - 1 {
        ps_silk_vad.nrg_ratio_smth_q8[b] = cast,no_check(Int32) ((100 * 256));
    }

    return ret;
}

silk_vad_get_sa_q8_c :: (ps_enc_c: *Silk_Encoder_State, p_in: *Int16) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    snr_q7: s32 = ---;
    s: s32 = ---;
    sum_squared: Int32 = ---;

    xnrg: [4] Int32 = ---;
    nrg_to_noise_ratio_q8: [4] Int32 = ---;
    speech_nrg, x_tmp: Int32 = ---;
    x_offset: [4] s32 = ---;
    ret: s32 = 0;
    ps_silk_vad := *ps_enc_c.s_vad;

    ((cast,no_check(s32) ((5 * 4))) * 16 >= ps_enc_c.frame_length);
    (ps_enc_c.frame_length <= 512);
    (ps_enc_c.frame_length == 8 * ps_enc_c.frame_length >> 3);

    decimated_framelength1 := ps_enc_c.frame_length >> 1;
    decimated_framelength2 := ps_enc_c.frame_length >> 2;
    decimated_framelength := ps_enc_c.frame_length >> 3;

    x_offset[0] = 0;
    x_offset[1] = decimated_framelength + decimated_framelength2;
    x_offset[2] = x_offset[1] + decimated_framelength;
    x_offset[3] = x_offset[2] + decimated_framelength2;
    x :=
        cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
            cast,no_check(u64) (x_offset[3] + decimated_framelength1))));

    silk_ana_filt_bank_1(p_in, ps_silk_vad.ana_state.data + 0, x, *x[x_offset[3]], ps_enc_c.frame_length);

    silk_ana_filt_bank_1(x, ps_silk_vad.ana_state1.data + 0, x, *x[x_offset[2]], decimated_framelength1);

    silk_ana_filt_bank_1(x, ps_silk_vad.ana_state2.data + 0, x, *x[x_offset[1]], decimated_framelength2);

    x[decimated_framelength - 1] = cast,no_check(Int16) ((cast(s32) x[decimated_framelength - 1]) >> 1);
    h_pstate_tmp := x[decimated_framelength - 1];
    i := decimated_framelength - 1;
    while i > 0 {
        x[i - 1] = cast,no_check(Int16) ((cast(s32) x[i - 1]) >> 1);
        x[i] = cast,no_check(Int16) ((cast,no_check(s32) x[i]) - cast,no_check(s32) x[i - 1]);
        i -= 1;
    }
    x[0] = cast,no_check(Int16) ((cast,no_check(s32) x[0]) - cast,no_check(s32) ps_silk_vad.h_pstate);
    ps_silk_vad.h_pstate = h_pstate_tmp;

    for b: 0..cast(s32) 4 - 1 {
        decimated_framelength =
            ps_enc_c.frame_length >> ((silk_min_int_in_vad(4 -
                b, cast,no_check(s32) (4 - 1))) & 31);

        dec_subframe_length := decimated_framelength >> 2;
        dec_subframe_offset: s32 = 0;

        xnrg[b] = ps_silk_vad.xnrg_subfr[b];
        s = 0;
        while s < (cast(s32) 1) << 2 {
            sum_squared = 0;
            i = 0;
            while i < dec_subframe_length {
                x_tmp = (cast(s32) x[x_offset[b] + i + dec_subframe_offset]) >> 3;
                sum_squared =
                    sum_squared +
                        (cast,no_check(Int32) (cast,no_check(Int16) x_tmp)) * cast,no_check(Int32) (cast,no_check(Int16) x_tmp);
                i += 1;
            }

            if s < (cast(s32) 1) << 2 - 1 {
                xnrg[b] =
                    ifx ((cast,no_check(Uint32) xnrg[b]) + cast,no_check(Uint32) sum_squared) & 0x80000000 != 0 then 0x7fffffff else xnrg[b] +
                        sum_squared;
            } else {
                xnrg[b] =
                    ifx ((cast,no_check(Uint32) xnrg[b]) + cast,no_check(Uint32) (sum_squared >> 1)) & 0x80000000 != 0 then 0x7fffffff else xnrg[b] +
                        sum_squared >> 1;
            }

            dec_subframe_offset += dec_subframe_length;
            s += 1;
        }
        ps_silk_vad.xnrg_subfr[b] = sum_squared;
    }

    silk_vad_get_noise_levels(xnrg.data + 0, ps_silk_vad);

    sum_squared = 0;
    input_tilt: s32 = 0;
    for b: 0..cast(s32) 4 - 1 {
        speech_nrg = xnrg[b] - ps_silk_vad.nl[b];
        if speech_nrg > 0 {
            if (cast,no_check(u32) xnrg[b]) & 0xff800000 == 0 {
                nrg_to_noise_ratio_q8[b] =
                    (cast,no_check(Int32) ((cast,no_check(Uint32) xnrg[b]) << 8)) /
                        (ps_silk_vad.nl[b] + 1);
            } else {
                nrg_to_noise_ratio_q8[b] = xnrg[b] / (ps_silk_vad.nl[b] >> 8 + 1);
            }

            snr_q7 = silk_lin2log(nrg_to_noise_ratio_q8[b]) - cast,no_check(Int32) ((8 * 128));

            sum_squared =
                sum_squared +
                    (cast,no_check(Int32) (cast,no_check(Int16) snr_q7)) * cast,no_check(Int32) (cast,no_check(Int16) snr_q7);

            if speech_nrg < (cast(s32) 1) << 20 {
                snr_q7 =
                    cast,no_check(Int32) (((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx_in_vad(speech_nrg)) << 6))) *
                        cast,no_check(Int64) (cast,no_check(Int16) snr_q7)) >> 16);
            }
            input_tilt =
                cast,no_check(Int32) ((cast(Int64) input_tilt) +
                    ((cast(Int64) TILT_WEIGHTS[b]) * cast,no_check(Int64) (cast,no_check(Int16) snr_q7)) >> 16);
        } else {
            nrg_to_noise_ratio_q8[b] = 256;
        }
    }

    sum_squared = sum_squared / 4;

    p_snr_d_b_q7 := cast,no_check(s32) (cast,no_check(Int16) (3 * silk_sqrt_approx_in_vad(sum_squared)));

    sa_q15 :=
        silk_sigm_q15(
            (cast,no_check(Int32) ((45000 * cast,no_check(Int64) (cast,no_check(Int16) p_snr_d_b_q7)) >> 16)) - 128
        );

    ps_enc_c.input_tilt_q15 = cast,no_check(Int32) ((cast,no_check(Uint32) (silk_sigm_q15(input_tilt) - 16384)) << 1);

    speech_nrg = 0;
    for b: 0..cast(s32) 4 - 1 {
        speech_nrg = cast,no_check(Int32) (speech_nrg + ((b + 1) * (xnrg[b] - ps_silk_vad.nl[b]) >> 4));
    }

    if ps_enc_c.frame_length == 20 * ps_enc_c.fs_k_hz {
        speech_nrg = speech_nrg >> 1;
    }

    if speech_nrg <= 0 {
        sa_q15 = sa_q15 >> 1;
    } else if speech_nrg < 16384 {
        speech_nrg = cast,no_check(Int32) ((cast,no_check(Uint32) speech_nrg) << 16);

        speech_nrg = silk_sqrt_approx_in_vad(speech_nrg);
        sa_q15 =
            cast,no_check(Int32) (((cast(Int64) (32768 + speech_nrg)) *
                cast,no_check(Int64) (cast,no_check(Int16) sa_q15)) >> 16);
    }

    ps_enc_c.speech_activity_q8 = silk_min_int_in_vad(sa_q15 >> 7, 0xff);

    smooth_coef_q16 :=
        cast,no_check(Int32) ((4096 *
            cast,no_check(Int64) (cast,no_check(Int16) (cast,no_check(Int32) (((cast(Int64) sa_q15) * cast,no_check(Int64) (cast,no_check(Int16) sa_q15)) >> 16)))) >> 16);

    if ps_enc_c.frame_length == 10 * ps_enc_c.fs_k_hz {
        c_transpiler_compound_shr(*(smooth_coef_q16), (cast(s32) 1), Int32, Int32);
    }

    for b: 0..cast(s32) 4 - 1 {
        ps_silk_vad.nrg_ratio_smth_q8[b] =
            cast,no_check(Int32) ((cast(Int64) ps_silk_vad.nrg_ratio_smth_q8[b]) +
                ((cast(Int64) (nrg_to_noise_ratio_q8[b] - ps_silk_vad.nrg_ratio_smth_q8[b])) * cast,no_check(Int64) (cast,no_check(Int16) smooth_coef_q16)) >> 16);

        snr_q7 = 3 * (silk_lin2log(ps_silk_vad.nrg_ratio_smth_q8[b]) - cast,no_check(Int32) ((8 * 128)));

        ps_enc_c.input_quality_bands_q15[b] = silk_sigm_q15((snr_q7 - cast,no_check(s32) ((16 * 128))) >> 4);
    }

    return ret;
}

silk_vad_get_noise_levels :: (p_x: *Int32, ps_silk_vad: *Silk_VAD_State) {
    min_coef: s32 = ---;

    if ps_silk_vad.counter < 1000 {
        min_coef = 0x7fff / (ps_silk_vad.counter >> 4 + 1);

        ps_silk_vad.counter += 1;
    } else {
        min_coef = 0;
    }

    for k: 0..cast(s32) 4 - 1 {
        nl := ps_silk_vad.nl[k];

        nrg :=
            (ifx ((cast,no_check(Uint32) p_x[k]) + cast,no_check(Uint32) ps_silk_vad.noise_level_bias[k]) & 0x80000000 != 0 then 0x7fffffff else p_x[k] +
                ps_silk_vad.noise_level_bias[k]);

        inv_nrg := 0x7fffffff / nrg;

        coef: s32 = ifx nrg > cast,no_check(Int32) ((cast,no_check(Uint32) nl) << 3)
            then (cast(s32) 1024) >> 3
            else ifx nrg < nl
                then cast(s32) 1024
                else cast,no_check(Int32) (((cast(Int64) (cast,no_check(Int32) (((cast,no_check(Int64) inv_nrg) * cast(Int64) nl) >> 16))) * cast,no_check(Int64) (cast,no_check(Int16) ((cast(s32) 1024) << 1))) >> 16);

        coef = silk_max_int_in_vad(coef, min_coef);

        ps_silk_vad.inv_nl[k] =
            cast,no_check(Int32) ((cast(Int64) ps_silk_vad.inv_nl[k]) +
                ((cast(Int64) (inv_nrg - ps_silk_vad.inv_nl[k])) * cast,no_check(Int64) (cast,no_check(Int16) coef)) >> 16);
        (ps_silk_vad.inv_nl[k] >= 0);

        nl = 0x7fffffff / ps_silk_vad.inv_nl[k];

        nl = ifx nl < 0xffffff then nl else 0xffffff;

        ps_silk_vad.nl[k] = nl;
    }
}

false__in_vad :: () -> s32 {
    return 0;
}

globals_initialization_state_for_vad: u32;
initialize_globals_for_vad :: () {
    {
        state := atomic_load(*globals_initialization_state_for_vad);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_vad, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_vad) != 2 {}
            return;
        }
    }
    TILT_WEIGHTS = Int32.[ 30000, 6000, -12000, -12000 ];
    atomic_store(*globals_initialization_state_for_vad, 2);
}

