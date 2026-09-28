// Generated directly from C by cpp_transpiler.
Encoder_in_opus_encoder :: struct {
    celt_enc_offset: s32;
    silk_enc_offset: s32;
    silk_mode: Silk_Enc_Control_Struct;
    application: s32;
    channels: s32;
    delay_compensation: s32;
    force_channels: s32;
    signal_type: s32;
    user_bandwidth: s32;
    max_bandwidth: s32;
    user_forced_mode: s32;
    voice_ratio: s32;
    fs: Int32;
    use_vbr: s32;
    vbr_constraint: s32;
    variable_duration: s32;
    bitrate_bps: Int32;
    user_bitrate_bps: Int32;
    lsb_depth: s32;
    encoder_buffer: s32;
    lfe: s32;
    arch: s32;
    use_dtx: s32;
    fec_config: s32;
    analysis: Tonality_Analysis_State;
    stream_channels: s32;
    hybrid_stereo_width_q14: Int16;
    variable_hp_smth2_q15: Int32;
    prev_hb_gain: Val16;
    hp_mem: [4] Val32;
    mode: s32;
    prev_mode: s32;
    prev_channels: s32;
    prev_framesize: s32;
    bandwidth: s32;
    auto_bandwidth: s32;
    silk_bw_switch: s32;
    first: s32;
    energy_masking: *Celt_Glog;
    width_mem: Stereo_Width_State;
    detected_bandwidth: s32;
    nb_no_activity_ms_q1: s32;
    peak_signal_energy: Val32;
    nonfinal_frame: s32;
    range_final: Uint32;
    delay_buffer: [960] Res;
}

Stereo_Width_State :: struct {
    xx_: Val32;
    xy: Val32;
    yy: Val32;
    smoothed_width: Val16;
    max_follower: Val16;
}

TRIM_ICDF_in_opus_encoder: [11] u8;

SPREAD_ICDF_in_opus_encoder: [4] u8;

TAPSET_ICDF_in_opus_encoder: [3] u8;

RATE_TABLE: [7] [5] s32;

FEC_THRESHOLDS: [10] Int32;

MONO_MUSIC_BANDWIDTH_THRESHOLDS: [8] Int32;

MONO_VOICE_BANDWIDTH_THRESHOLDS: [8] Int32;

STEREO_MUSIC_BANDWIDTH_THRESHOLDS: [8] Int32;

STEREO_VOICE_BANDWIDTH_THRESHOLDS: [8] Int32;

STEREO_MUSIC_THRESHOLD: Int32;

STEREO_VOICE_THRESHOLD: Int32;

MODE_THRESHOLDS: [2] [2] Int32;

ec_range_bytes_in_opus_encoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_encoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_encoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_encoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_opus_encoder :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_encoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_encoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

false__in_opus_encoder :: () -> s32 {
    return 0;
}

mm_cvtss_si32_in_opus_encoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_opus_encoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_opus_encoder(a);
}

mm_set_ss_in_opus_encoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_opus_encoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_opus_encoder(mm_set_ss_in_opus_encoder(x));
}

float2_int16_in_opus_encoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_opus_encoder(x);
}

float2_int24_in_opus_encoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_opus_encoder(x);
}

encoder_get_size :: (channels: s32) -> s32 {
    ret := encoder_init(null, 48000, channels, 2049);
    if ret < 0 {
        return 0;
    } else {
        return ret;
    }
}

encoder_init :: (st: *Encoder_in_opus_encoder, fs: Int32, channels: s32, application: s32) -> s32 {
    silk_enc: *void = null;
    celt_enc: *Custom_Encoder = null;
    err: s32 = ---;
    silk_enc_size_bytes: s32 = ---;
    celt_enc_size_bytes: s32 = 0;

    if fs != 48000 && fs != 24000 && fs != 16000 && fs != 12000 && fs != 8000 ||
        channels != 1 && channels != 2 ||
        application != 2048 && application != 2049 && application != 2051 && application != 2052 && application != 2053 {
        return -1;
    }

    ret := silk_get_encoder_size(*silk_enc_size_bytes, channels);
    if ret != 0 {
        return -1;
    }
    silk_enc_size_bytes = align_in_opus_encoder(silk_enc_size_bytes);
    if application == 2053 {
        silk_enc_size_bytes = 0;
    }
    if application != 2052 {
        celt_enc_size_bytes = celt_encoder_get_size(channels);
    }
    base_size := align_in_opus_encoder(cast,no_check(s32) (cast(u64) size_of(Encoder_in_opus_encoder)));
    if application == 2052 || application == 2053 {
        base_size =
            align_in_opus_encoder(
                cast,no_check(s32) ((cast,no_check(u64) base_size) - (cast,no_check(u64) ((480 * 2))) * size_of(Res))
            );
    } else if channels == 1 {
        base_size =
            align_in_opus_encoder(
                cast,no_check(s32) ((cast,no_check(u64) base_size) - (cast,no_check(u64) (480)) * size_of(Res))
            );
    }
    tot_size := base_size + silk_enc_size_bytes + celt_enc_size_bytes;
    if st == null {
        return tot_size;
    }
    fill_memory(cast(*s8) st, 0, cast,no_check(u64) tot_size);
    st.silk_enc_offset = base_size;
    st.celt_enc_offset = st.silk_enc_offset + silk_enc_size_bytes;

    st.channels = channels;
    st.stream_channels = st.channels;

    st.fs = fs;

    st.arch = select_arch_in_opus_encoder();

    if application != 2053 {
        silk_enc = cast(*void) ((cast(*s8) st) + st.silk_enc_offset);
        ret = silk_init_encoder(silk_enc, st.channels, st.arch, *st.silk_mode);
    }
    if ret != 0 {
        return -3;
    }

    st.silk_mode.n_channels_api = channels;
    st.silk_mode.n_channels_internal = channels;
    st.silk_mode.api_sample_rate = st.fs;
    st.silk_mode.max_internal_sample_rate = 16000;
    st.silk_mode.min_internal_sample_rate = 8000;
    st.silk_mode.desired_internal_sample_rate = 16000;
    st.silk_mode.payload_size_ms = 20;
    st.silk_mode.bit_rate = 25000;
    st.silk_mode.packet_loss_percentage = 0;
    st.silk_mode.complexity = 9;
    st.silk_mode.use_in_band_fec = 0;
    st.silk_mode.use_dred = 0;
    st.silk_mode.use_dtx = 0;
    st.silk_mode.use_cbr = 0;
    st.silk_mode.reduced_dependency = 0;

    if application != 2052 {
        celt_enc = cast(*Custom_Encoder) ((cast(*s8) st) + st.celt_enc_offset);
        err = celt_encoder_init(celt_enc, fs, channels, st.arch);
        if err != 0 {
            return -3;
        }
        custom_encoder_ctl(celt_enc, 10016, cast(s32) 0);
        custom_encoder_ctl(
            celt_enc,
            4010,
            (ifx true { ((st.silk_mode.complexity == cast(s32) 0)); (st.silk_mode.complexity); })
        );
    }

    st.use_vbr = 1;

    st.vbr_constraint = 1;
    st.user_bitrate_bps = -1000;
    st.bitrate_bps = 3000 + fs * channels;
    st.application = application;
    st.signal_type = -1000;
    st.user_bandwidth = -1000;
    st.max_bandwidth = 1105;
    st.force_channels = -1000;
    st.user_forced_mode = -1000;
    st.voice_ratio = -1;
    if application != 2053 && application != 2052 {
        st.encoder_buffer = st.fs / 100;
    } else {
        st.encoder_buffer = 0;
    }
    st.lsb_depth = 24;
    st.variable_duration = 5000;

    st.delay_compensation = st.fs / 250;

    st.hybrid_stereo_width_q14 = cast,no_check(Int16) ((cast(s32) 1) << 14);
    st.prev_hb_gain = 1.0;
    st.variable_hp_smth2_q15 = cast,no_check(Int32) ((cast,no_check(Uint32) silk_lin2log(60)) << 8);
    st.first = 1;
    st.mode = 1001;
    st.bandwidth = 1105;

    (cast,no_check(#type (_: *Tonality_Analysis_State, _: Int32)) (cast(*void) tonality_analysis_init))(
        *st.analysis,
        st.fs
    );
    st.analysis.application = st.application;

    return 0;
}

align_in_opus_encoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

encoder_create :: (fs: Int32, channels: s32, application: s32, error: *s32) -> *Encoder_in_opus_encoder {
    if fs != 48000 && fs != 24000 && fs != 16000 && fs != 12000 && fs != 8000 ||
        channels != 1 && channels != 2 ||
        application != 2048 && application != 2049 && application != 2051 && application != 2052 && application != 2053 {
        if error != null {
            error.* = -1;
        }
        return null;
    }
    size := encoder_init(null, fs, channels, application);
    if size <= 0 {
        if error != null {
            error.* = -3;
        }
        return null;
    }
    st := cast(*Encoder_in_opus_encoder) alloc__in_opus_encoder(cast,no_check(u64) size);
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret := encoder_init(st, fs, channels, application);
    if error != null {
        error.* = ret;
    }
    if ret != 0 {
        free__in_opus_encoder(cast(*void) st);
        st = null;
    }
    return st;
}

free__in_opus_encoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

alloc__in_opus_encoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

encode :: (
    st: *Encoder_in_opus_encoder,
    pcm: *Int16,
    analysis_frame_size: s32,
    data: *u8,
    max_data_bytes: Int32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    frame_size := frame_size_select(st.application, analysis_frame_size, st.variable_duration, st.fs);
    if frame_size <= 0 {
        return -1;
    }
    in := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (frame_size * st.channels))));

    i: s32 = 0;
    while i < frame_size * st.channels {
        in[i] = (cast,no_check(float32) pcm[i]) * cast(float32) 0.000030517578125;
        i += 1;
    }
    ret :=
        encode_native(
            st,
            in,
            frame_size,
            data,
            max_data_bytes,
            16,
            cast(*void) pcm,
            analysis_frame_size,
            0,
            -2,
            st.channels,
            cast,no_check(Downmix_Func) downmix_int,
            1
        );

    return ret;
}

downmix_int :: (x_value: *void, y: *Val32, subframe: s32, offset: s32, c1: s32, c2: s32, c_value: s32) {
    x := cast(*Int16) x_value;
    j: s32 = 0;
    while j < subframe {
        y[j] = cast,no_check(float32) x[(j + offset) * c_value + c1];
        j += 1;
    }
    if c2 > -1 {
        j = 0;
        while j < subframe {
            y[j] += cast,no_check(float32) x[(j + offset) * c_value + c2];
            j += 1;
        }
    } else if c2 == -2 {
        if 1 < c_value {
            for c: 1..c_value - 1 {
                j = 0;
                while j < subframe {
                    y[j] += cast,no_check(float32) x[(j + offset) * c_value + c];
                    j += 1;
                }
            }
        }
    }
}

