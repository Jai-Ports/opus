ERROR_STRINGS: [8] *s8;

TRIM_ICDF_in_celt: [11] u8;

SPREAD_ICDF_in_celt: [4] u8;

TAPSET_ICDF_in_celt: [3] u8;

TF_SELECT_TABLE: [4] [8] s8;

GAINS: [3] [3] Val16;

strerror_2 :: (error: s32) -> *s8 {
    if error > 0 || error < -7 {
        return c_string("unknown error");
    } else {
        return ERROR_STRINGS[-error];
    }
}

get_version_string :: () -> *s8 {
    return c_string("libopus 1.6.1");
}

alloc__in_celt :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_celt :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_celt :: (size: u64) -> *void {
    return alloc__in_celt(size);
}

free__in_celt :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

select_arch_in_celt :: () -> s32 {
    return 0;
}

ec_range_bytes_in_celt :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_celt :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_celt :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_celt :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_celt :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_celt :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

bits_to_bitrate_in_celt :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_celt :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

resampling_factor :: (rate: Int32) -> s32 {
    ret: s32 = ---;
    if rate == {
        case 48000;
            ret = 1;
        case 24000;
            ret = 2;
        case 16000;
            ret = 3;
        case 12000;
            ret = 4;
        case 8000;
            ret = 6;
        case;
            ret = 0;
    }
    return ret;
}

comb_filter :: (
    y: *Val32,
    x: *Val32,
    t0: s32,
    t1: s32,
    n: s32,
    g0: Val16,
    g1: Val16,
    tapset0: s32,
    tapset1: s32,
    window: *Celt_Coef,
    overlap: s32,
    arch: s32
) {

    if c_transpiler_float_equal(g0, 0.0) && c_transpiler_float_equal(g1, 0.0) {
        if x != y {
            move_memory(y, x, (cast,no_check(u64) n) * size_of(Val32) + cast,no_check(u64) (0 * (y - x)));
        }
        return;
    }

    t0 = ifx t0 > 15 then t0 else 15;
    t1 = ifx t1 > 15 then t1 else 15;
    g00 := g0 * GAINS[tapset0][0];
    g01 := g0 * GAINS[tapset0][1];
    g02 := g0 * GAINS[tapset0][2];
    g10 := g1 * GAINS[tapset1][0];
    g11 := g1 * GAINS[tapset1][1];
    g12 := g1 * GAINS[tapset1][2];
    x1 := x[-t1 + 1];
    x2 := x[-t1];
    x3 := x[-t1 - 1];
    x4 := x[-t1 - 2];

    if c_transpiler_float_equal(g0, g1) && t0 == t1 && tapset0 == tapset1 {
        overlap = 0;
    }
    i: s32 = 0;
    while i < overlap {
        x0 := x[i - t1 + 2];
        f := window[i] * window[i];
        y[i] =
            x[i] + (1.0 - f) * g00 * x[i - t0] + (1.0 - f) * g01 * (x[i - t0 + 1] + x[i - t0 - 1]) +
                (1.0 - f) * g02 * (x[i - t0 + 2] + x[i - t0 - 2]) + f * g10 * x2 + f * g11 * (x1 + x3) + f * g12 * (x0 + x4);

        y[i] = y[i];
        x4 = x3;
        x3 = x2;
        x2 = x1;
        x1 = x0;
        i += 1;
    }
    if c_transpiler_float_equal(g1, 0.0) {
        if x != y {
            move_memory(
                y + overlap,
                x + overlap,
                (cast,no_check(u64) (n - overlap)) * size_of(Val32) +
                cast,no_check(u64) (0 * (y + overlap - (x + overlap)))
            );
        }
        return;
    }

    comb_filter_const_c(y + i, x + i, t1, n - i, g10, g11, g12);
}

comb_filter_const_c :: (y: *Val32, x: *Val32, t: s32, n: s32, g10: Celt_Coef, g11: Celt_Coef, g12: Celt_Coef) {
    x4 := x[-t - 2];
    x3 := x[-t - 1];
    x2 := x[-t];
    x1 := x[-t + 1];
    if 0 < n {
        for i: 0..n - 1 {
            x0 := x[i - t + 2];
            y[i] = x[i] + g10 * x2 + g11 * (x1 + x3) + g12 * (x0 + x4);

            y[i] = y[i];
            x4 = x3;
            x3 = x2;
            x2 = x1;
            x1 = x0;
        }
    }
}

init_caps :: (m: *Custom_Mode, cap: *s32, lm: s32, c: s32) {
    i: s32 = 0;
    while i < m.nb_e_bands {
        n := ((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i]) << ((lm) & 31);
        cap[i] = (((cast(s32) m.cache.caps[m.nb_e_bands * (2 * lm + c - 1) + i]) + 64) * c * n) >> 2;
        i += 1;
    }
}

xcorr_kernel_c_in_celt :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_celt :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

celt_inner_prod_c_in_celt :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

false__in_celt :: () -> s32 {
    return 0;
}

get_pulses_in_celt :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_celt :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_celt :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

fast_atan2f_in_celt :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_celt :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_celt :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_celt :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_celt(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_celt(x / y);
    }
}

celt_cos_norm2_in_celt :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

mm_cvtss_si32_in_celt :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_celt :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_celt(a);
}

mm_set_ss_in_celt :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_celt :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_celt(mm_set_ss_in_celt(x));
}

float2_int16_in_celt :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_celt(x);
}

float2_int24_in_celt :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_celt(x);
}

globals_initialization_state_for_celt: u32;
initialize_globals_for_celt :: () {
    {
        state := atomic_load(*globals_initialization_state_for_celt);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_celt, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_celt) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_celt =
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
    SPREAD_ICDF_in_celt = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_celt = u8.[ 2, 1, 0 ];
    GAINS =
        [3] Val16.[
            Val16.[ cast(float32) 0.306640625, cast(float32) 0.217041015625, cast(float32) 0.129638671875 ],
            Val16.[ cast(float32) 0.4638671875, cast(float32) 0.26806640625, 0.0 ],
            Val16.[ cast(float32) 0.7998046875, cast(float32) 0.10009765625, 0.0 ]
        ];
    TF_SELECT_TABLE =
        [8] s8.[
            s8.[ 0, -1, 0, -1, 0, -1, 0, -1 ],
            s8.[ 0, -1, 0, -2, 1, 0, 1, -1 ],
            s8.[ 0, -2, 0, -3, 2, 0, 1, -1 ],
            s8.[ 0, -2, 0, -3, 3, 0, 1, -1 ]
        ];
    ERROR_STRINGS =
        *s8.[
            c_string("success"),
            c_string("invalid argument"),
            c_string("buffer too small"),
            c_string("internal error"),
            c_string("corrupted stream"),
            c_string("request not implemented"),
            c_string("invalid state"),
            c_string("memory allocation failed")
        ];
    atomic_store(*globals_initialization_state_for_celt, 2);
}

