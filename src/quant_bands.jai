TRIM_ICDF_in_quant_bands: [11] u8;

SPREAD_ICDF_in_quant_bands: [4] u8;

TAPSET_ICDF_in_quant_bands: [3] u8;

E_MEANS: [25] Val16;

PRED_COEF: [4] Val16;

E_PROB_MODEL: [4] [2] [42] u8;

SMALL_ENERGY_ICDF: [3] u8;

BETA_COEF: [4] Val16;

BETA_INTRA: Val16;

ec_range_bytes_in_quant_bands :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_quant_bands :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_quant_bands :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_quant_bands :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_quant_bands :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_quant_bands :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_quant_bands :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_quant_bands :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_quant_bands :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

alloc__in_quant_bands :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_quant_bands :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_quant_bands :: (size: u64) -> *void {
    return alloc__in_quant_bands(size);
}

free__in_quant_bands :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_quant_bands :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_quant_bands :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_quant_bands :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_quant_bands :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_quant_bands(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_quant_bands(x / y);
    }
}

celt_cos_norm2_in_quant_bands :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

amp2_log2 :: (m: *Custom_Mode, eff_end: s32, end: s32, band_e: *Celt_Ener, band_log_e: *Celt_Glog, c_value: s32) {
    c, i: s32 = ---;
    c = 0;
    while true {
        i = 0;
        while i < eff_end {
            band_log_e[i + c * m.nb_e_bands] =
                (cast,no_check(float32) (1.4426950408889634 * c_transpiler_math_log(
                    cast,no_check(float64) band_e[i + c * m.nb_e_bands]
                ))) - E_MEANS[i];
            i += 1;
        }
        i = eff_end;
        while i < end {
            band_log_e[c * m.nb_e_bands + i] = -14.0;
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
}

quant_coarse_energy :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    eff_end: s32,
    e_bands: *Celt_Glog,
    old_e_bands: *Celt_Glog,
    budget: Uint32,
    error: *Celt_Glog,
    enc: *Ec_Enc,
    c: s32,
    lm: s32,
    nb_available_bytes: s32,
    force_intra: s32,
    delayed_intra: *Val32,
    two_pass: s32,
    loss_rate: s32,
    lfe: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    enc_start_state: Ec_Enc = ---;

    badness1: s32 = 0;

    intra :=
        cast(s32) (force_intra != 0 ||
            two_pass == 0 && c_transpiler_float_greater(delayed_intra.*, cast,no_check(Val32) (2 * c * (end - start))) && nb_available_bytes > (end - start) * c);
    intra_bias := cast,no_check(Int32) (budget * delayed_intra.* * loss_rate / (c * 512));
    new_distortion := loss_distortion(e_bands, old_e_bands, start, eff_end, m.nb_e_bands, c);

    tell := cast,no_check(Uint32) ec_tell_in_quant_bands(enc);
    if (tell + 3) > budget {
        intra = 0;
        two_pass = intra;
    }

    max_decay: Celt_Glog = 16.0;
    if end - start > 10 {
        max_decay =
            ifx c_transpiler_float_less(max_decay, (0.125 * cast,no_check(float32) nb_available_bytes)) then max_decay else 0.125 *
                cast,no_check(float32) nb_available_bytes;
    }
    if lfe != 0 {
        max_decay = 3.0;
    }
    enc_start_state = enc.*;

    old_e_bands_intra :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (c * m.nb_e_bands))));
    error_intra :=
        cast(*Celt_Glog) c_transpiler_alloca(cast(u64) ((size_of(Celt_Glog) *
            cast,no_check(u64) (c * m.nb_e_bands))));
    copy_memory(
        old_e_bands_intra,
        old_e_bands,
        (cast,no_check(u64) (c * m.nb_e_bands)) * size_of(Celt_Glog) +
        cast,no_check(u64) (0 * (old_e_bands_intra - old_e_bands))
    );

    if two_pass != 0 || intra != 0 {
        badness1 =
            quant_coarse_energy_impl(
                m,
                start,
                end,
                e_bands,
                old_e_bands_intra,
                cast,no_check(Int32) budget,
                cast,no_check(Int32) tell,
                E_PROB_MODEL[lm][1].data,
                error_intra,
                enc,
                c,
                lm,
                1,
                max_decay,
                lfe
            );
    }

    if intra == 0 {
        enc_intra_state: Ec_Enc = ---;

        tell_intra := cast,no_check(Int32) ec_tell_frac(enc);

        enc_intra_state = enc.*;

        nstart_bytes := ec_range_bytes_in_quant_bands(*enc_start_state);
        nintra_bytes := ec_range_bytes_in_quant_bands(*enc_intra_state);
        intra_buf := ec_get_buffer_in_quant_bands(*enc_intra_state) + nstart_bytes;
        save_bytes := nintra_bytes - nstart_bytes;
        if save_bytes == 0 {
            save_bytes = 0;
        }
        intra_bits := cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) * cast(u64) save_bytes)));

        copy_memory(
            intra_bits,
            intra_buf,
            (cast(u64) (nintra_bytes - nstart_bytes)) * size_of(u8) + cast,no_check(u64) (0 * (intra_bits - intra_buf))
        );

        enc.* = enc_start_state;

        badness2 :=
            quant_coarse_energy_impl(
                m,
                start,
                end,
                e_bands,
                old_e_bands,
                cast,no_check(Int32) budget,
                cast,no_check(Int32) tell,
                E_PROB_MODEL[lm][intra].data,
                error,
                enc,
                c,
                lm,
                0,
                max_decay,
                lfe
            );

        if two_pass != 0 &&
            (badness1 < badness2 || badness1 == badness2 && (cast,no_check(Int32) ec_tell_frac(enc)) + intra_bias > tell_intra) {
            enc.* = enc_intra_state;

            copy_memory(
                intra_buf,
                intra_bits,
                (cast(u64) (nintra_bytes - nstart_bytes)) * size_of(u8) +
                cast,no_check(u64) (0 * (intra_buf - intra_bits))
            );
            copy_memory(
                old_e_bands,
                old_e_bands_intra,
                (cast,no_check(u64) (c * m.nb_e_bands)) * size_of(Celt_Glog) +
                cast,no_check(u64) (0 * (old_e_bands - old_e_bands_intra))
            );
            copy_memory(
                error,
                error_intra,
                (cast,no_check(u64) (c * m.nb_e_bands)) * size_of(Celt_Glog) +
                cast,no_check(u64) (0 * (error - error_intra))
            );
            intra = 1;
        }
    } else {
        copy_memory(
            old_e_bands,
            old_e_bands_intra,
            (cast,no_check(u64) (c * m.nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (old_e_bands - old_e_bands_intra))
        );
        copy_memory(
            error,
            error_intra,
            (cast,no_check(u64) (c * m.nb_e_bands)) * size_of(Celt_Glog) +
            cast,no_check(u64) (0 * (error - error_intra))
        );
    }

    if intra != 0 {
        delayed_intra.* = new_distortion;
    } else {
        delayed_intra.* = PRED_COEF[lm] * PRED_COEF[lm] * delayed_intra.* + new_distortion;
    }
}

