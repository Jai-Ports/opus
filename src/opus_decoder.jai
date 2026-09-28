// Generated directly from C by cpp_transpiler.
Decoder_in_opus_decoder :: struct {
    celt_dec_offset: s32;
    silk_dec_offset: s32;
    channels: s32;
    fs: Int32;
    dec_control: Silk_Dec_Control_Struct;
    decode_gain: s32;
    complexity: s32;
    ignore_extensions: s32;
    arch: s32;
    stream_channels: s32;
    bandwidth: s32;
    mode: s32;
    prev_mode: s32;
    frame_size: s32;
    prev_redundancy: s32;
    last_packet_duration: s32;
    softclip_mem: [2] Val16;
    range_final: Uint32;
}

DRED_Decoder_in_opus_decoder :: struct {
    loaded: s32;
    arch: s32;
    magic: Uint32;
}

TRIM_ICDF_in_opus_decoder: [11] u8;

SPREAD_ICDF_in_opus_decoder: [4] u8;

TAPSET_ICDF_in_opus_decoder: [3] u8;

ec_range_bytes_in_opus_decoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_decoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_decoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_decoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_opus_decoder :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_decoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_decoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

decoder_get_size :: (channels: s32) -> s32 {
    silk_dec_size_bytes: s32 = ---;

    if channels < 1 || channels > 2 {
        return 0;
    }
    ret := silk_get_decoder_size(*silk_dec_size_bytes);
    if ret != 0 {
        return 0;
    }
    silk_dec_size_bytes = align_in_opus_decoder(silk_dec_size_bytes);
    celt_dec_size_bytes := celt_decoder_get_size(channels);
    return align_in_opus_decoder(cast,no_check(s32) (cast(u64) size_of(Decoder_in_opus_decoder))) + silk_dec_size_bytes + celt_dec_size_bytes;
}

align_in_opus_decoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

decoder_create :: (fs: Int32, channels: s32, error: *s32) -> *Decoder_in_opus_decoder {
    if fs != 48000 && fs != 24000 && fs != 16000 && fs != 12000 && fs != 8000 || channels != 1 && channels != 2 {
        if error != null {
            error.* = -1;
        }
        return null;
    }
    st :=
        cast(*Decoder_in_opus_decoder) alloc__in_opus_decoder(
            cast,no_check(u64) decoder_get_size(channels)
        );
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret := decoder_init(st, fs, channels);
    if error != null {
        error.* = ret;
    }
    if ret != 0 {
        free__in_opus_decoder(cast(*void) st);
        st = null;
    }
    return st;
}

free__in_opus_decoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

decoder_init :: (st: *Decoder_in_opus_decoder, fs: Int32, channels: s32) -> s32 {
    silk_dec_size_bytes: s32 = ---;

    if fs != 48000 && fs != 24000 && fs != 16000 && fs != 12000 && fs != 8000 || channels != 1 && channels != 2 {
        return -1;
    }

    fill_memory(cast(*s8) st, 0, cast,no_check(u64) decoder_get_size(channels));

    ret := silk_get_decoder_size(*silk_dec_size_bytes);
    if ret != 0 {
        return -3;
    }

    silk_dec_size_bytes = align_in_opus_decoder(silk_dec_size_bytes);
    st.silk_dec_offset = align_in_opus_decoder(cast,no_check(s32) (cast(u64) size_of(Decoder_in_opus_decoder)));
    st.celt_dec_offset = st.silk_dec_offset + silk_dec_size_bytes;
    silk_dec := cast(*void) ((cast(*s8) st) + st.silk_dec_offset);
    celt_dec := cast(*Custom_Decoder) ((cast(*s8) st) + st.celt_dec_offset);
    st.channels = channels;
    st.stream_channels = st.channels;
    st.complexity = 0;

    st.fs = fs;
    st.dec_control.api_sample_rate = st.fs;
    st.dec_control.n_channels_api = st.channels;

    ret = silk_init_decoder_2(silk_dec);
    if ret != 0 {
        return -3;
    }

    ret = celt_decoder_init(celt_dec, fs, channels);
    if ret != 0 {
        return -3;
    }

    custom_decoder_ctl(celt_dec, 10016, cast(s32) 0);

    st.prev_mode = 0;
    st.frame_size = fs / 400;

    st.arch = select_arch_in_opus_decoder();
    return 0;
}

alloc__in_opus_decoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

