// Generated directly from C by cpp_transpiler.
select_arch_in_kiss_fft :: () -> s32 {
    return 0;
}

fft_c :: (st: *Kiss_Fft_State, fin: *Kiss_Fft_Cpx, fout: *Kiss_Fft_Cpx) {
    scale := st.scale;

    i: s32 = 0;
    while i < st.nfft {
        x := fin[i];
        fout[st.bitrev[i]].r = x.r * scale;
        fout[st.bitrev[i]].i = x.i * scale;
        i += 1;
    }
    fft_impl(st, fout);
}

fft_impl :: (st: *Kiss_Fft_State, fout: *Kiss_Fft_Cpx) {
    m: s32 = ---;
    p: s32 = ---;

    fstride: [8] s32 = ---;

    shift := (ifx st.shift > 0 then st.shift else 0);

    fstride[0] = 1;
    l: s32 = 0;
    while true {
        p = cast,no_check(s32) st.factors[2 * l];
        m = cast,no_check(s32) st.factors[2 * l + 1];
        fstride[l + 1] = fstride[l] * p;
        l += 1;
        if !(m != 1) break;
    }
    m = cast,no_check(s32) st.factors[2 * l - 1];
    i := l - 1;
    while i >= 0 {
        m2: s32 = ifx i != 0
            then cast,no_check(s32) st.factors[2 * i - 1]
            else 1;
        if cast,no_check(s32) st.factors[2 * i] == {
            case 2;
                kf_bfly2(fout, m, fstride[i]);
            case 4;
                kf_bfly4(fout, cast,no_check(u64) (fstride[i] << ((shift) & 31)), st, m, fstride[i], m2);
            case 3;
                kf_bfly3(fout, cast,no_check(u64) (fstride[i] << ((shift) & 31)), st, m, fstride[i], m2);
            case 5;
                kf_bfly5(fout, cast,no_check(u64) (fstride[i] << ((shift) & 31)), st, m, fstride[i], m2);
        }
        m = m2;
        i -= 1;
    }
}

