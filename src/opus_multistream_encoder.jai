Vorbis_Layout :: struct {
    nb_streams: s32;
    nb_coupled_streams: s32;
    mapping: [8] u8;
}

VORBIS_MAPPINGS: [8] Vorbis_Layout;

DIFF_TABLE: [17] Celt_Glog;

TRIM_ICDF_in_opus_multistream_encoder: [11] u8;

SPREAD_ICDF_in_opus_multistream_encoder: [4] u8;

TAPSET_ICDF_in_opus_multistream_encoder: [3] u8;

multistream_encoder_get_size :: (nb_streams: s32, nb_coupled_streams: s32) -> Int32 {
    if nb_streams < 1 || nb_coupled_streams > nb_streams || nb_coupled_streams < 0 {
        return 0;
    }
    coupled_size := encoder_get_size(2);
    mono_size := encoder_get_size(1);
    return align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder))) + nb_coupled_streams * align_in_opus_multistream_encoder(coupled_size) + (nb_streams - nb_coupled_streams) * align_in_opus_multistream_encoder(mono_size);
}

align_in_opus_multistream_encoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

multistream_surround_encoder_get_size :: (channels: s32, mapping_family: s32) -> Int32 {
    nb_streams: s32 = ---;
    nb_coupled_streams: s32 = ---;

    if mapping_family == 0 {
        if channels == 1 {
            nb_streams = 1;
            nb_coupled_streams = 0;
        } else if channels == 2 {
            nb_streams = 1;
            nb_coupled_streams = 1;
        } else {
            return 0;
        }
    } else if mapping_family == 1 && channels <= 8 && channels >= 1 {
        nb_streams = VORBIS_MAPPINGS[channels - 1].nb_streams;
        nb_coupled_streams = VORBIS_MAPPINGS[channels - 1].nb_coupled_streams;
    } else if mapping_family == 255 {
        nb_streams = channels;
        nb_coupled_streams = 0;
    } else if mapping_family == 2 {
        if validate_ambisonics(channels, *nb_streams, *nb_coupled_streams) == 0 {
            return 0;
        }
    } else {
        return 0;
    }
    size := multistream_encoder_get_size(nb_streams, nb_coupled_streams);
    if channels > 2 {
        size = cast,no_check(Int32) ((cast,no_check(u64) size) + ((cast,no_check(u64) channels) * ((cast,no_check(u64) (120)) * size_of(Val32) + size_of(Val32))));
    }
    return size;
}

validate_ambisonics :: (nb_channels: s32, nb_streams: *s32, nb_coupled_streams: *s32) -> s32 {
    if nb_channels < 1 || nb_channels > 227 {
        return 0;
    }

    order_plus_one := cast,no_check(s32) isqrt32(cast,no_check(Uint32) nb_channels);
    acn_channels := order_plus_one * order_plus_one;
    nondiegetic_channels := nb_channels - acn_channels;

    if nondiegetic_channels != 0 && nondiegetic_channels != 2 {
        return 0;
    }

    if nb_streams != null {
        nb_streams.* = acn_channels + cast(s32) (nondiegetic_channels != 0);
    }
    if nb_coupled_streams != null {
        nb_coupled_streams.* = cast(s32) (nondiegetic_channels != 0);
    }
    return 1;
}

multistream_encoder_create :: (
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    mapping: *u8,
    application: s32,
    error: *s32
) -> *MS_Encoder {
    if channels > 255 ||
        channels < 1 ||
        coupled_streams > streams ||
        streams < 1 ||
        coupled_streams < 0 ||
        streams > 255 - coupled_streams ||
        streams + coupled_streams > channels {
        if error != null {
            error.* = -1;
        }
        return null;
    }
    size := multistream_encoder_init(null, fs, channels, streams, coupled_streams, mapping, application);
    if size < 0 {
        if error != null {
            error.* = size;
        }
        return null;
    }
    st := cast(*MS_Encoder) alloc__in_opus_multistream_encoder(cast,no_check(u64) size);
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret := multistream_encoder_init(st, fs, channels, streams, coupled_streams, mapping, application);
    if ret != 0 {
        free__in_opus_multistream_encoder(cast(*void) st);
        st = null;
    }
    if error != null {
        error.* = ret;
    }
    return st;
}

free__in_opus_multistream_encoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

multistream_encoder_init :: (
    st: *MS_Encoder,
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    mapping: *u8,
    application: s32
) -> s32 {
    return multistream_encoder_init_impl(
        st,
        fs,
        channels,
        streams,
        coupled_streams,
        mapping,
        application,
        cast,no_check(Mapping_Type) MAPPING_TYPE_NONE
    );
}

