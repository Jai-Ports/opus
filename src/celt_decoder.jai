Custom_Decoder_in_celt_decoder :: struct {
    mode: *Custom_Mode;
    overlap: s32;
    channels: s32;
    stream_channels: s32;
    downsample: s32;
    start: s32;
    end: s32;
    signalling: s32;
    disable_inv: s32;
    complexity: s32;
    arch: s32;
    rng: Uint32;
    error: s32;
    last_pitch_index: s32;
    loss_duration: s32;
    plc_duration: s32;
    last_frame_type: s32;
    skip_plc: s32;
    postfilter_period: s32;
    postfilter_period_old: s32;
    postfilter_gain: Val16;
    postfilter_gain_old: Val16;
    postfilter_tapset: s32;
    postfilter_tapset_old: s32;
    prefilter_and_fold: s32;
    preemph_mem_d: [2] Celt_Sig;
    decode_mem: [1] Celt_Sig;
}

TRIM_ICDF_in_celt_decoder: [11] u8;

SPREAD_ICDF_in_celt_decoder: [4] u8;

TAPSET_ICDF_in_celt_decoder: [3] u8;

select_arch_in_celt_decoder :: () -> s32 {
    return 0;
}

alloc__in_celt_decoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_celt_decoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_celt_decoder :: (size: u64) -> *void {
    return alloc__in_celt_decoder(size);
}

free__in_celt_decoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

custom_decoder_get_size :: (mode: *Custom_Mode, channels: s32) -> s32 {
    size :=
        cast,no_check(s32) (size_of(Custom_Decoder_in_celt_decoder) + (cast,no_check(u64) (channels * (2048 + mode.overlap) - 1)) * size_of(Celt_Sig) +
            (cast,no_check(u64) ((cast,no_check(s32) ((4 * 2))) * mode.nb_e_bands)) * size_of(Celt_Glog) + (cast,no_check(u64) (channels * 24)) * size_of(Val16));
    return size;
}

custom_decoder_init :: (st: *Custom_Decoder_in_celt_decoder, mode: *Custom_Mode, channels: s32) -> s32 {
    if channels < 0 || channels > 2 {
        return -1;
    }

    if st == null {
        return -7;
    }

    fill_memory(cast(*s8) st, 0, cast,no_check(u64) custom_decoder_get_size(mode, channels));

    st.mode = mode;
    st.overlap = mode.overlap;
    st.channels = channels;
    st.stream_channels = st.channels;

    st.downsample = 1;
    st.start = 0;
    st.end = st.mode.eff_e_bands;
    st.signalling = 1;

    st.disable_inv = cast(s32) (channels == 1);

    st.arch = select_arch_in_celt_decoder();

    custom_decoder_ctl(st, 4028);

    return 0;
}