encode_native :: (
    st: *Encoder_in_opus_encoder,
    pcm: *Res,
    frame_size: s32,
    data: *u8,
    out_data_bytes: Int32,
    lsb_depth: s32,
    analysis_pcm: *void,
    analysis_size: Int32,
    c1: s32,
    c2: s32,
    analysis_channels: s32,
    downmix: Downmix_Func,
    float_api: s32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    silk_enc: *void = null;
    celt_enc: *Custom_Encoder = null;

    ret: s32 = 0;
    prefill: s32 = 0;
    redundancy: s32 = 0;
    celt_to_silk: s32 = 0;
    to_celt: s32 = 0;
    voice_est: s32 = ---;

    cbr_bytes: Int32 = -1;

    celt_mode: *Custom_Mode = null;
    packet_size_cap: s32 = 1276;

    analysis_info: Analysis_Info = ---;
    analysis_read_pos_bak: s32 = -1;
    analysis_read_subframe_bak: s32 = -1;

    is_silence: s32 = 0;

    max_data_bytes := (ifx packet_size_cap * 6 < out_data_bytes then packet_size_cap * 6 else out_data_bytes);

    st.range_final = 0;
    if frame_size <= 0 || max_data_bytes <= 0 {
        return -1;
    }

    if max_data_bytes == 1 && st.fs == frame_size * 10 {
        return -2;
    }

    if st.application != 2053 {
        silk_enc = cast(*void) ((cast(*s8) st) + st.silk_enc_offset);
    }
    if st.application != 2052 {
        celt_enc = cast(*Custom_Encoder) ((cast(*s8) st) + st.celt_enc_offset);
    }

    lsb_depth = ifx lsb_depth < st.lsb_depth then lsb_depth else st.lsb_depth;

    if st.application != 2052 {
        custom_encoder_ctl(celt_enc, 10015, *celt_mode + (*celt_mode - *celt_mode));
    }
    is_silence = is_digital_silence(pcm, frame_size, st.channels, lsb_depth);

    analysis_info.valid = 0;

    if st.silk_mode.complexity >= 7 && st.fs >= 16000 && st.fs <= 48000 && st.application != 2052 {
        analysis_read_pos_bak = st.analysis.read_pos;
        analysis_read_subframe_bak = st.analysis.read_subframe;
        (cast,no_check(#type (_: *Tonality_Analysis_State, _: *Custom_Mode, _: *void, _: s32, _: s32, _: s32, _: s32, _: s32, _: Int32, _: s32, _: Downmix_Func, _: *Analysis_Info)) (cast(*void) run_analysis))(
            *st.analysis,
            celt_mode,
            analysis_pcm,
            analysis_size,
            frame_size,
            c1,
            c2,
            analysis_channels,
            st.fs,
            lsb_depth,
            downmix,
            *analysis_info
        );
    } else if st.analysis.initialized != 0 {
        (cast,no_check(#type (_: *Tonality_Analysis_State)) (cast(*void) tonality_analysis_reset))(*st.analysis);
    }

    if is_silence == 0 {
        st.voice_ratio = -1;
    }

    st.detected_bandwidth = 0;
    if analysis_info.valid != 0 {
        if st.signal_type == -1000 {
            prob: float32 = ifx st.prev_mode == 0
                then analysis_info.music_prob
                else ifx st.prev_mode == 1002
                    then analysis_info.music_prob_max
                    else analysis_info.music_prob_min;
            st.voice_ratio = cast,no_check(s32) floor(0.5 + cast,no_check(float64) (100.0 * (1.0 - prob)));
        }

        analysis_bandwidth := analysis_info.bandwidth;
        if analysis_bandwidth <= 12 {
            st.detected_bandwidth = 1101;
        } else if analysis_bandwidth <= 14 {
            st.detected_bandwidth = 1102;
        } else if analysis_bandwidth <= 16 {
            st.detected_bandwidth = 1103;
        } else if analysis_bandwidth <= 18 {
            st.detected_bandwidth = 1104;
        } else {
            st.detected_bandwidth = 1105;
        }
    }

    if analysis_info.valid == 0 || c_transpiler_float_greater(analysis_info.activity_probability, 0.1) {
        if is_silence == 0 {
            st.peak_signal_energy =
                ifx c_transpiler_float_greater((0.999 * st.peak_signal_energy), compute_frame_energy(pcm, frame_size, st.channels, st.arch)) then 0.999 *
                    st.peak_signal_energy else compute_frame_energy(pcm, frame_size, st.channels, st.arch);
        }
    }
    stereo_width: Val16 = ifx st.channels == 2 && st.force_channels != 1
        then compute_stereo_width(pcm, frame_size, st.fs, *st.width_mem)
        else 0.0;
    st.bitrate_bps = user_bitrate_to_bitrate(st, frame_size, max_data_bytes);

    frame_rate := st.fs / frame_size;
    if st.use_vbr == 0 {
        cbr_bytes =
            ifx (bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, frame_size) + 4) /
                8 < max_data_bytes then (bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, frame_size) + 4) / 8 else max_data_bytes;
        st.bitrate_bps = bits_to_bitrate_in_opus_encoder(cbr_bytes * 8, st.fs, frame_size);

        max_data_bytes = ifx 1 > cbr_bytes then 1 else cbr_bytes;
    }

    if max_data_bytes < 3 ||
        st.bitrate_bps < 3 * frame_rate * 8 ||
        frame_rate < 50 && (max_data_bytes * frame_rate < 300 || st.bitrate_bps < 2400) {
        tocmode := st.mode;
        bw := (ifx st.bandwidth == 0 then 1101 else st.bandwidth);
        packet_code: s32 = 0;
        num_multiframes: s32 = 0;

        if tocmode == 0 {
            tocmode = 1000;
        }
        if frame_rate > 100 {
            tocmode = 1002;
        }

        if frame_rate == 25 && tocmode != 1000 {
            frame_rate = 50;
            packet_code = 1;
        }

        if frame_rate <= 16 {
            if out_data_bytes == 1 || tocmode == 1000 && frame_rate != 10 {
                tocmode = 1000;

                packet_code = cast(s32) (frame_rate <= 12);
                frame_rate = ifx frame_rate == 12 then cast(s32) 25 else 16;
            } else {
                num_multiframes = 50 / frame_rate;
                frame_rate = 50;
                packet_code = 3;
            }
        }

        if tocmode == 1000 && bw > 1103 {
            bw = 1103;
        } else if tocmode == 1002 && bw == 1102 {
            bw = 1101;
        } else if tocmode == 1001 && bw <= 1104 {
            bw = 1104;
        }

        data[0] = gen_toc(tocmode, frame_rate, bw, st.stream_channels);
        data[0] = cast,no_check(u8) ((cast,no_check(s32) data[0]) | packet_code);

        ret = ifx packet_code <= 1 then cast(s32) 1 else 2;

        max_data_bytes = max(max_data_bytes, ret);

        if packet_code == 3 {
            data[1] = cast,no_check(u8) num_multiframes;
        }

        if st.use_vbr == 0 {
            ret = packet_pad(data, ret, max_data_bytes);
            if ret == 0 {
                ret = max_data_bytes;
            } else {
                ret = -3;
            }
        }

        return ret;
    }
    max_rate := bits_to_bitrate_in_opus_encoder(max_data_bytes * 8, st.fs, frame_size);

    equiv_rate :=
        compute_equiv_rate(
            st.bitrate_bps,
            st.channels,
            st.fs / frame_size,
            st.use_vbr,
            0,
            st.silk_mode.complexity,
            st.silk_mode.packet_loss_percentage
        );

    if st.signal_type == 3001 {
        voice_est = 127;
    } else if st.signal_type == 3002 {
        voice_est = 0;
    } else if st.voice_ratio >= 0 {
        voice_est = (st.voice_ratio * 327) >> 8;

        if st.application == 2049 {
            voice_est = ifx voice_est < 115 then voice_est else 115;
        }
    } else if st.application == 2048 {
        voice_est = 115;
    } else {
        voice_est = 48;
    }

    if st.force_channels != -1000 && st.channels == 2 {
        st.stream_channels = st.force_channels;
    } else if st.channels == 2 {
        stereo_threshold :=
            STEREO_MUSIC_THRESHOLD +
                (voice_est * voice_est * (STEREO_VOICE_THRESHOLD - STEREO_MUSIC_THRESHOLD)) >> 14;
        if st.stream_channels == 2 {
            stereo_threshold = cast,no_check(Int32) (stereo_threshold - 1000);
        } else {
            stereo_threshold = cast,no_check(Int32) (stereo_threshold + 1000);
        }
        st.stream_channels = ifx equiv_rate > stereo_threshold then cast(s32) 2 else 1;
    } else {
        st.stream_channels = st.channels;
    }

    equiv_rate =
        compute_equiv_rate(
            st.bitrate_bps,
            st.stream_channels,
            st.fs / frame_size,
            st.use_vbr,
            0,
            st.silk_mode.complexity,
            st.silk_mode.packet_loss_percentage
        );

    st.silk_mode.use_dtx = cast(s32) (st.use_dtx != 0 && !(analysis_info.valid != 0 || is_silence != 0));

    if st.application == 2052 {
        st.mode = 1000;
    } else if st.application == 2051 || st.application == 2053 {
        st.mode = 1002;
    } else if st.user_forced_mode == -1000 {
        mode_voice := cast,no_check(Int32) ((1.0 - stereo_width) * 64000.0 + stereo_width * 44000.0);
        mode_music := cast,no_check(Int32) ((1.0 - stereo_width) * 10000.0 + stereo_width * 10000.0);

        threshold := mode_music + (voice_est * voice_est * (mode_voice - mode_music)) >> 14;

        if st.application == 2048 {
            threshold = cast,no_check(Int32) (threshold + 8000);
        }

        if st.prev_mode == 1002 {
            threshold = cast,no_check(Int32) (threshold - 4000);
        } else if st.prev_mode > 0 {
            threshold = cast,no_check(Int32) (threshold + 4000);
        }

        st.mode = ifx equiv_rate >= threshold then cast(s32) 1002 else 1000;

        if st.silk_mode.use_in_band_fec != 0 &&
            st.silk_mode.packet_loss_percentage > (128 - voice_est) >> 4 &&
            (st.fec_config != 2 || voice_est > 25) {
            st.mode = 1000;
        }

        if st.silk_mode.use_dtx != 0 && voice_est > 100 {
            st.mode = 1000;
        }

        if max_data_bytes < bitrate_to_bits_in_opus_encoder((ifx frame_rate > 50 then cast(Int32) 9000 else 6000), st.fs, frame_size) / 8 {
            st.mode = 1002;
        }
    } else {
        st.mode = st.user_forced_mode;
    }

    if st.mode != 1002 && frame_size < st.fs / 100 {
        (st.application != 2052);
        st.mode = 1002;
    }
    if st.lfe != 0 && st.application != 2052 {
        st.mode = 1002;
    }

    if st.prev_mode > 0 && (st.mode != 1002 && st.prev_mode == 1002 || st.mode == 1002 && st.prev_mode != 1002) {
        redundancy = 1;
        celt_to_silk = cast(s32) (st.mode != 1002);
        if celt_to_silk == 0 {
            if frame_size >= st.fs / 100 {
                st.mode = st.prev_mode;
                to_celt = 1;
            } else {
                redundancy = 0;
            }
        }
    }

    if st.stream_channels == 1 && st.prev_channels == 2 && st.silk_mode.to_mono == 0 && st.mode != 1002 && st.prev_mode != 1002 {
        st.silk_mode.to_mono = 1;
        st.stream_channels = 2;
    } else {
        st.silk_mode.to_mono = 0;
    }

    equiv_rate =
        compute_equiv_rate(
            st.bitrate_bps,
            st.stream_channels,
            st.fs / frame_size,
            st.use_vbr,
            st.mode,
            st.silk_mode.complexity,
            st.silk_mode.packet_loss_percentage
        );

    if st.mode != 1002 && st.prev_mode == 1002 {
        dummy: Silk_Enc_Control_Struct = ---;
        silk_init_encoder(silk_enc, st.channels, st.arch, *dummy);
        prefill = 1;
    }

    if st.mode == 1002 || st.first != 0 || st.silk_mode.allow_bandwidth_switch != 0 {
        voice_bandwidth_thresholds, music_bandwidth_thresholds: *Int32 = ---;
        bandwidth_thresholds: [8] Int32 = ---;
        bandwidth: s32 = 1105;

        if st.channels == 2 && st.force_channels != 1 {
            voice_bandwidth_thresholds = STEREO_VOICE_BANDWIDTH_THRESHOLDS.data;
            music_bandwidth_thresholds = STEREO_MUSIC_BANDWIDTH_THRESHOLDS.data;
        } else {
            voice_bandwidth_thresholds = MONO_VOICE_BANDWIDTH_THRESHOLDS.data;
            music_bandwidth_thresholds = MONO_MUSIC_BANDWIDTH_THRESHOLDS.data;
        }

        for i: 0..cast(s32) 8 - 1 {
            bandwidth_thresholds[i] =
                music_bandwidth_thresholds[i] +
                    (voice_est * voice_est * (voice_bandwidth_thresholds[i] - music_bandwidth_thresholds[i])) >> 14;
        }
        while true {
            {
                threshold: s32 = ---;
                threshold = bandwidth_thresholds[2 * (bandwidth - 1102)];
                hysteresis := bandwidth_thresholds[2 * (bandwidth - 1102) + 1];
                if st.first == 0 {
                    if st.auto_bandwidth >= bandwidth {
                        threshold -= hysteresis;
                    } else {
                        threshold += hysteresis;
                    }
                }
                if equiv_rate >= threshold {
                    break;
                }
            }
            if !(c_transpiler_pre_decrement(*(bandwidth)) > 1101) break;
        }

        if bandwidth == 1102 {
            bandwidth = 1103;
        }
        st.auto_bandwidth = bandwidth;
        st.bandwidth = st.auto_bandwidth;

        if st.first == 0 && st.mode != 1002 && st.silk_mode.in_w_bmode_without_variable_lp == 0 && st.bandwidth > 1103 {
            st.bandwidth = 1103;
        }
    }

    if st.bandwidth > st.max_bandwidth {
        st.bandwidth = st.max_bandwidth;
    }

    if st.user_bandwidth != -1000 {
        st.bandwidth = st.user_bandwidth;
    }

    if st.mode != 1002 && max_rate < 15000 {
        st.bandwidth = ifx st.bandwidth < 1103 then st.bandwidth else 1103;
    }

    if st.fs <= 24000 && st.bandwidth > 1104 {
        st.bandwidth = 1104;
    }
    if st.fs <= 16000 && st.bandwidth > 1103 {
        st.bandwidth = 1103;
    }
    if st.fs <= 12000 && st.bandwidth > 1102 {
        st.bandwidth = 1102;
    }
    if st.fs <= 8000 && st.bandwidth > 1101 {
        st.bandwidth = 1101;
    }

    if st.detected_bandwidth != 0 && st.user_bandwidth == -1000 {
        min_detected_bandwidth: s32 = ifx equiv_rate <= 18000 * st.stream_channels && st.mode == 1002
            then cast(s32) 1101
            else ifx equiv_rate <= 24000 * st.stream_channels && st.mode == 1002
                then cast(s32) 1102
                else ifx equiv_rate <= 30000 * st.stream_channels
                    then cast(s32) 1103
                    else ifx equiv_rate <= 44000 * st.stream_channels
                        then cast(s32) 1104
                        else 1105;

        st.detected_bandwidth =
            ifx st.detected_bandwidth > min_detected_bandwidth then st.detected_bandwidth else min_detected_bandwidth;
        st.bandwidth = ifx st.bandwidth < st.detected_bandwidth then st.bandwidth else st.detected_bandwidth;
    }

    st.silk_mode.lbrr_coded =
        decide_fec(
            st.silk_mode.use_in_band_fec,
            st.silk_mode.packet_loss_percentage,
            st.silk_mode.lbrr_coded,
            st.mode,
            *st.bandwidth,
            equiv_rate
        );
    if st.application != 2052 {
        custom_encoder_ctl(celt_enc, 4036, lsb_depth);
    }

    if st.mode == 1002 && st.bandwidth == 1102 {
        st.bandwidth = 1103;
    }
    if st.lfe != 0 {
        st.bandwidth = 1101;
    }

    curr_bandwidth := st.bandwidth;

    if st.application == 2052 && curr_bandwidth > 1103 {
        curr_bandwidth = 1103;
        st.bandwidth = curr_bandwidth;
    }

    if st.mode == 1000 && curr_bandwidth > 1103 {
        st.mode = 1001;
    }
    if st.mode == 1001 && curr_bandwidth <= 1103 {
        st.mode = 1000;
    }

    if frame_size > st.fs / 50 && st.mode != 1000 || frame_size > 3 * st.fs / 50 {
        repacketize_len: Int32 = ---;

        tot_size: Int32 = 0;

        dtx_count: s32 = 0;

        enc_frame_size: s32 = ifx st.mode == 1000
            then ifx frame_size == 2 * st.fs / 25
                then st.fs / 25
                else ifx frame_size == 3 * st.fs / 25
                    then 3 * st.fs / 50
                    else st.fs / 50
            else st.fs / 50;

        nb_frames := frame_size / enc_frame_size;

        if analysis_read_pos_bak != -1 {
            st.analysis.read_pos = analysis_read_pos_bak;
            st.analysis.read_subframe = analysis_read_subframe_bak;
        }

        max_header_bytes := (ifx nb_frames == 2 then 3 else 2 + (nb_frames - 1) * 2);

        if st.use_vbr != 0 || st.user_bitrate_bps == -1 {
            repacketize_len = out_data_bytes;
        } else {
            repacketize_len = min(cbr_bytes, out_data_bytes);
        }
        max_len_sum := nb_frames + repacketize_len - max_header_bytes;

        tmp_data := cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) * cast,no_check(u64) max_len_sum)));
        curr_data := tmp_data;
        rp := cast(*Repacketizer) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Repacketizer))) * 1)));
        repacketizer_init(rp);

        bak_to_mono := st.silk_mode.to_mono;
        if bak_to_mono != 0 {
            st.force_channels = 1;
        } else {
            st.prev_channels = st.stream_channels;
        }

        if 0 < nb_frames {
            for i: 0..nb_frames - 1 {
                first_frame := cast(s32) (i == 0 || i == dtx_count);
                st.silk_mode.to_mono = 0;
                st.nonfinal_frame = cast(s32) (i < nb_frames - 1);

                frame_to_celt := cast(s32) (to_celt != 0 && i == nb_frames - 1);
                frame_redundancy := cast(s32) (redundancy != 0 && (frame_to_celt != 0 || to_celt == 0 && i == 0));

                curr_max :=
                    (ifx bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, enc_frame_size) / 8 < max_len_sum /
                        nb_frames then bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, enc_frame_size) / 8 else max_len_sum / nb_frames);

                curr_max = ifx max_len_sum - tot_size < curr_max then max_len_sum - tot_size else curr_max;

                if analysis_read_pos_bak != -1 {
                    (cast,no_check(#type (_: *Tonality_Analysis_State, _: *Analysis_Info, _: s32)) (cast(*void) tonality_get_info))(
                        *st.analysis,
                        *analysis_info,
                        enc_frame_size
                    );
                }

                is_silence =
                    is_digital_silence(
                        pcm + i * (st.channels * enc_frame_size),
                        enc_frame_size,
                        st.channels,
                        lsb_depth
                    );

                tmp_len :=
                    encode_frame_native(
                        st,
                        pcm + i * (st.channels * enc_frame_size),
                        enc_frame_size,
                        curr_data,
                        curr_max,
                        float_api,
                        first_frame,
                        *analysis_info,
                        is_silence,
                        frame_redundancy,
                        celt_to_silk,
                        prefill,
                        equiv_rate,
                        frame_to_celt
                    );
                if tmp_len < 0 {
                    return -3;
                } else if tmp_len == 1 {
                    dtx_count += 1;
                }
                ret = repacketizer_cat(rp, curr_data, tmp_len);

                if ret < 0 {
                    return -3;
                }
                tot_size = cast,no_check(Int32) (tot_size + tmp_len);
                curr_data += tmp_len;
            }
        }
        ret =
            (cast,no_check(#type (_: *Repacketizer, _: s32, _: s32, _: *u8, _: Int32, _: s32, _: s32, _: *Extension_Data, _: s32) -> Int32) (cast(*void) repacketizer_out_range_impl))(
                rp,
                0,
                nb_frames,
                data,
                repacketize_len,
                0,
                cast(s32) (st.use_vbr == 0 && dtx_count != nb_frames),
                null,
                0
            );
        if ret < 0 {
            ret = -3;
        }
        st.silk_mode.to_mono = bak_to_mono;

        return ret;
    } else {
        ret =
            encode_frame_native(
                st,
                pcm,
                frame_size,
                data,
                max_data_bytes,
                float_api,
                1,
                *analysis_info,
                is_silence,
                redundancy,
                celt_to_silk,
                prefill,
                equiv_rate,
                to_celt
            );

        return ret;
    }
}