decode :: (st: *Decoder_in_opus_decoder, data: *u8, len: Int32, pcm: *Int16, frame_size: s32, decode_fec: s32) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    nb_samples: s32 = ---;

    if frame_size <= 0 {
        return -1;
    }
    if data != null && len > 0 && decode_fec == 0 {
        nb_samples = decoder_get_nb_samples(st, data, len);
        if nb_samples > 0 {
            frame_size = min(frame_size, nb_samples);
        } else {
            return -4;
        }
    }
    (st.channels == 1 || st.channels == 2);
    out := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (frame_size * st.channels))));

    ret := decode_native(st, data, len, out, frame_size, decode_fec, 0, null, 1, null, 0);
    if ret > 0 {
        st.arch;
        celt_float2int16_c(out, pcm, ret * st.channels);
    }

    return ret;
}

decode_native :: (
    st: *Decoder_in_opus_decoder,
    data: *u8,
    len: Int32,
    pcm: *Res,
    frame_size: s32,
    decode_fec: s32,
    self_delimited: s32,
    packet_offset: *Int32,
    soft_clip: s32,
    dred: *DRED,
    dred_offset: Int32
) -> s32 {
    offset: s32 = ---;
    toc: u8 = ---;

    size: [48] Int16 = ---;
    padding: *u8 = ---;
    padding_len: Int32 = ---;
    iter: Extension_Iterator = ---;

    if decode_fec < 0 || decode_fec > 1 {
        return -1;
    }

    if (decode_fec != 0 || len == 0 || data == null) && frame_size % st.fs / 400 != 0 {
        return -1;
    }

    if len == 0 || data == null {
        pcm_count: s32 = 0;
        while true {
            {
                ret := decode_frame(st, null, 0, pcm + pcm_count * st.channels, frame_size - pcm_count, 0);
                if ret < 0 {
                    return ret;
                }
                pcm_count += ret;
            }
            if !(pcm_count < frame_size) break;
        }

        if false__in_opus_decoder() != 0 {
        }
        st.last_packet_duration = pcm_count;
        return pcm_count;
    } else if len < 0 {
        return -1;
    }

    packet_mode := packet_get_mode(data);
    packet_bandwidth := packet_get_bandwidth(data);
    packet_frame_size := packet_get_samples_per_frame(data, st.fs);
    packet_stream_channels := packet_get_nb_channels(data);

    count :=
        packet_parse_impl(
            data,
            len,
            self_delimited,
            *toc,
            null,
            size.data,
            *offset,
            packet_offset,
            *padding,
            *padding_len
        );
    if st.ignore_extensions != 0 {
        padding = null;
        padding_len = 0;
    }
    if count < 0 {
        return count;
    }
    extension_iterator_init(*iter, padding, padding_len, count);

    data += offset;

    if decode_fec != 0 {
        ret: s32 = ---;

        if frame_size < packet_frame_size || packet_mode == 1002 || st.mode == 1002 {
            return decode_native(st, null, 0, pcm, frame_size, 0, 0, null, soft_clip, null, 0);
        }

        duration_copy := st.last_packet_duration;
        if frame_size - packet_frame_size != 0 {
            ret = decode_native(st, null, 0, pcm, frame_size - packet_frame_size, 0, 0, null, soft_clip, null, 0);
            if ret < 0 {
                st.last_packet_duration = duration_copy;
                return ret;
            }
            (ret == frame_size - packet_frame_size);
        }

        st.mode = packet_mode;
        st.bandwidth = packet_bandwidth;
        st.frame_size = packet_frame_size;
        st.stream_channels = packet_stream_channels;
        ret =
            decode_frame(
                st,
                data,
                cast,no_check(Int32) size[0],
                pcm + st.channels * (frame_size - packet_frame_size),
                packet_frame_size,
                1
            );
        if ret < 0 {
            return ret;
        } else {
            if false__in_opus_decoder() != 0 {
            }
            st.last_packet_duration = frame_size;
            return frame_size;
        }
    }

    if count * packet_frame_size > frame_size {
        return -2;
    }

    st.mode = packet_mode;
    st.bandwidth = packet_bandwidth;
    st.frame_size = packet_frame_size;
    st.stream_channels = packet_stream_channels;

    nb_samples: s32 = 0;
    if 0 < count {
        for i: 0..count - 1 {
            ret :=
                decode_frame(
                    st,
                    data,
                    cast,no_check(Int32) size[i],
                    pcm + nb_samples * st.channels,
                    frame_size - nb_samples,
                    0
                );
            if ret < 0 {
                return ret;
            }

            data += cast,no_check(s32) size[i];
            nb_samples += ret;
        }
    }
    st.last_packet_duration = nb_samples;
    if false__in_opus_decoder() != 0 {
    }

    if soft_clip != 0 {
        pcm_soft_clip_impl(pcm, nb_samples, st.channels, st.softclip_mem.data, st.arch);
    } else {
        st.softclip_mem[1] = 0.0;
        st.softclip_mem[0] = st.softclip_mem[1];
    }

    return nb_samples;
}

