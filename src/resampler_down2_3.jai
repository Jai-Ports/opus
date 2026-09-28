SILK_RESAMPLER_DOWN2_0_storage: Int16;

SILK_RESAMPLER_DOWN2_1_storage: Int16;

SILK_RESAMPLER_UP2_HQ_0_storage: [3] Int16;

SILK_RESAMPLER_UP2_HQ_1_storage: [3] Int16;

silk_clz16_in_resampler_down2_3 :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_resampler_down2_3 :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_resampler_down2_3 :: () -> s32 {
    return 0;
}

silk_resampler_down2_3 :: (s: *Int32, out: *Int16, in: *Int16, in_len: Int32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    n_samples_in: Int32 = ---;
    res_q6: Int32 = ---;

    buf :=
        cast(*Int32) c_transpiler_alloca(cast(u64) ((size_of(Int32) *
            cast,no_check(u64) ((cast,no_check(s32) ((10 * 48))) + 4))));

    copy_memory(buf, s, cast(u64) 4 * size_of(Int32));

    while ((cast(s32) 1) != 0) {
        n_samples_in = ifx in_len < 10 * 48 then in_len else cast,no_check(Int32) ((10 * 48));

        silk_resampler_private_ar2(*s[4], *buf[4], in, SILK_RESAMPLER_2_3_COEFS_LQ.data, n_samples_in);

        buf_ptr := buf;
        counter := n_samples_in;
        while counter > 2 {
            res_q6 =
                cast,no_check(Int32) (((cast(Int64) buf_ptr[0]) *
                    cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[2]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[1]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[3]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[2]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[5]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[3]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[4]) >> 16);

            out.* = cast,no_check(Int16) ((ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1))));
            out += 1;

            res_q6 =
                cast,no_check(Int32) (((cast(Int64) buf_ptr[1]) *
                    cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[4]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[2]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[5]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[3]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[3]) >> 16);
            res_q6 =
                cast,no_check(Int32) ((cast(Int64) res_q6) +
                    ((cast(Int64) buf_ptr[4]) * cast,no_check(Int64) SILK_RESAMPLER_2_3_COEFS_LQ[2]) >> 16);

            out.* = cast,no_check(Int16) ((ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 6 == 1 then res_q6 >> 1 + res_q6 & 1 else (res_q6 >> (((6 - 1)) & 31) + 1) >> 1))));
            out += 1;

            buf_ptr += 3;
            counter = cast,no_check(Int32) (counter - 3);
        }

        in += n_samples_in;
        in_len -= n_samples_in;

        if in_len > 0 {
            copy_memory(buf, *buf[n_samples_in], cast(u64) 4 * size_of(Int32));
        } else {
            break;
        }
    }

    copy_memory(s, *buf[n_samples_in], cast(u64) 4 * size_of(Int32));
}

silk_ror32_in_resampler_down2_3 :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_resampler_down2_3 :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_resampler_down2_3 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_resampler_down2_3 :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_resampler_down2_3 :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_resampler_down2_3 :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_resampler_down2_3 :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_resampler_down2_3 :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_resampler_down2_3 :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_resampler_down2_3 :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_resampler_down2_3(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_resampler_down2_3(in_upper);
    }
}

silk_clz_frac_in_resampler_down2_3 :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_resampler_down2_3(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_resampler_down2_3(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_resampler_down2_3 :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_resampler_down2_3(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_resampler_down2_3 :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_resampler_down2_3((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_resampler_down2_3((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_resampler_down2_3 :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_resampler_down2_3((ifx B32 > 0 then B32 else -B32)) - 1;
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

false__in_resampler_down2_3 :: () -> s32 {
    return 0;
}

globals_initialization_state_for_resampler_down2_3: u32;
initialize_globals_for_resampler_down2_3 :: () {
    {
        state := atomic_load(*globals_initialization_state_for_resampler_down2_3);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_resampler_down2_3, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_resampler_down2_3) != 2 {}
            return;
        }
    }
    SILK_RESAMPLER_DOWN2_0_storage = 9872;
    SILK_RESAMPLER_DOWN2_1_storage = cast,no_check(Int16) (39809 - 65536);
    SILK_RESAMPLER_UP2_HQ_0_storage = Int16.[ 1746, 14986, cast,no_check(Int16) (39083 - 65536) ];
    SILK_RESAMPLER_UP2_HQ_1_storage = Int16.[ 6854, 25769, cast,no_check(Int16) (55542 - 65536) ];
    atomic_store(*globals_initialization_state_for_resampler_down2_3, 2);
}

