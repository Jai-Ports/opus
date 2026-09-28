// Generated directly from C by cpp_transpiler.
Band_Ctx :: struct {
    encode: s32;
    resynth: s32;
    m: *Custom_Mode;
    i: s32;
    intensity: s32;
    spread: s32;
    tf_change: s32;
    ec: *Ec_Ctx;
    remaining_bits: Int32;
    band_e: *Celt_Ener;
    seed: Uint32;
    arch: s32;
    theta_round: s32;
    disable_inv: s32;
    avoid_split_noise: s32;
}

Split_Ctx :: struct {
    inv: s32;
    imid: s32;
    iside: s32;
    delta: s32;
    itheta: s32;
    qalloc: s32;
}

TRIM_ICDF_storage: [11] u8;

SPREAD_ICDF_storage: [4] u8;

TAPSET_ICDF_storage: [3] u8;

BIT_DEINTERLEAVE_TABLE: [16] u8;

ORDERY_TABLE: [30] s32;

EXP2_TABLE8: [8] Int16;

BIT_INTERLEAVE_TABLE: [16] u8;

ec_range_bytes_in_bands :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_bands :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_bands :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_bands :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_bands :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_bands :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_bands :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_bands :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_bands :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

false__in_bands :: () -> s32 {
    return 0;
}

get_pulses :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

bitexact_cos :: (x: Int16) -> Int16 {
    tmp := (4096 + (cast,no_check(Int32) x) * cast(Int32) x) >> 13;

    x2 := cast,no_check(Int16) tmp;
    x2 =
        cast,no_check(Int16) ((32767 - cast(s32) x2) +
            (16384 + (cast,no_check(Int32) x2) * cast(Int32) (cast,no_check(Int16) (-7651 + (16384 + (cast,no_check(Int32) x2) * cast(Int32) (cast,no_check(Int16) (8277 + (16384 + (cast,no_check(Int32) (cast,no_check(Int16) (-cast(s32) 626))) * cast(Int32) x2) >> 15))) >> 15))) >> 15);

    return cast,no_check(Int16) (1 + cast(s32) x2);
}

bitexact_log2tan :: (isin: s32, icos: s32) -> s32 {
    lc := (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) icos);
    ls := (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) isin);
    c_transpiler_compound_shl(*(icos), ((((15 - lc)) & 31)), s32, s32);
    c_transpiler_compound_shl(*(isin), ((((15 - ls)) & 31)), s32, s32);
    return ((ls - lc) * (cast(s32) 1) << 11 + (16384 + (cast,no_check(Int32) (cast,no_check(Int16) isin)) * cast(Int32) (cast,no_check(Int16) (((16384 + (cast,no_check(Int32) (cast,no_check(Int16) isin)) * cast,no_check(Int32) (cast,no_check(s32) (cast,no_check(Int16) (-cast(s32) 2597)))) >> 15) + 7932))) >> 15) - (16384 + (cast,no_check(Int32) (cast,no_check(Int16) icos)) * cast(Int32) (cast,no_check(Int16) (((16384 + (cast,no_check(Int32) (cast,no_check(Int16) icos)) * cast,no_check(Int32) (cast,no_check(s32) (cast,no_check(Int16) (-cast(s32) 2597)))) >> 15) + 7932))) >> 15;
}

compute_band_energies :: (
    m: *Custom_Mode,
    x: *Celt_Sig,
    band_e: *Celt_Ener,
    end: s32,
    c_value: s32,
    lm: s32,
    arch: s32
) {
    i: s32 = ---;
    e_bands := m.e_bands;
    n := m.short_mdct_size << ((lm) & 31);
    c: s32 = 0;
    while true {
        i = 0;
        while i < end {
            sum :=
                1.0e-27 + celt_inner_prod_c_in_bands(
                    *x[c * n + (cast(s32) e_bands[i]) << ((lm) & 31)],
                    *x[c * n + (cast(s32) e_bands[i]) << ((lm) & 31)],
                    ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i]) << ((lm) & 31)
                );
            band_e[i + c * m.nb_e_bands] = cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) sum);
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
}

celt_inner_prod_c_in_bands :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

