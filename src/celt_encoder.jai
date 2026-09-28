// Generated directly from C by cpp_transpiler.
Custom_Encoder_in_celt_encoder :: struct {
    mode: *Custom_Mode;
    channels: s32;
    stream_channels: s32;
    force_intra: s32;
    clip: s32;
    disable_pf: s32;
    complexity: s32;
    upsample: s32;
    start: s32;
    end: s32;
    bitrate: Int32;
    vbr: s32;
    signalling: s32;
    constrained_vbr: s32;
    loss_rate: s32;
    lsb_depth: s32;
    lfe: s32;
    disable_inv: s32;
    arch: s32;
    rng: Uint32;
    spread_decision: s32;
    delayed_intra: Val32;
    tonal_average: s32;
    last_coded_bands: s32;
    hf_average: s32;
    tapset_decision: s32;
    prefilter_period: s32;
    prefilter_gain: Val16;
    prefilter_tapset: s32;
    consec_transient: s32;
    analysis: Analysis_Info;
    silk_info: SILK_Info;
    preemph_mem_e: [2] Val32;
    preemph_mem_d: [2] Val32;
    vbr_reservoir: Int32;
    vbr_drift: Int32;
    vbr_offset: Int32;
    vbr_count: Int32;
    overlap_max: Val32;
    stereo_saving: Val16;
    intensity: s32;
    energy_mask: *Celt_Glog;
    spec_avg: Celt_Glog;
    in_mem: [1] Celt_Sig;
}

TRIM_ICDF_in_celt_encoder: [11] u8;

INTENSITY_HISTERESIS: [21] Val16;

INTENSITY_THRESHOLDS: [21] Val16;

SPREAD_ICDF_in_celt_encoder: [4] u8;

TAPSET_ICDF_in_celt_encoder: [3] u8;

INV_TABLE: [128] u8;

select_arch_in_celt_encoder :: () -> s32 {
    return 0;
}

alloc__in_celt_encoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_celt_encoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_celt_encoder :: (size: u64) -> *void {
    return alloc__in_celt_encoder(size);
}

free__in_celt_encoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

custom_encoder_get_size :: (mode: *Custom_Mode, channels: s32) -> s32 {
    extra: s32 = 0;
    size :=
        cast,no_check(s32) (size_of(Custom_Encoder_in_celt_encoder) + (cast,no_check(u64) (channels * mode.overlap - 1)) * size_of(Celt_Sig) +
            (cast,no_check(u64) (channels * 1024)) * size_of(Celt_Sig) + (cast,no_check(u64) (4 * channels * mode.nb_e_bands)) * size_of(Celt_Glog) + cast,no_check(u64) extra);
    return size;
}

