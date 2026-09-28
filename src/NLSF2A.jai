// Generated directly from C by cpp_transpiler.
ORDERING10: [10] u8;

ORDERING16: [16] u8;

silk_clz16_in_nlsf2_a :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_nlsf2_a :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_nlsf2_a :: () -> s32 {
    return 0;
}

silk_nlsf2_a :: (a_q12: *Int16, nlsf: *Int16, D: s32, arch: s32) {

    cos_lsf_qa: [24] Int32 = ---;
    p, q: [13] Int32 = ---;

    a32_qa1: [24] Int32 = ---;

    (D == 10 || D == 16);

    ordering := (ifx D == 16 then ORDERING16.data else ORDERING10.data);
    k: s32 = 0;
    while k < D {
        (nlsf[k] >= 0);

        f_int := (cast(s32) nlsf[k]) >> (((15 - 7)) & 31);

        f_frac := (cast(Int32) nlsf[k]) - cast,no_check(Int32) ((cast,no_check(Uint32) f_int) << (((15 - 7)) & 31));

        cos_val := cast,no_check(Int32) SILK_LSF_COS_TAB_FIX_Q12[f_int];
        delta := (cast(Int32) SILK_LSF_COS_TAB_FIX_Q12[f_int + 1]) - cos_val;

        cos_lsf_qa[ordering[k]] =
            ifx 20 - 16 == 1 then ((cast,no_check(Int32) ((cast,no_check(Uint32) cos_val) << 8)) + delta * f_frac) >> 1 +
                ((cast,no_check(Int32) ((cast,no_check(Uint32) cos_val) << 8)) + delta * f_frac) & 1 else (((cast,no_check(Int32) ((cast,no_check(Uint32) cos_val) << 8)) + delta * f_frac) >> ((((cast,no_check(s32) ((20 - 16))) - 1)) & 31) + 1) >> 1;
        k += 1;
    }

    dd := D >> 1;

    silk_nlsf2_a_find_poly(p.data, cos_lsf_qa.data + 0, dd);
    silk_nlsf2_a_find_poly(q.data, cos_lsf_qa.data + 1, dd);

    k = 0;
    while k < dd {
        ptmp := p[k + 1] + p[k];
        qtmp := q[k + 1] - q[k];

        a32_qa1[k] = -qtmp - ptmp;
        a32_qa1[D - k - 1] = qtmp - ptmp;
        k += 1;
    }

    silk_lpc_fit(a_q12, a32_qa1.data, 12, cast,no_check(s32) (16 + 1), D);

    i: s32 = 0;
    while silk_lpc_inverse_pred_gain_c(a_q12, D) == 0 && i < 16 {
        silk_bwexpander_32(a32_qa1.data, D, 65536 - cast,no_check(Int32) ((cast(Uint32) 2) << ((i) & 31)));
        k = 0;
        while k < D {
            a_q12[k] =
                cast,no_check(Int16) ((ifx (cast,no_check(s32) ((16 + 1))) - 12 == 1 then a32_qa1[k] >> 1 +
                    a32_qa1[k] & 1 else (a32_qa1[k] >> ((((cast,no_check(s32) ((16 + 1))) - 12 - 1)) & 31) + 1) >> 1));
            k += 1;
        }
        i += 1;
    }
}

silk_nlsf2_a_find_poly :: (out: *Int32, c_lsf: *Int32, dd: s32) {
    n: s32 = ---;

    out[0] = cast,no_check(Int32) ((cast(Uint32) 1) << 16);
    out[1] = -c_lsf[0];
    if 1 < dd {
        for k: 1..dd - 1 {
            ftmp := c_lsf[2 * k];
            out[k + 1] =
                (cast,no_check(Int32) ((cast,no_check(Uint32) out[k - 1]) << 1)) -
                    cast,no_check(Int32) ((ifx 16 == 1 then (((cast,no_check(Int64) ftmp) * cast(Int64) out[k]) >> 1) + ((cast,no_check(Int64) ftmp) * cast(Int64) out[k]) & 1 else ((((cast,no_check(Int64) ftmp) * cast(Int64) out[k]) >> (((16 - 1)) & 63)) + 1) >> 1));
            n = k;
            while n > 1 {
                out[n] +=
                    out[n - 2] -
                        cast,no_check(Int32) ((ifx 16 == 1 then (((cast,no_check(Int64) ftmp) * cast(Int64) out[n - 1]) >> 1) + ((cast,no_check(Int64) ftmp) * cast(Int64) out[n - 1]) & 1 else ((((cast,no_check(Int64) ftmp) * cast(Int64) out[n - 1]) >> (((16 - 1)) & 63)) + 1) >> 1));
                n -= 1;
            }
            out[1] -= ftmp;
        }
    }
}

silk_ror32_in_nlsf2_a :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_nlsf2_a :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_nlsf2_a :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_nlsf2_a :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_nlsf2_a :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_nlsf2_a :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_nlsf2_a :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_nlsf2_a :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_nlsf2_a :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_nlsf2_a :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_nlsf2_a(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_nlsf2_a(in_upper);
    }
}

silk_clz_frac_in_nlsf2_a :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_nlsf2_a(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_nlsf2_a(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_nlsf2_a :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_nlsf2_a(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_nlsf2_a :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_nlsf2_a((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_nlsf2_a((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_nlsf2_a :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_nlsf2_a((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_nlsf2_a :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_nlsf2_a :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_nlsf2_a :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_nlsf2_a :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_nlsf2_a :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_nlsf2_a :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_nlsf2_a: u32;
initialize_globals_for_nlsf2_a :: () {
    {
        state := atomic_load(*globals_initialization_state_for_nlsf2_a);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_nlsf2_a, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_nlsf2_a) != 2 {}
            return;
        }
    }
    ORDERING16 =
        u8.[
            0,
            15,
            8,
            7,
            4,
            11,
            12,
            3,
            2,
            13,
            10,
            5,
            6,
            9,
            14,
            1
        ];
    ORDERING10 =
        u8.[
            0,
            9,
            6,
            3,
            4,
            5,
            8,
            1,
            2,
            7
        ];
    atomic_store(*globals_initialization_state_for_nlsf2_a, 2);
}

