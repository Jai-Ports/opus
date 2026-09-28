TRIM_ICDF_in_vq: [11] u8;

SPREAD_ICDF_in_vq: [4] u8;

TAPSET_ICDF_in_vq: [3] u8;

SPREAD_FACTOR: [3] s32;

ec_range_bytes_in_vq :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_vq :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_vq :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_vq :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_vq :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_vq :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_vq :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_vq :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_vq :: (size: u64) -> *void {
    return alloc__in_vq(size);
}

free__in_vq :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_vq :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_vq :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_vq :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_vq :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_vq(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_vq(x / y);
    }
}

celt_cos_norm2_in_vq :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

false__in_vq :: () -> s32 {
    return 0;
}

select_arch_in_vq :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_vq :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_vq :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

exp_rotation :: (x: *Celt_Norm, len: s32, dir: s32, stride: s32, k: s32, spread: s32) {

    stride2: s32 = 0;

    if 2 * k >= len || spread == 0 {
        return;
    }
    factor := SPREAD_FACTOR[spread - 1];

    gain := (1.0 * cast,no_check(Val32) len) / cast,no_check(Val32) (len + factor * k);
    theta := 0.5 * (gain * gain);

    c := cast,no_check(float32) cos(1.5707963267948966 * cast,no_check(float64) theta);
    s := cast,no_check(float32) cos(1.5707963267948966 * cast,no_check(float64) (1.0 - theta));

    if len >= 8 * stride {
        stride2 = 1;

        while (stride2 * stride2 + stride2) * stride + stride >> 2 < len {
            stride2 += 1;
        }
    }

    len = cast,no_check(s32) celt_udiv_in_vq(cast,no_check(Uint32) len, cast,no_check(Uint32) stride);
    if 0 < stride {
        for i: 0..stride - 1 {
            if dir < 0 {
                if stride2 != 0 {
                    exp_rotation1(x + i * len, len, stride2, s, c);
                }
                exp_rotation1(x + i * len, len, 1, c, s);
            } else {
                exp_rotation1(x + i * len, len, 1, c, -s);
                if stride2 != 0 {
                    exp_rotation1(x + i * len, len, stride2, s, -c);
                }
            }
        }
    }
}

exp_rotation1 :: (x: *Celt_Norm, len: s32, stride: s32, c: Val16, s: Val16) {
    xptr := x;
    ms := -s;

    i: s32 = 0;
    while i < len - stride {
        x1: Celt_Norm = ---;
        x1 = xptr[0];
        x2 := xptr[stride];
        xptr[stride] = c * x2 + s * x1;
        xptr.* = c * x1 + ms * x2;
        xptr += 1;
        i += 1;
    }
    xptr = *x[len - 2 * stride - 1];
    i = len - 2 * stride - 1;
    while i >= 0 {
        x1: Celt_Norm = ---;
        x1 = xptr[0];
        x2 := xptr[stride];
        xptr[stride] = c * x2 + s * x1;
        assignment_0: Celt_Norm = (c * x1 + ms * x2);
        ((c_transpiler_post_decrement(*(xptr))).*) = assignment_0;
        i -= 1;
    }
}

op_pvq_search_c :: (x: *Celt_Norm, iy: *s32, k: s32, n: s32, arch: s32) -> Val16 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    xy: Val32 = ---;
    yy: Val16 = ---;

    y := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) n)));
    signx := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) n)));

    sum: Val32 = 0.0;
    j: s32 = 0;
    while true {
        signx[j] = cast(s32) (c_transpiler_float_less(x[j], 0.0));

        x[j] = cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) x[j]);
        iy[j] = 0;
        y[j] = 0.0;
        if !(c_transpiler_pre_increment(*(j)) < n) break;
    }

    yy = 0.0;
    xy = yy;

    pulses_left := k;

    if k > n >> 1 {
        j = 0;
        while true {
            sum += x[j];
            if !(c_transpiler_pre_increment(*(j)) < n) break;
        }

        if !(c_transpiler_float_greater(sum, 1.0e-15) && c_transpiler_float_less(sum, 64.0)) {
            x[0] = 1.0;
            j = 1;
            while true {
                x[j] = 0.0;
                if !(c_transpiler_pre_increment(*(j)) < n) break;
            }
            sum = 1.0;
        }

        rcp := ((cast,no_check(float32) k) + 0.8) * (1.0 / sum);

        j = 0;
        while true {
            iy[j] = cast,no_check(s32) floor(cast,no_check(float64) (rcp * x[j]));

            y[j] = cast,no_check(Celt_Norm) iy[j];
            yy = yy + y[j] * y[j];
            xy = xy + x[j] * y[j];
            y[j] *= 2.0;
            pulses_left -= iy[j];
            if !(c_transpiler_pre_increment(*(j)) < n) break;
        }
    }

    if pulses_left > n + 3 {
        tmp := cast,no_check(Val16) pulses_left;
        yy = yy + tmp * tmp;
        yy = yy + tmp * y[0];
        iy[0] += pulses_left;
        pulses_left = 0;
    }

    if 0 < pulses_left {
        for i: 0..pulses_left - 1 {
            best_id: s32 = 0;

            yy = yy + 1.0;

            rxy := xy + x[0];

            ryy := yy + y[0];

            rxy = rxy * rxy;
            best_den := ryy;
            best_num := rxy;
            j = 1;
            while true {
                rxy = xy + x[j];

                ryy = yy + y[j];

                rxy = rxy * rxy;

                if cast(s64) (c_transpiler_float_greater((best_den * rxy), (ryy * best_num))) != 0 {
                    best_den = ryy;
                    best_num = rxy;
                    best_id = j;
                }
                if !(c_transpiler_pre_increment(*(j)) < n) break;
            }

            xy = xy + x[best_id];

            yy = yy + y[best_id];

            y[best_id] += 2.0;
            iy[best_id] += 1;
        }
    }

    j = 0;
    while true {
        iy[j] = iy[j] ^ -signx[j] + signx[j];
        if !(c_transpiler_pre_increment(*(j)) < n) break;
    }

    return yy;
}

