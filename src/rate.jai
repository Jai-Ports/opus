TRIM_ICDF_in_rate: [11] u8;

SPREAD_ICDF_in_rate: [4] u8;

TAPSET_ICDF_in_rate: [3] u8;

LOG2_FRAC_TABLE: [24] u8;

ec_range_bytes_in_rate :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_rate :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_rate :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_rate :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_rate :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_rate :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_rate :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_rate :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_rate :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

false__in_rate :: () -> s32 {
    return 0;
}

alloc__in_rate :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_rate :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_rate :: (size: u64) -> *void {
    return alloc__in_rate(size);
}

free__in_rate :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

get_pulses_in_rate :: (i: s32) -> s32 {
    return ifx i < 8 then i else (8 + i & 7) << (((i >> 3 - 1)) & 31);
}

bits2pulses_in_rate :: (m: *Custom_Mode, band: s32, lm: s32, bits: s32) -> s32 {
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

pulses2bits_in_rate :: (m: *Custom_Mode, band: s32, lm: s32, pulses: s32) -> s32 {
    lm += 1;
    cache := m.cache.bits + cast,no_check(s32) m.cache.index[lm * m.nb_e_bands + band];
    return ifx pulses == 0 then 0 else (cast(s32) cache[pulses]) + 1;
}

clt_compute_allocation :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    offsets: *s32,
    cap: *s32,
    alloc_trim: s32,
    intensity: *s32,
    dual_stereo: *s32,
    total: Int32,
    balance: *Int32,
    pulses: *s32,
    ebits: *s32,
    fine_priority: *s32,
    c: s32,
    lm: s32,
    ec: *Ec_Ctx,
    encode: s32,
    prev: s32,
    signal_bandwidth: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    intensity_rsv: s32 = ---;
    dual_stereo_rsv: s32 = ---;

    total = ifx total > 0 then total else 0;
    len := m.nb_e_bands;
    skip_start := start;

    skip_rsv: s32 = (ifx total >= (cast(s32) 1) << 3 then (cast(s32) 1) << 3 else 0);
    total = cast,no_check(Int32) (total - skip_rsv);

    dual_stereo_rsv = 0;
    intensity_rsv = dual_stereo_rsv;
    if c == 2 {
        intensity_rsv = cast,no_check(s32) LOG2_FRAC_TABLE[end - start];
        if intensity_rsv > total {
            intensity_rsv = 0;
        } else {
            total = cast,no_check(Int32) (total - intensity_rsv);
            dual_stereo_rsv = ifx total >= (cast(s32) 1) << 3 then (cast(s32) 1) << 3 else 0;
            total = cast,no_check(Int32) (total - dual_stereo_rsv);
        }
    }
    bits1 := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));
    bits2 := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));
    thresh := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));
    trim_offset := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) len)));

    j := start;
    while j < end {
        thresh[j] =
            ifx c << 3 > (((3 * ((cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j])) << ((lm) & 31)) << 3) >> 4 then c << 3 else (((3 *
                ((cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j])) << ((lm) & 31)) << 3) >> 4;

        trim_offset[j] =
            ((((c * ((cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j])) * (alloc_trim - 5 - lm)) * (end - j - 1)) *
                (cast(s32) 1) << (((lm + 3)) & 31)) >> 6;

        if (((cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j]) << ((lm) & 31)) == 1 {
            trim_offset[j] -= c << 3;
        }
        j += 1;
    }
    lo: s32 = 1;
    hi := m.nb_alloc_vectors - 1;
    while true {
        {
            done: s32 = 0;
            psum: s32 = 0;
            mid := (lo + hi) >> 1;
            j = end;
            while c_transpiler_post_decrement(*(j)) > start {
                n := (cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j];
                bitsj := ((c * n * cast(s32) m.alloc_vectors[mid * len + j]) << ((lm) & 31)) >> 2;
                if bitsj > 0 {
                    bitsj = ifx 0 > bitsj + trim_offset[j] then 0 else bitsj + trim_offset[j];
                }
                bitsj += offsets[j];
                if bitsj >= thresh[j] || done != 0 {
                    done = 1;

                    psum += (ifx bitsj < cap[j] then bitsj else cap[j]);
                } else if bitsj >= c << 3 {
                    psum += c << 3;
                }
            }
            if psum > total {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
        if !(lo <= hi) break;
    }
    hi = c_transpiler_post_decrement(*(lo));

    j = start;
    while j < end {
        n := (cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j];
        bits1j := ((c * n * cast(s32) m.alloc_vectors[lo * len + j]) << ((lm) & 31)) >> 2;
        bits2j :=
            (ifx hi >= m.nb_alloc_vectors then cap[j] else ((c * n *
                cast(s32) m.alloc_vectors[hi * len + j]) << ((lm) & 31)) >> 2);
        if bits1j > 0 {
            bits1j = ifx 0 > bits1j + trim_offset[j] then 0 else bits1j + trim_offset[j];
        }
        if bits2j > 0 {
            bits2j = ifx 0 > bits2j + trim_offset[j] then 0 else bits2j + trim_offset[j];
        }
        if lo > 0 {
            bits1j += offsets[j];
        }
        bits2j += offsets[j];
        if offsets[j] > 0 {
            skip_start = j;
        }
        bits2j = ifx 0 > bits2j - bits1j then 0 else bits2j - bits1j;
        bits1[j] = bits1j;
        bits2[j] = bits2j;
        j += 1;
    }
    coded_bands :=
        interp_bits2pulses(
            m,
            start,
            end,
            skip_start,
            bits1,
            bits2,
            thresh,
            cap,
            total,
            balance,
            skip_rsv,
            intensity,
            intensity_rsv,
            dual_stereo,
            dual_stereo_rsv,
            pulses,
            ebits,
            fine_priority,
            c,
            lm,
            ec,
            encode,
            prev,
            signal_bandwidth
        );

    return coded_bands;
}

interp_bits2pulses :: (
    m: *Custom_Mode,
    start: s32,
    end: s32,
    skip_start: s32,
    bits1: *s32,
    bits2: *s32,
    thresh: *s32,
    cap: *s32,
    total: Int32,
    balance_value: *Int32,
    skip_rsv: s32,
    intensity: *s32,
    intensity_rsv: s32,
    dual_stereo: *s32,
    dual_stereo_rsv: s32,
    bits: *s32,
    ebits: *s32,
    fine_priority: *s32,
    c: s32,
    lm: s32,
    ec: *Ec_Ctx,
    encode: s32,
    prev: s32,
    signal_bandwidth: s32
) -> s32 {
    psum: Int32 = ---;
    j: s32 = ---;

    coded_bands: s32 = -1;

    left, percoeff: Int32 = ---;
    done: s32 = ---;

    alloc_floor := c << 3;
    stereo := cast(s32) (c > 1);

    log_m := lm << 3;
    lo: s32 = 0;
    hi: s32 = (cast(s32) 1) << 6;
    for i: 0..cast(s32) 6 - 1 {
        mid := (lo + hi) >> 1;
        psum = 0;
        done = 0;
        j = end;
        while c_transpiler_post_decrement(*(j)) > start {
            tmp: s32 = bits1[j] + (mid * bits2[j]) >> 6;
            if tmp >= thresh[j] || done != 0 {
                done = 1;

                c_transpiler_compound_add(*(psum), ((ifx tmp < cap[j] then tmp else cap[j])), s32, s32);
            } else if tmp >= alloc_floor {
                psum = cast,no_check(Int32) (psum + alloc_floor);
            }
        }
        if psum > total {
            hi = mid;
        } else {
            lo = mid;
        }
    }
    psum = 0;

    done = 0;
    j = end;
    while c_transpiler_post_decrement(*(j)) > start {
        tmp: s32 = bits1[j] + (lo * bits2[j]) >> 6;
        if tmp < thresh[j] && done == 0 {
            if tmp >= alloc_floor {
                tmp = alloc_floor;
            } else {
                tmp = 0;
            }
        } else {
            done = 1;
        }

        tmp = ifx tmp < cap[j] then tmp else cap[j];
        bits[j] = tmp;
        psum = cast,no_check(Int32) (psum + tmp);
    }

    coded_bands = end;
    while true {
        j = coded_bands - 1;

        if j <= skip_start {
            total = cast,no_check(Int32) (total + skip_rsv);
            break;
        }

        left = total - psum;
        percoeff =
            cast,no_check(Int32) celt_udiv_in_rate(
                cast,no_check(Uint32) left,
                cast,no_check(Uint32) ((cast(s32) m.e_bands[coded_bands]) - cast(s32) m.e_bands[start])
            );
        left = cast,no_check(Int32) (left - (((cast(s32) m.e_bands[coded_bands]) - cast(s32) m.e_bands[start]) * percoeff));
        rem :=
            (ifx (left - ((cast(s32) m.e_bands[j]) - cast(s32) m.e_bands[start])) > 0 then left -
                ((cast(s32) m.e_bands[j]) - cast(s32) m.e_bands[start]) else 0);
        band_width := (cast(s32) m.e_bands[coded_bands]) - cast(s32) m.e_bands[j];
        band_bits := bits[j] + percoeff * band_width + rem;

        if band_bits >= (ifx thresh[j] > alloc_floor + (cast(s32) 1) << 3 then thresh[j] else alloc_floor + (cast(s32) 1) << 3) {
            if encode != 0 {
                depth_threshold: s32 = ifx coded_bands > 17
                    then (ifx j < prev then cast(s32) 7 else 9)
                    else 0;

                if coded_bands <= start + 2 || band_bits > (depth_threshold * band_width) << ((lm) & 31) << 3 >> 4 && j <= signal_bandwidth {
                    ec_enc_bit_logp(ec, 1, 1);
                    break;
                }
                ec_enc_bit_logp(ec, 0, 1);
            } else if ec_dec_bit_logp(ec, 1) != 0 {
                break;
            }

            psum = cast,no_check(Int32) (psum + ((cast(s32) 1) << 3));
            band_bits -= (cast(s32) 1) << 3;
        }

        psum = cast,no_check(Int32) (psum - (bits[j] + intensity_rsv));
        if intensity_rsv > 0 {
            intensity_rsv = cast,no_check(s32) LOG2_FRAC_TABLE[j - start];
        }
        psum = cast,no_check(Int32) (psum + intensity_rsv);
        if band_bits >= alloc_floor {
            psum = cast,no_check(Int32) (psum + alloc_floor);
            bits[j] = alloc_floor;
        } else {
            bits[j] = 0;
        }
        coded_bands -= 1;
    }

    if intensity_rsv > 0 {
        if encode != 0 {
            intensity.* = min(intensity.*, coded_bands);
            ec_enc_uint(
                ec,
                cast,no_check(Uint32) (intensity.* - start),
                cast,no_check(Uint32) (coded_bands + 1 - start)
            );
        } else {
            intensity.* =
                cast,no_check(s32) ((cast,no_check(Uint32) start) +
                    ec_dec_uint(ec, cast,no_check(Uint32) (coded_bands + 1 - start)));
        }
    } else {
        intensity.* = 0;
    }
    if intensity.* <= start {
        total = cast,no_check(Int32) (total + dual_stereo_rsv);
        dual_stereo_rsv = 0;
    }
    if dual_stereo_rsv > 0 {
        if encode != 0 {
            ec_enc_bit_logp(ec, dual_stereo.*, 1);
        } else {
            dual_stereo.* = ec_dec_bit_logp(ec, 1);
        }
    } else {
        dual_stereo.* = 0;
    }

    left = total - psum;
    percoeff =
        cast,no_check(Int32) celt_udiv_in_rate(
            cast,no_check(Uint32) left,
            cast,no_check(Uint32) ((cast(s32) m.e_bands[coded_bands]) - cast(s32) m.e_bands[start])
        );
    left = cast,no_check(Int32) (left - (((cast(s32) m.e_bands[coded_bands]) - cast(s32) m.e_bands[start]) * percoeff));
    j = start;
    while j < coded_bands {
        bits[j] += percoeff * ((cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j]);
        j += 1;
    }
    j = start;
    while j < coded_bands {
        tmp :=
            (ifx left < (cast(s32) m.e_bands[j + 1]) -
                cast(s32) m.e_bands[j] then left else (cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j]);
        bits[j] += tmp;
        left = cast,no_check(Int32) (left - tmp);
        j += 1;
    }

    balance: Int32 = 0;
    j = start;
    while j < coded_bands {
        den: s32 = ---;
        offset: s32 = ---;
        n_clog_n: s32 = ---;
        excess: Int32 = ---;

        (bits[j] >= 0);
        n0 := (cast(s32) m.e_bands[j + 1]) - cast(s32) m.e_bands[j];
        n := n0 << ((lm) & 31);
        bit := bits[j] + balance;

        if n > 1 {
            excess = ifx bit - cap[j] > 0 then bit - cap[j] else 0;
            bits[j] = bit - excess;

            den = c * n + cast(s32) (c == 2 && n > 2 && dual_stereo.* == 0 && j < intensity.*);

            n_clog_n = den * ((cast(s32) m.log_n[j]) + log_m);

            offset = n_clog_n >> 1 - den * 21;

            if n == 2 {
                offset += den << 3 >> 2;
            }

            if bits[j] + offset < (den * 2) << 3 {
                offset += n_clog_n >> 2;
            } else if bits[j] + offset < (den * 3) << 3 {
                offset += n_clog_n >> 3;
            }

            ebits[j] =
                ifx 0 > bits[j] + offset + den << (((3 - 1)) & 31) then 0 else bits[j] +
                    offset + den << (((3 - 1)) & 31);
            ebits[j] =
                cast,no_check(s32) (celt_udiv_in_rate(
                    cast,no_check(Uint32) ebits[j],
                    cast,no_check(Uint32) den
                ) >> 3);

            if c * ebits[j] > bits[j] >> 3 {
                ebits[j] = bits[j] >> ((stereo) & 31) >> 3;
            }

            ebits[j] = ifx ebits[j] < 8 then ebits[j] else 8;

            fine_priority[j] = cast(s32) (ebits[j] * den << 3 >= bits[j] + offset);

            bits[j] -= (c * ebits[j]) << 3;
        } else {
            excess = ifx 0 > bit - c << 3 then 0 else bit - c << 3;
            bits[j] = bit - excess;
            ebits[j] = 0;
            fine_priority[j] = 1;
        }

        if excess > 0 {
            extra_fine :=
                (ifx excess >> (((stereo + 3)) & 31) < 8 -
                    ebits[j] then excess >> (((stereo + 3)) & 31) else 8 - ebits[j]);
            ebits[j] += extra_fine;
            extra_bits := (extra_fine * c) << 3;
            fine_priority[j] = cast(s32) (extra_bits >= excess - balance);
            excess = cast,no_check(Int32) (excess - extra_bits);
        }
        balance = excess;

        (bits[j] >= 0);
        (ebits[j] >= 0);
        j += 1;
    }

    balance_value.* = balance;

    while j < end {
        ebits[j] = bits[j] >> ((stereo) & 31) >> 3;
        ((c * ebits[j]) << 3 == bits[j]);
        bits[j] = 0;
        fine_priority[j] = cast(s32) (ebits[j] < 1);
        j += 1;
    }

    return coded_bands;
}

fast_atan2f_in_rate :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_rate :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_rate :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_rate :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_rate(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_rate(x / y);
    }
}

celt_cos_norm2_in_rate :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

globals_initialization_state_for_rate: u32;
initialize_globals_for_rate :: () {
    {
        state := atomic_load(*globals_initialization_state_for_rate);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_rate, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_rate) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_rate =
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
    SPREAD_ICDF_in_rate = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_rate = u8.[ 2, 1, 0 ];
    LOG2_FRAC_TABLE =
        u8.[
            0,
            8,
            13,
            16,
            19,
            21,
            23,
            24,
            26,
            27,
            28,
            29,
            30,
            31,
            32,
            32,
            33,
            34,
            34,
            35,
            36,
            36,
            37,
            37
        ];
    atomic_store(*globals_initialization_state_for_rate, 2);
}

