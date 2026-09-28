// Generated directly from C by cpp_transpiler.
DELAY_MATRIX_DEC: [3] [6] Int8;

DELAY_MATRIX_ENC: [6] [3] Int8;

SILK_RESAMPLER_DOWN2_0: Int16;

SILK_RESAMPLER_DOWN2_1: Int16;

SILK_RESAMPLER_UP2_HQ_0: [3] Int16;

SILK_RESAMPLER_UP2_HQ_1: [3] Int16;

silk_clz16_in_resampler :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_resampler :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_resampler :: () -> s32 {
    return 0;
}

silk_resampler_init :: (s: *Silk_Resampler_State_Struct, fs_hz_in: Int32, fs_hz_out: Int32, for_enc: s32) -> s32 {
    fill_memory(s, 0, size_of(Silk_Resampler_State_Struct));

    if for_enc != 0 {
        if fs_hz_in != 8000 && fs_hz_in != 12000 && fs_hz_in != 16000 && fs_hz_in != 24000 && fs_hz_in != 48000 ||
            fs_hz_out != 8000 && fs_hz_out != 12000 && fs_hz_out != 16000 {
            return -1;
        }
        s.input_delay =
            cast,no_check(s32) (((DELAY_MATRIX_ENC[(ifx 5 < ((fs_hz_in >> 12 - cast(Int32) (fs_hz_in > 16000)) >> ((cast(Int32) (fs_hz_in > 24000)) & 31)) - 1 then 5 else ((fs_hz_in >> 12 - cast(Int32) (fs_hz_in > 16000)) >> ((cast(Int32) (fs_hz_in > 24000)) & 31)) - 1)]).data)[(ifx 5 < ((fs_hz_out >> 12 - cast(Int32) (fs_hz_out > 16000)) >> ((cast(Int32) (fs_hz_out > 24000)) & 31)) -
                1 then 5 else ((fs_hz_out >> 12 - cast(Int32) (fs_hz_out > 16000)) >> ((cast(Int32) (fs_hz_out > 24000)) & 31)) - 1)]);
    } else {
        if fs_hz_in != 8000 && fs_hz_in != 12000 && fs_hz_in != 16000 ||
            fs_hz_out != 8000 && fs_hz_out != 12000 && fs_hz_out != 16000 && fs_hz_out != 24000 && fs_hz_out != 48000 {
            return -1;
        }
        s.input_delay =
            cast,no_check(s32) (((DELAY_MATRIX_DEC[(ifx 5 < ((fs_hz_in >> 12 - cast(Int32) (fs_hz_in > 16000)) >> ((cast(Int32) (fs_hz_in > 24000)) & 31)) - 1 then 5 else ((fs_hz_in >> 12 - cast(Int32) (fs_hz_in > 16000)) >> ((cast(Int32) (fs_hz_in > 24000)) & 31)) - 1)]).data)[(ifx 5 < ((fs_hz_out >> 12 - cast(Int32) (fs_hz_out > 16000)) >> ((cast(Int32) (fs_hz_out > 24000)) & 31)) -
                1 then 5 else ((fs_hz_out >> 12 - cast(Int32) (fs_hz_out > 16000)) >> ((cast(Int32) (fs_hz_out > 24000)) & 31)) - 1)]);
    }

    s.fs_in_k_hz = fs_hz_in / 1000;
    s.fs_out_k_hz = fs_hz_out / 1000;

    s.batch_size = s.fs_in_k_hz * 10;

    up2x: s32 = 0;
    if fs_hz_out > fs_hz_in {
        if fs_hz_out == fs_hz_in * 2 {
            s.resampler_function = 1;
        } else {
            s.resampler_function = 2;
            up2x = 1;
        }
    } else if fs_hz_out < fs_hz_in {
        s.resampler_function = 3;
        if fs_hz_out * 4 == fs_hz_in * 3 {
            s.fir_fracs = 3;
            s.fir_order = 18;
            s.coefs = SILK_RESAMPLER_3_4_COEFS.data;
        } else if fs_hz_out * 3 == fs_hz_in * 2 {
            s.fir_fracs = 2;
            s.fir_order = 18;
            s.coefs = SILK_RESAMPLER_2_3_COEFS.data;
        } else if fs_hz_out * 2 == fs_hz_in {
            s.fir_fracs = 1;
            s.fir_order = 24;
            s.coefs = SILK_RESAMPLER_1_2_COEFS.data;
        } else if fs_hz_out * 3 == fs_hz_in {
            s.fir_fracs = 1;
            s.fir_order = 36;
            s.coefs = SILK_RESAMPLER_1_3_COEFS.data;
        } else if fs_hz_out * 4 == fs_hz_in {
            s.fir_fracs = 1;
            s.fir_order = 36;
            s.coefs = SILK_RESAMPLER_1_4_COEFS.data;
        } else if fs_hz_out * 6 == fs_hz_in {
            s.fir_fracs = 1;
            s.fir_order = 36;
            s.coefs = SILK_RESAMPLER_1_6_COEFS.data;
        } else {
            return -1;
        }
    } else {
        s.resampler_function = 0;
    }

    s.inv_ratio_q16 =
        cast,no_check(Int32) ((cast,no_check(Uint32) ((cast,no_check(Int32) ((cast,no_check(Uint32) fs_hz_in) << (((14 + up2x)) & 31))) /
            fs_hz_out)) << 2);

    while cast,no_check(Int32) (((cast,no_check(Int64) s.inv_ratio_q16) * cast(Int64) fs_hz_out) >> 16) < cast,no_check(Int32) ((cast,no_check(Uint32) fs_hz_in) << ((up2x) & 31)) {
        s.inv_ratio_q16 += 1;
    }

    return 0;
}