multistream_encoder_init_impl :: (
    st: *MS_Encoder,
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    mapping: *u8,
    application: s32,
    mapping_type: Mapping_Type
) -> s32 {
    ret: s32 = ---;

    if channels > 255 ||
        channels < 1 ||
        coupled_streams > streams ||
        streams < 1 ||
        coupled_streams < 0 ||
        streams > 255 - coupled_streams ||
        streams + coupled_streams > channels {
        return -1;
    }

    coupled_size := encoder_init(null, fs, 2, application);
    if coupled_size < 0 {
        return coupled_size;
    }
    mono_size := encoder_init(null, fs, 1, application);
    if mono_size < 0 {
        return mono_size;
    }
    if st == null {
        surround_size: s32 = 0;
        if mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND {
            surround_size =
                cast,no_check(s32) ((cast,no_check(u64) channels) *
                    ((cast,no_check(u64) (120)) * size_of(Val32) + size_of(Val32)));
        }

        return align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder))) + coupled_streams * align_in_opus_multistream_encoder(coupled_size) + (streams - coupled_streams) * align_in_opus_multistream_encoder(mono_size) + surround_size;
    }

    st.arch = select_arch_in_opus_multistream_encoder();
    st.layout.nb_channels = channels;
    st.layout.nb_streams = streams;
    st.layout.nb_coupled_streams = coupled_streams;
    if mapping_type != cast,no_check(u32) MAPPING_TYPE_SURROUND {
        st.lfe_stream = -1;
    }
    st.bitrate_bps = -1000;
    st.application = application;
    st.fs = fs;
    st.variable_duration = 5000;
    i: s32 = 0;
    while i < st.layout.nb_channels {
        st.layout.mapping[i] = mapping[i];
        i += 1;
    }
    if validate_layout(*st.layout) == 0 {
        return -1;
    }
    if validate_encoder_layout(*st.layout) == 0 {
        return -1;
    }
    if mapping_type == cast,no_check(u32) MAPPING_TYPE_AMBISONICS &&
        validate_ambisonics(st.layout.nb_channels, null, null) == 0 {
        return -1;
    }
    ptr := (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    i = 0;
    while i < st.layout.nb_coupled_streams {
        ret = encoder_init(cast(*Encoder) ptr, fs, 2, application);
        if ret != 0 {
            return ret;
        }
        if i == st.lfe_stream {
            encoder_ctl(cast(*Encoder) ptr, 10024, cast(s32) 1);
        }
        ptr += align_in_opus_multistream_encoder(coupled_size);
        i += 1;
    }
    while i < st.layout.nb_streams {
        ret = encoder_init(cast(*Encoder) ptr, fs, 1, application);
        if ret != 0 {
            return ret;
        }
        if i == st.lfe_stream {
            encoder_ctl(cast(*Encoder) ptr, 10024, cast(s32) 1);
        }
        ptr += align_in_opus_multistream_encoder(mono_size);
        i += 1;
    }
    if mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND {
        fill_memory(ms_get_preemph_mem(st), 0, cast,no_check(u64) channels * size_of(Val32));
        fill_memory(ms_get_window_mem(st), 0, cast,no_check(u64) (channels * 120) * size_of(Val32));
    }
    st.mapping_type = mapping_type;
    return 0;
}

