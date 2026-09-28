// Generated directly from C by cpp_transpiler.
TRIM_ICDF_in_pitch: [11] u8;

SPREAD_ICDF_in_pitch: [4] u8;

TAPSET_ICDF_in_pitch: [3] u8;

SECOND_CHECK: [16] s32;

ec_range_bytes_in_pitch :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_pitch :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_pitch :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_pitch :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_pitch :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_pitch :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_pitch :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_pitch :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_pitch :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

pitch_downsample :: (x: **Celt_Sig, x_lp: *Val16, len: s32, c: s32, factor: s32, arch: s32) {
    ac: [5] Val32 = ---;
    tmp: Val16 = 1.0;
    lpc: [4] Val16 = ---;
    lpc2: [5] Val16 = ---;
    c1: Val16 = 0.8;
    offset := factor / 2;

    if 1 < len {
        for i: 1..len - 1 {
            x_lp[i] = 0.25 * x[0][factor * i - offset] + 0.25 * x[0][factor * i + offset] + 0.5 * x[0][factor * i];
        }
    }
    x_lp[0] = 0.25 * x[0][offset] + 0.5 * x[0][0];
    if c == 2 {
        if 1 < len {
            for i: 1..len - 1 {
                x_lp[i] += 0.25 * x[1][factor * i - offset] + 0.25 * x[1][factor * i + offset] + 0.5 * x[1][factor * i];
            }
        }
        x_lp[0] += 0.25 * x[1][offset] + 0.5 * x[1][0];
    }

    celt_autocorr(x_lp, ac.data, null, 0, 4, len, arch);

    ac[0] *= 1.0001;

    if 1 <= 4 {
        for i: 1..cast(s32) 4 {
            ac[i] -= (ac[i] * (0.008 * cast,no_check(float32) i)) * (0.008 * cast,no_check(float32) i);
        }
    }

    celt_lpc(lpc.data, ac.data, 4);
    for i: 0..cast(s32) 4 - 1 {
        tmp = 0.9 * tmp;
        lpc[i] = lpc[i] * tmp;
    }

    lpc2[0] = lpc[0] + 0.8;
    lpc2[1] = lpc[1] + c1 * lpc[0];
    lpc2[2] = lpc[2] + c1 * lpc[1];
    lpc2[3] = lpc[3] + c1 * lpc[2];
    lpc2[4] = c1 * lpc[3];
    celt_fir5(x_lp, lpc2.data, len);
}

celt_fir5 :: (x: *Val16, num: *Val16, n: s32) {
    num0 := num[0];
    num1 := num[1];
    num2 := num[2];
    num3 := num[3];
    num4 := num[4];
    mem0: Val32 = 0.0;
    mem1: Val32 = 0.0;
    mem2: Val32 = 0.0;
    mem3: Val32 = 0.0;
    mem4: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            sum := x[i];
            sum = sum + num0 * mem0;
            sum = sum + num1 * mem1;
            sum = sum + num2 * mem2;
            sum = sum + num3 * mem3;
            sum = sum + num4 * mem4;
            mem4 = mem3;
            mem3 = mem2;
            mem2 = mem1;
            mem1 = mem0;
            mem0 = x[i];
            x[i] = sum;
        }
    }
}

pitch_search :: (x_lp: *Val16, y: *Val16, len: s32, max_pitch: s32, pitch: *s32, arch: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    best_pitch: [2] s32;

    offset: s32 = ---;

    lag := len + max_pitch;

    x_lp4 := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) (len >> 2))));
    y_lp4 := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) (lag >> 2))));
    xcorr := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) (max_pitch >> 1))));

    j: s32 = 0;
    while j < len >> 2 {
        x_lp4[j] = x_lp[2 * j];
        j += 1;
    }
    j = 0;
    while j < lag >> 2 {
        y_lp4[j] = y[2 * j];
        j += 1;
    }

    celt_pitch_xcorr_c(x_lp4, y_lp4, xcorr, len >> 2, max_pitch >> 2, arch);

    find_best_pitch(xcorr, y_lp4, len >> 2, max_pitch >> 2, best_pitch.data);

    i: s32 = 0;
    while i < max_pitch >> 1 {
        xcorr[i] = 0.0;
        if absolute_value(i - 2 * best_pitch[0]) > 2 && absolute_value(i - 2 * best_pitch[1]) > 2 {
            i += 1;
            continue;
        }

        sum := celt_inner_prod_c_in_pitch(x_lp, y + i, len >> 1);

        xcorr[i] = ifx c_transpiler_float_greater(-1.0, sum) then -1.0 else sum;
        i += 1;
    }
    find_best_pitch(xcorr, y, len >> 1, max_pitch >> 1, best_pitch.data);

    if best_pitch[0] > 0 && best_pitch[0] < max_pitch >> 1 - 1 {
        a: Val32 = ---;
        a = xcorr[best_pitch[0] - 1];
        b := xcorr[best_pitch[0]];
        c := xcorr[best_pitch[0] + 1];
        if c_transpiler_float_greater((c - a), (0.7 * (b - a))) {
            offset = 1;
        } else if c_transpiler_float_greater((a - c), (0.7 * (b - c))) {
            offset = -1;
        } else {
            offset = 0;
        }
    } else {
        offset = 0;
    }
    pitch.* = 2 * best_pitch[0] - offset;
}

