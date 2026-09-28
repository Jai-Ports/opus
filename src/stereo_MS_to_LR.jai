// Generated directly from C by cpp_transpiler.
silk_clz16_in_stereo_ms_to_lr :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_stereo_ms_to_lr :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_stereo_ms_to_lr :: () -> s32 {
    return 0;
}

silk_ror32_in_stereo_ms_to_lr :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_stereo_ms_to_lr :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_stereo_ms_to_lr :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_stereo_ms_to_lr :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_stereo_ms_to_lr :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_stereo_ms_to_lr :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_stereo_ms_to_lr :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_stereo_ms_to_lr :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_stereo_ms_to_lr :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_stereo_ms_to_lr :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_stereo_ms_to_lr(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_stereo_ms_to_lr(in_upper);
    }
}

silk_clz_frac_in_stereo_ms_to_lr :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_stereo_ms_to_lr(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_stereo_ms_to_lr(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_stereo_ms_to_lr :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_stereo_ms_to_lr(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_stereo_ms_to_lr :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_stereo_ms_to_lr((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_stereo_ms_to_lr((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_stereo_ms_to_lr :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_stereo_ms_to_lr((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_stereo_ms_to_lr :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_stereo_ms_to_lr :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_stereo_ms_to_lr :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_stereo_ms_to_lr :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_stereo_ms_to_lr :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_stereo_ms_to_lr :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_stereo_ms_to_lr :: (
    state: *Stereo_Dec_State,
    x1: *Int16,
    x2: *Int16,
    pred_q13: *Int32,
    fs_k_hz: s32,
    frame_length: s32
) {
    sum: Int32 = ---;

    copy_memory(x1, state.s_mid.data, cast(u64) 2 * size_of(Int16));
    copy_memory(x2, state.s_side.data, cast(u64) 2 * size_of(Int16));
    copy_memory(state.s_mid.data, *x1[frame_length], cast(u64) 2 * size_of(Int16));
    copy_memory(state.s_side.data, *x2[frame_length], cast(u64) 2 * size_of(Int16));

    pred0_q13 := cast,no_check(Int32) state.pred_prev_q13[0];
    pred1_q13 := cast,no_check(Int32) state.pred_prev_q13[1];
    denom_q16 := (cast,no_check(Int32) (((cast(s32) 1) << 16))) / (8 * fs_k_hz);
    delta0_q13 :=
        (ifx 16 == 1 then (((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> 1) +
            ((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) & 1 else ((((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[0] - cast(Int32) state.pred_prev_q13[0]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> (((16 - 1)) & 31)) + 1) >> 1);
    delta1_q13 :=
        (ifx 16 == 1 then (((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> 1) +
            ((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) & 1 else ((((cast,no_check(Int32) (cast,no_check(Int16) (pred_q13[1] - cast(Int32) state.pred_prev_q13[1]))) * cast,no_check(Int32) (cast,no_check(Int16) denom_q16)) >> (((16 - 1)) & 31)) + 1) >> 1);
    n: s32 = 0;
    while n < 8 * fs_k_hz {
        pred0_q13 = cast,no_check(Int32) (pred0_q13 + delta0_q13);
        pred1_q13 = cast,no_check(Int32) (pred1_q13 + delta1_q13);
        sum =
            cast,no_check(Int32) ((cast,no_check(Uint32) (((cast(Int32) x1[n]) + cast,no_check(Int32) x1[n + 2]) +
                cast,no_check(Int32) ((cast,no_check(Uint32) x1[n + 1]) << 1))) << 9);
        sum =
            cast,no_check(Int32) ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) x2[n + 1])) << 8))) +
                ((cast(Int64) sum) * cast,no_check(Int64) (cast,no_check(Int16) pred0_q13)) >> 16);
        sum =
            cast,no_check(Int32) ((cast(Int64) sum) +
                ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) x1[n + 1])) << 11))) * cast,no_check(Int64) (cast,no_check(Int16) pred1_q13)) >> 16);
        x2[n + 1] =
            cast,no_check(Int16) ((ifx (ifx 8 == 1 then sum >> 1 +
                sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1))));
        n += 1;
    }
    pred0_q13 = pred_q13[0];
    pred1_q13 = pred_q13[1];
    n = 8 * fs_k_hz;
    while n < frame_length {
        sum =
            cast,no_check(Int32) ((cast,no_check(Uint32) (((cast(Int32) x1[n]) + cast,no_check(Int32) x1[n + 2]) +
                cast,no_check(Int32) ((cast,no_check(Uint32) x1[n + 1]) << 1))) << 9);
        sum =
            cast,no_check(Int32) ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) x2[n + 1])) << 8))) +
                ((cast(Int64) sum) * cast,no_check(Int64) (cast,no_check(Int16) pred0_q13)) >> 16);
        sum =
            cast,no_check(Int32) ((cast(Int64) sum) +
                ((cast(Int64) (cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) x1[n + 1])) << 11))) * cast,no_check(Int64) (cast,no_check(Int16) pred1_q13)) >> 16);
        x2[n + 1] =
            cast,no_check(Int16) ((ifx (ifx 8 == 1 then sum >> 1 +
                sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) > 0x7fff then 0x7fff else (ifx (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else (ifx 8 == 1 then sum >> 1 + sum & 1 else (sum >> (((8 - 1)) & 31) + 1) >> 1))));
        n += 1;
    }
    state.pred_prev_q13[0] = cast,no_check(Int16) pred_q13[0];
    state.pred_prev_q13[1] = cast,no_check(Int16) pred_q13[1];

    n = 0;
    while n < frame_length {
        sum = (cast(Int32) x1[n + 1]) + cast,no_check(Int32) x2[n + 1];
        diff := (cast(Int32) x1[n + 1]) - cast,no_check(Int32) x2[n + 1];
        x1[n + 1] =
            cast,no_check(Int16) ((ifx sum > 0x7fff then 0x7fff else (ifx sum < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else sum)));
        x2[n + 1] =
            cast,no_check(Int16) ((ifx diff > 0x7fff then 0x7fff else (ifx diff < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else diff)));
        n += 1;
    }
}