custom_decoder_ctl :: (st: *Custom_Decoder_in_celt_decoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ap: Va_List = ---;
    value: Int32 = ---;
    value_2: *Int32 = ---;
    value_3: Int32 = ---;
    value_4: Int32 = ---;
    value_5: Int32 = ---;
    value_6: *Int32 = ---;
    value_7: *Int32 = ---;
    i: s32 = ---;
    old_band_e: *Celt_Glog = ---;
    old_log_e: *Celt_Glog = ---;
    old_log_e2: *Celt_Glog = ---;
    decode_buffer_size: s32 = ---;
    value_8: *Int32 = ---;
    value_9: **Custom_Mode = ---;
    value_10: Int32 = ---;
    value_11: *Uint32 = ---;
    value_12: Int32 = ---;
    value_13: *Int32 = ---;
    code_block_to_execute: s64 = 105;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 20; {
                return -1;
            }
            case 22; {
                return 0;
            }
            case 55; {
                while c_transpiler_local_loop := true {
                    if i < 2 * st.mode.nb_e_bands {
                        old_log_e2[i] = -28.0;
                        old_log_e[i] = old_log_e2[i];
                        i += 1;
                        continue c_transpiler_local_loop;
                    } else {
                        st.skip_plc = 1;
                        st.last_frame_type = 0;
                        code_block_to_execute = 22;
                        continue c_transpiler_dispatch;
                    }
                }
            }
            case 105; {
                start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
                c_transpiler_switch_value_105 := request;
                if c_transpiler_switch_value_105 == {
                    case cast(s32) 4010; {
                        value = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value < 0 || value > 10 {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            st.complexity = value;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4011; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_2 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_2.* = st.complexity;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10010; {
                        value_3 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_3 < 0 || value_3 >= st.mode.nb_e_bands {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            st.start = value_3;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10012; {
                        value_4 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_4 < 1 || value_4 > st.mode.nb_e_bands {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            st.end = value_4;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10008; {
                        value_5 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_5 < 1 || value_5 > 2 {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            st.stream_channels = value_5;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10007; {
                        value_6 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_6 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_6.* = st.error;
                            st.error = 0;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4027; {
                        value_7 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_7 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_7.* = st.overlap / st.downsample;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4028; {
                        decode_buffer_size = 2048;
                        old_band_e = st.decode_mem.data + (decode_buffer_size + st.overlap) * st.channels;
                        old_log_e = old_band_e + 2 * st.mode.nb_e_bands;
                        old_log_e2 = old_log_e + 2 * st.mode.nb_e_bands;
                        fill_memory(
                            cast(*s8) *st.rng,
                            0,
                            cast,no_check(u64) ((cast(s64) custom_decoder_get_size(st.mode, st.channels)) -
                            ((cast(*s8) *st.rng) - cast(*s8) st))
                        );
                        i = 0;
                        code_block_to_execute = 55;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4033; {
                        value_8 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_8 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_8.* = st.postfilter_period;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10015; {
                        value_9 = c_transpiler_va_arg(cast(*void) (ap.data), **Custom_Mode);
                        if value_9 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_9.* = st.mode;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10016; {
                        value_10 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.signalling = value_10;
                        code_block_to_execute = 22;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4031; {
                        value_11 = c_transpiler_va_arg(cast(*void) (ap.data), *Uint32);
                        if value_11 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_11.* = st.rng;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4046; {
                        value_12 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_12 < 0 || value_12 > 1 {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            st.disable_inv = value_12;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4047; {
                        value_13 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_13 == null {
                            code_block_to_execute = 20;
                            continue c_transpiler_dispatch;
                        } else {
                            value_13.* = st.disable_inv;
                            code_block_to_execute = 22;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case; {
                        return -5;
                    }
                }
            }
        }
        assert(false, tprint("invalid code block to execute %", code_block_to_execute));
        break;
    }
    return unreachable_value(s32);
}

ec_range_bytes_in_celt_decoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_celt_decoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_celt_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_celt_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_celt_decoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_celt_decoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

bits_to_bitrate_in_celt_decoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_celt_decoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

celt_decoder_get_size :: (channels: s32) -> s32 {
    mode := custom_mode_create(48000, 960, null);

    return custom_decoder_get_size(mode, channels);
}

celt_decoder_init :: (st: *Custom_Decoder_in_celt_decoder, sampling_rate: Int32, channels: s32) -> s32 {
    ret := custom_decoder_init(st, custom_mode_create(48000, 960, null), channels);
    if ret != 0 {
        return ret;
    }
    st.downsample = resampling_factor(sampling_rate);
    if st.downsample == 0 {
        return -1;
    } else {
        return 0;
    }
}

celt_decode_with_ec_dred :: (
    st: *Custom_Decoder_in_celt_decoder,
    data: *u8,
    len: s32,
    pcm: *Res,
    frame_size: s32,
    dec: *Ec_Dec,
    accum: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    dec_ec_ctx: Ec_Dec = ---;

    decode_mem: [2] *Celt_Sig = ---;
    out_syn: [2] *Celt_Sig = ---;

    is_transient: s32 = ---;

    CC := st.channels;
    lm: s32 = ---;

    intensity: s32 = 0;
    dual_stereo: s32 = 0;

    balance: Int32 = ---;

    anti_collapse_on: s32 = 0;

    c_value := st.stream_channels;

    decode_buffer_size: s32 = 2048;

    mode := st.mode;
    nb_e_bands := mode.nb_e_bands;
    overlap := mode.overlap;
    e_bands := mode.e_bands;
    start := st.start;
    end := st.end;
    frame_size *= st.downsample;

    old_band_e := st.decode_mem.data + (decode_buffer_size + overlap) * CC;
    old_log_e := old_band_e + 2 * nb_e_bands;
    old_log_e2 := old_log_e + 2 * nb_e_bands;
    background_log_e := old_log_e2 + 2 * nb_e_bands;

    lm = 0;
    while lm <= mode.max_lm {
        if mode.short_mdct_size << ((lm) & 31) == frame_size {
            break;
        }
        lm += 1;
    }
    if lm > mode.max_lm {
        return -1;
    }
    m := (cast(s32) 1) << ((lm) & 31);

    if len < 0 || len > 1275 || pcm == null {
        return -1;
    }

    n := m * mode.short_mdct_size;
    c: s32 = 0;
    while true {
        decode_mem[c] = st.decode_mem.data + c * (decode_buffer_size + overlap);
        out_syn[c] = decode_mem[c] + decode_buffer_size - n;
        if !(c_transpiler_pre_increment(*(c)) < CC) break;
    }

    eff_end := end;
    if eff_end > mode.eff_e_bands {
        eff_end = mode.eff_e_bands;
    }

    if data == null || len <= 1 {
        celt_decode_lost(st, n, lm);
        deemphasis(out_syn.data, pcm, n, CC, st.downsample, mode.preemph.data, st.preemph_mem_d.data, accum);

        return frame_size / st.downsample;
    }

    if st.loss_duration == 0 {
        st.skip_plc = 0;
    }

    if dec == null {
        ec_dec_init(*dec_ec_ctx, data, cast,no_check(Uint32) len);
        dec = *dec_ec_ctx;
    }

    if c_value == 1 {
        i = 0;
        while i < nb_e_bands {
            old_band_e[i] =
                ifx c_transpiler_float_greater(old_band_e[i], old_band_e[nb_e_bands + i]) then old_band_e[i] else old_band_e[nb_e_bands +
                    i];
            i += 1;
        }
    }

    total_bits := len * 8;
    tell := ec_tell_in_celt_decoder(dec);

    silence: s32 = ifx tell >= total_bits
        then cast(s32) 1
        else ifx tell == 1
            then ec_dec_bit_logp(dec, 15)
            else 0;
    if silence != 0 {
        tell = len * 8;
        c_transpiler_compound_add(*(dec.nbits_total), ((tell - ec_tell_in_celt_decoder(dec))), s32, s32);
    }

    postfilter_gain: Val16 = 0.0;
    postfilter_pitch: s32 = 0;
    postfilter_tapset: s32 = 0;
    if start == 0 && tell + 16 <= total_bits {
        if ec_dec_bit_logp(dec, 1) != 0 {
            octave: s32 = ---;
            octave = cast,no_check(s32) ec_dec_uint(dec, 6);
            postfilter_pitch =
                cast,no_check(s32) (((cast,no_check(Uint32) ((cast(s32) 16) << ((octave) & 31))) + ec_dec_bits(dec, cast,no_check(u32) (4 + octave))) -
                    1);
            qg := cast,no_check(s32) ec_dec_bits(dec, 3);
            if ec_tell_in_celt_decoder(dec) + 2 <= total_bits {
                postfilter_tapset = ec_dec_icdf(dec, TAPSET_ICDF_in_celt_decoder.data, 2);
            }
            postfilter_gain = 0.09375 * cast,no_check(float32) (qg + 1);
        }
        tell = ec_tell_in_celt_decoder(dec);
    }

    if lm > 0 && tell + 3 <= total_bits {
        is_transient = ec_dec_bit_logp(dec, 3);
        tell = ec_tell_in_celt_decoder(dec);
    } else {
        is_transient = 0;
    }

    short_blocks: s32 = ifx is_transient != 0
        then m
        else 0;

    intra_ener := (ifx tell + 3 <= total_bits then ec_dec_bit_logp(dec, 3) else 0);

    if intra_ener == 0 && st.loss_duration != 0 {
        c = 0;
        while true {
            {
                safety: Celt_Glog = 0.0;
                missing := (ifx 10 < st.loss_duration >> ((lm) & 31) then 10 else st.loss_duration >> ((lm) & 31));
                if lm == 0 {
                    safety = 1.5;
                } else if lm == 1 {
                    safety = 0.5;
                }
                i = start;
                while i < end {
                    if c_transpiler_float_less(old_band_e[c * nb_e_bands + i], (ifx c_transpiler_float_greater(old_log_e[c * nb_e_bands + i], old_log_e2[c * nb_e_bands + i]) then old_log_e[c * nb_e_bands + i] else old_log_e2[c * nb_e_bands + i])) {
                        e0: Val32 = ---;
                        e0 = old_band_e[c * nb_e_bands + i];
                        e1 := old_log_e[c * nb_e_bands + i];
                        e2 := old_log_e2[c * nb_e_bands + i];
                        slope :=
                            (ifx c_transpiler_float_greater((e1 - e0), (0.5 * (e2 - e0))) then e1 -
                                e0 else 0.5 * (e2 - e0));
                        slope = ifx c_transpiler_float_less(slope, 2.0) then slope else 2.0;
                        e0 -=
                            (ifx c_transpiler_float_greater(0.0, ((1 + missing) * slope)) then 0.0 else (1 + missing) *
                                slope);
                        old_band_e[c * nb_e_bands + i] = ifx c_transpiler_float_greater(-20.0, e0) then -20.0 else e0;
                    } else {
                        old_band_e[c * nb_e_bands + i] =
                            ifx c_transpiler_float_less((ifx c_transpiler_float_less(old_band_e[c * nb_e_bands + i], old_log_e[c * nb_e_bands + i]) then old_band_e[c * nb_e_bands + i] else old_log_e[c * nb_e_bands + i]), old_log_e2[c * nb_e_bands + i]) then (ifx c_transpiler_float_less(old_band_e[c * nb_e_bands + i], old_log_e[c * nb_e_bands + i]) then old_band_e[c * nb_e_bands + i] else old_log_e[c * nb_e_bands + i]) else old_log_e2[c * nb_e_bands +
                                i];
                    }

                    old_band_e[c * nb_e_bands + i] -= safety;
                    i += 1;
                }
            }
            if !(c_transpiler_pre_increment(*(c)) < 2) break;
        }
    }

    unquant_coarse_energy(mode, start, end, old_band_e, intra_ener, dec, c_value, lm);

    tf_res := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    tf_decode(start, end, is_transient, tf_res, lm, dec);

    tell = ec_tell_in_celt_decoder(dec);
    spread_decision: s32 = 2;
    if tell + 4 <= total_bits {
        spread_decision = ec_dec_icdf(dec, SPREAD_ICDF_in_celt_decoder.data, 5);
    }

    cap := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    init_caps(mode, cap, lm, c_value);

    offsets := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    dynalloc_logp: s32 = 6;
    c_transpiler_compound_shl(*(total_bits), (cast(s32) 3), Int32, Int32);
    tell = cast,no_check(Int32) ec_tell_frac(dec);
    i = start;
    while i < end {
        width := (c_value * ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i])) << ((lm) & 31);

        quanta :=
            (ifx width << 3 < (ifx (cast(s32) 6) << 3 > width then (cast(s32) 6) << 3 else width) then width << 3 else (ifx (cast(s32) 6) << 3 > width then (cast(s32) 6) << 3 else width));
        dynalloc_loop_logp := dynalloc_logp;
        boost: s32 = 0;
        while tell + dynalloc_loop_logp << 3 < total_bits && boost < cap[i] {
            flag := ec_dec_bit_logp(dec, cast,no_check(u32) dynalloc_loop_logp);
            tell = cast,no_check(Int32) ec_tell_frac(dec);
            if flag == 0 {
                break;
            }
            boost += quanta;
            total_bits = cast,no_check(Int32) (total_bits - quanta);
            dynalloc_loop_logp = 1;
        }
        offsets[i] = boost;

        if boost > 0 {
            dynalloc_logp = ifx 2 > dynalloc_logp - 1 then 2 else dynalloc_logp - 1;
        }
        i += 1;
    }

    fine_quant := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    alloc_trim :=
        (ifx (tell +
            cast,no_check(Int32) (((cast(s32) 6) << 3))) <= total_bits then ec_dec_icdf(dec, TRIM_ICDF_in_celt_decoder.data, 7) else 5);

    bits := ((len * 8) << 3 - cast,no_check(Int32) ec_tell_frac(dec)) - 1;
    anti_collapse_rsv: s32 = (ifx is_transient != 0 && lm >= 2 && bits >= (lm + 2) << 3 then (cast(s32) 1) << 3 else 0);
    bits = cast,no_check(Int32) (bits - anti_collapse_rsv);

    pulses := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    fine_priority := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    coded_bands :=
        clt_compute_allocation(
            mode,
            start,
            end,
            offsets,
            cap,
            alloc_trim,
            *intensity,
            *dual_stereo,
            bits,
            *balance,
            pulses,
            fine_quant,
            fine_priority,
            c_value,
            lm,
            dec,
            0,
            0,
            0
        );

    unquant_fine_energy(mode, start, end, old_band_e, null, fine_quant, dec, c_value);

    x := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) (c_value * n))));

    c = 0;
    while true {
        move_memory(
            decode_mem[c],
            decode_mem[c] + n,
            (cast,no_check(u64) (decode_buffer_size - n + overlap)) * size_of(Celt_Sig) +
            cast,no_check(u64) (0 * (decode_mem[c] - (decode_mem[c] + n)))
        );
        if !(c_transpiler_pre_increment(*(c)) < CC) break;
    }

    collapse_masks :=
        cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) *
            cast,no_check(u64) (c_value * nb_e_bands))));

    quant_all_bands(
        0,
        mode,
        start,
        end,
        x,
        (ifx c_value == 2 then x + n else null),
        collapse_masks,
        null,
        pulses,
        short_blocks,
        spread_decision,
        dual_stereo,
        intensity,
        tf_res,
        len * (cast(s32) 8) << 3 - anti_collapse_rsv,
        balance,
        dec,
        lm,
        coded_bands,
        *st.rng,
        0,
        st.arch,
        st.disable_inv
    );

    if anti_collapse_rsv > 0 {
        anti_collapse_on = cast,no_check(s32) ec_dec_bits(dec, 1);
    }
    unquant_energy_finalise(
        mode,
        start,
        end,
        (ifx 0 > 0 then null else old_band_e),
        fine_quant,
        fine_priority,
        len * 8 - ec_tell_in_celt_decoder(dec),
        dec,
        c_value
    );
    if anti_collapse_on != 0 {
        anti_collapse(
            mode,
            x,
            collapse_masks,
            lm,
            c_value,
            n,
            start,
            end,
            old_band_e,
            old_log_e,
            old_log_e2,
            pulses,
            st.rng,
            0,
            st.arch
        );
    }

    if silence != 0 {
        i = 0;
        while i < c_value * nb_e_bands {
            old_band_e[i] = -28.0;
            i += 1;
        }
    }
    if st.prefilter_and_fold != 0 {
        prefilter_and_fold(st, n);
    }
    celt_synthesis(
        mode,
        x,
        out_syn.data,
        old_band_e,
        start,
        eff_end,
        c_value,
        CC,
        is_transient,
        lm,
        st.downsample,
        silence,
        st.arch
    );

    c = 0;
    while true {
        st.postfilter_period = ifx st.postfilter_period > 15 then st.postfilter_period else 15;
        st.postfilter_period_old = ifx st.postfilter_period_old > 15 then st.postfilter_period_old else 15;
        comb_filter(
            out_syn[c],
            out_syn[c],
            st.postfilter_period_old,
            st.postfilter_period,
            mode.short_mdct_size,
            st.postfilter_gain_old,
            st.postfilter_gain,
            st.postfilter_tapset_old,
            st.postfilter_tapset,
            mode.window,
            overlap,
            st.arch
        );
        if lm != 0 {
            comb_filter(
                out_syn[c] + mode.short_mdct_size,
                out_syn[c] + mode.short_mdct_size,
                st.postfilter_period,
                postfilter_pitch,
                n - mode.short_mdct_size,
                st.postfilter_gain,
                postfilter_gain,
                st.postfilter_tapset,
                postfilter_tapset,
                mode.window,
                overlap,
                st.arch
            );
        }
        if !(c_transpiler_pre_increment(*(c)) < CC) break;
    }
    st.postfilter_period_old = st.postfilter_period;
    st.postfilter_gain_old = st.postfilter_gain;
    st.postfilter_tapset_old = st.postfilter_tapset;
    st.postfilter_period = postfilter_pitch;
    st.postfilter_gain = postfilter_gain;
    st.postfilter_tapset = postfilter_tapset;
    if lm != 0 {
        st.postfilter_period_old = st.postfilter_period;
        st.postfilter_gain_old = st.postfilter_gain;
        st.postfilter_tapset_old = st.postfilter_tapset;
    }

    if c_value == 1 {
        copy_memory(
            *old_band_e[nb_e_bands],
            old_band_e,
            (cast,no_check(u64) nb_e_bands) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (*old_band_e[nb_e_bands] - old_band_e))
        );
    }

    if is_transient == 0 {
        copy_memory(
            old_log_e2,
            old_log_e,
            (cast,no_check(u64) (2 * nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (old_log_e2 - old_log_e))
        );
        copy_memory(
            old_log_e,
            old_band_e,
            (cast,no_check(u64) (2 * nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (old_log_e - old_band_e))
        );
    } else {
        i = 0;
        while i < 2 * nb_e_bands {
            old_log_e[i] =
                ifx c_transpiler_float_less(old_log_e[i], old_band_e[i]) then old_log_e[i] else old_band_e[i];
            i += 1;
        }
    }

    max_background_increase :=
        (cast,no_check(float32) ((ifx 160 < st.loss_duration + m then 160 else st.loss_duration + m))) *
            0.001;
    i = 0;
    while i < 2 * nb_e_bands {
        background_log_e[i] =
            ifx c_transpiler_float_less((background_log_e[i] + max_background_increase), old_band_e[i]) then background_log_e[i] +
                max_background_increase else old_band_e[i];
        i += 1;
    }

    c = 0;
    while true {
        i = 0;
        while i < start {
            old_band_e[c * nb_e_bands + i] = 0.0;
            old_log_e2[c * nb_e_bands + i] = -28.0;
            old_log_e[c * nb_e_bands + i] = old_log_e2[c * nb_e_bands + i];
            i += 1;
        }
        i = end;
        while i < nb_e_bands {
            old_band_e[c * nb_e_bands + i] = 0.0;
            old_log_e2[c * nb_e_bands + i] = -28.0;
            old_log_e[c * nb_e_bands + i] = old_log_e2[c * nb_e_bands + i];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < 2) break;
    }
    st.rng = dec.rng;

    deemphasis(out_syn.data, pcm, n, CC, st.downsample, mode.preemph.data, st.preemph_mem_d.data, accum);
    st.loss_duration = 0;
    st.plc_duration = 0;
    st.last_frame_type = 1;
    st.prefilter_and_fold = 0;

    if ec_tell_in_celt_decoder(dec) > 8 * len {
        return -3;
    }

    if ec_get_error_in_celt_decoder(dec) != 0 {
        st.error = 1;
    }
    return frame_size / st.downsample;
}

deemphasis :: (
    in: **Celt_Sig,
    pcm: *Res,
    n: s32,
    c_value: s32,
    downsample: s32,
    coef: *Val16,
    mem: *Celt_Sig,
    accum: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    apply_downsampling: s32 = 0;

    if downsample == 1 && c_value == 2 && accum == 0 {
        deemphasis_stereo_simple(in, pcm, n, coef[0], mem);
        return;
    }

    scratch := cast(*Celt_Sig) c_transpiler_alloca(cast(u64) ((size_of(Celt_Sig) * cast,no_check(u64) n)));
    coef0 := coef[0];
    nd := n / downsample;
    c: s32 = 0;
    while true {
        {
            m := mem[c];
            x := in[c];
            y := pcm + c;

            if downsample > 1 {
                if 0 < n {
                    for j: 0..n - 1 {
                        tmp := x[j] + 1.0e-30 + m;
                        m = coef0 * tmp;
                        scratch[j] = tmp;
                    }
                }
                apply_downsampling = 1;
            } else if accum != 0 {
                if 0 < n {
                    for j: 0..n - 1 {
                        tmp := x[j] + m + 1.0e-30;
                        m = coef0 * tmp;
                        y[j * c_value] = y[j * c_value] + (cast(float32) 0.000030517578125) * tmp;
                    }
                }
            } else {
                if 0 < n {
                    for j: 0..n - 1 {
                        tmp := x[j] + 1.0e-30 + m;
                        m = coef0 * tmp;
                        y[j * c_value] = (cast(float32) 0.000030517578125) * tmp;
                    }
                }
            }
            mem[c] = m;

            if apply_downsampling != 0 {
                if accum != 0 {
                    if 0 < nd {
                        for j: 0..nd - 1 {
                            y[j * c_value] =
                                y[j * c_value] +
                                    (cast(float32) 0.000030517578125) * scratch[j * downsample];
                        }
                    }
                } else {
                    if 0 < nd {
                        for j: 0..nd - 1 {
                            y[j * c_value] = (cast(float32) 0.000030517578125) * scratch[j * downsample];
                        }
                    }
                }
            }
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
}

deemphasis_stereo_simple :: (in: **Celt_Sig, pcm: *Res, n: s32, COEF0: Val16, mem: *Celt_Sig) {
    x0 := in[0];
    x1 := in[1];
    m0 := mem[0];
    m1 := mem[1];
    if 0 < n {
        for j: 0..n - 1 {
            tmp0: Celt_Sig = ---;

            tmp0 = x0[j] + 1.0e-30 + m0;
            tmp1 := x1[j] + 1.0e-30 + m1;
            m0 = COEF0 * tmp0;
            m1 = COEF0 * tmp1;
            pcm[2 * j] = (cast(float32) 0.000030517578125) * tmp0;
            pcm[2 * j + 1] = (cast(float32) 0.000030517578125) * tmp1;
        }
    }
    mem[0] = m0;
    mem[1] = m1;
}

celt_synthesis :: (
    mode: *Custom_Mode,
    x: *Celt_Norm,
    out_syn: **Celt_Sig,
    old_band_e: *Celt_Glog,
    start: s32,
    eff_end: s32,
    c_value: s32,
    cc: s32,
    is_transient: s32,
    lm: s32,
    downsample: s32,
    silence: s32,
    arch: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    c, i: s32 = ---;

    b: s32 = ---;
    b_value: s32 = ---;
    nb: s32 = ---;
    shift: s32 = ---;

    overlap := mode.overlap;
    nb_e_bands := mode.nb_e_bands;
    n := mode.short_mdct_size << ((lm) & 31);
    freq := cast(*Celt_Sig) c_transpiler_alloca(cast(u64) ((size_of(Celt_Sig) * cast,no_check(u64) n)));
    m := (cast(s32) 1) << ((lm) & 31);

    if is_transient != 0 {
        b_value = m;
        nb = mode.short_mdct_size;
        shift = mode.max_lm;
    } else {
        b_value = 1;
        nb = mode.short_mdct_size << ((lm) & 31);
        shift = mode.max_lm - lm;
    }

    if cc == 2 && c_value == 1 {
        denormalise_bands(mode, x, freq, old_band_e, start, eff_end, m, downsample, silence);

        freq2 := out_syn[1] + overlap / 2;
        copy_memory(freq2, freq, (cast,no_check(u64) n) * size_of(Celt_Sig) + cast,no_check(u64) (0 * (freq2 - freq)));
        b = 0;
        while b < b_value {
            (cast,no_check(#type (_: *Mdct_Lookup, _: *float32, _: *float32, _: *Celt_Coef, _: s32, _: s32, _: s32, _: s32)) (cast(*void) clt_mdct_backward_c))(
                *mode.mdct,
                *freq2[b],
                out_syn[0] + nb * b,
                mode.window,
                overlap,
                shift,
                b_value,
                arch
            );
            b += 1;
        }
        b = 0;
        while b < b_value {
            (cast,no_check(#type (_: *Mdct_Lookup, _: *float32, _: *float32, _: *Celt_Coef, _: s32, _: s32, _: s32, _: s32)) (cast(*void) clt_mdct_backward_c))(
                *mode.mdct,
                *freq[b],
                out_syn[1] + nb * b,
                mode.window,
                overlap,
                shift,
                b_value,
                arch
            );
            b += 1;
        }
    } else if cc == 1 && c_value == 2 {
        freq2 := out_syn[0] + overlap / 2;
        denormalise_bands(mode, x, freq, old_band_e, start, eff_end, m, downsample, silence);

        denormalise_bands(mode, x + n, freq2, old_band_e + nb_e_bands, start, eff_end, m, downsample, silence);

        i = 0;
        while i < n {
            freq[i] = 0.5 * freq[i] + 0.5 * freq2[i];
            i += 1;
        }
        b = 0;
        while b < b_value {
            (cast,no_check(#type (_: *Mdct_Lookup, _: *float32, _: *float32, _: *Celt_Coef, _: s32, _: s32, _: s32, _: s32)) (cast(*void) clt_mdct_backward_c))(
                *mode.mdct,
                *freq[b],
                out_syn[0] + nb * b,
                mode.window,
                overlap,
                shift,
                b_value,
                arch
            );
            b += 1;
        }
    } else {
        c = 0;
        while true {
            denormalise_bands(
                mode,
                x + c * n,
                freq,
                old_band_e + c * nb_e_bands,
                start,
                eff_end,
                m,
                downsample,
                silence
            );

            b = 0;
            while b < b_value {
                (cast,no_check(#type (_: *Mdct_Lookup, _: *float32, _: *float32, _: *Celt_Coef, _: s32, _: s32, _: s32, _: s32)) (cast(*void) clt_mdct_backward_c))(
                    *mode.mdct,
                    *freq[b],
                    out_syn[c] + nb * b,
                    mode.window,
                    overlap,
                    shift,
                    b_value,
                    arch
                );
                b += 1;
            }
            if !(c_transpiler_pre_increment(*(c)) < cc) break;
        }
    }

    c = 0;
    while true {
        i = 0;
        while i < n {
            out_syn[c][i] = out_syn[c][i];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }
}

prefilter_and_fold :: (st: *Custom_Decoder_in_celt_decoder, n: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    decode_mem: [2] *Celt_Sig = ---;

    decode_buffer_size: s32 = 2048;
    mode := st.mode;
    overlap := st.overlap;
    cc := st.channels;
    etmp := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) overlap)));
    c: s32 = 0;
    while true {
        decode_mem[c] = st.decode_mem.data + c * (decode_buffer_size + overlap);
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }

    c = 0;
    while true {
        comb_filter(
            etmp,
            decode_mem[c] + decode_buffer_size - n,
            st.postfilter_period_old,
            st.postfilter_period,
            overlap,
            -st.postfilter_gain_old,
            -st.postfilter_gain,
            st.postfilter_tapset_old,
            st.postfilter_tapset,
            null,
            0,
            st.arch
        );

        i = 0;
        while i < overlap / 2 {
            decode_mem[c][decode_buffer_size - n + i] =
                mode.window[i] * etmp[overlap - 1 - i] +
                    mode.window[overlap - i - 1] * etmp[i];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }
}

tf_decode :: (start: s32, end: s32, is_transient: s32, tf_res: *s32, lm: s32, dec: *Ec_Dec) {
    curr: s32 = ---;

    tf_changed: s32 = ---;

    budget := dec.storage * 8;
    tell := cast,no_check(Uint32) ec_tell_in_celt_decoder(dec);
    logp := (ifx is_transient != 0 then cast(s32) 2 else 4);
    tf_select_rsv := cast(s32) (lm > 0 && ((tell + cast,no_check(Uint32) logp) + 1) <= budget);
    budget -= cast,no_check(Uint32) tf_select_rsv;
    curr = 0;
    tf_changed = curr;
    i := start;
    while i < end {
        if (tell + cast,no_check(Uint32) logp) <= budget {
            curr ^= ec_dec_bit_logp(dec, cast,no_check(u32) logp);
            tell = cast,no_check(Uint32) ec_tell_in_celt_decoder(dec);
            tf_changed |= curr;
        }
        tf_res[i] = curr;
        logp = ifx is_transient != 0 then cast(s32) 4 else 5;
        i += 1;
    }
    tf_select: s32 = 0;
    if tf_select_rsv != 0 &&
        TF_SELECT_TABLE[lm][4 * is_transient + 0 + tf_changed] != TF_SELECT_TABLE[lm][4 * is_transient + 2 + tf_changed] {
        tf_select = ec_dec_bit_logp(dec, 1);
    }
    i = start;
    while i < end {
        tf_res[i] = cast,no_check(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + tf_res[i]];
        i += 1;
    }
}

celt_decode_lost :: (st: *Custom_Decoder_in_celt_decoder, n: s32, lm: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;
    C := st.channels;
    decode_mem: [2] *Celt_Sig = ---;
    out_syn: [2] *Celt_Sig = ---;

    decode_buffer_size: s32 = 2048;
    max_period: s32 = 1024;
    mode := st.mode;
    nb_e_bands := mode.nb_e_bands;
    overlap := mode.overlap;
    e_bands := mode.e_bands;

    c: s32 = 0;
    while true {
        decode_mem[c] = st.decode_mem.data + c * (decode_buffer_size + overlap);
        out_syn[c] = decode_mem[c] + decode_buffer_size - n;
        if !(c_transpiler_pre_increment(*(c)) < C) break;
    }
    old_band_e := st.decode_mem.data + (decode_buffer_size + overlap) * C;
    old_log_e := old_band_e + 2 * nb_e_bands;
    old_log_e2 := old_log_e + 2 * nb_e_bands;
    background_log_e := old_log_e2 + 2 * nb_e_bands;
    lpc := background_log_e + 2 * nb_e_bands;

    loss_duration := st.loss_duration;
    start := st.start;
    curr_frame_type: s32 = 3;
    if st.plc_duration >= 40 || start != 0 || st.skip_plc != 0 {
        curr_frame_type = 2;
    }

    if curr_frame_type == 2 {
        end := st.end;
        eff_end :=
            (ifx start > (ifx end < mode.eff_e_bands then end else mode.eff_e_bands) then start else (ifx end < mode.eff_e_bands then end else mode.eff_e_bands));

        x := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) (C * n))));
        c = 0;
        while true {
            move_memory(
                decode_mem[c],
                decode_mem[c] + n,
                (cast,no_check(u64) (decode_buffer_size - n + overlap)) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (decode_mem[c] - (decode_mem[c] + n)))
            );
            if !(c_transpiler_pre_increment(*(c)) < C) break;
        }

        if st.prefilter_and_fold != 0 {
            prefilter_and_fold(st, n);
        }

        decay: Celt_Glog = (ifx loss_duration == 0 then 1.5 else 0.5);
        c = 0;
        while true {
            i = start;
            while i < end {
                old_band_e[c * nb_e_bands + i] =
                    ifx c_transpiler_float_greater(background_log_e[c * nb_e_bands + i], (old_band_e[c * nb_e_bands + i] - decay)) then background_log_e[c * nb_e_bands + i] else old_band_e[c * nb_e_bands + i] -
                        decay;
                i += 1;
            }
            if !(c_transpiler_pre_increment(*(c)) < C) break;
        }
        seed := st.rng;
        c = 0;
        while c < C {
            i = start;
            while i < eff_end {
                boffs := n * c + (cast(s32) e_bands[i]) << ((lm) & 31);
                blen := ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i]) << ((lm) & 31);
                if 0 < blen {
                    for j: 0..blen - 1 {
                        seed = celt_lcg_rand(seed);
                        x[boffs + j] = cast,no_check(Celt_Norm) ((cast,no_check(Int32) seed) >> 20);
                    }
                }
                renormalise_vector(x + boffs, blen, 1.0, st.arch);
                i += 1;
            }
            c += 1;
        }
        st.rng = seed;

        celt_synthesis(mode, x, out_syn.data, old_band_e, start, eff_end, C, C, 0, lm, st.downsample, 0, st.arch);

        c = 0;
        while true {
            st.postfilter_period = ifx st.postfilter_period > 15 then st.postfilter_period else 15;
            st.postfilter_period_old = ifx st.postfilter_period_old > 15 then st.postfilter_period_old else 15;
            comb_filter(
                out_syn[c],
                out_syn[c],
                st.postfilter_period_old,
                st.postfilter_period,
                mode.short_mdct_size,
                st.postfilter_gain_old,
                st.postfilter_gain,
                st.postfilter_tapset_old,
                st.postfilter_tapset,
                mode.window,
                overlap,
                st.arch
            );
            if lm != 0 {
                comb_filter(
                    out_syn[c] + mode.short_mdct_size,
                    out_syn[c] + mode.short_mdct_size,
                    st.postfilter_period,
                    st.postfilter_period,
                    n - mode.short_mdct_size,
                    st.postfilter_gain,
                    st.postfilter_gain,
                    st.postfilter_tapset,
                    st.postfilter_tapset,
                    mode.window,
                    overlap,
                    st.arch
                );
            }
            if !(c_transpiler_pre_increment(*(c)) < C) break;
        }
        st.postfilter_period_old = st.postfilter_period;
        st.postfilter_gain_old = st.postfilter_gain;
        st.postfilter_tapset_old = st.postfilter_tapset;

        st.prefilter_and_fold = 0;

        st.skip_plc = 1;
    } else {
        fade: Val16 = 1.0;
        pitch_index: s32 = ---;

        curr_neural := cast(s32) (curr_frame_type == 4 || curr_frame_type == 5);
        last_neural := cast(s32) (st.last_frame_type == 4 || st.last_frame_type == 5);
        if st.last_frame_type != 3 && !(last_neural != 0 && curr_neural != 0) {
            pitch_index = celt_plc_pitch_search(st, decode_mem.data, C, st.arch);
            st.last_pitch_index = pitch_index;
        } else {
            pitch_index = st.last_pitch_index;
            fade = 0.8;
        }

        exc_length := (ifx 2 * pitch_index < max_period then 2 * pitch_index else max_period);

        exc_value :=
            cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) *
                cast,no_check(u64) (max_period + 24))));
        fir_tmp := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) exc_length)));
        exc := exc_value + 24;
        window := mode.window;
        c = 0;
        while true {
            {
                decay: Val16 = ---;

                s1: Val32 = 0.0;

                j: s32 = ---;

                buf := decode_mem[c];
                i = 0;
                while i < max_period + 24 {
                    exc[i - 24] = buf[decode_buffer_size - max_period - 24 + i];
                    i += 1;
                }

                if st.last_frame_type != 3 && !(last_neural != 0 && curr_neural != 0) {
                    ac: [25] Val32 = ---;

                    celt_autocorr(exc, ac.data, window, overlap, 24, max_period, st.arch);

                    ac[0] *= 1.0001;

                    i = 1;
                    while i <= 24 {
                        ac[i] -= ((ac[i] * cast(float32) 0.00006400000711437315) * i) * i;
                        i += 1;
                    }
                    celt_lpc(lpc + c * 24, ac.data, 24);
                }

                celt_fir_c(exc + max_period - exc_length, lpc + c * 24, fir_tmp, exc_length, 24, st.arch);
                copy_memory(
                    exc + max_period - exc_length,
                    fir_tmp,
                    (cast,no_check(u64) exc_length) * size_of(Val16) +
                    cast,no_check(u64) (0 * (exc + max_period - exc_length - fir_tmp))
                );

                {
                    e1: Val32 = 1.0;
                    e2: Val32 = 1.0;
                    decay_length := exc_length >> 1;
                    i = 0;
                    while i < decay_length {
                        e := exc[max_period - decay_length + i];
                        e1 += e * e;
                        e = exc[max_period - 2 * decay_length + i];
                        e2 += e * e;
                        i += 1;
                    }
                    e1 = ifx c_transpiler_float_less(e1, e2) then e1 else e2;
                    decay = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (e1 / e2));
                }

                move_memory(
                    buf,
                    buf + n,
                    (cast,no_check(u64) (decode_buffer_size - n)) * size_of(Celt_Sig) +
                    cast,no_check(u64) (0 * (buf - (buf + n)))
                );

                extrapolation_offset := max_period - pitch_index;

                extrapolation_len := n + overlap;

                attenuation := fade * decay;
                j = 0;
                i = j;
                while i < extrapolation_len {
                    if j >= pitch_index {
                        j -= pitch_index;
                        attenuation = attenuation * decay;
                    }
                    buf[decode_buffer_size - n + i] = attenuation * exc[extrapolation_offset + j];

                    tmp := buf[decode_buffer_size - max_period - n + extrapolation_offset + j];
                    s1 += tmp * tmp;
                    i += 1;
                    j += 1;
                }
                {
                    lpc_mem: [24] Val16 = ---;

                    i = 0;
                    while i < 24 {
                        lpc_mem[i] = buf[decode_buffer_size - n - 1 - i];
                        i += 1;
                    }

                    celt_iir(
                        buf + decode_buffer_size - n,
                        lpc + c * 24,
                        buf + decode_buffer_size - n,
                        extrapolation_len,
                        24,
                        lpc_mem.data,
                        st.arch
                    );
                }

                {
                    s2: Val32 = 0.0;
                    i = 0;
                    while i < extrapolation_len {
                        tmp := buf[decode_buffer_size - n + i];
                        s2 += tmp * tmp;
                        i += 1;
                    }

                    if !(c_transpiler_float_greater(s1, (0.2 * s2))) {
                        i = 0;
                        while i < extrapolation_len {
                            buf[decode_buffer_size - n + i] = 0.0;
                            i += 1;
                        }
                    } else if c_transpiler_float_less(s1, s2) {
                        ratio :=
                            cast,no_check(float32) c_transpiler_libm_sqrt(
                                cast,no_check(float64) ((s1 + 1.0) / (s2 + 1.0))
                            );
                        i = 0;
                        while i < overlap {
                            tmp_g := 1.0 - window[i] * (1.0 - ratio);
                            buf[decode_buffer_size - n + i] = tmp_g * buf[decode_buffer_size - n + i];
                            i += 1;
                        }
                        i = overlap;
                        while i < extrapolation_len {
                            buf[decode_buffer_size - n + i] = ratio * buf[decode_buffer_size - n + i];
                            i += 1;
                        }
                    }
                }
            }
            if !(c_transpiler_pre_increment(*(c)) < C) break;
        }

        st.prefilter_and_fold = 1;
    }

    st.loss_duration =
        ifx 10000 < loss_duration + (cast(s32) 1) << ((lm) & 31) then 10000 else loss_duration +
            (cast(s32) 1) << ((lm) & 31);
    st.plc_duration =
        ifx 10000 < st.plc_duration + (cast(s32) 1) << ((lm) & 31) then 10000 else st.plc_duration +
            (cast(s32) 1) << ((lm) & 31);

    st.last_frame_type = curr_frame_type;
}