encode_frame_native :: (
    st: *Encoder_in_opus_encoder,
    pcm: *Res,
    frame_size: s32,
    data: *u8,
    orig_max_data_bytes: Int32,
    float_api: s32,
    first_frame: s32,
    analysis_info: *Analysis_Info,
    is_silence: s32,
    redundancy: s32,
    celt_to_silk: s32,
    prefill: s32,
    equiv_rate: Int32,
    to_celt: s32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    silk_enc: *void = null;
    celt_enc: *Custom_Encoder = null;
    celt_mode: *Custom_Mode = null;
    i: s32 = ---;
    ret: s32 = 0;

    n_bytes: Int32 = ---;
    enc: Ec_Enc = ---;

    start_band: s32 = 0;
    redundancy_bytes: s32 = 0;
    nb_compr_bytes: s32 = ---;
    redundant_rng: Uint32 = 0;

    activity: s32 = -1;

    max_data_bytes := (ifx orig_max_data_bytes < 1276 then orig_max_data_bytes else 1276);
    st.range_final = 0;
    if st.application != 2053 {
        silk_enc = cast(*void) ((cast(*s8) st) + st.silk_enc_offset);
    }
    if st.application != 2052 {
        celt_enc = cast(*Custom_Encoder) ((cast(*s8) st) + st.celt_enc_offset);
        custom_encoder_ctl(celt_enc, 10015, *celt_mode + (*celt_mode - *celt_mode));
    }
    curr_bandwidth := st.bandwidth;
    delay_compensation: s32 = ifx st.application == 2051 || st.application == 2053 || st.application == 2052
        then cast(s32) 0
        else st.delay_compensation;
    total_buffer := delay_compensation;

    frame_rate := st.fs / frame_size;

    if is_silence != 0 {
        activity = cast(s32) (is_silence == 0);
    } else if analysis_info.valid != 0 {
        activity = cast(s32) (c_transpiler_float_greater_equal(analysis_info.activity_probability, 0.1));
        if activity == 0 {
            noise_energy := compute_frame_energy(pcm, frame_size, st.channels, st.arch);
            activity = cast(s32) (c_transpiler_float_less(st.peak_signal_energy, (316.23 * noise_energy)));
        }
    } else if st.mode == 1002 {
        noise_energy := compute_frame_energy(pcm, frame_size, st.channels, st.arch);

        activity = cast(s32) (c_transpiler_float_less(st.peak_signal_energy, (316.23 * (0.5 * noise_energy))));
    }

    if st.silk_bw_switch != 0 {
        redundancy = 1;
        celt_to_silk = 1;
        st.silk_bw_switch = 0;

        prefill = 2;
    }

    if st.mode == 1002 {
        redundancy = 0;
    }

    if redundancy != 0 {
        redundancy_bytes = compute_redundancy_bytes(max_data_bytes, st.bitrate_bps, frame_rate, st.stream_channels);
        if redundancy_bytes == 0 {
            redundancy = 0;
        }
    }
    if st.application == 2052 {
        redundancy = 0;
        redundancy_bytes = 0;
    }

    bits_target :=
        (ifx 8 * (max_data_bytes - redundancy_bytes) < bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, frame_size) then 8 * (max_data_bytes - redundancy_bytes) else bitrate_to_bits_in_opus_encoder(st.bitrate_bps, st.fs, frame_size)) -
            8;

    data += 1;

    ec_enc_init(*enc, data, cast,no_check(Uint32) (orig_max_data_bytes - 1));

    pcm_buf :=
        cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) *
            cast,no_check(u64) ((total_buffer + frame_size) * st.channels))));
    copy_memory(
        pcm_buf,
        st.delay_buffer.data + (st.encoder_buffer - total_buffer) * st.channels,
        (cast,no_check(u64) (total_buffer * st.channels)) * size_of(Res) +
        cast,no_check(u64) (0 * (pcm_buf - st.delay_buffer.data + (st.encoder_buffer - total_buffer) * st.channels))
    );

    hp_freq_smth1: s32 = ifx st.mode == 1002
        then cast,no_check(Int32) ((cast,no_check(Uint32) silk_lin2log(60)) << 8)
        else (((((cast(*Silk_Encoder) silk_enc).state_fxx).data)[0]).s_cmn).variable_hp_smth1_q15;

    st.variable_hp_smth2_q15 =
        cast,no_check(Int32) ((cast(Int64) st.variable_hp_smth2_q15) +
            ((cast(Int64) (hp_freq_smth1 - st.variable_hp_smth2_q15)) * cast,no_check(Int64) (cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 983.5399780273438)))) >> 16);

    cutoff_hz := silk_log2lin(st.variable_hp_smth2_q15 >> 8);

    if st.application == 2048 {
        hp_cutoff(
            pcm,
            cutoff_hz,
            *pcm_buf[total_buffer * st.channels],
            st.hp_mem.data,
            frame_size,
            st.channels,
            st.fs,
            st.arch
        );
    } else {
        dc_reject(pcm, 3, *pcm_buf[total_buffer * st.channels], st.hp_mem.data, frame_size, st.channels, st.fs);
    }

    if float_api != 0 {
        sum :=
            (ifx true { (st.arch); (celt_inner_prod_c_in_opus_encoder(
                *pcm_buf[total_buffer * st.channels],
                *pcm_buf[total_buffer * st.channels],
                frame_size * st.channels
            )); });

        if !(c_transpiler_float_less(sum, 1.0e9)) || c_transpiler_float_not_equal(sum, sum) {
            fill_memory(
                *pcm_buf[total_buffer * st.channels],
                0,
                cast,no_check(u64) (frame_size * st.channels) * size_of(Res)
            );
            st.hp_mem[3] = 0.0;
            st.hp_mem[2] = st.hp_mem[3];
            st.hp_mem[1] = st.hp_mem[2];
            st.hp_mem[0] = st.hp_mem[1];
        }
    }

    hb_gain: Val16 = 1.0;
    if st.mode != 1002 {
        celt_rate: Int32 = ---;
        pcm_silk: *Res = ---;

        total_bit_rate := bits_to_bitrate_in_opus_encoder(bits_target, st.fs, frame_size);
        if st.mode == 1001 {
            st.silk_mode.bit_rate =
                compute_silk_rate_for_hybrid(
                    total_bit_rate,
                    curr_bandwidth,
                    cast(s32) (st.fs == 50 * frame_size),
                    st.use_vbr,
                    st.silk_mode.lbrr_coded,
                    st.stream_channels
                );
            if st.energy_masking == null {
                celt_rate = total_bit_rate - st.silk_mode.bit_rate;
                hb_gain =
                    1.0 - cast,no_check(float32) c_transpiler_math_exp(
                        0.6931471805599453 * cast,no_check(float64) ((cast,no_check(float32) (-celt_rate)) * 0.0009765625)
                    );
            }
        } else {
            st.silk_mode.bit_rate = total_bit_rate;
        }

        if st.energy_masking != null && st.use_vbr != 0 && st.lfe == 0 {
            mask_sum: Val32 = 0.0;

            end: s32 = 17;
            srate: Int16 = 16000;
            if st.bandwidth == 1101 {
                end = 13;
                srate = 8000;
            } else if st.bandwidth == 1102 {
                end = 15;
                srate = 12000;
            }
            c: s32 = 0;
            while c < st.channels {
                i = 0;
                while i < end {
                    mask :=
                        (ifx c_transpiler_float_greater((ifx c_transpiler_float_less(st.energy_masking[21 * c + i], 0.5) then st.energy_masking[21 * c + i] else 0.5), -2.0) then (ifx c_transpiler_float_less(st.energy_masking[21 * c + i], 0.5) then st.energy_masking[21 * c +
                            i] else 0.5) else -2.0);
                    if c_transpiler_float_greater(mask, 0.0) {
                        mask = 0.5 * mask;
                    }
                    mask_sum += mask;
                    i += 1;
                }
                c += 1;
            }

            masking_depth := mask_sum / end * st.channels;
            masking_depth += 0.2;
            rate_offset := cast,no_check(Int32) ((cast,no_check(Val32) srate) * masking_depth);
            rate_offset =
                ifx rate_offset > -2 * st.silk_mode.bit_rate /
                    3 then rate_offset else -2 * st.silk_mode.bit_rate / 3;

            if st.bandwidth == 1104 || st.bandwidth == 1105 {
                st.silk_mode.bit_rate = cast,no_check(Int32) (st.silk_mode.bit_rate + (3 * rate_offset / 5));
            } else {
                st.silk_mode.bit_rate += rate_offset;
            }
        }

        st.silk_mode.payload_size_ms = 1000 * frame_size / st.fs;
        st.silk_mode.n_channels_api = st.channels;
        st.silk_mode.n_channels_internal = st.stream_channels;
        if curr_bandwidth == 1101 {
            st.silk_mode.desired_internal_sample_rate = 8000;
        } else if curr_bandwidth == 1102 {
            st.silk_mode.desired_internal_sample_rate = 12000;
        } else {
            (st.mode == 1001 || curr_bandwidth == 1103);
            st.silk_mode.desired_internal_sample_rate = 16000;
        }
        if st.mode == 1001 {
            st.silk_mode.min_internal_sample_rate = 16000;
        } else {
            st.silk_mode.min_internal_sample_rate = 8000;
        }

        st.silk_mode.max_internal_sample_rate = 16000;
        if st.mode == 1000 {
            effective_max_rate := bits_to_bitrate_in_opus_encoder(max_data_bytes * 8, st.fs, frame_size);
            if frame_rate > 50 {
                effective_max_rate = effective_max_rate * 2 / 3;
            }
            if effective_max_rate < 8000 {
                st.silk_mode.max_internal_sample_rate = 12000;
                st.silk_mode.desired_internal_sample_rate =
                    ifx 12000 < st.silk_mode.desired_internal_sample_rate then 12000 else st.silk_mode.desired_internal_sample_rate;
            }
            if effective_max_rate < 7000 {
                st.silk_mode.max_internal_sample_rate = 8000;
                st.silk_mode.desired_internal_sample_rate =
                    ifx 8000 < st.silk_mode.desired_internal_sample_rate then 8000 else st.silk_mode.desired_internal_sample_rate;
            }
        }

        st.silk_mode.use_cbr = cast(s32) (st.use_vbr == 0);

        st.silk_mode.max_bits = (max_data_bytes - 1) * 8;
        if redundancy != 0 && redundancy_bytes >= 2 {
            st.silk_mode.max_bits -= redundancy_bytes * 8 + 1;
            if st.mode == 1001 {
                st.silk_mode.max_bits -= 20;
            }
        }
        if st.silk_mode.use_cbr != 0 {
            if st.mode == 1001 {
                other_bits :=
                    cast,no_check(Int16) ((ifx 0 > st.silk_mode.max_bits -
                        st.silk_mode.bit_rate * frame_size / st.fs then 0 else st.silk_mode.max_bits - st.silk_mode.bit_rate * frame_size / st.fs));
                st.silk_mode.max_bits =
                    ifx 0 > st.silk_mode.max_bits - (cast(s32) other_bits) * 3 / 4 then 0 else st.silk_mode.max_bits -
                        (cast(s32) other_bits) * 3 / 4;
                st.silk_mode.use_cbr = 0;
            }
        } else if st.mode == 1001 {
            max_bit_rate: Int32 =
                compute_silk_rate_for_hybrid(
                    st.silk_mode.max_bits * st.fs / frame_size,
                    curr_bandwidth,
                    cast(s32) (st.fs == 50 * frame_size),
                    st.use_vbr,
                    st.silk_mode.lbrr_coded,
                    st.stream_channels
                );
            st.silk_mode.max_bits = bitrate_to_bits_in_opus_encoder(max_bit_rate, st.fs, frame_size);
        }

        if prefill != 0 && st.application != 2052 {
            zero: Int32 = 0;
            prefill_offset := st.channels * (st.encoder_buffer - st.delay_compensation - st.fs / 400);
            gain_fade(
                st.delay_buffer.data + prefill_offset,
                st.delay_buffer.data + prefill_offset,
                0.0,
                1.0,
                celt_mode.overlap,
                st.fs / 400,
                st.channels,
                celt_mode.window,
                st.fs
            );
            fill_memory(st.delay_buffer.data, 0, cast,no_check(u64) prefill_offset * size_of(Res));
            pcm_silk = st.delay_buffer.data;
            silk_encode(silk_enc, *st.silk_mode, pcm_silk, st.encoder_buffer, null, *zero, prefill, activity);

            st.silk_mode.can_switch = 0;
        }

        pcm_silk = pcm_buf + total_buffer * st.channels;
        ret = silk_encode(silk_enc, *st.silk_mode, pcm_silk, frame_size, *enc, *n_bytes, 0, activity);
        if ret != 0 {
            return -3;
        }

        if st.mode == 1000 {
            if st.silk_mode.internal_sample_rate == 8000 {
                curr_bandwidth = 1101;
            } else if st.silk_mode.internal_sample_rate == 12000 {
                curr_bandwidth = 1102;
            } else if st.silk_mode.internal_sample_rate == 16000 {
                curr_bandwidth = 1103;
            }
        } else {
            (st.silk_mode.internal_sample_rate == 16000);
        }

        st.silk_mode.can_switch = cast(s32) (st.silk_mode.switch_ready != 0 && st.nonfinal_frame == 0);

        if activity == -1 {
            activity = cast(s32) (st.silk_mode.signal_type != 0);
        }
        if n_bytes == 0 {
            st.range_final = 0;
            data[-1] = gen_toc(st.mode, st.fs / frame_size, curr_bandwidth, st.stream_channels);

            return 1;
        }

        if st.silk_mode.can_switch != 0 {
            if st.application != 2052 {
                redundancy_bytes =
                    compute_redundancy_bytes(
                        max_data_bytes,
                        st.bitrate_bps,
                        frame_rate,
                        st.stream_channels
                    );
                redundancy = cast(s32) (redundancy_bytes != 0);
            }
            celt_to_silk = 0;
            st.silk_bw_switch = 1;
        }
    }

    if st.application != 2052 {
        endband: s32 = 21;

        if curr_bandwidth == {
            case 1101;
                endband = 13;
            case 1102; #through;
            case 1103;
                endband = 17;
            case 1104;
                endband = 19;
            case 1105;
                endband = 21;
        }
        custom_encoder_ctl(celt_enc, 10012, endband);
        custom_encoder_ctl(celt_enc, 10008, (ifx true { ((st.stream_channels == cast(s32) 0)); (st.stream_channels); }));
        custom_encoder_ctl(celt_enc, 4002, (ifx true { ((-1 == cast(s32) 0)); (-cast(s32) 1); }));
    }
    if st.mode != 1000 {
        celt_pred: Val32 = 2.0;

        if st.silk_mode.reduced_dependency != 0 {
            celt_pred = 0.0;
        }
        custom_encoder_ctl(celt_enc, 10002, cast,no_check(Int32) celt_pred);
    }

    tmp_prefill :=
        cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) *
            cast,no_check(u64) (st.channels * st.fs / 400))));
    if st.mode != 1000 && st.mode != st.prev_mode && st.prev_mode > 0 && st.application != 2053 {
        copy_memory(
            tmp_prefill,
            st.delay_buffer.data + (st.encoder_buffer - total_buffer - st.fs / 400) * st.channels,
            (cast,no_check(u64) (st.channels * st.fs / 400)) * size_of(Res) +
            cast,no_check(u64) (0 * (tmp_prefill - st.delay_buffer.data + (st.encoder_buffer - total_buffer - st.fs / 400) * st.channels))
        );
    }

    if st.channels * (st.encoder_buffer - (frame_size + total_buffer)) > 0 {
        move_memory(
            st.delay_buffer.data,
            st.delay_buffer.data + st.channels * frame_size,
            (cast,no_check(u64) (st.channels * (st.encoder_buffer - frame_size - total_buffer))) * size_of(Res) +
            cast,no_check(u64) (0 * (st.delay_buffer.data - st.delay_buffer.data + st.channels * frame_size))
        );
        copy_memory(
            st.delay_buffer.data + st.channels * (st.encoder_buffer - frame_size - total_buffer),
            *pcm_buf[0],
            (cast,no_check(u64) ((frame_size + total_buffer) * st.channels)) * size_of(Res) +
            cast,no_check(u64) (0 * (st.delay_buffer.data + st.channels * (st.encoder_buffer - frame_size - total_buffer) - *pcm_buf[0]))
        );
    } else {
        copy_memory(
            st.delay_buffer.data,
            *pcm_buf[(frame_size + total_buffer - st.encoder_buffer) * st.channels],
            (cast,no_check(u64) (st.encoder_buffer * st.channels)) * size_of(Res) +
            cast,no_check(u64) (0 * (st.delay_buffer.data - *pcm_buf[(frame_size + total_buffer - st.encoder_buffer) * st.channels]))
        );
    }

    if (c_transpiler_float_less(st.prev_hb_gain, 1.0) || c_transpiler_float_less(hb_gain, 1.0)) && celt_mode != null {
        gain_fade(
            pcm_buf,
            pcm_buf,
            st.prev_hb_gain,
            hb_gain,
            celt_mode.overlap,
            frame_size,
            st.channels,
            celt_mode.window,
            st.fs
        );
    }
    st.prev_hb_gain = hb_gain;
    if st.mode != 1001 || st.stream_channels == 1 {
        if equiv_rate > 32000 {
            st.silk_mode.stereo_width_q14 = 16384;
        } else if equiv_rate < 16000 {
            st.silk_mode.stereo_width_q14 = 0;
        } else {
            st.silk_mode.stereo_width_q14 = 16384 - 2048 * (32000 - equiv_rate) / (equiv_rate - 14000);
        }
    }
    if st.energy_masking == null && st.channels == 2 {
        if cast,no_check(s32) st.hybrid_stereo_width_q14 < (cast(s32) 1) << 14 ||
            st.silk_mode.stereo_width_q14 < (cast(s32) 1) << 14 {
            g1: Val16 = ---;
            g1 = cast,no_check(Val16) st.hybrid_stereo_width_q14;
            g2 := cast,no_check(Val16) st.silk_mode.stereo_width_q14;

            g1 *= cast(float32) 0.00006103515625;
            g2 *= cast(float32) 0.00006103515625;

            if celt_mode != null {
                stereo_fade(
                    pcm_buf,
                    pcm_buf,
                    g1,
                    g2,
                    celt_mode.overlap,
                    frame_size,
                    st.channels,
                    celt_mode.window,
                    st.fs
                );
            }
            st.hybrid_stereo_width_q14 = cast,no_check(Int16) st.silk_mode.stereo_width_q14;
        }
    }

    if st.mode != 1002 && (ec_tell_in_opus_encoder(*enc) + 17 + 20 * cast(s32) (st.mode == 1001)) <= 8 * (max_data_bytes - 1) {
        if st.mode == 1001 {
            ec_enc_bit_logp(*enc, redundancy, 12);
        }
        if redundancy != 0 {
            ec_enc_bit_logp(*enc, celt_to_silk, 1);
            max_redundancy: s32 = ifx st.mode == 1001
                then max_data_bytes - 1 - (ec_tell_in_opus_encoder(*enc) + 8 + 3 + 7) >> 3
                else max_data_bytes - 1 - (ec_tell_in_opus_encoder(*enc) + 7) >> 3;

            redundancy_bytes = min(max_redundancy, redundancy_bytes);
            redundancy_bytes =
                ifx 257 < (ifx 2 > redundancy_bytes then 2 else redundancy_bytes) then 257 else (ifx 2 > redundancy_bytes then 2 else redundancy_bytes);
            if st.mode == 1001 {
                ec_enc_uint(*enc, cast,no_check(Uint32) (redundancy_bytes - 2), 256);
            }
        }
    } else {
        redundancy = 0;
    }

    if redundancy == 0 {
        st.silk_bw_switch = 0;
        redundancy_bytes = 0;
    }
    if st.mode != 1002 {
        start_band = 17;
    }

    if st.mode == 1000 {
        ret = (ec_tell_in_opus_encoder(*enc) + 7) >> 3;
        ec_enc_done(*enc);
        nb_compr_bytes = ret;
    } else {
        nb_compr_bytes = max_data_bytes - 1 - redundancy_bytes;

        ec_enc_shrink(*enc, cast,no_check(Uint32) nb_compr_bytes);
    }

    if redundancy != 0 || st.mode != 1000 {
        custom_encoder_ctl(celt_enc, 10022, analysis_info + (analysis_info - analysis_info));
    }

    if st.mode == 1001 {
        info: SILK_Info = ---;
        info.signal_type = st.silk_mode.signal_type;
        info.offset = st.silk_mode.offset;
        custom_encoder_ctl(celt_enc, 10028, *info + (*info - *info));
    }

    if redundancy != 0 && celt_to_silk != 0 {
        custom_encoder_ctl(celt_enc, 10010, cast(s32) 0);
        custom_encoder_ctl(celt_enc, 4006, cast(s32) 0);
        custom_encoder_ctl(celt_enc, 4002, (ifx true { ((-1 == cast(s32) 0)); (-cast(s32) 1); }));
        err := celt_encode_with_ec(celt_enc, pcm_buf, st.fs / 200, data + nb_compr_bytes, redundancy_bytes, null);
        if err < 0 {
            return -3;
        }
        custom_encoder_ctl(celt_enc, 4031, *redundant_rng + (*redundant_rng - *redundant_rng));
        custom_encoder_ctl(celt_enc, 4028);
    }

    if st.application != 2052 {
        custom_encoder_ctl(celt_enc, 10010, start_band);
    }

    data[-1] = 0;
    if st.mode != 1000 {
        custom_encoder_ctl(celt_enc, 4006, (ifx true { ((st.use_vbr == cast(s32) 0)); (st.use_vbr); }));
        if st.mode == 1001 {
            if st.use_vbr != 0 {
                custom_encoder_ctl(
                    celt_enc,
                    4002,
                    (ifx true { ((st.bitrate_bps -
                    st.silk_mode.bit_rate == cast(s32) 0)); ((st.bitrate_bps - st.silk_mode.bit_rate)); })
                );
                custom_encoder_ctl(celt_enc, 4020, cast(s32) 0);
            }
        } else if st.use_vbr != 0 {
            custom_encoder_ctl(celt_enc, 4006, cast(s32) 1);
            custom_encoder_ctl(
                celt_enc,
                4020,
                (ifx true { ((st.vbr_constraint == cast(s32) 0)); (st.vbr_constraint); })
            );
            custom_encoder_ctl(celt_enc, 4002, (ifx true { ((st.bitrate_bps == cast(s32) 0)); (st.bitrate_bps); }));
        }

        if st.mode != st.prev_mode && st.prev_mode > 0 && st.application != 2053 {
            dummy: [2] u8 = ---;
            custom_encoder_ctl(celt_enc, 4028);

            celt_encode_with_ec(celt_enc, tmp_prefill, st.fs / 400, dummy.data, 2, null);
            custom_encoder_ctl(celt_enc, 10002, cast(s32) 0);
        }

        if ec_tell_in_opus_encoder(*enc) <= 8 * nb_compr_bytes {
            ret = celt_encode_with_ec(celt_enc, pcm_buf, frame_size, null, nb_compr_bytes, *enc);

            if ret < 0 {
                return -3;
            }

            if redundancy != 0 && celt_to_silk != 0 && st.mode == 1001 && nb_compr_bytes != ret {
                move_memory(
                    data + ret,
                    data + nb_compr_bytes,
                    (cast,no_check(u64) redundancy_bytes) * size_of(u8) +
                    cast,no_check(u64) (0 * (data + ret - (data + nb_compr_bytes)))
                );
                nb_compr_bytes = ret + redundancy_bytes;
            }
        }
        custom_encoder_ctl(celt_enc, 4031, *st.range_final + (*st.range_final - *st.range_final));
    } else {
        st.range_final = enc.rng;
    }

    if redundancy != 0 && celt_to_silk == 0 {
        dummy: [2] u8 = ---;
        n2: s32 = ---;
        n2 = st.fs / 200;
        n4 := st.fs / 400;

        custom_encoder_ctl(celt_enc, 4028);
        custom_encoder_ctl(celt_enc, 10010, cast(s32) 0);
        custom_encoder_ctl(celt_enc, 10002, cast(s32) 0);
        custom_encoder_ctl(celt_enc, 4006, cast(s32) 0);
        custom_encoder_ctl(celt_enc, 4002, (ifx true { ((-1 == cast(s32) 0)); (-cast(s32) 1); }));

        if st.mode == 1001 {
            nb_compr_bytes = ret;
            ec_enc_shrink(*enc, cast,no_check(Uint32) nb_compr_bytes);
        }

        celt_encode_with_ec(celt_enc, pcm_buf + st.channels * (frame_size - n2 - n4), n4, dummy.data, 2, null);

        err :=
            celt_encode_with_ec(
                celt_enc,
                pcm_buf + st.channels * (frame_size - n2),
                n2,
                data + nb_compr_bytes,
                redundancy_bytes,
                null
            );
        if err < 0 {
            return -3;
        }
        custom_encoder_ctl(celt_enc, 4031, *redundant_rng + (*redundant_rng - *redundant_rng));
    }

    data -= 1;
    c_transpiler_compound_or(*(data[0]), (cast,no_check(s32) gen_toc(st.mode, st.fs / frame_size, curr_bandwidth, st.stream_channels)), s32, s32);

    st.range_final ^= redundant_rng;

    if to_celt != 0 {
        st.prev_mode = 1002;
    } else {
        st.prev_mode = st.mode;
    }
    st.prev_channels = st.stream_channels;
    st.prev_framesize = frame_size;

    st.first = 0;

    if st.use_dtx != 0 && st.silk_mode.use_dtx == 0 {
        if decide_dtx_mode(activity, *st.nb_no_activity_ms_q1, (cast,no_check(s32) ((2 * 1000))) * frame_size / st.fs) != 0 {
            st.range_final = 0;
            data[0] = gen_toc(st.mode, st.fs / frame_size, curr_bandwidth, st.stream_channels);

            return 1;
        }
    } else {
        st.nb_no_activity_ms_q1 = 0;
    }

    if ec_tell_in_opus_encoder(*enc) > (max_data_bytes - 1) * 8 {
        if max_data_bytes < 2 {
            return -2;
        }
        data[1] = 0;
        ret = 1;
        st.range_final = 0;
    } else if st.mode == 1000 && redundancy == 0 {
        while ret > 2 && data[ret] == 0 {
            ret -= 1;
        }
    }

    ret += 1 + redundancy_bytes;
    apply_padding := cast(s32) (st.use_vbr == 0);

    if apply_padding != 0 {
        if packet_pad(data, ret, orig_max_data_bytes) != 0 {
            return -3;
        }
        ret = orig_max_data_bytes;
    }

    return ret;
}

