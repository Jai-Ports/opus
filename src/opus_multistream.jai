TRIM_ICDF_in_opus_multistream: [11] u8;

SPREAD_ICDF_in_opus_multistream: [4] u8;

TAPSET_ICDF_in_opus_multistream: [3] u8;

ec_range_bytes_in_opus_multistream :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus_multistream :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus_multistream :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus_multistream :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus_multistream :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus_multistream :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_opus_multistream :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus_multistream :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus_multistream :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

validate_layout :: (layout: *Channel_Layout) -> s32 {
    max_channel: s32 = ---;

    max_channel = layout.nb_streams + layout.nb_coupled_streams;
    if max_channel > 255 {
        return 0;
    }
    i: s32 = 0;
    while i < layout.nb_channels {
        if cast,no_check(s32) layout.mapping[i] >= max_channel && layout.mapping[i] != 255 {
            return 0;
        }
        i += 1;
    }
    return 1;
}

get_left_channel :: (layout: *Channel_Layout, stream_id: s32, prev: s32) -> s32 {
    i := (ifx prev < 0 then 0 else prev + 1);
    while i < layout.nb_channels {
        if cast,no_check(s32) layout.mapping[i] == stream_id * 2 {
            return i;
        }
        i += 1;
    }
    return -1;
}

get_right_channel :: (layout: *Channel_Layout, stream_id: s32, prev: s32) -> s32 {
    i := (ifx prev < 0 then 0 else prev + 1);
    while i < layout.nb_channels {
        if cast,no_check(s32) layout.mapping[i] == stream_id * 2 + 1 {
            return i;
        }
        i += 1;
    }
    return -1;
}

get_mono_channel :: (layout: *Channel_Layout, stream_id: s32, prev: s32) -> s32 {
    i := (ifx prev < 0 then 0 else prev + 1);
    while i < layout.nb_channels {
        if cast,no_check(s32) layout.mapping[i] == stream_id + layout.nb_coupled_streams {
            return i;
        }
        i += 1;
    }
    return -1;
}

align_in_opus_multistream :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

false__in_opus_multistream :: () -> s32 {
    return 0;
}

mm_cvtss_si32_in_opus_multistream :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_opus_multistream :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_opus_multistream(a);
}

mm_set_ss_in_opus_multistream :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_opus_multistream :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_opus_multistream(mm_set_ss_in_opus_multistream(x));
}

float2_int16_in_opus_multistream :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_opus_multistream(x);
}

float2_int24_in_opus_multistream :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_opus_multistream(x);
}

alloc__in_opus_multistream :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_opus_multistream :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus_multistream :: (size: u64) -> *void {
    return alloc__in_opus_multistream(size);
}

free__in_opus_multistream :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

globals_initialization_state_for_opus_multistream: u32;
initialize_globals_for_opus_multistream :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus_multistream);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus_multistream, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus_multistream) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus_multistream =
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
    SPREAD_ICDF_in_opus_multistream = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus_multistream = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus_multistream, 2);
}

Channel_Layout :: struct {
    nb_channels: s32;
    nb_streams: s32;
    nb_coupled_streams: s32;
    mapping: [256] u8;
}

