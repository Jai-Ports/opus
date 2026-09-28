silk_clz16_in_decode_parameters :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decode_parameters :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decode_parameters :: () -> s32 {
    return 0;
}

silk_ror32_in_decode_parameters :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decode_parameters :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decode_parameters :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decode_parameters :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decode_parameters :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decode_parameters :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decode_parameters :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decode_parameters :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decode_parameters :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decode_parameters :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decode_parameters(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decode_parameters(in_upper);
    }
}

silk_clz_frac_in_decode_parameters :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decode_parameters(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decode_parameters(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decode_parameters :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decode_parameters(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decode_parameters :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decode_parameters((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decode_parameters((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decode_parameters :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decode_parameters((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_decode_parameters :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_decode_parameters :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_decode_parameters :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_decode_parameters :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_decode_parameters :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_decode_parameters :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_decode_parameters :: (ps_dec: *Silk_Decoder_State, ps_dec_ctrl: *Silk_Decoder_Control, cond_coding: s32) {
    i, k, ix: s32 = ---;
    p_nlsf_q15, p_nlsf0_q15: [16] Int16 = ---;
    cbk_ptr_q7: *Int8 = ---;

    silk_gains_dequant(
        ps_dec_ctrl.gains_q16.data,
        ps_dec.indices.gains_indices.data,
        *ps_dec.last_gain_index,
        cast(s32) (cond_coding == 2),
        ps_dec.nb_subfr
    );

    (cast,no_check(#type (_: *Int16, _: *Int8, _: *Silk_NLSF_CB_Struct)) (cast(*void) silk_nlsf_decode))(
        p_nlsf_q15.data,
        ps_dec.indices.nlsf_indices.data,
        ps_dec.ps_nlsf_cb
    );

    silk_nlsf2_a(ps_dec_ctrl.pred_coef_q12[1].data, p_nlsf_q15.data, ps_dec.lpc_order, ps_dec.arch);

    if ps_dec.first_frame_after_reset == 1 {
        ps_dec.indices.nlsf_interp_coef_q2 = 4;
    }

    if ps_dec.indices.nlsf_interp_coef_q2 < 4 {
        i = 0;
        while i < ps_dec.lpc_order {
            p_nlsf0_q15[i] =
                cast,no_check(Int16) ((cast(s32) ps_dec.prev_nlsf_q15[i]) +
                    ((cast(s32) ps_dec.indices.nlsf_interp_coef_q2) * ((cast(s32) p_nlsf_q15[i]) - cast(s32) ps_dec.prev_nlsf_q15[i])) >> 2);
            i += 1;
        }

        silk_nlsf2_a(ps_dec_ctrl.pred_coef_q12[0].data, p_nlsf0_q15.data, ps_dec.lpc_order, ps_dec.arch);
    } else {
        copy_memory(
            ps_dec_ctrl.pred_coef_q12[0].data,
            ps_dec_ctrl.pred_coef_q12[1].data,
            cast,no_check(u64) ps_dec.lpc_order * size_of(Int16)
        );
    }

    copy_memory(ps_dec.prev_nlsf_q15.data, p_nlsf_q15.data, cast,no_check(u64) ps_dec.lpc_order * size_of(Int16));

    if ps_dec.loss_cnt != 0 {
        silk_bwexpander(ps_dec_ctrl.pred_coef_q12[0].data, ps_dec.lpc_order, 63570);
        silk_bwexpander(ps_dec_ctrl.pred_coef_q12[1].data, ps_dec.lpc_order, 63570);
    }

    if ps_dec.indices.signal_type == 2 {
        silk_decode_pitch(
            ps_dec.indices.lag_index,
            ps_dec.indices.contour_index,
            ps_dec_ctrl.pitch_l.data,
            ps_dec.fs_k_hz,
            ps_dec.nb_subfr
        );

        cbk_ptr_q7 = SILK_LTP_VQ_PTRS_Q7[ps_dec.indices.per_index];

        k = 0;
        while k < ps_dec.nb_subfr {
            ix = cast,no_check(s32) ps_dec.indices.ltp_index[k];
            i = 0;
            while i < 5 {
                ps_dec_ctrl.ltp_coef_q14[k * 5 + i] =
                    cast,no_check(Int16) (cast,no_check(Int32) ((cast,no_check(Uint32) cbk_ptr_q7[ix * 5 +
                        i]) << 7));
                i += 1;
            }
            k += 1;
        }

        ix = cast,no_check(s32) ps_dec.indices.ltp_scale_index;
        ps_dec_ctrl.ltp_scale_q14 = cast,no_check(s32) SILK_LTP_SCALES_TABLE_Q14[ix];
    } else {
        fill_memory(ps_dec_ctrl.pitch_l.data, 0, cast,no_check(u64) ps_dec.nb_subfr * size_of(s32));
        fill_memory(ps_dec_ctrl.ltp_coef_q14.data, 0, cast,no_check(u64) (5 * ps_dec.nb_subfr) * size_of(Int16));
        ps_dec.indices.per_index = 0;
        ps_dec_ctrl.ltp_scale_q14 = 0;
    }
}

