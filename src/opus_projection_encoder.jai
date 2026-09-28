// Generated directly from C by cpp_transpiler.
Projection_Encoder :: struct {
    mixing_matrix_size_in_bytes: Int32;
    demixing_matrix_size_in_bytes: Int32;
}

TRIM_ICDF_in_opus_projection_encoder: [11] u8;

SPREAD_ICDF_in_opus_projection_encoder: [4] u8;

TAPSET_ICDF_in_opus_projection_encoder: [3] u8;

ec_range_bytes_in_opus_projection_encoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_projection_encoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_projection_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_projection_encoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_projection_encoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_projection_encoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_opus_projection_encoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_opus_projection_encoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_projection_encoder :: (size: u64) -> *void {
    return alloc__in_opus_projection_encoder(size);
}

free__in_opus_projection_encoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_opus_projection_encoder :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_opus_projection_encoder :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_opus_projection_encoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus_projection_encoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus_projection_encoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus_projection_encoder(x / y);
    }
}

celt_cos_norm2_in_opus_projection_encoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

select_arch_in_opus_projection_encoder :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_projection_encoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_projection_encoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

align_in_opus_projection_encoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

projection_ambisonics_encoder_get_size :: (channels: s32, mapping_family: s32) -> Int32 {
    nb_streams: s32 = ---;
    nb_coupled_streams: s32 = ---;
    order_plus_one: s32 = ---;
    mixing_matrix_rows, mixing_matrix_cols: s32 = ---;
    demixing_matrix_rows, demixing_matrix_cols: s32 = ---;

    ret := get_streams_from_channels(channels, mapping_family, *nb_streams, *nb_coupled_streams, *order_plus_one);
    if ret != 0 {
        return 0;
    }

    if order_plus_one == 2 {
        mixing_matrix_rows = MAPPING_MATRIX_FOA_MIXING.rows;
        mixing_matrix_cols = MAPPING_MATRIX_FOA_MIXING.cols;
        demixing_matrix_rows = MAPPING_MATRIX_FOA_DEMIXING.rows;
        demixing_matrix_cols = MAPPING_MATRIX_FOA_DEMIXING.cols;
    } else if order_plus_one == 3 {
        mixing_matrix_rows = MAPPING_MATRIX_SOA_MIXING.rows;
        mixing_matrix_cols = MAPPING_MATRIX_SOA_MIXING.cols;
        demixing_matrix_rows = MAPPING_MATRIX_SOA_DEMIXING.rows;
        demixing_matrix_cols = MAPPING_MATRIX_SOA_DEMIXING.cols;
    } else if order_plus_one == 4 {
        mixing_matrix_rows = MAPPING_MATRIX_TOA_MIXING.rows;
        mixing_matrix_cols = MAPPING_MATRIX_TOA_MIXING.cols;
        demixing_matrix_rows = MAPPING_MATRIX_TOA_DEMIXING.rows;
        demixing_matrix_cols = MAPPING_MATRIX_TOA_DEMIXING.cols;
    } else if order_plus_one == 5 {
        mixing_matrix_rows = MAPPING_MATRIX_FOURTHOA_MIXING.rows;
        mixing_matrix_cols = MAPPING_MATRIX_FOURTHOA_MIXING.cols;
        demixing_matrix_rows = MAPPING_MATRIX_FOURTHOA_DEMIXING.rows;
        demixing_matrix_cols = MAPPING_MATRIX_FOURTHOA_DEMIXING.cols;
    } else if order_plus_one == 6 {
        mixing_matrix_rows = MAPPING_MATRIX_FIFTHOA_MIXING.rows;
        mixing_matrix_cols = MAPPING_MATRIX_FIFTHOA_MIXING.cols;
        demixing_matrix_rows = MAPPING_MATRIX_FIFTHOA_DEMIXING.rows;
        demixing_matrix_cols = MAPPING_MATRIX_FIFTHOA_DEMIXING.cols;
    } else {
        return 0;
    }

    mixing_matrix_size := mapping_matrix_get_size(mixing_matrix_rows, mixing_matrix_cols);
    if mixing_matrix_size == 0 {
        return 0;
    }

    demixing_matrix_size := mapping_matrix_get_size(demixing_matrix_rows, demixing_matrix_cols);
    if demixing_matrix_size == 0 {
        return 0;
    }

    encoder_size := multistream_encoder_get_size(nb_streams, nb_coupled_streams);
    if encoder_size == 0 {
        return 0;
    }

    return align_in_opus_projection_encoder(cast,no_check(s32) (cast(u64) size_of(Projection_Encoder))) + mixing_matrix_size + demixing_matrix_size + encoder_size;
}

