// Generated directly from C by cpp_transpiler.
silk_clz16_in_nlsf_encode :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nlsf_encode :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nlsf_encode :: () -> s32 {
    return 0;
}

silk_ror32_in_nlsf_encode :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nlsf_encode :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nlsf_encode :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nlsf_encode :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nlsf_encode :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nlsf_encode :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nlsf_encode :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nlsf_encode :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nlsf_encode :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nlsf_encode :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nlsf_encode(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nlsf_encode(in_upper);
    }
}

silk_clz_frac_in_nlsf_encode :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nlsf_encode(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nlsf_encode(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nlsf_encode :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nlsf_encode(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nlsf_encode :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nlsf_encode((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nlsf_encode((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nlsf_encode :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nlsf_encode((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nlsf_encode :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nlsf_encode :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nlsf_encode :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nlsf_encode :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nlsf_encode :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nlsf_encode :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_nlsf_encode :: (
    nlsf_indices: *Int8,
    p_nlsf_q15: *Int16,
    ps_nlsf_cb: *Silk_NLSF_CB_Struct,
    p_w_q2: *Int16,
    NLSF_MU_Q20: s32,
    N_SURVIVORS: s32,
    SIGNAL_TYPE: s32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    i: s32 = ---;
    best_index: s32 = ---;
    w_tmp_q9: Int32 = ---;

    res_q10: [16] Int16 = ---;
    nlsf_tmp_q15: [16] Int16 = ---;
    w_adj_q5: [16] Int16 = ---;
    pred_q8: [16] Uint8 = ---;
    ec_ix: [16] Int16 = ---;

    (SIGNAL_TYPE >= 0 && SIGNAL_TYPE <= 2);
    (NLSF_MU_Q20 <= 32767 && NLSF_MU_Q20 >= 0);

    silk_nlsf_stabilize(p_nlsf_q15, ps_nlsf_cb.delta_min_q15, cast,no_check(s32) ps_nlsf_cb.order);

    err_q24 := cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) * cast,no_check(u64) ps_nlsf_cb.n_vectors)));
    silk_nlsf_vq(
        err_q24,
        p_nlsf_q15,
        ps_nlsf_cb.cb1_nlsf_q8,
        ps_nlsf_cb.cb1_wght_q9,
        cast,no_check(s32) ps_nlsf_cb.n_vectors,
        cast,no_check(s32) ps_nlsf_cb.order
    );

    temp_indices1 := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) N_SURVIVORS)));
    silk_insertion_sort_increasing(err_q24, temp_indices1, cast,no_check(s32) ps_nlsf_cb.n_vectors, N_SURVIVORS);

    rd_q25 := cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) * cast,no_check(u64) N_SURVIVORS)));
    temp_indices2 :=
        cast(*Int8) c_transpiler_alloca(cast(u64) ((size_of(Int8) *
            cast,no_check(u64) (N_SURVIVORS * 16))));

    if 0 < N_SURVIVORS {
        for s: 0..N_SURVIVORS - 1 {
            ind1 := temp_indices1[s];

            p_cb_element := *ps_nlsf_cb.cb1_nlsf_q8[ind1 * cast(s32) ps_nlsf_cb.order];
            p_cb_wght_q9 := *ps_nlsf_cb.cb1_wght_q9[ind1 * cast(s32) ps_nlsf_cb.order];
            i = 0;
            while i < cast,no_check(s32) ps_nlsf_cb.order {
                nlsf_tmp_q15[i] =
                    cast,no_check(Int16) ((cast(s32) (cast,no_check(Uint16) (cast,no_check(Int16) p_cb_element[i]))) << 7);
                w_tmp_q9 = cast,no_check(Int32) p_cb_wght_q9[i];
                res_q10[i] =
                    cast,no_check(Int16) (((cast,no_check(Int32) (cast,no_check(Int16) ((cast(s32) p_nlsf_q15[i]) - cast(s32) nlsf_tmp_q15[i]))) *
                        cast,no_check(Int32) (cast,no_check(Int16) w_tmp_q9)) >> 14);
                w_adj_q5[i] =
                    cast,no_check(Int16) silk_div32_var_q_in_nlsf_encode(
                        cast,no_check(Int32) p_w_q2[i],
                        (cast,no_check(Int32) (cast,no_check(Int16) w_tmp_q9)) *
                        cast,no_check(Int32) (cast,no_check(Int16) w_tmp_q9),
                        21
                    );
                i += 1;
            }

            (cast,no_check(#type (_: *Int16, _: *Uint8, _: *Silk_NLSF_CB_Struct, _: s32)) (cast(*void) silk_nlsf_unpack))(
                ec_ix.data,
                pred_q8.data,
                ps_nlsf_cb,
                ind1
            );

            rd_q25[s] =
                silk_nlsf_del_dec_quant(
                    *temp_indices2[s * 16],
                    res_q10.data,
                    w_adj_q5.data,
                    pred_q8.data,
                    ec_ix.data,
                    ps_nlsf_cb.ec_rates_q5,
                    cast,no_check(s32) ps_nlsf_cb.quant_step_size_q16,
                    ps_nlsf_cb.inv_quant_step_size_q6,
                    NLSF_MU_Q20,
                    ps_nlsf_cb.order
                );

            i_cdf_ptr := *ps_nlsf_cb.cb1_i_cdf[SIGNAL_TYPE >> 1 * cast(s32) ps_nlsf_cb.n_vectors];
            prob_q8: s32 = ifx ind1 == 0
                then 256 - cast(s32) i_cdf_ptr[ind1]
                else (cast(s32) i_cdf_ptr[ind1 - 1]) - cast(s32) i_cdf_ptr[ind1];
            bits_q7 := (cast,no_check(Int32) (((cast(s32) 8) << 7))) - silk_lin2log(prob_q8);
            rd_q25[s] =
                rd_q25[s] +
                    (cast,no_check(Int32) (cast,no_check(Int16) bits_q7)) * cast,no_check(Int32) (cast,no_check(Int16) (NLSF_MU_Q20 >> 2));
        }
    }

    silk_insertion_sort_increasing(rd_q25, *best_index, N_SURVIVORS, 1);

    nlsf_indices[0] = cast,no_check(Int8) temp_indices1[best_index];
    copy_memory(*nlsf_indices[1], *temp_indices2[best_index * 16], cast,no_check(u64) ps_nlsf_cb.order);

    silk_nlsf_decode(p_nlsf_q15, nlsf_indices, ps_nlsf_cb);

    ret := rd_q25[0];

    return ret;
}

false__in_nlsf_encode :: () -> s32 {
    return 0;
}

Uint16 :: u16;

