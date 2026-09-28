silk_clz16_in_decoder_set_fs :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decoder_set_fs :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decoder_set_fs :: () -> s32 {
    return 0;
}

silk_ror32_in_decoder_set_fs :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decoder_set_fs :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decoder_set_fs :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decoder_set_fs :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decoder_set_fs :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decoder_set_fs :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decoder_set_fs :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decoder_set_fs :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decoder_set_fs :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decoder_set_fs :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decoder_set_fs(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decoder_set_fs(in_upper);
    }
}

silk_clz_frac_in_decoder_set_fs :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decoder_set_fs(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decoder_set_fs(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decoder_set_fs :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decoder_set_fs(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decoder_set_fs :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decoder_set_fs((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decoder_set_fs((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decoder_set_fs :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decoder_set_fs((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_decoder_set_fs :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_decoder_set_fs :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_decoder_set_fs :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_decoder_set_fs :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_decoder_set_fs :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_decoder_set_fs :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_decoder_set_fs :: (ps_dec: *Silk_Decoder_State, fs_k_hz: s32, fs_api_hz: Int32) -> s32 {
    ret: s32 = 0;

    (fs_k_hz == 8 || fs_k_hz == 12 || fs_k_hz == 16);
    (ps_dec.nb_subfr == 4 || ps_dec.nb_subfr == 4 / 2);

    ps_dec.subfr_length = (cast,no_check(Int32) (cast(Int16) 5)) * cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
    frame_length :=
        (cast,no_check(Int32) (cast,no_check(Int16) ps_dec.nb_subfr)) *
            cast,no_check(Int32) (cast,no_check(Int16) ps_dec.subfr_length);

    if ps_dec.fs_k_hz != fs_k_hz || ps_dec.fs_api_hz != fs_api_hz {
        ret +=
            silk_resampler_init(
                *ps_dec.resampler_state,
                (cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000),
                fs_api_hz,
                0
            );

        ps_dec.fs_api_hz = fs_api_hz;
    }

    if ps_dec.fs_k_hz != fs_k_hz || frame_length != ps_dec.frame_length {
        if fs_k_hz == 8 {
            if ps_dec.nb_subfr == 4 {
                ps_dec.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_NB_I_CDF.data;
            } else {
                ps_dec.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_NB_I_CDF.data;
            }
        } else if ps_dec.nb_subfr == 4 {
            ps_dec.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_I_CDF.data;
        } else {
            ps_dec.pitch_contour_i_cdf = SILK_PITCH_CONTOUR_10_MS_I_CDF.data;
        }
        if ps_dec.fs_k_hz != fs_k_hz {
            ps_dec.ltp_mem_length =
                (cast,no_check(Int32) (cast(Int16) 20)) *
                    cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz);
            if fs_k_hz == 8 || fs_k_hz == 12 {
                ps_dec.lpc_order = 10;
                ps_dec.ps_nlsf_cb = *SILK_NLSF_CB_NB_MB;
            } else {
                ps_dec.lpc_order = 16;
                ps_dec.ps_nlsf_cb = *SILK_NLSF_CB_WB;
            }
            if fs_k_hz == 16 {
                ps_dec.pitch_lag_low_bits_i_cdf = SILK_UNIFORM8_I_CDF.data;
            } else if fs_k_hz == 12 {
                ps_dec.pitch_lag_low_bits_i_cdf = SILK_UNIFORM6_I_CDF.data;
            } else if fs_k_hz == 8 {
                ps_dec.pitch_lag_low_bits_i_cdf = SILK_UNIFORM4_I_CDF.data;
            } else {
            }
            ps_dec.first_frame_after_reset = 1;
            ps_dec.lag_prev = 100;
            ps_dec.last_gain_index = 10;
            ps_dec.prev_signal_type = 0;
            fill_memory(ps_dec.out_buf.data, 0, ps_dec.out_buf.count * size_of(Int16));
            fill_memory(ps_dec.s_lpc_q14_buf.data, 0, ps_dec.s_lpc_q14_buf.count * size_of(Int32));
        }

        ps_dec.fs_k_hz = fs_k_hz;
        ps_dec.frame_length = frame_length;
    }

    (ps_dec.frame_length > 0 && ps_dec.frame_length <= (cast,no_check(s32) ((5 * 4))) * 16);

    return ret;
}

