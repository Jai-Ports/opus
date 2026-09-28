silk_clz16_in_encode_indices :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_encode_indices :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_encode_indices :: () -> s32 {
    return 0;
}

silk_ror32_in_encode_indices :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_encode_indices :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_encode_indices :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_encode_indices :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_encode_indices :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_encode_indices :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_encode_indices :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_encode_indices :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_encode_indices :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_encode_indices :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_encode_indices(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_encode_indices(in_upper);
    }
}

silk_clz_frac_in_encode_indices :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_encode_indices(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_encode_indices(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_encode_indices :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_encode_indices(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_encode_indices :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_encode_indices((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_encode_indices((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_encode_indices :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_encode_indices((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_encode_indices :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_encode_indices :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_encode_indices :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_encode_indices :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_encode_indices :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_encode_indices :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_encode_indices :: (
    ps_enc_c: *Silk_Encoder_State,
    ps_range_enc: *Ec_Enc,
    frame_index: s32,
    encode_lbrr: s32,
    cond_coding: s32
) {
    k: s32 = ---;
    encode_absolute_lag_index, delta_lag_index: s32 = ---;
    ec_ix: [16] Int16 = ---;
    pred_q8: [16] Uint8 = ---;

    ps_indices: *Side_Info_Indices = ifx encode_lbrr != 0
        then ps_enc_c.indices_lbrr.data + frame_index
        else *ps_enc_c.indices;

    type_offset := (2 * cast(s32) ps_indices.signal_type) + cast(s32) ps_indices.quant_offset_type;
    (type_offset >= 0 && type_offset < 6);
    (encode_lbrr == 0 || type_offset >= 2);
    if encode_lbrr != 0 || type_offset >= 2 {
        ec_enc_icdf(ps_range_enc, type_offset - 2, SILK_TYPE_OFFSET_VAD_I_CDF.data, 8);
    } else {
        ec_enc_icdf(ps_range_enc, type_offset, SILK_TYPE_OFFSET_NO_VAD_I_CDF.data, 8);
    }

    if cond_coding == 2 {
        (ps_indices.gains_indices[0] >= 0 && cast,no_check(s32) ps_indices.gains_indices[0] < (cast,no_check(s32) ((36 - -4))) + 1);
        ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.gains_indices[0], SILK_DELTA_GAIN_I_CDF.data, 8);
    } else {
        (ps_indices.gains_indices[0] >= 0 && ps_indices.gains_indices[0] < 64);
        ec_enc_icdf(
            ps_range_enc,
            (cast(s32) ps_indices.gains_indices[0]) >> 3,
            SILK_GAIN_I_CDF[ps_indices.signal_type].data,
            8
        );
        ec_enc_icdf(ps_range_enc, (cast(s32) ps_indices.gains_indices[0]) & 7, SILK_UNIFORM8_I_CDF.data, 8);
    }

    i: s32 = 1;
    while i < ps_enc_c.nb_subfr {
        (ps_indices.gains_indices[i] >= 0 && cast,no_check(s32) ps_indices.gains_indices[i] < (cast,no_check(s32) ((36 - -4))) + 1);
        ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.gains_indices[i], SILK_DELTA_GAIN_I_CDF.data, 8);
        i += 1;
    }

    ec_enc_icdf(
        ps_range_enc,
        cast,no_check(s32) ps_indices.nlsf_indices[0],
        *ps_enc_c.ps_nlsf_cb.cb1_i_cdf[(cast(s32) ps_indices.signal_type) >> 1 *
        cast(s32) ps_enc_c.ps_nlsf_cb.n_vectors],
        8
    );
    (cast,no_check(#type (_: *Int16, _: *Uint8, _: *Silk_NLSF_CB_Struct, _: s32)) (cast(*void) silk_nlsf_unpack))(
        ec_ix.data,
        pred_q8.data,
        ps_enc_c.ps_nlsf_cb,
        cast,no_check(s32) ps_indices.nlsf_indices[0]
    );
    (cast,no_check(s32) ps_enc_c.ps_nlsf_cb.order == ps_enc_c.predict_lpc_order);
    i = 0;
    while i < cast,no_check(s32) ps_enc_c.ps_nlsf_cb.order {
        if ps_indices.nlsf_indices[i + 1] >= 4 {
            ec_enc_icdf(ps_range_enc, cast,no_check(s32) (2 * 4), *ps_enc_c.ps_nlsf_cb.ec_i_cdf[ec_ix[i]], 8);
            ec_enc_icdf(ps_range_enc, (cast(s32) ps_indices.nlsf_indices[i + 1]) - 4, SILK_NLSF_EXT_I_CDF.data, 8);
        } else if ps_indices.nlsf_indices[i + 1] <= -4 {
            ec_enc_icdf(ps_range_enc, 0, *ps_enc_c.ps_nlsf_cb.ec_i_cdf[ec_ix[i]], 8);
            ec_enc_icdf(
                ps_range_enc,
                -(cast,no_check(s32) ps_indices.nlsf_indices[i + 1]) - 4,
                SILK_NLSF_EXT_I_CDF.data,
                8
            );
        } else {
            ec_enc_icdf(
                ps_range_enc,
                (cast(s32) ps_indices.nlsf_indices[i + 1]) + 4,
                *ps_enc_c.ps_nlsf_cb.ec_i_cdf[ec_ix[i]],
                8
            );
        }
        i += 1;
    }

    if ps_enc_c.nb_subfr == 4 {
        (ps_indices.nlsf_interp_coef_q2 >= 0 && ps_indices.nlsf_interp_coef_q2 < 5);
        ec_enc_icdf(
            ps_range_enc,
            cast,no_check(s32) ps_indices.nlsf_interp_coef_q2,
            SILK_NLSF_INTERPOLATION_FACTOR_I_CDF.data,
            8
        );
    }

    if ps_indices.signal_type == 2 {
        encode_absolute_lag_index = 1;
        if cond_coding == 2 && ps_enc_c.ec_prev_signal_type == 2 {
            delta_lag_index = (cast(s32) ps_indices.lag_index) - cast(s32) ps_enc_c.ec_prev_lag_index;
            if delta_lag_index < -8 || delta_lag_index > 11 {
                delta_lag_index = 0;
            } else {
                delta_lag_index = delta_lag_index + 9;
                encode_absolute_lag_index = 0;
            }
            (delta_lag_index >= 0 && delta_lag_index < 21);
            ec_enc_icdf(ps_range_enc, delta_lag_index, SILK_PITCH_DELTA_I_CDF.data, 8);
        }
        if encode_absolute_lag_index != 0 {
            pitch_high_bits: Int32 = ---;
            pitch_high_bits = (cast(s32) ps_indices.lag_index) / ps_enc_c.fs_k_hz >> 1;
            pitch_low_bits :=
                (cast(Int32) ps_indices.lag_index) -
                    (cast,no_check(Int32) (cast,no_check(Int16) pitch_high_bits)) * cast,no_check(Int32) (cast,no_check(Int16) (ps_enc_c.fs_k_hz >> 1));
            (pitch_low_bits < ps_enc_c.fs_k_hz / 2);

            ec_enc_icdf(ps_range_enc, pitch_high_bits, SILK_PITCH_LAG_I_CDF.data, 8);
            ec_enc_icdf(ps_range_enc, pitch_low_bits, ps_enc_c.pitch_lag_low_bits_i_cdf, 8);
        }
        ps_enc_c.ec_prev_lag_index = ps_indices.lag_index;

        (ps_indices.contour_index >= 0);
        (ps_indices.contour_index < 34 && ps_enc_c.fs_k_hz > 8 && ps_enc_c.nb_subfr == 4 || ps_indices.contour_index < 11 && ps_enc_c.fs_k_hz == 8 && ps_enc_c.nb_subfr == 4 || ps_indices.contour_index < 12 && ps_enc_c.fs_k_hz > 8 && ps_enc_c.nb_subfr == 2 || ps_indices.contour_index < 3 && ps_enc_c.fs_k_hz == 8 && ps_enc_c.nb_subfr == 2);
        ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.contour_index, ps_enc_c.pitch_contour_i_cdf, 8);

        (ps_indices.per_index >= 0 && ps_indices.per_index < 3);
        ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.per_index, SILK_LTP_PER_INDEX_I_CDF.data, 8);

        k = 0;
        while k < ps_enc_c.nb_subfr {
            (ps_indices.ltp_index[k] >= 0 && cast,no_check(s32) ps_indices.ltp_index[k] < (cast(s32) 8) << ((ps_indices.per_index) & 31));
            ec_enc_icdf(
                ps_range_enc,
                cast,no_check(s32) ps_indices.ltp_index[k],
                SILK_LTP_GAIN_I_CDF_PTRS[ps_indices.per_index],
                8
            );
            k += 1;
        }

        if cond_coding == 0 {
            (ps_indices.ltp_scale_index >= 0 && ps_indices.ltp_scale_index < 3);
            ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.ltp_scale_index, SILK_LT_PSCALE_I_CDF.data, 8);
        }
        (cond_coding == 0 || ps_indices.ltp_scale_index == 0);
    }

    ps_enc_c.ec_prev_signal_type = cast,no_check(s32) ps_indices.signal_type;

    (ps_indices.seed >= 0 && ps_indices.seed < 4);
    ec_enc_icdf(ps_range_enc, cast,no_check(s32) ps_indices.seed, SILK_UNIFORM4_I_CDF.data, 8);
}