false__in_opus_decoder :: () -> s32 {
    return 0;
}

decode_frame :: (
    st: *Decoder_in_opus_decoder,
    data: *u8,
    len: Int32,
    pcm: *Res,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;
    silk_ret: s32 = 0;
    celt_ret: s32 = 0;
    dec: Ec_Dec = ---;
    silk_frame_size: Int32 = ---;

    pcm_transition: *Res = null;

    audiosize: s32 = ---;
    mode: s32 = ---;
    bandwidth: s32 = ---;
    transition: s32 = 0;

    redundancy: s32 = 0;
    redundancy_bytes: s32 = 0;
    celt_to_silk: s32 = 0;
    c: s32 = ---;

    window: *Celt_Coef = ---;
    redundant_rng: Uint32 = 0;

    silk_dec := cast(*void) ((cast(*s8) st) + st.silk_dec_offset);
    celt_dec := cast(*Custom_Decoder) ((cast(*s8) st) + st.celt_dec_offset);
    f20 := st.fs / 50;
    f10 := f20 >> 1;
    f5 := f10 >> 1;
    f2_5 := f5 >> 1;
    if frame_size < f2_5 {
        return -2;
    }

    frame_size = ifx frame_size < st.fs / 25 * 3 then frame_size else st.fs / 25 * 3;

    if len <= 1 {
        data = null;

        frame_size = ifx frame_size < st.frame_size then frame_size else st.frame_size;
    }
    if data != null {
        audiosize = st.frame_size;
        mode = st.mode;
        bandwidth = st.bandwidth;
        ec_dec_init(*dec, data, cast,no_check(Uint32) len);
    } else {
        audiosize = frame_size;

        mode = ifx st.prev_redundancy != 0 then 1002 else st.prev_mode;
        bandwidth = 0;

        if mode == 0 {
            i = 0;
            while i < audiosize * st.channels {
                pcm[i] = 0.0;
                i += 1;
            }

            return audiosize;
        }

        if audiosize > f20 {
            while true {
                {
                    ret := decode_frame(st, null, 0, pcm, min(audiosize, f20), 0);
                    if ret < 0 {
                        return ret;
                    }
                    pcm += ret * st.channels;
                    audiosize -= ret;
                }
                if !(audiosize > 0) break;
            }

            return frame_size;
        } else if audiosize < f20 {
            if audiosize > f10 {
                audiosize = f10;
            } else if mode != 1000 && audiosize > f5 && audiosize < f10 {
                audiosize = f5;
            }
        }
    }

    celt_accum := cast(s32) (mode != 1002);

    pcm_transition_silk_size: s32 = 0;
    pcm_transition_celt_size: s32 = 0;
    if data != null &&
        st.prev_mode > 0 &&
        (mode == 1002 && st.prev_mode != 1002 && st.prev_redundancy == 0 || mode != 1002 && st.prev_mode == 1002) {
        transition = 1;

        if mode == 1002 {
            pcm_transition_celt_size = f5 * st.channels;
        } else {
            pcm_transition_silk_size = f5 * st.channels;
        }
    }
    pcm_transition_celt :=
        cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) *
            cast,no_check(u64) pcm_transition_celt_size)));
    if transition != 0 && mode == 1002 {
        pcm_transition = pcm_transition_celt;
        decode_frame(st, null, 0, pcm_transition, min(f5, audiosize), 0);
    }
    if audiosize > frame_size {
        return -1;
    } else {
        frame_size = audiosize;
    }

    if mode != 1002 {
        pcm_silk_size: s32 = 0;

        pcm_too_small := cast(s32) (frame_size < f10);
        if pcm_too_small != 0 {
            pcm_silk_size = f10 * st.channels;
        }
        pcm_silk := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) pcm_silk_size)));
        pcm_ptr: *Res = ifx pcm_too_small != 0
            then pcm_silk
            else pcm;

        if st.prev_mode == 1002 {
            silk_reset_decoder_2(silk_dec);
        }

        st.dec_control.payload_size_ms = ifx 10 > 1000 * audiosize / st.fs then 10 else 1000 * audiosize / st.fs;

        if data != null {
            st.dec_control.n_channels_internal = st.stream_channels;
            if mode == 1000 {
                if bandwidth == 1101 {
                    st.dec_control.internal_sample_rate = 8000;
                } else if bandwidth == 1102 {
                    st.dec_control.internal_sample_rate = 12000;
                } else if bandwidth == 1103 {
                    st.dec_control.internal_sample_rate = 16000;
                } else {
                    st.dec_control.internal_sample_rate = 16000;
                }
            } else {
                st.dec_control.internal_sample_rate = 16000;
            }
        }
        st.dec_control.enable_deep_plc = cast(s32) (st.complexity >= 5);

        lost_flag := (ifx data == null then 1 else 2 * cast(s32) (decode_fec != 0));
        decoded_samples: s32 = 0;
        while true {
            {
                first_frame := cast(s32) (decoded_samples == 0);
                silk_ret =
                    silk_decode(
                        silk_dec,
                        *st.dec_control,
                        lost_flag,
                        first_frame,
                        *dec,
                        pcm_ptr,
                        *silk_frame_size,
                        st.arch
                    );
                if silk_ret != 0 {
                    if lost_flag != 0 {
                        silk_frame_size = frame_size;
                        i = 0;
                        while i < frame_size * st.channels {
                            pcm_ptr[i] = 0.0;
                            i += 1;
                        }
                    } else {
                        return -3;
                    }
                }
                pcm_ptr += silk_frame_size * st.channels;
                decoded_samples = cast,no_check(s32) (decoded_samples + silk_frame_size);
            }
            if !(decoded_samples < frame_size) break;
        }
        if pcm_too_small != 0 {
            copy_memory(
                pcm,
                pcm_silk,
                (cast,no_check(u64) (frame_size * st.channels)) * size_of(Res) +
                cast,no_check(u64) (0 * (pcm - pcm_silk))
            );
        }
    }

    start_band: s32 = 0;
    if decode_fec == 0 &&
        mode != 1002 &&
        data != null &&
        (ec_tell_in_opus_decoder(*dec) + 17 + 20 * cast(s32) (mode == 1001)) <= 8 * len {
        if mode == 1001 {
            redundancy = ec_dec_bit_logp(*dec, 12);
        } else {
            redundancy = 1;
        }
        if redundancy != 0 {
            celt_to_silk = ec_dec_bit_logp(*dec, 1);

            redundancy_bytes =
                ifx mode == 1001 then (cast,no_check(Int32) ec_dec_uint(*dec, 256)) +
                    2 else len - (ec_tell_in_opus_decoder(*dec) + 7) >> 3;
            len = cast,no_check(Int32) (len - redundancy_bytes);

            if len * 8 < ec_tell_in_opus_decoder(*dec) {
                len = 0;
                redundancy_bytes = 0;
                redundancy = 0;
            }

            dec.storage -= cast,no_check(Uint32) redundancy_bytes;
        }
    }
    if mode != 1002 {
        start_band = 17;
    }

    if redundancy != 0 {
        transition = 0;
        pcm_transition_silk_size = 0;
    }

    pcm_transition_silk :=
        cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) *
            cast,no_check(u64) pcm_transition_silk_size)));

    if transition != 0 && mode != 1002 {
        pcm_transition = pcm_transition_silk;
        decode_frame(st, null, 0, pcm_transition, min(f5, audiosize), 0);
    }

    if bandwidth != 0 {
        endband: s32 = 21;

        if bandwidth == {
            case 1101;
                endband = 13;
            case 1102; #through;
            case 1103;
                endband = 17;
            case 1104;
                endband = 19;
            case 1105;
                endband = 21;
            case;
        }
        if custom_decoder_ctl(celt_dec, 10012, endband) != 0 {
            return -3;
        }
    }
    if custom_decoder_ctl(celt_dec, 10008, (ifx true { ((st.stream_channels == cast(s32) 0)); (st.stream_channels); })) != 0 {
        return -3;
    }

    redundant_audio_size := (ifx redundancy != 0 then f5 * st.channels else 0);
    redundant_audio :=
        cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) *
            cast,no_check(u64) redundant_audio_size)));

    if redundancy != 0 && celt_to_silk != 0 {
        if custom_decoder_ctl(celt_dec, 10010, cast(s32) 0) != 0 {
            return -3;
        }
        celt_decode_with_ec(celt_dec, data + len, redundancy_bytes, redundant_audio, f5, null, 0);
        if custom_decoder_ctl(celt_dec, 4031, *redundant_rng + (*redundant_rng - *redundant_rng)) != 0 {
            return -3;
        }
    }

    if custom_decoder_ctl(celt_dec, 10010, start_band) != 0 {
        return -3;
    }

    if mode != 1000 {
        celt_frame_size := min(f20, frame_size);

        if mode != st.prev_mode && st.prev_mode > 0 && st.prev_redundancy == 0 {
            if custom_decoder_ctl(celt_dec, 4028) != 0 {
                return -3;
            }
        }

        celt_ret =
            celt_decode_with_ec_dred(
                celt_dec,
                (ifx decode_fec != 0 then null else data),
                len,
                pcm,
                celt_frame_size,
                *dec,
                celt_accum
            );
        custom_decoder_ctl(celt_dec, 4031, *st.range_final + (*st.range_final - *st.range_final));
    } else {
        silence := u8.[ 0xff, 0xff ];
        if celt_accum == 0 {
            i = 0;
            while i < frame_size * st.channels {
                pcm[i] = 0.0;
                i += 1;
            }
        }

        if st.prev_mode == 1001 && !(redundancy != 0 && celt_to_silk != 0 && st.prev_redundancy != 0) {
            if custom_decoder_ctl(celt_dec, 10010, cast(s32) 0) != 0 {
                return -3;
            }
            celt_decode_with_ec(celt_dec, silence.data, 2, pcm, f2_5, null, celt_accum);
        }
        st.range_final = dec.rng;
    }

    {
        celt_mode: *Custom_Mode = ---;
        if custom_decoder_ctl(celt_dec, 10015, *celt_mode + (*celt_mode - *celt_mode)) != 0 {
            return -3;
        }
        window = celt_mode.window;
    }

    if redundancy != 0 && celt_to_silk == 0 {
        if custom_decoder_ctl(celt_dec, 4028) != 0 {
            return -3;
        }
        if custom_decoder_ctl(celt_dec, 10010, cast(s32) 0) != 0 {
            return -3;
        }

        celt_decode_with_ec(celt_dec, data + len, redundancy_bytes, redundant_audio, f5, null, 0);
        if custom_decoder_ctl(celt_dec, 4031, *redundant_rng + (*redundant_rng - *redundant_rng)) != 0 {
            return -3;
        }
        smooth_fade(
            pcm + st.channels * (frame_size - f2_5),
            redundant_audio + st.channels * f2_5,
            pcm + st.channels * (frame_size - f2_5),
            f2_5,
            st.channels,
            window,
            st.fs
        );
    }

    if redundancy != 0 && celt_to_silk != 0 && (st.prev_mode != 1000 || st.prev_redundancy != 0) {
        c = 0;
        while c < st.channels {
            i = 0;
            while i < f2_5 {
                pcm[st.channels * i + c] = redundant_audio[st.channels * i + c];
                i += 1;
            }
            c += 1;
        }
        smooth_fade(
            redundant_audio + st.channels * f2_5,
            pcm + st.channels * f2_5,
            pcm + st.channels * f2_5,
            f2_5,
            st.channels,
            window,
            st.fs
        );
    }
    if transition != 0 {
        if audiosize >= f5 {
            i = 0;
            while i < st.channels * f2_5 {
                pcm[i] = pcm_transition[i];
                i += 1;
            }
            smooth_fade(
                pcm_transition + st.channels * f2_5,
                pcm + st.channels * f2_5,
                pcm + st.channels * f2_5,
                f2_5,
                st.channels,
                window,
                st.fs
            );
        } else {
            smooth_fade(pcm_transition, pcm, pcm, f2_5, st.channels, window, st.fs);
        }
    }

    if st.decode_gain != 0 {
        gain :=
            cast,no_check(float32) c_transpiler_math_exp(
                0.6931471805599453 *
                cast,no_check(float64) ((cast(float32) 0.0006488140788860619) * cast,no_check(float32) st.decode_gain)
            );
        i = 0;
        while i < frame_size * st.channels {
            x := pcm[i] * gain;

            pcm[i] = x;
            i += 1;
        }
    }

    if len <= 1 {
        st.range_final = 0;
    } else {
        st.range_final ^= redundant_rng;
    }

    st.prev_mode = mode;
    st.prev_redundancy = cast(s32) (redundancy != 0 && celt_to_silk == 0);

    if celt_ret >= 0 {
        if false__in_opus_decoder() != 0 {
        }
    }

    return ifx celt_ret < 0 then celt_ret else audiosize;
}

