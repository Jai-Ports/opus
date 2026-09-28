silk_clz16_in_nlsf_del_dec_quant :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nlsf_del_dec_quant :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nlsf_del_dec_quant :: () -> s32 {
    return 0;
}

silk_ror32_in_nlsf_del_dec_quant :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nlsf_del_dec_quant :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nlsf_del_dec_quant :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nlsf_del_dec_quant :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nlsf_del_dec_quant :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nlsf_del_dec_quant :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nlsf_del_dec_quant :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nlsf_del_dec_quant :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nlsf_del_dec_quant :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nlsf_del_dec_quant :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nlsf_del_dec_quant(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nlsf_del_dec_quant(in_upper);
    }
}

silk_clz_frac_in_nlsf_del_dec_quant :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nlsf_del_dec_quant(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nlsf_del_dec_quant(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nlsf_del_dec_quant :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nlsf_del_dec_quant(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nlsf_del_dec_quant :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nlsf_del_dec_quant((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nlsf_del_dec_quant((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nlsf_del_dec_quant :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nlsf_del_dec_quant((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nlsf_del_dec_quant :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nlsf_del_dec_quant :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nlsf_del_dec_quant :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nlsf_del_dec_quant :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nlsf_del_dec_quant :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nlsf_del_dec_quant :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_nlsf_del_dec_quant :: (
    indices: *Int8,
    x_q10: *Int16,
    w_q5: *Int16,
    pred_coef_q8: *Uint8,
    ec_ix: *Int16,
    ec_rates_q5: *Uint8,
    QUANT_STEP_SIZE_Q16: s32,
    INV_QUANT_STEP_SIZE_Q6: Int16,
    MU_Q20: Int32,
    ORDER: Int16
) -> Int32 {
    j: s32 = ---;
    ind_tmp: s32 = ---;
    ind_min_max: s32 = ---;
    ind_max_min: s32 = ---;
    res_q10: s32 = ---;
    pred_q10, diff_q10, rate0_q5, rate1_q5: s32 = ---;
    out0_q10, out1_q10: Int16 = ---;
    rd_tmp_q25: Int32 = ---;
    min_max_q25: Int32 = ---;
    max_min_q25: Int32 = ---;
    ind_sort: [4] s32 = ---;
    ind: [4] [16] Int8 = ---;
    prev_out_q10: [8] Int16 = ---;
    rd_q25: [8] Int32 = ---;
    rd_min_q25: [4] Int32 = ---;
    rd_max_q25: [4] Int32 = ---;

    out0_q10_table: [20] s32 = ---;
    out1_q10_table: [20] s32 = ---;

    i: s32 = -10;
    while i <= 10 - 1 {
        out0_q10 = cast,no_check(Int16) (cast,no_check(Int32) ((cast,no_check(Uint32) i) << 10));
        out1_q10 = cast,no_check(Int16) ((cast(s32) out0_q10) + 1024);
        if i > 0 {
            out0_q10 = cast,no_check(Int16) ((cast(Int32) out0_q10) - cast,no_check(Int32) (cast(float64) 102.9));
            out1_q10 = cast,no_check(Int16) ((cast(Int32) out1_q10) - cast,no_check(Int32) (cast(float64) 102.9));
        } else if i == 0 {
            out1_q10 = cast,no_check(Int16) ((cast(Int32) out1_q10) - cast,no_check(Int32) (cast(float64) 102.9));
        } else if i == -1 {
            out0_q10 = cast,no_check(Int16) ((cast(Int32) out0_q10) + cast,no_check(Int32) (cast(float64) 102.9));
        } else {
            out0_q10 = cast,no_check(Int16) ((cast(Int32) out0_q10) + cast,no_check(Int32) (cast(float64) 102.9));
            out1_q10 = cast,no_check(Int16) ((cast(Int32) out1_q10) + cast,no_check(Int32) (cast(float64) 102.9));
        }
        out0_q10_table[i + 10] =
            ((cast,no_check(Int32) out0_q10) *
                cast,no_check(Int32) (cast,no_check(Int16) QUANT_STEP_SIZE_Q16)) >> 16;
        out1_q10_table[i + 10] =
            ((cast,no_check(Int32) out1_q10) *
                cast,no_check(Int32) (cast,no_check(Int16) QUANT_STEP_SIZE_Q16)) >> 16;
        i += 1;
    }

    ((cast(s32) 1) << 2 & ((cast(s32) 1) << 2 - 1) == 0);

    n_states: s32 = 1;
    rd_q25[0] = 0;
    prev_out_q10[0] = 0;
    i = (cast(s32) ORDER) - 1;
    while i >= 0 {
        rates_q5 := *ec_rates_q5[ec_ix[i]];
        in_q10 := cast,no_check(s32) x_q10[i];
        j = 0;
        while j < n_states {
            pred_q10 =
                ((cast,no_check(Int32) (cast,no_check(Int16) pred_coef_q8[i])) *
                    cast,no_check(Int32) prev_out_q10[j]) >> 8;
            res_q10 = in_q10 - pred_q10;
            ind_tmp =
                ((cast,no_check(Int32) INV_QUANT_STEP_SIZE_Q6) *
                    cast,no_check(Int32) (cast,no_check(Int16) res_q10)) >> 16;
            ind_tmp =
                ifx -10 > 10 -
                    1 then (ifx ind_tmp > -10 then -10 else (ifx ind_tmp < 10 - 1 then cast,no_check(s32) ((10 - 1)) else ind_tmp)) else (ifx ind_tmp > 10 - 1 then cast,no_check(s32) ((10 - 1)) else (ifx ind_tmp < -10 then -10 else ind_tmp));
            ind[j][i] = cast,no_check(Int8) ind_tmp;

            out0_q10 = cast,no_check(Int16) out0_q10_table[ind_tmp + 10];
            out1_q10 = cast,no_check(Int16) out1_q10_table[ind_tmp + 10];

            out0_q10 = cast,no_check(Int16) ((cast(s32) out0_q10) + pred_q10);
            out1_q10 = cast,no_check(Int16) ((cast(s32) out1_q10) + pred_q10);
            prev_out_q10[j] = out0_q10;
            prev_out_q10[j + n_states] = out1_q10;

            if ind_tmp + 1 >= 4 {
                if ind_tmp + 1 == 4 {
                    rate0_q5 = cast,no_check(s32) rates_q5[ind_tmp + 4];
                    rate1_q5 = 280;
                } else {
                    rate0_q5 =
                        (cast,no_check(Int32) ((280 - cast,no_check(s32) ((43 * 4))))) +
                            (cast,no_check(Int32) (cast(Int16) 43)) * cast,no_check(Int32) (cast,no_check(Int16) ind_tmp);
                    rate1_q5 = rate0_q5 + 43;
                }
            } else if ind_tmp <= -4 {
                if ind_tmp == -4 {
                    rate0_q5 = 280;
                    rate1_q5 = cast,no_check(s32) rates_q5[ind_tmp + 1 + 4];
                } else {
                    rate0_q5 =
                        (cast,no_check(Int32) ((280 - cast,no_check(s32) ((43 * 4))))) +
                            (cast,no_check(Int32) (cast,no_check(Int16) (-cast(s32) 43))) * cast,no_check(Int32) (cast,no_check(Int16) ind_tmp);
                    rate1_q5 = rate0_q5 - 43;
                }
            } else {
                rate0_q5 = cast,no_check(s32) rates_q5[ind_tmp + 4];
                rate1_q5 = cast,no_check(s32) rates_q5[ind_tmp + 1 + 4];
            }
            rd_tmp_q25 = rd_q25[j];
            diff_q10 = in_q10 - cast(s32) out0_q10;
            rd_q25[j] =
                (rd_tmp_q25 + ((cast,no_check(Int32) (cast,no_check(Int16) diff_q10)) * cast,no_check(Int32) (cast,no_check(Int16) diff_q10)) * cast(Int32) w_q5[i]) +
                    (cast,no_check(Int32) (cast,no_check(Int16) MU_Q20)) * cast,no_check(Int32) (cast,no_check(Int16) rate0_q5);
            diff_q10 = in_q10 - cast(s32) out1_q10;
            rd_q25[j + n_states] =
                (rd_tmp_q25 + ((cast,no_check(Int32) (cast,no_check(Int16) diff_q10)) * cast,no_check(Int32) (cast,no_check(Int16) diff_q10)) * cast(Int32) w_q5[i]) +
                    (cast,no_check(Int32) (cast,no_check(Int16) MU_Q20)) * cast,no_check(Int32) (cast,no_check(Int16) rate1_q5);
            j += 1;
        }

        if n_states <= (cast(s32) 1) << 2 / 2 {
            j = 0;
            while j < n_states {
                ind[j + n_states][i] = cast,no_check(Int8) ((cast(s32) ind[j][i]) + 1);
                j += 1;
            }
            n_states = cast,no_check(Int32) ((cast,no_check(Uint32) n_states) << 1);
            j = n_states;
            while j < (cast(s32) 1) << 2 {
                ind[j][i] = ind[j - n_states][i];
                j += 1;
            }
        } else {
            j = 0;
            while j < (cast(s32) 1) << 2 {
                if rd_q25[j] > rd_q25[j + (cast(s32) 1) << 2] {
                    rd_max_q25[j] = rd_q25[j];
                    rd_min_q25[j] = rd_q25[j + (cast(s32) 1) << 2];
                    rd_q25[j] = rd_min_q25[j];
                    rd_q25[j + (cast(s32) 1) << 2] = rd_max_q25[j];

                    out0_q10 = prev_out_q10[j];
                    prev_out_q10[j] = prev_out_q10[j + (cast(s32) 1) << 2];
                    prev_out_q10[j + (cast(s32) 1) << 2] = out0_q10;
                    ind_sort[j] = j + (cast(s32) 1) << 2;
                } else {
                    rd_min_q25[j] = rd_q25[j];
                    rd_max_q25[j] = rd_q25[j + (cast(s32) 1) << 2];
                    ind_sort[j] = j;
                }
                j += 1;
            }

            while ((cast(s32) 1) != 0) {
                min_max_q25 = 0x7fffffff;
                max_min_q25 = 0;
                ind_min_max = 0;
                ind_max_min = 0;
                j = 0;
                while j < (cast(s32) 1) << 2 {
                    if min_max_q25 > rd_max_q25[j] {
                        min_max_q25 = rd_max_q25[j];
                        ind_min_max = j;
                    }
                    if max_min_q25 < rd_min_q25[j] {
                        max_min_q25 = rd_min_q25[j];
                        ind_max_min = j;
                    }
                    j += 1;
                }
                if min_max_q25 >= max_min_q25 {
                    break;
                }

                ind_sort[ind_max_min] = ind_sort[ind_min_max] ^ ((cast(s32) 1) << 2);
                rd_q25[ind_max_min] = rd_q25[ind_min_max + (cast(s32) 1) << 2];
                prev_out_q10[ind_max_min] = prev_out_q10[ind_min_max + (cast(s32) 1) << 2];
                rd_min_q25[ind_max_min] = 0;
                rd_max_q25[ind_min_max] = 0x7fffffff;
                copy_memory(ind[ind_max_min].data, ind[ind_min_max].data, 16);
            }

            j = 0;
            while j < (cast(s32) 1) << 2 {
                ind[j][i] = cast,no_check(Int8) ((cast,no_check(s32) ind[j][i]) + (ind_sort[j] >> 2));
                j += 1;
            }
        }
        i -= 1;
    }

    ind_tmp = 0;
    min_q25: Int32 = 0x7fffffff;
    j = 0;
    while j < 2 * (cast(s32) 1) << 2 {
        if min_q25 > rd_q25[j] {
            min_q25 = rd_q25[j];
            ind_tmp = j;
        }
        j += 1;
    }
    j = 0;
    while j < cast,no_check(s32) ORDER {
        indices[j] = ind[ind_tmp & ((cast(s32) 1) << 2 - 1)][j];
        (indices[j] >= -10);
        (indices[j] <= 10);
        j += 1;
    }
    indices[0] = cast,no_check(Int8) ((cast,no_check(s32) indices[0]) + (ind_tmp >> 2));
    (indices[0] <= 10);

    return min_q25;
}