custom_encoder_ctl :: (st: *Custom_Encoder_in_celt_encoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ap: Va_List = ---;
    value: s32 = ---;
    value_2: Int32 = ---;
    value_3: Int32 = ---;
    value_4: s32 = ---;
    value_5: s32 = ---;
    value_6: Int32 = ---;
    value_7: Int32 = ---;
    value_8: Int32 = ---;
    value_9: Int32 = ---;
    value_10: Int32 = ---;
    value_11: *Int32 = ---;
    value_12: Int32 = ---;
    value_13: *Int32 = ---;
    i: s32 = ---;
    old_band_e: *Celt_Glog = ---;
    old_log_e: *Celt_Glog = ---;
    old_log_e2: *Celt_Glog = ---;
    value_14: Int32 = ---;
    info: *Analysis_Info = ---;
    info_2: *SILK_Info = ---;
    value_15: **Custom_Mode = ---;
    value_16: *Uint32 = ---;
    value_17: Int32 = ---;
    value_18: *Celt_Glog = ---;
    code_block_to_execute: s64 = 138;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 27; {
                return -1;
            }
            case 29; {
                return 0;
            }
            case 65; {
                while c_transpiler_local_loop := true {
                    if i < st.channels * st.mode.nb_e_bands {
                        old_log_e2[i] = -28.0;
                        old_log_e[i] = old_log_e2[i];
                        i += 1;
                        continue c_transpiler_local_loop;
                    } else {
                        st.vbr_offset = 0;
                        st.delayed_intra = 1.0;
                        st.spread_decision = 2;
                        st.tonal_average = 256;
                        st.hf_average = 0;
                        st.tapset_decision = 0;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                }
            }
            case 138; {
                start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
                c_transpiler_switch_value_138 := request;
                if c_transpiler_switch_value_138 == {
                    case cast(s32) 4010; {
                        value = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value < 0 || value > 10 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.complexity = value;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10010; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_2 < 0 || value_2 >= st.mode.nb_e_bands {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.start = value_2;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10012; {
                        value_3 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_3 < 1 || value_3 > st.mode.nb_e_bands {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.end = value_3;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10002; {
                        value_4 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_4 < 0 || value_4 > 2 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.disable_pf = cast(s32) (value_4 <= 1);
                            st.force_intra = cast(s32) (value_4 == 0);
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4014; {
                        value_5 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_5 < 0 || value_5 > 100 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.loss_rate = value_5;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4020; {
                        value_6 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.constrained_vbr = value_6;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4006; {
                        value_7 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.vbr = value_7;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4002; {
                        value_8 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_8 <= 500 && value_8 != -1 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            value_8 = ifx value_8 < 750000 * st.channels then value_8 else 750000 * st.channels;
                            st.bitrate = value_8;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10008; {
                        value_9 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_9 < 1 || value_9 > 2 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.stream_channels = value_9;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4036; {
                        value_10 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_10 < 8 || value_10 > 24 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.lsb_depth = value_10;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4037; {
                        value_11 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        value_11.* = st.lsb_depth;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4046; {
                        value_12 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_12 < 0 || value_12 > 1 {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            st.disable_inv = value_12;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4047; {
                        value_13 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_13 == null {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            value_13.* = st.disable_inv;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4028; {
                        old_band_e = st.in_mem.data + st.channels * (st.mode.overlap + 1024);
                        old_log_e = old_band_e + st.channels * st.mode.nb_e_bands;
                        old_log_e2 = old_log_e + st.channels * st.mode.nb_e_bands;
                        fill_memory(
                            cast(*s8) *st.rng,
                            0,
                            cast,no_check(u64) ((cast(s64) custom_encoder_get_size(st.mode, st.channels)) -
                            ((cast(*s8) *st.rng) - cast(*s8) st))
                        );
                        i = 0;
                        code_block_to_execute = 65;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 10016; {
                        value_14 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.signalling = value_14;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 10022; {
                        info = c_transpiler_va_arg(cast(*void) (ap.data), *Analysis_Info);
                        if info != null {
                            copy_memory(
                                *st.analysis,
                                info,
                                (cast,no_check(u64) (1)) * size_of(Analysis_Info) +
                                cast,no_check(u64) (0 * (*st.analysis - info))
                            );
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10028; {
                        info_2 = c_transpiler_va_arg(cast(*void) (ap.data), *SILK_Info);
                        if info_2 != null {
                            copy_memory(
                                *st.silk_info,
                                info_2,
                                (cast,no_check(u64) (1)) * size_of(SILK_Info) +
                                cast,no_check(u64) (0 * (*st.silk_info - info_2))
                            );
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10015; {
                        value_15 = c_transpiler_va_arg(cast(*void) (ap.data), **Custom_Mode);
                        if value_15 == null {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            value_15.* = st.mode;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4031; {
                        value_16 = c_transpiler_va_arg(cast(*void) (ap.data), *Uint32);
                        if value_16 == null {
                            code_block_to_execute = 27;
                            continue c_transpiler_dispatch;
                        } else {
                            value_16.* = st.rng;
                            code_block_to_execute = 29;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10024; {
                        value_17 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.lfe = value_17;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 10026; {
                        value_18 = c_transpiler_va_arg(cast(*void) (ap.data), *Celt_Glog);
                        st.energy_mask = value_18;
                        code_block_to_execute = 29;
                        continue c_transpiler_dispatch;
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

ec_range_bytes_in_celt_encoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_celt_encoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_celt_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_celt_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_celt_encoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_celt_encoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

bits_to_bitrate_in_celt_encoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_celt_encoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

celt_encoder_get_size :: (channels: s32) -> s32 {
    mode := custom_mode_create(48000, 960, null);

    return custom_encoder_get_size(mode, channels);
}

celt_encode_with_ec :: (
    st: *Custom_Encoder_in_celt_encoder,
    pcm: *Res,
    frame_size: s32,
    compressed: *u8,
    nb_compressed_bytes: s32,
    enc: *Ec_Enc
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    enc_ec_ctx: Ec_Enc = ---;

    short_blocks: s32 = 0;
    is_transient: s32 = 0;
    CC := st.channels;
    C := st.stream_channels;

    tf_select: s32 = ---;
    nb_filled_bytes: s32 = ---;

    pitch_index: s32 = 15;
    gain1: Val16 = 0.0;
    dual_stereo: s32 = 0;
    effective_bytes: s32 = ---;

    vbr_rate: Int32 = ---;

    balance: Int32 = ---;
    tell: Int32 = ---;
    tell0_frac: Int32 = ---;
    prefilter_tapset: s32 = 0;
    pf_on: s32 = ---;

    anti_collapse_on: s32 = 0;
    silence: s32 = 0;
    tf_chan: s32 = 0;

    pitch_change: s32 = 0;
    tot_boost: Int32 = ---;

    transient_got_disabled: s32 = 0;
    surround_masking: Celt_Glog = 0.0;
    temporal_vbr: Celt_Glog = 0.0;
    surround_trim: Celt_Glog = 0.0;

    weak_transient: s32 = 0;

    tone_freq: Val16 = -1.0;
    toneishness: Val32 = 0.0;

    qext_bytes: s32 = 0;
    packet_size_cap: s32 = 1275;

    mode := st.mode;
    nb_e_bands := mode.nb_e_bands;
    overlap := mode.overlap;
    e_bands := mode.e_bands;
    start := st.start;
    end := st.end;
    hybrid := cast(s32) (start != 0);
    tf_estimate: Val16 = 0.0;
    if nb_compressed_bytes < 2 || pcm == null {
        return -1;
    }

    frame_size *= st.upsample;
    lm: s32 = 0;
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
    n := m * mode.short_mdct_size;

    prefilter_mem := st.in_mem.data + CC * overlap;
    old_band_e := st.in_mem.data + CC * (overlap + 1024);
    old_log_e := old_band_e + CC * nb_e_bands;
    old_log_e2 := old_log_e + CC * nb_e_bands;
    energy_error := old_log_e2 + CC * nb_e_bands;

    if enc == null {
        tell = 1;
        tell0_frac = tell;
        nb_filled_bytes = 0;
    } else {
        tell0_frac = cast,no_check(Int32) ec_tell_frac(enc);
        tell = ec_tell_in_celt_encoder(enc);
        nb_filled_bytes = (tell + 4) >> 3;
    }

    (st.signalling == 0);

    nb_compressed_bytes = min(nb_compressed_bytes, packet_size_cap);

    if st.vbr != 0 && st.bitrate != -1 {
        vbr_rate = bitrate_to_bits_in_celt_encoder(st.bitrate, mode.fs, frame_size) << 3;

        effective_bytes = vbr_rate >> (((3 + 3)) & 31);
    } else {
        vbr_rate = 0;
        tmp := st.bitrate * frame_size;
        if tell > 1 {
            tmp += tell * mode.fs;
        }
        if st.bitrate != -1 {
            nb_compressed_bytes =
                ifx 2 > (ifx nb_compressed_bytes < (tmp + 4 * mode.fs) / (8 * mode.fs) - cast(Int32) (st.signalling != 0) then nb_compressed_bytes else (tmp + 4 * mode.fs) / (8 * mode.fs) -
                    cast(Int32) (st.signalling != 0)) then 2 else (ifx nb_compressed_bytes < (tmp + 4 * mode.fs) / (8 * mode.fs) - cast(Int32) (st.signalling != 0) then nb_compressed_bytes else (tmp + 4 * mode.fs) / (8 * mode.fs) - cast(Int32) (st.signalling != 0));
            if enc != null {
                ec_enc_shrink(enc, cast,no_check(Uint32) nb_compressed_bytes);
            }
        }
        effective_bytes = nb_compressed_bytes - nb_filled_bytes;
    }
    nb_available_bytes := nb_compressed_bytes - nb_filled_bytes;
    equiv_rate :=
        (nb_compressed_bytes * 8 * 50) << (((3 - lm)) & 31) -
            (40 * C + 20) * ((cast(s32) 400) >> ((lm) & 31) - 50);
    if st.bitrate != -1 {
        equiv_rate =
            ifx equiv_rate < st.bitrate - (40 * C + 20) * ((cast(s32) 400) >> ((lm) & 31) - 50) then equiv_rate else st.bitrate -
                (40 * C + 20) * ((cast(s32) 400) >> ((lm) & 31) - 50);
    }

    if enc == null {
        ec_enc_init(*enc_ec_ctx, compressed, cast,no_check(Uint32) nb_compressed_bytes);
        enc = *enc_ec_ctx;
    }

    if vbr_rate > 0 {
        if st.constrained_vbr != 0 {
            vbr_bound := vbr_rate;
            max_allowed :=
                (ifx (ifx (ifx tell == 1 then cast(s32) 2 else 0) > (vbr_rate + vbr_bound - st.vbr_reservoir) >> (((3 + 3)) & 31) then (ifx tell == 1 then cast(Int32) 2 else 0) else (vbr_rate + vbr_bound - st.vbr_reservoir) >> (((3 + 3)) & 31)) < nb_available_bytes then (ifx (ifx tell == 1 then cast(s32) 2 else 0) > (vbr_rate +
                    vbr_bound - st.vbr_reservoir) >> (((3 + 3)) & 31) then (ifx tell == 1 then cast(Int32) 2 else 0) else (vbr_rate + vbr_bound - st.vbr_reservoir) >> (((3 + 3)) & 31)) else nb_available_bytes);
            if max_allowed < nb_available_bytes {
                nb_compressed_bytes = nb_filled_bytes + max_allowed;
                nb_available_bytes = max_allowed;
                ec_enc_shrink(enc, cast,no_check(Uint32) nb_compressed_bytes);
            }
        }
    }
    total_bits := nb_compressed_bytes * 8;

    eff_end := end;
    if eff_end > mode.eff_e_bands {
        eff_end = mode.eff_e_bands;
    }

    in :=
        cast(*Celt_Sig) c_transpiler_alloca(cast(u64) ((size_of(Celt_Sig) *
            cast,no_check(u64) (CC * (n + overlap)))));

    sample_max :=
        (ifx c_transpiler_float_greater(st.overlap_max, celt_maxabs16_in_celt_encoder(pcm, C * (n - overlap) / st.upsample)) then st.overlap_max else celt_maxabs16_in_celt_encoder(pcm, C *
            (n - overlap) / st.upsample));
    st.overlap_max = celt_maxabs16_in_celt_encoder(pcm + C * (n - overlap) / st.upsample, C * overlap / st.upsample);
    sample_max = ifx c_transpiler_float_greater(sample_max, st.overlap_max) then sample_max else st.overlap_max;

    silence =
        cast(s32) (c_transpiler_float_less_equal(sample_max, (1.0 /
            cast,no_check(Val16) ((cast(s32) 1) << ((st.lsb_depth) & 31)))));

    if tell == 1 {
        ec_enc_bit_logp(enc, silence, 15);
    } else {
        silence = 0;
    }
    if silence != 0 {
        if vbr_rate > 0 {
            nb_compressed_bytes =
                (ifx nb_compressed_bytes < nb_filled_bytes +
                    2 then nb_compressed_bytes else nb_filled_bytes + 2);
            effective_bytes = nb_compressed_bytes;
            total_bits = nb_compressed_bytes * 8;
            nb_available_bytes = 2;
            ec_enc_shrink(enc, cast,no_check(Uint32) nb_compressed_bytes);
        }

        tell = nb_compressed_bytes * 8;
        c_transpiler_compound_add(*(enc.nbits_total), ((tell - ec_tell_in_celt_encoder(enc))), s32, s32);
    }
    c: s32 = 0;
    while true {
        {
            need_clip: s32 = 0;

            need_clip = cast(s32) (st.clip != 0 && c_transpiler_float_greater(sample_max, 65536.0));

            celt_preemphasis(
                pcm + c,
                in + c * (n + overlap) + overlap,
                n,
                CC,
                st.upsample,
                mode.preemph.data,
                st.preemph_mem_e.data + c,
                need_clip
            );
            copy_memory(
                in + c * (n + overlap),
                *prefilter_mem[(1 + c) * 1024 - overlap],
                (cast,no_check(u64) overlap) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (in + c * (n + overlap) - *prefilter_mem[(1 + c) * 1024 - overlap]))
            );
        }
        if !(c_transpiler_pre_increment(*(c)) < CC) break;
    }

    tone_freq = tone_detect(in, CC, n + overlap, *toneishness, mode.fs);
    is_transient = 0;
    short_blocks = 0;
    if st.complexity >= 1 && st.lfe == 0 {
        allow_weak_transients := cast(s32) (hybrid != 0 && effective_bytes < 15 && st.silk_info.signal_type != 2);
        is_transient =
            transient_analysis(
                in,
                n + overlap,
                CC,
                *tf_estimate,
                *tf_chan,
                allow_weak_transients,
                *weak_transient,
                tone_freq,
                toneishness
            );
    }
    toneishness = ifx c_transpiler_float_less(toneishness, (1.0 - tf_estimate)) then toneishness else 1.0 - tf_estimate;

    {
        qg: s32 = ---;
        enabled :=
            cast(s32) ((st.lfe != 0 && nb_available_bytes > 3 || nb_available_bytes > 12 * C) &&
                hybrid == 0 && silence == 0 && tell + 16 <= total_bits && st.disable_pf == 0);

        prefilter_tapset = st.tapset_decision;
        pf_on =
            run_prefilter(
                st,
                in,
                prefilter_mem,
                CC,
                n,
                prefilter_tapset,
                *pitch_index,
                *gain1,
                *qg,
                enabled,
                st.complexity,
                tf_estimate,
                nb_available_bytes,
                *st.analysis,
                tone_freq,
                toneishness
            );
        if (c_transpiler_float_greater(gain1, 0.4) || c_transpiler_float_greater(st.prefilter_gain, 0.4)) &&
            (st.analysis.valid == 0 || c_transpiler_float_greater(cast,no_check(float64) st.analysis.tonality, 0.3)) &&
            (c_transpiler_float_greater(cast,no_check(float64) pitch_index, (1.26 * cast,no_check(float64) st.prefilter_period)) ||
                c_transpiler_float_less(cast,no_check(float64) pitch_index, (0.79 * cast,no_check(float64) st.prefilter_period))) {
            pitch_change = 1;
        }
        if pf_on == 0 {
            if hybrid == 0 && tell + 16 <= total_bits {
                ec_enc_bit_logp(enc, 0, 1);
            }
        } else {
            ec_enc_bit_logp(enc, 1, 1);
            pitch_index += 1;
            octave :=
                (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 -
                    c_transpiler_clz32(cast,no_check(u32) pitch_index) - 5;
            ec_enc_uint(enc, cast,no_check(Uint32) octave, 6);
            ec_enc_bits(
                enc,
                cast,no_check(Uint32) (pitch_index - (cast(s32) 16) << ((octave) & 31)),
                cast,no_check(u32) (4 + octave)
            );
            pitch_index -= 1;
            ec_enc_bits(enc, cast,no_check(Uint32) qg, 3);
            ec_enc_icdf(enc, prefilter_tapset, TAPSET_ICDF_in_celt_encoder.data, 2);
        }
    }
    if lm > 0 && ec_tell_in_celt_encoder(enc) + 3 <= total_bits {
        if is_transient != 0 {
            short_blocks = m;
        }
    } else {
        is_transient = 0;
        transient_got_disabled = 1;
    }

    freq := cast(*Celt_Sig) c_transpiler_alloca(cast(u64) ((size_of(Celt_Sig) * cast,no_check(u64) (CC * n))));
    band_e :=
        cast(*Celt_Ener) c_transpiler_alloca(cast(u64) ((size_of(Celt_Ener) *
            cast,no_check(u64) (nb_e_bands * CC))));
    band_log_e :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (nb_e_bands * CC))));

    second_mdct := cast(s32) (short_blocks != 0 && st.complexity >= 8);
    band_log_e2 :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (C * nb_e_bands))));
    if second_mdct != 0 {
        compute_mdcts(mode, 0, in, freq, C, CC, lm, st.upsample, st.arch);
        compute_band_energies(mode, freq, band_e, eff_end, C, lm, st.arch);
        amp2_log2(mode, eff_end, end, band_e, band_log_e2, C);
        c = 0;
        while c < C {
            i = 0;
            while i < end {
                band_log_e2[nb_e_bands * c + i] += 0.5 * cast,no_check(float32) lm;
                i += 1;
            }
            c += 1;
        }
    }

    compute_mdcts(mode, short_blocks, in, freq, C, CC, lm, st.upsample, st.arch);

    (!(c_transpiler_float_not_equal(freq[0], freq[0])) && (C == 1 || !(c_transpiler_float_not_equal(freq[n], freq[n]))));
    if CC == 2 && C == 1 {
        tf_chan = 0;
    }
    compute_band_energies(mode, freq, band_e, eff_end, C, lm, st.arch);

    if st.lfe != 0 {
        i = 2;
        while i < end {
            band_e[i] =
                ifx c_transpiler_float_less(band_e[i], (1.0e-4 * band_e[0])) then band_e[i] else 1.0e-4 *
                    band_e[0];
            band_e[i] = ifx c_transpiler_float_greater(band_e[i], 1.0e-15) then band_e[i] else 1.0e-15;
            i += 1;
        }
    }
    amp2_log2(mode, eff_end, end, band_e, band_log_e, C);

    surround_dynalloc :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (C * nb_e_bands))));
    fill_memory(surround_dynalloc, 0, cast,no_check(u64) end * size_of(Celt_Glog));

    if hybrid == 0 && st.energy_mask != null && st.lfe == 0 {
        mask_avg: Val32 = 0.0;
        diff: Val32 = 0.0;
        count: s32 = 0;
        mask_end := (ifx 2 > st.last_coded_bands then 2 else st.last_coded_bands);
        c = 0;
        while c < C {
            i = 0;
            while i < mask_end {
                mask :=
                    (ifx c_transpiler_float_greater((ifx c_transpiler_float_less(st.energy_mask[nb_e_bands * c + i], 0.25) then st.energy_mask[nb_e_bands * c + i] else 0.25), -2.0) then (ifx c_transpiler_float_less(st.energy_mask[nb_e_bands * c + i], 0.25) then st.energy_mask[nb_e_bands * c +
                        i] else 0.25) else -2.0);
                if c_transpiler_float_greater(mask, 0.0) {
                    mask = 0.5 * mask;
                }
                mask16 := mask;
                mask_avg += mask16 * cast,no_check(Val32) ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i]);
                count += (cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i];
                diff += mask16 * cast,no_check(Val32) (1 + 2 * i - mask_end);
                i += 1;
            }
            c += 1;
        }

        mask_avg = mask_avg / cast,no_check(Val16) count;
        mask_avg += 0.2;
        diff = diff * 6.0 / (C * (mask_end - 1) * (mask_end + 1) * mask_end);

        diff = 0.5 * diff;
        diff =
            ifx c_transpiler_float_greater((ifx c_transpiler_float_less(diff, 0.031) then diff else 0.031), cast(float32) -0.03099999949336052) then (ifx c_transpiler_float_less(diff, 0.031) then diff else 0.031) else cast(float32) -0.03099999949336052;

        midband: s32 = 0;
        while cast,no_check(s32) e_bands[midband + 1] < (cast(s32) e_bands[mask_end]) / 2 {
            midband += 1;
        }
        count_dynalloc: s32 = 0;
        i = 0;
        while i < mask_end {
            lin := mask_avg + diff * (i - midband);
            unmask: Celt_Glog = ifx C == 2
                then (ifx c_transpiler_float_greater(st.energy_mask[i], st.energy_mask[nb_e_bands + i]) then st.energy_mask[i] else st.energy_mask[nb_e_bands + i])
                else st.energy_mask[i];
            unmask = ifx c_transpiler_float_less(unmask, 0.0) then unmask else 0.0;
            unmask -= lin;
            if c_transpiler_float_greater(unmask, 0.25) {
                surround_dynalloc[i] = unmask - 0.25;
                count_dynalloc += 1;
            }
            i += 1;
        }
        if count_dynalloc >= 3 {
            mask_avg += 0.25;
            if c_transpiler_float_greater(mask_avg, 0.0) {
                mask_avg = 0.0;
                diff = 0.0;
                fill_memory(surround_dynalloc, 0, cast,no_check(u64) mask_end * size_of(Celt_Glog));
            } else {
                i = 0;
                while i < mask_end {
                    surround_dynalloc[i] =
                        ifx c_transpiler_float_greater(0.0, (surround_dynalloc[i] - 0.25)) then 0.0 else surround_dynalloc[i] -
                            0.25;
                    i += 1;
                }
            }
        }
        mask_avg += 0.2;

        surround_trim = 64.0 * diff;

        surround_masking = mask_avg;
    }

    if st.lfe == 0 {
        follow: Celt_Glog = -10.0;
        frame_avg: Val32 = 0.0;
        offset := (ifx short_blocks != 0 then 0.5 * cast,no_check(float32) lm else 0.0);
        i = start;
        while i < end {
            follow =
                ifx c_transpiler_float_greater((follow - 1.0), (band_log_e[i] - offset)) then follow -
                    1.0 else band_log_e[i] - offset;
            if C == 2 {
                follow =
                    ifx c_transpiler_float_greater(follow, (band_log_e[i + nb_e_bands] - offset)) then follow else band_log_e[i + nb_e_bands] -
                        offset;
            }
            frame_avg += follow;
            i += 1;
        }
        frame_avg /= cast,no_check(Val32) (end - start);
        temporal_vbr = frame_avg - st.spec_avg;
        temporal_vbr =
            ifx c_transpiler_float_less(3.0, (ifx c_transpiler_float_greater(-1.5, temporal_vbr) then -1.5 else temporal_vbr)) then 3.0 else (ifx c_transpiler_float_greater(-1.5, temporal_vbr) then -1.5 else temporal_vbr);
        st.spec_avg += 0.02 * temporal_vbr;
    }

    if second_mdct == 0 {
        copy_memory(
            band_log_e2,
            band_log_e,
            (cast,no_check(u64) (C * nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (band_log_e2 - band_log_e))
        );
    }

    if lm > 0 &&
        ec_tell_in_celt_encoder(enc) + 3 <= total_bits &&
        is_transient == 0 &&
        st.complexity >= 5 &&
        st.lfe == 0 &&
        hybrid == 0 {
        if patch_transient_decision(band_log_e, old_band_e, nb_e_bands, start, end, C) != 0 {
            is_transient = 1;
            short_blocks = m;
            compute_mdcts(mode, short_blocks, in, freq, C, CC, lm, st.upsample, st.arch);
            compute_band_energies(mode, freq, band_e, eff_end, C, lm, st.arch);
            amp2_log2(mode, eff_end, end, band_e, band_log_e, C);

            c = 0;
            while c < C {
                i = 0;
                while i < end {
                    band_log_e2[nb_e_bands * c + i] += 0.5 * cast,no_check(float32) lm;
                    i += 1;
                }
                c += 1;
            }
            tf_estimate = 0.2;
        }
    }

    if lm > 0 && ec_tell_in_celt_encoder(enc) + 3 <= total_bits {
        ec_enc_bit_logp(enc, is_transient, 3);
    }

    x := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) (C * n))));

    normalise_bands(mode, freq, x, band_e, eff_end, C, m);

    enable_tf_analysis :=
        cast(s32) (effective_bytes >= 15 * C && hybrid == 0 && st.complexity >= 2 &&
            st.lfe == 0 && c_transpiler_float_less(toneishness, 0.98));

    offsets := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    importance := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    spread_weight := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    max_depth :=
        dynalloc_analysis(
            band_log_e,
            band_log_e2,
            old_band_e,
            nb_e_bands,
            start,
            end,
            C,
            offsets,
            st.lsb_depth,
            mode.log_n,
            is_transient,
            st.vbr,
            st.constrained_vbr,
            e_bands,
            lm,
            effective_bytes,
            *tot_boost,
            st.lfe,
            surround_dynalloc,
            *st.analysis,
            importance,
            spread_weight,
            tone_freq,
            toneishness
        );

    tf_res := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    if enable_tf_analysis != 0 {
        lambda := (ifx 80 > 20480 / effective_bytes + 2 then 80 else 20480 / effective_bytes + 2);
        tf_select =
            tf_analysis(mode, eff_end, is_transient, tf_res, lambda, x, n, lm, tf_estimate, tf_chan, importance);
        i = eff_end;
        while i < end {
            tf_res[i] = tf_res[eff_end - 1];
            i += 1;
        }
    } else if hybrid != 0 && weak_transient != 0 {
        i = 0;
        while i < end {
            tf_res[i] = 1;
            i += 1;
        }
        tf_select = 0;
    } else if hybrid != 0 && effective_bytes < 15 && st.silk_info.signal_type != 2 {
        i = 0;
        while i < end {
            tf_res[i] = 0;
            i += 1;
        }
        tf_select = is_transient;
    } else {
        i = 0;
        while i < end {
            tf_res[i] = is_transient;
            i += 1;
        }
        tf_select = 0;
    }

    error :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (C * nb_e_bands))));
    c = 0;
    while true {
        i = start;
        while i < end {
            if c_transpiler_float_less(cast,no_check(float32) c_transpiler_math_fabs(
                cast,no_check(float64) (band_log_e[i + c * nb_e_bands] - old_band_e[i + c * nb_e_bands])
            ), 2.0) {
                band_log_e[i + c * nb_e_bands] -= 0.25 * energy_error[i + c * nb_e_bands];
            }
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < C) break;
    }
    quant_coarse_energy(
        mode,
        start,
        end,
        eff_end,
        band_log_e,
        old_band_e,
        cast,no_check(Uint32) total_bits,
        error,
        enc,
        C,
        lm,
        nb_available_bytes,
        st.force_intra,
        *st.delayed_intra,
        cast(s32) (st.complexity >= 4),
        st.loss_rate,
        st.lfe
    );

    tf_encode(start, end, is_transient, tf_res, lm, tf_select, enc);

    if ec_tell_in_celt_encoder(enc) + 4 <= total_bits {
        if st.lfe != 0 {
            st.tapset_decision = 0;
            st.spread_decision = 2;
        } else if hybrid != 0 {
            if st.complexity == 0 {
                st.spread_decision = 0;
            } else if is_transient != 0 {
                st.spread_decision = 2;
            } else {
                st.spread_decision = 3;
            }
        } else if short_blocks != 0 || st.complexity < 3 || nb_available_bytes < 10 * C {
            if st.complexity == 0 {
                st.spread_decision = 0;
            } else {
                st.spread_decision = 2;
            }
        } else {
            st.spread_decision =
                spreading_decision(
                    mode,
                    x,
                    *st.tonal_average,
                    st.spread_decision,
                    *st.hf_average,
                    *st.tapset_decision,
                    cast(s32) (pf_on != 0 && short_blocks == 0),
                    eff_end,
                    C,
                    m,
                    spread_weight
                );
        }
        ec_enc_icdf(enc, st.spread_decision, SPREAD_ICDF_in_celt_encoder.data, 5);
    } else {
        st.spread_decision = 2;
    }

    if st.lfe != 0 {
        offsets[0] = ifx 8 < effective_bytes / 3 then 8 else effective_bytes / 3;
    }
    cap := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    init_caps(mode, cap, lm, C);

    dynalloc_logp: s32 = 6;
    c_transpiler_compound_shl(*(total_bits), (cast(s32) 3), Int32, Int32);
    total_boost: Int32 = 0;
    tell = cast,no_check(Int32) ec_tell_frac(enc);
    i = start;
    while i < end {
        width := (C * ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i])) << ((lm) & 31);

        quanta :=
            (ifx width << 3 < (ifx (cast(s32) 6) << 3 > width then (cast(s32) 6) << 3 else width) then width << 3 else (ifx (cast(s32) 6) << 3 > width then (cast(s32) 6) << 3 else width));
        dynalloc_loop_logp := dynalloc_logp;
        boost: s32 = 0;
        j: s32 = 0;
        while tell + dynalloc_loop_logp << 3 < total_bits - total_boost && boost < cap[i] {
            flag := cast(s32) (j < offsets[i]);
            ec_enc_bit_logp(enc, flag, cast,no_check(u32) dynalloc_loop_logp);
            tell = cast,no_check(Int32) ec_tell_frac(enc);
            if flag == 0 {
                break;
            }
            boost += quanta;
            total_boost = cast,no_check(Int32) (total_boost + quanta);
            dynalloc_loop_logp = 1;
            j += 1;
        }

        if j != 0 {
            dynalloc_logp = ifx 2 > dynalloc_logp - 1 then 2 else dynalloc_logp - 1;
        }
        offsets[i] = boost;
        i += 1;
    }

    if C == 2 {

        if lm != 0 {
            dual_stereo = stereo_analysis(mode, x, lm, n);
        }

        st.intensity =
            hysteresis_decision(
                cast,no_check(Val16) (equiv_rate / 1000),
                INTENSITY_THRESHOLDS.data,
                INTENSITY_HISTERESIS.data,
                21,
                st.intensity
            );
        st.intensity =
            ifx end < (ifx start > st.intensity then start else st.intensity) then end else (ifx start > st.intensity then start else st.intensity);
    }

    alloc_trim: s32 = 5;
    if (tell + cast,no_check(Int32) (((cast(s32) 6) << 3))) <= total_bits - total_boost {
        if start > 0 || st.lfe != 0 {
            st.stereo_saving = 0.0;
            alloc_trim = 5;
        } else {
            alloc_trim =
                alloc_trim_analysis(
                    mode,
                    x,
                    band_log_e,
                    end,
                    lm,
                    C,
                    n,
                    *st.analysis,
                    *st.stereo_saving,
                    tf_estimate,
                    st.intensity,
                    surround_trim,
                    equiv_rate,
                    st.arch
                );
        }
        ec_enc_icdf(enc, alloc_trim, TRIM_ICDF_in_celt_encoder.data, 7);
        tell = cast,no_check(Int32) ec_tell_frac(enc);
    }

    min_allowed :=
        (((tell + total_boost + cast,no_check(Int32) (((cast(s32) 1) << (((3 + 3)) & 31)))) - 1) >> (((3 + 3)) & 31)) +
            2;

    if hybrid != 0 {
        min_allowed =
            ifx min_allowed > ((((tell0_frac + cast,no_check(Int32) (((cast(s32) 37) << 3))) + total_boost) + cast,no_check(Int32) (((cast(s32) 1) << (((3 + 3)) & 31)))) -
                1) >> (((3 + 3)) & 31) then min_allowed else ((((tell0_frac + cast,no_check(Int32) (((cast(s32) 37) << 3))) + total_boost) + cast,no_check(Int32) (((cast(s32) 1) << (((3 + 3)) & 31)))) - 1) >> (((3 + 3)) & 31);
    }

    if vbr_rate > 0 {
        alpha: Val16 = ---;
        target: Int32 = ---;
        lm_diff := mode.max_lm - lm;

        nb_compressed_bytes =
            ifx nb_compressed_bytes < packet_size_cap >> (((3 -
                lm)) & 31) then nb_compressed_bytes else packet_size_cap >> (((3 - lm)) & 31);
        base_target: Int32 = ifx hybrid == 0
            then vbr_rate - (40 * C + 20) << 3
            else (ifx 0 > vbr_rate - (9 * C + 4) << 3 then 0 else vbr_rate - (9 * C + 4) << 3);

        if st.constrained_vbr != 0 {
            base_target += st.vbr_offset >> ((lm_diff) & 31);
        }

        if hybrid == 0 {
            target =
                compute_vbr(
                    mode,
                    *st.analysis,
                    base_target,
                    lm,
                    equiv_rate,
                    st.last_coded_bands,
                    C,
                    st.intensity,
                    st.constrained_vbr,
                    st.stereo_saving,
                    tot_boost,
                    tf_estimate,
                    pitch_change,
                    max_depth,
                    st.lfe,
                    cast(s32) (st.energy_mask != null),
                    surround_masking,
                    temporal_vbr
                );
        } else {
            target = base_target;

            if st.silk_info.offset < 100 {
                target = cast,no_check(Int32) (target + ((cast(s32) 12) << 3 >> (((3 - lm)) & 31)));
            }
            if st.silk_info.offset > 100 {
                target = cast,no_check(Int32) (target - ((cast(s32) 18) << 3 >> (((3 - lm)) & 31)));
            }

            target += cast,no_check(Int32) ((tf_estimate - 0.25) * 400.0);

            if c_transpiler_float_greater(tf_estimate, 0.7) {
                target = ifx target > (cast(s32) 50) << 3 then target else cast,no_check(Int32) (((cast(s32) 50) << 3));
            }
        }

        target = target + tell;

        nb_available_bytes = (target + cast,no_check(Int32) (((cast(s32) 1) << (((3 + 2)) & 31)))) >> (((3 + 3)) & 31);
        nb_available_bytes = max(min_allowed, nb_available_bytes);
        nb_available_bytes = min(nb_compressed_bytes, nb_available_bytes);

        delta := target - vbr_rate;

        target = nb_available_bytes << (((3 + 3)) & 31);

        if silence != 0 {
            nb_available_bytes = 2;
            target = cast,no_check(Int32) (((cast,no_check(s32) ((2 * 8))) << 3));
            delta = 0;
        }

        if st.vbr_count < 970 {
            st.vbr_count += 1;
            alpha = 1.0 / cast,no_check(float32) (st.vbr_count + 20);
        } else {
            alpha = 0.001;
        }

        if st.constrained_vbr != 0 {
            st.vbr_reservoir += target - vbr_rate;
        }

        if st.constrained_vbr != 0 {
            st.vbr_drift +=
                cast,no_check(Int32) (alpha *
                    (delta * (cast(s32) 1) << ((lm_diff) & 31) - st.vbr_offset - st.vbr_drift));
            st.vbr_offset = -st.vbr_drift;
        }

        if st.constrained_vbr != 0 && st.vbr_reservoir < 0 {
            adjust: s32 = -st.vbr_reservoir / cast,no_check(Int32) (((cast(s32) 8) << 3));

            nb_available_bytes += (ifx silence != 0 then 0 else adjust);
            st.vbr_reservoir = 0;
        }
        nb_compressed_bytes = min(nb_compressed_bytes, nb_available_bytes);

        ec_enc_shrink(enc, cast,no_check(Uint32) nb_compressed_bytes);
    }

    fine_quant := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    pulses := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));
    fine_priority := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) nb_e_bands)));

    bits := ((nb_compressed_bytes * 8) << 3 - cast,no_check(Int32) ec_tell_frac(enc)) - 1;
    anti_collapse_rsv: s32 = (ifx is_transient != 0 && lm >= 2 && bits >= (lm + 2) << 3 then (cast(s32) 1) << 3 else 0);
    bits = cast,no_check(Int32) (bits - anti_collapse_rsv);
    signal_bandwidth := end - 1;

    if st.analysis.valid != 0 {
        min_bandwidth: s32 = ifx equiv_rate < (cast(s32) 32000) * C
            then cast(s32) 13
            else ifx equiv_rate < (cast(s32) 48000) * C
                then cast(s32) 16
                else ifx equiv_rate < (cast(s32) 60000) * C
                    then cast(s32) 18
                    else ifx equiv_rate < (cast(s32) 80000) * C
                        then cast(s32) 19
                        else 20;
        signal_bandwidth = ifx st.analysis.bandwidth > min_bandwidth then st.analysis.bandwidth else min_bandwidth;
    }

    if st.lfe != 0 {
        signal_bandwidth = 1;
    }
    coded_bands :=
        clt_compute_allocation(
            mode,
            start,
            end,
            offsets,
            cap,
            alloc_trim,
            *st.intensity,
            *dual_stereo,
            bits,
            *balance,
            pulses,
            fine_quant,
            fine_priority,
            C,
            lm,
            enc,
            1,
            st.last_coded_bands,
            signal_bandwidth
        );
    if st.last_coded_bands != 0 {
        st.last_coded_bands =
            ifx st.last_coded_bands + 1 < (ifx st.last_coded_bands - 1 > coded_bands then st.last_coded_bands - 1 else coded_bands) then st.last_coded_bands +
                1 else (ifx st.last_coded_bands - 1 > coded_bands then st.last_coded_bands - 1 else coded_bands);
    } else {
        st.last_coded_bands = coded_bands;
    }

    quant_fine_energy(mode, start, end, old_band_e, error, null, fine_quant, enc, C);
    fill_memory(energy_error, 0, cast,no_check(u64) (nb_e_bands * CC) * size_of(Celt_Glog));

    collapse_masks := cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) * cast,no_check(u64) (C * nb_e_bands))));
    quant_all_bands(
        1,
        mode,
        start,
        end,
        x,
        (ifx C == 2 then x + n else null),
        collapse_masks,
        band_e,
        pulses,
        short_blocks,
        st.spread_decision,
        dual_stereo,
        st.intensity,
        tf_res,
        nb_compressed_bytes * (cast(s32) 8) << 3 - anti_collapse_rsv,
        balance,
        enc,
        lm,
        coded_bands,
        *st.rng,
        st.complexity,
        st.arch,
        st.disable_inv
    );

    if anti_collapse_rsv > 0 {
        anti_collapse_on = cast(s32) (st.consec_transient < 2);

        ec_enc_bits(enc, cast,no_check(Uint32) anti_collapse_on, 1);
    }
    if qext_bytes == 0 {
        quant_energy_finalise(
            mode,
            start,
            end,
            old_band_e,
            error,
            fine_quant,
            fine_priority,
            nb_compressed_bytes * 8 - ec_tell_in_celt_encoder(enc),
            enc,
            C
        );
    }
    c = 0;
    while true {
        i = start;
        while i < end {
            energy_error[i + c * nb_e_bands] =
                ifx c_transpiler_float_greater(-0.5, (ifx c_transpiler_float_less(0.5, error[i + c * nb_e_bands]) then 0.5 else error[i + c * nb_e_bands])) then -0.5 else (ifx c_transpiler_float_less(0.5, error[i + c * nb_e_bands]) then 0.5 else error[i +
                    c * nb_e_bands]);
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < C) break;
    }

    if silence != 0 {
        i = 0;
        while i < C * nb_e_bands {
            old_band_e[i] = -28.0;
            i += 1;
        }
    }

    st.prefilter_period = pitch_index;
    st.prefilter_gain = gain1;
    st.prefilter_tapset = prefilter_tapset;

    if CC == 2 && C == 1 {
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
            (cast,no_check(u64) (CC * nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (old_log_e2 - old_log_e))
        );
        copy_memory(
            old_log_e,
            old_band_e,
            (cast,no_check(u64) (CC * nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (old_log_e - old_band_e))
        );
    } else {
        i = 0;
        while i < CC * nb_e_bands {
            old_log_e[i] =
                ifx c_transpiler_float_less(old_log_e[i], old_band_e[i]) then old_log_e[i] else old_band_e[i];
            i += 1;
        }
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
        if !(c_transpiler_pre_increment(*(c)) < CC) break;
    }

    if is_transient != 0 || transient_got_disabled != 0 {
        st.consec_transient += 1;
    } else {
        st.consec_transient = 0;
    }
    st.rng = enc.rng;

    ec_enc_done(enc);

    if ec_get_error_in_celt_encoder(enc) != 0 {
        return -3;
    } else {
        return nb_compressed_bytes;
    }
}

compute_vbr :: (
    mode: *Custom_Mode,
    analysis: *Analysis_Info,
    base_target: Int32,
    lm: s32,
    bitrate: Int32,
    last_coded_bands: s32,
    c: s32,
    intensity: s32,
    constrained_vbr: s32,
    stereo_saving: Val16,
    tot_boost: s32,
    tf_estimate: Val16,
    pitch_change: s32,
    max_depth: Celt_Glog,
    lfe: s32,
    has_surround_mask: s32,
    surround_masking: Celt_Glog,
    temporal_vbr: Celt_Glog
) -> s32 {
    nb_e_bands := mode.nb_e_bands;
    e_bands := mode.e_bands;

    coded_bands := (ifx last_coded_bands != 0 then last_coded_bands else nb_e_bands);
    coded_bins := (cast(s32) e_bands[coded_bands]) << ((lm) & 31);
    if c == 2 {
        coded_bins += (cast(s32) (e_bands[min(intensity, coded_bands)])) << ((lm) & 31);
    }

    target := base_target;

    if analysis.valid != 0 && c_transpiler_float_less(cast,no_check(float64) analysis.activity, 0.4) {
        target -= cast,no_check(Int32) ((coded_bins << 3) * (0.4 - analysis.activity));
    }

    if c == 2 {
        coded_stereo_bands := min(intensity, coded_bands);
        coded_stereo_dof := (cast(s32) e_bands[coded_stereo_bands]) << ((lm) & 31) - coded_stereo_bands;

        max_frac :=
            ((cast(float32) 0.800000011920929) * cast,no_check(Val32) coded_stereo_dof) /
                cast,no_check(Val16) coded_bins;
        stereo_saving = ifx c_transpiler_float_less(stereo_saving, 1.0) then stereo_saving else 1.0;

        target -=
            cast,no_check(Int32) ((ifx c_transpiler_float_less((max_frac * target), ((stereo_saving - 0.1) * cast,no_check(Val32) (coded_stereo_dof << 3))) then max_frac *
                target else (stereo_saving - 0.1) * cast,no_check(Val32) (coded_stereo_dof << 3)));
    }

    target = cast,no_check(Int32) (target + (tot_boost - (cast(s32) 19) << ((lm) & 31)));

    tf_calibration: Val16 = 0.044;
    target += cast,no_check(Int32) ((tf_estimate - tf_calibration) * target);

    if analysis.valid != 0 && lfe == 0 {
        tonal :=
            (ifx c_transpiler_float_greater(0.0, (analysis.tonality - 0.15)) then 0.0 else analysis.tonality - 0.15) -
                0.12;
        tonal_target := target + cast,no_check(Int32) ((cast,no_check(float32) (coded_bins << 3)) * 1.2 * tonal);
        if pitch_change != 0 {
            tonal_target += cast,no_check(Int32) ((cast,no_check(float32) (coded_bins << 3)) * 0.8);
        }

        target = tonal_target;
    }

    if has_surround_mask != 0 && lfe == 0 {
        surround_target := target + cast,no_check(Int32) (surround_masking * cast,no_check(Val32) (coded_bins << 3));

        target = ifx target / 4 > surround_target then target / 4 else surround_target;
    }

    {
        bins := (cast(s32) e_bands[nb_e_bands - 2]) << ((lm) & 31);

        floor_depth := cast,no_check(Int32) (((c * bins) << 3) * max_depth);
        floor_depth = ifx floor_depth > target >> 2 then floor_depth else target >> 2;
        target = min(target, floor_depth);
    }

    if (has_surround_mask == 0 || lfe != 0) && constrained_vbr != 0 {
        target = base_target + cast,no_check(Int32) (0.67 * cast,no_check(float32) (target - base_target));
    }

    if has_surround_mask == 0 && c_transpiler_float_less(tf_estimate, 0.2) {
        amount :=
            0.0000031 *
                cast,no_check(float32) ((ifx 0 > (ifx 32000 < 96000 - bitrate then 32000 else 96000 - bitrate) then 0 else (ifx 32000 < 96000 - bitrate then 32000 else 96000 - bitrate)));
        tvbr_factor := temporal_vbr * amount;
        target += cast,no_check(Int32) (tvbr_factor * target);
    }

    target = ifx 2 * base_target < target then 2 * base_target else target;

    return target;
}

alloc_trim_analysis :: (
    m: *Custom_Mode,
    x: *Celt_Norm,
    band_log_e: *Celt_Glog,
    end: s32,
    lm: s32,
    c_value: s32,
    n0: s32,
    analysis: *Analysis_Info,
    stereo_saving: *Val16,
    tf_estimate: Val16,
    intensity: s32,
    surround_trim: Celt_Glog,
    equiv_rate: Int32,
    arch: s32
) -> s32 {
    i: s32 = ---;
    diff: Val32 = 0.0;

    trim: Val16 = 5.0;
    log_xc, log_xc2: Val16 = ---;

    if equiv_rate < 64000 {
        trim = 4.0;
    } else if equiv_rate < 80000 {
        frac := (equiv_rate - 64000) >> 10;
        trim = 4.0 + 0.0625 * cast,no_check(float32) frac;
    }
    if c_value == 2 {
        sum: Val16 = 0.0;

        i = 0;
        while i < 8 {
            partial :=
                celt_inner_prod_c_in_celt_encoder(
                    *x[(cast(s32) m.e_bands[i]) << ((lm) & 31)],
                    *x[n0 + (cast(s32) m.e_bands[i]) << ((lm) & 31)],
                    ((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i]) << ((lm) & 31)
                );
            sum = sum + partial;
            i += 1;
        }
        sum = 0.125 * sum;
        sum =
            ifx c_transpiler_float_less(1.0, cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) sum)) then 1.0 else cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) sum);
        min_xc := sum;
        i = 8;
        while i < intensity {
            partial :=
                celt_inner_prod_c_in_celt_encoder(
                    *x[(cast(s32) m.e_bands[i]) << ((lm) & 31)],
                    *x[n0 + (cast(s32) m.e_bands[i]) << ((lm) & 31)],
                    ((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i]) << ((lm) & 31)
                );
            min_xc =
                ifx c_transpiler_float_less(min_xc, cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) partial)) then min_xc else cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) partial);
            i += 1;
        }
        min_xc =
            ifx c_transpiler_float_less(1.0, cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) min_xc)) then 1.0 else cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) min_xc);

        log_xc =
            cast,no_check(float32) (1.4426950408889634 *
                c_transpiler_math_log(cast,no_check(float64) (1.001 - sum * sum)));

        log_xc2 =
            ifx c_transpiler_float_greater((0.5 * log_xc), cast,no_check(float32) (1.4426950408889634 * c_transpiler_math_log(cast,no_check(float64) (1.001 - min_xc * min_xc)))) then 0.5 *
                log_xc else cast,no_check(float32) (1.4426950408889634 * c_transpiler_math_log(cast,no_check(float64) (1.001 - min_xc * min_xc)));

        trim += (ifx c_transpiler_float_greater(-4.0, (0.75 * log_xc)) then -4.0 else 0.75 * log_xc);
        stereo_saving.* =
            ifx c_transpiler_float_less((stereo_saving.* + 0.25), -(0.5 * log_xc2)) then stereo_saving.* +
                0.25 else -(0.5 * log_xc2);
    }

    c: s32 = 0;
    while true {
        i = 0;
        while i < end - 1 {
            diff += band_log_e[i + c * m.nb_e_bands] * (2 + 2 * i - end);
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
    diff /= cast,no_check(Val32) (c_value * (end - 1));

    trim -=
        (ifx c_transpiler_float_greater(-2.0, (ifx c_transpiler_float_less(2.0, ((diff + 1.0) / 6.0)) then 2.0 else (diff + 1.0) / 6.0)) then -2.0 else (ifx c_transpiler_float_less(2.0, ((diff + 1.0) / 6.0)) then 2.0 else (diff + 1.0) /
            6.0));
    trim -= surround_trim;
    trim -= 2.0 * tf_estimate;

    if analysis.valid != 0 {
        trim -=
            (ifx c_transpiler_float_greater(-2.0, (ifx c_transpiler_float_less(2.0, (2.0 * (analysis.tonality_slope + 0.05))) then 2.0 else 2.0 * (analysis.tonality_slope + 0.05))) then -2.0 else (ifx c_transpiler_float_less(2.0, (2.0 * (analysis.tonality_slope + 0.05))) then 2.0 else 2.0 *
                (analysis.tonality_slope + 0.05)));
    }

    trim_index := cast,no_check(s32) floor(cast,no_check(float64) (0.5 + trim));

    trim_index =
        ifx 0 > (ifx 10 < trim_index then 10 else trim_index) then 0 else (ifx 10 < trim_index then 10 else trim_index);

    return trim_index;
}

celt_inner_prod_c_in_celt_encoder :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

stereo_analysis :: (m: *Custom_Mode, x: *Celt_Norm, lm: s32, n0: s32) -> s32 {
    sum_lr: Val32 = 1.0e-15;
    sum_ms: Val32 = 1.0e-15;

    for i: 0..cast(s32) 13 - 1 {
        j := (cast(s32) m.e_bands[i]) << ((lm) & 31);
        while j < (cast(s32) m.e_bands[i + 1]) << ((lm) & 31) {
            l: Val32 = ---;

            l = x[j];
            r := x[n0 + j];
            m_value := l + r;
            s := l - r;
            sum_lr =
                sum_lr +
                    ((cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) l)) + cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) r));
            sum_ms =
                sum_ms +
                    ((cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) m_value)) + cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) s));
            j += 1;
        }
    }
    sum_ms = 0.707107 * sum_ms;
    thetas: s32 = 13;

    if lm <= 1 {
        thetas -= 8;
    }
    if c_transpiler_float_greater((((cast(s32) m.e_bands[13]) << (((lm + 1)) & 31) + thetas) * sum_ms), (((cast(s32) m.e_bands[13]) << (((lm + 1)) & 31)) * sum_lr)) {
        return 1;
    }
    return 0;
}