find_best_pitch :: (xcorr: *Val32, y: *Val16, len: s32, max_pitch: s32, best_pitch: *s32) {
    syy: Val32 = 1.0;
    best_num: [2] Val16 = ---;
    best_den: [2] Val32 = ---;

    best_num[0] = -1.0;
    best_num[1] = -1.0;
    best_den[0] = 0.0;
    best_den[1] = 0.0;
    best_pitch[0] = 0;
    best_pitch[1] = 1;
    if 0 < len {
        for j: 0..len - 1 {
            syy = syy + y[j] * y[j];
        }
    }
    if 0 < max_pitch {
        for i: 0..max_pitch - 1 {
            if c_transpiler_float_greater(xcorr[i], 0.0) {
                xcorr16 := xcorr[i];

                xcorr16 *= 1.0e-12;

                num := xcorr16 * xcorr16;
                if c_transpiler_float_greater((num * best_den[1]), (best_num[1] * syy)) {
                    if c_transpiler_float_greater((num * best_den[0]), (best_num[0] * syy)) {
                        best_num[1] = best_num[0];
                        best_den[1] = best_den[0];
                        best_pitch[1] = best_pitch[0];
                        best_num[0] = num;
                        best_den[0] = syy;
                        best_pitch[0] = i;
                    } else {
                        best_num[1] = num;
                        best_den[1] = syy;
                        best_pitch[1] = i;
                    }
                }
            }
            syy += y[i + len] * y[i + len] - y[i] * y[i];
            syy = ifx c_transpiler_float_greater(1.0, syy) then 1.0 else syy;
        }
    }
}

celt_inner_prod_c_in_pitch :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

celt_pitch_xcorr_c :: (x: *Val16, y: *Val16, xcorr: *Val32, len: s32, max_pitch: s32, arch: s32) {
    (((cast,no_check(u64) x) & 3) == 0);
    i: s32 = 0;
    while i < max_pitch - 3 {
        sum := Val32.[ 0.0, 0.0, 0.0, 0.0 ];

        xcorr_kernel_c_in_pitch(x, y + i, sum.data, len);

        xcorr[i] = sum[0];
        xcorr[i + 1] = sum[1];
        xcorr[i + 2] = sum[2];
        xcorr[i + 3] = sum[3];
        i += 4;
    }

    while i < max_pitch {
        sum := celt_inner_prod_c_in_pitch(x, y + i, len);
        xcorr[i] = sum;
        i += 1;
    }
}

xcorr_kernel_c_in_pitch :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

