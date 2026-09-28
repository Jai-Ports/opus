// Generated directly from C by cpp_transpiler.
mm_cvtss_si32_in_mathops :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_mathops :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_mathops(a);
}

mm_set_ss_in_mathops :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_mathops :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_mathops(mm_set_ss_in_mathops(x));
}

float2_int16_in_mathops :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_mathops(x);
}

float2_int24_in_mathops :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_mathops(x);
}

ec_range_bytes_in_mathops :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_mathops :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_mathops :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_mathops :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_mathops :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_mathops :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_mathops :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_mathops :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_mathops :: (size: u64) -> *void {
    return alloc__in_mathops(size);
}

free__in_mathops :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

isqrt32 :: (val: Uint32) -> u32 {
    g: u32 = 0;
    bshift := ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(val) - 1) >> 1;
    b := (cast(u32) 1) << ((bshift) & 31);
    while true {
        {
            t := (g << 1 + b) << ((bshift) & 31);
            if t <= val {
                g += b;
                val -= t;
            }
            c_transpiler_compound_shr(*(b), (cast(s32) 1), u32, u32);
            bshift -= 1;
        }
        if !(bshift >= 0) break;
    }
    return g;
}

fast_atan2f_in_mathops :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_mathops :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_mathops :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_mathops :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_mathops(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_mathops(x / y);
    }
}

celt_cos_norm2_in_mathops :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

celt_float2int16_c :: (in: *float32, out: *s16, cnt: s32) {
    if 0 < cnt {
        for i: 0..cnt - 1 {
            out[i] = float2_int16_in_mathops(in[i]);
        }
    }
}

limit2_checkwithin1_c :: (samples: *float32, cnt: s32) -> s32 {
    if cnt <= 0 {
        return 1;
    }

    if 0 < cnt {
        for i: 0..cnt - 1 {
            clipped_val := samples[i];
            clipped_val = ifx c_transpiler_float_greater(-2.0, clipped_val) then -2.0 else clipped_val;
            clipped_val = ifx c_transpiler_float_less(2.0, clipped_val) then 2.0 else clipped_val;
            samples[i] = clipped_val;
        }
    }

    return 0;
}