smooth_fade :: (in1: *Res, in2: *Res, out: *Res, overlap: s32, channels: s32, window: *Celt_Coef, fs: Int32) {
    i: s32 = ---;
    inc: s32 = 48000 / fs;
    if 0 < channels {
        for c: 0..channels - 1 {
            i = 0;
            while i < overlap {
                w := window[i * inc];
                w = w * w;
                out[i * channels + c] = w * in2[i * channels + c] + (1.0 - w) * in1[i * channels + c];
                i += 1;
            }
        }
    }
}

packet_get_nb_channels :: (data: *u8) -> s32 {
    if data[0] & 0x4 != 0 {
        return 2;
    }
    return 1;
}

packet_get_bandwidth :: (data: *u8) -> s32 {
    bandwidth: s32 = ---;
    if data[0] & 0x80 != 0 {
        bandwidth = 1102 + (cast(s32) data[0]) >> 5 & 0x3;
        if bandwidth == 1102 {
            bandwidth = 1101;
        }
    } else if (cast(s32) data[0]) & 0x60 == 0x60 {
        bandwidth = ifx data[0] & 0x10 != 0 then cast(s32) 1105 else 1104;
    } else {
        bandwidth = 1101 + (cast(s32) data[0]) >> 5 & 0x3;
    }
    return bandwidth;
}