tf_encode :: (start: s32, end: s32, is_transient: s32, tf_res: *s32, lm: s32, tf_select: s32, enc: *Ec_Enc) {
    curr: s32 = ---;

    tf_changed: s32 = ---;

    budget := enc.storage * 8;
    tell := cast,no_check(Uint32) ec_tell_in_celt_encoder(enc);
    logp := (ifx is_transient != 0 then cast(s32) 2 else 4);

    tf_select_rsv := cast(s32) (lm > 0 && ((tell + cast,no_check(Uint32) logp) + 1) <= budget);
    budget -= cast,no_check(Uint32) tf_select_rsv;
    tf_changed = 0;
    curr = tf_changed;
    i := start;
    while i < end {
        if (tell + cast,no_check(Uint32) logp) <= budget {
            ec_enc_bit_logp(enc, tf_res[i] ^ curr, cast,no_check(u32) logp);
            tell = cast,no_check(Uint32) ec_tell_in_celt_encoder(enc);
            curr = tf_res[i];
            tf_changed |= curr;
        } else {
            tf_res[i] = curr;
        }
        logp = ifx is_transient != 0 then cast(s32) 4 else 5;
        i += 1;
    }

    if tf_select_rsv != 0 &&
        TF_SELECT_TABLE[lm][4 * is_transient + 0 + tf_changed] != TF_SELECT_TABLE[lm][4 * is_transient + 2 + tf_changed] {
        ec_enc_bit_logp(enc, tf_select, 1);
    } else {
        tf_select = 0;
    }
    i = start;
    while i < end {
        tf_res[i] = cast,no_check(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + tf_res[i]];
        i += 1;
    }
}

