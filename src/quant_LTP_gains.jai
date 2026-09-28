silk_clz16_in_quant_ltp_gains :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_quant_ltp_gains :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_quant_ltp_gains :: () -> s32 {
    return 0;
}

silk_ror32_in_quant_ltp_gains :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_quant_ltp_gains :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_quant_ltp_gains :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_quant_ltp_gains :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_quant_ltp_gains :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_quant_ltp_gains :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_quant_ltp_gains :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_quant_ltp_gains :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_quant_ltp_gains :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_quant_ltp_gains :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_quant_ltp_gains(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_quant_ltp_gains(in_upper);
    }
}

silk_clz_frac_in_quant_ltp_gains :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_quant_ltp_gains(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_quant_ltp_gains(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_quant_ltp_gains :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_quant_ltp_gains(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_quant_ltp_gains :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_quant_ltp_gains((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_quant_ltp_gains((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_quant_ltp_gains :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_quant_ltp_gains((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_quant_ltp_gains :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_quant_ltp_gains :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_quant_ltp_gains :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_quant_ltp_gains :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_quant_ltp_gains :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_quant_ltp_gains :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_quant_ltp_gains :: (
    b_q14: *Int16,
    cbk_index: *Int8,
    periodicity_index: *Int8,
    sum_log_gain_q7: *Int32,
    pred_gain_d_b_q7: *s32,
    xx_q17: *Int32,
    x_x_q17: *Int32,
    SUBFR_LEN: s32,
    NB_SUBFR: s32,
    arch: s32
) {
    j: s32 = ---;
    temp_idx: [4] Int8 = ---;

    cbk_ptr_q7: *Int8 = ---;
    res_nrg_q15_subfr: Int32 = ---;
    res_nrg_q15: Int32 = ---;
    rate_dist_q7_subfr: Int32 = ---;
    max_gain_q7: Int32 = ---;
    gain_q7: s32 = ---;

    min_rate_dist_q7: Int32 = 0x7fffffff;
    best_sum_log_gain_q7: Int32 = 0;
    k: s32 = 0;
    while k < 3 {
        gain_safety: Int32 = cast,no_check(Int32) (cast(float64) 51.7);

        cl_ptr_q5 := SILK_LTP_GAIN_BITS_Q5_PTRS[k];
        cbk_ptr_q7 = SILK_LTP_VQ_PTRS_Q7[k];
        cbk_gain_ptr_q7 := SILK_LTP_VQ_GAIN_PTRS_Q7[k];
        cbk_size := cast,no_check(s32) SILK_LTP_VQ_SIZES[k];

        xx_q17_ptr := xx_q17;
        x_x_q17_ptr := x_x_q17;

        res_nrg_q15 = 0;
        rate_dist_q7: Int32 = 0;
        sum_log_gain_tmp_q7 := sum_log_gain_q7.*;
        j = 0;
        while j < NB_SUBFR {
            max_gain_q7 =
                silk_log2lin(
                    (cast,no_check(Int32) (cast(float64) 5333.833333333333)) -
                    sum_log_gain_tmp_q7 + cast,no_check(Int32) (cast(float64) 896.5)
                ) - gain_safety;
            silk_vq_w_mat_ec_c(
                temp_idx.data + j,
                *res_nrg_q15_subfr,
                *rate_dist_q7_subfr,
                *gain_q7,
                xx_q17_ptr,
                x_x_q17_ptr,
                cbk_ptr_q7,
                cbk_gain_ptr_q7,
                cl_ptr_q5,
                SUBFR_LEN,
                max_gain_q7,
                cbk_size
            );

            res_nrg_q15 =
                ifx ((cast,no_check(Uint32) res_nrg_q15) + cast,no_check(Uint32) res_nrg_q15_subfr) & 0x80000000 != 0 then 0x7fffffff else res_nrg_q15 +
                    res_nrg_q15_subfr;
            rate_dist_q7 =
                ifx ((cast,no_check(Uint32) rate_dist_q7) + cast,no_check(Uint32) rate_dist_q7_subfr) & 0x80000000 != 0 then 0x7fffffff else rate_dist_q7 +
                    rate_dist_q7_subfr;
            sum_log_gain_tmp_q7 =
                ifx 0 > sum_log_gain_tmp_q7 + silk_lin2log(gain_safety + gain_q7) - cast,no_check(Int32) (cast(float64) 896.5) then 0 else sum_log_gain_tmp_q7 +
                    silk_lin2log(gain_safety + gain_q7) - cast,no_check(Int32) (cast(float64) 896.5);

            xx_q17_ptr += 5 * 5;
            x_x_q17_ptr += 5;
            j += 1;
        }

        if rate_dist_q7 <= min_rate_dist_q7 {
            min_rate_dist_q7 = rate_dist_q7;
            periodicity_index.* = cast,no_check(Int8) k;
            copy_memory(cbk_index, temp_idx.data, cast,no_check(u64) NB_SUBFR);
            best_sum_log_gain_q7 = sum_log_gain_tmp_q7;
        }
        k += 1;
    }

    cbk_ptr_q7 = SILK_LTP_VQ_PTRS_Q7[periodicity_index.*];
    j = 0;
    while j < NB_SUBFR {
        k = 0;
        while k < 5 {
            b_q14[j * 5 + k] =
                cast,no_check(Int16) (cast,no_check(Int32) ((cast,no_check(Uint32) cbk_ptr_q7[(cast(s32) cbk_index[j]) * 5 +
                    k]) << 7));
            k += 1;
        }
        j += 1;
    }

    if NB_SUBFR == 2 {
        res_nrg_q15 = res_nrg_q15 >> 1;
    } else {
        res_nrg_q15 = res_nrg_q15 >> 2;
    }

    sum_log_gain_q7.* = best_sum_log_gain_q7;
    pred_gain_d_b_q7.* =
        (cast,no_check(Int32) (cast,no_check(Int16) (-cast(s32) 3))) *
            cast,no_check(Int32) (cast,no_check(Int16) (silk_lin2log(res_nrg_q15) - cast,no_check(Int32) (((cast(s32) 15) << 7))));
}