silk_resampler :: (s: *Silk_Resampler_State_Struct, out: *Int16, in: *Int16, in_len: Int32) -> s32 {
    (in_len >= s.fs_in_k_hz);

    (s.input_delay <= s.fs_in_k_hz);

    n_samples := s.fs_in_k_hz - s.input_delay;

    copy_memory(s.delay_buf.data + s.input_delay, in, cast,no_check(u64) n_samples * size_of(Int16));

    if s.resampler_function == {
        case 1;
            silk_resampler_private_up2_hq_wrapper(cast(*void) s, out, s.delay_buf.data, s.fs_in_k_hz);
            silk_resampler_private_up2_hq_wrapper(
                cast(*void) s,
                *out[s.fs_out_k_hz],
                *in[n_samples],
                in_len - s.fs_in_k_hz
            );
        case 2;
            silk_resampler_private_iir_fir(cast(*void) s, out, s.delay_buf.data, s.fs_in_k_hz);
            silk_resampler_private_iir_fir(cast(*void) s, *out[s.fs_out_k_hz], *in[n_samples], in_len - s.fs_in_k_hz);
        case 3;
            silk_resampler_private_down_fir(cast(*void) s, out, s.delay_buf.data, s.fs_in_k_hz);
            silk_resampler_private_down_fir(cast(*void) s, *out[s.fs_out_k_hz], *in[n_samples], in_len - s.fs_in_k_hz);
        case;
            copy_memory(out, s.delay_buf.data, cast,no_check(u64) s.fs_in_k_hz * size_of(Int16));
            copy_memory(
                *out[s.fs_out_k_hz],
                *in[n_samples],
                cast,no_check(u64) (in_len - s.fs_in_k_hz) * size_of(Int16)
            );
    }

    copy_memory(s.delay_buf.data, *in[in_len - s.input_delay], cast,no_check(u64) s.input_delay * size_of(Int16));

    return 0;
}

silk_ror32_in_resampler :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_resampler :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_resampler :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_resampler :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_resampler :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_resampler :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_resampler :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_resampler :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_resampler :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_resampler :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_resampler(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_resampler(in_upper);
    }
}

silk_clz_frac_in_resampler :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_resampler(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_resampler(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_resampler :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_resampler(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_resampler :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_resampler((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_resampler((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_resampler :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_resampler((ifx B32 > 0 then B32 else -B32)) - 1;
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

globals_initialization_state_for_resampler: u32;
initialize_globals_for_resampler :: () {
    {
        state := atomic_load(*globals_initialization_state_for_resampler);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_resampler, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_resampler) != 2 {}
            return;
        }
    }
    DELAY_MATRIX_ENC =
        [3] Int8.[
            Int8.[ 6, 0, 3 ],
            Int8.[ 0, 7, 3 ],
            Int8.[ 0, 1, 10 ],
            Int8.[ 0, 2, 6 ],
            Int8.[ 18, 10, 12 ],
            Int8.[ 0, 0, 44 ]
        ];
    DELAY_MATRIX_DEC =
        [6] Int8.[
            Int8.[ 4, 0, 2, 0, 0, 0 ],
            Int8.[ 0, 9, 4, 7, 4, 4 ],
            Int8.[ 0, 3, 12, 7, 7, 7 ]
        ];
    SILK_RESAMPLER_DOWN2_0 = 9872;
    SILK_RESAMPLER_DOWN2_1 = cast,no_check(Int16) (39809 - 65536);
    SILK_RESAMPLER_UP2_HQ_0 = Int16.[ 1746, 14986, cast,no_check(Int16) (39083 - 65536) ];
    SILK_RESAMPLER_UP2_HQ_1 = Int16.[ 6854, 25769, cast,no_check(Int16) (55542 - 65536) ];
    atomic_store(*globals_initialization_state_for_resampler, 2);
}

