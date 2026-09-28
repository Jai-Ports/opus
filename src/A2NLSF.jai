silk_clz16_in_a2_nlsf :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_a2_nlsf :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_a2_nlsf :: () -> s32 {
    return 0;
}

silk_a2_nlsf :: (nlsf: *Int16, a_q16: *Int32, D: s32) {
    root_ix: s32 = ---;
    ffrac: s32 = ---;
    xmid: Int32 = ---;
    ymid: Int32 = ---;
    nom, den: Int32 = ---;
    p_value: [13] Int32 = ---;
    q: [13] Int32 = ---;
    pq: [2] *Int32 = ---;

    pq[0] = p_value.data;
    pq[1] = q.data;

    dd := D >> 1;

    silk_a2_nlsf_init(a_q16, p_value.data, q.data, dd);

    p := p_value.data;

    xlo := cast,no_check(Int32) SILK_LSF_COS_TAB_FIX_Q12[0];
    ylo := silk_a2_nlsf_eval_poly(p, xlo, dd);

    if ylo < 0 {
        nlsf[0] = 0;
        p = q.data;
        ylo = silk_a2_nlsf_eval_poly(p, xlo, dd);
        root_ix = 1;
    } else {
        root_ix = 0;
    }
    k: s32 = 1;
    i: s32 = 0;
    thr: Int32 = 0;
    while ((cast(s32) 1) != 0) {
        xhi := cast,no_check(Int32) SILK_LSF_COS_TAB_FIX_Q12[k];
        yhi := silk_a2_nlsf_eval_poly(p, xhi, dd);

        if ylo <= 0 && yhi >= thr || ylo >= 0 && yhi <= -thr {
            if yhi == 0 {
                thr = 1;
            } else {
                thr = 0;
            }

            ffrac = -256;
            for m: 0..cast(s32) 3 - 1 {
                xmid =
                    ifx 1 == 1 then (xlo + xhi) >> 1 +
                        (xlo + xhi) & 1 else ((xlo + xhi) >> (((1 - 1)) & 31) + 1) >> 1;
                ymid = silk_a2_nlsf_eval_poly(p, xmid, dd);

                if ylo <= 0 && ymid >= 0 || ylo >= 0 && ymid <= 0 {
                    xhi = xmid;
                    yhi = ymid;
                } else {
                    xlo = xmid;
                    ylo = ymid;
                    ffrac = ffrac + (cast(s32) 128) >> ((m) & 31);
                }
            }

            if (ifx ylo > 0 then ylo else -ylo) < 65536 {
                den = ylo - yhi;
                nom = (cast,no_check(Int32) ((cast,no_check(Uint32) ylo) << (((8 - 3)) & 31))) + den >> 1;
                if den != 0 {
                    ffrac = cast,no_check(s32) (ffrac + (nom / den));
                }
            } else {
                ffrac = cast,no_check(s32) (ffrac + (ylo / (ylo - yhi) >> (((8 - 3)) & 31)));
            }
            nlsf[root_ix] =
                cast,no_check(Int16) silk_min_32_in_a2_nlsf(
                    (cast,no_check(Int32) ((cast,no_check(Uint32) k) << 8)) + ffrac,
                    0x7fff
                );

            (nlsf[root_ix] >= 0);

            root_ix += 1;
            if root_ix >= D {
                break;
            }

            p = pq[root_ix & 1];

            xlo = cast,no_check(Int32) SILK_LSF_COS_TAB_FIX_Q12[k - 1];
            ylo = cast,no_check(Int32) ((cast,no_check(Uint32) (1 - root_ix & 2)) << 12);
        } else {
            k += 1;
            xlo = xhi;
            ylo = yhi;
            thr = 0;

            if k > 128 {
                i += 1;
                if i > 16 {
                    nlsf[0] = cast,no_check(Int16) ((cast(s32) 1) << 15 / (D + 1));
                    k = 1;
                    while k < D {
                        nlsf[k] = cast,no_check(Int16) ((cast(s32) nlsf[k - 1]) + cast(s32) nlsf[0]);
                        k += 1;
                    }
                    return;
                }

                silk_bwexpander_32(a_q16, D, 65536 - cast,no_check(Int32) ((cast(Uint32) 1) << ((i) & 31)));

                silk_a2_nlsf_init(a_q16, p_value.data, q.data, dd);
                p = p_value.data;
                xlo = cast,no_check(Int32) SILK_LSF_COS_TAB_FIX_Q12[0];
                ylo = silk_a2_nlsf_eval_poly(p, xlo, dd);
                if ylo < 0 {
                    nlsf[0] = 0;
                    p = q.data;
                    ylo = silk_a2_nlsf_eval_poly(p, xlo, dd);
                    root_ix = 1;
                } else {
                    root_ix = 0;
                }
                k = 1;
            }
        }
    }
}

silk_a2_nlsf_eval_poly :: (p: *Int32, X: Int32, DD: s32) -> Int32 {
    n: s32 = ---;
    y32: Int32 = ---;

    y32 = p[DD];
    x_q16 := cast,no_check(Int32) ((cast,no_check(Uint32) X) << 4);

    if cast(s64) (8 == DD) != 0 {
        y32 = cast,no_check(Int32) ((cast(Int64) p[7]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[6]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[5]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[4]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[3]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[2]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[1]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
        y32 = cast,no_check(Int32) ((cast(Int64) p[0]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
    } else {
        n = DD - 1;
        while n >= 0 {
            y32 = cast,no_check(Int32) ((cast(Int64) p[n]) + ((cast,no_check(Int64) y32) * cast(Int64) x_q16) >> 16);
            n -= 1;
        }
    }
    return y32;
}

silk_a2_nlsf_init :: (a_q16: *Int32, p: *Int32, q: *Int32, DD: s32) {
    p[DD] = cast,no_check(Int32) ((cast(Uint32) 1) << 16);
    q[DD] = cast,no_check(Int32) ((cast(Uint32) 1) << 16);
    k: s32 = 0;
    while k < DD {
        p[k] = -a_q16[DD - k - 1] - a_q16[DD + k];
        q[k] = -a_q16[DD - k - 1] + a_q16[DD + k];
        k += 1;
    }

    k = DD;
    while k > 0 {
        p[k - 1] -= p[k];
        q[k - 1] += q[k];
        k -= 1;
    }

    silk_a2_nlsf_trans_poly(p, DD);
    silk_a2_nlsf_trans_poly(q, DD);
}

silk_a2_nlsf_trans_poly :: (p: *Int32, DD: s32) {
    n: s32 = ---;

    if 2 <= DD {
        for k: 2..DD {
            n = DD;
            while n > k {
                p[n - 2] -= p[n];
                n -= 1;
            }
            p[k - 2] -= cast,no_check(Int32) ((cast,no_check(Uint32) p[k]) << 1);
        }
    }
}

silk_min_32_in_a2_nlsf :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_ror32_in_a2_nlsf :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_a2_nlsf :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_a2_nlsf :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_64_in_a2_nlsf :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_a2_nlsf :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_a2_nlsf :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_a2_nlsf :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_a2_nlsf :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_a2_nlsf :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_a2_nlsf(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_a2_nlsf(in_upper);
    }
}

silk_clz_frac_in_a2_nlsf :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_a2_nlsf(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_a2_nlsf(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_a2_nlsf :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_a2_nlsf(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_a2_nlsf :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_a2_nlsf((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_a2_nlsf((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_a2_nlsf :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_a2_nlsf((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_a2_nlsf :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_a2_nlsf :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_a2_nlsf :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_a2_nlsf :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_a2_nlsf :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_a2_nlsf :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

