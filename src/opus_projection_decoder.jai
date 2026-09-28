// Generated directly from C by cpp_transpiler.
Projection_Decoder_in_opus_projection_decoder :: struct {
    demixing_matrix_size_in_bytes: Int32;
}

TRIM_ICDF_in_opus_projection_decoder: [11] u8;

SPREAD_ICDF_in_opus_projection_decoder: [4] u8;

TAPSET_ICDF_in_opus_projection_decoder: [3] u8;

ec_range_bytes_in_opus_projection_decoder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_projection_decoder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_projection_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_projection_decoder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_projection_decoder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_projection_decoder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_opus_projection_decoder :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_opus_projection_decoder :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_projection_decoder :: (size: u64) -> *void {
    return alloc__in_opus_projection_decoder(size);
}

free__in_opus_projection_decoder :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_opus_projection_decoder :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_opus_projection_decoder :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_opus_projection_decoder :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus_projection_decoder :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus_projection_decoder(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus_projection_decoder(x / y);
    }
}

celt_cos_norm2_in_opus_projection_decoder :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

select_arch_in_opus_projection_decoder :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_projection_decoder :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_projection_decoder :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

align_in_opus_projection_decoder :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

projection_decoder_get_size :: (channels: s32, streams: s32, coupled_streams: s32) -> Int32 {
    matrix_size := mapping_matrix_get_size(streams + coupled_streams, channels);
    if matrix_size == 0 {
        return 0;
    }

    decoder_size := multistream_decoder_get_size(streams, coupled_streams);
    if decoder_size == 0 {
        return 0;
    }

    return (align_in_opus_projection_decoder(
        cast,no_check(s32) (cast(u64) size_of(Projection_Decoder_in_opus_projection_decoder))
    ) + matrix_size) + decoder_size;
}

projection_decoder_create :: (
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    demixing_matrix: *u8,
    demixing_matrix_size: Int32,
    error: *s32
) -> *Projection_Decoder_in_opus_projection_decoder {
    size := projection_decoder_get_size(channels, streams, coupled_streams);
    if size == 0 {
        if error != null {
            error.* = -7;
        }
        return null;
    }
    st :=
        cast(*Projection_Decoder_in_opus_projection_decoder) alloc__in_opus_projection_decoder(
            cast,no_check(u64) size
        );
    if st == null {
        if error != null {
            error.* = -7;
        }
        return null;
    }

    ret := projection_decoder_init(st, fs, channels, streams, coupled_streams, demixing_matrix, demixing_matrix_size);
    if ret != 0 {
        free__in_opus_projection_decoder(cast(*void) st);
        st = null;
    }
    if error != null {
        error.* = ret;
    }
    return st;
}

projection_decoder_init :: (
    st: *Projection_Decoder_in_opus_projection_decoder,
    fs: Int32,
    channels: s32,
    streams: s32,
    coupled_streams: s32,
    demixing_matrix: *u8,
    demixing_matrix_size: Int32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    mapping: [255] u8 = ---;

    nb_input_streams := streams + coupled_streams;
    expected_matrix_size := cast,no_check(Int32) ((cast,no_check(u64) (nb_input_streams * channels)) * size_of(Int16));
    if expected_matrix_size != demixing_matrix_size {
        return -1;
    }

    buf :=
        cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
            cast,no_check(u64) (nb_input_streams * channels))));
    i: s32 = 0;
    while i < nb_input_streams * channels {
        s := (cast(s32) demixing_matrix[2 * i + 1]) << 8 | cast(s32) demixing_matrix[2 * i];
        s = s & 0xffff ^ 0x8000 - 0x8000;
        buf[i] = cast,no_check(Int16) s;
        i += 1;
    }

    st.demixing_matrix_size_in_bytes = mapping_matrix_get_size(channels, nb_input_streams);
    if st.demixing_matrix_size_in_bytes == 0 {
        return -1;
    }

    mapping_matrix_init(get_dec_demixing_matrix(st), channels, nb_input_streams, 0, buf, demixing_matrix_size);

    i = 0;
    while i < channels {
        mapping[i] = cast,no_check(u8) i;
        i += 1;
    }

    ret := multistream_decoder_init(get_multistream_decoder(st), fs, channels, streams, coupled_streams, mapping.data);

    return ret;
}

get_multistream_decoder :: (st: *Projection_Decoder_in_opus_projection_decoder) -> *MS_Decoder {
    return cast(*MS_Decoder) (cast(*void) ((cast(*s8) st) + align_in_opus_projection_decoder(
        cast,no_check(s32) (size_of(Projection_Decoder_in_opus_projection_decoder) +
        cast,no_check(u64) st.demixing_matrix_size_in_bytes)
    )));
}