ms_get_window_mem :: (st: *MS_Encoder) -> *Val32 {
    coupled_size: s32 = ---;

    coupled_size = encoder_init(null, st.fs, 2, st.application);
    mono_size := encoder_init(null, st.fs, 1, st.application);
    ptr := (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    s: s32 = 0;
    while s < st.layout.nb_streams {
        if s < st.layout.nb_coupled_streams {
            ptr += align_in_opus_multistream_encoder(coupled_size);
        } else {
            ptr += align_in_opus_multistream_encoder(mono_size);
        }
        s += 1;
    }

    return cast(*Val32) (cast(*void) ptr);
}

ms_get_preemph_mem :: (st: *MS_Encoder) -> *Val32 {
    coupled_size: s32 = ---;

    coupled_size = encoder_init(null, st.fs, 2, st.application);
    mono_size := encoder_init(null, st.fs, 1, st.application);
    ptr := (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    s: s32 = 0;
    while s < st.layout.nb_streams {
        if s < st.layout.nb_coupled_streams {
            ptr += align_in_opus_multistream_encoder(coupled_size);
        } else {
            ptr += align_in_opus_multistream_encoder(mono_size);
        }
        s += 1;
    }

    return cast(*Val32) (cast(*void) (ptr + (cast,no_check(u64) (st.layout.nb_channels * 120)) * size_of(Val32)));
}

validate_encoder_layout :: (layout: *Channel_Layout) -> s32 {
    s: s32 = 0;
    while s < layout.nb_streams {
        if s < layout.nb_coupled_streams {
            if get_left_channel(layout, s, -1) == -1 {
                return 0;
            }
            if get_right_channel(layout, s, -1) == -1 {
                return 0;
            }
        } else if get_mono_channel(layout, s, -1) == -1 {
            return 0;
        }
        s += 1;
    }
    return 1;
}

select_arch_in_opus_multistream_encoder :: () -> s32 {
    return 0;
}

alloc__in_opus_multistream_encoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

multistream_surround_encoder_create :: (
    fs: Int32,
    channels: s32,
    mapping_family: s32,
    streams: *s32,
    coupled_streams: *s32,
    mapping: *u8,
    application: s32,
    error: *s32
) -> *MS_Encoder {
    if channels > 255 || channels < 1 {
        if error != null {
            error.* = -1;
        }
        return null;
    }
    size :=
        multistream_surround_encoder_init(
            null,
            fs,
            channels,
            mapping_family,
            streams,
            coupled_streams,
            mapping,
            application
        );
    if size < 0 {
        if error != null {
            error.* = size;
        }
        return null;
    }
    st := cast(*MS_Encoder) alloc__in_opus_multistream_encoder(cast,no_check(u64) size);
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret :=
        multistream_surround_encoder_init(
            st,
            fs,
            channels,
            mapping_family,
            streams,
            coupled_streams,
            mapping,
            application
        );
    if ret != 0 {
        free__in_opus_multistream_encoder(cast(*void) st);
        st = null;
    }
    if error != null {
        error.* = ret;
    }
    return st;
}

multistream_surround_encoder_init :: (
    st: *MS_Encoder,
    fs: Int32,
    channels: s32,
    mapping_family: s32,
    streams: *s32,
    coupled_streams: *s32,
    mapping: *u8,
    application: s32
) -> s32 {
    if channels > 255 || channels < 1 {
        return -1;
    }
    lfe_stream: s32 = -1;
    if mapping_family == 0 {
        if channels == 1 {
            streams.* = 1;
            coupled_streams.* = 0;
            mapping[0] = 0;
        } else if channels == 2 {
            streams.* = 1;
            coupled_streams.* = 1;
            mapping[0] = 0;
            mapping[1] = 1;
        } else {
            return -5;
        }
    } else if mapping_family == 1 && channels <= 8 && channels >= 1 {
        streams.* = VORBIS_MAPPINGS[channels - 1].nb_streams;
        coupled_streams.* = VORBIS_MAPPINGS[channels - 1].nb_coupled_streams;
        if 0 < channels {
            for i: 0..channels - 1 {
                mapping[i] = VORBIS_MAPPINGS[channels - 1].mapping[i];
            }
        }
        if channels >= 6 {
            lfe_stream = streams.* - 1;
        }
    } else if mapping_family == 255 {
        streams.* = channels;
        coupled_streams.* = 0;
        if 0 < channels {
            for i: 0..channels - 1 {
                mapping[i] = cast,no_check(u8) i;
            }
        }
    } else if mapping_family == 2 {
        if validate_ambisonics(channels, streams, coupled_streams) == 0 {
            return -1;
        }
        i: s32 = 0;
        while i < streams.* - coupled_streams.* {
            mapping[i] = cast,no_check(u8) (i + coupled_streams.* * 2);
            i += 1;
        }
        i = 0;
        while i < coupled_streams.* * 2 {
            mapping[i + (streams.* - coupled_streams.*)] = cast,no_check(u8) i;
            i += 1;
        }
    } else {
        return -5;
    }

    mapping_type: Mapping_Type = ifx channels > 2 && mapping_family == 1
        then cast,no_check(Mapping_Type) MAPPING_TYPE_SURROUND
        else ifx mapping_family == 2
            then cast,no_check(Mapping_Type) MAPPING_TYPE_AMBISONICS
            else cast,no_check(Mapping_Type) MAPPING_TYPE_NONE;
    if st != null {
        st.lfe_stream = lfe_stream;
    }
    return multistream_encoder_init_impl(st, fs, channels, streams.*, coupled_streams.*, mapping, application, mapping_type);
}

multistream_encode :: (st: *MS_Encoder, pcm: *Int16, frame_size: s32, data: *u8, max_data_bytes: Int32) -> s32 {
    return multistream_encode_native(
        st,
        cast,no_check(Copy_Channel_In_Func) copy_channel_in_short,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        16,
        cast,no_check(Downmix_Func) downmix_int,
        0,
        null
    );
}

copy_channel_in_short :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    short_src := cast(*Int16) src;
    i: Int32 = 0;
    while i < frame_size {
        dst[i * dst_stride] =
            (cast,no_check(float32) short_src[i * src_stride + src_channel]) *
                cast(float32) 0.000030517578125;
        i += 1;
    }
}

multistream_encode_native :: (
    st: *MS_Encoder,
    copy_channel_in: Copy_Channel_In_Func,
    pcm: *void,
    analysis_frame_size: s32,
    data: *u8,
    max_data_bytes: Int32,
    lsb_depth: s32,
    downmix: Downmix_Func,
    float_api: s32,
    user_data: *void
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    fs: Int32 = ---;

    tmp_data: [7662] u8 = ---;
    rp: Repacketizer = ---;
    vbr: Int32 = ---;
    celt_mode: *Custom_Mode = null;
    bitrates: [256] Int32 = ---;
    band_log_e: [42] Celt_Glog = ---;
    mem: *Val32 = null;
    preemph_mem: *Val32 = null;

    if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND {
        preemph_mem = ms_get_preemph_mem(st);
        mem = ms_get_window_mem(st);
    }

    ptr := (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    encoder_ctl(cast(*Encoder) ptr, 4029, *fs + (*fs - *fs));
    encoder_ctl(cast(*Encoder) ptr, 4007, *vbr + (*vbr - *vbr));
    if st.application != 2052 {
        encoder_ctl(cast(*Encoder) ptr, 10015, *celt_mode + (*celt_mode - *celt_mode));
    }

    frame_size := frame_size_select(st.application, analysis_frame_size, st.variable_duration, fs);
    if frame_size <= 0 {
        return -1;
    }

    smallest_packet := st.layout.nb_streams * 2 - 1;

    if fs / frame_size == 10 {
        smallest_packet = cast,no_check(Int32) (smallest_packet + st.layout.nb_streams);
    }
    if max_data_bytes < smallest_packet {
        return -2;
    }
    buf := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (2 * frame_size))));
    coupled_size := encoder_init(null, st.fs, 2, st.application);
    mono_size := encoder_init(null, st.fs, 1, st.application);

    band_smr :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (21 * st.layout.nb_channels))));
    if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND && st.application != 2052 {
        surround_analysis(
            celt_mode,
            pcm,
            band_smr,
            mem,
            preemph_mem,
            frame_size,
            celt_mode.overlap,
            st.layout.nb_channels,
            fs,
            cast,no_check(Copy_Channel_In_Func) (copy_channel_in),
            st.arch
        );
    }

    rate_sum := rate_allocation(st, bitrates.data, frame_size);

    if vbr == 0 {
        if st.bitrate_bps == -1000 {
            max_data_bytes =
                ifx max_data_bytes < (bitrate_to_bits_in_opus_multistream_encoder(rate_sum, fs, frame_size) + 4) /
                    8 then max_data_bytes else (bitrate_to_bits_in_opus_multistream_encoder(rate_sum, fs, frame_size) + 4) / 8;
        } else if st.bitrate_bps != -1 {
            max_data_bytes =
                ifx max_data_bytes < (ifx smallest_packet > (bitrate_to_bits_in_opus_multistream_encoder(st.bitrate_bps, fs, frame_size) + 4) / 8 then smallest_packet else (bitrate_to_bits_in_opus_multistream_encoder(st.bitrate_bps, fs, frame_size) + 4) /
                    8) then max_data_bytes else (ifx smallest_packet > (bitrate_to_bits_in_opus_multistream_encoder(st.bitrate_bps, fs, frame_size) + 4) / 8 then smallest_packet else (bitrate_to_bits_in_opus_multistream_encoder(st.bitrate_bps, fs, frame_size) + 4) / 8);
        }
    }
    ptr = (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    s: s32 = 0;
    while s < st.layout.nb_streams {
        enc := cast(*Encoder) ptr;
        if s < st.layout.nb_coupled_streams {
            ptr += align_in_opus_multistream_encoder(coupled_size);
        } else {
            ptr += align_in_opus_multistream_encoder(mono_size);
        }
        encoder_ctl(enc, 4002, (ifx true { ((bitrates[s] == cast(s32) 0)); (bitrates[s]); }));
        if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND {
            equiv_rate := st.bitrate_bps;
            if frame_size * 50 < fs {
                equiv_rate = cast,no_check(Int32) (equiv_rate - (60 * (fs / frame_size - 50) * st.layout.nb_channels));
            }
            if equiv_rate > 10000 * st.layout.nb_channels {
                encoder_ctl(enc, 4008, cast(s32) 1105);
            } else if equiv_rate > 7000 * st.layout.nb_channels {
                encoder_ctl(enc, 4008, cast(s32) 1104);
            } else if equiv_rate > 5000 * st.layout.nb_channels {
                encoder_ctl(enc, 4008, cast(s32) 1103);
            } else {
                encoder_ctl(enc, 4008, cast(s32) 1101);
            }
            if s < st.layout.nb_coupled_streams {
                encoder_ctl(enc, 11002, cast(s32) 1002);
                encoder_ctl(enc, 4022, cast(s32) 2);
            }
        } else if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_AMBISONICS {
            encoder_ctl(enc, 11002, cast(s32) 1002);
        }
        s += 1;
    }

    ptr = (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));

    tot_size: s32 = 0;
    s = 0;
    while s < st.layout.nb_streams {
        c1, c2: s32 = ---;

        repacketizer_init(*rp);
        enc := cast(*Encoder) ptr;
        if s < st.layout.nb_coupled_streams {
            left: s32 = ---;
            left = get_left_channel(*st.layout, s, -1);
            right := get_right_channel(*st.layout, s, -1);
            (cast,no_check(#type (_: *Res, _: s32, _: *void, _: s32, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_in)))(
                buf,
                2,
                pcm,
                st.layout.nb_channels,
                left,
                frame_size,
                user_data
            );
            (cast,no_check(#type (_: *Res, _: s32, _: *void, _: s32, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_in)))(
                buf + 1,
                2,
                pcm,
                st.layout.nb_channels,
                right,
                frame_size,
                user_data
            );
            ptr += align_in_opus_multistream_encoder(coupled_size);
            if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND && st.application != 2052 {
                for i: 0..cast(s32) 21 - 1 {
                    band_log_e[i] = band_smr[21 * left + i];
                    band_log_e[21 + i] = band_smr[21 * right + i];
                }
            }
            c1 = left;
            c2 = right;
        } else {
            chan := get_mono_channel(*st.layout, s, -1);
            (cast,no_check(#type (_: *Res, _: s32, _: *void, _: s32, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_in)))(
                buf,
                1,
                pcm,
                st.layout.nb_channels,
                chan,
                frame_size,
                user_data
            );
            ptr += align_in_opus_multistream_encoder(mono_size);
            if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND && st.application != 2052 {
                for i: 0..cast(s32) 21 - 1 {
                    band_log_e[i] = band_smr[21 * chan + i];
                }
            }
            c1 = chan;
            c2 = -1;
        }
        if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND && st.application != 2052 {
            encoder_ctl(enc, 10026, band_log_e.data + (band_log_e.data - band_log_e.data));
        }

        curr_max := max_data_bytes - tot_size;

        curr_max -= (ifx 0 > 2 * (st.layout.nb_streams - s - 1) - 1 then 0 else 2 * (st.layout.nb_streams - s - 1) - 1);

        if fs / frame_size == 10 {
            curr_max -= st.layout.nb_streams - s - 1;
        }
        curr_max =
            ifx curr_max < (cast,no_check(s32) ((6 * 1275))) +
                12 then curr_max else (cast,no_check(s32) ((6 * 1275))) + 12;

        if s != st.layout.nb_streams - 1 {
            curr_max -= (ifx curr_max > 253 then cast(s32) 2 else 1);
        }
        if vbr == 0 && s == st.layout.nb_streams - 1 {
            encoder_ctl(
                enc,
                4002,
                (ifx true { ((bits_to_bitrate_in_opus_multistream_encoder(curr_max * 8, fs, frame_size) == cast(s32) 0)); (bits_to_bitrate_in_opus_multistream_encoder(curr_max *
                8, fs, frame_size)); })
            );
        }
        len :=
            encode_native(
                enc,
                buf,
                frame_size,
                tmp_data.data,
                curr_max,
                lsb_depth,
                pcm,
                analysis_frame_size,
                c1,
                c2,
                st.layout.nb_channels,
                cast,no_check(Downmix_Func) (downmix),
                float_api
            );
        if len < 0 {
            return len;
        }

        ret := repacketizer_cat(*rp, tmp_data.data, len);

        if ret != 0 {
            return -3;
        }
        len =
            (cast,no_check(#type (_: *Repacketizer, _: s32, _: s32, _: *u8, _: Int32, _: s32, _: s32, _: *Extension_Data, _: s32) -> Int32) (cast(*void) repacketizer_out_range_impl))(
                *rp,
                0,
                repacketizer_get_nb_frames(*rp),
                data,
                max_data_bytes - tot_size,
                cast(s32) (s != st.layout.nb_streams - 1),
                cast(s32) (vbr == 0 && s == st.layout.nb_streams - 1),
                null,
                0
            );
        data += len;
        tot_size += len;
        s += 1;
    }

    return tot_size;
}

bits_to_bitrate_in_opus_multistream_encoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_multistream_encoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

rate_allocation :: (st: *MS_Encoder, rate: *Int32, frame_size: s32) -> Int32 {
    rate_sum: Int32 = 0;
    fs: Int32 = ---;
    ptr := (cast(*s8) st) + align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
    encoder_ctl(cast(*Encoder) ptr, 4029, *fs + (*fs - *fs));

    if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_AMBISONICS {
        ambisonics_rate_allocation(st, rate, frame_size, fs);
    } else {
        surround_rate_allocation(st, rate, frame_size, fs);
    }

    i: s32 = 0;
    while i < st.layout.nb_streams {
        rate[i] = ifx rate[i] > 500 then rate[i] else 500;
        rate_sum += rate[i];
        i += 1;
    }
    return rate_sum;
}

surround_rate_allocation :: (st: *MS_Encoder, rate: *Int32, frame_size: s32, fs: Int32) {
    nb_lfe := cast(s32) (st.lfe_stream != -1);
    nb_coupled := st.layout.nb_coupled_streams;
    nb_uncoupled := st.layout.nb_streams - nb_coupled - nb_lfe;
    nb_normal := 2 * nb_coupled + nb_uncoupled;

    channel_offset := 40 * (ifx 50 > fs / frame_size then 50 else fs / frame_size);

    bitrate: Int32 = ifx st.bitrate_bps == -1000
        then nb_normal * (channel_offset + fs + 10000) + 8000 * nb_lfe
        else ifx st.bitrate_bps == -1
            then nb_normal * 750000 + nb_lfe * 128000
            else st.bitrate_bps;

    lfe_offset :=
        (ifx bitrate / 20 < 3000 then bitrate / 20 else 3000) +
            15 * (ifx 50 > fs / frame_size then 50 else fs / frame_size);

    stream_offset := (bitrate - channel_offset * nb_normal - lfe_offset * nb_lfe) / nb_normal / 2;
    stream_offset =
        ifx 0 > (ifx 20000 < stream_offset then 20000 else stream_offset) then 0 else (ifx 20000 < stream_offset then 20000 else stream_offset);

    coupled_ratio: s32 = 512;

    lfe_ratio: s32 = 32;

    total := nb_uncoupled << 8 + coupled_ratio * nb_coupled + nb_lfe * lfe_ratio;
    channel_rate :=
        cast,no_check(Int32) ((256 * cast,no_check(Int64) (bitrate - lfe_offset * nb_lfe - stream_offset * (nb_coupled + nb_uncoupled) - channel_offset * nb_normal)) /
            cast(Int64) total);

    i: s32 = 0;
    while i < st.layout.nb_streams {
        if i < st.layout.nb_coupled_streams {
            rate[i] =
                2 * channel_offset +
                    (ifx 0 > stream_offset + (channel_rate * coupled_ratio) >> 8 then 0 else stream_offset + (channel_rate * coupled_ratio) >> 8);
        } else if i != st.lfe_stream {
            rate[i] = channel_offset + (ifx 0 > stream_offset + channel_rate then 0 else stream_offset + channel_rate);
        } else {
            rate[i] =
                ifx 0 > lfe_offset + (channel_rate * lfe_ratio) >> 8 then 0 else lfe_offset +
                    (channel_rate * lfe_ratio) >> 8;
        }
        i += 1;
    }
}

ambisonics_rate_allocation :: (st: *MS_Encoder, rate: *Int32, frame_size: s32, fs: Int32) {
    NB_CHANNELS := st.layout.nb_streams + st.layout.nb_coupled_streams;

    total_rate: Int32 = ifx st.bitrate_bps == -1000
        then (st.layout.nb_coupled_streams + st.layout.nb_streams) * (fs + 60 * fs / frame_size) + st.layout.nb_streams * cast(s32) 15000
        else ifx st.bitrate_bps == -1
            then NB_CHANNELS * 750000
            else st.bitrate_bps;

    per_stream_rate := total_rate / st.layout.nb_streams;
    i: s32 = 0;
    while i < st.layout.nb_streams {
        rate[i] = per_stream_rate;
        i += 1;
    }
}

surround_analysis :: (
    celt_mode: *Custom_Mode,
    pcm: *void,
    band_log_e: *Celt_Glog,
    mem: *Val32,
    preemph_mem: *Val32,
    len: s32,
    overlap: s32,
    channels: s32,
    rate: s32,
    copy_channel_in: Copy_Channel_In_Func,
    arch: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;

    pos: [8] s32;

    band_e: [21] Val32 = ---;
    mask_log_e: [3] [21] Celt_Glog = ---;

    upsample := resampling_factor(rate);
    frame_size := len * upsample;

    lm: s32 = 0;
    while lm < celt_mode.max_lm {
        if celt_mode.short_mdct_size << ((lm) & 31) == frame_size {
            break;
        }
        lm += 1;
    }

    freq_size := celt_mode.short_mdct_size << ((lm) & 31);

    in := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) (frame_size + overlap))));
    x := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) len)));
    freq := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) freq_size)));

    channel_pos(channels, pos.data);

    for c: 0..cast(s32) 3 - 1 {
        i = 0;
        while i < 21 {
            mask_log_e[c][i] = -28.0;
            i += 1;
        }
    }

    if 0 < channels {
        for c: 0..channels - 1 {
            nb_frames := frame_size / freq_size;
            (nb_frames * freq_size == frame_size);
            copy_memory(
                in,
                mem + c * overlap,
                (cast,no_check(u64) overlap) * size_of(Val32) + cast,no_check(u64) (0 * (in - (mem + c * overlap)))
            );
            (cast,no_check(#type (_: *Res, _: s32, _: *void, _: s32, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_in)))(
                x,
                1,
                pcm,
                channels,
                c,
                len,
                null
            );
            celt_preemphasis(x, in + overlap, frame_size, 1, upsample, celt_mode.preemph.data, preemph_mem + c, 0);

            {
                sum := celt_inner_prod_c_in_opus_multistream_encoder(in, in, frame_size + overlap);

                if !(c_transpiler_float_less(sum, 1.0e18)) || c_transpiler_float_not_equal(sum, sum) {
                    fill_memory(in, 0, cast,no_check(u64) (frame_size + overlap) * size_of(Val32));
                    preemph_mem[c] = 0.0;
                }
            }

            fill_memory(band_e.data, 0, cast(u64) 21 * size_of(Val32));
            if 0 < nb_frames {
                for frame: 0..nb_frames - 1 {
                    tmp_e: [21] Val32 = ---;
                    clt_mdct_forward_c(
                        *celt_mode.mdct,
                        in + freq_size * frame,
                        freq,
                        celt_mode.window,
                        overlap,
                        celt_mode.max_lm - lm,
                        1,
                        arch
                    );
                    if upsample != 1 {
                        bound := freq_size / upsample;
                        i = 0;
                        while i < bound {
                            freq[i] *= cast,no_check(Val32) upsample;
                            i += 1;
                        }
                        while i < freq_size {
                            freq[i] = 0.0;
                            i += 1;
                        }
                    }

                    compute_band_energies(celt_mode, freq, tmp_e.data, 21, 1, lm, arch);

                    i = 0;
                    while i < 21 {
                        band_e[i] = ifx c_transpiler_float_greater(band_e[i], tmp_e[i]) then band_e[i] else tmp_e[i];
                        i += 1;
                    }
                }
            }
            amp2_log2(celt_mode, 21, 21, band_e.data, band_log_e + 21 * c, 1);

            i = 1;
            while i < 21 {
                band_log_e[21 * c + i] =
                    ifx c_transpiler_float_greater(band_log_e[21 * c + i], (band_log_e[21 * c + i - 1] - 1.0)) then band_log_e[21 * c + i] else band_log_e[21 * c + i - 1] -
                        1.0;
                i += 1;
            }
            i = 19;
            while i >= 0 {
                band_log_e[21 * c + i] =
                    ifx c_transpiler_float_greater(band_log_e[21 * c + i], (band_log_e[21 * c + i + 1] - 2.0)) then band_log_e[21 * c + i] else band_log_e[21 * c + i + 1] -
                        2.0;
                i -= 1;
            }
            if pos[c] == 1 {
                i = 0;
                while i < 21 {
                    mask_log_e[0][i] = log_sum(mask_log_e[0][i], band_log_e[21 * c + i]);
                    i += 1;
                }
            } else if pos[c] == 3 {
                i = 0;
                while i < 21 {
                    mask_log_e[2][i] = log_sum(mask_log_e[2][i], band_log_e[21 * c + i]);
                    i += 1;
                }
            } else if pos[c] == 2 {
                i = 0;
                while i < 21 {
                    mask_log_e[0][i] = log_sum(mask_log_e[0][i], band_log_e[21 * c + i] - 0.5);
                    mask_log_e[2][i] = log_sum(mask_log_e[2][i], band_log_e[21 * c + i] - 0.5);
                    i += 1;
                }
            }

            copy_memory(
                mem + c * overlap,
                in + frame_size,
                (cast,no_check(u64) overlap) * size_of(Val32) +
                cast,no_check(u64) (0 * (mem + c * overlap - (in + frame_size)))
            );
        }
    }
    i = 0;
    while i < 21 {
        mask_log_e[1][i] =
            ifx c_transpiler_float_less(mask_log_e[0][i], mask_log_e[2][i]) then mask_log_e[0][i] else mask_log_e[2][i];
        i += 1;
    }
    channel_offset :=
        0.5 *
            cast,no_check(float32) (1.4426950408889634 * c_transpiler_math_log(cast,no_check(float64) (2.0 / cast,no_check(float32) (channels - 1))));
    for c: 0..cast(s32) 3 - 1 {
        i = 0;
        while i < 21 {
            mask_log_e[c][i] += channel_offset;
            i += 1;
        }
    }

    if 0 < channels {
        for c: 0..channels - 1 {
            mask: *Celt_Glog = ---;
            if pos[c] != 0 {
                mask = mask_log_e[pos[c] - 1].data + 0;
                i = 0;
                while i < 21 {
                    band_log_e[21 * c + i] = band_log_e[21 * c + i] - mask[i];
                    i += 1;
                }
            } else {
                i = 0;
                while i < 21 {
                    band_log_e[21 * c + i] = 0.0;
                    i += 1;
                }
            }
        }
    }
}

