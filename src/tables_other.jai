SILK_LSB_I_CDF: [2] Uint8;

SILK_UNIFORM3_I_CDF: [3] Uint8;

SILK_UNIFORM4_I_CDF: [4] Uint8;

SILK_UNIFORM5_I_CDF: [5] Uint8;

SILK_UNIFORM6_I_CDF: [6] Uint8;

SILK_UNIFORM8_I_CDF: [8] Uint8;

SILK_NLSF_EXT_I_CDF: [7] Uint8;

SILK_LT_PSCALE_I_CDF: [3] Uint8;

SILK_LTP_SCALES_TABLE_Q14: [3] Int16;

SILK_TYPE_OFFSET_VAD_I_CDF: [4] Uint8;

SILK_TYPE_OFFSET_NO_VAD_I_CDF: [2] Uint8;

SILK_STEREO_PRED_QUANT_Q13: [16] Int16;

SILK_STEREO_PRED_JOINT_I_CDF: [25] Uint8;

SILK_STEREO_ONLY_CODE_MID_I_CDF: [2] Uint8;

SILK_LBRR_FLAGS_I_CDF_PTR: [2] *Uint8;

SILK_LBRR_FLAGS_3_I_CDF: [7] Uint8;

SILK_LBRR_FLAGS_2_I_CDF: [3] Uint8;

SILK_NLSF_INTERPOLATION_FACTOR_I_CDF: [5] Uint8;

SILK_QUANTIZATION_OFFSETS_Q10: [2] [2] Int16;

SILK_TRANSITION_LP_B_Q28: [5] [3] Int32;

SILK_TRANSITION_LP_A_Q28: [5] [2] Int32;

silk_clz16_in_tables_other :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_tables_other :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_tables_other :: () -> s32 {
    return 0;
}

silk_ror32_in_tables_other :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_tables_other :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_tables_other :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_tables_other :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_tables_other :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_tables_other :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_tables_other :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_tables_other :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_tables_other :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_tables_other :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_tables_other(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_tables_other(in_upper);
    }
}

silk_clz_frac_in_tables_other :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_tables_other(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_tables_other(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_tables_other :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_tables_other(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_tables_other :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_tables_other((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_tables_other((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_tables_other :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_tables_other((ifx B32 > 0 then B32 else -B32)) - 1;
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

ec_range_bytes_in_tables_other :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_tables_other :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_tables_other :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_tables_other :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_tables_other :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_tables_other :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_tables_other: u32;
initialize_globals_for_tables_other :: () {
    {
        state := atomic_load(*globals_initialization_state_for_tables_other);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_tables_other, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_tables_other) != 2 {}
            return;
        }
    }
    SILK_STEREO_PRED_QUANT_Q13 =
        Int16.[
            -13732,
            -10050,
            -8266,
            -7526,
            -6500,
            -5000,
            -2950,
            -820,
            820,
            2950,
            5000,
            6500,
            7526,
            8266,
            10050,
            13732
        ];
    SILK_STEREO_PRED_JOINT_I_CDF =
        Uint8.[
            249,
            247,
            246,
            245,
            244,
            234,
            210,
            202,
            201,
            200,
            197,
            174,
            82,
            59,
            56,
            55,
            54,
            46,
            22,
            12,
            11,
            10,
            9,
            7,
            0
        ];
    SILK_STEREO_ONLY_CODE_MID_I_CDF = Uint8.[ 64, 0 ];
    SILK_LBRR_FLAGS_2_I_CDF = Uint8.[ 203, 150, 0 ];
    SILK_LBRR_FLAGS_3_I_CDF =
        Uint8.[
            215,
            195,
            166,
            125,
            110,
            82,
            0
        ];
    SILK_LBRR_FLAGS_I_CDF_PTR = *Uint8.[ SILK_LBRR_FLAGS_2_I_CDF.data, SILK_LBRR_FLAGS_3_I_CDF.data ];
    SILK_LSB_I_CDF = Uint8.[ 120, 0 ];
    SILK_LT_PSCALE_I_CDF = Uint8.[ 128, 64, 0 ];
    SILK_TYPE_OFFSET_VAD_I_CDF = Uint8.[ 232, 158, 10, 0 ];
    SILK_TYPE_OFFSET_NO_VAD_I_CDF = Uint8.[ 230, 0 ];
    SILK_NLSF_INTERPOLATION_FACTOR_I_CDF =
        Uint8.[
            243,
            221,
            192,
            181,
            0
        ];
    SILK_QUANTIZATION_OFFSETS_Q10 =
        [2] Int16.[
            Int16.[ 100, 240 ],
            Int16.[ 32, 100 ]
        ];
    SILK_LTP_SCALES_TABLE_Q14 = Int16.[ 15565, 12288, 8192 ];
    SILK_UNIFORM3_I_CDF = Uint8.[ 171, 85, 0 ];
    SILK_UNIFORM4_I_CDF = Uint8.[ 192, 128, 64, 0 ];
    SILK_UNIFORM5_I_CDF =
        Uint8.[
            205,
            154,
            102,
            51,
            0
        ];
    SILK_UNIFORM6_I_CDF =
        Uint8.[
            213,
            171,
            128,
            85,
            43,
            0
        ];
    SILK_UNIFORM8_I_CDF =
        Uint8.[
            224,
            192,
            160,
            128,
            96,
            64,
            32,
            0
        ];
    SILK_NLSF_EXT_I_CDF =
        Uint8.[
            100,
            40,
            16,
            7,
            3,
            1,
            0
        ];
    SILK_TRANSITION_LP_B_Q28 =
        [3] Int32.[
            Int32.[ 250767114, 501534038, 250767114 ],
            Int32.[ 209867381, 419732057, 209867381 ],
            Int32.[ 170987846, 341967853, 170987846 ],
            Int32.[ 131531482, 263046905, 131531482 ],
            Int32.[ 89306658, 178584282, 89306658 ]
        ];
    SILK_TRANSITION_LP_A_Q28 =
        [2] Int32.[
            Int32.[ 506393414, 239854379 ],
            Int32.[ 411067935, 169683996 ],
            Int32.[ 306733530, 116694253 ],
            Int32.[ 185807084, 77959395 ],
            Int32.[ 35497197, 57401098 ]
        ];
    atomic_store(*globals_initialization_state_for_tables_other, 2);
}