gen_toc :: (mode: s32, framerate: s32, bandwidth: s32, channels: s32) -> u8 {
    toc: u8 = ---;
    period: s32 = 0;
    while framerate < 400 {
        c_transpiler_compound_shl(*(framerate), (cast(s32) 1), s32, s32);
        period += 1;
    }
    if mode == 1000 {
        toc = cast,no_check(u8) ((bandwidth - 1101) << 5);
        toc = cast,no_check(u8) ((cast,no_check(s32) toc) | ((period - 2) << 3));
    } else if mode == 1002 {
        tmp := bandwidth - 1102;
        if tmp < 0 {
            tmp = 0;
        }
        toc = 0x80;
        toc = cast,no_check(u8) ((cast,no_check(s32) toc) | (tmp << 5));
        toc = cast,no_check(u8) ((cast,no_check(s32) toc) | (period << 3));
    } else {
        toc = 0x60;
        toc = cast,no_check(u8) ((cast,no_check(s32) toc) | ((bandwidth - 1104) << 4));
        toc = cast,no_check(u8) ((cast,no_check(s32) toc) | ((period - 2) << 3));
    }
    toc = cast,no_check(u8) ((cast,no_check(s32) toc) | ((cast(s32) (channels == 2)) << 2));
    return toc;
}