alg_quant :: (
    x: *Celt_Norm,
    n: s32,
    k: s32,
    spread: s32,
    b: s32,
    enc: *Ec_Enc,
    gain: Val32,
    resynth: s32,
    arch: s32
) -> u32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    yy: Val32 = ---;
    collapse_mask: u32 = ---;

    iy := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) (n + 3))));

    exp_rotation(x, n, 1, b, k, spread);

    yy = op_pvq_search_c(x, iy, k, n, arch);
    collapse_mask = extract_collapse_mask(iy, n, b);
    encode_pulses(iy, n, k, enc);
    if resynth != 0 {
        normalise_residual(iy, x, n, yy, gain, 0);
    }

    if resynth != 0 {
        exp_rotation(x, n, -1, b, k, spread);
    }

    return collapse_mask;
}

normalise_residual :: (iy: *s32, x: *Celt_Norm, n: s32, ryy: Val32, gain: Val32, shift: s32) {
    t := ryy;
    g := (1.0 / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) t)) * gain;
    i: s32 = 0;

    while true {
        x[i] = iy[i] * g;
        if !(c_transpiler_pre_increment(*(i)) < n) break;
    }
}

extract_collapse_mask :: (iy: *s32, n: s32, b: s32) -> u32 {
    if b <= 1 {
        return 1;
    }

    n0 := cast,no_check(s32) celt_udiv_in_vq(cast,no_check(Uint32) n, cast,no_check(Uint32) b);
    collapse_mask: u32 = 0;
    i: s32 = 0;
    while true {
        {
            tmp: u32 = 0;
            j: s32 = 0;
            while true {
                tmp |= cast,no_check(u32) iy[i * n0 + j];
                if !(c_transpiler_pre_increment(*(j)) < n0) break;
            }
            collapse_mask |= cast,no_check(u32) ((cast(s32) (tmp != 0)) << ((i) & 31));
        }
        if !(c_transpiler_pre_increment(*(i)) < b) break;
    }
    return collapse_mask;
}

alg_unquant :: (x: *Celt_Norm, n: s32, k: s32, spread: s32, b: s32, dec: *Ec_Dec, gain: Val32) -> u32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    yy_shift: s32 = 0;

    iy := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) n)));
    ryy := decode_pulses(iy, n, k, dec);

    normalise_residual(iy, x, n, ryy, gain, yy_shift);
    exp_rotation(x, n, -1, b, k, spread);
    collapse_mask := extract_collapse_mask(iy, n, b);

    return collapse_mask;
}

renormalise_vector :: (x: *Celt_Norm, n: s32, gain: Val32, arch: s32) {
    e := 1.0e-15 + celt_inner_prod_c_in_vq(x, x, n);

    t := e;
    g := (1.0 / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) t)) * gain;

    xptr := x;
    if 0 < n {
        for i: 0..n - 1 {
            xptr.* = g * xptr.*;
            xptr += 1;
        }
    }
}

celt_inner_prod_c_in_vq :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

stereo_itheta :: (x: *Celt_Norm, y: *Celt_Norm, stereo: s32, n: s32, arch: s32) -> Int32 {
    emid, eside: Val32 = ---;

    eside = 0.0;
    emid = eside;
    if stereo != 0 {
        if 0 < n {
            for i: 0..n - 1 {
                m: Celt_Norm = ---;
                m = x[i] + y[i];
                s := x[i] - y[i];
                emid = emid + m * m;
                eside = eside + s * s;
            }
        }
    } else {
        emid += celt_inner_prod_c_in_vq(x, x, n);
        eside += celt_inner_prod_c_in_vq(y, y, n);
    }
    mid := cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) emid);
    side := cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) eside);

    itheta :=
        cast,no_check(s32) floor(
            cast,no_check(float64) (0.5 + (cast(float32) 1073741824.0) * celt_atan2p_norm_in_vq(side, mid))
        );

    return itheta;
}

get_pulses_in_vq :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_vq :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_vq :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

xcorr_kernel_c_in_vq :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_vq :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

silk_clz16_in_vq :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_vq :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

silk_ror32_in_vq :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_vq :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_vq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_vq :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_vq :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_vq :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_vq :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_vq :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_vq :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_vq :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_vq(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_vq(in_upper);
    }
}

silk_clz_frac_in_vq :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_vq(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_vq(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_vq :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_vq(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_vq :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_vq((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_vq((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_vq :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_vq((ifx B32 > 0 then B32 else -B32)) - 1;
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

globals_initialization_state_for_vq: u32;
initialize_globals_for_vq :: () {
    {
        state := atomic_load(*globals_initialization_state_for_vq);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_vq, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_vq) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_vq =
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
    SPREAD_ICDF_in_vq = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_vq = u8.[ 2, 1, 0 ];
    SPREAD_FACTOR = s32.[ 15, 10, 5 ];
    atomic_store(*globals_initialization_state_for_vq, 2);
}

cos :: (x: float64) -> float64 #foreign System_Library_libm_so_6;