tf_analysis :: (
    m: *Custom_Mode,
    len: s32,
    is_transient: s32,
    tf_res: *s32,
    lambda: s32,
    x: *Celt_Norm,
    n0: s32,
    lm: s32,
    tf_estimate: Val16,
    tf_chan: s32,
    importance: *s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    cost0: s32 = ---;
    cost1: s32 = ---;

    selcost: [2] s32 = ---;
    tf_select: s32 = 0;

    bias := 0.04 * (ifx c_transpiler_float_greater(-0.25, (0.5 - tf_estimate)) then -0.25 else 0.5 - tf_estimate);

    metric := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));
    tmp :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) (((cast(s32) m.e_bands[len]) - cast(s32) m.e_bands[len - 1]) << ((lm) & 31)))));
    tmp_1 :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) (((cast(s32) m.e_bands[len]) - cast(s32) m.e_bands[len - 1]) << ((lm) & 31)))));
    path0 := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));
    path1 := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));

    i: s32 = 0;
    while i < len {
        best_level: s32 = 0;
        n := ((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i]) << ((lm) & 31);

        narrow := cast(s32) (((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i]) == 1);
        copy_memory(
            tmp,
            *x[tf_chan * n0 + (cast(s32) m.e_bands[i]) << ((lm) & 31)],
            (cast,no_check(u64) n) * size_of(Celt_Norm) +
            cast,no_check(u64) (0 * (tmp - *x[tf_chan * n0 + (cast(s32) m.e_bands[i]) << ((lm) & 31)]))
        );

        l1 := l1_metric(tmp, n, (ifx is_transient != 0 then lm else 0), bias);
        best_l1 := l1;

        if is_transient != 0 && narrow == 0 {
            copy_memory(
                tmp_1,
                tmp,
                (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (tmp_1 - tmp))
            );
            haar1(tmp_1, n >> ((lm) & 31), (cast(s32) 1) << ((lm) & 31));
            l1 = l1_metric(tmp_1, n, lm + 1, bias);
            if c_transpiler_float_less(l1, best_l1) {
                best_l1 = l1;
                best_level = -1;
            }
        }

        k: s32 = 0;
        while k < lm + cast(s32) (!(is_transient != 0 || narrow != 0)) {
            b: s32 = ifx is_transient != 0
                then lm - k - 1
                else k + 1;

            haar1(tmp, n >> ((k) & 31), (cast(s32) 1) << ((k) & 31));

            l1 = l1_metric(tmp, n, b, bias);

            if c_transpiler_float_less(l1, best_l1) {
                best_l1 = l1;
                best_level = k + 1;
            }
            k += 1;
        }

        if is_transient != 0 {
            metric[i] = 2 * best_level;
        } else {
            metric[i] = -2 * best_level;
        }

        if narrow != 0 && (metric[i] == 0 || metric[i] == -2 * lm) {
            metric[i] -= 1;
        }
        i += 1;
    }

    tf_select = 0;
    for sel: 0..cast(s32) 2 - 1 {
        cost0 =
            importance[0] *
                absolute_value(metric[0] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * sel + 0]);
        cost1 =
            (importance[0] * absolute_value(metric[0] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * sel + 1])) +
                (ifx is_transient != 0 then 0 else lambda);
        i = 1;
        while i < len {
            curr0: s32 = ---;
            curr0 = ifx cost0 < cost1 + lambda then cost0 else cost1 + lambda;
            curr1 := (ifx cost0 + lambda < cost1 then cost0 + lambda else cost1);
            cost0 =
                curr0 +
                    importance[i] * absolute_value(metric[i] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * sel + 0]);
            cost1 =
                curr1 +
                    importance[i] * absolute_value(metric[i] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * sel + 1]);
            i += 1;
        }
        cost0 = min(cost0, cost1);
        selcost[sel] = cost0;
    }

    if selcost[1] < selcost[0] && is_transient != 0 {
        tf_select = 1;
    }
    cost0 =
        importance[0] *
            absolute_value(metric[0] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + 0]);
    cost1 =
        (importance[0] * absolute_value(metric[0] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + 1])) +
            (ifx is_transient != 0 then 0 else lambda);

    i = 1;
    while i < len {
        curr0, curr1: s32 = ---;
        from0: s32 = ---;

        from0 = cost0;
        from1 := cost1 + lambda;
        if from0 < from1 {
            curr0 = from0;
            path0[i] = 0;
        } else {
            curr0 = from1;
            path0[i] = 1;
        }

        from0 = cost0 + lambda;
        from1 = cost1;
        if from0 < from1 {
            curr1 = from0;
            path1[i] = 0;
        } else {
            curr1 = from1;
            path1[i] = 1;
        }
        cost0 =
            curr0 +
                importance[i] * absolute_value(metric[i] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + 0]);
        cost1 =
            curr1 +
                importance[i] * absolute_value(metric[i] - 2 * cast(s32) TF_SELECT_TABLE[lm][4 * is_transient + 2 * tf_select + 1]);
        i += 1;
    }
    tf_res[len - 1] = ifx cost0 < cost1 then cast(s32) 0 else 1;

    i = len - 2;
    while i >= 0 {
        if tf_res[i + 1] == 1 {
            tf_res[i] = path1[i + 1];
        } else {
            tf_res[i] = path0[i + 1];
        }
        i -= 1;
    }

    return tf_select;
}