normalise_bands :: (
    m: *Custom_Mode,
    freq: *Celt_Sig,
    x: *Celt_Norm,
    band_e: *Celt_Ener,
    end: s32,
    c_value: s32,
    m_value: s32
) {
    i: s32 = ---;
    e_bands := m.e_bands;
    n := m_value * m.short_mdct_size;
    c: s32 = 0;
    while true {
        i = 0;
        while i < end {
            g := 1.0 / (1.0e-27 + band_e[i + c * m.nb_e_bands]);
            j := m_value * cast(s32) e_bands[i];
            while j < m_value * cast(s32) e_bands[i + 1] {
                x[j + c * n] = freq[j + c * n] * g;
                j += 1;
            }
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }
}

denormalise_bands :: (
    m: *Custom_Mode,
    x_value: *Celt_Norm,
    freq: *Celt_Sig,
    band_log_e: *Celt_Glog,
    start: s32,
    end: s32,
    m_value: s32,
    downsample: s32,
    silence: s32
) {
    i: s32 = ---;

    e_bands := m.e_bands;
    n := m_value * m.short_mdct_size;
    bound := m_value * cast(s32) e_bands[end];
    if downsample != 1 {
        bound = ifx bound < n / downsample then bound else n / downsample;
    }
    if silence != 0 {
        bound = 0;
        end = 0;
        start = end;
    }
    f := freq;
    x := x_value + m_value * cast(s32) e_bands[start];
    if start != 0 {
        i = 0;
        while i < m_value * cast(s32) e_bands[start] {
            f.* = 0.0;
            f += 1;
            i += 1;
        }
    } else {
        f += m_value * cast(s32) e_bands[start];
    }
    i = start;
    while i < end {
        j := m_value * cast(s32) e_bands[i];
        band_end := m_value * cast(s32) e_bands[i + 1];
        lg := band_log_e[i] + E_MEANS[i];

        g :=
            cast,no_check(float32) c_transpiler_math_exp(
                0.6931471805599453 * cast,no_check(float64) ((ifx c_transpiler_float_less(32.0, lg) then 32.0 else lg))
            );

        while true {
            f.* = x.* * g;
            f += 1;
            x += 1;
            if !(c_transpiler_pre_increment(*(j)) < band_end) break;
        }
        i += 1;
    }

    fill_memory(*freq[bound], 0, cast,no_check(u64) (n - bound) * size_of(Celt_Sig));
}

spreading_decision :: (
    m: *Custom_Mode,
    x_value: *Celt_Norm,
    average: *s32,
    last_decision: s32,
    hf_average: *s32,
    tapset_decision: *s32,
    update_hf: s32,
    end: s32,
    c_value: s32,
    m_value: s32,
    spread_weight: *s32
) -> s32 {
    i: s32 = ---;
    sum: s32 = 0;
    nb_bands: s32 = 0;
    e_bands := m.e_bands;

    hf_sum: s32 = 0;

    n0 := m_value * m.short_mdct_size;

    if (m_value * ((cast(s32) e_bands[end]) - cast(s32) e_bands[end - 1])) <= 8 {
        return 0;
    }
    c: s32 = 0;
    while true {
        i = 0;
        while i < end {
            tmp: s32 = 0;
            tcount: [3] s32;
            x := (x_value + m_value * cast(s32) e_bands[i]) + c * n0;
            n := m_value * ((cast(s32) e_bands[i + 1]) - cast(s32) e_bands[i]);
            if n <= 8 {
                i += 1;
                continue;
            }

            if 0 < n {
                for j: 0..n - 1 {
                    x2_n := x[j] * x[j] * cast,no_check(Val32) n;
                    if c_transpiler_float_less(x2_n, 0.25) {
                        tcount[0] += 1;
                    }
                    if c_transpiler_float_less(x2_n, 0.0625) {
                        tcount[1] += 1;
                    }
                    if c_transpiler_float_less(x2_n, 0.015625) {
                        tcount[2] += 1;
                    }
                }
            }

            if i > m.nb_e_bands - 4 {
                c_transpiler_compound_add(*(hf_sum), (celt_udiv_in_bands(cast,no_check(Uint32) (32 * (tcount[1] + tcount[0])), cast,no_check(Uint32) n)), Uint32, Uint32);
            }
            tmp = ((cast(s32) (2 * tcount[2] >= n)) + cast(s32) (2 * tcount[1] >= n)) + cast(s32) (2 * tcount[0] >= n);
            sum += tmp * spread_weight[i];
            nb_bands += spread_weight[i];
            i += 1;
        }
        if !(c_transpiler_pre_increment(*(c)) < c_value) break;
    }

    if update_hf != 0 {
        if hf_sum != 0 {
            hf_sum =
                cast,no_check(s32) celt_udiv_in_bands(
                    cast,no_check(Uint32) hf_sum,
                    cast,no_check(Uint32) (c_value * (4 - m.nb_e_bands + end))
                );
        }
        hf_average.* = (hf_average.* + hf_sum) >> 1;
        hf_sum = hf_average.*;
        if tapset_decision.* == 2 {
            hf_sum += 4;
        } else if tapset_decision.* == 0 {
            hf_sum -= 4;
        }
        if hf_sum > 22 {
            tapset_decision.* = 2;
        } else if hf_sum > 18 {
            tapset_decision.* = 1;
        } else {
            tapset_decision.* = 0;
        }
    }

    sum = cast,no_check(s32) celt_udiv_in_bands(cast,no_check(Uint32) (sum << 8), cast,no_check(Uint32) nb_bands);

    sum = (sum + average.*) >> 1;
    average.* = sum;

    sum = (3 * sum + ((3 - last_decision) << 7 + 64) + 2) >> 2;
    decision: s32 = ifx sum < 80
        then cast(s32) 3
        else ifx sum < 256
            then cast(s32) 2
            else ifx sum < 384
                then cast(s32) 1
                else 0;

    return decision;
}

haar1 :: (x: *Celt_Norm, n0: s32, stride: s32) {
    j: s32 = ---;
    c_transpiler_compound_shr(*(n0), (cast(s32) 1), s32, s32);
    if 0 < stride {
        for i: 0..stride - 1 {
            j = 0;
            while j < n0 {
                tmp1: Val32 = ---;
                tmp1 = 0.70710678 * x[stride * 2 * j + i];
                tmp2 := 0.70710678 * x[stride * (2 * j + 1) + i];
                x[stride * 2 * j + i] = tmp1 + tmp2;
                x[stride * (2 * j + 1) + i] = tmp1 - tmp2;
                j += 1;
            }
        }
    }
}

quant_all_bands :: (
    encode: s32,
    m: *Custom_Mode,
    start: s32,
    end: s32,
    x: *Celt_Norm,
    y: *Celt_Norm,
    collapse_masks: *u8,
    band_e: *Celt_Ener,
    pulses: *s32,
    short_blocks: s32,
    spread: s32,
    dual_stereo: s32,
    intensity: s32,
    tf_res: *s32,
    total_bits: Int32,
    balance: Int32,
    ec: *Ec_Ctx,
    lm: s32,
    coded_bands: s32,
    seed: *Uint32,
    complexity: s32,
    arch: s32,
    disable_inv: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    e_bands := m.e_bands;

    update_lowband: s32 = 1;
    c := (ifx y != null then cast(s32) 2 else 1);

    theta_rdo := cast(s32) (encode != 0 && y != null && dual_stereo == 0 && complexity >= 8);

    resynth := cast(s32) (encode == 0 || theta_rdo != 0);

    ctx: Band_Ctx = ---;

    m_value := (cast(s32) 1) << ((lm) & 31);
    b_value := (ifx short_blocks != 0 then m_value else 1);
    norm_offset := m_value * cast(s32) e_bands[start];

    norm_value :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) (c * ((m_value * cast(s32) e_bands[m.nb_e_bands - 1]) - norm_offset)))));
    norm := norm_value;
    norm2 := (norm + m_value * cast(s32) e_bands[m.nb_e_bands - 1]) - norm_offset;

    resynth_alloc: s32 = ifx encode != 0 && resynth != 0
        then m_value * ((cast(s32) e_bands[m.nb_e_bands]) - cast(s32) e_bands[m.nb_e_bands - 1])
        else 0;
    lowband_scratch_value :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) resynth_alloc)));
    lowband_scratch: *Celt_Norm = ifx encode != 0 && resynth != 0
        then lowband_scratch_value
        else x + m_value * cast(s32) e_bands[m.eff_e_bands - 1];
    x_save := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) resynth_alloc)));
    y_save := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) resynth_alloc)));
    x_save2 :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) resynth_alloc)));
    y_save2 :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) resynth_alloc)));
    norm_save2 :=
        cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) *
            cast,no_check(u64) resynth_alloc)));

    lowband_offset: s32 = 0;
    ctx.band_e = band_e;
    ctx.ec = ec;
    ctx.encode = encode;
    ctx.intensity = intensity;
    ctx.m = m;
    ctx.seed = seed.*;
    ctx.spread = spread;
    ctx.arch = arch;
    ctx.disable_inv = disable_inv;
    ctx.resynth = resynth;
    ctx.theta_round = 0;

    bytes_save :=
        cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) *
            (ifx theta_rdo != 0 then cast(u64) 1275 else 0))));

    ctx.avoid_split_noise = cast(s32) (b_value > 1);
    i := start;
    while i < end {
        b: s32 = ---;

        curr_balance: Int32 = ---;
        effective_lowband: s32 = -1;

        tf_change: s32 = 0;
        x_cm: u32 = ---;
        y_cm: u32 = ---;

        ctx.i = i;
        last := cast(s32) (i == end - 1);

        x_value := x + m_value * cast(s32) e_bands[i];
        y_value: *Celt_Norm = ifx y != null
            then y + m_value * cast(s32) e_bands[i]
            else null;
        n := (m_value * cast(s32) e_bands[i + 1]) - m_value * cast(s32) e_bands[i];

        tell := cast,no_check(Int32) ec_tell_frac(ec);

        if i != start {
            balance -= tell;
        }
        remaining_bits := total_bits - tell - 1;
        ctx.remaining_bits = remaining_bits;

        if i <= coded_bands - 1 {
            curr_balance = celt_sudiv_in_bands(balance, (ifx 3 < coded_bands - i then 3 else coded_bands - i));
            b =
                ifx 0 > (ifx 16383 < (ifx remaining_bits + 1 < pulses[i] + curr_balance then remaining_bits + 1 else pulses[i] + curr_balance) then 16383 else (ifx remaining_bits + 1 < pulses[i] + curr_balance then remaining_bits + 1 else pulses[i] +
                    curr_balance)) then 0 else (ifx 16383 < (ifx remaining_bits + 1 < pulses[i] + curr_balance then remaining_bits + 1 else pulses[i] + curr_balance) then 16383 else (ifx remaining_bits + 1 < pulses[i] + curr_balance then remaining_bits + 1 else pulses[i] + curr_balance));
        } else {
            b = 0;
        }

        if resynth != 0 &&
            (((m_value * cast(s32) e_bands[i]) - n) >= m_value * cast(s32) e_bands[start] || i == start + 1) &&
            (update_lowband != 0 || lowband_offset == 0) {
            lowband_offset = i;
        }
        if i == start + 1 {
            special_hybrid_folding(m, norm, norm2, start, m_value, dual_stereo);
        }

        tf_change = tf_res[i];
        ctx.tf_change = tf_change;
        if i >= m.eff_e_bands {
            x_value = norm;
            if y != null {
                y_value = norm;
            }
            lowband_scratch = null;
        }
        if last != 0 && theta_rdo == 0 {
            lowband_scratch = null;
        }

        if lowband_offset != 0 && (spread != 3 || b_value > 1 || tf_change < 0) {
            effective_lowband =
                ifx 0 > ((m_value * cast(s32) e_bands[lowband_offset]) - norm_offset) -
                    n then 0 else ((m_value * cast(s32) e_bands[lowband_offset]) - norm_offset) - n;
            fold_start := lowband_offset;
            while (m_value * cast(s32) (e_bands[c_transpiler_pre_decrement(*(fold_start))])) > effective_lowband + norm_offset {
            }
            fold_end := lowband_offset - 1;

            while c_transpiler_pre_increment(*(fold_end)) < i && (m_value * cast(s32) e_bands[fold_end]) < effective_lowband + norm_offset + n {
            }

            y_cm = 0;
            x_cm = y_cm;
            fold_i := fold_start;
            while true {
                x_cm |= cast,no_check(u32) collapse_masks[fold_i * c + 0];
                y_cm |= cast,no_check(u32) collapse_masks[fold_i * c + c - 1];
                if !(c_transpiler_pre_increment(*(fold_i)) < fold_end) break;
            }
        } else {
            y_cm = cast,no_check(u32) ((cast(s32) 1) << ((b_value) & 31) - 1);
            x_cm = y_cm;
        }

        if dual_stereo != 0 && i == intensity {
            j: s32 = ---;

            dual_stereo = 0;
            if resynth != 0 {
                j = 0;
                while j < (m_value * cast(s32) e_bands[i]) - norm_offset {
                    norm[j] = 0.5 * (norm[j] + norm2[j]);
                    j += 1;
                }
            }
        }
        if dual_stereo != 0 {
            x_cm =
                quant_band(
                    *ctx,
                    x_value,
                    n,
                    b / 2,
                    b_value,
                    (ifx effective_lowband != -1 then norm + effective_lowband else null),
                    lm,
                    (ifx last != 0 then null else (norm + m_value * cast(s32) e_bands[i]) - norm_offset),
                    1.0,
                    lowband_scratch,
                    cast,no_check(s32) x_cm
                );
            y_cm =
                quant_band(
                    *ctx,
                    y_value,
                    n,
                    b / 2,
                    b_value,
                    (ifx effective_lowband != -1 then norm2 + effective_lowband else null),
                    lm,
                    (ifx last != 0 then null else (norm2 + m_value * cast(s32) e_bands[i]) - norm_offset),
                    1.0,
                    lowband_scratch,
                    cast,no_check(s32) y_cm
                );
        } else {
            if y_value != null {
                if theta_rdo != 0 && i < intensity {
                    ec_save, ec_save2: Ec_Ctx = ---;
                    ctx_save, ctx_save2: Band_Ctx = ---;

                    w: [2] Val16 = ---;
                    compute_channel_weights(band_e[i], band_e[i + m.nb_e_bands], w.data);

                    cm := x_cm | y_cm;
                    ec_save = ec.*;

                    ctx_save = ctx;
                    copy_memory(
                        x_save,
                        x_value,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x_save - x_value))
                    );
                    copy_memory(
                        y_save,
                        y_value,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y_save - y_value))
                    );

                    ctx.theta_round = -1;
                    x_cm =
                        quant_band_stereo(
                            *ctx,
                            x_value,
                            y_value,
                            n,
                            b,
                            b_value,
                            (ifx effective_lowband != -1 then norm + effective_lowband else null),
                            lm,
                            (ifx last != 0 then null else (norm + m_value * cast(s32) e_bands[i]) - norm_offset),
                            lowband_scratch,
                            cast,no_check(s32) cm
                        );
                    dist0 :=
                        w[0] * celt_inner_prod_c_in_bands(x_save, x_value, n) +
                            w[1] * celt_inner_prod_c_in_bands(y_save, y_value, n);

                    cm2 := x_cm;
                    ec_save2 = ec.*;

                    ctx_save2 = ctx;
                    copy_memory(
                        x_save2,
                        x_value,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x_save2 - x_value))
                    );
                    copy_memory(
                        y_save2,
                        y_value,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y_save2 - y_value))
                    );
                    if last == 0 {
                        copy_memory(
                            norm_save2,
                            (norm + m_value * cast(s32) e_bands[i]) - norm_offset,
                            (cast,no_check(u64) n) * size_of(Celt_Norm) +
                            cast,no_check(u64) (0 * (norm_save2 - ((norm + m_value * cast(s32) e_bands[i]) - norm_offset)))
                        );
                    }
                    nstart_bytes := cast,no_check(s32) ec_save.offs;
                    nend_bytes := cast,no_check(s32) ec_save.storage;
                    bytes_buf := ec_save.buf + nstart_bytes;
                    save_bytes := nend_bytes - nstart_bytes;
                    copy_memory(
                        bytes_save,
                        bytes_buf,
                        (cast,no_check(u64) save_bytes) * size_of(u8) +
                        cast,no_check(u64) (0 * (bytes_save - bytes_buf))
                    );

                    ec.* = ec_save;

                    ctx = ctx_save;
                    copy_memory(
                        x_value,
                        x_save,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x_value - x_save))
                    );
                    copy_memory(
                        y_value,
                        y_save,
                        (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y_value - y_save))
                    );

                    if i == start + 1 {
                        special_hybrid_folding(m, norm, norm2, start, m_value, dual_stereo);
                    }

                    ctx.theta_round = 1;
                    x_cm =
                        quant_band_stereo(
                            *ctx,
                            x_value,
                            y_value,
                            n,
                            b,
                            b_value,
                            (ifx effective_lowband != -1 then norm + effective_lowband else null),
                            lm,
                            (ifx last != 0 then null else (norm + m_value * cast(s32) e_bands[i]) - norm_offset),
                            lowband_scratch,
                            cast,no_check(s32) cm
                        );
                    dist1 :=
                        w[0] * celt_inner_prod_c_in_bands(x_save, x_value, n) +
                            w[1] * celt_inner_prod_c_in_bands(y_save, y_value, n);
                    if c_transpiler_float_greater_equal(dist0, dist1) {
                        x_cm = cm2;
                        ec.* = ec_save2;

                        ctx = ctx_save2;
                        copy_memory(
                            x_value,
                            x_save2,
                            (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x_value - x_save2))
                        );
                        copy_memory(
                            y_value,
                            y_save2,
                            (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y_value - y_save2))
                        );
                        if last == 0 {
                            copy_memory(
                                (norm + m_value * cast(s32) e_bands[i]) - norm_offset,
                                norm_save2,
                                (cast,no_check(u64) n) * size_of(Celt_Norm) +
                                cast,no_check(u64) (0 * (((norm + m_value * cast(s32) e_bands[i]) - norm_offset) - norm_save2))
                            );
                        }
                        copy_memory(
                            bytes_buf,
                            bytes_save,
                            (cast,no_check(u64) save_bytes) * size_of(u8) +
                            cast,no_check(u64) (0 * (bytes_buf - bytes_save))
                        );
                    }
                } else {
                    ctx.theta_round = 0;
                    x_cm =
                        quant_band_stereo(
                            *ctx,
                            x_value,
                            y_value,
                            n,
                            b,
                            b_value,
                            (ifx effective_lowband != -1 then norm + effective_lowband else null),
                            lm,
                            (ifx last != 0 then null else (norm + m_value * cast(s32) e_bands[i]) - norm_offset),
                            lowband_scratch,
                            cast,no_check(s32) (x_cm | y_cm)
                        );
                }
            } else {
                x_cm =
                    quant_band(
                        *ctx,
                        x_value,
                        n,
                        b,
                        b_value,
                        (ifx effective_lowband != -1 then norm + effective_lowband else null),
                        lm,
                        (ifx last != 0 then null else (norm + m_value * cast(s32) e_bands[i]) - norm_offset),
                        1.0,
                        lowband_scratch,
                        cast,no_check(s32) (x_cm | y_cm)
                    );
            }
            y_cm = x_cm;
        }
        collapse_masks[i * c + 0] = cast,no_check(u8) x_cm;
        collapse_masks[i * c + c - 1] = cast,no_check(u8) y_cm;
        balance = cast,no_check(Int32) (balance + (pulses[i] + tell));

        update_lowband = cast(s32) (b > n << 3);

        ctx.avoid_split_noise = 0;
        i += 1;
    }
    seed.* = ctx.seed;
}