packet_get_mode :: (data: *u8) -> s32 {
    mode: s32 = ifx data[0] & 0x80 != 0
        then cast(s32) 1002
        else ifx (cast(s32) data[0]) & 0x60 == 0x60
            then cast(s32) 1001
            else 1000;
    return mode;
}

decoder_get_nb_samples :: (dec: *Decoder_in_opus_decoder, packet: *u8, len: Int32) -> s32 {
    return packet_get_nb_samples(packet, len, dec.fs);
}

packet_get_nb_samples :: (packet: *u8, len: Int32, fs: Int32) -> s32 {
    count := packet_get_nb_frames(packet, len);

    if count < 0 {
        return count;
    }

    samples := count * packet_get_samples_per_frame(packet, fs);

    if samples * 25 > fs * 3 {
        return -4;
    } else {
        return samples;
    }
}

packet_get_nb_frames :: (packet: *u8, len: Int32) -> s32 {
    if len < 1 {
        return -1;
    }
    count := (cast(s32) packet[0]) & 0x3;
    if count == 0 {
        return 1;
    } else if count != 3 {
        return 2;
    } else if len < 2 {
        return -4;
    } else {
        return (cast(s32) packet[1]) & 0x3f;
    }
}

decode24 :: (
    st: *Decoder_in_opus_decoder,
    data: *u8,
    len: Int32,
    pcm: *Int32,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    nb_samples: s32 = ---;

    if frame_size <= 0 {
        return -1;
    }
    if data != null && len > 0 && decode_fec == 0 {
        nb_samples = decoder_get_nb_samples(st, data, len);
        if nb_samples > 0 {
            frame_size = min(frame_size, nb_samples);
        } else {
            return -4;
        }
    }
    (st.channels == 1 || st.channels == 2);
    out := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (frame_size * st.channels))));

    ret := decode_native(st, data, len, out, frame_size, decode_fec, 0, null, 0, null, 0);
    if ret > 0 {
        nb_samples = ret * st.channels;
        if 0 < nb_samples {
            for i: 0..nb_samples - 1 {
                pcm[i] = float2int_in_opus_decoder(8388608.0 * out[i]);
            }
        }
    }

    return ret;
}

