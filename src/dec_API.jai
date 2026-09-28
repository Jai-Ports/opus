// Generated directly from C by cpp_transpiler.
Silk_Decoder :: struct {
    channel_state: [2] Silk_Decoder_State #align 8;
    s_stereo: Stereo_Dec_State #align 1;
    n_channels_api: s32 #align 1;
    n_channels_internal: s32 #align 1;
    prev_decode_only_middle: s32 #align 1;
} #no_padding;

ec_range_bytes_in_dec_api :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_dec_api :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_dec_api :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_dec_api :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_dec_api :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_dec_api :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_load_osce_models :: (dec_state: *void, data: *u8, len: s32) -> s32 {
    return 0;
}

silk_get_decoder_size :: (dec_size_bytes: *s32) -> s32 {
    ret: s32 = 0;

    dec_size_bytes.* = cast,no_check(s32) (cast(u64) size_of(Silk_Decoder));

    return ret;
}

silk_reset_decoder_2 :: (dec_state: *void) -> s32 {
    ret: s32 = 0;
    channel_state := ((cast(*Silk_Decoder) dec_state).channel_state).data;

    for n: 0..cast(s32) 2 - 1 {
        ret = silk_reset_decoder(*channel_state[n]);
    }
    fill_memory(*((cast(*Silk_Decoder) dec_state).s_stereo), 0, size_of(Stereo_Dec_State));

    (cast(*Silk_Decoder) dec_state).prev_decode_only_middle = 0;

    return ret;
}

silk_init_decoder_2 :: (dec_state: *void) -> s32 {
    ret: s32 = 0;
    channel_state := ((cast(*Silk_Decoder) dec_state).channel_state).data;

    silk_load_osce_models(dec_state, null, 0);

    for n: 0..cast(s32) 2 - 1 {
        ret = silk_init_decoder(*channel_state[n]);
    }
    fill_memory(*((cast(*Silk_Decoder) dec_state).s_stereo), 0, size_of(Stereo_Dec_State));

    (cast(*Silk_Decoder) dec_state).prev_decode_only_middle = 0;

    return ret;
}