quant_band :: (
    ctx: *Band_Ctx,
    x: *Celt_Norm,
    n_value: s32,
    b: s32,
    b_value: s32,
    lowband: *Celt_Norm,
    lm: s32,
    lowband_out: *Celt_Norm,
    gain: Val32,
    lowband_scratch: *Celt_Norm,
    fill: s32
) -> u32 {
    n0 := n_value;
    n_b := n_value;

    b0 := b_value;
    time_divide: s32 = 0;
    recombine: s32 = 0;

    cm: u32 = 0;

    encode := ctx.encode;
    tf_change := ctx.tf_change;

    long_blocks := cast(s32) (b0 == 1);

    n_b = cast,no_check(s32) celt_udiv_in_bands(cast,no_check(Uint32) n_b, cast,no_check(Uint32) b_value);

    if n_value == 1 {
        return quant_band_n1(ctx, x, null, lowband_out);
    }

    if tf_change > 0 {
        recombine = tf_change;
    }

    if lowband_scratch != null && lowband != null && (recombine != 0 || n_b & 1 == 0 && tf_change < 0 || b0 > 1) {
        copy_memory(
            lowband_scratch,
            lowband,
            (cast,no_check(u64) n_value) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (lowband_scratch - lowband))
        );
        lowband = lowband_scratch;
    }

    if 0 < recombine {
        for k: 0..recombine - 1 {
            if encode != 0 {
                haar1(x, n_value >> ((k) & 31), (cast(s32) 1) << ((k) & 31));
            }
            if lowband != null {
                haar1(lowband, n_value >> ((k) & 31), (cast(s32) 1) << ((k) & 31));
            }
            fill = (cast(s32) BIT_INTERLEAVE_TABLE[fill & 0xf]) | ((cast(s32) BIT_INTERLEAVE_TABLE[fill >> 4]) << 2);
        }
    }
    c_transpiler_compound_shr(*(b_value), (((recombine) & 31)), s32, s32);
    c_transpiler_compound_shl(*(n_b), (((recombine) & 31)), s32, s32);

    while n_b & 1 == 0 && tf_change < 0 {
        if encode != 0 {
            haar1(x, n_b, b_value);
        }
        if lowband != null {
            haar1(lowband, n_b, b_value);
        }
        fill |= fill << ((b_value) & 31);
        c_transpiler_compound_shl(*(b_value), (cast(s32) 1), s32, s32);
        c_transpiler_compound_shr(*(n_b), (cast(s32) 1), s32, s32);
        time_divide += 1;
        tf_change += 1;
    }
    b0 = b_value;
    n_b0 := n_b;

    if b0 > 1 {
        if encode != 0 {
            deinterleave_hadamard(x, n_b >> ((recombine) & 31), b0 << ((recombine) & 31), long_blocks);
        }
        if lowband != null {
            deinterleave_hadamard(lowband, n_b >> ((recombine) & 31), b0 << ((recombine) & 31), long_blocks);
        }
    }

    cm = quant_partition(ctx, x, n_value, b, b_value, lowband, lm, gain, fill);

    if ctx.resynth != 0 {
        if b0 > 1 {
            interleave_hadamard(x, n_b >> ((recombine) & 31), b0 << ((recombine) & 31), long_blocks);
        }

        n_b = n_b0;
        b_value = b0;
        if 0 < time_divide {
            for k: 0..time_divide - 1 {
                c_transpiler_compound_shr(*(b_value), (cast(s32) 1), s32, s32);
                c_transpiler_compound_shl(*(n_b), (cast(s32) 1), s32, s32);
                cm |= cm >> ((b_value) & 31);
                haar1(x, n_b, b_value);
            }
        }

        if 0 < recombine {
            for k: 0..recombine - 1 {
                cm = cast,no_check(u32) BIT_DEINTERLEAVE_TABLE[cm];
                haar1(x, n0 >> ((k) & 31), (cast(s32) 1) << ((k) & 31));
            }
        }
        c_transpiler_compound_shl(*(b_value), (((recombine) & 31)), s32, s32);

        if lowband_out != null {
            n := cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) n0);
            if 0 < n0 {
                for j: 0..n0 - 1 {
                    lowband_out[j] = n * x[j];
                }
            }
        }
        cm &= cast,no_check(u32) ((cast(s32) 1) << ((b_value) & 31) - 1);
    }
    return cm;
}