log_sum :: (a: Celt_Glog, b: Celt_Glog) -> Val16 {
    max: Celt_Glog = ---;
    diff: Celt_Glog = ---;


    if c_transpiler_float_greater(a, b) {
        max = a;
        diff = a - b;
    } else {
        max = b;
        diff = b - a;
    }
    if !(c_transpiler_float_less(diff, 8.0)) {
        return max;
    }

    low := cast,no_check(s32) floor(cast,no_check(float64) (2.0 * diff));
    frac := 2.0 * diff - low;

    return max + DIFF_TABLE[low] + frac * (DIFF_TABLE[low + 1] - DIFF_TABLE[low]);
}

celt_inner_prod_c_in_opus_multistream_encoder :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

channel_pos :: (channels: s32, pos: *s32) {
    if channels == 4 {
        pos[0] = 1;
        pos[1] = 3;
        pos[2] = 1;
        pos[3] = 3;
    } else if channels == 3 || channels == 5 || channels == 6 {
        pos[0] = 1;
        pos[1] = 2;
        pos[2] = 3;
        pos[3] = 1;
        pos[4] = 3;
        pos[5] = 0;
    } else if channels == 7 {
        pos[0] = 1;
        pos[1] = 2;
        pos[2] = 3;
        pos[3] = 1;
        pos[4] = 3;
        pos[5] = 2;
        pos[6] = 0;
    } else if channels == 8 {
        pos[0] = 1;
        pos[1] = 2;
        pos[2] = 3;
        pos[3] = 1;
        pos[4] = 3;
        pos[5] = 1;
        pos[6] = 3;
        pos[7] = 0;
    }
}

