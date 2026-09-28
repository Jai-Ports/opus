// Generated directly from C by cpp_transpiler.
TRIM_ICDF: [11] u8;

SPREAD_ICDF: [4] u8;

TAPSET_ICDF: [3] u8;

silk_clz16_in_pitch_analysis_core_flp :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_pitch_analysis_core_flp :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_pitch_analysis_core_flp :: () -> s32 {
    return 0;
}

silk_ror32_in_pitch_analysis_core_flp :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_pitch_analysis_core_flp :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_pitch_analysis_core_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_pitch_analysis_core_flp :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_pitch_analysis_core_flp :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_pitch_analysis_core_flp :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_pitch_analysis_core_flp :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_pitch_analysis_core_flp :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_pitch_analysis_core_flp :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_pitch_analysis_core_flp :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_pitch_analysis_core_flp(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_pitch_analysis_core_flp(in_upper);
    }
}

silk_clz_frac_in_pitch_analysis_core_flp :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_pitch_analysis_core_flp(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_pitch_analysis_core_flp(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_pitch_analysis_core_flp :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_pitch_analysis_core_flp(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_pitch_analysis_core_flp :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_pitch_analysis_core_flp((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_pitch_analysis_core_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_pitch_analysis_core_flp :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_pitch_analysis_core_flp((ifx B32 > 0 then B32 else -B32)) - 1;
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

mm_cvtss_si32_in_pitch_analysis_core_flp :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

mm_cvt_ss2si_in_pitch_analysis_core_flp :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_pitch_analysis_core_flp(a);
}

mm_set_ss_in_pitch_analysis_core_flp :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

float2int_in_pitch_analysis_core_flp :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_pitch_analysis_core_flp(mm_set_ss_in_pitch_analysis_core_flp(x));
}

float2_int16_in_pitch_analysis_core_flp :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_pitch_analysis_core_flp(x);
}

float2_int24_in_pitch_analysis_core_flp :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_pitch_analysis_core_flp(x);
}

ec_range_bytes_in_pitch_analysis_core_flp :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_pitch_analysis_core_flp :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_pitch_analysis_core_flp :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_pitch_analysis_core_flp :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_pitch_analysis_core_flp :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_pitch_analysis_core_flp :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_pitch_analysis_core_flp :: (
    frame: *float32,
    pitch_out: *s32,
    lag_index: *Int16,
    contour_index: *Int8,
    ltp_corr: *float32,
    prev_lag: s32,
    SEARCH_THRES1: float32,
    SEARCH_THRES2: float32,
    FS_K_HZ: s32,
    COMPLEXITY: s32,
    NB_SUBFR: s32,
    arch: s32
) -> s32 {
    d: s32 = ---;
    j: s32 = ---;
    frame_8k_hz: [320] float32 = ---;
    frame_4k_hz: [160] float32 = ---;
    frame_8_fix: [320] Int16 = ---;
    frame_4_fix: [160] Int16 = ---;
    filt_state: [6] Int32 = ---;
    contour_bias: float32 = ---;
    c: [4] [149] float32 = ---;
    xcorr: [65] Val32 = ---;
    cc: [11] float32 = ---;
    basis_ptr: *float32 = ---;
    cross_corr: float64 = ---;
    energy: float64 = ---;
    energy_tmp: float64 = ---;
    d_srch: [24] s32 = ---;
    d_comp: [149] Int16 = ---;
    c_cmax_new: float32 = ---;
    start_lag: s32 = ---;
    end_lag: s32 = ---;
    lag_new: s32 = ---;
    cbk_size: s32 = ---;
    prev_lag_log2: float32 = ---;
    delta_lag_log2_sqr: float32 = ---;
    energies_st3: [4] [34] [5] float32 = ---;
    cross_corr_st3: [4] [34] [5] float32 = ---;
    lag_counter: s32 = ---;

    nb_cbk_search: s32 = ---;
    lag_cb_ptr: *Int8 = ---;

    (FS_K_HZ == 8 || FS_K_HZ == 12 || FS_K_HZ == 16);

    (c_transpiler_float_greater_equal(SEARCH_THRES1, 0.0) && c_transpiler_float_less_equal(SEARCH_THRES1, 1.0));
    (c_transpiler_float_greater_equal(SEARCH_THRES2, 0.0) && c_transpiler_float_less_equal(SEARCH_THRES2, 1.0));

    frame_length := ((cast,no_check(s32) ((4 * 5))) + NB_SUBFR * 5) * FS_K_HZ;
    frame_length_4k_hz := ((cast,no_check(s32) ((4 * 5))) + NB_SUBFR * 5) * 4;
    frame_length_8k_hz := ((cast,no_check(s32) ((4 * 5))) + NB_SUBFR * 5) * 8;
    sf_length := 5 * FS_K_HZ;
    sf_length_4k_hz: s32 = cast,no_check(s32) ((5 * 4));
    sf_length_8k_hz: s32 = cast,no_check(s32) ((5 * 8));
    min_lag := 2 * FS_K_HZ;
    min_lag_4k_hz: s32 = cast,no_check(s32) ((2 * 4));
    min_lag_8k_hz: s32 = cast,no_check(s32) ((2 * 8));
    max_lag := 18 * FS_K_HZ - 1;
    max_lag_4k_hz: s32 = cast,no_check(s32) ((18 * 4));
    max_lag_8k_hz: s32 = (cast,no_check(s32) ((18 * 8))) - 1;

    if FS_K_HZ == 16 {
        frame_16_fix: [640] Int16 = ---;
        silk_float2short_array_in_pitch_analysis_core_flp(frame_16_fix.data, frame, frame_length);
        fill_memory(filt_state.data, 0, cast(u64) 2 * size_of(Int32));
        silk_resampler_down2(filt_state.data, frame_8_fix.data, frame_16_fix.data, frame_length);
        silk_short2float_array_in_pitch_analysis_core_flp(frame_8k_hz.data, frame_8_fix.data, frame_length_8k_hz);
    } else if FS_K_HZ == 12 {
        frame_12_fix: [480] Int16 = ---;
        silk_float2short_array_in_pitch_analysis_core_flp(frame_12_fix.data, frame, frame_length);
        fill_memory(filt_state.data, 0, cast(u64) 6 * size_of(Int32));
        silk_resampler_down2_3(filt_state.data, frame_8_fix.data, frame_12_fix.data, frame_length);
        silk_short2float_array_in_pitch_analysis_core_flp(frame_8k_hz.data, frame_8_fix.data, frame_length_8k_hz);
    } else {
        silk_float2short_array_in_pitch_analysis_core_flp(frame_8_fix.data, frame, frame_length_8k_hz);
    }

    fill_memory(filt_state.data, 0, cast(u64) 2 * size_of(Int32));
    silk_resampler_down2(filt_state.data, frame_4_fix.data, frame_8_fix.data, frame_length_8k_hz);
    silk_short2float_array_in_pitch_analysis_core_flp(frame_4k_hz.data, frame_4_fix.data, frame_length_4k_hz);

    i := frame_length_4k_hz - 1;
    while i > 0 {
        frame_4k_hz[i] =
            cast,no_check(float32) (cast,no_check(Int16) ((ifx c_transpiler_float_greater(((cast,no_check(Int32) frame_4k_hz[i]) + frame_4k_hz[i - 1]), 32767.0) then 32767.0 else (ifx c_transpiler_float_less(((cast,no_check(Int32) frame_4k_hz[i]) + frame_4k_hz[i - 1]), -32768.0) then -32768.0 else (cast,no_check(Int32) frame_4k_hz[i]) +
                frame_4k_hz[i - 1]))));
        i -= 1;
    }

    fill_memory(
        c.data,
        0,
        (size_of(float32) * cast,no_check(u64) NB_SUBFR) *
        cast,no_check(u64) ((cast,no_check(s32) ((18 * 16))) >> 1 + 5)
    );
    target_ptr := frame_4k_hz.data + cast,no_check(Int32) ((cast,no_check(Uint32) sf_length_4k_hz) << 2);
    k: s32 = 0;
    while k < NB_SUBFR >> 1 {
        (target_ptr + sf_length_8k_hz <= (frame_4k_hz.data + frame_length_4k_hz));

        basis_ptr = target_ptr - min_lag_4k_hz;

        (basis_ptr + sf_length_8k_hz <= (frame_4k_hz.data + frame_length_4k_hz));

        celt_pitch_xcorr_c(
            target_ptr,
            target_ptr - max_lag_4k_hz,
            xcorr.data,
            sf_length_8k_hz,
            max_lag_4k_hz - min_lag_4k_hz + 1,
            arch
        );

        cross_corr = cast,no_check(float64) xcorr[max_lag_4k_hz - min_lag_4k_hz];
        normalizer :=
            silk_energy_flp(target_ptr, sf_length_8k_hz) + silk_energy_flp(basis_ptr, sf_length_8k_hz) +
                cast,no_check(float64) ((cast,no_check(float32) sf_length_8k_hz) * 4000.0);

        c[0][min_lag_4k_hz] += cast,no_check(float32) (2.0 * cross_corr / normalizer);

        d = min_lag_4k_hz + 1;
        while d <= max_lag_4k_hz {
            basis_ptr -= 1;

            (basis_ptr + sf_length_8k_hz <= (frame_4k_hz.data + frame_length_4k_hz));

            cross_corr = cast,no_check(float64) xcorr[max_lag_4k_hz - d];

            normalizer +=
                ((cast,no_check(float64) basis_ptr[0]) * cast,no_check(float64) basis_ptr[0]) -
                    (cast,no_check(float64) basis_ptr[sf_length_8k_hz]) * cast,no_check(float64) basis_ptr[sf_length_8k_hz];
            c[0][d] += cast,no_check(float32) (2.0 * cross_corr / normalizer);
            d += 1;
        }

        target_ptr += sf_length_8k_hz;
        k += 1;
    }

    i = max_lag_4k_hz;
    while i >= min_lag_4k_hz {
        c[0][i] -= c[0][i] * i / 4096.0;
        i -= 1;
    }

    length_d_srch := 4 + 2 * COMPLEXITY;
    (3 * length_d_srch <= 24);
    silk_insertion_sort_decreasing_flp(
        c[0].data + min_lag_4k_hz,
        d_srch.data,
        max_lag_4k_hz - min_lag_4k_hz + 1,
        length_d_srch
    );

    cmax := c[0][min_lag_4k_hz];
    if c_transpiler_float_less(cmax, 0.2) {
        fill_memory(pitch_out, 0, cast,no_check(u64) NB_SUBFR * size_of(s32));
        ltp_corr.* = 0.0;
        lag_index.* = 0;
        contour_index.* = 0;
        return 1;
    }

    threshold := SEARCH_THRES1 * cmax;
    i = 0;
    while i < length_d_srch {
        if c_transpiler_float_greater(c[0][min_lag_4k_hz + i], threshold) {
            d_srch[i] = cast,no_check(Int32) ((cast,no_check(Uint32) (d_srch[i] + min_lag_4k_hz)) << 1);
        } else {
            length_d_srch = i;
            break;
        }
        i += 1;
    }

    i = min_lag_8k_hz - 5;
    while i < max_lag_8k_hz + 5 {
        d_comp[i] = 0;
        i += 1;
    }
    i = 0;
    while i < length_d_srch {
        d_comp[d_srch[i]] = 1;
        i += 1;
    }

    i = max_lag_8k_hz + 3;
    while i >= min_lag_8k_hz {
        d_comp[i] = cast,no_check(Int16) ((cast,no_check(s32) d_comp[i]) + ((cast(s32) d_comp[i - 1]) + cast(s32) d_comp[i - 2]));
        i -= 1;
    }

    length_d_srch = 0;
    i = min_lag_8k_hz;
    while i < max_lag_8k_hz + 1 {
        if d_comp[i + 1] > 0 {
            d_srch[length_d_srch] = i;
            length_d_srch += 1;
        }
        i += 1;
    }

    i = max_lag_8k_hz + 3;
    while i >= min_lag_8k_hz {
        d_comp[i] = cast,no_check(Int16) ((cast,no_check(s32) d_comp[i]) + (((cast(s32) d_comp[i - 1]) + cast(s32) d_comp[i - 2]) + cast(s32) d_comp[i - 3]));
        i -= 1;
    }

    length_d_comp: s32 = 0;
    i = min_lag_8k_hz;
    while i < max_lag_8k_hz + 4 {
        if d_comp[i] > 0 {
            d_comp[length_d_comp] = cast,no_check(Int16) (i - 2);
            length_d_comp += 1;
        }
        i += 1;
    }

    fill_memory(c.data, 0, cast,no_check(u64) (4 * ((cast,no_check(s32) ((18 * 16))) >> 1 + 5)) * size_of(float32));

    if FS_K_HZ == 8 {
        target_ptr = *frame[(cast,no_check(s32) ((4 * 5))) * 8];
    } else {
        target_ptr = frame_8k_hz.data + (cast,no_check(s32) ((4 * 5))) * 8;
    }
    k = 0;
    while k < NB_SUBFR {
        energy_tmp = silk_energy_flp(target_ptr, sf_length_8k_hz) + 1.0;
        j = 0;
        while j < length_d_comp {
            d = cast,no_check(s32) d_comp[j];
            basis_ptr = target_ptr - d;
            cross_corr = silk_inner_product_flp_c(basis_ptr, target_ptr, sf_length_8k_hz);
            if c_transpiler_float_greater(cross_corr, 0.0) {
                energy = silk_energy_flp(basis_ptr, sf_length_8k_hz);
                c[k][d] = cast,no_check(float32) (2.0 * cross_corr / (energy + energy_tmp));
            } else {
                c[k][d] = 0.0;
            }
            j += 1;
        }
        target_ptr += sf_length_8k_hz;
        k += 1;
    }

    c_cmax: float32 = 0.0;
    c_cmax_b: float32 = -1000.0;

    c_bimax: s32 = 0;
    lag: s32 = -1;

    if prev_lag > 0 {
        if FS_K_HZ == 12 {
            prev_lag = (cast,no_check(Int32) ((cast,no_check(Uint32) prev_lag) << 1)) / 3;
        } else if FS_K_HZ == 16 {
            prev_lag = prev_lag >> 1;
        }
        prev_lag_log2 = silk_log2_in_pitch_analysis_core_flp(cast,no_check(float64) (cast,no_check(float32) prev_lag));
    } else {
        prev_lag_log2 = 0.0;
    }

    if NB_SUBFR == 4 {
        cbk_size = 11;
        lag_cb_ptr = SILK_CB_LAGS_STAGE2[0].data + 0;
        if FS_K_HZ == 8 && COMPLEXITY > 0 {
            nb_cbk_search = 11;
        } else {
            nb_cbk_search = 3;
        }
    } else {
        cbk_size = 3;
        lag_cb_ptr = SILK_CB_LAGS_STAGE2_10_MS[0].data + 0;
        nb_cbk_search = 3;
    }

    k = 0;
    while k < length_d_srch {
        d = d_srch[k];
        j = 0;
        while j < nb_cbk_search {
            cc[j] = 0.0;
            i = 0;
            while i < NB_SUBFR {
                cc[j] += c[i][d + cast(s32) ((lag_cb_ptr + (i * cbk_size + j)).*)];
                i += 1;
            }
            j += 1;
        }

        c_cmax_new = -1000.0;
        c_bimax_new: s32 = 0;
        i = 0;
        while i < nb_cbk_search {
            if c_transpiler_float_greater(cc[i], c_cmax_new) {
                c_cmax_new = cc[i];
                c_bimax_new = i;
            }
            i += 1;
        }

        lag_log2 := silk_log2_in_pitch_analysis_core_flp(cast,no_check(float64) (cast,no_check(float32) d));
        c_cmax_new_b := c_cmax_new - (0.2 * cast,no_check(float32) NB_SUBFR) * lag_log2;

        if prev_lag > 0 {
            delta_lag_log2_sqr = lag_log2 - prev_lag_log2;
            delta_lag_log2_sqr *= delta_lag_log2_sqr;
            c_cmax_new_b -=
                (((0.2 * cast,no_check(float32) NB_SUBFR) * ltp_corr.*) * delta_lag_log2_sqr) /
                    (delta_lag_log2_sqr + 0.5);
        }

        if c_transpiler_float_greater(c_cmax_new_b, c_cmax_b) && c_transpiler_float_greater(c_cmax_new, (NB_SUBFR * SEARCH_THRES2)) {
            c_cmax_b = c_cmax_new_b;
            c_cmax = c_cmax_new;
            lag = d;
            c_bimax = c_bimax_new;
        }
        k += 1;
    }

    if lag == -1 {
        fill_memory(pitch_out, 0, cast(u64) 4 * size_of(s32));
        ltp_corr.* = 0.0;
        lag_index.* = 0;
        contour_index.* = 0;
        return 1;
    }

    ltp_corr.* = c_cmax / NB_SUBFR;

    if FS_K_HZ > 8 {
        if FS_K_HZ == 12 {
            lag =
                ifx 1 == 1 then (((cast,no_check(Int32) (cast,no_check(Int16) lag)) * cast,no_check(Int32) (cast(Int16) 3)) >> 1) +
                    ((cast,no_check(Int32) (cast,no_check(Int16) lag)) * cast,no_check(Int32) (cast(Int16) 3)) & 1 else ((((cast,no_check(Int32) (cast,no_check(Int16) lag)) * cast,no_check(Int32) (cast(Int16) 3)) >> (((1 - 1)) & 31)) + 1) >> 1;
        } else {
            lag = cast,no_check(Int32) ((cast,no_check(Uint32) lag) << 1);
        }

        lag =
            ifx min_lag > max_lag then (ifx lag > min_lag then min_lag else (ifx lag < max_lag then max_lag else lag)) else (ifx lag > max_lag then max_lag else (ifx lag < min_lag then min_lag else lag));
        start_lag = silk_max_int_in_pitch_analysis_core_flp(lag - 2, min_lag);
        end_lag = silk_min_int_in_pitch_analysis_core_flp(lag + 2, max_lag);
        lag_new = lag;
        c_bimax = 0;

        c_cmax = -1000.0;

        silk_p_ana_calc_corr_st3(cross_corr_st3.data, frame, start_lag, sf_length, NB_SUBFR, COMPLEXITY, arch);
        silk_p_ana_calc_energy_st3(energies_st3.data, frame, start_lag, sf_length, NB_SUBFR, COMPLEXITY);

        lag_counter = 0;

        contour_bias = 0.05 / cast,no_check(float32) lag;

        if NB_SUBFR == 4 {
            nb_cbk_search = cast,no_check(s32) SILK_NB_CBK_SEARCHS_STAGE3[COMPLEXITY];
            cbk_size = 34;
            lag_cb_ptr = SILK_CB_LAGS_STAGE3[0].data + 0;
        } else {
            nb_cbk_search = 12;
            cbk_size = 12;
            lag_cb_ptr = SILK_CB_LAGS_STAGE3_10_MS[0].data + 0;
        }

        target_ptr = *frame[(cast,no_check(s32) ((4 * 5))) * FS_K_HZ];
        energy_tmp = silk_energy_flp(target_ptr, NB_SUBFR * sf_length) + 1.0;
        d = start_lag;
        while d <= end_lag {
            j = 0;
            while j < nb_cbk_search {
                cross_corr = 0.0;
                energy = energy_tmp;
                k = 0;
                while k < NB_SUBFR {
                    cross_corr += cast,no_check(float64) cross_corr_st3[k][j][lag_counter];
                    energy += cast,no_check(float64) energies_st3[k][j][lag_counter];
                    k += 1;
                }
                if c_transpiler_float_greater(cross_corr, 0.0) {
                    c_cmax_new = cast,no_check(float32) (2.0 * cross_corr / energy);

                    c_cmax_new *= 1.0 - contour_bias * j;
                } else {
                    c_cmax_new = 0.0;
                }

                if c_transpiler_float_greater(c_cmax_new, c_cmax) && (d + cast,no_check(s32) SILK_CB_LAGS_STAGE3[0][j]) <= max_lag {
                    c_cmax = c_cmax_new;
                    lag_new = d;
                    c_bimax = j;
                }
                j += 1;
            }
            lag_counter += 1;
            d += 1;
        }

        k = 0;
        while k < NB_SUBFR {
            pitch_out[k] = lag_new + cast(s32) ((lag_cb_ptr + (k * cbk_size + c_bimax)).*);
            pitch_out[k] =
                ifx min_lag > 18 *
                    FS_K_HZ then (ifx pitch_out[k] > min_lag then min_lag else (ifx pitch_out[k] < 18 * FS_K_HZ then 18 * FS_K_HZ else pitch_out[k])) else (ifx pitch_out[k] > 18 * FS_K_HZ then 18 * FS_K_HZ else (ifx pitch_out[k] < min_lag then min_lag else pitch_out[k]));
            k += 1;
        }
        lag_index.* = cast,no_check(Int16) (lag_new - min_lag);
        contour_index.* = cast,no_check(Int8) c_bimax;
    } else {
        k = 0;
        while k < NB_SUBFR {
            pitch_out[k] = lag + cast(s32) ((lag_cb_ptr + (k * cbk_size + c_bimax)).*);
            pitch_out[k] =
                ifx min_lag_8k_hz > 18 *
                    8 then (ifx pitch_out[k] > min_lag_8k_hz then min_lag_8k_hz else (ifx pitch_out[k] < 18 * 8 then cast,no_check(s32) ((18 * 8)) else pitch_out[k])) else (ifx pitch_out[k] > 18 * 8 then cast,no_check(s32) ((18 * 8)) else (ifx pitch_out[k] < min_lag_8k_hz then min_lag_8k_hz else pitch_out[k]));
            k += 1;
        }
        lag_index.* = cast,no_check(Int16) (lag - min_lag_8k_hz);
        contour_index.* = cast,no_check(Int8) c_bimax;
    }

    return 0;
}

silk_p_ana_calc_energy_st3 :: (
    energies_st3: *[34] [5] float32,
    frame: *float32,
    start_lag: s32,
    sf_length: s32,
    nb_subfr: s32,
    complexity: s32
) {
    i: s32 = ---;
    j: s32 = ---;
    nb_cbk_search: s32 = ---;
    idx: s32 = ---;
    cbk_size: s32 = ---;
    scratch_mem: [22] float32 = ---;
    lag_range_ptr, lag_cb_ptr: *Int8 = ---;

    if nb_subfr == 4 {
        lag_range_ptr = SILK_LAG_RANGE_STAGE3[complexity][0].data + 0;
        lag_cb_ptr = SILK_CB_LAGS_STAGE3[0].data + 0;
        nb_cbk_search = cast,no_check(s32) SILK_NB_CBK_SEARCHS_STAGE3[complexity];
        cbk_size = 34;
    } else {
        (nb_subfr == (cast(s32) 4) >> 1);
        lag_range_ptr = SILK_LAG_RANGE_STAGE3_10_MS[0].data + 0;
        lag_cb_ptr = SILK_CB_LAGS_STAGE3_10_MS[0].data + 0;
        nb_cbk_search = 12;
        cbk_size = 12;
    }

    target_ptr := *frame[cast,no_check(Int32) ((cast,no_check(Uint32) sf_length) << 2)];
    if 0 < nb_subfr {
        for k: 0..nb_subfr - 1 {
            lag_counter: s32 = 0;

            basis_ptr := target_ptr - (start_lag + cast(s32) ((lag_range_ptr + (k * 2 + 0)).*));
            energy := silk_energy_flp(basis_ptr, sf_length) + 0.001;

            scratch_mem[lag_counter] = cast,no_check(float32) energy;
            lag_counter += 1;

            lag_diff :=
                ((cast(s32) ((lag_range_ptr + (k * 2 + 1)).*)) - cast(s32) ((lag_range_ptr + (k * 2 + 0)).*)) +
                    1;
            i = 1;
            while i < lag_diff {
                energy -=
                    (cast,no_check(float64) basis_ptr[sf_length - i]) *
                        cast,no_check(float64) basis_ptr[sf_length - i];

                energy += (cast,no_check(float64) basis_ptr[-i]) * cast,no_check(float64) basis_ptr[-i];

                scratch_mem[lag_counter] = cast,no_check(float32) energy;
                lag_counter += 1;
                i += 1;
            }

            delta := cast,no_check(s32) ((lag_range_ptr + (k * 2 + 0)).*);
            i = 0;
            while i < nb_cbk_search {
                idx = (cast(s32) ((lag_cb_ptr + (k * cbk_size + i)).*)) - delta;
                j = 0;
                while j < 5 {
                    (idx + j < 22);
                    (idx + j < lag_counter);
                    energies_st3[k][i][j] = scratch_mem[idx + j];
                    c_transpiler_float_greater_equal(energies_st3[k][i][j], 0.0);
                    j += 1;
                }
                i += 1;
            }
            target_ptr += sf_length;
        }
    }
}

silk_p_ana_calc_corr_st3 :: (
    cross_corr_st3: *[34] [5] float32,
    frame: *float32,
    start_lag: s32,
    sf_length: s32,
    nb_subfr: s32,
    complexity: s32,
    arch: s32
) {
    i: s32 = ---;
    j: s32 = ---;
    nb_cbk_search: s32 = ---;
    idx: s32 = ---;
    cbk_size: s32 = ---;
    scratch_mem: [22] float32 = ---;
    xcorr: [22] Val32 = ---;
    lag_range_ptr, lag_cb_ptr: *Int8 = ---;

    if nb_subfr == 4 {
        lag_range_ptr = SILK_LAG_RANGE_STAGE3[complexity][0].data + 0;
        lag_cb_ptr = SILK_CB_LAGS_STAGE3[0].data + 0;
        nb_cbk_search = cast,no_check(s32) SILK_NB_CBK_SEARCHS_STAGE3[complexity];
        cbk_size = 34;
    } else {
        (nb_subfr == (cast(s32) 4) >> 1);
        lag_range_ptr = SILK_LAG_RANGE_STAGE3_10_MS[0].data + 0;
        lag_cb_ptr = SILK_CB_LAGS_STAGE3_10_MS[0].data + 0;
        nb_cbk_search = 12;
        cbk_size = 12;
    }

    target_ptr := *frame[cast,no_check(Int32) ((cast,no_check(Uint32) sf_length) << 2)];
    if 0 < nb_subfr {
        for k: 0..nb_subfr - 1 {
            lag_counter: s32 = 0;

            lag_low := cast,no_check(s32) ((lag_range_ptr + (k * 2 + 0)).*);
            lag_high := cast,no_check(s32) ((lag_range_ptr + (k * 2 + 1)).*);
            (lag_high - lag_low + 1 <= 22);
            celt_pitch_xcorr_c(
                target_ptr,
                target_ptr - start_lag - lag_high,
                xcorr.data,
                sf_length,
                lag_high - lag_low + 1,
                arch
            );
            j = lag_low;
            while j <= lag_high {
                scratch_mem[lag_counter] = xcorr[lag_high - j];
                lag_counter += 1;
                j += 1;
            }

            delta := cast,no_check(s32) ((lag_range_ptr + (k * 2 + 0)).*);
            i = 0;
            while i < nb_cbk_search {
                idx = (cast(s32) ((lag_cb_ptr + (k * cbk_size + i)).*)) - delta;
                j = 0;
                while j < 5 {
                    (idx + j < 22);
                    (idx + j < lag_counter);
                    cross_corr_st3[k][i][j] = scratch_mem[idx + j];
                    j += 1;
                }
                i += 1;
            }
            target_ptr += sf_length;
        }
    }
}

silk_log2_in_pitch_analysis_core_flp :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

silk_short2float_array_in_pitch_analysis_core_flp :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_float2short_array_in_pitch_analysis_core_flp :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int_in_pitch_analysis_core_flp(in[k]) > 0x7fff then 0x7fff else (ifx float2int_in_pitch_analysis_core_flp(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int_in_pitch_analysis_core_flp(in[k]))));
        k -= 1;
    }
}