interleave_hadamard :: (x: *Celt_Norm, n0: s32, stride: s32, hadamard: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    j: s32 = ---;

    n := n0 * stride;
    tmp := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) n)));
    if hadamard != 0 {
        ordery := ORDERY_TABLE.data + stride - 2;
        if 0 < stride {
            for i: 0..stride - 1 {
                j = 0;
                while j < n0 {
                    tmp[j * stride + i] = x[ordery[i] * n0 + j];
                    j += 1;
                }
            }
        }
    } else {
        if 0 < stride {
            for i: 0..stride - 1 {
                j = 0;
                while j < n0 {
                    tmp[j * stride + i] = x[i * n0 + j];
                    j += 1;
                }
            }
        }
    }
    copy_memory(x, tmp, (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x - tmp)));
}

quant_partition :: (
    ctx: *Band_Ctx,
    x: *Celt_Norm,
    n: s32,
    b: s32,
    b_value: s32,
    lowband: *Celt_Norm,
    lm: s32,
    gain: Val32,
    fill: s32
) -> u32 {
    q: s32 = ---;
    curr_bits: s32 = ---;
    imid: s32 = 0;
    iside: s32 = 0;
    b0 := b_value;
    mid: Val32 = 0.0;
    side: Val32 = 0.0;
    cm: u32 = 0;
    y: *Celt_Norm = null;

    encode := ctx.encode;
    m := ctx.m;
    i := ctx.i;
    spread := ctx.spread;
    ec := ctx.ec;

    cache := m.cache.bits + cast,no_check(s32) m.cache.index[(lm + 1) * m.nb_e_bands + i];
    if lm != -1 && b > (cast(s32) cache[cache[0]]) + 12 && n > 2 {
        sctx: Split_Ctx = ---;
        next_lowband2: *Celt_Norm = null;

        c_transpiler_compound_shr(*(n), (cast(s32) 1), s32, s32);
        y = x + n;
        lm -= 1;
        if b_value == 1 {
            fill = fill & 1 | (fill << 1);
        }
        b_value = (b_value + 1) >> 1;

        compute_theta(ctx, *sctx, x, y, n, *b, b_value, b0, lm, 0, *fill);
        imid = sctx.imid;
        iside = sctx.iside;
        delta := sctx.delta;
        itheta := sctx.itheta;
        qalloc := sctx.qalloc;

        mid = (cast(float32) 0.000030517578125) * cast,no_check(float32) imid;
        side = (cast(float32) 0.000030517578125) * cast,no_check(float32) iside;

        if b0 > 1 && itheta & 0x3fff != 0 {
            if itheta > 8192 {
                delta -= delta >> (((4 - lm)) & 31);
            } else {
                delta = ifx 0 < delta + n << 3 >> (((5 - lm)) & 31) then 0 else delta + n << 3 >> (((5 - lm)) & 31);
            }
        }
        mbits :=
            (ifx 0 > (ifx b < (b - delta) / 2 then b else (b - delta) /
                2) then 0 else (ifx b < (b - delta) / 2 then b else (b - delta) / 2));
        sbits := b - mbits;
        ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - qalloc);

        if lowband != null {
            next_lowband2 = lowband + n;
        }

        rebalance := ctx.remaining_bits;
        if mbits >= sbits {
            cm = quant_partition(ctx, x, n, mbits, b_value, lowband, lm, gain * mid, fill);
            rebalance = mbits - (rebalance - ctx.remaining_bits);
            if rebalance > (cast(s32) 3) << 3 && itheta != 0 {
                sbits = cast,no_check(s32) (sbits + (rebalance - cast,no_check(Int32) (((cast(s32) 3) << 3))));
            }
            cm |=
                quant_partition(ctx, y, n, sbits, b_value, next_lowband2, lm, gain *
                    side, fill >> ((b_value) & 31)) << (((b0 >> 1)) & 31);
        } else {
            cm =
                quant_partition(ctx, y, n, sbits, b_value, next_lowband2, lm, gain *
                    side, fill >> ((b_value) & 31)) << (((b0 >> 1)) & 31);
            rebalance = sbits - (rebalance - ctx.remaining_bits);
            if rebalance > (cast(s32) 3) << 3 && itheta != 16384 {
                mbits = cast,no_check(s32) (mbits + (rebalance - cast,no_check(Int32) (((cast(s32) 3) << 3))));
            }
            cm |= quant_partition(ctx, x, n, mbits, b_value, lowband, lm, gain * mid, fill);
        }
    } else {
        q = bits2pulses(m, i, lm, b);
        curr_bits = pulses2bits(m, i, lm, q);
        ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - curr_bits);

        while ctx.remaining_bits < 0 && q > 0 {
            ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits + curr_bits);
            q -= 1;
            curr_bits = pulses2bits(m, i, lm, q);
            ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - curr_bits);
        }

        if q != 0 {
            k := get_pulses(q);

            if encode != 0 {
                cm = alg_quant(x, n, k, spread, b_value, ec, gain, ctx.resynth, ctx.arch);
            } else {
                cm = alg_unquant(x, n, k, spread, b_value, ec, gain);
            }
        } else {
            if ctx.resynth != 0 {
                cm_mask := (cast,no_check(u32) ((cast(u64) 1) << ((b_value) & 63))) - 1;
                fill = cast,no_check(s32) ((cast,no_check(u32) fill) & cm_mask);
                if fill == 0 {
                    fill_memory(x, 0, cast,no_check(u64) n * size_of(Celt_Norm));
                } else {
                    if lowband == null {
                        if 0 < n {
                            for j: 0..n - 1 {
                                ctx.seed = celt_lcg_rand(ctx.seed);
                                x[j] = cast,no_check(Celt_Norm) ((cast,no_check(Int32) ctx.seed) >> 20);
                            }
                        }
                        cm = cm_mask;
                    } else {
                        if 0 < n {
                            for j: 0..n - 1 {
                                ctx.seed = celt_lcg_rand(ctx.seed);

                                tmp: Val16 = 0.00390625;
                                tmp = ifx ctx.seed & 0x8000 != 0 then tmp else -tmp;
                                x[j] = lowband[j] + tmp;
                            }
                        }
                        cm = cast,no_check(u32) fill;
                    }
                    renormalise_vector(x, n, gain, ctx.arch);
                }
            }
        }
    }

    return cm;
}