silk_decode :: (
    dec_state: *void,
    dec_control: *Silk_Dec_Control_Struct,
    lost_flag: s32,
    new_packet_flag: s32,
    ps_range_dec: *Ec_Dec,
    samples_out: *Res,
    n_samples_out: *Int32,
    arch: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;
    n: s32 = ---;
    decode_only_middle: s32 = 0;
    ret: s32 = 0;
    n_samples_out_dec, lbrr_symbol: Int32 = ---;
    samples_out1_tmp: [2] *Int16 = ---;

    ms_pred_q13: [2] Int32;

    ps_dec := cast(*Silk_Decoder) dec_state;
    channel_state := ps_dec.channel_state.data;

    (dec_control.n_channels_internal == 1 || dec_control.n_channels_internal == 2);

    if new_packet_flag != 0 {
        n = 0;
        while n < dec_control.n_channels_internal {
            channel_state[n].n_frames_decoded = 0;
            n += 1;
        }
    }

    if dec_control.n_channels_internal > ps_dec.n_channels_internal {
        ret += silk_init_decoder(*channel_state[1]);
    }

    stereo_to_mono :=
        cast(s32) (dec_control.n_channels_internal == 1 && ps_dec.n_channels_internal == 2 &&
            dec_control.internal_sample_rate == 1000 * channel_state[0].fs_k_hz);

    if channel_state[0].n_frames_decoded == 0 {
        n = 0;
        while n < dec_control.n_channels_internal {
            if dec_control.payload_size_ms == 0 {
                channel_state[n].n_frames_per_packet = 1;
                channel_state[n].nb_subfr = 2;
            } else if dec_control.payload_size_ms == 10 {
                channel_state[n].n_frames_per_packet = 1;
                channel_state[n].nb_subfr = 2;
            } else if dec_control.payload_size_ms == 20 {
                channel_state[n].n_frames_per_packet = 1;
                channel_state[n].nb_subfr = 4;
            } else if dec_control.payload_size_ms == 40 {
                channel_state[n].n_frames_per_packet = 2;
                channel_state[n].nb_subfr = 4;
            } else if dec_control.payload_size_ms == 60 {
                channel_state[n].n_frames_per_packet = 3;
                channel_state[n].nb_subfr = 4;
            } else {
                return -203;
            }
            fs_k_hz_dec := dec_control.internal_sample_rate >> 10 + 1;
            if fs_k_hz_dec != 8 && fs_k_hz_dec != 12 && fs_k_hz_dec != 16 {
                return -200;
            }
            ret += silk_decoder_set_fs(*channel_state[n], fs_k_hz_dec, dec_control.api_sample_rate);
            n += 1;
        }
    }

    if dec_control.n_channels_api == 2 &&
        dec_control.n_channels_internal == 2 &&
        (ps_dec.n_channels_api == 1 || ps_dec.n_channels_internal == 1) {
        fill_memory(ps_dec.s_stereo.pred_prev_q13.data, 0, ps_dec.s_stereo.pred_prev_q13.count * size_of(Int16));
        fill_memory(ps_dec.s_stereo.s_side.data, 0, ps_dec.s_stereo.s_side.count * size_of(Int16));
        copy_memory(
            *channel_state[1].resampler_state,
            *channel_state[0].resampler_state,
            size_of(Silk_Resampler_State_Struct)
        );
    }
    ps_dec.n_channels_api = dec_control.n_channels_api;
    ps_dec.n_channels_internal = dec_control.n_channels_internal;

    if dec_control.api_sample_rate > (cast(s32) 48) * 1000 || dec_control.api_sample_rate < 8000 {
        ret = -200;

        return ret;
    }

    if lost_flag != 1 && channel_state[0].n_frames_decoded == 0 {
        n = 0;
        while n < dec_control.n_channels_internal {
            i = 0;
            while i < channel_state[n].n_frames_per_packet {
                channel_state[n].vad_flags[i] = ec_dec_bit_logp(ps_range_dec, 1);
                i += 1;
            }
            channel_state[n].lbrr_flag = ec_dec_bit_logp(ps_range_dec, 1);
            n += 1;
        }

        n = 0;
        while n < dec_control.n_channels_internal {
            fill_memory(channel_state[n].lbrr_flags.data, 0, 3 * cast(u64) size_of(s32));
            if channel_state[n].lbrr_flag != 0 {
                if channel_state[n].n_frames_per_packet == 1 {
                    channel_state[n].lbrr_flags[0] = 1;
                } else {
                    lbrr_symbol =
                        ec_dec_icdf(
                            ps_range_dec,
                            SILK_LBRR_FLAGS_I_CDF_PTR[channel_state[n].n_frames_per_packet - 2],
                            8
                        ) + 1;
                    i = 0;
                    while i < channel_state[n].n_frames_per_packet {
                        channel_state[n].lbrr_flags[i] = lbrr_symbol >> ((i) & 31) & 1;
                        i += 1;
                    }
                }
            }
            n += 1;
        }

        if lost_flag == 0 {
            i = 0;
            while i < channel_state[0].n_frames_per_packet {
                n = 0;
                while n < dec_control.n_channels_internal {
                    if channel_state[n].lbrr_flags[i] != 0 {
                        pulses: [320] Int16 = ---;

                        if dec_control.n_channels_internal == 2 && n == 0 {
                            silk_stereo_decode_pred(ps_range_dec, ms_pred_q13.data);
                            if channel_state[1].lbrr_flags[i] == 0 {
                                silk_stereo_decode_mid_only(ps_range_dec, *decode_only_middle);
                            }
                        }

                        cond_coding: s32 = ifx i > 0 && channel_state[n].lbrr_flags[i - 1] != 0
                            then cast(s32) 2
                            else 0;
                        silk_decode_indices(*channel_state[n], ps_range_dec, i, 1, cond_coding);
                        silk_decode_pulses(
                            ps_range_dec,
                            pulses.data,
                            cast,no_check(s32) channel_state[n].indices.signal_type,
                            cast,no_check(s32) channel_state[n].indices.quant_offset_type,
                            channel_state[n].frame_length
                        );
                    }
                    n += 1;
                }
                i += 1;
            }
        }
    }

    if dec_control.n_channels_internal == 2 {
        if lost_flag == 0 || lost_flag == 2 && channel_state[0].lbrr_flags[channel_state[0].n_frames_decoded] == 1 {
            silk_stereo_decode_pred(ps_range_dec, ms_pred_q13.data);

            if lost_flag == 0 && channel_state[1].vad_flags[channel_state[0].n_frames_decoded] == 0 ||
                lost_flag == 2 && channel_state[1].lbrr_flags[channel_state[0].n_frames_decoded] == 0 {
                silk_stereo_decode_mid_only(ps_range_dec, *decode_only_middle);
            } else {
                decode_only_middle = 0;
            }
        } else {
            n = 0;
            while n < 2 {
                ms_pred_q13[n] = cast,no_check(Int32) ps_dec.s_stereo.pred_prev_q13[n];
                n += 1;
            }
        }
    }

    if dec_control.n_channels_internal == 2 && decode_only_middle == 0 && ps_dec.prev_decode_only_middle == 1 {
        fill_memory(ps_dec.channel_state[1].out_buf.data, 0, 480 * cast(u64) size_of(Int16));
        fill_memory(ps_dec.channel_state[1].s_lpc_q14_buf.data, 0, 16 * cast(u64) size_of(Int32));
        ps_dec.channel_state[1].lag_prev = 100;
        ps_dec.channel_state[1].last_gain_index = 10;
        ps_dec.channel_state[1].prev_signal_type = 0;
        ps_dec.channel_state[1].first_frame_after_reset = 1;
    }

    samples_out1_tmp_storage1 :=
        cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
            cast,no_check(u64) (dec_control.n_channels_internal * (channel_state[0].frame_length + 2)))));
    samples_out1_tmp[0] = samples_out1_tmp_storage1;
    samples_out1_tmp[1] = samples_out1_tmp_storage1 + channel_state[0].frame_length + 2;

    has_side: s32 = ifx lost_flag == 0
        then cast(s32) (decode_only_middle == 0)
        else cast(s32) (ps_dec.prev_decode_only_middle == 0 || dec_control.n_channels_internal == 2 && lost_flag == 2 && channel_state[1].lbrr_flags[channel_state[1].n_frames_decoded] == 1);
    channel_state[0].s_plc.enable_deep_plc = dec_control.enable_deep_plc;

    n = 0;
    while n < dec_control.n_channels_internal {
        if n == 0 || has_side != 0 {
            frame_index := channel_state[0].n_frames_decoded - n;

            cond_coding: s32 = ifx frame_index <= 0
                then cast(s32) 0
                else ifx lost_flag == 2
                    then (ifx channel_state[n].lbrr_flags[frame_index - 1] != 0 then cast(s32) 2 else 0)
                    else ifx n > 0 && ps_dec.prev_decode_only_middle != 0
                        then cast(s32) 1
                        else 2;

            ret +=
                silk_decode_frame(
                    *channel_state[n],
                    ps_range_dec,
                    *samples_out1_tmp[n][2],
                    *n_samples_out_dec,
                    lost_flag,
                    cond_coding,
                    arch
                );
        } else {
            fill_memory(*samples_out1_tmp[n][2], 0, cast,no_check(u64) n_samples_out_dec * size_of(Int16));
        }
        channel_state[n].n_frames_decoded += 1;
        n += 1;
    }

    if dec_control.n_channels_api == 2 && dec_control.n_channels_internal == 2 {
        (cast,no_check(#type (_: *Stereo_Dec_State, _: *Int16, _: *Int16, _: *Int32, _: s32, _: s32)) (cast(*void) silk_stereo_ms_to_lr))(
            *ps_dec.s_stereo,
            samples_out1_tmp[0],
            samples_out1_tmp[1],
            ms_pred_q13.data,
            channel_state[0].fs_k_hz,
            n_samples_out_dec
        );
    } else {
        copy_memory(samples_out1_tmp[0], ps_dec.s_stereo.s_mid.data, cast(u64) 2 * size_of(Int16));
        copy_memory(ps_dec.s_stereo.s_mid.data, *samples_out1_tmp[0][n_samples_out_dec], cast(u64) 2 * size_of(Int16));
    }

    n_samples_out.* =
        n_samples_out_dec * dec_control.api_sample_rate /
            ((cast,no_check(Int32) (cast,no_check(Int16) channel_state[0].fs_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000));

    samples_out2_tmp :=
        cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
            cast,no_check(u64) n_samples_out.*)));
    resample_out_ptr := samples_out2_tmp;

    n = 0;
    while n < (ifx dec_control.n_channels_api < dec_control.n_channels_internal then dec_control.n_channels_api else dec_control.n_channels_internal) {
        ret +=
            silk_resampler(
                *channel_state[n].resampler_state,
                resample_out_ptr,
                *samples_out1_tmp[n][1],
                n_samples_out_dec
            );

        if dec_control.n_channels_api == 2 {
            i = 0;
            while i < n_samples_out.* {
                samples_out[n + 2 * i] = (cast,no_check(float32) resample_out_ptr[i]) * cast(float32) 0.000030517578125;
                i += 1;
            }
        } else {
            i = 0;
            while i < n_samples_out.* {
                samples_out[i] = (cast,no_check(float32) resample_out_ptr[i]) * cast(float32) 0.000030517578125;
                i += 1;
            }
        }
        n += 1;
    }

    if dec_control.n_channels_api == 2 && dec_control.n_channels_internal == 1 {
        if stereo_to_mono != 0 {
            ret +=
                silk_resampler(
                    *channel_state[1].resampler_state,
                    resample_out_ptr,
                    *samples_out1_tmp[0][1],
                    n_samples_out_dec
                );

            i = 0;
            while i < n_samples_out.* {
                samples_out[1 + 2 * i] = (cast,no_check(float32) resample_out_ptr[i]) * cast(float32) 0.000030517578125;
                i += 1;
            }
        } else {
            i = 0;
            while i < n_samples_out.* {
                samples_out[1 + 2 * i] = samples_out[0 + 2 * i];
                i += 1;
            }
        }
    }

    if channel_state[0].prev_signal_type == 2 {
        mult_tab := s32.[ 6, 4, 3 ];
        dec_control.prev_pitch_lag = channel_state[0].lag_prev * mult_tab[(channel_state[0].fs_k_hz - 8) >> 2];
    } else {
        dec_control.prev_pitch_lag = 0;
    }

    if lost_flag == 1 {
        i = 0;
        while i < ps_dec.n_channels_internal {
            ps_dec.channel_state[i].last_gain_index = 10;
            i += 1;
        }
    } else {
        ps_dec.prev_decode_only_middle = decode_only_middle;
    }

    return ret;
}