decide_dtx_mode :: (activity: s32, nb_no_activity_ms_q1: *s32, frame_size_ms_q1: s32) -> s32 {
    if activity == 0 {
        nb_no_activity_ms_q1.* += frame_size_ms_q1;
        if nb_no_activity_ms_q1.* > (cast,no_check(s32) ((10 * 20))) * 2 {
            if nb_no_activity_ms_q1.* <= (cast,no_check(s32) ((10 + 20))) * 20 * 2 {
                return 1;
            } else {
                nb_no_activity_ms_q1.* = (cast,no_check(s32) ((10 * 20))) * 2;
            }
        }
    } else {
        nb_no_activity_ms_q1.* = 0;
    }

    return 0;
}

stereo_fade :: (
    in: *Res,
    out: *Res,
    g1: Val16,
    g2: Val16,
    overlap48: s32,
    frame_size: s32,
    channels: s32,
    window: *Celt_Coef,
    fs: Int32
) {
    inc := (ifx 1 > 48000 / fs then 1 else 48000 / fs);
    overlap := overlap48 / inc;
    g1 = 1.0 - g1;
    g2 = 1.0 - g2;
    i: s32 = 0;
    while i < overlap {
        w: Val16 = ---;
        w = window[i * inc];
        w = w * w;
        g := w * g2 + (1.0 - w) * g1;
        diff := 0.5 * (in[i * channels] - in[i * channels + 1]);
        diff = g * diff;
        out[i * channels] = out[i * channels] - diff;
        out[i * channels + 1] = out[i * channels + 1] + diff;
        i += 1;
    }
    while i < frame_size {
        diff := 0.5 * (in[i * channels] - in[i * channels + 1]);
        diff = g2 * diff;
        out[i * channels] = out[i * channels] - diff;
        out[i * channels + 1] = out[i * channels + 1] + diff;
        i += 1;
    }
}