celt_lcg_rand :: (seed: Uint32) -> Uint32 {
    return 1664525 * seed + 1013904223;
}

compute_theta :: (
    ctx: *Band_Ctx,
    sctx: *Split_Ctx,
    x_value: *Celt_Norm,
    y: *Celt_Norm,
    n: s32,
    b: *s32,
    b_value: s32,
    b0: s32,
    lm: s32,
    stereo: s32,
    fill: *s32
) {
    itheta: s32 = 0;
    itheta_q30: s32 = 0;
    delta: s32 = ---;
    imid, iside: s32 = ---;

    inv: s32 = 0;

    encode := ctx.encode;
    m := ctx.m;
    i := ctx.i;
    intensity := ctx.intensity;
    ec := ctx.ec;
    band_e := ctx.band_e;

    pulse_cap := (cast(s32) m.log_n[i]) + lm * (cast(s32) 1) << 3;
    offset := pulse_cap >> 1 - (ifx stereo != 0 && n == 2 then cast(s32) 16 else 4);
    qn := compute_qn(n, b.*, offset, pulse_cap, stereo);
    if stereo != 0 && i >= intensity {
        qn = 1;
    }
    if encode != 0 {
        itheta_q30 = stereo_itheta(x_value, y, stereo, n, ctx.arch);
        itheta = itheta_q30 >> 16;
    }
    tell := cast,no_check(Int32) ec_tell_frac(ec);
    if qn != 1 {
        if encode != 0 {
            if stereo == 0 || ctx.theta_round == 0 {
                itheta = (itheta * qn + 8192) >> 14;
                if stereo == 0 && ctx.avoid_split_noise != 0 && itheta > 0 && itheta < qn {
                    unquantized :=
                        cast,no_check(s32) celt_udiv_in_bands(
                            cast,no_check(Uint32) (itheta * 16384),
                            cast,no_check(Uint32) qn
                        );
                    imid = cast,no_check(s32) bitexact_cos(cast,no_check(Int16) unquantized);
                    iside = cast,no_check(s32) bitexact_cos(cast,no_check(Int16) (16384 - unquantized));
                    delta =
                        (16384 +
                            (cast,no_check(Int32) (cast,no_check(Int16) ((n - 1) << 7))) * cast(Int32) (cast,no_check(Int16) bitexact_log2tan(iside, imid))) >> 15;
                    if delta > b.* {
                        itheta = qn;
                    } else if delta < -b.* {
                        itheta = 0;
                    }
                }
            } else {
                bias := (ifx itheta > 8192 then 32767 / qn else -32767 / qn);
                down :=
                    (ifx qn - 1 < (ifx 0 > (itheta * qn + bias) >> 14 then 0 else (itheta * qn + bias) >> 14) then qn -
                        1 else (ifx 0 > (itheta * qn + bias) >> 14 then 0 else (itheta * qn + bias) >> 14));
                if ctx.theta_round < 0 {
                    itheta = down;
                } else {
                    itheta = down + 1;
                }
            }
        }

        if stereo != 0 && n > 2 {
            p0: s32 = 3;
            x := itheta;
            x0 := qn / 2;
            ft := p0 * (x0 + 1) + x0;

            if encode != 0 {
                ec_encode(
                    ec,
                    cast,no_check(u32) ((ifx x <= x0 then p0 * x else x - 1 - x0 + (x0 + 1) * p0)),
                    cast,no_check(u32) ((ifx x <= x0 then p0 * (x + 1) else x - x0 + (x0 + 1) * p0)),
                    cast,no_check(u32) ft
                );
            } else {
                fs := cast,no_check(s32) ec_decode(ec, cast,no_check(u32) ft);
                if fs < (x0 + 1) * p0 {
                    x = fs / p0;
                } else {
                    x = x0 + 1 + (fs - (x0 + 1) * p0);
                }
                ec_dec_update(
                    ec,
                    cast,no_check(u32) ((ifx x <= x0 then p0 * x else x - 1 - x0 + (x0 + 1) * p0)),
                    cast,no_check(u32) ((ifx x <= x0 then p0 * (x + 1) else x - x0 + (x0 + 1) * p0)),
                    cast,no_check(u32) ft
                );
                itheta = x;
            }
        } else if b0 > 1 || stereo != 0 {
            if encode != 0 {
                ec_enc_uint(ec, cast,no_check(Uint32) itheta, cast,no_check(Uint32) (qn + 1));
            } else {
                itheta = cast,no_check(s32) ec_dec_uint(ec, cast,no_check(Uint32) (qn + 1));
            }
        } else {
            fs: s32 = 1;
            ft: s32 = ---;
            ft = (qn >> 1 + 1) * (qn >> 1 + 1);
            if encode != 0 {
                fs = ifx itheta <= qn >> 1 then itheta + 1 else qn + 1 - itheta;
                fl :=
                    (ifx itheta <= qn >> 1 then (itheta * (itheta + 1)) >> 1 else ft -
                        ((qn + 1 - itheta) * (qn + 2 - itheta)) >> 1);

                ec_encode(ec, cast,no_check(u32) fl, cast,no_check(u32) (fl + fs), cast,no_check(u32) ft);
            } else {
                fl: s32 = 0;
                fm := cast,no_check(s32) ec_decode(ec, cast,no_check(u32) ft);

                if fm < (qn >> 1 * (qn >> 1 + 1)) >> 1 {
                    itheta = cast,no_check(s32) ((isqrt32((8 * cast,no_check(Uint32) fm) + 1) - 1) >> 1);
                    fs = itheta + 1;
                    fl = (itheta * (itheta + 1)) >> 1;
                } else {
                    itheta =
                        cast,no_check(s32) (((cast,no_check(u32) (2 * (qn + 1))) -
                            isqrt32((8 * cast,no_check(Uint32) (ft - fm - 1)) + 1)) >> 1);
                    fs = qn + 1 - itheta;
                    fl = ft - ((qn + 1 - itheta) * (qn + 2 - itheta)) >> 1;
                }

                ec_dec_update(ec, cast,no_check(u32) fl, cast,no_check(u32) (fl + fs), cast,no_check(u32) ft);
            }
        }

        itheta =
            cast,no_check(s32) celt_udiv_in_bands(
                cast,no_check(Uint32) (itheta * 16384),
                cast,no_check(Uint32) qn
            );

        if encode != 0 && stereo != 0 {
            if itheta == 0 {
                intensity_stereo(m, x_value, y, band_e, i, n);
            } else {
                stereo_split(x_value, y, n);
            }
        }
    } else if stereo != 0 {
        if encode != 0 {
            inv = cast(s32) (itheta > 8192 && ctx.disable_inv == 0);
            if inv != 0 {
                if 0 < n {
                    for j: 0..n - 1 {
                        y[j] = -y[j];
                    }
                }
            }
            intensity_stereo(m, x_value, y, band_e, i, n);
        }
        if b.* > (cast(s32) 2) << 3 && ctx.remaining_bits > (cast(s32) 2) << 3 {
            if encode != 0 {
                ec_enc_bit_logp(ec, inv, 2);
            } else {
                inv = ec_dec_bit_logp(ec, 2);
            }
        } else {
            inv = 0;
        }

        if ctx.disable_inv != 0 {
            inv = 0;
        }
        itheta = 0;
        itheta_q30 = 0;
    }
    qalloc := cast,no_check(s32) (ec_tell_frac(ec) - cast,no_check(Uint32) tell);
    b.* -= qalloc;

    if itheta == 0 {
        imid = 32767;
        iside = 0;
        fill.* &= (cast(s32) 1) << ((b_value) & 31) - 1;
        delta = -16384;
    } else if itheta == 16384 {
        imid = 0;
        iside = 32767;
        fill.* &= ((cast(s32) 1) << ((b_value) & 31) - 1) << ((b_value) & 31);
        delta = 16384;
    } else {
        imid = cast,no_check(s32) bitexact_cos(cast,no_check(Int16) itheta);
        iside = cast,no_check(s32) bitexact_cos(cast,no_check(Int16) (16384 - itheta));

        delta =
            (16384 +
                (cast,no_check(Int32) (cast,no_check(Int16) ((n - 1) << 7))) * cast(Int32) (cast,no_check(Int16) bitexact_log2tan(iside, imid))) >> 15;
    }

    sctx.inv = inv;
    sctx.imid = imid;
    sctx.iside = iside;
    sctx.delta = delta;
    sctx.itheta = itheta;

    sctx.qalloc = qalloc;
}