get_streams_from_channels :: (
    channels: s32,
    mapping_family: s32,
    streams: *s32,
    coupled_streams: *s32,
    order_plus_one: *s32
) -> s32 {
    if mapping_family == 3 {
        if get_order_plus_one_from_channels(channels, order_plus_one) != 0 {
            return -1;
        }
        if streams != null {
            streams.* = (channels + 1) / 2;
        }
        if coupled_streams != null {
            coupled_streams.* = channels / 2;
        }
        return 0;
    }
    return -1;
}

get_order_plus_one_from_channels :: (channels: s32, order_plus_one: *s32) -> s32 {
    if channels < 1 || channels > 227 {
        return -1;
    }

    order_plus_one_value := cast,no_check(s32) isqrt32(cast,no_check(Uint32) channels);
    acn_channels := order_plus_one_value * order_plus_one_value;
    nondiegetic_channels := channels - acn_channels;
    if nondiegetic_channels != 0 && nondiegetic_channels != 2 {
        return -1;
    }

    if order_plus_one != null {
        order_plus_one.* = order_plus_one_value;
    }
    return 0;
}

projection_ambisonics_encoder_create :: (
    fs: Int32,
    channels: s32,
    mapping_family: s32,
    streams: *s32,
    coupled_streams: *s32,
    application: s32,
    error: *s32
) -> *Projection_Encoder {
    size := projection_ambisonics_encoder_get_size(channels, mapping_family);
    if size == 0 {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    st := cast(*Projection_Encoder) alloc__in_opus_projection_encoder(cast,no_check(u64) size);
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }

    ret := projection_ambisonics_encoder_init(st, fs, channels, mapping_family, streams, coupled_streams, application);
    if ret != 0 {
        free__in_opus_projection_encoder(cast(*void) st);
        st = null;
    }
    if error != null {
        error.* = ret;
    }
    return st;
}

