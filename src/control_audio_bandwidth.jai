// Generated directly from C by cpp_transpiler.
silk_clz16_in_control_audio_bandwidth :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_control_audio_bandwidth :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_control_audio_bandwidth :: () -> s32 {
    return 0;
}

silk_ror32_in_control_audio_bandwidth :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_control_audio_bandwidth :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_control_audio_bandwidth :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_control_audio_bandwidth :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_control_audio_bandwidth :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_control_audio_bandwidth :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_control_audio_bandwidth :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_control_audio_bandwidth :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_control_audio_bandwidth :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_control_audio_bandwidth :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_control_audio_bandwidth(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_control_audio_bandwidth(in_upper);
    }
}

silk_clz_frac_in_control_audio_bandwidth :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_control_audio_bandwidth(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_control_audio_bandwidth(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_control_audio_bandwidth :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_control_audio_bandwidth(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_control_audio_bandwidth :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_control_audio_bandwidth((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_control_audio_bandwidth((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_control_audio_bandwidth :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_control_audio_bandwidth((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_control_audio_bandwidth :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_control_audio_bandwidth :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_control_audio_bandwidth :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_control_audio_bandwidth :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_control_audio_bandwidth :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_control_audio_bandwidth :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_control_audio_bandwidth :: (ps_enc_c: *Silk_Encoder_State, enc_control: *Silk_Enc_Control_Struct) -> s32 {
    orig_k_hz := ps_enc_c.fs_k_hz;

    if orig_k_hz == 0 {
        orig_k_hz = ps_enc_c.s_lp.saved_fs_k_hz;
    }
    fs_k_hz := orig_k_hz;
    fs_hz := (cast,no_check(Int32) (cast,no_check(Int16) fs_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000);
    if fs_hz == 0 {
        fs_hz =
            ifx ps_enc_c.desired_internal_fs_hz < ps_enc_c.api_fs_hz then ps_enc_c.desired_internal_fs_hz else ps_enc_c.api_fs_hz;
        fs_k_hz = fs_hz / 1000;
    } else if fs_hz > ps_enc_c.api_fs_hz || fs_hz > ps_enc_c.max_internal_fs_hz || fs_hz < ps_enc_c.min_internal_fs_hz {
        fs_hz = ps_enc_c.api_fs_hz;
        fs_hz = ifx fs_hz < ps_enc_c.max_internal_fs_hz then fs_hz else ps_enc_c.max_internal_fs_hz;
        fs_hz = ifx fs_hz > ps_enc_c.min_internal_fs_hz then fs_hz else ps_enc_c.min_internal_fs_hz;
        fs_k_hz = fs_hz / 1000;
    } else {
        if ps_enc_c.s_lp.transition_frame_no >= 5120 / cast,no_check(s32) ((5 * 4)) {
            ps_enc_c.s_lp.mode = 0;
        }
        if ps_enc_c.allow_bandwidth_switch != 0 || enc_control.can_switch != 0 {
            if ((cast,no_check(Int32) (cast,no_check(Int16) orig_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000)) > ps_enc_c.desired_internal_fs_hz {
                if ps_enc_c.s_lp.mode == 0 {
                    ps_enc_c.s_lp.transition_frame_no = cast,no_check(Int32) ((5120 / cast,no_check(s32) ((5 * 4))));

                    fill_memory(ps_enc_c.s_lp.in_lp_state.data, 0, ps_enc_c.s_lp.in_lp_state.count * size_of(Int32));
                }
                if enc_control.can_switch != 0 {
                    ps_enc_c.s_lp.mode = 0;

                    fs_k_hz = ifx orig_k_hz == 16 then cast(s32) 12 else 8;
                } else if ps_enc_c.s_lp.transition_frame_no <= 0 {
                    enc_control.switch_ready = 1;

                    enc_control.max_bits -= enc_control.max_bits * 5 / (enc_control.payload_size_ms + 5);
                } else {
                    ps_enc_c.s_lp.mode = -2;
                }
            } else if ((cast,no_check(Int32) (cast,no_check(Int16) orig_k_hz)) * cast,no_check(Int32) (cast(Int16) 1000)) < ps_enc_c.desired_internal_fs_hz {
                if enc_control.can_switch != 0 {
                    fs_k_hz = ifx orig_k_hz == 8 then cast(s32) 12 else 16;

                    ps_enc_c.s_lp.transition_frame_no = 0;

                    fill_memory(ps_enc_c.s_lp.in_lp_state.data, 0, ps_enc_c.s_lp.in_lp_state.count * size_of(Int32));

                    ps_enc_c.s_lp.mode = 1;
                } else if ps_enc_c.s_lp.mode == 0 {
                    enc_control.switch_ready = 1;

                    enc_control.max_bits -= enc_control.max_bits * 5 / (enc_control.payload_size_ms + 5);
                } else {
                    ps_enc_c.s_lp.mode = 1;
                }
            } else if ps_enc_c.s_lp.mode < 0 {
                ps_enc_c.s_lp.mode = 1;
            }
        }
    }

    return fs_k_hz;
}