intensity_stereo :: (m: *Custom_Mode, x: *Celt_Norm, y: *Celt_Norm, band_e: *Celt_Ener, band_id: s32, n: s32) {
    i := band_id;

    left := band_e[i];
    right := band_e[i + m.nb_e_bands];
    norm :=
        1.0e-15 +
            cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (1.0e-15 + left * left + right * right));

    a1 := left / norm;
    a2 := right / norm;
    if 0 < n {
        for j: 0..n - 1 {
            x[j] = a1 * x[j] + a2 * y[j];
        }
    }
}

stereo_split :: (x: *Celt_Norm, y: *Celt_Norm, n: s32) {
    if 0 < n {
        for j: 0..n - 1 {
            l: Val32 = ---;
            l = 0.70710678 * x[j];
            r := 0.70710678 * y[j];
            x[j] = l + r;
            y[j] = r - l;
        }
    }
}

compute_qn :: (n: s32, b: s32, offset: s32, pulse_cap: s32, stereo: s32) -> s32 {
    qn: s32 = ---;
    n2 := 2 * n - 1;
    if stereo != 0 && n == 2 {
        n2 -= 1;
    }

    qb := celt_sudiv_in_bands(b + n2 * offset, n2);
    qb = ifx b - pulse_cap - (cast(s32) 4) << 3 < qb then b - pulse_cap - (cast(s32) 4) << 3 else qb;

    qb = ifx (cast(s32) 8) << 3 < qb then (cast(s32) 8) << 3 else qb;

    if qb < (cast(s32) 1) << 3 >> 1 {
        qn = 1;
    } else {
        qn = (cast(s32) EXP2_TABLE8[qb & 0x7]) >> (((14 - qb >> 3)) & 31);
        qn = (qn + 1) >> 1 << 1;
    }

    return qn;
}

deinterleave_hadamard :: (x: *Celt_Norm, n0: s32, stride: s32, hadamard: s32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    j: s32 = ---;

    n := n0 * stride;
    tmp := cast(*Celt_Norm) c_transpiler_alloca(cast(u64) ((size_of(Celt_Norm) * cast,no_check(u64) n)));

    if hadamard != 0 {
        ordery := ORDERY_TABLE.data + stride - 2;
        if 0 < stride {
            for i: 0..stride - 1 {
                j = 0;
                while j < n0 {
                    tmp[ordery[i] * n0 + j] = x[j * stride + i];
                    j += 1;
                }
            }
        }
    } else {
        if 0 < stride {
            for i: 0..stride - 1 {
                j = 0;
                while j < n0 {
                    tmp[i * n0 + j] = x[j * stride + i];
                    j += 1;
                }
            }
        }
    }
    copy_memory(x, tmp, (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x - tmp)));
}

quant_band_n1 :: (ctx: *Band_Ctx, x_value: *Celt_Norm, y: *Celt_Norm, lowband_out: *Celt_Norm) -> u32 {
    x := x_value;

    encode := ctx.encode;
    ec := ctx.ec;

    stereo := cast(s32) (y != null);
    c: s32 = 0;
    while true {
        {
            sign: s32 = 0;
            if ctx.remaining_bits >= (cast(s32) 1) << 3 {
                if encode != 0 {
                    sign = cast(s32) (c_transpiler_float_less(x[0], 0.0));
                    ec_enc_bits(ec, cast,no_check(Uint32) sign, 1);
                } else {
                    sign = cast,no_check(s32) ec_dec_bits(ec, 1);
                }
                ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - ((cast(s32) 1) << 3));
            }
            if ctx.resynth != 0 {
                x[0] = ifx sign != 0 then -1.0 else 1.0;
            }
            x = y;
        }
        if !(c_transpiler_pre_increment(*(c)) < 1 + stereo) break;
    }
    if lowband_out != null {
        lowband_out[0] = x_value[0];
    }
    return 1;
}