silk_clz16_in_dec_api :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_dec_api :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_dec_api :: () -> s32 {
    return 0;
}

silk_ror32_in_dec_api :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_dec_api :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_dec_api :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_dec_api :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_dec_api :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_dec_api :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_dec_api :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_dec_api :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_dec_api :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_dec_api :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_dec_api(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_dec_api(in_upper);
    }
}

silk_clz_frac_in_dec_api :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_dec_api(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_dec_api(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_dec_api :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_dec_api(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_dec_api :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_dec_api((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_dec_api((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_dec_api :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_dec_api((ifx B32 > 0 then B32 else -B32)) - 1;
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

false__in_dec_api :: () -> s32 {
    return 0;
}

alloc_ :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_dec_api :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch :: (size: u64) -> *void {
    return alloc_(size);
}

deallocate_memory :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

Res :: float32;

Stereo_Dec_State :: struct {
    pred_prev_q13: [2] Int16;
    s_mid: [2] Int16;
    s_side: [2] Int16;
}

Silk_Dec_Control_Struct :: struct {
    n_channels_api: Int32;
    n_channels_internal: Int32;
    api_sample_rate: Int32;
    internal_sample_rate: Int32;
    payload_size_ms: s32;
    prev_pitch_lag: s32;
    enable_deep_plc: s32;
}

