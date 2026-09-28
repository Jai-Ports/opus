TRIM_ICDF_in_opus_multistream_decoder: [11] u8;

SPREAD_ICDF_in_opus_multistream_decoder: [4] u8;

TAPSET_ICDF_in_opus_multistream_decoder: [3] u8;

multistream_decoder_get_size :: (nb_streams: s32, nb_coupled_streams: s32) -> Int32 {
    if nb_streams < 1 || nb_coupled_streams > nb_streams || nb_coupled_streams < 0 {
        return 0;
    }
    coupled_size := decoder_get_size(2);
    mono_size := decoder_get_size(1);
    return align_in_opus_multistream_decoder(cast,no_check(s32) (cast(u64) size_of(MS_Decoder))) + nb_coupled_streams * align_in_opus_multistream_decoder(coupled_size) + (nb_streams - nb_coupled_streams) * align_in_opus_multistream_decoder(mono_size);
}

align_in_opus_multistream_decoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

multistream_decoder_create :: (
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    mapping: *u8,
    error: *s32
) -> *MS_Decoder {
    if channels > 255 ||
        channels < 1 ||
        coupled_streams > streams ||
        streams < 1 ||
        coupled_streams < 0 ||
        streams > 255 - coupled_streams {
        if error != null {
            error.* = -1;
        }
        return null;
    }
    st :=
        cast(*MS_Decoder) alloc__in_opus_multistream_decoder(
            cast,no_check(u64) multistream_decoder_get_size(streams, coupled_streams)
        );
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    ret := multistream_decoder_init(st, fs, channels, streams, coupled_streams, mapping);
    if error != null {
        error.* = ret;
    }
    if ret != 0 {
        free__in_opus_multistream_decoder(cast(*void) st);
        st = null;
    }
    return st;
}

free__in_opus_multistream_decoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

multistream_decoder_init :: (
    st: *MS_Decoder,
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    mapping: *u8
) -> s32 {
    ret: s32 = ---;

    if channels > 255 ||
        channels < 1 ||
        coupled_streams > streams ||
        streams < 1 ||
        coupled_streams < 0 ||
        streams > 255 - coupled_streams {
        return -1;
    }

    st.layout.nb_channels = channels;
    st.layout.nb_streams = streams;
    st.layout.nb_coupled_streams = coupled_streams;

    i: s32 = 0;
    while i < st.layout.nb_channels {
        st.layout.mapping[i] = mapping[i];
        i += 1;
    }
    if validate_layout(*st.layout) == 0 {
        return -1;
    }

    ptr := (cast(*s8) st) + align_in_opus_multistream_decoder(cast,no_check(s32) (cast(u64) size_of(MS_Decoder)));
    coupled_size := decoder_get_size(2);
    mono_size := decoder_get_size(1);

    i = 0;
    while i < st.layout.nb_coupled_streams {
        ret = decoder_init(cast(*Decoder) ptr, fs, 2);
        if ret != 0 {
            return ret;
        }
        ptr += align_in_opus_multistream_decoder(coupled_size);
        i += 1;
    }
    while i < st.layout.nb_streams {
        ret = decoder_init(cast(*Decoder) ptr, fs, 1);
        if ret != 0 {
            return ret;
        }
        ptr += align_in_opus_multistream_decoder(mono_size);
        i += 1;
    }
    return 0;
}

alloc__in_opus_multistream_decoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

multistream_decode :: (st: *MS_Decoder, data: *u8, len: Int32, pcm: *Int16, frame_size: s32, decode_fec: s32) -> s32 {
    return multistream_decode_native(
        st,
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) copy_channel_out_short,
        frame_size,
        decode_fec,
        1,
        null
    );
}

copy_channel_out_short :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    i: Int32 = ---;

    short_dst := cast(*Int16) dst;
    if src != null {
        i = 0;
        while i < frame_size {
            short_dst[i * dst_stride + dst_channel] = float2_int16_in_opus_multistream_decoder(src[i * src_stride]);
            i += 1;
        }
    } else {
        i = 0;
        while i < frame_size {
            short_dst[i * dst_stride + dst_channel] = 0;
            i += 1;
        }
    }
}

float2_int16_in_opus_multistream_decoder :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_opus_multistream_decoder(x);
}

float2int_in_opus_multistream_decoder :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_opus_multistream_decoder(mm_set_ss_in_opus_multistream_decoder(x));
}

mm_set_ss_in_opus_multistream_decoder :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

mm_cvt_ss2si_in_opus_multistream_decoder :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_opus_multistream_decoder(a);
}

mm_cvtss_si32_in_opus_multistream_decoder :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

