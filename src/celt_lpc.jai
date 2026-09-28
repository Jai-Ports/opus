TRIM_ICDF_in_celt_lpc: [11] u8;

SPREAD_ICDF_in_celt_lpc: [4] u8;

TAPSET_ICDF_in_celt_lpc: [3] u8;

select_arch_in_celt_lpc :: () -> s32 {
    return 0;
}

celt_lpc :: (lpc_value: *Val16, ac: *Val32, p: s32) {
    j: s32 = ---;
    r: Val32 = ---;
    error := ac[0];

    lpc: *float32 = lpc_value;

    fill_memory(lpc, 0, cast,no_check(u64) p * size_of(float32));

    if c_transpiler_float_greater(ac[0], 1.0e-10) {
        if 0 < p {
            for i: 0..p - 1 {
                rr: Val32 = 0.0;

                j = 0;
                while j < i {
                    rr += lpc[j] * ac[i - j];
                    j += 1;
                }

                rr += ac[i + 1];
                r = -(rr / error);

                lpc[i] = r;
                j = 0;
                while j < (i + 1) >> 1 {
                    tmp1: Val32 = ---;
                    tmp1 = lpc[j];
                    tmp2 := lpc[i - 1 - j];
                    lpc[j] = tmp1 + r * tmp2;
                    lpc[i - 1 - j] = tmp2 + r * tmp1;
                    j += 1;
                }

                error = error - r * r * error;

                if c_transpiler_float_less_equal(error, (0.001 * ac[0])) {
                    break;
                }
            }
        }
    }
}

celt_fir_c :: (x: *Val16, num: *Val16, y: *Val16, n: s32, ord: s32, arch: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    j: s32 = ---;

    rnum := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) ord)));
    i: s32 = 0;
    while i < ord {
        rnum[i] = num[ord - i - 1];
        i += 1;
    }
    i = 0;
    while i < n - 3 {
        sum: [4] Val32 = ---;
        sum[0] = x[i];
        sum[1] = x[i + 1];
        sum[2] = x[i + 2];
        sum[3] = x[i + 3];

        xcorr_kernel_c_in_celt_lpc(rnum, x + i - ord, sum.data, ord);

        y[i] = sum[0];
        y[i + 1] = sum[1];
        y[i + 2] = sum[2];
        y[i + 3] = sum[3];
        i += 4;
    }
    while i < n {
        sum := x[i];
        j = 0;
        while j < ord {
            sum = sum + rnum[j] * x[i + j - ord];
            j += 1;
        }
        y[i] = sum;
        i += 1;
    }
}

xcorr_kernel_c_in_celt_lpc :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

celt_iir :: (x: *Val32, den: *Val16, y_value: *Val32, n: s32, ord: s32, mem: *Val16, arch: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    j: s32 = ---;

    (ord & 3 == 0);
    rden := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) ord)));
    y := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) (n + ord))));
    i: s32 = 0;
    while i < ord {
        rden[i] = den[ord - i - 1];
        i += 1;
    }
    i = 0;
    while i < ord {
        y[i] = -mem[ord - i - 1];
        i += 1;
    }
    while i < n + ord {
        y[i] = 0.0;
        i += 1;
    }
    i = 0;
    while i < n - 3 {
        sum: [4] Val32 = ---;
        sum[0] = x[i];
        sum[1] = x[i + 1];
        sum[2] = x[i + 2];
        sum[3] = x[i + 3];

        xcorr_kernel_c_in_celt_lpc(rden, y + i, sum.data, ord);

        y[i + ord] = -sum[0];
        y_value[i] = sum[0];
        sum[1] = sum[1] + y[i + ord] * den[0];
        y[i + ord + 1] = -sum[1];
        y_value[i + 1] = sum[1];
        sum[2] = sum[2] + y[i + ord + 1] * den[0];
        sum[2] = sum[2] + y[i + ord] * den[1];
        y[i + ord + 2] = -sum[2];
        y_value[i + 2] = sum[2];

        sum[3] = sum[3] + y[i + ord + 2] * den[0];
        sum[3] = sum[3] + y[i + ord + 1] * den[1];
        sum[3] = sum[3] + y[i + ord] * den[2];
        y[i + ord + 3] = -sum[3];
        y_value[i + 3] = sum[3];
        i += 4;
    }
    while i < n {
        sum := x[i];
        j = 0;
        while j < ord {
            sum -= rden[j] * y[i + j];
            j += 1;
        }
        y[i + ord] = sum;
        y_value[i] = sum;
        i += 1;
    }
    i = 0;
    while i < ord {
        mem[i] = y_value[n - i - 1];
        i += 1;
    }
}

celt_autocorr :: (x: *Val16, ac: *Val32, window: *Celt_Coef, overlap: s32, lag: s32, n: s32, arch: s32) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    d: Val32 = ---;
    i: s32 = ---;
    fast_n := n - lag;

    xptr: *Val16 = ---;

    xx_ := cast(*Val16) c_transpiler_alloca(cast(u64) ((size_of(Val16) * cast,no_check(u64) n)));

    if overlap == 0 {
        xptr = x;
    } else {
        i = 0;
        while i < n {
            xx_[i] = x[i];
            i += 1;
        }
        i = 0;
        while i < overlap {
            w := window[i];
            xx_[i] = x[i] * w;
            xx_[n - i - 1] = x[n - i - 1] * w;
            i += 1;
        }
        xptr = xx_;
    }
    shift: s32 = 0;

    celt_pitch_xcorr_c(xptr, xptr, ac, fast_n, lag + 1, arch);
    if 0 <= lag {
        for k: 0..lag {
            i = k + fast_n;
            d = 0.0;
            while i < n {
                d = d + xptr[i] * xptr[i - k];
                i += 1;
            }
            ac[k] += d;
        }
    }

    return shift;
}

false__in_celt_lpc :: () -> s32 {
    return 0;
}

ec_range_bytes_in_celt_lpc :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_celt_lpc :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_celt_lpc :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_celt_lpc :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_celt_lpc :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_celt_lpc :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_celt_lpc :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_celt_lpc :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_celt_lpc :: (size: u64) -> *void {
    return alloc__in_celt_lpc(size);
}

free__in_celt_lpc :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_celt_lpc :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_celt_lpc :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_celt_lpc :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_celt_lpc :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_celt_lpc(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_celt_lpc(x / y);
    }
}

celt_cos_norm2_in_celt_lpc :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

bits_to_bitrate_in_celt_lpc :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_celt_lpc :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

dual_inner_prod_c_in_celt_lpc :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

celt_inner_prod_c_in_celt_lpc :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

globals_initialization_state_for_celt_lpc: u32;
initialize_globals_for_celt_lpc :: () {
    {
        state := atomic_load(*globals_initialization_state_for_celt_lpc);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_celt_lpc, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_celt_lpc) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_celt_lpc =
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
    SPREAD_ICDF_in_celt_lpc = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_celt_lpc = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_celt_lpc, 2);
}

