// Generated directly from C by cpp_transpiler.
silk_clz16_in_encode_pulses :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_encode_pulses :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_encode_pulses :: () -> s32 {
    return 0;
}

silk_ror32_in_encode_pulses :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_encode_pulses :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_encode_pulses :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_encode_pulses :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_encode_pulses :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_encode_pulses :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_encode_pulses :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_encode_pulses :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_encode_pulses :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_encode_pulses :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_encode_pulses(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_encode_pulses(in_upper);
    }
}

silk_clz_frac_in_encode_pulses :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_encode_pulses(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_encode_pulses(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_encode_pulses :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_encode_pulses(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_encode_pulses :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_encode_pulses((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_encode_pulses((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_encode_pulses :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_encode_pulses((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_encode_pulses :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_encode_pulses :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_encode_pulses :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_encode_pulses :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_encode_pulses :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_encode_pulses :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_encode_pulses :: (
    ps_range_enc: *Ec_Enc,
    SIGNAL_TYPE: s32,
    QUANT_OFFSET_TYPE: s32,
    pulses: *Int8,
    FRAME_LENGTH: s32
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    k: s32 = ---;
    j: s32 = ---;
    bit: s32 = ---;
    n_ls: s32 = ---;
    scale_down: s32 = ---;
    rate_level_index: s32 = 0;
    abs_q: Int32 = ---;

    pulses_comb: [8] s32 = ---;

    pulses_ptr: *Int8 = ---;

    fill_memory(pulses_comb.data, 0, cast(u64) 8 * size_of(s32));

    ((cast(s32) 1) << 4 == 16);
    iter := FRAME_LENGTH >> 4;
    if iter * 16 < FRAME_LENGTH {
        (FRAME_LENGTH == 12 * 10);
        iter += 1;
        fill_memory(*pulses[FRAME_LENGTH], 0, 16);
    }

    abs_pulses := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) (iter * 16))));
    (16 & 3 == 0);
    i: s32 = 0;
    while i < iter * 16 {
        abs_pulses[i + 0] =
            ifx pulses[i + 0] > 0 then cast,no_check(s32) pulses[i +
                0] else -(cast,no_check(s32) pulses[i + 0]);
        abs_pulses[i + 1] =
            ifx pulses[i + 1] > 0 then cast,no_check(s32) pulses[i +
                1] else -(cast,no_check(s32) pulses[i + 1]);
        abs_pulses[i + 2] =
            ifx pulses[i + 2] > 0 then cast,no_check(s32) pulses[i +
                2] else -(cast,no_check(s32) pulses[i + 2]);
        abs_pulses[i + 3] =
            ifx pulses[i + 3] > 0 then cast,no_check(s32) pulses[i +
                3] else -(cast,no_check(s32) pulses[i + 3]);
        i += 4;
    }

    sum_pulses := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) iter)));
    n_rshifts := cast(*s32) c_transpiler_alloca(cast(u64) ((size_of(s32) * cast,no_check(u64) iter)));
    abs_pulses_ptr := abs_pulses;
    i = 0;
    while i < iter {
        n_rshifts[i] = 0;

        while ((cast(s32) 1) != 0) {
            scale_down =
                combine_and_check(
                    pulses_comb.data,
                    abs_pulses_ptr,
                    cast,no_check(s32) SILK_MAX_PULSES_TABLE[0],
                    8
                );

            scale_down +=
                combine_and_check(
                    pulses_comb.data,
                    pulses_comb.data,
                    cast,no_check(s32) SILK_MAX_PULSES_TABLE[1],
                    4
                );

            scale_down +=
                combine_and_check(
                    pulses_comb.data,
                    pulses_comb.data,
                    cast,no_check(s32) SILK_MAX_PULSES_TABLE[2],
                    2
                );

            scale_down +=
                combine_and_check(
                    *sum_pulses[i],
                    pulses_comb.data,
                    cast,no_check(s32) SILK_MAX_PULSES_TABLE[3],
                    1
                );

            if scale_down != 0 {
                n_rshifts[i] += 1;
                k = 0;
                while k < 16 {
                    abs_pulses_ptr[k] = abs_pulses_ptr[k] >> 1;
                    k += 1;
                }
            } else {
                break;
            }
        }
        abs_pulses_ptr += 16;
        i += 1;
    }

    min_sum_bits_q5: Int32 = 0x7fffffff;
    k = 0;
    while k < 10 - 1 {
        n_bits_ptr := SILK_PULSES_PER_BLOCK_BITS_Q5[k].data;
        sum_bits_q5 := cast,no_check(Int32) SILK_RATE_LEVELS_BITS_Q5[SIGNAL_TYPE >> 1][k];
        i = 0;
        while i < iter {
            if n_rshifts[i] > 0 {
                sum_bits_q5 = cast,no_check(Int32) (sum_bits_q5 + cast,no_check(s32) n_bits_ptr[16 + 1]);
            } else {
                sum_bits_q5 = cast,no_check(Int32) (sum_bits_q5 + cast,no_check(s32) n_bits_ptr[sum_pulses[i]]);
            }
            i += 1;
        }
        if sum_bits_q5 < min_sum_bits_q5 {
            min_sum_bits_q5 = sum_bits_q5;
            rate_level_index = k;
        }
        k += 1;
    }
    ec_enc_icdf(ps_range_enc, rate_level_index, SILK_RATE_LEVELS_I_CDF[SIGNAL_TYPE >> 1].data, 8);

    cdf_ptr := SILK_PULSES_PER_BLOCK_I_CDF[rate_level_index].data;
    i = 0;
    while i < iter {
        if n_rshifts[i] == 0 {
            ec_enc_icdf(ps_range_enc, sum_pulses[i], cdf_ptr, 8);
        } else {
            ec_enc_icdf(ps_range_enc, cast,no_check(s32) (16 + 1), cdf_ptr, 8);
            k = 0;
            while k < n_rshifts[i] - 1 {
                ec_enc_icdf(ps_range_enc, cast,no_check(s32) (16 + 1), SILK_PULSES_PER_BLOCK_I_CDF[10 - 1].data, 8);
                k += 1;
            }
            ec_enc_icdf(ps_range_enc, sum_pulses[i], SILK_PULSES_PER_BLOCK_I_CDF[10 - 1].data, 8);
        }
        i += 1;
    }

    i = 0;
    while i < iter {
        if sum_pulses[i] > 0 {
            silk_shell_encoder(ps_range_enc, *abs_pulses[i * 16]);
        }
        i += 1;
    }

    i = 0;
    while i < iter {
        if n_rshifts[i] > 0 {
            pulses_ptr = *pulses[i * 16];
            n_ls = n_rshifts[i] - 1;
            k = 0;
            while k < 16 {
                abs_q =
                    cast,no_check(Int32) (cast,no_check(Int8) ((ifx pulses_ptr[k] > 0 then cast,no_check(s32) pulses_ptr[k] else -(cast,no_check(s32) pulses_ptr[k]))));
                j = n_ls;
                while j > 0 {
                    bit = abs_q >> ((j) & 31) & 1;
                    ec_enc_icdf(ps_range_enc, bit, SILK_LSB_I_CDF.data, 8);
                    j -= 1;
                }
                bit = abs_q & 1;
                ec_enc_icdf(ps_range_enc, bit, SILK_LSB_I_CDF.data, 8);
                k += 1;
            }
        }
        i += 1;
    }

    silk_encode_signs(ps_range_enc, pulses, FRAME_LENGTH, SIGNAL_TYPE, QUANT_OFFSET_TYPE, sum_pulses);
}

combine_and_check :: (pulses_comb: *s32, pulses_in: *s32, max_pulses: s32, len: s32) -> s32 {
    if 0 < len {
        for k: 0..len - 1 {
            sum := pulses_in[2 * k] + pulses_in[2 * k + 1];
            if sum > max_pulses {
                return 1;
            }
            pulses_comb[k] = sum;
        }
    }

    return 0;
}

false__in_encode_pulses :: () -> s32 {
    return 0;
}