get_dec_demixing_matrix :: (st: *Projection_Decoder_in_opus_projection_decoder) -> *Mapping_Matrix {
    return cast(*Mapping_Matrix) (cast(*void) ((cast(*s8) st) + align_in_opus_projection_decoder(
        cast,no_check(s32) (cast(u64) size_of(Projection_Decoder_in_opus_projection_decoder))
    )));
}

projection_decode :: (
    st: *Projection_Decoder_in_opus_projection_decoder,
    data: *u8,
    len: Int32,
    pcm: *Int16,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    return multistream_decode_native(
        get_multistream_decoder(st),
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) projection_copy_channel_out_short,
        frame_size,
        decode_fec,
        1,
        cast(*void) get_dec_demixing_matrix(st)
    );
}

projection_copy_channel_out_short :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    short_dst := cast(*Int16) dst;
    matrix := cast(*Mapping_Matrix) user_data;
    if dst_channel == 0 {
        fill_memory(short_dst, 0, cast,no_check(u64) (frame_size * dst_stride) * size_of(Int16));
    }

    if src != null {
        mapping_matrix_multiply_channel_out_short(
            matrix,
            src,
            dst_channel,
            src_stride,
            short_dst,
            dst_stride,
            frame_size
        );
    }
}

projection_decode24 :: (
    st: *Projection_Decoder_in_opus_projection_decoder,
    data: *u8,
    len: Int32,
    pcm: *Int32,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    return multistream_decode_native(
        get_multistream_decoder(st),
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) projection_copy_channel_out_int24,
        frame_size,
        decode_fec,
        0,
        cast(*void) get_dec_demixing_matrix(st)
    );
}

projection_copy_channel_out_int24 :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    short_dst := cast(*Int32) dst;
    matrix := cast(*Mapping_Matrix) user_data;
    if dst_channel == 0 {
        fill_memory(short_dst, 0, cast,no_check(u64) (frame_size * dst_stride) * size_of(Int32));
    }

    if src != null {
        mapping_matrix_multiply_channel_out_int24(
            matrix,
            src,
            dst_channel,
            src_stride,
            short_dst,
            dst_stride,
            frame_size
        );
    }
}

projection_decode_float :: (
    st: *Projection_Decoder_in_opus_projection_decoder,
    data: *u8,
    len: Int32,
    pcm: *float32,
    frame_size: s32,
    decode_fec: s32
) -> s32 {
    return multistream_decode_native(
        get_multistream_decoder(st),
        data,
        len,
        cast(*void) pcm,
        cast,no_check(Copy_Channel_Out_Func) projection_copy_channel_out_float,
        frame_size,
        decode_fec,
        0,
        cast(*void) get_dec_demixing_matrix(st)
    );
}

projection_copy_channel_out_float :: (
    dst: *void,
    dst_stride: s32,
    dst_channel: s32,
    src: *Res,
    src_stride: s32,
    frame_size: s32,
    user_data: *void
) {
    float_dst := cast(*float32) dst;
    matrix := cast(*Mapping_Matrix) user_data;

    if dst_channel == 0 {
        fill_memory(float_dst, 0, cast,no_check(u64) (frame_size * dst_stride) * size_of(float32));
    }

    if src != null {
        mapping_matrix_multiply_channel_out_float(
            matrix,
            src,
            dst_channel,
            src_stride,
            float_dst,
            dst_stride,
            frame_size
        );
    }
}

projection_decoder_ctl :: (
    st: *Projection_Decoder_in_opus_projection_decoder,
    request: s32,
    variadic_arguments: ..Any
) -> s32 {
    ap: Va_List = ---;
    ret: s32 = 0;

    start_variadic_arguments(cast(*void) ap.data, variadic_arguments);
    ret = multistream_decoder_ctl_va_list(get_multistream_decoder(st), request, ap.data);
    return ret;
}

projection_decoder_destroy :: (st: *Projection_Decoder_in_opus_projection_decoder) {
    free__in_opus_projection_decoder(cast(*void) st);
}

false__in_opus_projection_decoder :: () -> s32 {
    return 0;
}

globals_initialization_state_for_opus_projection_decoder: u32;
initialize_globals_for_opus_projection_decoder :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_projection_decoder);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_projection_decoder, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_projection_decoder) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_projection_decoder =
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
    SPREAD_ICDF_in_opus_projection_decoder = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_projection_decoder = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus_projection_decoder, 2);
}