kf_bfly5 :: (fout: *Kiss_Fft_Cpx, FSTRIDE: u64, st: *Kiss_Fft_State, m: s32, n: s32, mm: s32) {
    u: s32 = ---;
    scratch: [13] Kiss_Fft_Cpx = ---;

    ya, yb: Kiss_Twiddle_Cpx = ---;
    fout_beg := fout;

    ya = st.twiddles[FSTRIDE * cast,no_check(u64) m];
    yb = st.twiddles[(FSTRIDE * 2) * cast,no_check(u64) m];

    tw := st.twiddles;

    if 0 < n {
        for i: 0..n - 1 {
            fout = fout_beg + i * mm;
            fout0 := fout;
            fout1 := fout0 + m;
            fout2 := fout0 + 2 * m;
            fout3 := fout0 + 3 * m;
            fout4 := fout0 + 4 * m;

            u = 0;
            while u < m {
                scratch[0] = fout0.*;

                scratch[1].r =
                    fout1.*.r * tw[(cast,no_check(u64) u) * FSTRIDE].r -
                        fout1.*.i * tw[(cast,no_check(u64) u) * FSTRIDE].i;

                scratch[1].i =
                    fout1.*.r * tw[(cast,no_check(u64) u) * FSTRIDE].i +
                        fout1.*.i * tw[(cast,no_check(u64) u) * FSTRIDE].r;
                scratch[2].r =
                    fout2.*.r * tw[(cast,no_check(u64) (2 * u)) * FSTRIDE].r -
                        fout2.*.i * tw[(cast,no_check(u64) (2 * u)) * FSTRIDE].i;

                scratch[2].i =
                    fout2.*.r * tw[(cast,no_check(u64) (2 * u)) * FSTRIDE].i +
                        fout2.*.i * tw[(cast,no_check(u64) (2 * u)) * FSTRIDE].r;
                scratch[3].r =
                    fout3.*.r * tw[(cast,no_check(u64) (3 * u)) * FSTRIDE].r -
                        fout3.*.i * tw[(cast,no_check(u64) (3 * u)) * FSTRIDE].i;

                scratch[3].i =
                    fout3.*.r * tw[(cast,no_check(u64) (3 * u)) * FSTRIDE].i +
                        fout3.*.i * tw[(cast,no_check(u64) (3 * u)) * FSTRIDE].r;
                scratch[4].r =
                    fout4.*.r * tw[(cast,no_check(u64) (4 * u)) * FSTRIDE].r -
                        fout4.*.i * tw[(cast,no_check(u64) (4 * u)) * FSTRIDE].i;

                scratch[4].i =
                    fout4.*.r * tw[(cast,no_check(u64) (4 * u)) * FSTRIDE].i +
                        fout4.*.i * tw[(cast,no_check(u64) (4 * u)) * FSTRIDE].r;

                scratch[7].r = scratch[1].r + scratch[4].r;

                scratch[7].i = scratch[1].i + scratch[4].i;
                scratch[10].r = scratch[1].r - scratch[4].r;

                scratch[10].i = scratch[1].i - scratch[4].i;
                scratch[8].r = scratch[2].r + scratch[3].r;

                scratch[8].i = scratch[2].i + scratch[3].i;
                scratch[9].r = scratch[2].r - scratch[3].r;

                scratch[9].i = scratch[2].i - scratch[3].i;

                fout0.r = fout0.r + (scratch[7].r + scratch[8].r);
                fout0.i = fout0.i + (scratch[7].i + scratch[8].i);

                scratch[5].r = scratch[0].r + (scratch[7].r * ya.r + scratch[8].r * yb.r);
                scratch[5].i = scratch[0].i + (scratch[7].i * ya.r + scratch[8].i * yb.r);

                scratch[6].r = scratch[10].i * ya.i + scratch[9].i * yb.i;
                scratch[6].i = -(scratch[10].r * ya.i + scratch[9].r * yb.i);

                fout1.*.r = scratch[5].r - scratch[6].r;

                fout1.*.i = scratch[5].i - scratch[6].i;
                fout4.*.r = scratch[5].r + scratch[6].r;

                fout4.*.i = scratch[5].i + scratch[6].i;

                scratch[11].r = scratch[0].r + (scratch[7].r * yb.r + scratch[8].r * ya.r);
                scratch[11].i = scratch[0].i + (scratch[7].i * yb.r + scratch[8].i * ya.r);
                scratch[12].r = scratch[9].i * ya.i - scratch[10].i * yb.i;
                scratch[12].i = scratch[10].r * yb.i - scratch[9].r * ya.i;

                fout2.*.r = scratch[11].r + scratch[12].r;

                fout2.*.i = scratch[11].i + scratch[12].i;
                fout3.*.r = scratch[11].r - scratch[12].r;

                fout3.*.i = scratch[11].i - scratch[12].i;

                fout0 += 1;
                fout1 += 1;
                fout2 += 1;
                fout3 += 1;
                fout4 += 1;
                u += 1;
            }
        }
    }
}