l1_metric :: (tmp: *Celt_Norm, n: s32, lm: s32, bias: Val16) -> Val32 {
    l1: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            l1 += cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) tmp[i]);
        }
    }

    l1 = l1 + lm * bias * l1;
    return l1;
}

dynalloc_analysis :: (
    band_log_e: *Celt_Glog,
    band_log_e2: *Celt_Glog,
    old_band_e: *Celt_Glog,
    nb_e_bands: s32,
    start: s32,
    end: s32,
    c_value: s32,
    offsets: *s32,
    lsb_depth: s32,
    log_n: *Int16,
    is_transient: s32,
    vbr: s32,
    constrained_vbr: s32,
    e_bands: *Int16,
    lm: s32,
    effective_bytes: s32,
    tot_boost_value: *Int32,
    lfe: s32,
    surround_dynalloc: *Celt_Glog,
    analysis: *Analysis_Info,
    importance: *s32,
    spread_weight: *s32,
    tone_freq: Val16,
    toneishness: Val32
) -> Celt_Glog {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    tot_boost: Int32 = 0;

    follower :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (c_value * nb_e_bands))));
    noise_floor :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (c_value * nb_e_bands))));
    band_log_e3 :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) nb_e_bands)));
    fill_memory(offsets, 0, cast,no_check(u64) nb_e_bands * size_of(s32));

    max_depth: Celt_Glog = cast(float32) -31.899999618530275;
    i: s32 = 0;
    while i < end {
        noise_floor[i] =
            ((((0.0625 * cast,no_check(float32) log_n[i]) + 0.5) + (9 - lsb_depth)) - E_MEANS[i]) +
                (0.0062 * cast,no_check(float32) (i + 5)) * (i + 5);
        i += 1;
    }
    c: s32 = 0;
    while true {
        i = 0;
        while i < end {
            max_depth =
                ifx c_transpiler_float_greater(max_depth, (band_log_e[c * nb_e_bands + i] - noise_floor[i])) then max_depth else band_log_e[c * nb_e_bands + i] -
                    noise_floor[i];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
    {
        mask := cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) * cast,no_check(u64) nb_e_bands)));
        sig := cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) * cast,no_check(u64) nb_e_bands)));
        i = 0;
        while i < end {
            mask[i] = band_log_e[i] - noise_floor[i];
            i += 1;
        }
        if c_value == 2 {
            i = 0;
            while i < end {
                mask[i] =
                    ifx c_transpiler_float_greater(mask[i], (band_log_e[nb_e_bands + i] - noise_floor[i])) then mask[i] else band_log_e[nb_e_bands + i] -
                        noise_floor[i];
                i += 1;
            }
        }
        copy_memory(sig, mask, (cast,no_check(u64) end) * size_of(Celt_Glog) + cast,no_check(u64) (0 * (sig - mask)));
        i = 1;
        while i < end {
            mask[i] = ifx c_transpiler_float_greater(mask[i], (mask[i - 1] - 2.0)) then mask[i] else mask[i - 1] - 2.0;
            i += 1;
        }
        i = end - 2;
        while i >= 0 {
            mask[i] = ifx c_transpiler_float_greater(mask[i], (mask[i + 1] - 3.0)) then mask[i] else mask[i + 1] - 3.0;
            i -= 1;
        }
        i = 0;
        while i < end {
            smr :=
                sig[i] -
                    (ifx c_transpiler_float_greater((ifx c_transpiler_float_greater(0.0, (max_depth - 12.0)) then 0.0 else max_depth - 12.0), mask[i]) then (ifx c_transpiler_float_greater(0.0, (max_depth - 12.0)) then 0.0 else max_depth - 12.0) else mask[i]);

            shift :=
                (ifx 5 < (ifx 0 > -(cast,no_check(s32) floor(cast,no_check(float64) (0.5 + smr))) then 0 else -(cast,no_check(s32) floor(cast,no_check(float64) (0.5 +
                    smr)))) then 5 else (ifx 0 > -(cast,no_check(s32) floor(cast,no_check(float64) (0.5 + smr))) then 0 else -(cast,no_check(s32) floor(cast,no_check(float64) (0.5 + smr)))));

            spread_weight[i] = (cast(s32) 32) >> ((shift) & 31);
            i += 1;
        }
    }

    if effective_bytes >= 30 + 5 * lm && lfe == 0 {
        last: s32 = 0;
        c = 0;
        while true {
            {
                copy_memory(
                    band_log_e3,
                    *band_log_e2[c * nb_e_bands],
                    (cast,no_check(u64) end) * size_of(Celt_Glog) +
                    cast,no_check(u64) (0 * (band_log_e3 - *band_log_e2[c * nb_e_bands]))
                );
                if lm == 0 {
                    i = 0;
                    while i < (ifx 8 < end then 8 else end) {
                        band_log_e3[i] =
                            ifx c_transpiler_float_greater(band_log_e2[c * nb_e_bands + i], old_band_e[c * nb_e_bands + i]) then band_log_e2[c * nb_e_bands +
                                i] else old_band_e[c * nb_e_bands + i];
                        i += 1;
                    }
                }
                f := *follower[c * nb_e_bands];
                f[0] = band_log_e3[0];
                i = 1;
                while i < end {
                    if c_transpiler_float_greater(band_log_e3[i], (band_log_e3[i - 1] + 0.5)) {
                        last = i;
                    }
                    f[i] =
                        ifx c_transpiler_float_less((f[i - 1] + 1.5), band_log_e3[i]) then f[i - 1] +
                            1.5 else band_log_e3[i];
                    i += 1;
                }
                i = last - 1;
                while i >= 0 {
                    f[i] =
                        ifx c_transpiler_float_less(f[i], (ifx c_transpiler_float_less((f[i + 1] + 2.0), band_log_e3[i]) then f[i + 1] + 2.0 else band_log_e3[i])) then f[i] else (ifx c_transpiler_float_less((f[i + 1] + 2.0), band_log_e3[i]) then f[i + 1] +
                            2.0 else band_log_e3[i]);
                    i -= 1;
                }

                offset: Celt_Glog = 1.0;
                i = 2;
                while i < end - 2 {
                    f[i] =
                        ifx c_transpiler_float_greater(f[i], (median_of_5(*band_log_e3[i - 2]) - offset)) then f[i] else median_of_5(*band_log_e3[i - 2]) -
                            offset;
                    i += 1;
                }
                tmp := median_of_3(*band_log_e3[0]) - offset;
                f[0] = ifx c_transpiler_float_greater(f[0], tmp) then f[0] else tmp;
                f[1] = ifx c_transpiler_float_greater(f[1], tmp) then f[1] else tmp;
                tmp = median_of_3(*band_log_e3[end - 3]) - offset;
                f[end - 2] = ifx c_transpiler_float_greater(f[end - 2], tmp) then f[end - 2] else tmp;
                f[end - 1] = ifx c_transpiler_float_greater(f[end - 1], tmp) then f[end - 1] else tmp;

                i = 0;
                while i < end {
                    f[i] = ifx c_transpiler_float_greater(f[i], noise_floor[i]) then f[i] else noise_floor[i];
                    i += 1;
                }
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        if c_value == 2 {
            i = start;
            while i < end {
                follower[nb_e_bands + i] =
                    ifx c_transpiler_float_greater(follower[nb_e_bands + i], (follower[i] - 4.0)) then follower[nb_e_bands + i] else follower[i] -
                        4.0;
                follower[i] =
                    ifx c_transpiler_float_greater(follower[i], (follower[nb_e_bands + i] - 4.0)) then follower[i] else follower[nb_e_bands + i] -
                        4.0;
                follower[i] =
                    0.5 *
                        ((ifx c_transpiler_float_greater(0.0, (band_log_e[i] - follower[i])) then 0.0 else band_log_e[i] - follower[i]) + (ifx c_transpiler_float_greater(0.0, (band_log_e[nb_e_bands + i] - follower[nb_e_bands + i])) then 0.0 else band_log_e[nb_e_bands + i] - follower[nb_e_bands + i]));
                i += 1;
            }
        } else {
            i = start;
            while i < end {
                follower[i] =
                    ifx c_transpiler_float_greater(0.0, (band_log_e[i] - follower[i])) then 0.0 else band_log_e[i] -
                        follower[i];
                i += 1;
            }
        }
        i = start;
        while i < end {
            follower[i] =
                ifx c_transpiler_float_greater(follower[i], surround_dynalloc[i]) then follower[i] else surround_dynalloc[i];
            i += 1;
        }
        i = start;
        while i < end {
            importance[i] =
                cast,no_check(s32) floor(
                    cast,no_check(float64) (0.5 + 13.0 * cast,no_check(float32) c_transpiler_math_exp(
                    0.6931471805599453 *
                    cast,no_check(float64) ((ifx c_transpiler_float_less(follower[i], 4.0) then follower[i] else 4.0))
                ))
                );
            i += 1;
        }

        if (vbr == 0 || constrained_vbr != 0) && is_transient == 0 {
            i = start;
            while i < end {
                follower[i] = 0.5 * follower[i];
                i += 1;
            }
        }
        i = start;
        while i < end {
            if i < 8 {
                follower[i] *= 2.0;
            }
            if i >= 12 {
                follower[i] = 0.5 * follower[i];
            }
            i += 1;
        }

        if c_transpiler_float_greater(toneishness, 0.98) {
            freq_bin :=
                cast,no_check(s32) floor(
                    0.5 + (cast,no_check(float64) (tone_freq * 120.0)) / 3.141592653589793
                );

            i = start;
            while i < end {
                if freq_bin >= cast,no_check(s32) e_bands[i] && freq_bin <= cast,no_check(s32) e_bands[i + 1] {
                    follower[i] += 2.0;
                }
                if freq_bin >= (cast(s32) e_bands[i]) - 1 && freq_bin <= (cast(s32) e_bands[i + 1]) + 1 {
                    follower[i] += 1.0;
                }
                if freq_bin >= (cast(s32) e_bands[i]) - 2 && freq_bin <= (cast(s32) e_bands[i + 1]) + 2 {
                    follower[i] += 1.0;
                }
                if freq_bin >= (cast(s32) e_bands[i]) - 3 && freq_bin <= (cast(s32) e_bands[i + 1]) + 3 {
                    follower[i] += 0.5;
                }
                i += 1;
            }
            if freq_bin >= cast,no_check(s32) e_bands[end] {
                follower[end - 1] += 2.0;
                follower[end - 2] += 1.0;
            }
        }

        if analysis.valid != 0 {
            i = start;
            while i < (ifx 19 < end then 19 else end) {
                follower[i] = follower[i] + 0.015625 * cast,no_check(float32) analysis.leak_boost[i];
                i += 1;
            }
        }

        i = start;
        while i < end {
            boost: s32 = ---;
            boost_bits: s32 = ---;

            follower[i] = ifx c_transpiler_float_less(follower[i], 4.0) then follower[i] else 4.0;

            follower[i] = follower[i];
            width := (c_value * ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i])) << ((lm) & 31);
            if width < 6 {
                boost = cast,no_check(s32) follower[i];
                boost_bits = (boost * width) << 3;
            } else if width > 48 {
                boost = cast,no_check(s32) (follower[i] * 8.0);
                boost_bits = (boost * width) << 3 / 8;
            } else {
                boost = cast,no_check(s32) (follower[i] * width / 6.0);
                boost_bits = (boost * 6) << 3;
            }

            if (vbr == 0 || constrained_vbr != 0 && is_transient == 0) && (tot_boost + boost_bits) >> 3 >> 3 > 2 * effective_bytes / 3 {
                cap: Int32 = (2 * effective_bytes / 3) << 3 << 3;
                offsets[i] = cap - tot_boost;
                tot_boost = cap;
                break;
            } else {
                offsets[i] = boost;
                tot_boost = cast,no_check(Int32) (tot_boost + boost_bits);
            }
            i += 1;
        }
    } else {
        i = start;
        while i < end {
            importance[i] = 13;
            i += 1;
        }
    }
    tot_boost_value.* = tot_boost;

    return max_depth;
}