float2int_in_opus_decoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_opus_decoder(mm_set_ss_in_opus_decoder(x));
}

mm_set_ss_in_opus_decoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

mm_cvt_ss2si_in_opus_decoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_opus_decoder(a);
}

mm_cvtss_si32_in_opus_decoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

decode_float :: (
    st: *Decoder_in_opus_decoder,
    data: *u8,
    len: Int32,
    pcm: *Val16,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    if frame_size <= 0 {
        return -1;
    }
    return decode_native(st, data, len, pcm, frame_size, decode_fec, 0, null, 0, null, 0);
}

decoder_ctl :: (st: *Decoder_in_opus_decoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ret: s32 = ---;
    ap: Va_List = ---;
    silk_dec: *void = ---;
    celt_dec: *Custom_Decoder = ---;
    value: *Int32 = ---;
    value_2: Int32 = ---;
    value_3: *Int32 = ---;
    value_4: *Uint32 = ---;
    value_5: *Int32 = ---;
    value_6: *Int32 = ---;
    value_7: *Int32 = ---;
    value_8: Int32 = ---;
    value_9: *Int32 = ---;
    value_10: Int32 = ---;
    value_11: *Int32 = ---;
    value_12: Int32 = ---;
    value_13: *Int32 = ---;
    code_block_to_execute: s64 = 103;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 17; {
                return -1;
            }
            case 19; {
                return ret;
            }
            case 103; {
                ret = 0;
                silk_dec = cast(*void) ((cast(*s8) st) + st.silk_dec_offset);
                celt_dec = cast(*Custom_Decoder) ((cast(*s8) st) + st.celt_dec_offset);
                start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
                c_transpiler_switch_value_103 := request;
                if c_transpiler_switch_value_103 == {
                    case cast(s32) 4009; {
                        value = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value.* = st.bandwidth;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4010; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_2 < 0 || value_2 > 10 {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            st.complexity = value_2;
                            custom_decoder_ctl(celt_dec, 4010, value_2);
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4011; {
                        value_3 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_3 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_3.* = st.complexity;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4031; {
                        value_4 = c_transpiler_va_arg(cast(*void) (ap.data), *Uint32);
                        if value_4 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_4.* = st.range_final;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4028; {
                        fill_memory(
                            cast(*s8) *st.stream_channels,
                            0,
                            size_of(Decoder_in_opus_decoder) -
                            cast,no_check(u64) ((cast(*s8) *st.stream_channels) - cast(*s8) st)
                        );
                        custom_decoder_ctl(celt_dec, 4028);
                        silk_reset_decoder_2(silk_dec);
                        st.stream_channels = st.channels;
                        st.frame_size = st.fs / 400;
                        code_block_to_execute = 19;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4029; {
                        value_5 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_5 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_5.* = st.fs;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4033; {
                        value_6 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_6 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            if st.prev_mode == 1002 {
                                ret = custom_decoder_ctl(celt_dec, 4033, value_6 + (value_6 - value_6));
                                code_block_to_execute = 19;
                                continue c_transpiler_dispatch;
                            } else {
                                value_6.* = st.dec_control.prev_pitch_lag;
                                code_block_to_execute = 19;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4045; {
                        value_7 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_7 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_7.* = st.decode_gain;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4034; {
                        value_8 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_8 < -32768 || value_8 > 32767 {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            st.decode_gain = value_8;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4039; {
                        value_9 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_9 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_9.* = st.last_packet_duration;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4046; {
                        value_10 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_10 < 0 || value_10 > 1 {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            ret = custom_decoder_ctl(celt_dec, 4046, value_10);
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4047; {
                        value_11 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_11 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            ret = custom_decoder_ctl(celt_dec, 4047, value_11 + (value_11 - value_11));
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4058; {
                        value_12 = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if value_12 < 0 || value_12 > 1 {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            st.ignore_extensions = value_12;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4059; {
                        value_13 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_13 == null {
                            code_block_to_execute = 17;
                            continue c_transpiler_dispatch;
                        } else {
                            value_13.* = st.ignore_extensions;
                            code_block_to_execute = 19;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case; {
                        ret = -5;
                        code_block_to_execute = 19;
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

decoder_destroy :: (st: *Decoder_in_opus_decoder) {
    free__in_opus_decoder(cast(*void) st);
}

dred_decoder_get_size :: () -> s32 {
    return cast,no_check(s32) (cast(u64) size_of(DRED_Decoder_in_opus_decoder));
}

dred_decoder_create :: (error: *s32) -> *DRED_Decoder_in_opus_decoder {
    dec :=
        cast(*DRED_Decoder_in_opus_decoder) alloc__in_opus_decoder(
            cast,no_check(u64) dred_decoder_get_size()
        );
    if dec == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret := dred_decoder_init(dec);
    if error != null {
        error.* = ret;
    }
    if ret != 0 {
        free__in_opus_decoder(cast(*void) dec);
        dec = null;
    }
    return dec;
}

dred_decoder_init :: (dec: *DRED_Decoder_in_opus_decoder) -> s32 {
    ret: s32 = 0;
    dec.loaded = 0;

    dec.arch = select_arch_in_opus_decoder();

    dec.magic = 0xd8eddec0;
    if ret == 0 {
        return 0;
    }
    return -5;
}

dred_decoder_destroy :: (dec: *DRED_Decoder_in_opus_decoder) {
    if dec != null {
        dec.magic = 0xde57801d;
    }
    free__in_opus_decoder(cast(*void) dec);
}

dred_decoder_ctl :: (dred_dec: *DRED_Decoder_in_opus_decoder, request: s32, variadic_arguments: ..Any) -> s32 {
    return -5;
}

dred_get_size :: () -> s32 {
    return 0;
}

dred_alloc :: (error: *s32) -> *DRED {
    if error != null {
        error.* = -5;
    }
    return null;
}

dred_free :: (dec: *DRED) {
}

dred_parse :: (
    dred_dec: *DRED_Decoder_in_opus_decoder,
    dred: *DRED,
    data: *u8,
    len: Int32,
    max_dred_samples: Int32,
    sampling_rate: Int32,
    dred_end: *s32,
    defer_processing: s32
) -> s32 {
    return -5;
}

dred_process :: (dred_dec: *DRED_Decoder_in_opus_decoder, src: *DRED, dst: *DRED) -> s32 {
    return -5;
}

decoder_dred_decode :: (
    st: *Decoder_in_opus_decoder,
    dred: *DRED,
    dred_offset: Int32,
    pcm: *Int16,
    frame_size: Int32
) -> s32 {
    return -5;
}

decoder_dred_decode24 :: (
    st: *Decoder_in_opus_decoder,
    dred: *DRED,
    dred_offset: Int32,
    pcm: *Int32,
    frame_size: Int32
) -> s32 {
    return -5;
}

decoder_dred_decode_float :: (
    st: *Decoder_in_opus_decoder,
    dred: *DRED,
    dred_offset: Int32,
    pcm: *float32,
    frame_size: Int32
) -> s32 {
    return -5;
}

packet_has_lbrr :: (packet: *u8, len: Int32) -> s32 {
    frames: [48] *u8 = ---;
    size: [48] Int16 = ---;

    nb_frames: s32 = 1;

    packet_mode := packet_get_mode(packet);
    if packet_mode == 1002 {
        return 0;
    }
    packet_frame_size := packet_get_samples_per_frame(packet, 48000);
    if packet_frame_size > 960 {
        nb_frames = packet_frame_size / 960;
    }
    packet_stream_channels := packet_get_nb_channels(packet);
    ret := packet_parse(packet, len, null, frames.data, size.data, null);
    if ret <= 0 {
        return ret;
    }
    if size[0] == 0 {
        return 0;
    }
    lbrr := (cast(s32) frames[0][0]) >> (((7 - nb_frames)) & 31) & 0x1;
    if packet_stream_channels == 2 {
        lbrr = cast(s32) (lbrr != 0 || (cast(s32) frames[0][0]) >> (((6 - 2 * nb_frames)) & 31) & 0x1 != 0);
    }
    return lbrr;
}

float2_int16_in_opus_decoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_opus_decoder(x);
}

float2_int24_in_opus_decoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_opus_decoder(x);
}

realloc_in_opus_decoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_decoder :: (size: u64) -> *void {
    return alloc__in_opus_decoder(size);
}

silk_clz16_in_opus_decoder :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_opus_decoder :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

silk_ror32_in_opus_decoder :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_opus_decoder :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_opus_decoder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_opus_decoder :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_opus_decoder :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_opus_decoder :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_opus_decoder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_opus_decoder :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_opus_decoder :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_opus_decoder :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_opus_decoder(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_opus_decoder(in_upper);
    }
}

silk_clz_frac_in_opus_decoder :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_opus_decoder(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_opus_decoder(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_opus_decoder :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_opus_decoder(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_opus_decoder :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_opus_decoder((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_opus_decoder((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_opus_decoder :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_opus_decoder((ifx B32 > 0 then B32 else -B32)) - 1;
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

fast_atan2f_in_opus_decoder :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_opus_decoder :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_opus_decoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus_decoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus_decoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus_decoder(x / y);
    }
}

celt_cos_norm2_in_opus_decoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

globals_initialization_state_for_opus_decoder: u32;
initialize_globals_for_opus_decoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_decoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_decoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_decoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_decoder =
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
    SPREAD_ICDF_in_opus_decoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_decoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus_decoder, 2);
}

Extension_Iterator :: struct {
    data: *u8;
    curr_data: *u8;
    repeat_data: *u8;
    last_long: *u8;
    src_data: *u8;
    len: Int32;
    curr_len: Int32;
    repeat_len: Int32;
    src_len: Int32;
    trailing_short_len: Int32;
    nb_frames: s32;
    frame_max: s32;
    curr_frame: s32;
    repeat_frame: s32;
    repeat_l: u8;
}