kf_bfly3 :: (fout: *Kiss_Fft_Cpx, FSTRIDE: u64, st: *Kiss_Fft_State, m: s32, n: s32, mm: s32) {
    M2 := cast,no_check(u64) (2 * m);
    tw1, tw2: *Kiss_Twiddle_Cpx = ---;
    scratch: [5] Kiss_Fft_Cpx = ---;
    epi3: Kiss_Twiddle_Cpx = ---;

    fout_beg := fout;

    epi3 = st.twiddles[FSTRIDE * cast,no_check(u64) m];

    if 0 < n {
        for i: 0..n - 1 {
            fout = fout_beg + i * mm;
            tw2 = st.twiddles;
            tw1 = tw2;

            k := cast,no_check(u64) m;
            while true {
                scratch[1].r = fout[m].r * tw1.*.r - fout[m].i * tw1.*.i;

                scratch[1].i = fout[m].r * tw1.*.i + fout[m].i * tw1.*.r;
                scratch[2].r = fout[M2].r * tw2.*.r - fout[M2].i * tw2.*.i;

                scratch[2].i = fout[M2].r * tw2.*.i + fout[M2].i * tw2.*.r;

                scratch[3].r = scratch[1].r + scratch[2].r;

                scratch[3].i = scratch[1].i + scratch[2].i;
                scratch[0].r = scratch[1].r - scratch[2].r;

                scratch[0].i = scratch[1].i - scratch[2].i;
                tw1 += FSTRIDE;
                tw2 += FSTRIDE * 2;

                fout[m].r = fout.r - scratch[3].r * 0.5;
                fout[m].i = fout.i - scratch[3].i * 0.5;

                scratch[0].r *= epi3.i;

                scratch[0].i *= epi3.i;

                fout.*.r += scratch[3].r;

                fout.*.i += scratch[3].i;

                fout[M2].r = fout[m].r + scratch[0].i;
                fout[M2].i = fout[m].i - scratch[0].r;

                fout[m].r = fout[m].r - scratch[0].i;
                fout[m].i = fout[m].i + scratch[0].r;

                fout += 1;
                if c_transpiler_pre_decrement(*(k)) == 0 break;
            }
        }
    }
}

kf_bfly4 :: (fout: *Kiss_Fft_Cpx, FSTRIDE: u64, st: *Kiss_Fft_State, m: s32, n: s32, mm: s32) {
    if m == 1 {
        if 0 < n {
            for i: 0..n - 1 {
                scratch0, scratch1: Kiss_Fft_Cpx = ---;

                scratch0.r = fout.*.r - fout[2].r;

                scratch0.i = fout.*.i - fout[2].i;
                fout.*.r += fout[2].r;

                fout.*.i += fout[2].i;
                scratch1.r = fout[1].r + fout[3].r;

                scratch1.i = fout[1].i + fout[3].i;
                fout[2].r = fout.*.r - scratch1.r;

                fout[2].i = fout.*.i - scratch1.i;
                fout.*.r += scratch1.r;

                fout.*.i += scratch1.i;
                scratch1.r = fout[1].r - fout[3].r;

                scratch1.i = fout[1].i - fout[3].i;

                fout[1].r = scratch0.r + scratch1.i;
                fout[1].i = scratch0.i - scratch1.r;
                fout[3].r = scratch0.r - scratch1.i;
                fout[3].i = scratch0.i + scratch1.r;
                fout += 4;
            }
        }
    } else {
        j: s32 = ---;
        scratch: [6] Kiss_Fft_Cpx = ---;
        tw1, tw2, tw3: *Kiss_Twiddle_Cpx = ---;
        M2 := 2 * m;
        M3 := 3 * m;
        fout_beg := fout;
        if 0 < n {
            for i: 0..n - 1 {
                fout = fout_beg + i * mm;
                tw1 = st.twiddles;
                tw2 = tw1;
                tw3 = tw2;

                j = 0;
                while j < m {
                    scratch[0].r = fout[m].r * tw1.*.r - fout[m].i * tw1.*.i;

                    scratch[0].i = fout[m].r * tw1.*.i + fout[m].i * tw1.*.r;
                    scratch[1].r = fout[M2].r * tw2.*.r - fout[M2].i * tw2.*.i;

                    scratch[1].i = fout[M2].r * tw2.*.i + fout[M2].i * tw2.*.r;
                    scratch[2].r = fout[M3].r * tw3.*.r - fout[M3].i * tw3.*.i;

                    scratch[2].i = fout[M3].r * tw3.*.i + fout[M3].i * tw3.*.r;

                    scratch[5].r = fout.*.r - scratch[1].r;

                    scratch[5].i = fout.*.i - scratch[1].i;
                    fout.*.r += scratch[1].r;

                    fout.*.i += scratch[1].i;
                    scratch[3].r = scratch[0].r + scratch[2].r;

                    scratch[3].i = scratch[0].i + scratch[2].i;
                    scratch[4].r = scratch[0].r - scratch[2].r;

                    scratch[4].i = scratch[0].i - scratch[2].i;
                    fout[M2].r = fout.*.r - scratch[3].r;

                    fout[M2].i = fout.*.i - scratch[3].i;
                    tw1 += FSTRIDE;
                    tw2 += FSTRIDE * 2;
                    tw3 += FSTRIDE * 3;
                    fout.*.r += scratch[3].r;

                    fout.*.i += scratch[3].i;

                    fout[m].r = scratch[5].r + scratch[4].i;
                    fout[m].i = scratch[5].i - scratch[4].r;
                    fout[M3].r = scratch[5].r - scratch[4].i;
                    fout[M3].i = scratch[5].i + scratch[4].r;
                    fout += 1;
                    j += 1;
                }
            }
        }
    }
}

