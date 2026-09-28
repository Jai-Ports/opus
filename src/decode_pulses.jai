silk_clz16_in_decode_pulses :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decode_pulses :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decode_pulses :: () -> s32 {
    return 0;
}

silk_ror32_in_decode_pulses :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decode_pulses :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decode_pulses :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decode_pulses :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decode_pulses :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decode_pulses :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decode_pulses :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decode_pulses :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decode_pulses :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decode_pulses :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decode_pulses(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decode_pulses(in_upper);
    }
}

silk_clz_frac_in_decode_pulses :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decode_pulses(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decode_pulses(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decode_pulses :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decode_pulses(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decode_pulses :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decode_pulses((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decode_pulses((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decode_pulses :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decode_pulses((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_decode_pulses :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_decode_pulses :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_decode_pulses :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_decode_pulses :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_decode_pulses :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_decode_pulses :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_decode_pulses :: (
    ps_range_dec: *Ec_Dec,
    pulses: *Int16,
    SIGNAL_TYPE: s32,
    QUANT_OFFSET_TYPE: s32,
    FRAME_LENGTH: s32
) {
    j: s32 = ---;
    k: s32 = ---;
    abs_q: s32 = ---;
    n_ls: s32 = ---;
    sum_pulses, n_lshifts: [20] s32 = ---;
    pulses_ptr: *Int16 = ---;

    rate_level_index := ec_dec_icdf(ps_range_dec, SILK_RATE_LEVELS_I_CDF[SIGNAL_TYPE >> 1].data, 8);

    ((cast(s32) 1) << 4 == 16);
    iter := FRAME_LENGTH >> 4;
    if iter * 16 < FRAME_LENGTH {
        (FRAME_LENGTH == 12 * 10);
        iter += 1;
    }

    cdf_ptr := SILK_PULSES_PER_BLOCK_I_CDF[rate_level_index].data;
    if 0 < iter {
        for i: 0..iter - 1 {
            n_lshifts[i] = 0;
            sum_pulses[i] = ec_dec_icdf(ps_range_dec, cdf_ptr, 8);

            while sum_pulses[i] == 16 + 1 {
                n_lshifts[i] += 1;

                sum_pulses[i] =
                    ec_dec_icdf(
                        ps_range_dec,
                        SILK_PULSES_PER_BLOCK_I_CDF[10 - 1].data + cast(s32) ((n_lshifts[i] == 10)),
                        8
                    );
            }
        }
    }

    if 0 < iter {
        for i: 0..iter - 1 {
            if sum_pulses[i] > 0 {
                silk_shell_decoder(
                    *pulses[(cast,no_check(Int32) (cast,no_check(Int16) i)) * cast,no_check(Int32) (cast(Int16) 16)],
                    ps_range_dec,
                    sum_pulses[i]
                );
            } else {
                fill_memory(
                    *pulses[(cast,no_check(Int32) (cast,no_check(Int16) i)) * cast,no_check(Int32) (cast(Int16) 16)],
                    0,
                    cast(u64) 16 * size_of(Int16)
                );
            }
        }
    }

    if 0 < iter {
        for i: 0..iter - 1 {
            if n_lshifts[i] > 0 {
                n_ls = n_lshifts[i];
                pulses_ptr =
                    *pulses[(cast,no_check(Int32) (cast,no_check(Int16) i)) *
                        cast,no_check(Int32) (cast(Int16) 16)];
                k = 0;
                while k < 16 {
                    abs_q = cast,no_check(s32) pulses_ptr[k];
                    j = 0;
                    while j < n_ls {
                        abs_q = cast,no_check(Int32) ((cast,no_check(Uint32) abs_q) << 1);
                        abs_q += ec_dec_icdf(ps_range_dec, SILK_LSB_I_CDF.data, 8);
                        j += 1;
                    }
                    pulses_ptr[k] = cast,no_check(Int16) abs_q;
                    k += 1;
                }

                sum_pulses[i] |= n_ls << 5;
            }
        }
    }

    silk_decode_signs(ps_range_dec, pulses, FRAME_LENGTH, SIGNAL_TYPE, QUANT_OFFSET_TYPE, sum_pulses.data);
}