silk_sigmoid_in_pitch_analysis_core_flp :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int_in_pitch_analysis_core_flp :: (x: float32) -> Int32 {
    return float2int_in_pitch_analysis_core_flp(x);
}

bits_to_bitrate :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

xcorr_kernel_c :: (x: *Val16, y: *Val16, sum: *Val32, len: s32) {
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

dual_inner_prod_c :: (x: *Val16, y01: *Val16, y02: *Val16, n: s32, xy1: *Val32, xy2: *Val32) {
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

celt_inner_prod_c :: (x: *Val16, y: *Val16, n: s32) -> Val32 {
    xy: Val32 = 0.0;
    if 0 < n {
        for i: 0..n - 1 {
            xy = xy + x[i] * y[i];
        }
    }
    return xy;
}

globals_initialization_state_for_pitch_analysis_core_flp: u32;
initialize_globals_for_pitch_analysis_core_flp :: () {
    {
        state := atomic_load(*globals_initialization_state_for_pitch_analysis_core_flp);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_pitch_analysis_core_flp, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_pitch_analysis_core_flp) != 2 {}
            return;
        }
    }
    TRIM_ICDF =
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
    SPREAD_ICDF = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_pitch_analysis_core_flp, 2);
}

Val32 :: float32;

Val16 :: float32;