kf_bfly2 :: (fout: *Kiss_Fft_Cpx, m: s32, n: s32) {
    fout2: *Kiss_Fft_Cpx = ---;

    {
        tw: Celt_Coef = cast(float32) 0.7071067690849304;

        if 0 < n {
            for i: 0..n - 1 {
                t: Kiss_Fft_Cpx = ---;
                fout2 = fout + 4;
                t = fout2[0];
                fout2[0].r = fout[0].r - t.r;

                fout2[0].i = fout[0].i - t.i;
                fout[0].r += t.r;

                fout[0].i += t.i;

                t.r = (fout2[1].r + fout2[1].i) * tw;
                t.i = (fout2[1].i - fout2[1].r) * tw;
                fout2[1].r = fout[1].r - t.r;

                fout2[1].i = fout[1].i - t.i;
                fout[1].r += t.r;

                fout[1].i += t.i;

                t.r = fout2[2].i;
                t.i = -fout2[2].r;
                fout2[2].r = fout[2].r - t.r;

                fout2[2].i = fout[2].i - t.i;
                fout[2].r += t.r;

                fout[2].i += t.i;

                t.r = (fout2[3].i - fout2[3].r) * tw;
                t.i = -(fout2[3].i + fout2[3].r) * tw;
                fout2[3].r = fout[3].r - t.r;

                fout2[3].i = fout[3].i - t.i;
                fout[3].r += t.r;

                fout[3].i += t.i;
                fout += 8;
            }
        }
    }
}

ifft_c :: (st: *Kiss_Fft_State, fin: *Kiss_Fft_Cpx, fout: *Kiss_Fft_Cpx) {
    i: s32 = 0;
    while i < st.nfft {
        fout[st.bitrev[i]] = fin[i];
        i += 1;
    }
    i = 0;
    while i < st.nfft {
        fout[i].i = -fout[i].i;
        i += 1;
    }
    fft_impl(st, fout);
    i = 0;
    while i < st.nfft {
        fout[i].i = -fout[i].i;
        i += 1;
    }
}

alloc__in_kiss_fft :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_kiss_fft :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_kiss_fft :: (size: u64) -> *void {
    return alloc__in_kiss_fft(size);
}

free__in_kiss_fft :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

ec_range_bytes_in_kiss_fft :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_kiss_fft :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_kiss_fft :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_kiss_fft :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_kiss_fft :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_kiss_fft :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

fast_atan2f_in_kiss_fft :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_kiss_fft :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_kiss_fft :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_kiss_fft :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_kiss_fft(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_kiss_fft(x / y);
    }
}

celt_cos_norm2_in_kiss_fft :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

false__in_kiss_fft :: () -> s32 {
    return 0;
}

Kiss_Fft_Cpx :: struct {
    r: float32;
    i: float32;
}