celt_plc_pitch_search :: (st: *Custom_Decoder_in_celt_decoder, decode_mem: **Celt_Sig, c: s32, arch: s32) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    pitch_index: s32 = ---;

    lp_pitch_buf :=
        cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) *
            cast,no_check(u64) ((cast(s32) 2048) >> 1))));
    pitch_downsample(decode_mem, lp_pitch_buf, (cast(s32) 2048) >> 1, c, 2, arch);
    pitch_search(
        lp_pitch_buf + (cast(s32) 720) >> 1,
        lp_pitch_buf,
        cast,no_check(s32) (2048 - 720),
        cast,no_check(s32) (720 - 100),
        *pitch_index,
        arch
    );
    pitch_index = 720 - pitch_index;

    return pitch_index;
}

celt_decode_with_ec :: (
    st: *Custom_Decoder_in_celt_decoder,
    data: *u8,
    len: s32,
    pcm: *Res,
    frame_size: s32,
    dec: *Ec_Dec,
    accum: s32
) -> s32 {
    return celt_decode_with_ec_dred(st, data, len, pcm, frame_size, dec, accum);
}

xcorr_kernel_c_in_celt_decoder :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
    y_3: Val16 = 0.0;
    y_0 := (c_transpiler_post_increment(*(y))).*;
    y_1 := (c_transpiler_post_increment(*(y))).*;
    y_2 := (c_transpiler_post_increment(*(y))).*;
    j: s32 = 0;
    while j < len - 3 {
        tmp := (c_transpiler_post_increment(*(x))).*;
        y_3 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_0;
        sum[1] = sum[1] + tmp * y_1;
        sum[2] = sum[2] + tmp * y_2;
        sum[3] = sum[3] + tmp * y_3;
        tmp = (c_transpiler_post_increment(*(x))).*;
        y_0 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_1;
        sum[1] = sum[1] + tmp * y_2;
        sum[2] = sum[2] + tmp * y_3;
        sum[3] = sum[3] + tmp * y_0;
        tmp = (c_transpiler_post_increment(*(x))).*;
        y_1 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_2;
        sum[1] = sum[1] + tmp * y_3;
        sum[2] = sum[2] + tmp * y_0;
        sum[3] = sum[3] + tmp * y_1;
        tmp = (c_transpiler_post_increment(*(x))).*;
        y_2 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_3;
        sum[1] = sum[1] + tmp * y_0;
        sum[2] = sum[2] + tmp * y_1;
        sum[3] = sum[3] + tmp * y_2;
        j += 4;
    }
    if c_transpiler_post_increment(*(j)) < len {
        tmp := (c_transpiler_post_increment(*(x))).*;
        y_3 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_0;
        sum[1] = sum[1] + tmp * y_1;
        sum[2] = sum[2] + tmp * y_2;
        sum[3] = sum[3] + tmp * y_3;
    }
    if c_transpiler_post_increment(*(j)) < len {
        tmp := (c_transpiler_post_increment(*(x))).*;
        y_0 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_1;
        sum[1] = sum[1] + tmp * y_2;
        sum[2] = sum[2] + tmp * y_3;
        sum[3] = sum[3] + tmp * y_0;
    }
    if j < len {
        tmp := (c_transpiler_post_increment(*(x))).*;
        y_1 = (c_transpiler_post_increment(*(y))).*;
        sum[0] = sum[0] + tmp * y_2;
        sum[1] = sum[1] + tmp * y_3;
        sum[2] = sum[2] + tmp * y_0;
        sum[3] = sum[3] + tmp * y_1;
    }
}