remove_doubling :: (
    x: *Val16,
    maxperiod: s32,
    minperiod: s32,
    n: s32,
    t0: *s32,
    prev_period: s32,
    prev_gain: Val16,
    arch: s32
) -> Val16 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    t: s32 = ---;
    t0_value: s32 = ---;
    g, g0: Val16 = ---;
    xy: Val32 = ---;
    xx_: Val32 = ---;
    xy2: Val32 = ---;
    xcorr: [3] Val32 = ---;

    minperiod0 := minperiod;
    maxperiod /= 2;
    minperiod /= 2;
    t0.* /= 2;
    prev_period /= 2;
    n /= 2;
    x += maxperiod;
    if t0.* >= maxperiod {
        t0.* = maxperiod - 1;
    }

    t0_value = t0.*;
    t = t0_value;
    yy_lookup := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) (maxperiod + 1))));
    dual_inner_prod_c_in_pitch(x, x, x - t0_value, n, *xx_, *xy);
    yy_lookup[0] = xx_;
    yy := xx_;
    if 1 <= maxperiod {
        for i: 1..maxperiod {
            yy = yy + x[-i] * x[-i] - x[n - i] * x[n - i];
            yy_lookup[i] = ifx c_transpiler_float_greater(0.0, yy) then 0.0 else yy;
        }
    }
    yy = yy_lookup[t0_value];
    best_xy := xy;
    best_yy := yy;
    g0 = compute_pitch_gain(xy, xx_, yy);
    g = g0;

    if 2 <= 15 {
        for k: 2..cast(s32) 15 {
            cont: Val16 = 0.0;

            t1 :=
                cast,no_check(s32) celt_udiv_in_pitch(
                    cast,no_check(Uint32) (2 * t0_value + k),
                    cast,no_check(Uint32) (2 * k)
                );
            if t1 < minperiod {
                break;
            }

            t1b: s32 = ifx k == 2
                then ifx t1 + t0_value > maxperiod
                    then t0_value
                    else t0_value + t1
                else cast,no_check(s32) celt_udiv_in_pitch(
                    cast,no_check(Uint32) (2 * SECOND_CHECK[k] * t0_value + k),
                    cast,no_check(Uint32) (2 * k)
                );
            dual_inner_prod_c_in_pitch(x, *x[-t1], *x[-t1b], n, *xy, *xy2);
            xy = 0.5 * (xy + xy2);
            yy = 0.5 * (yy_lookup[t1] + yy_lookup[t1b]);
            g1 := compute_pitch_gain(xy, xx_, yy);
            if absolute_value(t1 - prev_period) <= 1 {
                cont = prev_gain;
            } else if absolute_value(t1 - prev_period) <= 2 && 5 * k * k < t0_value {
                cont = 0.5 * prev_gain;
            } else {
                cont = 0.0;
            }
            thresh := (ifx c_transpiler_float_greater(0.3, (0.7 * g0 - cont)) then 0.3 else 0.7 * g0 - cont);

            if t1 < 3 * minperiod {
                thresh = ifx c_transpiler_float_greater(0.4, (0.85 * g0 - cont)) then 0.4 else 0.85 * g0 - cont;
            } else if t1 < 2 * minperiod {
                thresh = ifx c_transpiler_float_greater(0.5, (0.9 * g0 - cont)) then 0.5 else 0.9 * g0 - cont;
            }
            if c_transpiler_float_greater(g1, thresh) {
                best_xy = xy;
                best_yy = yy;
                t = t1;
                g = g1;
            }
        }
    }
    best_xy = ifx c_transpiler_float_greater(0.0, best_xy) then 0.0 else best_xy;
    pg: Val16 = ifx c_transpiler_float_less_equal(best_yy, best_xy)
        then 1.0
        else best_xy / (best_yy + 1.0);

    for k: 0..cast(s32) 3 - 1 {
        xcorr[k] = celt_inner_prod_c_in_pitch(x, x - (t + k - 1), n);
    }
    offset: s32 = ifx c_transpiler_float_greater((xcorr[2] - xcorr[0]), (0.7 * (xcorr[1] - xcorr[0])))
        then cast(s32) 1
        else ifx c_transpiler_float_greater((xcorr[0] - xcorr[2]), (0.7 * (xcorr[1] - xcorr[2])))
            then cast(s32) -1
            else 0;
    if c_transpiler_float_greater(pg, g) {
        pg = g;
    }
    t0.* = 2 * t + offset;

    if t0.* < minperiod0 {
        t0.* = minperiod0;
    }

    return pg;
}

compute_pitch_gain :: (xy: Val32, xx_: Val32, yy: Val32) -> Val16 {
    return xy / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (1.0 + xx_ * yy));
}

dual_inner_prod_c_in_pitch :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

alloc__in_pitch :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_pitch :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_pitch :: (size: u64) -> *void {
    return alloc__in_pitch(size);
}

free__in_pitch :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

false__in_pitch :: () -> s32 {
    return 0;
}

fast_atan2f_in_pitch :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_pitch :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_pitch :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_pitch :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_pitch(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_pitch(x / y);
    }
}

celt_cos_norm2_in_pitch :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

globals_initialization_state_for_pitch: u32;
initialize_globals_for_pitch :: () {
    {
        state := atomic_load(*globals_initialization_state_for_pitch);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_pitch, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_pitch) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_pitch =
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
    SPREAD_ICDF_in_pitch = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_pitch = u8.[ 2, 1, 0 ];
    SECOND_CHECK =
        s32.[
            0,
            0,
            3,
            2,
            3,
            2,
            5,
            2,
            3,
            2,
            3,
            2,
            5,
            2,
            3,
            2
        ];
    atomic_store(*globals_initialization_state_for_pitch, 2);
}