projection_ambisonics_encoder_init :: (
    st: *Projection_Encoder,
    fs: Int32,
    channels: s32,
    mapping_family: s32,
    streams: *s32,
    coupled_streams: *s32,
    application: s32
) -> s32 {
    mixing_matrix: *Mapping_Matrix = ---;
    demixing_matrix: *Mapping_Matrix = ---;

    order_plus_one: s32 = ---;
    mapping: [255] u8 = ---;

    if streams == null || coupled_streams == null {
        return -1;
    }

    if get_streams_from_channels(channels, mapping_family, streams, coupled_streams, *order_plus_one) != 0 {
        return -1;
    }

    if mapping_family == 3 {
        mixing_matrix = get_mixing_matrix(st);
        if order_plus_one == 2 {
            mapping_matrix_init(
                mixing_matrix,
                MAPPING_MATRIX_FOA_MIXING.rows,
                MAPPING_MATRIX_FOA_MIXING.cols,
                MAPPING_MATRIX_FOA_MIXING.gain,
                MAPPING_MATRIX_FOA_MIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FOA_MIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 3 {
            mapping_matrix_init(
                mixing_matrix,
                MAPPING_MATRIX_SOA_MIXING.rows,
                MAPPING_MATRIX_SOA_MIXING.cols,
                MAPPING_MATRIX_SOA_MIXING.gain,
                MAPPING_MATRIX_SOA_MIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_SOA_MIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 4 {
            mapping_matrix_init(
                mixing_matrix,
                MAPPING_MATRIX_TOA_MIXING.rows,
                MAPPING_MATRIX_TOA_MIXING.cols,
                MAPPING_MATRIX_TOA_MIXING.gain,
                MAPPING_MATRIX_TOA_MIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_TOA_MIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 5 {
            mapping_matrix_init(
                mixing_matrix,
                MAPPING_MATRIX_FOURTHOA_MIXING.rows,
                MAPPING_MATRIX_FOURTHOA_MIXING.cols,
                MAPPING_MATRIX_FOURTHOA_MIXING.gain,
                MAPPING_MATRIX_FOURTHOA_MIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FOURTHOA_MIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 6 {
            mapping_matrix_init(
                mixing_matrix,
                MAPPING_MATRIX_FIFTHOA_MIXING.rows,
                MAPPING_MATRIX_FIFTHOA_MIXING.cols,
                MAPPING_MATRIX_FIFTHOA_MIXING.gain,
                MAPPING_MATRIX_FIFTHOA_MIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FIFTHOA_MIXING_DATA.count * size_of(Int16))
            );
        } else {
            return -1;
        }

        st.mixing_matrix_size_in_bytes = mapping_matrix_get_size(mixing_matrix.rows, mixing_matrix.cols);
        if st.mixing_matrix_size_in_bytes == 0 {
            return -1;
        }

        demixing_matrix = get_enc_demixing_matrix(st);
        if order_plus_one == 2 {
            mapping_matrix_init(
                demixing_matrix,
                MAPPING_MATRIX_FOA_DEMIXING.rows,
                MAPPING_MATRIX_FOA_DEMIXING.cols,
                MAPPING_MATRIX_FOA_DEMIXING.gain,
                MAPPING_MATRIX_FOA_DEMIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FOA_DEMIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 3 {
            mapping_matrix_init(
                demixing_matrix,
                MAPPING_MATRIX_SOA_DEMIXING.rows,
                MAPPING_MATRIX_SOA_DEMIXING.cols,
                MAPPING_MATRIX_SOA_DEMIXING.gain,
                MAPPING_MATRIX_SOA_DEMIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_SOA_DEMIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 4 {
            mapping_matrix_init(
                demixing_matrix,
                MAPPING_MATRIX_TOA_DEMIXING.rows,
                MAPPING_MATRIX_TOA_DEMIXING.cols,
                MAPPING_MATRIX_TOA_DEMIXING.gain,
                MAPPING_MATRIX_TOA_DEMIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_TOA_DEMIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 5 {
            mapping_matrix_init(
                demixing_matrix,
                MAPPING_MATRIX_FOURTHOA_DEMIXING.rows,
                MAPPING_MATRIX_FOURTHOA_DEMIXING.cols,
                MAPPING_MATRIX_FOURTHOA_DEMIXING.gain,
                MAPPING_MATRIX_FOURTHOA_DEMIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FOURTHOA_DEMIXING_DATA.count * size_of(Int16))
            );
        } else if order_plus_one == 6 {
            mapping_matrix_init(
                demixing_matrix,
                MAPPING_MATRIX_FIFTHOA_DEMIXING.rows,
                MAPPING_MATRIX_FIFTHOA_DEMIXING.cols,
                MAPPING_MATRIX_FIFTHOA_DEMIXING.gain,
                MAPPING_MATRIX_FIFTHOA_DEMIXING_DATA.data,
                cast,no_check(Int32) (MAPPING_MATRIX_FIFTHOA_DEMIXING_DATA.count * size_of(Int16))
            );
        } else {
            return -1;
        }

        st.demixing_matrix_size_in_bytes = mapping_matrix_get_size(demixing_matrix.rows, demixing_matrix.cols);
        if st.demixing_matrix_size_in_bytes == 0 {
            return -1;
        }
    } else {
        return -5;
    }

    if streams.* + coupled_streams.* > mixing_matrix.rows ||
        channels > mixing_matrix.cols ||
        channels > demixing_matrix.rows ||
        streams.* + coupled_streams.* > demixing_matrix.cols {
        return -1;
    }

    if 0 < channels {
        for i: 0..channels - 1 {
            mapping[i] = cast,no_check(u8) i;
        }
    }

    ms_encoder := get_multistream_encoder(st);
    ret := multistream_encoder_init(ms_encoder, fs, channels, streams.*, coupled_streams.*, mapping.data, application);
    return ret;
}

get_multistream_encoder :: (st: *Projection_Encoder) -> *MS_Encoder {
    return cast(*MS_Encoder) (cast(*void) ((cast(*s8) st) + align_in_opus_projection_encoder(
        cast,no_check(s32) ((size_of(Projection_Encoder) + cast,no_check(u64) st.mixing_matrix_size_in_bytes) +
        cast,no_check(u64) st.demixing_matrix_size_in_bytes)
    )));
}

get_enc_demixing_matrix :: (st: *Projection_Encoder) -> *Mapping_Matrix {
    return cast(*Mapping_Matrix) (cast(*void) ((cast(*s8) st) + align_in_opus_projection_encoder(
        cast,no_check(s32) (size_of(Projection_Encoder) + cast,no_check(u64) st.mixing_matrix_size_in_bytes)
    )));
}

get_mixing_matrix :: (st: *Projection_Encoder) -> *Mapping_Matrix {
    return cast(*Mapping_Matrix) (cast(*void) ((cast(*s8) st) + align_in_opus_projection_encoder(cast,no_check(s32) (cast(u64) size_of(Projection_Encoder)))));
}

projection_encode :: (st: *Projection_Encoder, pcm: *Int16, frame_size: s32, data: *u8, max_data_bytes: Int32) -> s32 {
    return multistream_encode_native(
        get_multistream_encoder(st),
        cast,no_check(Copy_Channel_In_Func) projection_copy_channel_in_short,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        16,
        cast,no_check(Downmix_Func) downmix_int,
        0,
        cast(*void) get_mixing_matrix(st)
    );
}

projection_copy_channel_in_short :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    mapping_matrix_multiply_channel_in_short(
        cast(*Mapping_Matrix) user_data,
        cast(*Int16) src,
        src_stride,
        dst,
        src_channel,
        dst_stride,
        frame_size
    );
}

projection_encode24 :: (
    st: *Projection_Encoder,
    pcm: *Int32,
    frame_size: s32,
    data: *u8,
    max_data_bytes: Int32
) -> s32 {
    return multistream_encode_native(
        get_multistream_encoder(st),
        cast,no_check(Copy_Channel_In_Func) projection_copy_channel_in_int24,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        24,
        cast,no_check(Downmix_Func) downmix_int,
        0,
        cast(*void) get_mixing_matrix(st)
    );
}

projection_copy_channel_in_int24 :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    mapping_matrix_multiply_channel_in_int24(
        cast(*Mapping_Matrix) user_data,
        cast(*Int32) src,
        src_stride,
        dst,
        src_channel,
        dst_stride,
        frame_size
    );
}

projection_encode_float :: (
    st: *Projection_Encoder,
    pcm: *float32,
    frame_size: s32,
    data: *u8,
    max_data_bytes: Int32
) -> s32 {
    return multistream_encode_native(
        get_multistream_encoder(st),
        cast,no_check(Copy_Channel_In_Func) projection_copy_channel_in_float,
        cast(*void) pcm,
        frame_size,
        data,
        max_data_bytes,
        24,
        cast,no_check(Downmix_Func) downmix_float,
        1,
        cast(*void) get_mixing_matrix(st)
    );
}

projection_copy_channel_in_float :: (
    dst: *Res,
    dst_stride: s32,
    src: *void,
    src_stride: s32,
    src_channel: s32,
    frame_size: s32,
    user_data: *void
) {
    mapping_matrix_multiply_channel_in_float(
        cast(*Mapping_Matrix) user_data,
        cast(*float32) src,
        src_stride,
        dst,
        src_channel,
        dst_stride,
        frame_size
    );
}

projection_encoder_destroy :: (st: *Projection_Encoder) {
    free__in_opus_projection_encoder(cast(*void) st);
}

projection_encoder_ctl :: (st: *Projection_Encoder, request: s32, variadic_arguments: ..Any) -> s32 {
    ap: Va_List = ---;
    demixing_matrix: *Mapping_Matrix = ---;
    ms_encoder: *MS_Encoder = ---;
    ret: s32 = ---;
    value: *Int32 = ---;
    value_2: *Int32 = ---;
    i: s32 = ---;
    j: s32 = ---;
    k: s32 = ---;
    l: s32 = ---;
    nb_input_streams: s32 = ---;
    nb_output_streams: s32 = ---;
    external_char: *u8 = ---;
    internal_short: *Int16 = ---;
    external_size: Int32 = ---;
    internal_size: Int32 = ---;
    code_block_to_execute: s64 = 57;
    // The transpiler had to use this control-flow loop because the source code used a goto, which Jai does not support.
    while c_transpiler_dispatch := true {
        if code_block_to_execute < 0 break;
        if code_block_to_execute == {
            case 12; {
                if i < nb_input_streams {
                    code_block_to_execute = 20;
                    continue c_transpiler_dispatch;
                } else {
                    return ret;
                }
            }
            case 14; {
                while c_transpiler_local_loop := true {
                    if j < nb_output_streams {
                        k = demixing_matrix.rows * i + j;
                        external_char[2 * l] = cast,no_check(u8) internal_short[k];
                        external_char[2 * l + 1] = cast,no_check(u8) ((cast(s32) internal_short[k]) >> 8);
                        l += 1;
                        j += 1;
                        continue c_transpiler_local_loop;
                    } else {
                        i += 1;
                        code_block_to_execute = 12;
                        continue c_transpiler_dispatch;
                    }
                }
            }
            case 20; {
                j = 0;
                code_block_to_execute = 14;
                continue c_transpiler_dispatch;
            }
            case 57; {
                ret = 0;
                ms_encoder = get_multistream_encoder(st);
                demixing_matrix = get_enc_demixing_matrix(st);
                start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
                c_transpiler_switch_value_57 := request;
                if c_transpiler_switch_value_57 == {
                    case cast(s32) 6003; {
                        value = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value == null {
                            return -1;
                        } else {
                            value.* =
                                cast,no_check(Int32) ((cast,no_check(u64) (ms_encoder.layout.nb_channels * (ms_encoder.layout.nb_streams + ms_encoder.layout.nb_coupled_streams))) *
                                    size_of(Int16));
                            return ret;
                        }
                    }
                    case cast(s32) 6001; {
                        value_2 = c_transpiler_va_arg(cast(*void) (ap.data), *Int32);
                        if value_2 == null {
                            return -1;
                        } else {
                            value_2.* = demixing_matrix.gain;
                            return ret;
                        }
                    }
                    case cast(s32) 6005; {
                        nb_input_streams = ms_encoder.layout.nb_streams + ms_encoder.layout.nb_coupled_streams;
                        nb_output_streams = ms_encoder.layout.nb_channels;
                        external_char = c_transpiler_va_arg(cast(*void) (ap.data), *u8);
                        external_size = c_transpiler_va_arg(cast(*void) (ap.data), Int32);
                        if external_char == null {
                            return -1;
                        } else {
                            internal_short = mapping_matrix_get_data(demixing_matrix);
                            internal_size =
                                cast,no_check(Int32) ((cast,no_check(u64) (nb_input_streams * nb_output_streams)) *
                                    size_of(Int16));
                            if external_size != internal_size {
                                return -1;
                            } else {
                                l = 0;
                                i = 0;
                                code_block_to_execute = 12;
                                continue c_transpiler_dispatch;
                            }
                        }
                    }
                    case; {
                        ret = multistream_encoder_ctl_va_list(ms_encoder, request, ap.data);
                        return ret;
                    }
                }
            }
        }
        assert(false, tprint("invalid code block to execute %", code_block_to_execute));
        break;
    }
    return unreachable_value(s32);
}

false__in_opus_projection_encoder :: () -> s32 {
    return 0;
}

globals_initialization_state_for_opus_projection_encoder: u32;
initialize_globals_for_opus_projection_encoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_projection_encoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_projection_encoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_projection_encoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_projection_encoder =
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
    SPREAD_ICDF_in_opus_projection_encoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_projection_encoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus_projection_encoder, 2);
}

Mapping_Matrix :: struct {
    rows: s32;
    cols: s32;
    gain: s32;
}