quant_band_stereo :: (
    ctx: *Band_Ctx,
    x: *Celt_Norm,
    y: *Celt_Norm,
    n: s32,
    b: s32,
    b_value: s32,
    lowband: *Celt_Norm,
    lm: s32,
    lowband_out: *Celt_Norm,
    lowband_scratch: *Celt_Norm,
    fill: s32
) -> u32 {
    imid: s32 = 0;
    iside: s32 = 0;
    inv: s32 = 0;
    mid: Val32 = 0.0;
    side: Val32 = 0.0;
    cm: u32 = 0;
    mbits: s32 = ---;
    sbits: s32 = ---;

    sctx: Split_Ctx = ---;

    encode := ctx.encode;
    ec := ctx.ec;

    if n == 1 {
        return quant_band_n1(ctx, x, y, lowband_out);
    }

    orig_fill := fill;

    if encode != 0 {
        if c_transpiler_float_less(ctx.band_e[ctx.i], 1.0e-10) ||
            c_transpiler_float_less(ctx.band_e[ctx.m.nb_e_bands + ctx.i], 1.0e-10) {
            if c_transpiler_float_greater(ctx.band_e[ctx.i], ctx.band_e[ctx.m.nb_e_bands + ctx.i]) {
                copy_memory(y, x, (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y - x)));
            } else {
                copy_memory(x, y, (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (x - y)));
            }
        }
    }
    compute_theta(ctx, *sctx, x, y, n, *b, b_value, b_value, lm, 1, *fill);
    inv = sctx.inv;
    imid = sctx.imid;
    iside = sctx.iside;
    delta := sctx.delta;
    itheta := sctx.itheta;
    qalloc := sctx.qalloc;

    mid = (cast(float32) 0.000030517578125) * cast,no_check(float32) imid;
    side = (cast(float32) 0.000030517578125) * cast,no_check(float32) iside;

    if n == 2 {
        sign: s32 = 0;

        mbits = b;
        sbits = 0;

        if itheta != 0 && itheta != 16384 {
            sbits = (cast(s32) 1) << 3;
        }
        mbits -= sbits;
        c := cast(s32) (itheta > 8192);
        ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - (qalloc + sbits));

        x2 := (ifx c != 0 then y else x);
        y2 := (ifx c != 0 then x else y);
        if sbits != 0 {
            if encode != 0 {
                sign = cast(s32) (c_transpiler_float_less((x2[0] * y2[1] - x2[1] * y2[0]), 0.0));
                ec_enc_bits(ec, cast,no_check(Uint32) sign, 1);
            } else {
                sign = cast,no_check(s32) ec_dec_bits(ec, 1);
            }
        }
        sign = 1 - 2 * sign;

        cm = quant_band(ctx, x2, n, mbits, b_value, lowband, lm, lowband_out, 1.0, lowband_scratch, orig_fill);

        y2[0] = -sign * x2[1];
        y2[1] = sign * x2[0];
        if ctx.resynth != 0 {
            x[0] = mid * x[0];
            x[1] = mid * x[1];
            y[0] = side * y[0];
            y[1] = side * y[1];
            tmp := x[0];
            x[0] = tmp - y[0];
            y[0] = tmp + y[0];
            tmp = x[1];
            x[1] = tmp - y[1];
            y[1] = tmp + y[1];
        }
    } else {
        mbits =
            ifx 0 > (ifx b < (b - delta) / 2 then b else (b - delta) /
                2) then 0 else (ifx b < (b - delta) / 2 then b else (b - delta) / 2);
        sbits = b - mbits;
        ctx.remaining_bits = cast,no_check(Int32) (ctx.remaining_bits - qalloc);

        rebalance := ctx.remaining_bits;
        if mbits >= sbits {
            cm = quant_band(ctx, x, n, mbits, b_value, lowband, lm, lowband_out, 1.0, lowband_scratch, fill);
            rebalance = mbits - (rebalance - ctx.remaining_bits);
            if rebalance > (cast(s32) 3) << 3 && itheta != 0 {
                sbits = cast,no_check(s32) (sbits + (rebalance - cast,no_check(Int32) (((cast(s32) 3) << 3))));
            }

            cm |= quant_band(ctx, y, n, sbits, b_value, null, lm, null, side, null, fill >> ((b_value) & 31));
        } else {
            cm = quant_band(ctx, y, n, sbits, b_value, null, lm, null, side, null, fill >> ((b_value) & 31));
            rebalance = sbits - (rebalance - ctx.remaining_bits);
            if rebalance > (cast(s32) 3) << 3 && itheta != 16384 {
                mbits = cast,no_check(s32) (mbits + (rebalance - cast,no_check(Int32) (((cast(s32) 3) << 3))));
            }

            cm |= quant_band(ctx, x, n, mbits, b_value, lowband, lm, lowband_out, 1.0, lowband_scratch, fill);
        }
    }

    if ctx.resynth != 0 {
        if n != 2 {
            stereo_merge(x, y, mid, n, ctx.arch);
        }
        if inv != 0 {
            if 0 < n {
                for j: 0..n - 1 {
                    y[j] = -y[j];
                }
            }
        }
    }
    return cm;
}

stereo_merge :: (x: *Celt_Norm, y: *Celt_Norm, mid: Val32, n: s32, arch: s32) {
    xp: Val32 = 0.0;
    side: Val32 = 0.0;

    xp = celt_inner_prod_c_in_bands(y, x, n);
    side = celt_inner_prod_c_in_bands(y, y, n);

    xp = mid * xp;

    el := mid * mid + side - 2.0 * xp;
    er := mid * mid + side + 2.0 * xp;
    if c_transpiler_float_less(er, 6.0e-4) || c_transpiler_float_less(el, 6.0e-4) {
        copy_memory(y, x, (cast,no_check(u64) n) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (y - x)));
        return;
    }

    t := el;
    lgain := 1.0 / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) t);
    t = er;
    rgain := 1.0 / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) t);

    if 0 < n {
        for j: 0..n - 1 {
            l: Celt_Norm = ---;

            l = mid * x[j];
            r := y[j];
            x[j] = lgain * (l - r);
            y[j] = rgain * (l + r);
        }
    }
}

special_hybrid_folding :: (
    m: *Custom_Mode,
    norm: *Celt_Norm,
    norm2: *Celt_Norm,
    start: s32,
    m_value: s32,
    dual_stereo: s32
) {
    e_bands := m.e_bands;
    n1 := m_value * ((cast(s32) e_bands[start + 1]) - cast(s32) e_bands[start]);
    n2 := m_value * ((cast(s32) e_bands[start + 2]) - cast(s32) e_bands[start + 1]);

    copy_memory(
        *norm[n1],
        *norm[2 * n1 - n2],
        (cast,no_check(u64) (n2 - n1)) * size_of(Celt_Norm) + cast,no_check(u64) (0 * (*norm[n1] - *norm[2 * n1 - n2]))
    );
    if dual_stereo != 0 {
        copy_memory(
            *norm2[n1],
            *norm2[2 * n1 - n2],
            (cast,no_check(u64) (n2 - n1)) * size_of(Celt_Norm) +
            cast,no_check(u64) (0 * (*norm2[n1] - *norm2[2 * n1 - n2]))
        );
    }
}

