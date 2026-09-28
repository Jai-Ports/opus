// Generated directly from C by cpp_transpiler.
SILK_RESAMPLER_DOWN2_0_in_resampler_private_iir_fir: Int16;

SILK_RESAMPLER_DOWN2_1_in_resampler_private_iir_fir: Int16;

SILK_RESAMPLER_UP2_HQ_0_in_resampler_private_iir_fir: [3] Int16;

SILK_RESAMPLER_UP2_HQ_1_in_resampler_private_iir_fir: [3] Int16;

silk_clz16_in_resampler_private_iir_fir :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_resampler_private_iir_fir :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_resampler_private_iir_fir :: () -> s32 {
    return 0;
}

silk_ror32_in_resampler_private_iir_fir :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_resampler_private_iir_fir :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_resampler_private_iir_fir :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_resampler_private_iir_fir :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_resampler_private_iir_fir :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_resampler_private_iir_fir :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_resampler_private_iir_fir :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_resampler_private_iir_fir :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_resampler_private_iir_fir :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_resampler_private_iir_fir :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_resampler_private_iir_fir(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_resampler_private_iir_fir(in_upper);
    }
}

silk_clz_frac_in_resampler_private_iir_fir :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_resampler_private_iir_fir(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_resampler_private_iir_fir(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_resampler_private_iir_fir :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_resampler_private_iir_fir(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_resampler_private_iir_fir :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_resampler_private_iir_fir((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_resampler_private_iir_fir((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_resampler_private_iir_fir :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_resampler_private_iir_fir((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_resampler_private_iir_fir :: (ss: *void, out: *Int16, in: *Int16, in_len: Int32) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    s := cast(*Silk_Resampler_State_Struct) ss;
    n_samples_in: Int32 = ---;

    buf := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) (2 * s.batch_size + 8))));

    copy_memory(buf, s.s_fir.i16.data, cast(u64) 8 * size_of(Int16));

    index_increment_q16 := s.inv_ratio_q16;
    while ((cast(s32) 1) != 0) {
        n_samples_in = ifx in_len < s.batch_size then in_len else s.batch_size;

        silk_resampler_private_up2_hq(s.s_iir.data, *buf[8], in, n_samples_in);

        max_index_q16 := cast,no_check(Int32) ((cast,no_check(Uint32) n_samples_in) << (((16 + 1)) & 31));
        out = silk_resampler_private_iir_fir_interpol(out, buf, max_index_q16, index_increment_q16);
        in += n_samples_in;
        in_len -= n_samples_in;

        if in_len > 0 {
            copy_memory(buf, *buf[n_samples_in << 1], cast(u64) 8 * size_of(Int16));
        } else {
            break;
        }
    }

    copy_memory(s.s_fir.i16.data, *buf[n_samples_in << 1], cast(u64) 8 * size_of(Int16));
}

silk_resampler_private_iir_fir_interpol :: (
    out: *Int16,
    buf: *Int16,
    max_index_q16: Int32,
    index_increment_q16: Int32
) -> *Int16 {
    index_q16: Int32 = 0;
    while index_q16 < max_index_q16 {
        table_index :=
            cast,no_check(Int32) (((cast(Int64) (index_q16 & 0xffff)) *
                cast,no_check(Int64) (cast(Int16) 12)) >> 16);
        buf_ptr := *buf[index_q16 >> 16];

        res_q15 := (cast,no_check(Int32) buf_ptr[0]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[table_index][0];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[1]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[table_index][1];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[2]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[table_index][2];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[3]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[table_index][3];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[4]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[11 - table_index][3];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[5]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[11 - table_index][2];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[6]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[11 - table_index][1];
        res_q15 =
            res_q15 +
                (cast,no_check(Int32) buf_ptr[7]) * cast,no_check(Int32) SILK_RESAMPLER_FRAC_FIR_12[11 - table_index][0];
        out.* = cast,no_check(Int16) ((ifx (ifx 15 == 1 then res_q15 >> 1 + res_q15 & 1 else (res_q15 >> (((15 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 15 == 1 then res_q15 >> 1 + res_q15 & 1 else (res_q15 >> (((15 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 15 == 1 then res_q15 >> 1 + res_q15 & 1 else (res_q15 >> (((15 - 1)) & 31) + 1) >> 1))));
        out += 1;
        index_q16 += index_increment_q16;
    }
    return out;
}

false__in_resampler_private_iir_fir :: () -> s32 {
    return 0;
}

globals_initialization_state_for_resampler_private_iir_fir: u32;
initialize_globals_for_resampler_private_iir_fir :: () {
    {
        state := atomic_load(*globals_initialization_state_for_resampler_private_iir_fir);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_resampler_private_iir_fir, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_resampler_private_iir_fir) != 2 {}
            return;
        }
    }
    SILK_RESAMPLER_DOWN2_0_in_resampler_private_iir_fir = 9872;
    SILK_RESAMPLER_DOWN2_1_in_resampler_private_iir_fir = cast,no_check(Int16) (39809 - 65536);
    SILK_RESAMPLER_UP2_HQ_0_in_resampler_private_iir_fir = Int16.[ 1746, 14986, cast,no_check(Int16) (39083 - 65536) ];
    SILK_RESAMPLER_UP2_HQ_1_in_resampler_private_iir_fir = Int16.[ 6854, 25769, cast,no_check(Int16) (55542 - 65536) ];
    atomic_store(*globals_initialization_state_for_resampler_private_iir_fir, 2);
}