gain_fade :: (
    in: *Res,
    out: *Res,
    g1: Val16,
    g2: Val16,
    overlap48: s32,
    frame_size: s32,
    channels: s32,
    window: *Celt_Coef,
    fs: Int32
) {
    i: s32 = ---;

    inc := (ifx 1 > 48000 / fs then 1 else 48000 / fs);
    overlap := overlap48 / inc;
    if channels == 1 {
        i = 0;
        while i < overlap {
            w: Val16 = ---;
            w = window[i * inc];
            w = w * w;
            g := w * g2 + (1.0 - w) * g1;
            out[i] = g * in[i];
            i += 1;
        }
    } else {
        i = 0;
        while i < overlap {
            w: Val16 = ---;
            w = window[i * inc];
            w = w * w;
            g := w * g2 + (1.0 - w) * g1;
            out[i * 2] = g * in[i * 2];
            out[i * 2 + 1] = g * in[i * 2 + 1];
            i += 1;
        }
    }
    c: s32 = 0;
    while true {
        i = overlap;
        while i < frame_size {
            out[i * channels + c] = g2 * in[i * channels + c];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < channels) break;
    }
}

compute_redundancy_bytes :: (max_data_bytes: Int32, bitrate_bps: Int32, frame_rate: s32, channels: s32) -> s32 {
    base_bits := 40 * channels + 20;

    redundancy_rate := bitrate_bps + base_bits * (200 - frame_rate);

    redundancy_rate = 3 * redundancy_rate / 2;
    redundancy_bytes := redundancy_rate / 1600;

    available_bits := max_data_bytes * 8 - 2 * base_bits;
    redundancy_bytes_cap := (available_bits * 240 / (240 + 48000 / frame_rate) + base_bits) / 8;
    redundancy_bytes = min(redundancy_bytes, redundancy_bytes_cap);

    if redundancy_bytes > 4 + 8 * channels {
        redundancy_bytes = ifx 257 < redundancy_bytes then 257 else redundancy_bytes;
    } else {
        redundancy_bytes = 0;
    }
    return redundancy_bytes;
}

compute_silk_rate_for_hybrid :: (rate: s32, bandwidth: s32, frame20ms: s32, vbr: s32, fec: s32, channels: s32) -> s32 {
    silk_rate: s32 = ---;

    rate /= channels;
    entry := 1 + frame20ms + 2 * fec;
    n: s32 = cast,no_check(s32) (cast(u64) RATE_TABLE.count);
    i: s32 = 1;
    while i < n {
        if RATE_TABLE[i][0] > rate {
            break;
        }
        i += 1;
    }
    if i == n {
        silk_rate = RATE_TABLE[i - 1][entry];

        silk_rate += (rate - RATE_TABLE[i - 1][0]) / 2;
    } else {
        lo: Int32 = ---;
        lo = RATE_TABLE[i - 1][entry];
        hi := RATE_TABLE[i][entry];
        x0 := RATE_TABLE[i - 1][0];
        x1 := RATE_TABLE[i][0];
        silk_rate = (lo * (x1 - rate) + hi * (rate - x0)) / (x1 - x0);
    }
    if vbr == 0 {
        silk_rate += 100;
    }
    if bandwidth == 1104 {
        silk_rate += 300;
    }
    silk_rate *= channels;

    if channels == 2 && rate >= 12000 {
        silk_rate -= 1000;
    }
    return silk_rate;
}

celt_inner_prod_c_in_opus_encoder :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

dc_reject :: (in: *Val16, cutoff_hz: Int32, out: *Val16, hp_mem: *Val32, len: s32, channels: s32, fs: Int32) {
    coef: float32 = ---;
    coef = (6.3 * cast,no_check(float32) cutoff_hz) / fs;
    coef2 := 1.0 - coef;
    if channels == 2 {
        m0: float32 = ---;
        m0 = hp_mem[0];
        m2 := hp_mem[2];
        if 0 < len {
            for i: 0..len - 1 {
                x0: Val32 = ---;
                x0 = in[2 * i + 0];
                x1 := in[2 * i + 1];
                out0 := x0 - m0;
                out1 := x1 - m2;
                m0 = coef * x0 + 1.0e-30 + coef2 * m0;
                m2 = coef * x1 + 1.0e-30 + coef2 * m2;
                out[2 * i + 0] = out0;
                out[2 * i + 1] = out1;
            }
        }
        hp_mem[0] = m0;
        hp_mem[2] = m2;
    } else {
        m0 := hp_mem[0];
        if 0 < len {
            for i: 0..len - 1 {
                x: Val32 = ---;
                x = in[i];
                y := x - m0;
                m0 = coef * x + 1.0e-30 + coef2 * m0;
                out[i] = y;
            }
        }
        hp_mem[0] = m0;
    }
}

hp_cutoff :: (in: *Res, cutoff_hz: Int32, out: *Res, hp_mem: *Val32, len: s32, channels: s32, fs: Int32, arch: s32) {
    b_q28: [3] Int32 = ---;
    a_q28: [2] Int32 = ---;

    (cutoff_hz <= 0x7fffffff / cast,no_check(Int32) (cast(float64) 2471.1469068799999));
    fc_q19 :=
        ((cast,no_check(Int32) (cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 2471.1469068799999)))) * cast,no_check(Int32) (cast,no_check(Int16) cutoff_hz)) /
            (fs / 1000);
    (fc_q19 > 0 && fc_q19 < 32768);

    r_q28 :=
        (cast,no_check(Int32) (cast(float64) 268435456.5)) -
            (cast,no_check(Int32) (cast(float64) 471.54)) * fc_q19;

    b_q28[0] = r_q28;
    b_q28[1] = cast,no_check(Int32) ((cast,no_check(Uint32) (-r_q28)) << 1);
    b_q28[2] = r_q28;

    r_q22 := r_q28 >> 6;
    a_q28[0] =
        cast,no_check(Int32) (((cast,no_check(Int64) r_q22) *
            cast(Int64) ((cast,no_check(Int32) (((cast,no_check(Int64) fc_q19) * cast(Int64) fc_q19) >> 16)) - cast,no_check(Int32) (cast(float64) 8388608.5))) >> 16);
    a_q28[1] = cast,no_check(Int32) (((cast,no_check(Int64) r_q22) * cast(Int64) r_q22) >> 16);

    silk_biquad_res(in, b_q28.data, a_q28.data, hp_mem, out, len, channels);
    if channels == 2 {
        silk_biquad_res(in + 1, b_q28.data, a_q28.data, hp_mem + 2, out + 1, len, channels);
    }
}

silk_biquad_res :: (in: *Res, b_q28: *Int32, a_q28: *Int32, s: *Val32, out: *Res, LEN: Int32, stride: s32) {
    a: [2] Val32 = ---;
    b: [3] Val32 = ---;

    a[0] = (cast,no_check(float32) a_q28[0]) * cast(float32) 3.725290298461914e-9;
    a[1] = (cast,no_check(float32) a_q28[1]) * cast(float32) 3.725290298461914e-9;
    b[0] = (cast,no_check(float32) b_q28[0]) * cast(float32) 3.725290298461914e-9;
    b[1] = (cast,no_check(float32) b_q28[1]) * cast(float32) 3.725290298461914e-9;
    b[2] = (cast,no_check(float32) b_q28[2]) * cast(float32) 3.725290298461914e-9;

    k: s32 = 0;
    while k < LEN {
        inval := in[k * stride];
        vout := s[0] + b[0] * inval;

        s[0] = s[1] - vout * a[0] + b[1] * inval;

        s[1] = -vout * a[1] + b[2] * inval + 1.0e-30;

        out[k * stride] = vout;
        k += 1;
    }
}

compute_frame_energy :: (pcm: *Val16, frame_size: s32, channels: s32, arch: s32) -> Val32 {
    len := frame_size * channels;
    return celt_inner_prod_c_in_opus_encoder(pcm, pcm, len) / len;
}

is_digital_silence :: (pcm: *Res, frame_size: s32, channels: s32, lsb_depth: s32) -> s32 {
    silence: s32 = 0;
    sample_max: Val32 = 0.0;

    sample_max = celt_maxabs16_in_opus_encoder(pcm, frame_size * channels);

    silence =
        cast(s32) (c_transpiler_float_less_equal(sample_max, (1.0 /
            cast,no_check(Val16) ((cast(s32) 1) << ((lsb_depth) & 31)))));

    return silence;
}

celt_maxabs16_in_opus_encoder :: (x: *Val16, len: s32) -> Val32 {
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

decide_fec :: (
    use_in_band_fec: s32,
    packet_loss_perc: s32,
    last_fec: s32,
    mode: s32,
    bandwidth: *s32,
    rate: Int32
) -> s32 {
    if use_in_band_fec == 0 || packet_loss_perc == 0 || mode == 1002 {
        return 0;
    }
    orig_bandwidth := bandwidth.*;
    while true {
        lbrr_rate_thres_bps := FEC_THRESHOLDS[2 * (bandwidth.* - 1101)];
        hysteresis := FEC_THRESHOLDS[2 * (bandwidth.* - 1101) + 1];
        if last_fec == 1 {
            lbrr_rate_thres_bps -= hysteresis;
        }
        if last_fec == 0 {
            lbrr_rate_thres_bps += hysteresis;
        }
        lbrr_rate_thres_bps =
            cast,no_check(Int32) (((cast(Int64) (lbrr_rate_thres_bps * (125 - (ifx packet_loss_perc < 25 then packet_loss_perc else 25)))) *
                cast,no_check(Int64) (cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 655.86)))) >> 16);

        if rate > lbrr_rate_thres_bps {
            return 1;
        } else if packet_loss_perc <= 5 {
            return 0;
        } else if bandwidth.* > 1101 {
            bandwidth.* -= 1;
        } else {
            break;
        }
    }

    bandwidth.* = orig_bandwidth;
    return 0;
}

compute_equiv_rate :: (
    bitrate: Int32,
    channels: s32,
    frame_rate: s32,
    vbr: s32,
    mode: s32,
    complexity: s32,
    loss: s32
) -> Int32 {
    equiv := bitrate;

    if frame_rate > 50 {
        equiv = cast,no_check(Int32) (equiv - ((40 * channels + 20) * (frame_rate - 50)));
    }

    if vbr == 0 {
        equiv = cast,no_check(Int32) (equiv - (equiv / 12));
    }

    equiv = equiv * (90 + complexity) / 100;
    if mode == 1000 || mode == 1001 {
        if complexity < 2 {
            equiv = equiv * 4 / 5;
        }
        equiv = cast,no_check(Int32) (equiv - (equiv * loss / (6 * loss + 10)));
    } else if mode == 1002 {
        if complexity < 5 {
            equiv = equiv * 9 / 10;
        }
    } else {
        equiv = cast,no_check(Int32) (equiv - (equiv * loss / (12 * loss + 20)));
    }
    return equiv;
}

user_bitrate_to_bitrate :: (st: *Encoder_in_opus_encoder, frame_size: s32, max_data_bytes: s32) -> Int32 {
    if frame_size == 0 {
        frame_size = st.fs / 400;
    }
    max_bitrate := bits_to_bitrate_in_opus_encoder(max_data_bytes * 8, st.fs, frame_size);
    user_bitrate: Int32 = ifx st.user_bitrate_bps == -1000
        then 60 * st.fs / frame_size + st.fs * st.channels
        else ifx st.user_bitrate_bps == -1
            then cast(Int32) 1500000
            else st.user_bitrate_bps;
    return min(user_bitrate, max_bitrate);
}

