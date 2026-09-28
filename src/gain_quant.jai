// Generated directly from C by cpp_transpiler.
silk_clz16_in_gain_quant :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_gain_quant :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_gain_quant :: () -> s32 {
    return 0;
}

silk_ror32_in_gain_quant :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_gain_quant :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_gain_quant :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_gain_quant :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_gain_quant :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_gain_quant :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_gain_quant :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_gain_quant :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_gain_quant :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_gain_quant :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_gain_quant(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_gain_quant(in_upper);
    }
}

silk_clz_frac_in_gain_quant :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_gain_quant(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_gain_quant(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_gain_quant :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_gain_quant(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_gain_quant :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_gain_quant((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_gain_quant((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_gain_quant :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_gain_quant((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_gain_quant :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_gain_quant :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_gain_quant :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_gain_quant :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_gain_quant :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_gain_quant :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_gains_quant :: (ind: *Int8, gain_q16: *Int32, prev_ind: *Int8, CONDITIONAL: s32, NB_SUBFR: s32) {
    double_step_size_threshold: s32 = ---;

    if 0 < NB_SUBFR {
        for k: 0..NB_SUBFR - 1 {
            ind[k] =
                cast,no_check(Int8) (cast,no_check(Int32) (((cast,no_check(Int64) ((65536 * cast,no_check(s32) ((64 - 1))) / ((cast,no_check(s32) ((88 - 2))) * 128 / 6))) *
                    cast,no_check(Int64) (cast,no_check(Int16) (silk_lin2log(gain_q16[k]) - cast,no_check(Int32) (((cast,no_check(s32) ((2 * 128))) / 6 + cast,no_check(s32) ((16 * 128))))))) >> 16));

            if ind[k] < prev_ind.* {
                ind[k] += 1;
            }
            ind[k] =
                cast,no_check(Int8) ((ifx 0 > 64 -
                    1 then (ifx ind[k] > 0 then 0 else (ifx cast,no_check(s32) ind[k] < 64 - 1 then cast,no_check(s32) ((64 - 1)) else cast,no_check(s32) ind[k])) else (ifx cast,no_check(s32) ind[k] > 64 - 1 then cast,no_check(s32) ((64 - 1)) else (ifx ind[k] < 0 then 0 else cast,no_check(s32) ind[k]))));

            if k == 0 && CONDITIONAL == 0 {
                ind[k] =
                    cast,no_check(Int8) ((ifx (cast(s32) prev_ind.*) + -4 > 64 -
                        1 then (ifx cast,no_check(s32) ind[k] > (cast(s32) prev_ind.*) + -4 then (cast(s32) prev_ind.*) + -4 else (ifx cast,no_check(s32) ind[k] < 64 - 1 then cast,no_check(s32) ((64 - 1)) else cast,no_check(s32) ind[k])) else (ifx cast,no_check(s32) ind[k] > 64 - 1 then cast,no_check(s32) ((64 - 1)) else (ifx cast,no_check(s32) ind[k] < (cast(s32) prev_ind.*) + -4 then (cast(s32) prev_ind.*) + -4 else cast,no_check(s32) ind[k]))));
                prev_ind.* = ind[k];
            } else {
                ind[k] = cast,no_check(Int8) ((cast(s32) ind[k]) - cast(s32) prev_ind.*);

                double_step_size_threshold = (cast,no_check(s32) ((2 * 36))) - 64 + cast(s32) prev_ind.*;
                if cast,no_check(s32) ind[k] > double_step_size_threshold {
                    ind[k] =
                        cast,no_check(Int8) (double_step_size_threshold +
                            ((cast(s32) ind[k]) - double_step_size_threshold + 1) >> 1);
                }

                ind[k] =
                    cast,no_check(Int8) ((ifx -4 > 36 then (ifx ind[k] > -4 then -4 else (ifx ind[k] < 36 then 36 else cast,no_check(s32) ind[k])) else (ifx ind[k] > 36 then 36 else (ifx ind[k] < -4 then -4 else cast,no_check(s32) ind[k]))));

                if cast,no_check(s32) ind[k] > double_step_size_threshold {
                    prev_ind.* = cast,no_check(Int8) ((cast,no_check(s32) prev_ind.*) + ((cast,no_check(Int32) ((cast,no_check(Uint32) ind[k]) << 1)) - double_step_size_threshold));
                    prev_ind.* =
                        cast,no_check(Int8) silk_min_int_in_gain_quant(
                            cast,no_check(s32) prev_ind.*,
                            cast,no_check(s32) (64 - 1)
                        );
                } else {
                    prev_ind.* = cast,no_check(Int8) ((cast,no_check(s32) prev_ind.*) + cast,no_check(s32) ind[k]);
                }

                ind[k] = cast,no_check(Int8) ((cast,no_check(s32) ind[k]) - -4);
            }

            gain_q16[k] =
                silk_log2lin(
                    silk_min_32_in_gain_quant(
                    (cast,no_check(Int32) (((cast,no_check(Int64) (65536 * ((cast,no_check(s32) ((88 - 2))) * 128 / 6) / cast,no_check(s32) ((64 - 1)))) * cast,no_check(Int64) (cast,no_check(Int16) prev_ind.*)) >> 16)) +
                    cast,no_check(Int32) (((cast,no_check(s32) ((2 * 128))) / 6 + cast,no_check(s32) ((16 * 128)))),
                    3967
                )
                );
        }
    }
}

silk_gains_dequant :: (gain_q16: *Int32, ind: *Int8, prev_ind: *Int8, CONDITIONAL: s32, NB_SUBFR: s32) {
    ind_tmp: s32 = ---;
    double_step_size_threshold: s32 = ---;

    if 0 < NB_SUBFR {
        for k: 0..NB_SUBFR - 1 {
            if k == 0 && CONDITIONAL == 0 {
                prev_ind.* =
                    cast,no_check(Int8) silk_max_int_in_gain_quant(
                        cast,no_check(s32) ind[k],
                        (cast(s32) prev_ind.*) - 16
                    );
            } else {
                ind_tmp = (cast(s32) ind[k]) + -4;

                double_step_size_threshold = (cast,no_check(s32) ((2 * 36))) - 64 + cast(s32) prev_ind.*;
                if ind_tmp > double_step_size_threshold {
                    prev_ind.* = cast,no_check(Int8) ((cast,no_check(s32) prev_ind.*) + ((cast,no_check(Int32) ((cast,no_check(Uint32) ind_tmp) << 1)) - double_step_size_threshold));
                } else {
                    prev_ind.* = cast,no_check(Int8) ((cast,no_check(s32) prev_ind.*) + ind_tmp);
                }
            }
            prev_ind.* =
                cast,no_check(Int8) ((ifx 0 > 64 -
                    1 then (ifx prev_ind.* > 0 then 0 else (ifx cast,no_check(s32) prev_ind.* < 64 - 1 then cast,no_check(s32) ((64 - 1)) else cast,no_check(s32) prev_ind.*)) else (ifx cast,no_check(s32) prev_ind.* > 64 - 1 then cast,no_check(s32) ((64 - 1)) else (ifx prev_ind.* < 0 then 0 else cast,no_check(s32) prev_ind.*))));

            gain_q16[k] =
                silk_log2lin(
                    silk_min_32_in_gain_quant(
                    (cast,no_check(Int32) (((cast,no_check(Int64) (65536 * ((cast,no_check(s32) ((88 - 2))) * 128 / 6) / cast,no_check(s32) ((64 - 1)))) * cast,no_check(Int64) (cast,no_check(Int16) prev_ind.*)) >> 16)) +
                    cast,no_check(Int32) (((cast,no_check(s32) ((2 * 128))) / 6 + cast,no_check(s32) ((16 * 128)))),
                    3967
                )
                );
        }
    }
}

silk_gains_id :: (ind: *Int8, NB_SUBFR: s32) -> Int32 {
    gains_id: Int32 = 0;
    if 0 < NB_SUBFR {
        for k: 0..NB_SUBFR - 1 {
            gains_id = (cast(Int32) ind[k]) + cast,no_check(Int32) ((cast,no_check(Uint32) gains_id) << 8);
        }
    }

    return gains_id;
}

