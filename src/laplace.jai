// Generated directly from C by cpp_transpiler.
ec_range_bytes_in_laplace :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_laplace :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_laplace :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_laplace :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_laplace :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_laplace :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

ec_laplace_encode :: (enc: *Ec_Enc, value: *s32, fs: u32, decay: s32) {
    val := value.*;
    fl: u32 = 0;
    if val != 0 {
        s := -(cast(s32) (val < 0));
        val = (val + s) ^ s;
        fl = fs;
        fs = ec_laplace_get_freq1(fs, decay);

        i: s32 = 1;
        while fs > 0 && i < val {
            fs *= 2;
            fl += fs + (2 * 1);
            fs = (fs * cast,no_check(u32) decay) >> 15;
            i += 1;
        }

        if fs == 0 {
            ndi_max := cast,no_check(s32) (32768 - fl + 1 - 1);
            ndi_max = (ndi_max - s) >> 1;
            di := (ifx val - i < ndi_max - 1 then val - i else ndi_max - 1);
            fl += cast,no_check(u32) ((2 * di + 1 + s) * 1);
            fs = ifx 1 < 32768 - fl then 1 else 32768 - fl;
            value.* = (i + di + s) ^ s;
        } else {
            fs += cast,no_check(u32) (1);
            fl += fs & cast,no_check(u32) (~(s));
        }
        (fl + fs <= 32768);
    }
    ec_encode_bin(enc, fl, fl + fs, 15);
}

ec_laplace_get_freq1 :: (fs0: u32, decay: s32) -> u32 {
    ft := (cast,no_check(u32) (32768 - 1 * cast,no_check(s32) ((2 * 16)))) - fs0;
    return (ft * cast,no_check(u32) (16384 - decay)) >> 15;
}

ec_laplace_decode :: (dec: *Ec_Dec, fs: u32, decay: s32) -> s32 {
    val: s32 = 0;

    fm := ec_decode_bin(dec, 15);
    fl: u32 = 0;
    if fm >= fs {
        val += 1;
        fl = fs;
        fs = ec_laplace_get_freq1(fs, decay) + 1;

        while fs > 1 && fm >= fl + 2 * fs {
            fs *= 2;
            fl += fs;
            fs = ((fs - (2 * 1)) * cast,no_check(u32) decay) >> 15;
            fs += cast,no_check(u32) (1);
            val += 1;
        }

        if fs <= 1 {
            di := cast,no_check(s32) ((fm - fl) >> (((0 + 1)) & 31));
            val += di;
            fl += cast,no_check(u32) (2 * di * 1);
        }
        if fm < fl + fs {
            val = -val;
        } else {
            fl += fs;
        }
    }

    (fm < (ifx fl + fs < 32768 then fl + fs else 32768));
    ec_dec_update(dec, fl, (ifx fl + fs < 32768 then fl + fs else 32768), 32768);
    return val;
}

ec_laplace_decode_p0 :: (dec: *Ec_Dec, p0: Uint16, decay: Uint16) -> s32 {
    value: s32 = ---;
    sign_icdf: [3] Uint16 = ---;
    sign_icdf[0] = cast,no_check(Uint16) (32768 - cast(s32) p0);
    sign_icdf[1] = cast,no_check(Uint16) ((cast(s32) sign_icdf[0]) / 2);
    sign_icdf[2] = 0;
    s := ec_dec_icdf16(dec, sign_icdf.data, 15);
    if s == 2 {
        s = -1;
    }
    if s != 0 {
        v: s32 = ---;
        icdf: [8] Uint16 = ---;
        icdf[0] = cast,no_check(Uint16) ((ifx 7 > decay then 7 else cast,no_check(s32) decay));
        if 1 < 7 {
            for i: 1..cast(s32) 7 - 1 {
                icdf[i] =
                    cast,no_check(Uint16) ((ifx 7 - i > ((cast(Int32) icdf[i - 1]) * cast,no_check(Int32) decay) >> 15 then 7 -
                        i else ((cast(Int32) icdf[i - 1]) * cast,no_check(Int32) decay) >> 15));
            }
        }
        icdf[7] = 0;
        value = 1;
        while true {
            v = ec_dec_icdf16(dec, icdf.data, 15);
            value += v;
            if !(v == 7) break;
        }
        return s * value;
    } else {
        return 0;
    }
}

ec_laplace_encode_p0 :: (enc: *Ec_Enc, value: s32, p0: Uint16, decay: Uint16) {
    sign_icdf: [3] Uint16 = ---;
    sign_icdf[0] = cast,no_check(Uint16) (32768 - cast(s32) p0);
    sign_icdf[1] = cast,no_check(Uint16) ((cast(s32) sign_icdf[0]) / 2);
    sign_icdf[2] = 0;
    s := (ifx value == 0 then 0 else (ifx value > 0 then cast(s32) 1 else 2));
    ec_enc_icdf16(enc, s, sign_icdf.data, 15);
    value = absolute_value(value);
    if value != 0 {
        icdf: [8] Uint16 = ---;
        icdf[0] = cast,no_check(Uint16) ((ifx 7 > decay then 7 else cast,no_check(s32) decay));
        if 1 < 7 {
            for i: 1..cast(s32) 7 - 1 {
                icdf[i] =
                    cast,no_check(Uint16) ((ifx 7 - i > ((cast(Int32) icdf[i - 1]) * cast,no_check(Int32) decay) >> 15 then 7 -
                        i else ((cast(Int32) icdf[i - 1]) * cast,no_check(Int32) decay) >> 15));
            }
        }
        icdf[7] = 0;
        value -= 1;
        while true {
            ec_enc_icdf16(enc, (ifx value < 7 then value else 7), icdf.data, 15);
            value -= 7;
            if !(value >= 0) break;
        }
    }
}

alloc__in_laplace :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_laplace :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_laplace :: (size: u64) -> *void {
    return alloc__in_laplace(size);
}

free__in_laplace :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_laplace :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_laplace :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_laplace :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_laplace :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_laplace(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_laplace(x / y);
    }
}

celt_cos_norm2_in_laplace :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