multistream_encode24 :: (st: *MS_Encoder, pcm: *Int32, frame_size: s32, data: *u8, max_data_bytes: Int32) -> s32 {
    return multistream_encode_native(
        st,
        cast,no_check(Copy_Channel_In_Func) copy_channel_in_int24,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        24,
        cast,no_check(Downmix_Func) downmix_int24,
        0,
        null
    );
}

copy_channel_in_int24 :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    short_src := cast(*Int32) src;
    i: Int32 = 0;
    while i < frame_size {
        dst[i * dst_stride] =
            (cast(float32) 1.1920928955078126e-7) *
                cast,no_check(float32) short_src[i * src_stride + src_channel];
        i += 1;
    }
}

multistream_encode_float :: (st: *MS_Encoder, pcm: *float32, frame_size: s32, data: *u8, max_data_bytes: Int32) -> s32 {
    return multistream_encode_native(
        st,
        cast,no_check(Copy_Channel_In_Func) copy_channel_in_float,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        24,
        cast,no_check(Downmix_Func) downmix_float,
        1,
        null
    );
}

copy_channel_in_float :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    float_src := cast(*float32) src;
    i: Int32 = 0;
    while i < frame_size {
        dst[i * dst_stride] = float_src[i * src_stride + src_channel];
        i += 1;
    }
}