quant_coarse_energy_impl :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    e_bands: *Celt_Glog,
    old_e_bands: *Celt_Glog,
    budget: Int32,
    tell: Int32,
    prob_model: *u8,
    error: *Celt_Glog,
    enc: *Ec_Enc,
    c_value: s32,
    lm: s32,
    intra: s32,
    max_decay: Celt_Glog,
    lfe: s32
) -> s32 {
    badness: s32 = 0;
    prev := Val32.[ 0.0, 0.0 ];
    coef: Val16 = ---;
    beta: Val16 = ---;

    if tell + 3 <= budget {
        ec_enc_bit_logp(enc, intra, 3);
    }
    if intra != 0 {
        coef = 0.0;
        beta = cast(float32) 0.149993896484375;
    } else {
        beta = BETA_COEF[lm];
        coef = PRED_COEF[lm];
    }

    i := start;
    while i < end {
        c: s32 = 0;
        while true {
            {
                x := e_bands[i + c * m.nb_e_bands];
                old_e :=
                    (ifx c_transpiler_float_greater(-9.0, old_e_bands[i + c * m.nb_e_bands]) then -9.0 else old_e_bands[i +
                        c * m.nb_e_bands]);

                f := x - coef * old_e - prev[c];

                qi := cast,no_check(s32) floor(cast,no_check(float64) (0.5 + f));
                decay_bound :=
                    (ifx c_transpiler_float_greater(-28.0, old_e_bands[i + c * m.nb_e_bands]) then -28.0 else old_e_bands[i + c * m.nb_e_bands]) -
                        max_decay;

                if qi < 0 && c_transpiler_float_less(x, decay_bound) {
                    qi += cast,no_check(s32) (decay_bound - x);
                    if qi > 0 {
                        qi = 0;
                    }
                }
                qi0 := qi;

                tell = ec_tell_in_quant_bands(enc);
                bits_left := budget - tell - 3 * c_value * (end - i);
                if i != start && bits_left < 30 {
                    if bits_left < 24 {
                        qi = ifx 1 < qi then 1 else qi;
                    }
                    if bits_left < 16 {
                        qi = ifx -1 > qi then -1 else qi;
                    }
                }
                if lfe != 0 && i >= 2 {
                    qi = ifx qi < 0 then qi else 0;
                }
                if budget - tell >= 15 {
                    pi := 2 * (ifx i < 20 then i else 20);
                    ec_laplace_encode(
                        enc,
                        *qi,
                        cast,no_check(u32) ((cast(s32) prob_model[pi]) << 7),
                        (cast(s32) prob_model[pi + 1]) << 6
                    );
                } else if budget - tell >= 2 {
                    qi = ifx -1 > (ifx qi < 1 then qi else 1) then -1 else (ifx qi < 1 then qi else 1);
                    ec_enc_icdf(enc, (2 * qi) ^ -(cast(s32) (qi < 0)), SMALL_ENERGY_ICDF.data, 2);
                } else if budget - tell >= 1 {
                    qi = ifx 0 < qi then 0 else qi;
                    ec_enc_bit_logp(enc, -qi, 1);
                } else {
                    qi = -1;
                }
                error[i + c * m.nb_e_bands] = f - qi;
                badness += absolute_value(qi0 - qi);
                q := cast,no_check(Val32) qi;

                tmp := coef * old_e + prev[c] + q;

                old_e_bands[i + c * m.nb_e_bands] = tmp;
                prev[c] = prev[c] + q - beta * q;
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        i += 1;
    }
    return ifx lfe != 0 then 0 else badness;
}

loss_distortion :: (
    e_bands: *Celt_Glog,
    old_e_bands: *Celt_Glog,
    start: s32,
    end: s32,
    len: s32,
    c_value: s32
) -> Val32 {
    i: s32 = ---;
    dist: Val32 = 0.0;
    c: s32 = 0;
    while true {
        i = start;
        while i < end {
            d := e_bands[i + c * len] - old_e_bands[i + c * len];
            dist = dist + d * d;
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
    return ifx c_transpiler_float_less(200.0, dist) then 200.0 else dist;
}

quant_fine_energy :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    old_e_bands: *Celt_Glog,
    error: *Celt_Glog,
    prev_quant: *s32,
    extra_quant: *s32,
    enc: *Ec_Enc,
    c_value: s32
) {
    i := start;
    while i < end {
        extra: Int16 = ---;
        extra = cast,no_check(Int16) ((cast(s32) 1) << ((extra_quant[i]) & 31));
        if extra_quant[i] <= 0 {
            i += 1;
            continue;
        }
        if ec_tell_in_quant_bands(enc) + c_value * extra_quant[i] > (cast,no_check(Int32) enc.storage) * 8 {
            i += 1;
            continue;
        }
        prev := cast,no_check(Int16) ((ifx prev_quant != null then prev_quant[i] else 0));
        c: s32 = 0;
        while true {
            {
                q2 :=
                    cast,no_check(s32) floor(
                        cast,no_check(float64) (((error[i + c * m.nb_e_bands] * ((cast(s32) 1) << ((prev) & 31))) + 0.5) *
                        extra)
                    );

                if q2 > (cast(s32) extra) - 1 {
                    q2 = (cast(s32) extra) - 1;
                }
                if q2 < 0 {
                    q2 = 0;
                }
                ec_enc_bits(enc, cast,no_check(Uint32) q2, cast,no_check(u32) extra_quant[i]);

                offset :=
                    (((cast,no_check(float32) q2) + 0.5) * ((cast(s32) 1) << (((14 - extra_quant[i])) & 31)) * cast(float32) 0.00006103515625) -
                        0.5;
                offset *=
                    (cast,no_check(float32) ((cast(s32) 1) << (((14 - cast(s32) prev)) & 31))) *
                        cast(float32) 0.00006103515625;

                old_e_bands[i + c * m.nb_e_bands] += offset;
                error[i + c * m.nb_e_bands] -= offset;
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        i += 1;
    }
}

quant_energy_finalise :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    old_e_bands: *Celt_Glog,
    error: *Celt_Glog,
    fine_quant: *s32,
    fine_priority: *s32,
    bits_left: s32,
    enc: *Ec_Enc,
    c_value: s32
) {
    i: s32 = ---;
    c: s32 = ---;

    for prio: 0..cast(s32) 2 - 1 {
        i = start;
        while i < end && bits_left >= c_value {
            if fine_quant[i] >= 8 || fine_priority[i] != prio {
                i += 1;
                continue;
            }
            c = 0;
            while true {
                {
                    q2 := (ifx c_transpiler_float_less(error[i + c * m.nb_e_bands], 0.0) then cast(s32) 0 else 1);
                    ec_enc_bits(enc, cast,no_check(Uint32) q2, 1);

                    offset :=
                        ((cast,no_check(float32) q2) - 0.5) *
                            ((cast(s32) 1) << (((14 - fine_quant[i] - 1)) & 31)) * cast(float32) 0.00006103515625;

                    if old_e_bands != null {
                        old_e_bands[i + c * m.nb_e_bands] += offset;
                    }
                    error[i + c * m.nb_e_bands] -= offset;
                    bits_left -= 1;
                }
                if !(c_transpiler_pre_increment(*(c)) < c_value) break;
            }
            i += 1;
        }
    }
}

unquant_coarse_energy :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    old_e_bands: *Celt_Glog,
    intra: s32,
    dec: *Ec_Dec,
    c_value: s32,
    lm: s32
) {
    prob_model := E_PROB_MODEL[lm][intra].data;

    prev := Val64.[ 0.0, 0.0 ];
    coef: Val16 = ---;
    beta: Val16 = ---;

    tell: Int32 = ---;

    if intra != 0 {
        coef = 0.0;
        beta = cast(float32) 0.149993896484375;
    } else {
        beta = BETA_COEF[lm];
        coef = PRED_COEF[lm];
    }

    budget := cast,no_check(Int32) (dec.storage * 8);

    i := start;
    while i < end {
        c: s32 = 0;
        while true {
            {
                qi: s32 = ---;

                tell = ec_tell_in_quant_bands(dec);
                if budget - tell >= 15 {
                    pi := 2 * (ifx i < 20 then i else 20);
                    qi =
                        ec_laplace_decode(
                            dec,
                            cast,no_check(u32) ((cast(s32) prob_model[pi]) << 7),
                            (cast(s32) prob_model[pi + 1]) << 6
                        );
                } else if budget - tell >= 2 {
                    qi = ec_dec_icdf(dec, SMALL_ENERGY_ICDF.data, 2);
                    qi = qi >> 1 ^ -(qi & 1);
                } else if budget - tell >= 1 {
                    qi = -ec_dec_bit_logp(dec, 1);
                } else {
                    qi = -1;
                }
                q := cast,no_check(Val32) qi;

                old_e_bands[i + c * m.nb_e_bands] =
                    ifx c_transpiler_float_greater(-9.0, old_e_bands[i + c * m.nb_e_bands]) then -9.0 else old_e_bands[i +
                        c * m.nb_e_bands];
                tmp := coef * old_e_bands[i + c * m.nb_e_bands] + prev[c] + q;

                old_e_bands[i + c * m.nb_e_bands] = tmp;
                prev[c] = prev[c] + q - beta * q;
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        i += 1;
    }
}

unquant_fine_energy :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    old_e_bands: *Celt_Glog,
    prev_quant: *s32,
    extra_quant: *s32,
    dec: *Ec_Dec,
    c_value: s32
) {
    i := start;
    while i < end {
        extra: Int16 = ---;
        extra = cast,no_check(Int16) extra_quant[i];
        if extra_quant[i] <= 0 {
            i += 1;
            continue;
        }
        if ec_tell_in_quant_bands(dec) + c_value * extra_quant[i] > (cast,no_check(Int32) dec.storage) * 8 {
            i += 1;
            continue;
        }
        prev := cast,no_check(Int16) ((ifx prev_quant != null then prev_quant[i] else 0));
        c: s32 = 0;
        while true {
            {
                q2 := cast,no_check(s32) ec_dec_bits(dec, cast,no_check(u32) extra);

                offset :=
                    ((((cast,no_check(float32) q2) + 0.5) * ((cast(s32) 1) << (((14 - cast(s32) extra)) & 31))) * cast(float32) 0.00006103515625) -
                        0.5;
                offset *=
                    (cast,no_check(float32) ((cast(s32) 1) << (((14 - cast(s32) prev)) & 31))) *
                        cast(float32) 0.00006103515625;

                old_e_bands[i + c * m.nb_e_bands] += offset;
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        i += 1;
    }
}

unquant_energy_finalise :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    old_e_bands: *Celt_Glog,
    fine_quant: *s32,
    fine_priority: *s32,
    bits_left: s32,
    dec: *Ec_Dec,
    c_value: s32
) {
    i: s32 = ---;
    c: s32 = ---;

    for prio: 0..cast(s32) 2 - 1 {
        i = start;
        while i < end && bits_left >= c_value {
            if fine_quant[i] >= 8 || fine_priority[i] != prio {
                i += 1;
                continue;
            }
            c = 0;
            while true {
                {
                    q2 := cast,no_check(s32) ec_dec_bits(dec, 1);

                    offset :=
                        ((cast,no_check(float32) q2) - 0.5) *
                            ((cast(s32) 1) << (((14 - fine_quant[i] - 1)) & 31)) * cast(float32) 0.00006103515625;

                    if old_e_bands != null {
                        old_e_bands[i + c * m.nb_e_bands] += offset;
                    }
                    bits_left -= 1;
                }
                if !(c_transpiler_pre_increment(*(c)) < c_value) break;
            }
            i += 1;
        }
    }
}

false__in_quant_bands :: () -> s32 {
    return 0;
}

get_pulses_in_quant_bands :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_quant_bands :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_quant_bands :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

globals_initialization_state_for_quant_bands: u32;
initialize_globals_for_quant_bands :: () {
    {
        state := atomic_load(*globals_initialization_state_for_quant_bands);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_quant_bands, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_quant_bands) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_quant_bands =
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
    SPREAD_ICDF_in_quant_bands = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_quant_bands = u8.[ 2, 1, 0 ];
    E_MEANS =
        Val16.[
            6.437500,
            6.250000,
            5.750000,
            5.312500,
            5.062500,
            4.812500,
            4.500000,
            4.375000,
            4.875000,
            4.687500,
            4.562500,
            4.437500,
            4.875000,
            4.625000,
            4.312500,
            4.500000,
            4.375000,
            4.625000,
            4.750000,
            4.437500,
            3.750000,
            3.750000,
            3.750000,
            3.750000,
            3.750000
        ];
    PRED_COEF = Val16.[ 0.8984375, 0.796875, 0.6484375, 0.5 ];
    BETA_COEF =
        Val16.[ cast(float32) 0.920013427734375, cast(float32) 0.67999267578125, cast(float32) 0.3699951171875, cast(float32) 0.20001220703125 ];
    BETA_INTRA = cast(float32) 0.149993896484375;
    E_PROB_MODEL =
        [2] [42] u8.[
            [42] u8.[ u8.[ 72, 127, 65, 129, 66, 128, 65, 128, 64, 128, 62, 128, 64, 128, 64, 128, 92, 78, 92, 79, 92, 78, 90, 79, 116, 41, 115, 40, 114, 40, 132, 26, 132, 26, 145, 17, 161, 12, 176, 10, 177, 11 ], u8.[ 24, 179, 48, 138, 54, 135, 54, 132, 53, 134, 56, 133, 55, 132, 55, 132, 61, 114, 70, 96, 74, 88, 75, 88, 87, 74, 89, 66, 91, 67, 100, 59, 108, 50, 120, 40, 122, 37, 97, 43, 78, 50 ] ],
            [42] u8.[ u8.[ 83, 78, 84, 81, 88, 75, 86, 74, 87, 71, 90, 73, 93, 74, 93, 74, 109, 40, 114, 36, 117, 34, 117, 34, 143, 17, 145, 18, 146, 19, 162, 12, 165, 10, 178, 7, 189, 6, 190, 8, 177, 9 ], u8.[ 23, 178, 54, 115, 63, 102, 66, 98, 69, 99, 74, 89, 71, 91, 73, 91, 78, 89, 86, 80, 92, 66, 93, 64, 102, 59, 103, 60, 104, 60, 117, 52, 123, 44, 138, 35, 133, 31, 97, 38, 77, 45 ] ],
            [42] u8.[ u8.[ 61, 90, 93, 60, 105, 42, 107, 41, 110, 45, 116, 38, 113, 38, 112, 38, 124, 26, 132, 27, 136, 19, 140, 20, 155, 14, 159, 16, 158, 18, 170, 13, 177, 10, 187, 8, 192, 6, 175, 9, 159, 10 ], u8.[ 21, 178, 59, 110, 71, 86, 75, 85, 84, 83, 91, 66, 88, 73, 87, 72, 92, 75, 98, 72, 105, 58, 107, 54, 115, 52, 114, 55, 112, 56, 129, 51, 132, 40, 150, 33, 140, 29, 98, 35, 77, 42 ] ],
            [42] u8.[ u8.[ 42, 121, 96, 66, 108, 43, 111, 40, 117, 44, 123, 32, 120, 36, 119, 33, 127, 33, 134, 34, 139, 21, 147, 23, 152, 20, 158, 25, 154, 26, 166, 21, 173, 16, 184, 13, 184, 10, 150, 13, 139, 15 ], u8.[ 22, 178, 63, 114, 74, 82, 84, 83, 92, 82, 103, 62, 96, 72, 96, 67, 101, 73, 107, 72, 113, 55, 118, 52, 125, 52, 118, 52, 117, 55, 135, 49, 137, 39, 157, 32, 145, 29, 97, 33, 77, 40 ] ]
        ];
    SMALL_ENERGY_ICDF = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_quant_bands, 2);
}

Val64 :: float32;