median_of_3 :: (x: *Celt_Glog) -> Celt_Glog {
    t0: Celt_Glog = ---;
    t1: Celt_Glog = ---;
    if c_transpiler_float_greater(x[0], x[1]) {
        t0 = x[1];
        t1 = x[0];
    } else {
        t0 = x[0];
        t1 = x[1];
    }
    t2 := x[2];
    if c_transpiler_float_less(t1, t2) {
        return t1;
    } else if c_transpiler_float_less(t0, t2) {
        return t2;
    } else {
        return t0;
    }
}

median_of_5 :: (x: *Celt_Glog) -> Celt_Glog {
    t0, t1, t2, t3, t4: Celt_Glog = ---;
    t2 = x[2];
    if c_transpiler_float_greater(x[0], x[1]) {
        t0 = x[1];
        t1 = x[0];
    } else {
        t0 = x[0];
        t1 = x[1];
    }
    if c_transpiler_float_greater(x[3], x[4]) {
        t3 = x[4];
        t4 = x[3];
    } else {
        t3 = x[3];
        t4 = x[4];
    }
    if c_transpiler_float_greater(t0, t3) {
        {
            tmp := t0;

            t0 = t3;

            t3 = tmp;
        }
        {
            tmp := t1;

            t1 = t4;

            t4 = tmp;
        }
    }
    if c_transpiler_float_greater(t2, t1) {
        if c_transpiler_float_less(t1, t3) {
            return ifx c_transpiler_float_less(t2, t3) then t2 else t3;
        } else {
            return ifx c_transpiler_float_less(t4, t1) then t4 else t1;
        }
    } else if c_transpiler_float_less(t2, t3) {
        return ifx c_transpiler_float_less(t1, t3) then t1 else t3;
    } else {
        return ifx c_transpiler_float_less(t2, t4) then t2 else t4;
    }
}

