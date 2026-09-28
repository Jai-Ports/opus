// Generated directly from C by cpp_transpiler.
silk_clz16_in_decode_pitch :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decode_pitch :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decode_pitch :: () -> s32 {
    return 0;
}

silk_decode_pitch :: (lag_index: Int16, contour_index: Int8, pitch_lags: *s32, FS_K_HZ: s32, NB_SUBFR: s32) {
    cbk_size: s32 = ---;
    lag_cb_ptr: *Int8 = ---;

    if FS_K_HZ == 8 {
        if NB_SUBFR == 4 {
            lag_cb_ptr = SILK_CB_LAGS_STAGE2[0].data + 0;
            cbk_size = 11;
        } else {
            (NB_SUBFR == (cast(s32) 4) >> 1);
            lag_cb_ptr = SILK_CB_LAGS_STAGE2_10_MS[0].data + 0;
            cbk_size = 3;
        }
    } else if NB_SUBFR == 4 {
        lag_cb_ptr = SILK_CB_LAGS_STAGE3[0].data + 0;
        cbk_size = 34;
    } else {
        (NB_SUBFR == (cast(s32) 4) >> 1);
        lag_cb_ptr = SILK_CB_LAGS_STAGE3_10_MS[0].data + 0;
        cbk_size = 12;
    }

    min_lag := (cast,no_check(Int32) (cast(Int16) 2)) * cast,no_check(Int32) (cast,no_check(Int16) FS_K_HZ);
    max_lag := (cast,no_check(Int32) (cast(Int16) 18)) * cast,no_check(Int32) (cast,no_check(Int16) FS_K_HZ);
    lag := min_lag + cast(s32) lag_index;

    if 0 < NB_SUBFR {
        for k: 0..NB_SUBFR - 1 {
            pitch_lags[k] = lag + cast(s32) ((lag_cb_ptr + (k * cbk_size + cast(s32) contour_index)).*);
            pitch_lags[k] =
                ifx min_lag > max_lag then (ifx pitch_lags[k] > min_lag then min_lag else (ifx pitch_lags[k] < max_lag then max_lag else pitch_lags[k])) else (ifx pitch_lags[k] > max_lag then max_lag else (ifx pitch_lags[k] < min_lag then min_lag else pitch_lags[k]));
        }
    }
}

silk_ror32_in_decode_pitch :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decode_pitch :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decode_pitch :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decode_pitch :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decode_pitch :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decode_pitch :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decode_pitch :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decode_pitch :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decode_pitch :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decode_pitch :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decode_pitch(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decode_pitch(in_upper);
    }
}

silk_clz_frac_in_decode_pitch :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decode_pitch(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decode_pitch(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decode_pitch :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decode_pitch(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decode_pitch :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decode_pitch((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decode_pitch((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decode_pitch :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decode_pitch((ifx B32 > 0 then B32 else -B32)) - 1;
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

