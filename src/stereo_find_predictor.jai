silk_clz16_in_stereo_find_predictor :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_stereo_find_predictor :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_stereo_find_predictor :: () -> s32 {
    return 0;
}

silk_ror32_in_stereo_find_predictor :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_stereo_find_predictor :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_stereo_find_predictor :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_stereo_find_predictor :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_stereo_find_predictor :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_stereo_find_predictor :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_stereo_find_predictor :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_stereo_find_predictor :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_stereo_find_predictor :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_stereo_find_predictor :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_stereo_find_predictor(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_stereo_find_predictor(in_upper);
    }
}

silk_clz_frac_in_stereo_find_predictor :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_stereo_find_predictor(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_stereo_find_predictor(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_stereo_find_predictor :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_stereo_find_predictor(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_stereo_find_predictor :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_stereo_find_predictor((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_stereo_find_predictor((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_stereo_find_predictor :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_stereo_find_predictor((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_stereo_find_predictor :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_stereo_find_predictor :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_stereo_find_predictor :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_stereo_find_predictor :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_stereo_find_predictor :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_stereo_find_predictor :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_stereo_find_predictor :: (
    ratio_q14: *Int32,
    x: *Int16,
    y: *Int16,
    mid_res_amp_q0: *Int32,
    length: s32,
    smooth_coef_q16: s32
) -> Int32 {
    scale1: s32 = ---;
    scale2: s32 = ---;
    nrgx: Int32 = ---;
    nrgy: Int32 = ---;

    silk_sum_sqr_shift(*nrgx, *scale1, x, length);
    silk_sum_sqr_shift(*nrgy, *scale2, y, length);
    scale := silk_max_int_in_stereo_find_predictor(scale1, scale2);
    scale = scale + scale & 1;
    nrgy = nrgy >> (((scale - scale2)) & 31);
    nrgx = nrgx >> (((scale - scale1)) & 31);
    nrgx = silk_max_int_in_stereo_find_predictor(nrgx, 1);
    corr := silk_inner_prod_aligned_scale(x, y, scale, length);
    pred_q13 := silk_div32_var_q_in_stereo_find_predictor(corr, nrgx, 13);
    pred_q13 =
        ifx -((cast(s32) 1) << 14) > (cast(s32) 1) << 14 then (ifx pred_q13 > -((cast(s32) 1) << 14) then cast,no_check(Int32) (-((cast(s32) 1) << 14)) else (ifx pred_q13 < (cast(s32) 1) << 14 then cast,no_check(Int32) (((cast(s32) 1) << 14)) else pred_q13)) else (ifx pred_q13 > (cast(s32) 1) << 14 then cast,no_check(Int32) (((cast(s32) 1) << 14)) else (ifx pred_q13 < -((cast(s32) 1) << 14) then cast,no_check(Int32) (-((cast(s32) 1) << 14)) else pred_q13));
    pred2_q10 :=
        cast,no_check(Int32) (((cast(Int64) pred_q13) *
            cast,no_check(Int64) (cast,no_check(Int16) pred_q13)) >> 16);

    smooth_coef_q16 =
        silk_max_int_in_stereo_find_predictor(
            smooth_coef_q16,
            (ifx pred2_q10 > 0 then pred2_q10 else -pred2_q10)
        );

    scale = scale >> 1;
    mid_res_amp_q0[0] =
        cast,no_check(Int32) ((cast(Int64) mid_res_amp_q0[0]) +
            ((cast(Int64) ((cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx_in_stereo_find_predictor(nrgx)) << ((scale) & 31))) - mid_res_amp_q0[0])) * cast,no_check(Int64) (cast,no_check(Int16) smooth_coef_q16)) >> 16);

    nrgy =
        nrgy -
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast(Int64) corr) * cast,no_check(Int64) (cast,no_check(Int16) pred_q13)) >> 16))) << (((3 + 1)) & 31));
    nrgy =
        nrgy +
            cast,no_check(Int32) ((cast,no_check(Uint32) (cast,no_check(Int32) (((cast(Int64) nrgx) * cast,no_check(Int64) (cast,no_check(Int16) pred2_q10)) >> 16))) << 6);
    mid_res_amp_q0[1] =
        cast,no_check(Int32) ((cast(Int64) mid_res_amp_q0[1]) +
            ((cast(Int64) ((cast,no_check(Int32) ((cast,no_check(Uint32) silk_sqrt_approx_in_stereo_find_predictor(nrgy)) << ((scale) & 31))) - mid_res_amp_q0[1])) * cast,no_check(Int64) (cast,no_check(Int16) smooth_coef_q16)) >> 16);

    ratio_q14.* =
        silk_div32_var_q_in_stereo_find_predictor(
            mid_res_amp_q0[1],
            (ifx mid_res_amp_q0[0] > 1 then mid_res_amp_q0[0] else 1),
            14
        );
    ratio_q14.* =
        ifx 0 > 32767 then (ifx ratio_q14.* > 0 then 0 else (ifx ratio_q14.* < 32767 then 32767 else ratio_q14.*)) else (ifx ratio_q14.* > 32767 then 32767 else (ifx ratio_q14.* < 0 then 0 else ratio_q14.*));

    return pred_q13;
}