compute_mdcts :: (
    mode: *Custom_Mode,
    short_blocks: s32,
    in: *Celt_Sig,
    out: *Celt_Sig,
    c_value: s32,
    cc: s32,
    lm: s32,
    upsample: s32,
    arch: s32
) {
    OVERLAP := mode.overlap;
    n: s32 = ---;
    b_value: s32 = ---;
    shift: s32 = ---;
    i: s32 = ---;
    b: s32 = ---;
    if short_blocks != 0 {
        b_value = short_blocks;
        n = mode.short_mdct_size;
        shift = mode.max_lm;
    } else {
        b_value = 1;
        n = mode.short_mdct_size << ((lm) & 31);
        shift = mode.max_lm - lm;
    }
    c: s32 = 0;
    while true {
        b = 0;
        while b < b_value {
            (cast,no_check(#type (_: *Mdct_Lookup, _: *float32, _: *float32, _: *Celt_Coef, _: s32, _: s32, _: s32, _: s32)) (cast(*void) clt_mdct_forward_c))(
                *mode.mdct,
                in + c * (b_value * n + OVERLAP) + b * n,
                *out[b + c * n * b_value],
                mode.window,
                OVERLAP,
                shift,
                b_value,
                arch
            );
            b += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }
    if cc == 2 && c_value == 1 {
        i = 0;
        while i < b_value * n {
            out[i] = 0.5 * out[i] + 0.5 * out[b_value * n + i];
            i += 1;
        }
    }
    if upsample != 1 {
        c = 0;
        while true {
            {
                bound := b_value * n / upsample;
                i = 0;
                while i < bound {
                    out[c * b_value * n + i] *= cast,no_check(Celt_Sig) upsample;
                    i += 1;
                }
                fill_memory(
                    *out[c * b_value * n + bound],
                    0,
                    cast,no_check(u64) (b_value * n - bound) * size_of(Celt_Sig)
                );
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
    }
}

patch_transient_decision :: (
    new_e: *Celt_Glog,
    old_e: *Celt_Glog,
    nb_e_bands: s32,
    start: s32,
    end: s32,
    c_value: s32
) -> s32 {
    i: s32 = ---;
    mean_diff: Val32 = 0.0;
    spread_old: [26] Celt_Glog = ---;

    if c_value == 1 {
        spread_old[start] = old_e[start];
        i = start + 1;
        while i < end {
            spread_old[i] =
                ifx c_transpiler_float_greater((spread_old[i - 1] - 1.0), old_e[i]) then spread_old[i - 1] -
                    1.0 else old_e[i];
            i += 1;
        }
    } else {
        spread_old[start] =
            ifx c_transpiler_float_greater(old_e[start], old_e[start + nb_e_bands]) then old_e[start] else old_e[start +
                nb_e_bands];
        i = start + 1;
        while i < end {
            spread_old[i] =
                ifx c_transpiler_float_greater((spread_old[i - 1] - 1.0), (ifx c_transpiler_float_greater(old_e[i], old_e[i + nb_e_bands]) then old_e[i] else old_e[i + nb_e_bands])) then spread_old[i - 1] -
                    1.0 else (ifx c_transpiler_float_greater(old_e[i], old_e[i + nb_e_bands]) then old_e[i] else old_e[i + nb_e_bands]);
            i += 1;
        }
    }
    i = end - 2;
    while i >= start {
        spread_old[i] =
            ifx c_transpiler_float_greater(spread_old[i], (spread_old[i + 1] - 1.0)) then spread_old[i] else spread_old[i + 1] -
                1.0;
        i -= 1;
    }

    c: s32 = 0;
    while true {
        i = ifx 2 > start then 2 else start;
        while i < end - 1 {
            x1: Val16 = ---;
            x1 = ifx c_transpiler_float_greater(0.0, new_e[i + c * nb_e_bands]) then 0.0 else new_e[i + c * nb_e_bands];
            x2 := (ifx c_transpiler_float_greater(0.0, spread_old[i]) then 0.0 else spread_old[i]);
            mean_diff = mean_diff + (ifx c_transpiler_float_greater(0.0, (x1 - x2)) then 0.0 else x1 - x2);
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
    mean_diff = mean_diff / cast,no_check(Val32) (c_value * (end - 1 - (ifx 2 > start then 2 else start)));

    if c_transpiler_float_greater(mean_diff, 1.0) {
        return 1;
    }
    return 0;
}

run_prefilter :: (
    st: *Custom_Encoder_in_celt_encoder,
    in: *Celt_Sig,
    prefilter_mem: *Celt_Sig,
    cc: s32,
    n: s32,
    prefilter_tapset: s32,
    pitch: *s32,
    gain: *Val16,
    qgain: *s32,
    enabled: s32,
    complexity: s32,
    tf_estimate: Val16,
    nb_available_bytes: s32,
    analysis: *Analysis_Info,
    tone_freq: Val16,
    toneishness: Val32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    pre: [2] *Celt_Sig = ---;

    pitch_index: s32 = ---;
    gain1: Val16 = ---;

    pf_on: s32 = ---;
    qg: s32 = ---;

    before := Val32.[ 0.0, cast,no_check(Val32) 0 ];
    after := Val32.[ 0.0, cast,no_check(Val32) 0 ];
    cancel_pitch: s32 = 0;

    max_period: s32 = 1024;
    min_period: s32 = 15;
    mode := st.mode;
    overlap := mode.overlap;
    pre_value :=
        cast(*Celt_Sig) c_transpiler_alloca(cast(u64) ((size_of(Celt_Sig) *
            cast,no_check(u64) (cc * (n + max_period)))));

    pre[0] = pre_value;
    pre[1] = pre_value + (n + max_period);

    c: s32 = 0;
    while true {
        copy_memory(
            pre[c],
            prefilter_mem + c * max_period,
            (cast,no_check(u64) max_period) * size_of(Celt_Sig) +
            cast,no_check(u64) (0 * (pre[c] - (prefilter_mem + c * max_period)))
        );
        copy_memory(
            pre[c] + max_period,
            in + c * (n + overlap) + overlap,
            (cast,no_check(u64) n) * size_of(Celt_Sig) +
            cast,no_check(u64) (0 * (pre[c] + max_period - (in + c * (n + overlap) + overlap)))
        );
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }

    if enabled != 0 && c_transpiler_float_greater(toneishness, 0.99) {
        multiple: s32 = 1;

        if c_transpiler_float_greater_equal(tone_freq, 3.1416) {
            tone_freq = 3.141593 - tone_freq;
        }

        while c_transpiler_float_greater_equal(tone_freq, ((cast,no_check(float32) multiple) * 0.39)) {
            multiple += 1;
        }
        if c_transpiler_float_greater(tone_freq, 0.006148) {
            pitch_index =
                ifx cast,no_check(s32) floor(
                    0.5 + (6.283185307179586 * cast,no_check(float64) multiple) / cast,no_check(float64) tone_freq
                ) < 1024 - 2 then cast,no_check(s32) floor(
                    0.5 + (6.283185307179586 * cast,no_check(float64) multiple) / cast,no_check(float64) tone_freq
                ) else cast,no_check(s32) ((1024 - 2));
        } else {
            pitch_index = 15;
        }
        gain1 = 0.75;
    } else if enabled != 0 && complexity >= 5 {
        pitch_buf :=
            cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) *
                cast,no_check(u64) ((max_period + n) >> 1))));

        pitch_downsample(pre.data, pitch_buf, (max_period + n) >> 1, cc, 2, st.arch);

        pitch_search(pitch_buf + max_period >> 1, pitch_buf, n, max_period - 3 * min_period, *pitch_index, st.arch);
        pitch_index = max_period - pitch_index;

        gain1 =
            remove_doubling(
                pitch_buf,
                max_period,
                min_period,
                n,
                *pitch_index,
                st.prefilter_period,
                st.prefilter_gain,
                st.arch
            );
        if pitch_index > max_period - 2 {
            pitch_index = max_period - 2;
        }

        gain1 = 0.7 * gain1;

        if st.loss_rate > 2 {
            gain1 = 0.5 * gain1;
        }
        if st.loss_rate > 4 {
            gain1 = 0.5 * gain1;
        }
        if st.loss_rate > 8 {
            gain1 = 0.0;
        }
    } else {
        gain1 = 0.0;
        pitch_index = 15;
    }

    if analysis.valid != 0 {
        gain1 = gain1 * analysis.max_pitch_ratio;
    }

    pf_threshold: Val16 = 0.2;

    if absolute_value(pitch_index - st.prefilter_period) * 10 > pitch_index {
        pf_threshold += 0.2;

        if c_transpiler_float_greater(tf_estimate, 0.98) {
            gain1 = 0.0;
        }
    }
    if nb_available_bytes < 25 {
        pf_threshold += 0.1;
    }
    if nb_available_bytes < 35 {
        pf_threshold += 0.1;
    }
    if c_transpiler_float_greater(st.prefilter_gain, 0.4) {
        pf_threshold -= 0.1;
    }
    if c_transpiler_float_greater(st.prefilter_gain, 0.55) {
        pf_threshold -= 0.1;
    }

    pf_threshold = ifx c_transpiler_float_greater(pf_threshold, 0.2) then pf_threshold else 0.2;
    if c_transpiler_float_less(gain1, pf_threshold) {
        gain1 = 0.0;
        pf_on = 0;
        qg = 0;
    } else {
        if c_transpiler_float_less(cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) (gain1 - st.prefilter_gain)), 0.1) {
            gain1 = st.prefilter_gain;
        }

        qg = (cast,no_check(s32) floor(cast,no_check(float64) (0.5 + gain1 * 32.0 / 3.0))) - 1;

        qg = ifx 0 > (ifx 7 < qg then 7 else qg) then 0 else (ifx 7 < qg then 7 else qg);
        gain1 = 0.09375 * cast,no_check(float32) (qg + 1);
        pf_on = 1;
    }

    c = 0;
    while true {
        {
            offset := mode.short_mdct_size - overlap;
            st.prefilter_period = ifx st.prefilter_period > 15 then st.prefilter_period else 15;
            copy_memory(
                in + c * (n + overlap),
                st.in_mem.data + c * overlap,
                (cast,no_check(u64) overlap) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (in + c * (n + overlap) - (st.in_mem.data + c * overlap)))
            );
            if 0 < n {
                for i: 0..n - 1 {
                    before[c] +=
                        cast,no_check(float32) c_transpiler_math_fabs(
                            cast,no_check(float64) in[c * (n + overlap) + overlap + i]
                        );
                }
            }
            if offset != 0 {
                comb_filter(
                    in + c * (n + overlap) + overlap,
                    pre[c] + max_period,
                    st.prefilter_period,
                    st.prefilter_period,
                    offset,
                    -st.prefilter_gain,
                    -st.prefilter_gain,
                    st.prefilter_tapset,
                    st.prefilter_tapset,
                    null,
                    0,
                    st.arch
                );
            }

            comb_filter(
                in + c * (n + overlap) + overlap + offset,
                pre[c] + max_period + offset,
                st.prefilter_period,
                pitch_index,
                n - offset,
                -st.prefilter_gain,
                -gain1,
                st.prefilter_tapset,
                prefilter_tapset,
                mode.window,
                overlap,
                st.arch
            );
            if 0 < n {
                for i: 0..n - 1 {
                    after[c] +=
                        cast,no_check(float32) c_transpiler_math_fabs(
                            cast,no_check(float64) in[c * (n + overlap) + overlap + i]
                        );
                }
            }
        }
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }

    if cc == 2 {
        thresh: [2] Val16 = ---;
        thresh[0] = 0.25 * gain1 * before[0] + 0.01 * before[1];
        thresh[1] = 0.25 * gain1 * before[1] + 0.01 * before[0];

        if c_transpiler_float_greater((after[0] - before[0]), thresh[0]) ||
            c_transpiler_float_greater((after[1] - before[1]), thresh[1]) {
            cancel_pitch = 1;
        }

        if c_transpiler_float_less((before[0] - after[0]), thresh[0]) && c_transpiler_float_less((before[1] - after[1]), thresh[1]) {
            cancel_pitch = 1;
        }
    } else if c_transpiler_float_greater(after[0], before[0]) {
        cancel_pitch = 1;
    }

    if cancel_pitch != 0 {
        c = 0;
        while true {
            {
                offset := mode.short_mdct_size - overlap;
                copy_memory(
                    in + c * (n + overlap) + overlap,
                    pre[c] + max_period,
                    (cast,no_check(u64) n) * size_of(Celt_Sig) +
                    cast,no_check(u64) (0 * (in + c * (n + overlap) + overlap - (pre[c] + max_period)))
                );
                comb_filter(
                    in + c * (n + overlap) + overlap + offset,
                    pre[c] + max_period + offset,
                    st.prefilter_period,
                    pitch_index,
                    overlap,
                    -st.prefilter_gain,
                    0.0,
                    st.prefilter_tapset,
                    prefilter_tapset,
                    mode.window,
                    overlap,
                    st.arch
                );
            }
            if !(c_transpiler_pre_increment(*(c)) < cc) break;
        }
        gain1 = 0.0;
        pf_on = 0;
        qg = 0;
    }

    c = 0;
    while true {
        copy_memory(
            st.in_mem.data + c * overlap,
            in + c * (n + overlap) + n,
            (cast,no_check(u64) overlap) * size_of(Celt_Sig) +
            cast,no_check(u64) (0 * (st.in_mem.data + c * overlap - (in + c * (n + overlap) + n)))
        );

        if n > max_period {
            copy_memory(
                prefilter_mem + c * max_period,
                pre[c] + n,
                (cast,no_check(u64) max_period) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (prefilter_mem + c * max_period - (pre[c] + n)))
            );
        } else {
            move_memory(
                prefilter_mem + c * max_period,
                prefilter_mem + c * max_period + n,
                (cast,no_check(u64) (max_period - n)) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (prefilter_mem + c * max_period - (prefilter_mem + c * max_period + n)))
            );
            copy_memory(
                prefilter_mem + c * max_period + max_period - n,
                pre[c] + max_period,
                (cast,no_check(u64) n) * size_of(Celt_Sig) +
                cast,no_check(u64) (0 * (prefilter_mem + c * max_period + max_period - n - (pre[c] + max_period)))
            );
        }
        if !(c_transpiler_pre_increment(*(c)) < cc) break;
    }

    gain.* = gain1;
    pitch.* = pitch_index;
    qgain.* = qg;
    return pf_on;
}

