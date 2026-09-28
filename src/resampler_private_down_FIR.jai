SILK_RESAMPLER_DOWN2_0_in_resampler_private_down_fir: Int16;

SILK_RESAMPLER_DOWN2_1_in_resampler_private_down_fir: Int16;

SILK_RESAMPLER_UP2_HQ_0_in_resampler_private_down_fir: [3] Int16;

SILK_RESAMPLER_UP2_HQ_1_in_resampler_private_down_fir: [3] Int16;

silk_clz16_in_resampler_private_down_fir :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_resampler_private_down_fir :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_resampler_private_down_fir :: () -> s32 {
    return 0;
}

silk_ror32_in_resampler_private_down_fir :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_resampler_private_down_fir :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_resampler_private_down_fir :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_resampler_private_down_fir :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_resampler_private_down_fir :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_resampler_private_down_fir :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_resampler_private_down_fir :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_resampler_private_down_fir :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_resampler_private_down_fir :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_resampler_private_down_fir :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_resampler_private_down_fir(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_resampler_private_down_fir(in_upper);
    }
}

silk_clz_frac_in_resampler_private_down_fir :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_resampler_private_down_fir(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_resampler_private_down_fir(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_resampler_private_down_fir :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_resampler_private_down_fir(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_resampler_private_down_fir :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_resampler_private_down_fir((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_resampler_private_down_fir((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_resampler_private_down_fir :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_resampler_private_down_fir((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_resampler_private_down_fir :: (ss: *void, out: *Int16, in: *Int16, in_len: Int32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    s := cast(*Silk_Resampler_State_Struct) ss;
    n_samples_in: Int32 = ---;

    buf :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) (s.batch_size + s.fir_order))));

    copy_memory(buf, s.s_fir.i32.data, cast,no_check(u64) s.fir_order * size_of(Int32));

    fir_coefs := *s.coefs[2];

    index_increment_q16 := s.inv_ratio_q16;
    while ((cast(s32) 1) != 0) {
        n_samples_in = ifx in_len < s.batch_size then in_len else s.batch_size;

        silk_resampler_private_ar2(s.s_iir.data, *buf[s.fir_order], in, s.coefs, n_samples_in);

        max_index_q16 := cast,no_check(Int32) ((cast,no_check(Uint32) n_samples_in) << 16);

        out =
            silk_resampler_private_down_fir_interpol(
                out,
                buf,
                fir_coefs,
                s.fir_order,
                s.fir_fracs,
                max_index_q16,
                index_increment_q16
            );

        in += n_samples_in;
        in_len -= n_samples_in;

        if in_len > 1 {
            copy_memory(buf, *buf[n_samples_in], cast,no_check(u64) s.fir_order * size_of(Int32));
        } else {
            break;
        }
    }

    copy_memory(s.s_fir.i32.data, *buf[n_samples_in], cast,no_check(u64) s.fir_order * size_of(Int32));
}

silk_resampler_private_down_fir_interpol :: (
    out: *Int16,
    buf: *Int32,
    fir_coefs: *Int16,
    fir_order: s32,
    fir_fracs: s32,
    max_index_q16: Int32,
    index_increment_q16: Int32
) -> *Int16 {
    index_q16, res_q6: Int32 = ---;
    buf_ptr: *Int32 = ---;
    interpol_ind: Int32 = ---;
    interpol_ptr: *Int16 = ---;

    if fir_order == {
        case 18;
            index_q16 = 0;
            while index_q16 < max_index_q16 {
                buf_ptr = buf + index_q16 >> 16;

                interpol_ind =
                    cast,no_check(Int32) (((cast(Int64) (index_q16 & 0xffff)) *
                        cast,no_check(Int64) (cast,no_check(Int16) fir_fracs)) >> 16);

                interpol_ptr = *fir_coefs[(cast,no_check(Int32) ((18 / 2))) * interpol_ind];
                res_q6 = cast,no_check(Int32) (((cast(Int64) buf_ptr[0]) * cast,no_check(Int64) interpol_ptr[0]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[1]) * cast,no_check(Int64) interpol_ptr[1]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[2]) * cast,no_check(Int64) interpol_ptr[2]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[3]) * cast,no_check(Int64) interpol_ptr[3]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[4]) * cast,no_check(Int64) interpol_ptr[4]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[5]) * cast,no_check(Int64) interpol_ptr[5]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[6]) * cast,no_check(Int64) interpol_ptr[6]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[7]) * cast,no_check(Int64) interpol_ptr[7]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[8]) * cast,no_check(Int64) interpol_ptr[8]) >> 16);
                interpol_ptr = *fir_coefs[(cast,no_check(Int32) ((18 / 2))) * (fir_fracs - 1 - interpol_ind)];
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[17]) * cast,no_check(Int64) interpol_ptr[0]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[16]) * cast,no_check(Int64) interpol_ptr[1]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[15]) * cast,no_check(Int64) interpol_ptr[2]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[14]) * cast,no_check(Int64) interpol_ptr[3]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[13]) * cast,no_check(Int64) interpol_ptr[4]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[12]) * cast,no_check(Int64) interpol_ptr[5]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[11]) * cast,no_check(Int64) interpol_ptr[6]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[10]) * cast,no_check(Int64) interpol_ptr[7]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) buf_ptr[9]) * cast,no_check(Int64) interpol_ptr[8]) >> 16);

                out.* = cast,no_check(Int16) ((ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1))));
                out += 1;
                index_q16 += index_increment_q16;
            }
        case 24;
            index_q16 = 0;
            while index_q16 < max_index_q16 {
                buf_ptr = buf + index_q16 >> 16;

                res_q6 =
                    cast,no_check(Int32) (((cast(Int64) (buf_ptr[0] + buf_ptr[23])) *
                        cast,no_check(Int64) fir_coefs[0]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[1] + buf_ptr[22])) * cast,no_check(Int64) fir_coefs[1]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[2] + buf_ptr[21])) * cast,no_check(Int64) fir_coefs[2]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[3] + buf_ptr[20])) * cast,no_check(Int64) fir_coefs[3]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[4] + buf_ptr[19])) * cast,no_check(Int64) fir_coefs[4]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[5] + buf_ptr[18])) * cast,no_check(Int64) fir_coefs[5]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[6] + buf_ptr[17])) * cast,no_check(Int64) fir_coefs[6]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[7] + buf_ptr[16])) * cast,no_check(Int64) fir_coefs[7]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[8] + buf_ptr[15])) * cast,no_check(Int64) fir_coefs[8]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[9] + buf_ptr[14])) * cast,no_check(Int64) fir_coefs[9]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[10] + buf_ptr[13])) * cast,no_check(Int64) fir_coefs[10]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[11] + buf_ptr[12])) * cast,no_check(Int64) fir_coefs[11]) >> 16);

                out.* = cast,no_check(Int16) ((ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1))));
                out += 1;
                index_q16 += index_increment_q16;
            }
        case 36;
            index_q16 = 0;
            while index_q16 < max_index_q16 {
                buf_ptr = buf + index_q16 >> 16;

                res_q6 =
                    cast,no_check(Int32) (((cast(Int64) (buf_ptr[0] + buf_ptr[35])) *
                        cast,no_check(Int64) fir_coefs[0]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[1] + buf_ptr[34])) * cast,no_check(Int64) fir_coefs[1]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[2] + buf_ptr[33])) * cast,no_check(Int64) fir_coefs[2]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[3] + buf_ptr[32])) * cast,no_check(Int64) fir_coefs[3]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[4] + buf_ptr[31])) * cast,no_check(Int64) fir_coefs[4]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[5] + buf_ptr[30])) * cast,no_check(Int64) fir_coefs[5]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[6] + buf_ptr[29])) * cast,no_check(Int64) fir_coefs[6]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[7] + buf_ptr[28])) * cast,no_check(Int64) fir_coefs[7]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[8] + buf_ptr[27])) * cast,no_check(Int64) fir_coefs[8]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[9] + buf_ptr[26])) * cast,no_check(Int64) fir_coefs[9]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[10] + buf_ptr[25])) * cast,no_check(Int64) fir_coefs[10]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[11] + buf_ptr[24])) * cast,no_check(Int64) fir_coefs[11]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[12] + buf_ptr[23])) * cast,no_check(Int64) fir_coefs[12]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[13] + buf_ptr[22])) * cast,no_check(Int64) fir_coefs[13]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[14] + buf_ptr[21])) * cast,no_check(Int64) fir_coefs[14]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[15] + buf_ptr[20])) * cast,no_check(Int64) fir_coefs[15]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[16] + buf_ptr[19])) * cast,no_check(Int64) fir_coefs[16]) >> 16);
                res_q6 =
                    cast,no_check(Int32) ((cast(Int64) res_q6) +
                        ((cast(Int64) (buf_ptr[17] + buf_ptr[18])) * cast,no_check(Int64) fir_coefs[17]) >> 16);

                out.* = cast,no_check(Int16) ((ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1))));
                out += 1;
                index_q16 += index_increment_q16;
            }
        case;
    }
    return out;
}

false__in_resampler_private_down_fir :: () -> s32 {
    return 0;
}

globals_initialization_state_for_resampler_private_down_fir: u32;
initialize_globals_for_resampler_private_down_fir :: () {
    {
        state := atomic_load(*globals_initialization_state_for_resampler_private_down_fir);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_resampler_private_down_fir, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_resampler_private_down_fir) != 2 {}
            return;
        }
    }
    SILK_RESAMPLER_DOWN2_0_in_resampler_private_down_fir = 9872;
    SILK_RESAMPLER_DOWN2_1_in_resampler_private_down_fir = cast,no_check(Int16) (39809 - 65536);
    SILK_RESAMPLER_UP2_HQ_0_in_resampler_private_down_fir = Int16.[ 1746, 14986, cast,no_check(Int16) (39083 - 65536) ];
    SILK_RESAMPLER_UP2_HQ_1_in_resampler_private_down_fir = Int16.[ 6854, 25769, cast,no_check(Int16) (55542 - 65536) ];
    atomic_store(*globals_initialization_state_for_resampler_private_down_fir, 2);
}