compute_stereo_width :: (pcm: *Res, frame_size: s32, fs: Int32, mem: *Stereo_Width_State) -> Val16 {
    xx_, xy, yy: Val32 = ---;
    sqrt_xx, sqrt_yy: Val16 = ---;
    qrrt_xx, qrrt_yy: Val16 = ---;

    frame_rate := fs / frame_size;
    short_alpha := 25.0 / cast,no_check(Val32) ((ifx 50 > frame_rate then 50 else frame_rate));
    yy = 0.0;
    xy = yy;
    xx_ = xy;

    i: s32 = 0;
    while i < frame_size - 3 {
        pxx: Val32 = 0.0;
        pxy: Val32 = 0.0;
        pyy: Val32 = 0.0;
        x: Val16 = ---;
        x = pcm[2 * i];
        y := pcm[2 * i + 1];
        pxx = x * x;
        pxy = x * y;
        pyy = y * y;
        x = pcm[2 * i + 2];
        y = pcm[2 * i + 3];
        pxx += x * x;
        pxy += x * y;
        pyy += y * y;
        x = pcm[2 * i + 4];
        y = pcm[2 * i + 5];
        pxx += x * x;
        pxy += x * y;
        pyy += y * y;
        x = pcm[2 * i + 6];
        y = pcm[2 * i + 7];
        pxx += x * x;
        pxy += x * y;
        pyy += y * y;

        xx_ += pxx;
        xy += pxy;
        yy += pyy;
        i += 4;
    }

    if !(c_transpiler_float_less(xx_, 1.0e9)) ||
        c_transpiler_float_not_equal(xx_, xx_) ||
        !(c_transpiler_float_less(yy, 1.0e9)) ||
        c_transpiler_float_not_equal(yy, yy) {
        yy = 0.0;
        xx_ = yy;
        xy = xx_;
    }

    mem.xx_ += short_alpha * (xx_ - mem.xx_);

    mem.xy = (1.0 - short_alpha) * mem.xy + short_alpha * xy;
    mem.yy += short_alpha * (yy - mem.yy);
    mem.xx_ = ifx c_transpiler_float_greater(0.0, mem.xx_) then 0.0 else mem.xx_;
    mem.xy = ifx c_transpiler_float_greater(0.0, mem.xy) then 0.0 else mem.xy;
    mem.yy = ifx c_transpiler_float_greater(0.0, mem.yy) then 0.0 else mem.yy;
    if c_transpiler_float_greater((ifx c_transpiler_float_greater(mem.xx_, mem.yy) then mem.xx_ else mem.yy), 8.0e-4) {
        sqrt_xx = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) mem.xx_);
        sqrt_yy = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) mem.yy);
        qrrt_xx = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) sqrt_xx);
        qrrt_yy = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) sqrt_yy);

        mem.xy = ifx c_transpiler_float_less(mem.xy, (sqrt_xx * sqrt_yy)) then mem.xy else sqrt_xx * sqrt_yy;
        corr := mem.xy / (1.0e-15 + sqrt_xx * sqrt_yy);

        ldiff :=
            (1.0 * cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) (qrrt_xx - qrrt_yy))) /
                (1.0e-15 + qrrt_xx + qrrt_yy);
        width :=
            (ifx c_transpiler_float_less(1.0, cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (1.0 - corr * corr))) then 1.0 else cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (1.0 - corr * corr))) *
                ldiff;

        mem.smoothed_width += (width - mem.smoothed_width) / frame_rate;

        mem.max_follower =
            ifx c_transpiler_float_greater((mem.max_follower - 0.02 / cast,no_check(float32) frame_rate), mem.smoothed_width) then mem.max_follower -
                0.02 / cast,no_check(float32) frame_rate else mem.smoothed_width;
    }

    return ifx c_transpiler_float_less(1.0, (20.0 * mem.max_follower)) then 1.0 else 20.0 * mem.max_follower;
}

frame_size_select :: (application: s32, frame_size: Int32, variable_duration: s32, fs: Int32) -> Int32 {
    new_size: s32 = ---;
    if frame_size < fs / 400 {
        return -1;
    }
    if variable_duration == 5000 {
        new_size = frame_size;
    } else if variable_duration >= 5001 && variable_duration <= 5009 {
        if variable_duration <= 5005 {
            new_size = (fs / 400) << (((variable_duration - 5001)) & 31);
        } else {
            new_size = (variable_duration - 5001 - 2) * fs / 50;
        }
    } else {
        return -1;
    }
    if new_size > frame_size {
        return -1;
    }
    if 400 * new_size != fs &&
        200 * new_size != fs &&
        100 * new_size != fs &&
        50 * new_size != fs &&
        25 * new_size != fs &&
        50 * new_size != 3 * fs &&
        50 * new_size != 4 * fs &&
        50 * new_size != 5 * fs &&
        50 * new_size != 6 * fs {
        return -1;
    }
    if application == 2052 && new_size < fs / 100 {
        return -1;
    }
    return new_size;
}

encode24 :: (
    st: *Encoder_in_opus_encoder,
    pcm: *Int32,
    analysis_frame_size: s32,
    data: *u8,
    max_data_bytes: Int32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    frame_size := frame_size_select(st.application, analysis_frame_size, st.variable_duration, st.fs);
    if frame_size <= 0 {
        return -1;
    }
    in := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (frame_size * st.channels))));

    i: s32 = 0;
    while i < frame_size * st.channels {
        in[i] = (cast(float32) 1.1920928955078126e-7) * cast,no_check(float32) pcm[i];
        i += 1;
    }
    ret :=
        encode_native(
            st,
            in,
            frame_size,
            data,
            max_data_bytes,
            24,
            cast(*void) pcm,
            analysis_frame_size,
            0,
            -2,
            st.channels,
            cast,no_check(Downmix_Func) downmix_int24,
            1
        );

    return ret;
}

downmix_int24 :: (x_value: *void, y: *Val32, subframe: s32, offset: s32, c1: s32, c2: s32, c_value: s32) {
    x := cast(*Int32) x_value;
    j: s32 = 0;
    while j < subframe {
        y[j] = (cast,no_check(float32) x[(j + offset) * c_value + c1]) * 0.00390625;
        j += 1;
    }
    if c2 > -1 {
        j = 0;
        while j < subframe {
            y[j] += (cast,no_check(float32) x[(j + offset) * c_value + c2]) * 0.00390625;
            j += 1;
        }
    } else if c2 == -2 {
        if 1 < c_value {
            for c: 1..c_value - 1 {
                j = 0;
                while j < subframe {
                    y[j] += (cast,no_check(float32) x[(j + offset) * c_value + c]) * 0.00390625;
                    j += 1;
                }
            }
        }
    }
}

encode_float :: (
    st: *Encoder_in_opus_encoder,
    pcm: *float32,
    analysis_frame_size: s32,
    data: *u8,
    out_data_bytes: Int32
) -> Int32 {
    frame_size := frame_size_select(st.application, analysis_frame_size, st.variable_duration, st.fs);
    return encode_native(
        st,
        pcm,
        frame_size,
        data,
        out_data_bytes,
        24,
        cast(*void) pcm,
        analysis_frame_size,
        0,
        -2,
        st.channels,
        cast,no_check(Downmix_Func) downmix_float,
        1
    );
}

downmix_float :: (x_value: *void, y: *Val32, subframe: s32, offset: s32, c1: s32, c2: s32, c_value: s32) {
    x := cast(*float32) x_value;
    j: s32 = 0;
    while j < subframe {
        y[j] = x[(j + offset) * c_value + c1] * 32768.0;
        j += 1;
    }
    if c2 > -1 {
        j = 0;
        while j < subframe {
            y[j] += x[(j + offset) * c_value + c2] * 32768.0;
            j += 1;
        }
    } else if c2 == -2 {
        if 1 < c_value {
            for c: 1..c_value - 1 {
                j = 0;
                while j < subframe {
                    y[j] += x[(j + offset) * c_value + c] * 32768.0;
                    j += 1;
                }
            }
        }
    }

    j = 0;
    while j < subframe {
        if c_transpiler_float_less(y[j], -65536.0) {
            y[j] = -65536.0;
        }
        if c_transpiler_float_greater(y[j], 65536.0) {
            y[j] = 65536.0;
        }
        if c_transpiler_float_not_equal(y[j], y[j]) {
            y[j] = 0.0;
        }
        j += 1;
    }
}

encoder_destroy :: (st: *Encoder_in_opus_encoder) {
    free__in_opus_encoder(cast(*void) st);
}

