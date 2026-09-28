silk_clz16_in_decode_frame :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_decode_frame :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_decode_frame :: () -> s32 {
    return 0;
}

silk_ror32_in_decode_frame :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_decode_frame :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_decode_frame :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_decode_frame :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_decode_frame :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_decode_frame :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_decode_frame :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_decode_frame :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_decode_frame :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_decode_frame :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_decode_frame(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_decode_frame(in_upper);
    }
}

silk_clz_frac_in_decode_frame :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_decode_frame(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_decode_frame(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_decode_frame :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_decode_frame(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_decode_frame :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_decode_frame((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_decode_frame((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_decode_frame :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_decode_frame((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_decode_frame :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_decode_frame :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_decode_frame :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_decode_frame :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_decode_frame :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_decode_frame :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_decode_frame :: (
    ps_dec: *Silk_Decoder_State,
    ps_range_dec: *Ec_Dec,
    p_out: *Int16,
    p_n: *Int32,
    lost_flag: s32,
    cond_coding: s32,
    arch: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    mv_len: s32 = ---;
    ret: s32 = 0;

    l := ps_dec.frame_length;
    ps_dec_ctrl :=
        cast(*Silk_Decoder_Control) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Silk_Decoder_Control))) *
            1)));
    ps_dec_ctrl.ltp_scale_q14 = 0;

    (l > 0 && l <= (cast,no_check(s32) ((5 * 4))) * 16);

    if lost_flag == 0 || lost_flag == 2 && ps_dec.lbrr_flags[ps_dec.n_frames_decoded] == 1 {
        pulses :=
            cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) *
                cast,no_check(u64) ((l + 16 - 1) & cast,no_check(s32) (~(16 - 1))))));

        (cast,no_check(#type (_: *Silk_Decoder_State, _: *Ec_Dec, _: s32, _: s32, _: s32)) (cast(*void) silk_decode_indices))(
            ps_dec,
            ps_range_dec,
            ps_dec.n_frames_decoded,
            lost_flag,
            cond_coding
        );

        silk_decode_pulses(
            ps_range_dec,
            pulses,
            cast,no_check(s32) ps_dec.indices.signal_type,
            cast,no_check(s32) ps_dec.indices.quant_offset_type,
            ps_dec.frame_length
        );

        (cast,no_check(#type (_: *Silk_Decoder_State, _: *Silk_Decoder_Control, _: s32)) (cast(*void) silk_decode_parameters))(
            ps_dec,
            ps_dec_ctrl,
            cond_coding
        );

        silk_decode_core(ps_dec, ps_dec_ctrl, p_out, pulses, arch);

        (ps_dec.ltp_mem_length >= ps_dec.frame_length);
        mv_len = ps_dec.ltp_mem_length - ps_dec.frame_length;
        move_memory(
            ps_dec.out_buf.data,
            ps_dec.out_buf.data + ps_dec.frame_length,
            cast,no_check(u64) mv_len * size_of(Int16)
        );
        copy_memory(ps_dec.out_buf.data + mv_len, p_out, cast,no_check(u64) ps_dec.frame_length * size_of(Int16));

        (cast,no_check(#type (_: *Silk_Decoder_State, _: *Silk_Decoder_Control, _: *Int16, _: s32, _: s32)) (cast(*void) silk_plc))(
            ps_dec,
            ps_dec_ctrl,
            p_out,
            0,
            arch
        );

        ps_dec.loss_cnt = 0;
        ps_dec.prev_signal_type = cast,no_check(s32) ps_dec.indices.signal_type;
        (ps_dec.prev_signal_type >= 0 && ps_dec.prev_signal_type <= 2);

        ps_dec.first_frame_after_reset = 0;
    } else {
        (cast,no_check(#type (_: *Silk_Decoder_State, _: *Silk_Decoder_Control, _: *Int16, _: s32, _: s32)) (cast(*void) silk_plc))(
            ps_dec,
            ps_dec_ctrl,
            p_out,
            1,
            arch
        );

        (ps_dec.ltp_mem_length >= ps_dec.frame_length);
        mv_len = ps_dec.ltp_mem_length - ps_dec.frame_length;
        move_memory(
            ps_dec.out_buf.data,
            ps_dec.out_buf.data + ps_dec.frame_length,
            cast,no_check(u64) mv_len * size_of(Int16)
        );
        copy_memory(ps_dec.out_buf.data + mv_len, p_out, cast,no_check(u64) ps_dec.frame_length * size_of(Int16));
    }

    silk_cng(ps_dec, ps_dec_ctrl, p_out, l);

    (cast,no_check(#type (_: *Silk_Decoder_State, _: *Int16, _: s32)) (cast(*void) silk_plc_glue_frames))(
        ps_dec,
        p_out,
        l
    );

    ps_dec.lag_prev = ps_dec_ctrl.pitch_l[ps_dec.nb_subfr - 1];

    p_n.* = l;

    return ret;
}

false__in_decode_frame :: () -> s32 {
    return 0;
}

