// Generated directly from C by cpp_transpiler.
silk_clz16_in_shell_coder :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_shell_coder :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_shell_coder :: () -> s32 {
    return 0;
}

silk_ror32_in_shell_coder :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_shell_coder :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_shell_coder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_shell_coder :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_shell_coder :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_shell_coder :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_shell_coder :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_shell_coder :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_shell_coder :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_shell_coder :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_shell_coder(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_shell_coder(in_upper);
    }
}

silk_clz_frac_in_shell_coder :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_shell_coder(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_shell_coder(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_shell_coder :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_shell_coder(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_shell_coder :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_shell_coder((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_shell_coder((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_shell_coder :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_shell_coder((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_shell_coder :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_shell_coder :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_shell_coder :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_shell_coder :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_shell_coder :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_shell_coder :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_shell_encoder :: (ps_range_enc: *Ec_Enc, pulses0: *s32) {
    pulses1: [8] s32 = ---;
    pulses2: [4] s32 = ---;
    pulses3: [2] s32 = ---;
    pulses4: [1] s32 = ---;

    combine_pulses(pulses1.data, pulses0, 8);
    combine_pulses(pulses2.data, pulses1.data, 4);
    combine_pulses(pulses3.data, pulses2.data, 2);
    combine_pulses(pulses4.data, pulses3.data, 1);

    encode_split(ps_range_enc, pulses3[0], pulses4[0], SILK_SHELL_CODE_TABLE3.data);

    encode_split(ps_range_enc, pulses2[0], pulses3[0], SILK_SHELL_CODE_TABLE2.data);

    encode_split(ps_range_enc, pulses1[0], pulses2[0], SILK_SHELL_CODE_TABLE1.data);
    encode_split(ps_range_enc, pulses0[0], pulses1[0], SILK_SHELL_CODE_TABLE0.data);
    encode_split(ps_range_enc, pulses0[2], pulses1[1], SILK_SHELL_CODE_TABLE0.data);

    encode_split(ps_range_enc, pulses1[2], pulses2[1], SILK_SHELL_CODE_TABLE1.data);
    encode_split(ps_range_enc, pulses0[4], pulses1[2], SILK_SHELL_CODE_TABLE0.data);
    encode_split(ps_range_enc, pulses0[6], pulses1[3], SILK_SHELL_CODE_TABLE0.data);

    encode_split(ps_range_enc, pulses2[2], pulses3[1], SILK_SHELL_CODE_TABLE2.data);

    encode_split(ps_range_enc, pulses1[4], pulses2[2], SILK_SHELL_CODE_TABLE1.data);
    encode_split(ps_range_enc, pulses0[8], pulses1[4], SILK_SHELL_CODE_TABLE0.data);
    encode_split(ps_range_enc, pulses0[10], pulses1[5], SILK_SHELL_CODE_TABLE0.data);

    encode_split(ps_range_enc, pulses1[6], pulses2[3], SILK_SHELL_CODE_TABLE1.data);
    encode_split(ps_range_enc, pulses0[12], pulses1[6], SILK_SHELL_CODE_TABLE0.data);
    encode_split(ps_range_enc, pulses0[14], pulses1[7], SILK_SHELL_CODE_TABLE0.data);
}

encode_split :: (ps_range_enc: *Ec_Enc, P_CHILD1: s32, P: s32, shell_table: *Uint8) {
    if P > 0 {
        ec_enc_icdf(ps_range_enc, P_CHILD1, *shell_table[SILK_SHELL_CODE_TABLE_OFFSETS[P]], 8);
    }
}

combine_pulses :: (out: *s32, in: *s32, LEN: s32) {
    if 0 < LEN {
        for k: 0..LEN - 1 {
            out[k] = in[2 * k] + in[2 * k + 1];
        }
    }
}

silk_shell_decoder :: (pulses0: *Int16, ps_range_dec: *Ec_Dec, PULSES4: s32) {
    pulses3: [2] Int16 = ---;
    pulses2: [4] Int16 = ---;
    pulses1: [8] Int16 = ---;

    decode_split(pulses3.data + 0, pulses3.data + 1, ps_range_dec, PULSES4, SILK_SHELL_CODE_TABLE3.data);

    decode_split(
        pulses2.data + 0,
        pulses2.data + 1,
        ps_range_dec,
        cast,no_check(s32) pulses3[0],
        SILK_SHELL_CODE_TABLE2.data
    );

    decode_split(
        pulses1.data + 0,
        pulses1.data + 1,
        ps_range_dec,
        cast,no_check(s32) pulses2[0],
        SILK_SHELL_CODE_TABLE1.data
    );
    decode_split(*pulses0[0], *pulses0[1], ps_range_dec, cast,no_check(s32) pulses1[0], SILK_SHELL_CODE_TABLE0.data);
    decode_split(*pulses0[2], *pulses0[3], ps_range_dec, cast,no_check(s32) pulses1[1], SILK_SHELL_CODE_TABLE0.data);

    decode_split(
        pulses1.data + 2,
        pulses1.data + 3,
        ps_range_dec,
        cast,no_check(s32) pulses2[1],
        SILK_SHELL_CODE_TABLE1.data
    );
    decode_split(*pulses0[4], *pulses0[5], ps_range_dec, cast,no_check(s32) pulses1[2], SILK_SHELL_CODE_TABLE0.data);
    decode_split(*pulses0[6], *pulses0[7], ps_range_dec, cast,no_check(s32) pulses1[3], SILK_SHELL_CODE_TABLE0.data);

    decode_split(
        pulses2.data + 2,
        pulses2.data + 3,
        ps_range_dec,
        cast,no_check(s32) pulses3[1],
        SILK_SHELL_CODE_TABLE2.data
    );

    decode_split(
        pulses1.data + 4,
        pulses1.data + 5,
        ps_range_dec,
        cast,no_check(s32) pulses2[2],
        SILK_SHELL_CODE_TABLE1.data
    );
    decode_split(*pulses0[8], *pulses0[9], ps_range_dec, cast,no_check(s32) pulses1[4], SILK_SHELL_CODE_TABLE0.data);
    decode_split(*pulses0[10], *pulses0[11], ps_range_dec, cast,no_check(s32) pulses1[5], SILK_SHELL_CODE_TABLE0.data);

    decode_split(
        pulses1.data + 6,
        pulses1.data + 7,
        ps_range_dec,
        cast,no_check(s32) pulses2[3],
        SILK_SHELL_CODE_TABLE1.data
    );
    decode_split(*pulses0[12], *pulses0[13], ps_range_dec, cast,no_check(s32) pulses1[6], SILK_SHELL_CODE_TABLE0.data);
    decode_split(*pulses0[14], *pulses0[15], ps_range_dec, cast,no_check(s32) pulses1[7], SILK_SHELL_CODE_TABLE0.data);
}

decode_split :: (p_child1: *Int16, p_child2: *Int16, ps_range_dec: *Ec_Dec, P: s32, shell_table: *Uint8) {
    if P > 0 {
        p_child1[0] =
            cast,no_check(Int16) ec_dec_icdf(
                ps_range_dec,
                *shell_table[SILK_SHELL_CODE_TABLE_OFFSETS[P]],
                8
            );
        p_child2[0] = cast,no_check(Int16) (P - cast(s32) p_child1[0]);
    } else {
        p_child1[0] = 0;
        p_child2[0] = 0;
    }
}