multistream_encoder_destroy :: (st: *MS_Encoder) {
    free__in_opus_multistream_encoder(cast(*void) st);
}

multistream_encoder_ctl :: (st: *MS_Encoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ap: Va_List = ---;
    start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
    ret := multistream_encoder_ctl_va_list(st, request, ap.data);
    return ret;
}

multistream_encoder_ctl_va_list :: (st: *MS_Encoder, request: s32, ap: *Va_List_Tag) -> s32 {
    coupled_size: s32 = ---;
    mono_size: s32 = ---;
    ptr: *s8 = ---;
    ret: s32 = ---;
    value: Int32 = ---;
    s: s32 = ---;
    value_2: *Int32 = ---;
    rate: Int32 = ---;
    enc: *Encoder = ---;
    enc_2: *Encoder = ---;
    value_3: *Int32 = ---;
    s_2: s32 = ---;
    value_4: *Uint32 = ---;
    tmp: Uint32 = ---;
    enc_3: *Encoder = ---;
    s_3: s32 = ---;
    value_5: Int32 = ---;
    enc_4: *Encoder = ---;
    s_4: s32 = ---;
    stream_id: Int32 = ---;
    value_6: **Encoder = ---;
    value_7: Int32 = ---;
    value_8: *Int32 = ---;
    s_5: s32 = ---;
    enc_5: *Encoder = ---;
    code_block_to_execute: s64 = 155;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 42; {
                return -1;
            }
            case 43; {
                return ret;
            }
            case 47; {
                if s_5 < st.layout.nb_streams {
                    code_block_to_execute = 56;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                }
            }
            case 51; {
                ret = encoder_ctl(enc_5, 4028);
                if ret != 0 {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                } else {
                    s_5 += 1;
                    code_block_to_execute = 47;
                    continue c_transpiler_dispatch;
                }
            }
            case 56; {
                enc_5 = cast(*Encoder) ptr;
                if s_5 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_encoder(coupled_size);
                    code_block_to_execute = 51;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_encoder(mono_size);
                    code_block_to_execute = 51;
                    continue c_transpiler_dispatch;
                }
            }
            case 57; {
                s_5 = 0;
                code_block_to_execute = 47;
                continue c_transpiler_dispatch;
            }
            case 72; {
                if s_4 < stream_id {
                    code_block_to_execute = 76;
                    continue c_transpiler_dispatch;
                } else {
                    value_6.* = cast(*Encoder) ptr;
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                }
            }
            case 73; {
                s_4 += 1;
                code_block_to_execute = 72;
                continue c_transpiler_dispatch;
            }
            case 76; {
                if s_4 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_encoder(coupled_size);
                    code_block_to_execute = 73;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_encoder(mono_size);
                    code_block_to_execute = 73;
                    continue c_transpiler_dispatch;
                }
            }
            case 88; {
                if s_3 < st.layout.nb_streams {
                    code_block_to_execute = 97;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                }
            }
            case 92; {
                ret = encoder_ctl(enc_4, request, value_5);
                if ret != 0 {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                } else {
                    s_3 += 1;
                    code_block_to_execute = 88;
                    continue c_transpiler_dispatch;
                }
            }
            case 97; {
                enc_4 = cast(*Encoder) ptr;
                if s_3 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_encoder(coupled_size);
                    code_block_to_execute = 92;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_encoder(mono_size);
                    code_block_to_execute = 92;
                    continue c_transpiler_dispatch;
                }
            }
            case 100; {
                value_5 = c_transpiler_va_arg(cast(*void) (ap), Int32);
                s_3 = 0;
                code_block_to_execute = 88;
                continue c_transpiler_dispatch;
            }
            case 102; {
                if s_2 < st.layout.nb_streams {
                    code_block_to_execute = 112;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                }
            }
            case 107; {
                ret = encoder_ctl(enc_3, request, *tmp);
                if ret != 0 {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                } else {
                    value_4.* ^= tmp;
                    s_2 += 1;
                    code_block_to_execute = 102;
                    continue c_transpiler_dispatch;
                }
            }
            case 112; {
                enc_3 = cast(*Encoder) ptr;
                if s_2 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_encoder(coupled_size);
                    code_block_to_execute = 107;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_encoder(mono_size);
                    code_block_to_execute = 107;
                    continue c_transpiler_dispatch;
                }
            }
            case 124; {
                value_3 = c_transpiler_va_arg(cast(*void) (ap), *Int32);
                enc_2 = cast(*Encoder) ptr;
                ret = encoder_ctl(enc_2, request, value_3);
                code_block_to_execute = 43;
                continue c_transpiler_dispatch;
            }
            case 126; {
                if s < st.layout.nb_streams {
                    code_block_to_execute = 135;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 43;
                    continue c_transpiler_dispatch;
                }
            }
            case 129; {
                encoder_ctl(enc, request, *rate);
                value_2.* += rate;
                s += 1;
                code_block_to_execute = 126;
                continue c_transpiler_dispatch;
            }
            case 135; {
                enc = cast(*Encoder) ptr;
                if s < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_encoder(coupled_size);
                    code_block_to_execute = 129;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_encoder(mono_size);
                    code_block_to_execute = 129;
                    continue c_transpiler_dispatch;
                }
            }
            case 155; {
                ret = 0;
                coupled_size = encoder_init(null, st.fs, 2, st.application);
                mono_size = encoder_init(null, st.fs, 1, st.application);
                ptr =
                    (cast(*s8) st) +
                        align_in_opus_multistream_encoder(cast,no_check(s32) (cast(u64) size_of(MS_Encoder)));
                c_transpiler_switch_value_155 := request;
                if c_transpiler_switch_value_155 == {
                    case cast(s32) 4002; {
                        value = c_transpiler_va_arg(cast(*void) (ap), Int32);
                        if value != -1000 && value != -1 {
                            if value <= 0 {
                                code_block_to_execute = 42;
                                continue c_transpiler_dispatch;
                            } else {
                                value =
                                    ifx 750000 * st.layout.nb_channels < (ifx 500 * st.layout.nb_channels > value then 500 * st.layout.nb_channels else value) then 750000 *
                                        st.layout.nb_channels else (ifx 500 * st.layout.nb_channels > value then 500 * st.layout.nb_channels else value);
                                st.bitrate_bps = value;
                                code_block_to_execute = 43;
                                continue c_transpiler_dispatch;
                            }
                        } else {
                            st.bitrate_bps = value;
                            code_block_to_execute = 43;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4003; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap), *Int32);
                        if value_2 == null {
                            code_block_to_execute = 42;
                            continue c_transpiler_dispatch;
                        } else {
                            value_2.* = 0;
                            s = 0;
                            code_block_to_execute = 126;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4037; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4007; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4001; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4009; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4011; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4015; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4017; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 11019; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4021; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4025; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4027; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4029; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4013; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4023; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4043; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4047; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4057; {
                        code_block_to_execute = 124;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4031; {
                        value_4 = c_transpiler_va_arg(cast(*void) (ap), *Uint32);
                        if value_4 == null {
                            code_block_to_execute = 42;
                            continue c_transpiler_dispatch;
                        } else {
                            value_4.* = 0;
                            s_2 = 0;
                            code_block_to_execute = 102;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4036; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4010; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4006; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4020; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4004; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4008; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4024; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4000; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4012; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4014; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4016; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 11002; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4022; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4042; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4046; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4056; {
                        code_block_to_execute = 100;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 5120; {
                        stream_id = c_transpiler_va_arg(cast(*void) (ap), Int32);
                        if stream_id < 0 || stream_id >= st.layout.nb_streams {
                            code_block_to_execute = 42;
                            continue c_transpiler_dispatch;
                        } else {
                            value_6 = c_transpiler_va_arg(cast(*void) (ap), **Encoder);
                            if value_6 == null {
                                code_block_to_execute = 42;
                                continue c_transpiler_dispatch;
                            } else {
                                s_4 = 0;
                                code_block_to_execute = 72;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4040; {
                        value_7 = c_transpiler_va_arg(cast(*void) (ap), Int32);
                        st.variable_duration = value_7;
                        code_block_to_execute = 43;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4041; {
                        value_8 = c_transpiler_va_arg(cast(*void) (ap), *Int32);
                        if value_8 == null {
                            code_block_to_execute = 42;
                            continue c_transpiler_dispatch;
                        } else {
                            value_8.* = st.variable_duration;
                            code_block_to_execute = 43;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4028; {
                        if st.mapping_type == cast,no_check(u32) MAPPING_TYPE_SURROUND {
                            fill_memory(
                                ms_get_preemph_mem(st),
                                0,
                                cast,no_check(u64) st.layout.nb_channels * size_of(Val32)
                            );
                            fill_memory(
                                ms_get_window_mem(st),
                                0,
                                cast,no_check(u64) (st.layout.nb_channels * 120) * size_of(Val32)
                            );
                            code_block_to_execute = 57;
                            continue c_transpiler_dispatch;
                        } else {
                            code_block_to_execute = 57;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case; {
                        ret = -5;
                        code_block_to_execute = 43;
                        continue c_transpiler_dispatch;
                    }
                }
            }
        }
        assert(false, tprint("invalid code block to execute %", code_block_to_execute));
        break;
    }
    return unreachable_value(s32);
}

ec_range_bytes_in_opus_multistream_encoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_multistream_encoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_multistream_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_multistream_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_multistream_encoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_multistream_encoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

false__in_opus_multistream_encoder :: () -> s32 {
    return 0;
}

mm_cvtss_si32_in_opus_multistream_encoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_opus_multistream_encoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_opus_multistream_encoder(a);
}

mm_set_ss_in_opus_multistream_encoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_opus_multistream_encoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_opus_multistream_encoder(mm_set_ss_in_opus_multistream_encoder(x));
}

float2_int16_in_opus_multistream_encoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_opus_multistream_encoder(x);
}

float2_int24_in_opus_multistream_encoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_opus_multistream_encoder(x);
}

realloc_in_opus_multistream_encoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_multistream_encoder :: (size: u64) -> *void {
    return alloc__in_opus_multistream_encoder(size);
}

fast_atan2f_in_opus_multistream_encoder :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_opus_multistream_encoder :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_opus_multistream_encoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus_multistream_encoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus_multistream_encoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus_multistream_encoder(x / y);
    }
}

celt_cos_norm2_in_opus_multistream_encoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

get_pulses_in_opus_multistream_encoder :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_opus_multistream_encoder :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_opus_multistream_encoder :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

xcorr_kernel_c_in_opus_multistream_encoder :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_opus_multistream_encoder :: (
    x: *Val16,
    y01: *Val16,
    y02: *Val16,
    n: s32,
    xy1: *Val32,
    xy2: *Val32
) {
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

globals_initialization_state_for_opus_multistream_encoder: u32;
initialize_globals_for_opus_multistream_encoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_multistream_encoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_multistream_encoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_multistream_encoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_multistream_encoder =
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
    SPREAD_ICDF_in_opus_multistream_encoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_multistream_encoder = u8.[ 2, 1, 0 ];
    VORBIS_MAPPINGS =
        Vorbis_Layout.[
            Vorbis_Layout.{nb_streams = 1, nb_coupled_streams = 0, mapping = u8.[ 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 1, nb_coupled_streams = 1, mapping = u8.[ 0, 1, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 2, nb_coupled_streams = 1, mapping = u8.[ 0, 2, 1, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 2, nb_coupled_streams = 2, mapping = u8.[ 0, 1, 2, 3, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 3, nb_coupled_streams = 2, mapping = u8.[ 0, 4, 1, 2, 3, cast,no_check(u8) 0, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 4, nb_coupled_streams = 2, mapping = u8.[ 0, 4, 1, 2, 3, 5, cast,no_check(u8) 0, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 4, nb_coupled_streams = 3, mapping = u8.[ 0, 4, 1, 2, 3, 5, 6, cast,no_check(u8) 0 ]},
            Vorbis_Layout.{nb_streams = 5, nb_coupled_streams = 3, mapping = u8.[ 0, 6, 1, 2, 3, 4, 5, 7 ]}
        ];
    DIFF_TABLE =
        Celt_Glog.[
            0.5000000,
            0.2924813,
            0.1609640,
            0.0849625,
            0.0437314,
            0.0221971,
            0.0111839,
            0.0056136,
            0.0028123,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0,
            cast,no_check(Celt_Glog) 0
        ];
    atomic_store(*globals_initialization_state_for_opus_multistream_encoder, 2);
}

Mapping_Type :: u32;
MAPPING_TYPE_NONE : s32 : 0;
MAPPING_TYPE_SURROUND : s32 : 1;
MAPPING_TYPE_AMBISONICS : s32 : 2;

MS_Encoder :: struct {
    layout: Channel_Layout;
    arch: s32;
    lfe_stream: s32;
    application: s32;
    fs: Int32;
    variable_duration: s32;
    mapping_type: Mapping_Type;
    bitrate_bps: Int32;
}

Copy_Channel_In_Func :: #type (_: *Res, _: s32, _: *void, _: s32, _: s32, _: s32, _: *void);