compute_channel_weights :: (ex: Celt_Ener, ey: Celt_Ener, w: *Val16) {
    min_e := (ifx c_transpiler_float_less(ex, ey) then ex else ey);

    ex = ex + min_e / 3.0;
    ey = ey + min_e / 3.0;

    w[0] = ex;
    w[1] = ey;
}

anti_collapse :: (
    m: *Custom_Mode,
    x: *Celt_Norm,
    collapse_masks: *u8,
    lm: s32,
    c_value: s32,
    size: s32,
    start: s32,
    end: s32,
    log_e: *Celt_Glog,
    prev1log_e: *Celt_Glog,
    prev2log_e: *Celt_Glog,
    pulses: *s32,
    seed: Uint32,
    encode: s32,
    arch: s32
) {
    j: s32 = ---;
    k: s32 = ---;
    i := start;
    while i < end {
        n0 := (cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i];

        (pulses[i] >= 0);
        depth :=
            cast,no_check(s32) (celt_udiv_in_bands(
                cast,no_check(Uint32) (1 + pulses[i]),
                cast,no_check(Uint32) ((cast(s32) m.e_bands[i + 1]) - cast(s32) m.e_bands[i])
            ) >> ((lm) & 31));

        thresh :=
            0.5 * cast,no_check(float32) c_transpiler_math_exp(
                0.6931471805599453 * cast,no_check(float64) (-0.125 * cast,no_check(float32) depth)
            );
        sqrt_1 := 1.0 / cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (n0 << ((lm) & 31)));

        c: s32 = 0;
        while true {
            {
                renormalize: s32 = 0;
                prev1 := prev1log_e[c * m.nb_e_bands + i];
                prev2 := prev2log_e[c * m.nb_e_bands + i];
                if encode == 0 && c_value == 1 {
                    prev1 =
                        ifx c_transpiler_float_greater(prev1, prev1log_e[m.nb_e_bands + i]) then prev1 else prev1log_e[m.nb_e_bands +
                            i];
                    prev2 =
                        ifx c_transpiler_float_greater(prev2, prev2log_e[m.nb_e_bands + i]) then prev2 else prev2log_e[m.nb_e_bands +
                            i];
                }
                ediff :=
                    log_e[c * m.nb_e_bands + i] -
                        (ifx c_transpiler_float_less(prev1, prev2) then prev1 else prev2);
                ediff = ifx c_transpiler_float_greater(0.0, ediff) then 0.0 else ediff;

                r :=
                    2.0 *
                        cast,no_check(float32) c_transpiler_math_exp(0.6931471805599453 * cast,no_check(float64) (-ediff));
                if lm == 3 {
                    r *= cast(float32) 1.4142135381698609;
                }
                r = ifx c_transpiler_float_less(thresh, r) then thresh else r;
                r = r * sqrt_1;

                x_value := x + c * size + (cast(s32) m.e_bands[i]) << ((lm) & 31);
                k = 0;
                while k < (cast(s32) 1) << ((lm) & 31) {
                    if (cast(s32) collapse_masks[i * c_value + c]) & ((cast(s32) 1) << ((k) & 31)) == 0 {
                        j = 0;
                        while j < n0 {
                            seed = celt_lcg_rand(seed);
                            x_value[j << ((lm) & 31) + k] = ifx seed & 0x8000 != 0 then r else -r;
                            j += 1;
                        }
                        renormalize = 1;
                    }
                    k += 1;
                }

                if renormalize != 0 {
                    renormalise_vector(x_value, n0 << ((lm) & 31), 1.0, arch);
                }
            }
            if !(c_transpiler_pre_increment(*(c)) < c_value) break;
        }
        i += 1;
    }
}

hysteresis_decision :: (val: Val16, thresholds: *Val16, hysteresis: *Val16, n: s32, prev: s32) -> s32 {
    i: s32 = 0;
    while i < n {
        if c_transpiler_float_less(val, thresholds[i]) {
            break;
        }
        i += 1;
    }
    if i > prev && c_transpiler_float_less(val, (thresholds[prev] + hysteresis[prev])) {
        i = prev;
    }
    if i < prev && c_transpiler_float_greater(val, (thresholds[prev - 1] - hysteresis[prev - 1])) {
        i = prev;
    }
    return i;
}

alloc__in_bands :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_bands :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_bands :: (size: u64) -> *void {
    return alloc__in_bands(size);
}

free__in_bands :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16 :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm(y / x);
    } else {
        return 1.0 - celt_atan_norm(x / y);
    }
}

celt_cos_norm2 :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

xcorr_kernel_c_in_bands :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c_in_bands :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

globals_initialization_state_for_bands: u32;
initialize_globals_for_bands :: () {
    {
        state := atomic_load(*globals_initialization_state_for_bands);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_bands, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_bands) != 2 {}
            return;
        }
    }
    TRIM_ICDF_storage =
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
    SPREAD_ICDF_storage = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_storage = u8.[ 2, 1, 0 ];
    ORDERY_TABLE =
        s32.[
            1,
            0,
            3,
            0,
            2,
            1,
            7,
            0,
            4,
            3,
            6,
            1,
            5,
            2,
            15,
            0,
            8,
            7,
            12,
            3,
            11,
            4,
            14,
            1,
            9,
            6,
            13,
            2,
            10,
            5
        ];
    EXP2_TABLE8 =
        Int16.[
            16384,
            17866,
            19483,
            21247,
            23170,
            25267,
            27554,
            30048
        ];
    BIT_INTERLEAVE_TABLE =
        u8.[
            0,
            1,
            1,
            1,
            2,
            3,
            3,
            3,
            2,
            3,
            3,
            3,
            2,
            3,
            3,
            3
        ];
    BIT_DEINTERLEAVE_TABLE =
        u8.[
            0,
            0x3,
            0xc,
            0xf,
            0x30,
            0x33,
            0x3c,
            0x3f,
            0xc0,
            0xc3,
            0xcc,
            0xcf,
            0xf0,
            0xf3,
            0xfc,
            0xff
        ];
    atomic_store(*globals_initialization_state_for_bands, 2);
}

System_Library_Compiler :: #import "Compiler";
#run System_Library_Compiler.compiler_add_library_search_directory("/usr/lib");
System_Library_libm_so_6 :: #library,system "libm.so.6";
floor :: (x: float64) -> float64 #foreign System_Library_libm_so_6;

Celt_Ener :: float32;

Celt_Sig :: float32;

Celt_Norm :: float32;

Celt_Glog :: float32;

Custom_Mode :: struct {
    fs: Int32;
    overlap: s32;
    nb_e_bands: s32;
    eff_e_bands: s32;
    preemph: [4] Val16;
    e_bands: *Int16;
    max_lm: s32;
    nb_short_mdcts: s32;
    short_mdct_size: s32;
    nb_alloc_vectors: s32;
    alloc_vectors: *u8;
    log_n: *Int16;
    window: *Celt_Coef;
    mdct: Mdct_Lookup;
    cache: Pulse_Cache;
}

Celt_Coef :: float32;

Mdct_Lookup :: struct {
    n: s32;
    maxshift: s32;
    kfft: [4] *Kiss_Fft_State;
    trig: *float32;
}

Pulse_Cache :: struct {
    size: s32;
    index: *Int16;
    bits: *u8;
    caps: *u8;
}

Kiss_Fft_State :: struct {
    nfft: s32;
    scale: Celt_Coef;
    shift: s32;
    factors: [16] Int16;
    bitrev: *Int16;
    twiddles: *Kiss_Twiddle_Cpx;
    arch_fft: *Arch_Fft_State;
}

Kiss_Twiddle_Cpx :: struct {
    r: float32;
    i: float32;
}

Arch_Fft_State :: struct {
    is_supported: s32;
    priv: *void;
}

