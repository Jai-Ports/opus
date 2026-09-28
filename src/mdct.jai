// Generated directly from C by cpp_transpiler.
select_arch_in_mdct :: () -> s32 {
    return 0;
}

clt_mdct_forward_c :: (
    l: *Mdct_Lookup,
    in: *float32,
    out: *float32,
    window: *Celt_Coef,
    overlap: s32,
    shift: s32,
    stride: s32,
    arch: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    st := l.kfft[shift];

    scale := st.scale;

    n := l.n;
    trig := l.trig;
    i: s32 = 0;
    while i < shift {
        c_transpiler_compound_shr(*(n), (cast(s32) 1), s32, s32);
        trig += n;
        i += 1;
    }
    n2 := n >> 1;
    n4 := n >> 2;

    f := cast(*float32) c_transpiler_alloca(cast(u64) ((size_of(float32) * cast,no_check(u64) n2)));
    f2 := cast(*Kiss_Fft_Cpx) c_transpiler_alloca(cast(u64) ((size_of(Kiss_Fft_Cpx) * cast,no_check(u64) n4)));

    {
        xp1 := in + overlap >> 1;
        xp2 := in + n2 - 1 + overlap >> 1;
        yp := f;
        wp1 := window + overlap >> 1;
        wp2 := window + overlap >> 1 - 1;
        i = 0;
        while i < (overlap + 3) >> 2 {
            yp.* = xp1[n2] * wp2.* + xp2.* * wp1.*;
            yp += 1;
            yp.* = xp1.* * wp1.* - xp2[-n2] * wp2.*;
            yp += 1;
            xp1 += 2;
            xp2 -= 2;
            wp1 += 2;
            wp2 -= 2;
            i += 1;
        }
        wp1 = window;
        wp2 = window + overlap - 1;
        while i < n4 - (overlap + 3) >> 2 {
            yp.* = xp2.*;
            yp += 1;
            yp.* = xp1.*;
            yp += 1;
            xp1 += 2;
            xp2 -= 2;
            i += 1;
        }
        while i < n4 {
            yp.* = -(xp1[-n2] * wp1.*) + xp2.* * wp2.*;
            yp += 1;
            yp.* = xp1.* * wp2.* + xp2[n2] * wp1.*;
            yp += 1;
            xp1 += 2;
            xp2 -= 2;
            wp1 += 2;
            wp2 -= 2;
            i += 1;
        }
    }

    {
        yp := f;
        t := *trig[0];

        i = 0;
        while i < n4 {
            yc: Kiss_Fft_Cpx = ---;

            t0 := t[i];
            t1 := t[n4 + i];
            re := (c_transpiler_post_increment(*(yp))).*;
            im := (c_transpiler_post_increment(*(yp))).*;
            yr := re * t0 - im * t1;
            yi := im * t0 + re * t1;

            yc.r = yr * scale;
            yc.i = yi * scale;

            f2[st.bitrev[i]] = yc;
            i += 1;
        }
    }

    fft_impl(st, f2);

    {
        fp := f2;
        yp1 := out;
        yp2 := out + stride * (n2 - 1);
        t := *trig[0];

        i = 0;
        while i < n4 {
            t0: float32 = ---;

            t0 = t[i];
            t1 := t[n4 + i];

            yr := fp.i * t1 - fp.r * t0;
            yi := fp.r * t1 + fp.i * t0;
            yp1.* = yr;
            yp2.* = yi;
            fp += 1;
            yp1 += 2 * stride;
            yp2 -= 2 * stride;
            i += 1;
        }
    }
}

clt_mdct_backward_c :: (
    l: *Mdct_Lookup,
    in: *float32,
    out: *float32,
    window: *Celt_Coef,
    overlap: s32,
    shift: s32,
    stride: s32,
    arch: s32
) {
    n := l.n;
    trig := l.trig;
    i: s32 = 0;
    while i < shift {
        c_transpiler_compound_shr(*(n), (cast(s32) 1), s32, s32);
        trig += n;
        i += 1;
    }
    n2 := n >> 1;
    n4 := n >> 2;

    {
        xp1 := in;
        xp2 := in + stride * (n2 - 1);
        yp := out + overlap >> 1;
        t := *trig[0];
        bitrev := l.kfft[shift].bitrev;
        i = 0;
        while i < n4 {
            rev := cast,no_check(s32) ((c_transpiler_post_increment(*(bitrev))).*);
            x1 := xp1.*;
            x2 := xp2.*;
            yr := x2 * t[i] + x1 * t[n4 + i];
            yi := x1 * t[i] - x2 * t[n4 + i];

            yp[2 * rev + 1] = yr;
            yp[2 * rev] = yi;

            xp1 += 2 * stride;
            xp2 -= 2 * stride;
            i += 1;
        }
    }

    fft_impl(l.kfft[shift], cast(*Kiss_Fft_Cpx) (out + overlap >> 1));

    {
        yp0 := out + overlap >> 1;
        yp1 := out + overlap >> 1 + n2 - 2;
        t := *trig[0];

        i = 0;
        while i < (n4 + 1) >> 1 {
            re := yp0[1];
            im := yp0[0];
            t0 := t[i];
            t1 := t[n4 + i];

            yr := re * t0 + im * t1;
            yi := re * t1 - im * t0;

            re = yp1[1];
            im = yp1[0];
            yp0[0] = yr;
            yp1[1] = yi;

            t0 = t[n4 - i - 1];
            t1 = t[n2 - i - 1];

            yr = re * t0 + im * t1;
            yi = re * t1 - im * t0;
            yp1[0] = yr;
            yp0[1] = yi;
            yp0 += 2;
            yp1 -= 2;
            i += 1;
        }
    }

    {
        xp1 := out + overlap - 1;
        yp1 := out;
        wp1 := window;
        wp2 := window + overlap - 1;

        i = 0;
        while i < overlap / 2 {
            x1: float32 = ---;
            x1 = xp1.*;
            x2 := yp1.*;
            yp1.* = x2 * wp2.* - x1 * wp1.*;
            yp1 += 1;
            assignment_0: float32 = (x2 * wp1.* + x1 * wp2.*);
            ((c_transpiler_post_decrement(*(xp1))).*) = assignment_0;
            wp1 += 1;
            wp2 -= 1;
            i += 1;
        }
    }
}

alloc__in_mdct :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_mdct :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_mdct :: (size: u64) -> *void {
    return alloc__in_mdct(size);
}

free__in_mdct :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

ec_range_bytes_in_mdct :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_mdct :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_mdct :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_mdct :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_mdct :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_mdct :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

fast_atan2f_in_mdct :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_mdct :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_mdct :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_mdct :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_mdct(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_mdct(x / y);
    }
}

celt_cos_norm2_in_mdct :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

false__in_mdct :: () -> s32 {
    return 0;
}