multistream_decode_native :: (
    st: *MS_Decoder,
    data: *u8,
    len: Int32,
    pcm: *void,
    copy_channel_out: Copy_Channel_Out_Func,
    frame_size: s32,
    decode_fec: s32,
    soft_clip: s32,
    user_data: *void
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    fs: Int32 = ---;

    do_plc: s32 = 0;

    if frame_size <= 0 {
        return -1;
    }

    if multistream_decoder_ctl(st, 4029, *fs + (*fs - *fs)) != 0 {
        return -3;
    }
    frame_size = ifx frame_size < fs / 25 * 3 then frame_size else fs / 25 * 3;
    buf := cast(*Res) c_transpiler_alloca(cast(u64) ((size_of(Res) * cast,no_check(u64) (2 * frame_size))));
    ptr := (cast(*s8) st) + align_in_opus_multistream_decoder(cast,no_check(s32) (cast(u64) size_of(MS_Decoder)));
    coupled_size := decoder_get_size(2);
    mono_size := decoder_get_size(1);

    if len == 0 {
        do_plc = 1;
    }
    if len < 0 {
        return -1;
    }
    if do_plc == 0 && len < 2 * st.layout.nb_streams - 1 {
        return -4;
    }
    if do_plc == 0 {
        ret := multistream_packet_validate(data, len, st.layout.nb_streams, fs);
        if ret < 0 {
            return ret;
        } else if ret > frame_size {
            return -2;
        }
    }
    s: s32 = 0;
    while s < st.layout.nb_streams {
        dec := cast(*Decoder) ptr;
        ptr += (ifx s < st.layout.nb_coupled_streams then align_in_opus_multistream_decoder(coupled_size) else align_in_opus_multistream_decoder(mono_size));

        if do_plc == 0 && len <= 0 {
            return -3;
        }
        packet_offset: Int32 = 0;
        ret :=
            decode_native(
                dec,
                data,
                len,
                buf,
                frame_size,
                decode_fec,
                cast(s32) (s != st.layout.nb_streams - 1),
                *packet_offset,
                soft_clip,
                null,
                0
            );
        if do_plc == 0 {
            data += packet_offset;
            len -= packet_offset;
        }
        if ret <= 0 {
            return ret;
        }
        frame_size = ret;
        if s < st.layout.nb_coupled_streams {
            chan, prev: s32 = ---;
            prev = -1;

            while (ifx true { assignment_0: s32 = cast,no_check(s32) (get_left_channel(*st.layout, s, prev)); (chan) = assignment_0; assignment_0; }) != -1 {
                (cast,no_check(#type (_: *void, _: s32, _: s32, _: *Res, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_out)))(
                    pcm,
                    st.layout.nb_channels,
                    chan,
                    buf,
                    2,
                    frame_size,
                    user_data
                );
                prev = chan;
            }
            prev = -1;

            while (ifx true { assignment_1: s32 = cast,no_check(s32) (get_right_channel(*st.layout, s, prev)); (chan) = assignment_1; assignment_1; }) != -1 {
                (cast,no_check(#type (_: *void, _: s32, _: s32, _: *Res, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_out)))(
                    pcm,
                    st.layout.nb_channels,
                    chan,
                    buf + 1,
                    2,
                    frame_size,
                    user_data
                );
                prev = chan;
            }
        } else {
            chan, prev: s32 = ---;
            prev = -1;

            while (ifx true { assignment_2: s32 = cast,no_check(s32) (get_mono_channel(*st.layout, s, prev)); (chan) = assignment_2; assignment_2; }) != -1 {
                (cast,no_check(#type (_: *void, _: s32, _: s32, _: *Res, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_out)))(
                    pcm,
                    st.layout.nb_channels,
                    chan,
                    buf,
                    1,
                    frame_size,
                    user_data
                );
                prev = chan;
            }
        }
        s += 1;
    }

    c: s32 = 0;
    while c < st.layout.nb_channels {
        if st.layout.mapping[c] == 255 {
            (cast,no_check(#type (_: *void, _: s32, _: s32, _: *Res, _: s32, _: s32, _: *void)) (cast(*void) (copy_channel_out)))(
                pcm,
                st.layout.nb_channels,
                c,
                null,
                0,
                frame_size,
                user_data
            );
        }
        c += 1;
    }

    return frame_size;
}

multistream_packet_validate :: (data: *u8, len: Int32, nb_streams: s32, fs: Int32) -> s32 {
    toc: u8 = ---;
    size: [48] Int16 = ---;
    samples: s32 = 0;
    packet_offset: Int32 = ---;

    if 0 < nb_streams {
        for s: 0..nb_streams - 1 {
            if len <= 0 {
                return -4;
            }
            count :=
                packet_parse_impl(
                    data,
                    len,
                    cast(s32) (s != nb_streams - 1),
                    *toc,
                    null,
                    size.data,
                    null,
                    *packet_offset,
                    null,
                    null
                );
            if count < 0 {
                return count;
            }
            tmp_samples := packet_get_nb_samples(data, packet_offset, fs);
            if s != 0 && samples != tmp_samples {
                return -4;
            }
            samples = tmp_samples;
            data += packet_offset;
            len -= packet_offset;
        }
    }
    return samples;
}

multistream_decoder_ctl :: (st: *MS_Decoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ap: Va_List = ---;
    start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
    ret := multistream_decoder_ctl_va_list(st, request, ap.data);
    return ret;
}

multistream_decoder_ctl_va_list :: (st: *MS_Decoder, request: s32, ap: *Va_List_Tag) -> s32 {
    coupled_size: s32 = ---;
    mono_size: s32 = ---;
    ptr: *s8 = ---;
    ret: s32 = ---;
    dec: *Decoder = ---;
    value: *Int32 = ---;
    s: s32 = ---;
    value_2: *Uint32 = ---;
    tmp: Uint32 = ---;
    dec_2: *Decoder = ---;
    s_2: s32 = ---;
    dec_3: *Decoder = ---;
    s_3: s32 = ---;
    stream_id: Int32 = ---;
    value_3: **Decoder = ---;
    s_4: s32 = ---;
    value_4: Int32 = ---;
    dec_4: *Decoder = ---;
    code_block_to_execute: s64 = 92;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 15; {
                return ret;
            }
            case 19; {
                if s_4 < st.layout.nb_streams {
                    code_block_to_execute = 28;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                }
            }
            case 23; {
                ret = decoder_ctl(dec_4, request, value_4);
                if ret != 0 {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                } else {
                    s_4 += 1;
                    code_block_to_execute = 19;
                    continue c_transpiler_dispatch;
                }
            }
            case 28; {
                dec_4 = cast(*Decoder) ptr;
                if s_4 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_decoder(coupled_size);
                    code_block_to_execute = 23;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_decoder(mono_size);
                    code_block_to_execute = 23;
                    continue c_transpiler_dispatch;
                }
            }
            case 31; {
                value_4 = c_transpiler_va_arg(cast(*void) (ap), Int32);
                s_4 = 0;
                code_block_to_execute = 19;
                continue c_transpiler_dispatch;
            }
            case 34; {
                if s_3 < stream_id {
                    code_block_to_execute = 38;
                    continue c_transpiler_dispatch;
                } else {
                    value_3.* = cast(*Decoder) ptr;
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                }
            }
            case 35; {
                s_3 += 1;
                code_block_to_execute = 34;
                continue c_transpiler_dispatch;
            }
            case 38; {
                if s_3 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_decoder(coupled_size);
                    code_block_to_execute = 35;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_decoder(mono_size);
                    code_block_to_execute = 35;
                    continue c_transpiler_dispatch;
                }
            }
            case 50; {
                if s_2 < st.layout.nb_streams {
                    code_block_to_execute = 59;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                }
            }
            case 54; {
                ret = decoder_ctl(dec_3, 4028);
                if ret != 0 {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                } else {
                    s_2 += 1;
                    code_block_to_execute = 50;
                    continue c_transpiler_dispatch;
                }
            }
            case 59; {
                dec_3 = cast(*Decoder) ptr;
                if s_2 < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_decoder(coupled_size);
                    code_block_to_execute = 54;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_decoder(mono_size);
                    code_block_to_execute = 54;
                    continue c_transpiler_dispatch;
                }
            }
            case 63; {
                if s < st.layout.nb_streams {
                    code_block_to_execute = 73;
                    continue c_transpiler_dispatch;
                } else {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                }
            }
            case 68; {
                ret = decoder_ctl(dec_2, request, *tmp);
                if ret != 0 {
                    code_block_to_execute = 15;
                    continue c_transpiler_dispatch;
                } else {
                    value_2.* ^= tmp;
                    s += 1;
                    code_block_to_execute = 63;
                    continue c_transpiler_dispatch;
                }
            }
            case 73; {
                dec_2 = cast(*Decoder) ptr;
                if s < st.layout.nb_coupled_streams {
                    ptr += align_in_opus_multistream_decoder(coupled_size);
                    code_block_to_execute = 68;
                    continue c_transpiler_dispatch;
                } else {
                    ptr += align_in_opus_multistream_decoder(mono_size);
                    code_block_to_execute = 68;
                    continue c_transpiler_dispatch;
                }
            }
            case 85; {
                value = c_transpiler_va_arg(cast(*void) (ap), *Int32);
                dec = cast(*Decoder) ptr;
                ret = decoder_ctl(dec, request, value);
                code_block_to_execute = 15;
                continue c_transpiler_dispatch;
            }
            case 92; {
                ret = 0;
                coupled_size = decoder_get_size(2);
                mono_size = decoder_get_size(1);
                ptr =
                    (cast(*s8) st) +
                        align_in_opus_multistream_decoder(cast,no_check(s32) (cast(u64) size_of(MS_Decoder)));
                c_transpiler_switch_value_92 := request;
                if c_transpiler_switch_value_92 == {
                    case cast(s32) 4009; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4029; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4045; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4039; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4047; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4011; {
                        code_block_to_execute = 85;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4031; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap), *Uint32);
                        if value_2 == null {
                            return -1;
                        } else {
                            value_2.* = 0;
                            s = 0;
                            code_block_to_execute = 63;
                            continue c_transpiler_dispatch;
                        }
                    }
                    case cast(s32) 4028; {
                        s_2 = 0;
                        code_block_to_execute = 50;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 5122; {
                        stream_id = c_transpiler_va_arg(cast(*void) (ap), Int32);
                        if stream_id < 0 || stream_id >= st.layout.nb_streams {
                            return -1;
                        } else {
                            value_3 = c_transpiler_va_arg(cast(*void) (ap), **Decoder);
                            if value_3 == null {
                                return -1;
                            } else {
                                s_3 = 0;
                                code_block_to_execute = 34;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case cast(s32) 4034; {
                        code_block_to_execute = 31;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4010; {
                        code_block_to_execute = 31;
                        continue c_transpiler_dispatch;
                    }
                    case cast(s32) 4046; {
                        code_block_to_execute = 31;
                        continue c_transpiler_dispatch;
                    }
                    case; {
                        ret = -5;
                        code_block_to_execute = 15;
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

multistream_decode24 :: (st: *MS_Decoder, data: *u8, len: Int32, pcm: *Int32, frame_size: s32, decode_fec: s32) -> s32 {
    return multistream_decode_native(
        st,
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) copy_channel_out_int24,
        frame_size,
        decode_fec,
        0,
        null
    );
}

copy_channel_out_int24 :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    i: Int32 = ---;

    short_dst := cast(*Int32) dst;
    if src != null {
        i = 0;
        while i < frame_size {
            short_dst[i * dst_stride + dst_channel] =
                float2int_in_opus_multistream_decoder(
                    8388608.0 * src[i * src_stride]
                );
            i += 1;
        }
    } else {
        i = 0;
        while i < frame_size {
            short_dst[i * dst_stride + dst_channel] = 0;
            i += 1;
        }
    }
}

multistream_decode_float :: (
    st: *MS_Decoder,
    data: *u8,
    len: Int32,
    pcm: *float32,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    return multistream_decode_native(
        st,
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) copy_channel_out_float,
        frame_size,
        decode_fec,
        0,
        null
    );
}

copy_channel_out_float :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    i: Int32 = ---;

    float_dst := cast(*float32) dst;
    if src != null {
        i = 0;
        while i < frame_size {
            float_dst[i * dst_stride + dst_channel] = src[i * src_stride];
            i += 1;
        }
    } else {
        i = 0;
        while i < frame_size {
            float_dst[i * dst_stride + dst_channel] = 0.0;
            i += 1;
        }
    }
}

multistream_decoder_destroy :: (st: *MS_Decoder) {
    free__in_opus_multistream_decoder(cast(*void) st);
}

ec_range_bytes_in_opus_multistream_decoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_multistream_decoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_multistream_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_multistream_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_multistream_decoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_multistream_decoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_opus_multistream_decoder :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_multistream_decoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_multistream_decoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

false__in_opus_multistream_decoder :: () -> s32 {
    return 0;
}

float2_int24_in_opus_multistream_decoder :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_opus_multistream_decoder(x);
}

realloc_in_opus_multistream_decoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_multistream_decoder :: (size: u64) -> *void {
    return alloc__in_opus_multistream_decoder(size);
}

globals_initialization_state_for_opus_multistream_decoder: u32;
initialize_globals_for_opus_multistream_decoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_multistream_decoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_multistream_decoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_multistream_decoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_multistream_decoder =
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
    SPREAD_ICDF_in_opus_multistream_decoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_multistream_decoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus_multistream_decoder, 2);
}

MS_Decoder :: struct {
    layout: Channel_Layout;
}

Copy_Channel_Out_Func :: #type (_: *void, _: s32, _: s32, _: *Res, _: s32, _: s32, _: *void);

