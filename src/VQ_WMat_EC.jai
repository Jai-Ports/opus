silk_clz16_in_vq_w_mat_ec :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_vq_w_mat_ec :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_vq_w_mat_ec :: () -> s32 {
    return 0;
}

silk_ror32_in_vq_w_mat_ec :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_vq_w_mat_ec :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_vq_w_mat_ec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_vq_w_mat_ec :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_vq_w_mat_ec :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_vq_w_mat_ec :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_vq_w_mat_ec :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_vq_w_mat_ec :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_vq_w_mat_ec :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_vq_w_mat_ec :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_vq_w_mat_ec(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_vq_w_mat_ec(in_upper);
    }
}

silk_clz_frac_in_vq_w_mat_ec :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_vq_w_mat_ec(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_vq_w_mat_ec(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_vq_w_mat_ec :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_vq_w_mat_ec(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_vq_w_mat_ec :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_vq_w_mat_ec((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_vq_w_mat_ec((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_vq_w_mat_ec :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_vq_w_mat_ec((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_vq_w_mat_ec :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_vq_w_mat_ec :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_vq_w_mat_ec :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_vq_w_mat_ec :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_vq_w_mat_ec :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_vq_w_mat_ec :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_vq_w_mat_ec_c :: (
    ind: *Int8,
    res_nrg_q15: *Int32,
    rate_dist_q8: *Int32,
    gain_q7: *s32,
    xx_q17: *Int32,
    x_x_q17: *Int32,
    cb_q7: *Int8,
    cb_gain_q7: *Uint8,
    cl_q5: *Uint8,
    SUBFR_LEN: s32,
    MAX_GAIN_Q7: Int32,
    L: s32
) {
    neg_x_x_q24: [5] Int32 = ---;

    bits_res_q8, bits_tot_q8: Int32 = ---;

    neg_x_x_q24[0] = -(cast,no_check(Int32) ((cast,no_check(Uint32) x_x_q17[0]) << 7));
    neg_x_x_q24[1] = -(cast,no_check(Int32) ((cast,no_check(Uint32) x_x_q17[1]) << 7));
    neg_x_x_q24[2] = -(cast,no_check(Int32) ((cast,no_check(Uint32) x_x_q17[2]) << 7));
    neg_x_x_q24[3] = -(cast,no_check(Int32) ((cast,no_check(Uint32) x_x_q17[3]) << 7));
    neg_x_x_q24[4] = -(cast,no_check(Int32) ((cast,no_check(Uint32) x_x_q17[4]) << 7));

    rate_dist_q8.* = 0x7fffffff;
    res_nrg_q15.* = 0x7fffffff;
    cb_row_q7 := cb_q7;

    ind.* = 0;
    if 0 < L {
        for k: 0..L - 1 {
            gain_tmp_q7 := cast,no_check(s32) cb_gain_q7[k];

            sum1_q15: Int32 = cast,no_check(Int32) (cast(float64) 32801.268);

            penalty :=
                cast,no_check(Int32) ((cast,no_check(Uint32) ((ifx gain_tmp_q7 -
                    MAX_GAIN_Q7 > 0 then gain_tmp_q7 - MAX_GAIN_Q7 else 0))) << 11);

            sum2_q24 := neg_x_x_q24[0] + xx_q17[1] * cast(Int32) cb_row_q7[1];
            sum2_q24 = sum2_q24 + xx_q17[2] * cast(Int32) cb_row_q7[2];
            sum2_q24 = sum2_q24 + xx_q17[3] * cast(Int32) cb_row_q7[3];
            sum2_q24 = sum2_q24 + xx_q17[4] * cast(Int32) cb_row_q7[4];
            sum2_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) sum2_q24) << 1);
            sum2_q24 = sum2_q24 + xx_q17[0] * cast(Int32) cb_row_q7[0];
            sum1_q15 =
                cast,no_check(Int32) ((cast(Int64) sum1_q15) +
                    ((cast(Int64) sum2_q24) * cast,no_check(Int64) (cast,no_check(Int16) cb_row_q7[0])) >> 16);

            sum2_q24 = neg_x_x_q24[1] + xx_q17[7] * cast(Int32) cb_row_q7[2];
            sum2_q24 = sum2_q24 + xx_q17[8] * cast(Int32) cb_row_q7[3];
            sum2_q24 = sum2_q24 + xx_q17[9] * cast(Int32) cb_row_q7[4];
            sum2_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) sum2_q24) << 1);
            sum2_q24 = sum2_q24 + xx_q17[6] * cast(Int32) cb_row_q7[1];
            sum1_q15 =
                cast,no_check(Int32) ((cast(Int64) sum1_q15) +
                    ((cast(Int64) sum2_q24) * cast,no_check(Int64) (cast,no_check(Int16) cb_row_q7[1])) >> 16);

            sum2_q24 = neg_x_x_q24[2] + xx_q17[13] * cast(Int32) cb_row_q7[3];
            sum2_q24 = sum2_q24 + xx_q17[14] * cast(Int32) cb_row_q7[4];
            sum2_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) sum2_q24) << 1);
            sum2_q24 = sum2_q24 + xx_q17[12] * cast(Int32) cb_row_q7[2];
            sum1_q15 =
                cast,no_check(Int32) ((cast(Int64) sum1_q15) +
                    ((cast(Int64) sum2_q24) * cast,no_check(Int64) (cast,no_check(Int16) cb_row_q7[2])) >> 16);

            sum2_q24 = neg_x_x_q24[3] + xx_q17[19] * cast(Int32) cb_row_q7[4];
            sum2_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) sum2_q24) << 1);
            sum2_q24 = sum2_q24 + xx_q17[18] * cast(Int32) cb_row_q7[3];
            sum1_q15 =
                cast,no_check(Int32) ((cast(Int64) sum1_q15) +
                    ((cast(Int64) sum2_q24) * cast,no_check(Int64) (cast,no_check(Int16) cb_row_q7[3])) >> 16);

            sum2_q24 = cast,no_check(Int32) ((cast,no_check(Uint32) neg_x_x_q24[4]) << 1);
            sum2_q24 = sum2_q24 + xx_q17[24] * cast(Int32) cb_row_q7[4];
            sum1_q15 =
                cast,no_check(Int32) ((cast(Int64) sum1_q15) +
                    ((cast(Int64) sum2_q24) * cast,no_check(Int64) (cast,no_check(Int16) cb_row_q7[4])) >> 16);

            if sum1_q15 >= 0 {
                bits_res_q8 =
                    (cast,no_check(Int32) (cast,no_check(Int16) SUBFR_LEN)) *
                        cast,no_check(Int32) (cast,no_check(Int16) (silk_lin2log(sum1_q15 + penalty) - cast,no_check(Int32) (((cast(s32) 15) << 7))));

                bits_tot_q8 = bits_res_q8 + cast,no_check(Int32) ((cast,no_check(Uint32) cl_q5[k]) << (((3 - 1)) & 31));
                if bits_tot_q8 <= rate_dist_q8.* {
                    rate_dist_q8.* = bits_tot_q8;
                    res_nrg_q15.* = sum1_q15 + penalty;
                    ind.* = cast,no_check(Int8) k;
                    gain_q7.* = gain_tmp_q7;
                }
            }

            cb_row_q7 += 5;
        }
    }
}