encoder_ctl :: (st: *Encoder_in_opus_encoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ret: s32 = ---;
    celt_enc: *Custom_Encoder = ---;
    ap: Va_List = ---;
    value: Int32 = ---;
    value_2: *Int32 = ---;
    value_3: Int32 = ---;
    value_4: *Int32 = ---;
    value_5: Int32 = ---;
    value_6: *Int32 = ---;
    value_7: Int32 = ---;
    value_8: *Int32 = ---;
    value_9: Int32 = ---;
    value_10: *Int32 = ---;
    value_11: Int32 = ---;
    value_12: *Int32 = ---;
    value_13: Int32 = ---;
    value_14: *Int32 = ---;
    value_15: Int32 = ---;
    value_16: *Int32 = ---;
    value_17: Int32 = ---;
    value_18: *Int32 = ---;
    value_19: Int32 = ---;
    value_20: *Int32 = ---;
    value_21: Int32 = ---;
    value_22: *Int32 = ---;
    value_23: Int32 = ---;
    value_24: *Int32 = ---;
    value_25: Int32 = ---;
    value_26: *Int32 = ---;
    value_27: *Int32 = ---;
    value_28: *Int32 = ---;
    value_29: *Uint32 = ---;
    value_30: Int32 = ---;
    value_31: *Int32 = ---;
    value_32: Int32 = ---;
    value_33: *Int32 = ---;
    value_34: Int32 = ---;
    value_35: *Int32 = ---;
    value_36: Int32 = ---;
    value_37: *Int32 = ---;
    silk_enc: *void = ---;
    dummy: Silk_Enc_Control_Struct = ---;
    start: *s8 = ---;
    value_38: Int32 = ---;
    value_39: Int32 = ---;
    value_40: *Celt_Glog = ---;
    value_41: *Int32 = ---;
    silk_enc_2: *Silk_Encoder = ---;
    value_42: **Custom_Mode = ---;
    code_block_to_execute: s64 = 326;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 46; {
                return -1;
            }
            case 48; {
                return ret;
            }
            case 91; {
                st.stream_channels = st.channels;
                st.hybrid_stereo_width_q14 = cast,no_check(Int16) ((cast(s32) 1) << 14);
                st.prev_hb_gain = 1.0;
                st.first = 1;
                st.mode = 1001;
                st.bandwidth = 1105;
                st.variable_hp_smth2_q15 = cast,no_check(Int32) ((cast,no_check(Uint32) silk_lin2log(60)) << 8);
                code_block_to_execute = 48;
                continue c_transpiler_dispatch;
            }
            case 93; {
                if st.application != 2053 {
                    silk_init_encoder(silk_enc, st.channels, st.arch, *dummy);
                    code_block_to_execute = 91;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 91;
                    continue c_transpiler_dispatch;
                }
            }
            case 319; {
                c_transpiler_switch_value_319 := request;
                if c_transpiler_switch_value_319 == {
                    case cast(s32) 4000; {
                        value = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if st.application == 2052 || st.application == 2053 {
                            ret = -1;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        } else {
                            if value != 2048 && value != 2049 && value != 2051 || st.first == 0 && st.application != value {
                                ret = -1;
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                st.application = value;
                                st.analysis.application = value;
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4001; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_2 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_2.* = st.application;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4002; {
                        value_3 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_3 != -1000 && value_3 != -1 {
                            if value_3 <= 0 {
                                code_block_to_execute = 46;
                                continue c_transpiler_dispatch;
                            } else {
                                if value_3 <= 500 {
                                    value_3 = 500;
                                    st.user_bitrate_bps = value_3;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                } else {
                                    if value_3 > (cast(s32) 750000) * st.channels {
                                        value_3 = (cast(s32) 750000) * st.channels;
                                        st.user_bitrate_bps = value_3;
                                        code_block_to_execute = 48;
                                        continue c_transpiler_dispatch;
                                    } else {
                                        st.user_bitrate_bps = value_3;
                                        code_block_to_execute = 48;
                                        continue c_transpiler_dispatch;
                                    }
                                }
                            }
                        } else {
                            st.user_bitrate_bps = value_3;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4003; {
                        value_4 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_4 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_4.* = user_bitrate_to_bitrate(st, st.prev_framesize, 1276);
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4022; {
                        value_5 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if (value_5 < 1 || value_5 > st.channels) && value_5 != -1000 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.force_channels = value_5;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4023; {
                        value_6 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_6 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_6.* = st.force_channels;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4004; {
                        value_7 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_7 < 1101 || value_7 > 1105 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.max_bandwidth = value_7;
                            if st.max_bandwidth == 1101 {
                                st.silk_mode.max_internal_sample_rate = 8000;
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                if st.max_bandwidth == 1102 {
                                    st.silk_mode.max_internal_sample_rate = 12000;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                } else {
                                    st.silk_mode.max_internal_sample_rate = 16000;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                }
                            }
                        }
                    }
                    case cast(s32) 4005; {
                        value_8 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_8 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_8.* = st.max_bandwidth;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4008; {
                        value_9 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if (value_9 < 1101 || value_9 > 1105) && value_9 != -1000 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.user_bandwidth = value_9;
                            if st.user_bandwidth == 1101 {
                                st.silk_mode.max_internal_sample_rate = 8000;
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                if st.user_bandwidth == 1102 {
                                    st.silk_mode.max_internal_sample_rate = 12000;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                } else {
                                    st.silk_mode.max_internal_sample_rate = 16000;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                }
                            }
                        }
                    }
                    case cast(s32) 4009; {
                        value_10 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_10 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_10.* = st.bandwidth;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4016; {
                        value_11 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_11 < 0 || value_11 > 1 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.use_dtx = value_11;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4017; {
                        value_12 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_12 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_12.* = st.use_dtx;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4010; {
                        value_13 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_13 < 0 || value_13 > 10 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.silk_mode.complexity = value_13;
                            if st.application != 2052 {
                                custom_encoder_ctl(celt_enc, 4010, value_13);
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4011; {
                        value_14 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_14 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_14.* = st.silk_mode.complexity;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4012; {
                        value_15 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_15 < 0 || value_15 > 2 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.fec_config = value_15;
                            st.silk_mode.use_in_band_fec = cast(s32) (value_15 != 0);
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4013; {
                        value_16 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_16 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_16.* = st.fec_config;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4014; {
                        value_17 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_17 < 0 || value_17 > 100 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.silk_mode.packet_loss_percentage = value_17;
                            if st.application != 2052 {
                                custom_encoder_ctl(celt_enc, 4014, value_17);
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4015; {
                        value_18 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_18 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_18.* = st.silk_mode.packet_loss_percentage;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4006; {
                        value_19 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_19 < 0 || value_19 > 1 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.use_vbr = value_19;
                            st.silk_mode.use_cbr = 1 - value_19;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4007; {
                        value_20 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_20 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_20.* = st.use_vbr;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 11018; {
                        value_21 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_21 < -1 || value_21 > 100 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.voice_ratio = value_21;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 11019; {
                        value_22 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_22 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_22.* = st.voice_ratio;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4020; {
                        value_23 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_23 < 0 || value_23 > 1 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.vbr_constraint = value_23;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4021; {
                        value_24 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_24 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_24.* = st.vbr_constraint;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4024; {
                        value_25 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_25 != -1000 && value_25 != 3001 && value_25 != 3002 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.signal_type = value_25;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4025; {
                        value_26 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_26 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_26.* = st.signal_type;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4027; {
                        value_27 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_27 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_27.* = st.fs / 400;
                            if st.application != 2051 && st.application != 2053 {
                                value_27.* = cast,no_check(Int32) (value_27.* + st.delay_compensation);
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4029; {
                        value_28 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_28 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_28.* = st.fs;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4031; {
                        value_29 = c_transpiler_va_arg(cast(*void) (ap.data), *Uint32);
                        if value_29 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_29.* = st.range_final;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4036; {
                        value_30 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_30 < 8 || value_30 > 24 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.lsb_depth = value_30;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4037; {
                        value_31 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_31 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_31.* = st.lsb_depth;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4040; {
                        value_32 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_32 != 5000 && value_32 != 5001 && value_32 != 5002 && value_32 != 5003 && value_32 != 5004 && value_32 != 5005 && value_32 != 5006 && value_32 != 5007 && value_32 != 5008 && value_32 != 5009 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.variable_duration = value_32;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4041; {
                        value_33 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_33 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_33.* = st.variable_duration;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4042; {
                        value_34 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_34 > 1 || value_34 < 0 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.silk_mode.reduced_dependency = value_34;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4043; {
                        value_35 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_35 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            value_35.* = st.silk_mode.reduced_dependency;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4046; {
                        value_36 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_36 < 0 || value_36 > 1 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            if st.application != 2052 {
                                custom_encoder_ctl(celt_enc, 4046, value_36);
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4047; {
                        value_37 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_37 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            if st.application != 2052 {
                                custom_encoder_ctl(celt_enc, 4047, value_37 + (value_37 - value_37));
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            } else {
                                value_37.* = 0;
                                code_block_to_execute = 48;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4028; {
                        silk_enc = cast(*void) ((cast(*s8) st) + st.silk_enc_offset);
                        (cast,no_check(#type (_: *Tonality_Analysis_State)) (cast(*void) tonality_analysis_reset))(
                            *st.analysis
                        );
                        start = cast(*s8) *st.stream_channels;
                        fill_memory(
                            start,
                            0,
                            cast,no_check(u64) ((cast(s64) st.silk_enc_offset) - (start - cast(*s8) st))
                        );
                        if st.application != 2052 {
                            custom_encoder_ctl(celt_enc, 4028);
                            code_block_to_execute = 93;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 93;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 11002; {
                        value_38 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if (value_38 < 1000 || value_38 > 1002) && value_38 != -1000 {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            st.user_forced_mode = value_38;
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10024; {
                        value_39 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        st.lfe = value_39;
                        if st.application != 2052 {
                            ret = custom_encoder_ctl(celt_enc, 10024, value_39);
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 10026; {
                        value_40 = c_transpiler_va_arg(cast(*void) (ap.data), *Celt_Glog);
                        st.energy_masking = value_40;
                        if st.application != 2052 {
                            ret = custom_encoder_ctl(celt_enc, 10026, value_40 + (value_40 - value_40));
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4049; {
                        value_41 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_41 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            if st.silk_mode.use_dtx != 0 && (st.prev_mode == 1000 || st.prev_mode == 1001) {
                                silk_enc_2 = cast(*Silk_Encoder) (cast(*void) ((cast(*s8) st) + st.silk_enc_offset));
                                value_41.* = cast(Int32) (silk_enc_2.state_fxx[0].s_cmn.no_speech_counter >= 10);
                                if value_41.* == 1 && st.silk_mode.n_channels_internal == 2 && silk_enc_2.prev_decode_only_middle == 0 {
                                    value_41.* = cast(Int32) (silk_enc_2.state_fxx[1].s_cmn.no_speech_counter >= 10);
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                } else {
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                }
                            } else {
                                if st.use_dtx != 0 {
                                    value_41.* =
                                        cast(Int32) (st.nb_no_activity_ms_q1 >= (cast,no_check(s32) ((10 * 20))) *
                                            2);
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                } else {
                                    value_41.* = 0;
                                    code_block_to_execute = 48;
                                    continue c_transpiler_dispatch;
                                }
                            }
                        }
                    }
                    case cast(s32) 10015; {
                        value_42 = c_transpiler_va_arg(cast(*void) (ap.data), **Custom_Mode);
                        if value_42 == null {
                            code_block_to_execute = 46;
                            continue c_transpiler_dispatch;
                        } else {
                            ret = custom_encoder_ctl(celt_enc, 10015, value_42 + (value_42 - value_42));
                            code_block_to_execute = 48;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case; {
                        ret = -5;
                        code_block_to_execute = 48;
                        continue c_transpiler_dispatch;
                    }
                }
            }
            case 326; {
                celt_enc = null;
                ret = 0;
                start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
                if st.application != 2052 {
                    celt_enc = cast(*Custom_Encoder) ((cast(*s8) st) + st.celt_enc_offset);
                    code_block_to_execute = 319;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 319;
                    continue c_transpiler_dispatch;
                }
            }
        }
        assert(false, tprint("invalid code block to execute %", code_block_to_execute));
        break;
    }
    return unreachable_value(s32);
}

xcorr_kernel_c_in_opus_encoder :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_opus_encoder :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

realloc_in_opus_encoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_encoder :: (size: u64) -> *void {
    return alloc__in_opus_encoder(size);
}

fast_atan2f_in_opus_encoder :: (y: float32, x: float32) -> float32 {
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

celt_atan_norm_in_opus_encoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus_encoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus_encoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus_encoder(x / y);
    }
}

celt_cos_norm2_in_opus_encoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

silk_clz16_in_opus_encoder :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_opus_encoder :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

silk_ror32_in_opus_encoder :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_opus_encoder :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_opus_encoder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_opus_encoder :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_opus_encoder :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_opus_encoder :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_opus_encoder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_opus_encoder :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_opus_encoder :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_opus_encoder :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_opus_encoder(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_opus_encoder(in_upper);
    }
}

silk_clz_frac_in_opus_encoder :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_opus_encoder(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_opus_encoder(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_opus_encoder :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_opus_encoder(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_opus_encoder :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_opus_encoder((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_opus_encoder((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_opus_encoder :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_opus_encoder((ifx B32 > 0 then B32 else -B32)) - 1;
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

globals_initialization_state_for_opus_encoder: u32;
initialize_globals_for_opus_encoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_encoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_encoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_encoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_encoder =
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
    SPREAD_ICDF_in_opus_encoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_encoder = u8.[ 2, 1, 0 ];
    MONO_VOICE_BANDWIDTH_THRESHOLDS =
        Int32.[
            9000,
            700,
            9000,
            700,
            13500,
            1000,
            14000,
            2000
        ];
    MONO_MUSIC_BANDWIDTH_THRESHOLDS =
        Int32.[
            9000,
            700,
            9000,
            700,
            11000,
            1000,
            12000,
            2000
        ];
    STEREO_VOICE_BANDWIDTH_THRESHOLDS =
        Int32.[
            9000,
            700,
            9000,
            700,
            13500,
            1000,
            14000,
            2000
        ];
    STEREO_MUSIC_BANDWIDTH_THRESHOLDS =
        Int32.[
            9000,
            700,
            9000,
            700,
            11000,
            1000,
            12000,
            2000
        ];
    STEREO_VOICE_THRESHOLD = 19000;
    STEREO_MUSIC_THRESHOLD = 17000;
    MODE_THRESHOLDS =
        [2] Int32.[
            Int32.[ 64000, 10000 ],
            Int32.[ 44000, 10000 ]
        ];
    FEC_THRESHOLDS =
        Int32.[
            12000,
            1000,
            14000,
            1000,
            16000,
            1000,
            20000,
            1000,
            22000,
            1000
        ];
    RATE_TABLE =
        [5] s32.[
            s32.[ 0, 0, 0, 0, 0 ],
            s32.[ 12000, 10000, 10000, 11000, 11000 ],
            s32.[ 16000, 13500, 13500, 15000, 15000 ],
            s32.[ 20000, 16000, 16000, 18000, 18000 ],
            s32.[ 24000, 18000, 18000, 21000, 21000 ],
            s32.[ 32000, 22000, 22000, 28000, 28000 ],
            s32.[ 64000, 38000, 38000, 50000, 50000 ]
        ];
    atomic_store(*globals_initialization_state_for_opus_encoder, 2);
}

Downmix_Func :: #type (_: *void, _: *Val32, _: s32, _: s32, _: s32, _: s32, _: s32);

Tonality_Analysis_State :: struct {
    arch: s32;
    application: s32;
    fs: Int32;
    angle: [240] float32;
    d_angle: [240] float32;
    d2_angle: [240] float32;
    inmem: [720] Val32;
    mem_fill: s32;
    prev_band_tonality: [18] float32;
    prev_tonality: float32;
    prev_bandwidth: s32;
    e: [8] [18] float32;
    log_e: [8] [18] float32;
    low_e: [18] float32;
    high_e: [18] float32;
    mean_e: [19] float32;
    mem: [32] float32;
    cmean: [8] float32;
    std: [9] float32;
    etracker: float32;
    low_e_count: float32;
    e_count: s32;
    count: s32;
    analysis_offset: s32;
    write_pos: s32;
    read_pos: s32;
    read_subframe: s32;
    hp_ener_accum: float32;
    initialized: s32;
    rnn_state: [32] float32;
    downmix_state: [3] Val32;
    info: [100] Analysis_Info;
}

Repacketizer :: struct {
    toc: u8;
    nb_frames: s32;
    frames: [48] *u8;
    len: [48] Int16;
    framesize: s32;
    paddings: [48] *u8;
    padding_len: [48] Int32;
    padding_nb_frames: [48] u8;
}

Extension_Data :: struct {
    id: s32;
    frame: s32;
    data: *u8;
    len: Int32;
}

