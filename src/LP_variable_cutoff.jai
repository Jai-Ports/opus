// Generated directly from C by cpp_transpiler.
silk_clz16_in_lp_variable_cutoff :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_lp_variable_cutoff :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_lp_variable_cutoff :: () -> s32 {
    return 0;
}

silk_ror32_in_lp_variable_cutoff :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_lp_variable_cutoff :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_lp_variable_cutoff :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_lp_variable_cutoff :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_lp_variable_cutoff :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_lp_variable_cutoff :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_lp_variable_cutoff :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_lp_variable_cutoff :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_lp_variable_cutoff :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_lp_variable_cutoff :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_lp_variable_cutoff(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_lp_variable_cutoff(in_upper);
    }
}

silk_clz_frac_in_lp_variable_cutoff :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_lp_variable_cutoff(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_lp_variable_cutoff(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_lp_variable_cutoff :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_lp_variable_cutoff(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_lp_variable_cutoff :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_lp_variable_cutoff((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_lp_variable_cutoff((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_lp_variable_cutoff :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_lp_variable_cutoff((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_lp_variable_cutoff :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_lp_variable_cutoff :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_lp_variable_cutoff :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_lp_variable_cutoff :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_lp_variable_cutoff :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_lp_variable_cutoff :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_lp_variable_cutoff :: (ps_lp: *Silk_LP_State, frame: *Int16, FRAME_LENGTH: s32) {
    b_q28: [3] Int32 = ---;
    a_q28: [2] Int32 = ---;
    fac_q16: Int32 = 0;
    ind: s32 = 0;

    (ps_lp.transition_frame_no >= 0 && ps_lp.transition_frame_no <= 5120 / cast,no_check(s32) ((5 * 4)));

    if ps_lp.mode != 0 {
        fac_q16 =
            cast,no_check(Int32) ((cast,no_check(Uint32) ((cast,no_check(Int32) ((5120 / cast,no_check(s32) ((5 * 4))))) -
                ps_lp.transition_frame_no)) << (((16 - 6)) & 31));

        ind = fac_q16 >> 16;
        fac_q16 -= cast,no_check(Int32) ((cast,no_check(Uint32) ind) << 16);

        silk_lp_interpolate_filter_taps(b_q28.data, a_q28.data, ind, fac_q16);

        ps_lp.transition_frame_no =
            ifx 0 > 5120 /
                cast,no_check(s32) ((5 * 4)) then (ifx ps_lp.transition_frame_no + ps_lp.mode > 0 then 0 else (ifx ps_lp.transition_frame_no + ps_lp.mode < 5120 / cast,no_check(s32) ((5 * 4)) then cast,no_check(Int32) ((5120 / cast,no_check(s32) ((5 * 4)))) else ps_lp.transition_frame_no + ps_lp.mode)) else (ifx ps_lp.transition_frame_no + ps_lp.mode > 5120 / cast,no_check(s32) ((5 * 4)) then cast,no_check(Int32) ((5120 / cast,no_check(s32) ((5 * 4)))) else (ifx ps_lp.transition_frame_no + ps_lp.mode < 0 then 0 else ps_lp.transition_frame_no + ps_lp.mode));

        (3 == 3 && 2 == 2);
        silk_biquad_alt_stride1(frame, b_q28.data, a_q28.data, ps_lp.in_lp_state.data, frame, FRAME_LENGTH);
    }
}

silk_lp_interpolate_filter_taps :: (b_q28: *Int32, a_q28: *Int32, IND: s32, FAC_Q16: Int32) {
    if IND < 5 - 1 {
        if FAC_Q16 > 0 {
            if FAC_Q16 < 32768 {
                for nb: 0..cast(s32) 3 - 1 {
                    b_q28[nb] =
                        cast,no_check(Int32) ((cast(Int64) SILK_TRANSITION_LP_B_Q28[IND][nb]) +
                            ((cast(Int64) (SILK_TRANSITION_LP_B_Q28[IND + 1][nb] - SILK_TRANSITION_LP_B_Q28[IND][nb])) * cast,no_check(Int64) (cast,no_check(Int16) FAC_Q16)) >> 16);
                }
                for na: 0..cast(s32) 2 - 1 {
                    a_q28[na] =
                        cast,no_check(Int32) ((cast(Int64) SILK_TRANSITION_LP_A_Q28[IND][na]) +
                            ((cast(Int64) (SILK_TRANSITION_LP_A_Q28[IND + 1][na] - SILK_TRANSITION_LP_A_Q28[IND][na])) * cast,no_check(Int64) (cast,no_check(Int16) FAC_Q16)) >> 16);
                }
            } else {
                ((FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16))) == (ifx (FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16))) > 0x7fff then 0x7fff else (ifx (FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16))) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16)))));

                for nb: 0..cast(s32) 3 - 1 {
                    b_q28[nb] =
                        cast,no_check(Int32) ((cast(Int64) SILK_TRANSITION_LP_B_Q28[IND + 1][nb]) +
                            ((cast(Int64) (SILK_TRANSITION_LP_B_Q28[IND + 1][nb] - SILK_TRANSITION_LP_B_Q28[IND][nb])) * cast,no_check(Int64) (cast,no_check(Int16) (FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16))))) >> 16);
                }
                for na: 0..cast(s32) 2 - 1 {
                    a_q28[na] =
                        cast,no_check(Int32) ((cast(Int64) SILK_TRANSITION_LP_A_Q28[IND + 1][na]) +
                            ((cast(Int64) (SILK_TRANSITION_LP_A_Q28[IND + 1][na] - SILK_TRANSITION_LP_A_Q28[IND][na])) * cast,no_check(Int64) (cast,no_check(Int16) (FAC_Q16 - cast,no_check(Int32) (((cast(s32) 1) << 16))))) >> 16);
                }
            }
        } else {
            copy_memory(b_q28, SILK_TRANSITION_LP_B_Q28[IND].data, cast(u64) 3 * size_of(Int32));
            copy_memory(a_q28, SILK_TRANSITION_LP_A_Q28[IND].data, cast(u64) 2 * size_of(Int32));
        }
    } else {
        copy_memory(b_q28, SILK_TRANSITION_LP_B_Q28[5 - 1].data, cast(u64) 3 * size_of(Int32));
        copy_memory(a_q28, SILK_TRANSITION_LP_A_Q28[5 - 1].data, cast(u64) 2 * size_of(Int32));
    }
}