dual_inner_prod_c_in_celt_decoder :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
    xy01: Val32 = 0.0;
    xy02: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy01 = xy01 + x[i] * y01[i];
            xy02 = xy02 + x[i] * y02[i];
        }
    }
    xy1.* = xy01;
    xy2.* = xy02;
}

celt_inner_prod_c_in_celt_decoder :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

false__in_celt_decoder :: () -> s32 {
    return 0;
}

get_pulses_in_celt_decoder :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_celt_decoder :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];

    lo: s32 = 0;
    hi := cast,no_check(s32) cache[0];
    bits -= 1;
    for i: 0..cast(s32) 6 - 1 {
        mid := (lo + hi + 1) >> 1;

        if cast,no_check(s32) cache[mid] >= bits {
            hi = mid;
        } else {
            lo = mid;
        }
    }
    if (bits - (ifx lo == 0 then -1 else cast,no_check(s32) cache[lo])) <= (cast,no_check(s32) cache[hi]) - bits {
        return lo;
    } else {
        return hi;
    }
}

pulses2bits_in_celt_decoder :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

fast_atan2f_in_celt_decoder :: (y: float32, x: float32) -> float32 {
    x2: float32 = ---;
    x2 = x * x;
    y2 := y * y;

    if c_transpiler_float_less((x2 + y2), 1.0e-18) {
        return 0.0;
    }
    if c_transpiler_float_less(x2, y2) {
        den := (y2 + 0.67848403 * x2) * (y2 + 0.08595542 * x2);
        return -x * y * (y2 + 0.43157974 * x2) / den + (ifx c_transpiler_float_less(y, 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867);
    } else {
        den := (x2 + 0.67848403 * y2) * (x2 + 0.08595542 * y2);
        return (x * y * (x2 + 0.43157974 * y2) / den + (ifx c_transpiler_float_less(y, 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867)) - (ifx c_transpiler_float_less((x * y), 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867);
    }
}

celt_maxabs16_in_celt_decoder :: (x: *Val16, len: s32) -> Val32 {
    maxval: Val16 = 0.0;
    minval: Val16 = 0.0;
    if 0 < len {
        for i: 0..len - 1 {
            maxval = ifx c_transpiler_float_greater(maxval, x[i]) then maxval else x[i];
            minval = ifx c_transpiler_float_less(minval, x[i]) then minval else x[i];
        }
    }
    return ifx c_transpiler_float_greater(maxval, -minval) then maxval else -minval;
}

celt_atan_norm_in_celt_decoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_celt_decoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_celt_decoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_celt_decoder(x / y);
    }
}

celt_cos_norm2_in_celt_decoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

mm_cvtss_si32_in_celt_decoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_celt_decoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_celt_decoder(a);
}

mm_set_ss_in_celt_decoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_celt_decoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_celt_decoder(mm_set_ss_in_celt_decoder(x));
}

float2_int16_in_celt_decoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_celt_decoder(x);
}

float2_int24_in_celt_decoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_celt_decoder(x);
}

globals_initialization_state_for_celt_decoder: u32;
initialize_globals_for_celt_decoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_celt_decoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_celt_decoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_celt_decoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_celt_decoder =
        u8.[
            126,
            124,
            119,
            109,
            87,
            41,
            19,
            9,
            4,
            2,
            0
        ];
    SPREAD_ICDF_in_celt_decoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_celt_decoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_celt_decoder, 2);
}