transient_analysis :: (
    in: *Val32,
    len: s32,
    c_value: s32,
    tf_estimate: *Val16,
    tf_chan: *s32,
    allow_weak_transients: s32,
    weak_transient: *s32,
    tone_freq: Val16,
    toneishness: Val32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    is_transient: s32 = 0;
    mask_metric: Int32 = 0;

    forward_decay: Val16 = 0.0625;


    tmp := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) len)));

    weak_transient.* = 0;

    if allow_weak_transients != 0 {
        forward_decay = 0.03125;
    }
    len2 := len / 2;
    if 0 < c_value {
        for c: 0..c_value - 1 {
            unmask: Int32 = 0;

            mem0: Val32 = 0.0;
            mem1: Val32 = 0.0;

            i = 0;
            while i < len {
                x: Val32 = ---;
                x = in[i + c * len];
                y := mem0 + x;

                mem00 := mem0;
                mem0 = mem0 - x + 0.5 * mem1;
                mem1 = x - mem00;

                tmp[i] = y;
                i += 1;
            }

            fill_memory(tmp, 0, cast(u64) 12 * size_of(Val16));

            mean: Val32 = 0.0;
            mem0 = 0.0;

            i = 0;
            while i < len2 {
                x2 := tmp[2 * i] * tmp[2 * i] + tmp[2 * i + 1] * tmp[2 * i + 1];
                mean += x2;

                mem0 = x2 + (1.0 - forward_decay) * mem0;
                tmp[i] = forward_decay * mem0;
                i += 1;
            }

            mem0 = 0.0;
            max_e: Val16 = 0.0;

            i = len2 - 1;
            while i >= 0 {
                mem0 = tmp[i] + 0.875 * mem0;
                tmp[i] = 0.125 * mem0;
                max_e = ifx c_transpiler_float_greater(max_e, (0.125 * mem0)) then max_e else 0.125 * mem0;
                i -= 1;
            }

            mean =
                cast,no_check(float32) c_transpiler_libm_sqrt(
                    (cast,no_check(float64) (mean * max_e)) * 0.5 * len2
                );

            norm := len2 / (1.0e-15 + mean);

            unmask = 0;

            !(c_transpiler_float_not_equal(tmp[0], tmp[0]));
            !(c_transpiler_float_not_equal(norm, norm));
            i = 12;
            while i < len2 - 5 {
                id :=
                    cast,no_check(s32) ((ifx c_transpiler_float_greater(0.0, (ifx c_transpiler_float_less(127.0, floor(cast,no_check(float64) (64.0 * norm * (tmp[i] + 1.0e-15)))) then 127.0 else floor(cast,no_check(float64) (64.0 * norm * (tmp[i] + 1.0e-15))))) then 0.0 else (ifx c_transpiler_float_less(127.0, floor(cast,no_check(float64) (64.0 * norm * (tmp[i] + 1.0e-15)))) then 127.0 else floor(cast,no_check(float64) (64.0 *
                        norm * (tmp[i] + 1.0e-15))))));

                unmask = cast,no_check(Int32) (unmask + cast,no_check(s32) INV_TABLE[id]);
                i += 4;
            }

            unmask = 64 * unmask * 4 / (6 * (len2 - 17));
            if unmask > mask_metric {
                tf_chan.* = c;
                mask_metric = unmask;
            }
        }
    }
    is_transient = cast(s32) (mask_metric > 200);

    if c_transpiler_float_greater(toneishness, 0.98) && c_transpiler_float_less(tone_freq, 0.026) {
        is_transient = 0;
        mask_metric = 0;
    }

    if allow_weak_transients != 0 && is_transient != 0 && mask_metric < 600 {
        is_transient = 0;
        weak_transient.* = 1;
    }

    tf_max :=
        (ifx c_transpiler_float_greater(0.0, ((cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (27 * mask_metric))) - 42.0)) then 0.0 else (cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (27 * mask_metric))) -
            42.0);

    tf_estimate.* =
        cast,no_check(float32) c_transpiler_libm_sqrt(
            (ifx c_transpiler_float_greater(0.0, ((cast,no_check(float64) ((cast(float32) 0.006899999920278788) * (ifx c_transpiler_float_less(163.0, tf_max) then 163.0 else tf_max))) - 0.139)) then 0.0 else (cast,no_check(float64) ((cast(float32) 0.006899999920278788) * (ifx c_transpiler_float_less(163.0, tf_max) then 163.0 else tf_max))) -
            0.139)
        );

    return is_transient;
}

tone_detect :: (in: *Celt_Sig, cc: s32, n: s32, toneishness: *Val32, fs: Int32) -> Val16 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    delay: s32 = 1;

    lpc: [2] Val32 = ---;
    freq: Val16 = ---;

    x := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) n)));

    if cc == 2 {
        if 0 < n {
            for i: 0..n - 1 {
                x[i] = in[i] + in[i + n];
            }
        }
    } else {
        if 0 < n {
            for i: 0..n - 1 {
                x[i] = in[i];
            }
        }
    }

    fail := tone_lpc(x, n, delay, lpc.data);

    while delay <= fs / 3000 && (fail != 0 || c_transpiler_float_greater(lpc[0], 1.0) && c_transpiler_float_less(lpc[1], 0.0)) {
        delay *= 2;
        fail = tone_lpc(x, n, delay, lpc.data);
    }

    if fail == 0 &&
        c_transpiler_float_less(((cast,no_check(float64) (lpc[0] * lpc[0])) + 3.999999 * cast,no_check(float64) lpc[1]), 0.0) {
        toneishness.* = -lpc[1];

        freq = cast,no_check(Val16) (acos(cast,no_check(float64) (0.5 * lpc[0])) / delay);
    } else {
        freq = -1.0;
        toneishness.* = 0.0;
    }

    return freq;
}

tone_lpc :: (x: *Val16, len: s32, delay: s32, lpc: *Val32) -> s32 {
    r00: Val32 = 0.0;
    r01: Val32 = 0.0;
    r11: Val32 = 0.0;
    r02: Val32 = 0.0;
    r12: Val32 = 0.0;
    r22: Val32 = 0.0;

    (len > 2 * delay);

    i: s32 = 0;
    while i < len - 2 * delay {
        r00 += x[i] * x[i];
        r01 += x[i] * x[i + delay];
        r02 += x[i] * x[i + 2 * delay];
        i += 1;
    }
    edges: Val32 = 0.0;
    i = 0;
    while i < delay {
        edges += x[len + i - 2 * delay] * x[len + i - 2 * delay] - x[i] * x[i];
        i += 1;
    }
    r11 = r00 + edges;
    edges = 0.0;
    i = 0;
    while i < delay {
        edges += x[len + i - delay] * x[len + i - delay] - x[i + delay] * x[i + delay];
        i += 1;
    }
    r22 = r11 + edges;
    edges = 0.0;
    i = 0;
    while i < delay {
        edges += x[len + i - 2 * delay] * x[len + i - delay] - x[i] * x[i + delay];
        i += 1;
    }
    r12 = r01 + edges;

    {
        r00_value: Val32 = ---;
        r00_value = r00 + r22;
        r01_value := r01 + r12;
        r11_value := 2.0 * r11;
        r02_value := 2.0 * r02;
        r12_value := r12 + r01;
        r22_value := r00 + r22;
        r00 = r00_value;
        r01 = r01_value;
        r11 = r11_value;
        r02 = r02_value;
        r12 = r12_value;
        r22 = r22_value;
    }

    den := r00 * r11 - r01 * r01;

    if c_transpiler_float_less(den, (0.001 * (r00 * r11))) {
        return 1;
    }

    num1 := r02 * r11 - r01 * r12;
    if c_transpiler_float_greater_equal(num1, den) {
        lpc[1] = 1.0;
    } else if c_transpiler_float_less_equal(num1, -den) {
        lpc[1] = -1.0;
    } else {
        lpc[1] = num1 / den;
    }
    num0 := r00 * r12 - r02 * r01;
    if c_transpiler_float_greater_equal((0.5 * num0), den) {
        lpc[0] = 1.999999;
    } else if c_transpiler_float_less_equal((0.5 * num0), -den) {
        lpc[0] = cast(float32) -1.9999990463256837;
    } else {
        lpc[0] = num0 / den;
    }

    return 0;
}

celt_preemphasis :: (
    pcmp: *Res,
    inp: *Celt_Sig,
    n: s32,
    cc: s32,
    upsample: s32,
    coef: *Val16,
    mem: *Celt_Sig,
    clip: s32
) {
    coef0 := coef[0];
    m := mem.*;

    if c_transpiler_float_equal(coef[1], 0.0) && upsample == 1 && clip == 0 {
        if 0 < n {
            for i: 0..n - 1 {
                x := 32768.0 * pcmp[cc * i];

                inp[i] = x - m;
                m = coef0 * x;
            }
        }
        mem.* = m;
        return;
    }

    nu := n / upsample;
    if upsample != 1 {
        fill_memory(inp, 0, cast,no_check(u64) n * size_of(Celt_Sig));
    }
    if 0 < nu {
        for i: 0..nu - 1 {
            inp[i * upsample] = 32768.0 * pcmp[cc * i];
        }
    }

    if clip != 0 {
        if 0 < nu {
            for i: 0..nu - 1 {
                inp[i * upsample] =
                    ifx c_transpiler_float_greater(-65536.0, (ifx c_transpiler_float_less(65536.0, inp[i * upsample]) then 65536.0 else inp[i * upsample])) then -65536.0 else (ifx c_transpiler_float_less(65536.0, inp[i * upsample]) then 65536.0 else inp[i *
                        upsample]);
            }
        }
    }

    if 0 < n {
        for i: 0..n - 1 {
            x := inp[i];

            inp[i] = x - m;
            m = coef0 * x;
        }
    }
    mem.* = m;
}

celt_maxabs16_in_celt_encoder :: (x: *Val16, len: s32) -> Val32 {
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

celt_encoder_init :: (st: *Custom_Encoder_in_celt_encoder, sampling_rate: Int32, channels: s32, arch: s32) -> s32 {
    ret := custom_encoder_init_arch(st, custom_mode_create(48000, 960, null), channels, arch);
    if ret != 0 {
        return ret;
    }
    st.upsample = resampling_factor(sampling_rate);
    return 0;
}

custom_encoder_init_arch :: (st: *Custom_Encoder_in_celt_encoder, mode: *Custom_Mode, channels: s32, arch: s32) -> s32 {
    if channels < 0 || channels > 2 {
        return -1;
    }

    if st == null || mode == null {
        return -7;
    }

    fill_memory(cast(*s8) st, 0, cast,no_check(u64) custom_encoder_get_size(mode, channels));

    st.mode = mode;
    st.channels = channels;
    st.stream_channels = st.channels;

    st.upsample = 1;
    st.start = 0;
    st.end = st.mode.eff_e_bands;
    st.signalling = 1;
    st.arch = arch;

    st.constrained_vbr = 1;
    st.clip = 1;

    st.bitrate = -1;
    st.vbr = 0;
    st.force_intra = 0;
    st.complexity = 5;
    st.lsb_depth = 24;

    custom_encoder_ctl(st, 4028);

    return 0;
}

xcorr_kernel_c_in_celt_encoder :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_celt_encoder :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

false__in_celt_encoder :: () -> s32 {
    return 0;
}

get_pulses_in_celt_encoder :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_celt_encoder :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_celt_encoder :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

fast_atan2f_in_celt_encoder :: (y: float32, x: float32) -> float32 {
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

celt_atan_norm_in_celt_encoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_celt_encoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_celt_encoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_celt_encoder(x / y);
    }
}

celt_cos_norm2_in_celt_encoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

mm_cvtss_si32_in_celt_encoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_celt_encoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_celt_encoder(a);
}

mm_set_ss_in_celt_encoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_celt_encoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_celt_encoder(mm_set_ss_in_celt_encoder(x));
}

float2_int16_in_celt_encoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_celt_encoder(x);
}

float2_int24_in_celt_encoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_celt_encoder(x);
}

globals_initialization_state_for_celt_encoder: u32;
initialize_globals_for_celt_encoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_celt_encoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_celt_encoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_celt_encoder) != 2 {}
            return;
        }
    }
    INV_TABLE =
        u8.[
            255,
            255,
            156,
            110,
            86,
            70,
            59,
            51,
            45,
            40,
            37,
            33,
            31,
            28,
            26,
            25,
            23,
            22,
            21,
            20,
            19,
            18,
            17,
            16,
            16,
            15,
            15,
            14,
            13,
            13,
            12,
            12,
            12,
            12,
            11,
            11,
            11,
            10,
            10,
            10,
            9,
            9,
            9,
            9,
            9,
            9,
            8,
            8,
            8,
            8,
            8,
            7,
            7,
            7,
            7,
            7,
            7,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            6,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            5,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            4,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            2
        ];
    INTENSITY_THRESHOLDS =
        Val16.[
            1.0,
            2.0,
            3.0,
            4.0,
            5.0,
            6.0,
            7.0,
            8.0,
            16.0,
            24.0,
            36.0,
            44.0,
            50.0,
            56.0,
            62.0,
            67.0,
            72.0,
            79.0,
            88.0,
            106.0,
            134.0
        ];
    INTENSITY_HISTERESIS =
        Val16.[
            1.0,
            1.0,
            1.0,
            1.0,
            1.0,
            1.0,
            1.0,
            2.0,
            2.0,
            2.0,
            2.0,
            2.0,
            2.0,
            2.0,
            3.0,
            3.0,
            4.0,
            5.0,
            6.0,
            8.0,
            8.0
        ];
    TRIM_ICDF_in_celt_encoder =
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
    SPREAD_ICDF_in_celt_encoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_celt_encoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_celt_encoder, 2);
}

acos :: (x: float64) -> float64 #foreign System_Library_libm_so_6;

Va_List :: [1] Va_List_Tag;

Analysis_Info :: struct {
    valid: s32;
    tonality: float32;
    tonality_slope: float32;
    noisiness: float32;
    activity: float32;
    music_prob: float32;
    music_prob_min: float32;
    music_prob_max: float32;
    bandwidth: s32;
    activity_probability: float32;
    max_pitch_ratio: float32;
    leak_boost: [19] u8;
}

SILK_Info :: struct {
    signal_type: s32;
    offset: s32;
}

Va_List_Tag :: struct {
    gp_offset: u32;
    fp_offset: u32;
    overflow_arg_area: *void;
    reg_save_area: *void;
}

