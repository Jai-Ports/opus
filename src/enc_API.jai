ec_range_bytes_in_enc_api :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_enc_api :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_enc_api :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_enc_api :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_enc_api :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_enc_api :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

silk_get_encoder_size :: (enc_size_bytes: *s32, channels: s32) -> s32 {
    ret: s32 = 0;

    enc_size_bytes.* = cast,no_check(s32) (cast(u64) size_of(Silk_Encoder));

    if channels == 1 {
        enc_size_bytes.* = cast,no_check(s32) ((cast,no_check(u64) enc_size_bytes.*) - cast(u64) size_of(Silk_Encoder_State_FLP));
    }

    return ret;
}

silk_init_encoder :: (enc_state: *void, channels: s32, arch: s32, enc_status: *Silk_Enc_Control_Struct) -> s32 {
    ret: s32 = 0;

    ps_enc := cast(*Silk_Encoder) enc_state;

    fill_memory(ps_enc, 0, size_of(Silk_Encoder) - (cast(u64) (channels == 1)) * size_of(Silk_Encoder_State_FLP));
    if 0 < channels {
        for n: 0..channels - 1 {
            if ((c_transpiler_compound_add(*(ret), ((cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: s32) -> s32) (cast(*void) silk_init_encoder_2))(
                ps_enc.state_fxx.data + n,
                arch
            )), s32, s32)) != 0) {
            }
        }
    }

    ps_enc.n_channels_api = 1;
    ps_enc.n_channels_internal = 1;

    if ((c_transpiler_compound_add(*(ret), (silk_query_encoder(enc_state, enc_status)), s32, s32)) != 0) {
    }

    return ret;
}

silk_query_encoder :: (enc_state: *void, enc_status: *Silk_Enc_Control_Struct) -> s32 {
    ret: s32 = 0;

    ps_enc := cast(*Silk_Encoder) enc_state;

    state_fxx := ps_enc.state_fxx.data;

    enc_status.n_channels_api = ps_enc.n_channels_api;
    enc_status.n_channels_internal = ps_enc.n_channels_internal;
    enc_status.api_sample_rate = state_fxx[0].s_cmn.api_fs_hz;
    enc_status.max_internal_sample_rate = state_fxx[0].s_cmn.max_internal_fs_hz;
    enc_status.min_internal_sample_rate = state_fxx[0].s_cmn.min_internal_fs_hz;
    enc_status.desired_internal_sample_rate = state_fxx[0].s_cmn.desired_internal_fs_hz;
    enc_status.payload_size_ms = state_fxx[0].s_cmn.packet_size_ms;
    enc_status.bit_rate = state_fxx[0].s_cmn.target_rate_bps;
    enc_status.packet_loss_percentage = state_fxx[0].s_cmn.packet_loss_perc;
    enc_status.complexity = state_fxx[0].s_cmn.complexity;
    enc_status.use_in_band_fec = state_fxx[0].s_cmn.use_in_band_fec;
    enc_status.use_dtx = state_fxx[0].s_cmn.use_dtx;
    enc_status.use_cbr = state_fxx[0].s_cmn.use_cbr;
    enc_status.internal_sample_rate =
        (cast,no_check(Int32) (cast,no_check(Int16) state_fxx[0].s_cmn.fs_k_hz)) *
            cast,no_check(Int32) (cast(Int16) 1000);
    enc_status.allow_bandwidth_switch = state_fxx[0].s_cmn.allow_bandwidth_switch;
    enc_status.in_w_bmode_without_variable_lp =
        cast(s32) (state_fxx[0].s_cmn.fs_k_hz == 16 &&
            state_fxx[0].s_cmn.s_lp.mode == 0);

    return ret;
}

silk_query_encoder :: (enc_state: *$Value, enc_status: *Silk_Enc_Control_Struct) -> s32 {
    return silk_query_encoder(cast(*void) enc_state, enc_status);
}

silk_encode :: (
    enc_state: *void,
    enc_control: *Silk_Enc_Control_Struct,
    samples_in: *Res,
    n_samples_in: s32,
    ps_range_enc: *Ec_Enc,
    n_bytes_out: *Int32,
    PREFILL_FLAG: s32,
    activity: s32
) -> s32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    n: s32 = ---;
    i: s32 = ---;
    n_bits: s32 = ---;
    flags: s32 = ---;
    tmp_payload_size_ms: s32 = 0;
    tmp_complexity: s32 = 0;
    ret: s32 = 0;
    n_samples_from_input: s32 = 0;
    speech_act_thr_for_switch_q8: s32 = ---;
    target_rate_bps: Int32 = ---;
    m_starget_rates_bps: [2] Int32 = ---;
    channel_rate_bps: Int32 = ---;
    lbrr_symbol: Int32 = ---;
    sum: Int32 = ---;
    ps_enc := cast(*Silk_Encoder) enc_state;

    (enc_control.n_channels_api >= enc_control.n_channels_internal && enc_control.n_channels_api >= ps_enc.n_channels_internal);
    if enc_control.reduced_dependency != 0 {
        n = 0;
        while n < enc_control.n_channels_api {
            ps_enc.state_fxx[n].s_cmn.first_frame_after_reset = 1;
            n += 1;
        }
    }
    n = 0;
    while n < enc_control.n_channels_api {
        ps_enc.state_fxx[n].s_cmn.n_frames_encoded = 0;
        n += 1;
    }

    if (ifx true { assignment_0: s32 = cast,no_check(s32) ((cast,no_check(#type (_: *Silk_Enc_Control_Struct) -> s32) (cast(*void) check_control_input))(enc_control)); (ret) = assignment_0; assignment_0; }) != 0 {
        return ret;
    }

    enc_control.switch_ready = 0;

    if enc_control.n_channels_internal > ps_enc.n_channels_internal {
        ret +=
            (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: s32) -> s32) (cast(*void) silk_init_encoder_2))(
                ps_enc.state_fxx.data + 1,
                ps_enc.state_fxx[0].s_cmn.arch
            );
        fill_memory(ps_enc.s_stereo.pred_prev_q13.data, 0, ps_enc.s_stereo.pred_prev_q13.count * size_of(Int16));
        fill_memory(ps_enc.s_stereo.s_side.data, 0, ps_enc.s_stereo.s_side.count * size_of(Int16));
        ps_enc.s_stereo.mid_side_amp_q0[0] = 0;
        ps_enc.s_stereo.mid_side_amp_q0[1] = 1;
        ps_enc.s_stereo.mid_side_amp_q0[2] = 0;
        ps_enc.s_stereo.mid_side_amp_q0[3] = 1;
        ps_enc.s_stereo.width_prev_q14 = 0;
        ps_enc.s_stereo.smth_width_q14 = cast,no_check(Int16) (cast,no_check(Int32) (cast(float64) 16384.5));
        if ps_enc.n_channels_api == 2 {
            copy_memory(
                *ps_enc.state_fxx[1].s_cmn.resampler_state,
                *ps_enc.state_fxx[0].s_cmn.resampler_state,
                size_of(Silk_Resampler_State_Struct)
            );
            copy_memory(
                *ps_enc.state_fxx[1].s_cmn.in_hp_state,
                *ps_enc.state_fxx[0].s_cmn.in_hp_state,
                2 * cast(u64) size_of(Int32)
            );
        }
    }

    transition :=
        cast(s32) (enc_control.payload_size_ms != ps_enc.state_fxx[0].s_cmn.packet_size_ms ||
            ps_enc.n_channels_internal != enc_control.n_channels_internal);

    ps_enc.n_channels_api = enc_control.n_channels_api;
    ps_enc.n_channels_internal = enc_control.n_channels_internal;

    n_blocks_of10ms := 100 * n_samples_in / enc_control.api_sample_rate;
    tot_blocks := (ifx n_blocks_of10ms > 1 then n_blocks_of10ms >> 1 else 1);
    curr_block: s32 = 0;
    if PREFILL_FLAG != 0 {
        save_lp: Silk_LP_State = ---;

        if n_blocks_of10ms != 1 {
            return -101;
        }
        if PREFILL_FLAG == 2 {
            save_lp = ps_enc.state_fxx[0].s_cmn.s_lp;

            save_lp.saved_fs_k_hz = ps_enc.state_fxx[0].s_cmn.fs_k_hz;
        }

        n = 0;
        while n < enc_control.n_channels_internal {
            ret =
                (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: s32) -> s32) (cast(*void) silk_init_encoder_2))(
                    ps_enc.state_fxx.data + n,
                    ps_enc.state_fxx[n].s_cmn.arch
                );

            if PREFILL_FLAG == 2 {
                ps_enc.state_fxx[n].s_cmn.s_lp = save_lp;
            }
            (ret == 0);
            n += 1;
        }
        tmp_payload_size_ms = enc_control.payload_size_ms;
        enc_control.payload_size_ms = 10;
        tmp_complexity = enc_control.complexity;
        enc_control.complexity = 0;
        n = 0;
        while n < enc_control.n_channels_internal {
            ps_enc.state_fxx[n].s_cmn.controlled_since_last_payload = 0;
            ps_enc.state_fxx[n].s_cmn.prefill_flag = 1;
            n += 1;
        }
    } else {
        if n_blocks_of10ms * enc_control.api_sample_rate != 100 * n_samples_in || n_samples_in < 0 {
            return -101;
        }

        if 1000 * n_samples_in > enc_control.payload_size_ms * enc_control.api_sample_rate {
            return -101;
        }
    }

    n = 0;
    while n < enc_control.n_channels_internal {
        force_fs_k_hz := (ifx n == 1 then ps_enc.state_fxx[0].s_cmn.fs_k_hz else 0);
        if (ifx true { assignment_1: s32 = cast,no_check(s32) ((cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Silk_Enc_Control_Struct, _: s32, _: s32, _: s32) -> s32) (cast(*void) silk_control_encoder))(
            ps_enc.state_fxx.data + n,
            enc_control,
            ps_enc.allow_bandwidth_switch,
            n,
            force_fs_k_hz
        )); (ret) = assignment_1; assignment_1; }) != 0 {
            return ret;
        }
        if ps_enc.state_fxx[n].s_cmn.first_frame_after_reset != 0 || transition != 0 {
            i = 0;
            while i < ps_enc.state_fxx[0].s_cmn.n_frames_per_packet {
                ps_enc.state_fxx[n].s_cmn.lbrr_flags[i] = 0;
                i += 1;
            }
        }
        ps_enc.state_fxx[n].s_cmn.in_dtx = ps_enc.state_fxx[n].s_cmn.use_dtx;
        n += 1;
    }
    (enc_control.n_channels_internal == 1 || ps_enc.state_fxx[0].s_cmn.fs_k_hz == ps_enc.state_fxx[1].s_cmn.fs_k_hz);

    n_samples_to_buffer_max := 10 * n_blocks_of10ms * ps_enc.state_fxx[0].s_cmn.fs_k_hz;
    n_samples_from_input_max :=
        n_samples_to_buffer_max * ps_enc.state_fxx[0].s_cmn.api_fs_hz /
            (ps_enc.state_fxx[0].s_cmn.fs_k_hz * 1000);
    buf := cast(*Int16) c_transpiler_alloca(cast(u64) ((size_of(Int16) * cast,no_check(u64) n_samples_from_input_max)));
    while ((cast(s32) 1) != 0) {
        curr_n_bits_used_lbrr: s32 = 0;
        n_samples_to_buffer := ps_enc.state_fxx[0].s_cmn.frame_length - ps_enc.state_fxx[0].s_cmn.input_buf_ix;
        n_samples_to_buffer = min(n_samples_to_buffer, n_samples_to_buffer_max);
        n_samples_from_input =
            n_samples_to_buffer * ps_enc.state_fxx[0].s_cmn.api_fs_hz /
                (ps_enc.state_fxx[0].s_cmn.fs_k_hz * 1000);

        if enc_control.n_channels_api == 2 && enc_control.n_channels_internal == 2 {
            id := ps_enc.state_fxx[0].s_cmn.n_frames_encoded;
            n = 0;
            while n < n_samples_from_input {
                buf[n] = float2_int16(samples_in[2 * n]);
                n += 1;
            }

            if ps_enc.n_prev_channels_internal == 1 && id == 0 {
                copy_memory(
                    *ps_enc.state_fxx[1].s_cmn.resampler_state,
                    *ps_enc.state_fxx[0].s_cmn.resampler_state,
                    size_of(Silk_Resampler_State_Struct)
                );
            }

            ret +=
                silk_resampler(
                    *ps_enc.state_fxx[0].s_cmn.resampler_state,
                    ps_enc.state_fxx[0].s_cmn.input_buf.data + ps_enc.state_fxx[0].s_cmn.input_buf_ix + 2,
                    buf,
                    n_samples_from_input
                );
            ps_enc.state_fxx[0].s_cmn.input_buf_ix += n_samples_to_buffer;

            n_samples_to_buffer = ps_enc.state_fxx[1].s_cmn.frame_length - ps_enc.state_fxx[1].s_cmn.input_buf_ix;
            n_samples_to_buffer =
                ifx n_samples_to_buffer < 10 * n_blocks_of10ms * ps_enc.state_fxx[1].s_cmn.fs_k_hz then n_samples_to_buffer else 10 *
                    n_blocks_of10ms * ps_enc.state_fxx[1].s_cmn.fs_k_hz;
            n = 0;
            while n < n_samples_from_input {
                buf[n] = float2_int16(samples_in[2 * n + 1]);
                n += 1;
            }
            ret +=
                silk_resampler(
                    *ps_enc.state_fxx[1].s_cmn.resampler_state,
                    ps_enc.state_fxx[1].s_cmn.input_buf.data + ps_enc.state_fxx[1].s_cmn.input_buf_ix + 2,
                    buf,
                    n_samples_from_input
                );

            ps_enc.state_fxx[1].s_cmn.input_buf_ix += n_samples_to_buffer;
        } else if enc_control.n_channels_api == 2 && enc_control.n_channels_internal == 1 {
            n = 0;
            while n < n_samples_from_input {
                sum = cast,no_check(Int32) float2_int16(samples_in[2 * n] + samples_in[2 * n + 1]);
                buf[n] =
                    cast,no_check(Int16) ((ifx 1 == 1 then sum >> 1 +
                        sum & 1 else (sum >> (((1 - 1)) & 31) + 1) >> 1));
                n += 1;
            }
            ret +=
                silk_resampler(
                    *ps_enc.state_fxx[0].s_cmn.resampler_state,
                    ps_enc.state_fxx[0].s_cmn.input_buf.data + ps_enc.state_fxx[0].s_cmn.input_buf_ix + 2,
                    buf,
                    n_samples_from_input
                );

            if ps_enc.n_prev_channels_internal == 2 && ps_enc.state_fxx[0].s_cmn.n_frames_encoded == 0 {
                ret +=
                    silk_resampler(
                        *ps_enc.state_fxx[1].s_cmn.resampler_state,
                        ps_enc.state_fxx[1].s_cmn.input_buf.data + ps_enc.state_fxx[1].s_cmn.input_buf_ix + 2,
                        buf,
                        n_samples_from_input
                    );
                n = 0;
                while n < ps_enc.state_fxx[0].s_cmn.frame_length {
                    ps_enc.state_fxx[0].s_cmn.input_buf[ps_enc.state_fxx[0].s_cmn.input_buf_ix + n + 2] =
                        cast,no_check(Int16) (((cast(s32) ps_enc.state_fxx[0].s_cmn.input_buf[ps_enc.state_fxx[0].s_cmn.input_buf_ix + n + 2]) +
                            cast(s32) ps_enc.state_fxx[1].s_cmn.input_buf[ps_enc.state_fxx[1].s_cmn.input_buf_ix + n + 2]) >> 1);
                    n += 1;
                }
            }
            ps_enc.state_fxx[0].s_cmn.input_buf_ix += n_samples_to_buffer;
        } else {
            (enc_control.n_channels_api == 1 && enc_control.n_channels_internal == 1);
            n = 0;
            while n < n_samples_from_input {
                buf[n] = float2_int16(samples_in[n]);
                n += 1;
            }
            ret +=
                silk_resampler(
                    *ps_enc.state_fxx[0].s_cmn.resampler_state,
                    ps_enc.state_fxx[0].s_cmn.input_buf.data + ps_enc.state_fxx[0].s_cmn.input_buf_ix + 2,
                    buf,
                    n_samples_from_input
                );
            ps_enc.state_fxx[0].s_cmn.input_buf_ix += n_samples_to_buffer;
        }

        samples_in += n_samples_from_input * enc_control.n_channels_api;
        n_samples_in -= n_samples_from_input;

        ps_enc.allow_bandwidth_switch = 0;

        if ps_enc.state_fxx[0].s_cmn.input_buf_ix >= ps_enc.state_fxx[0].s_cmn.frame_length {
            (ps_enc.state_fxx[0].s_cmn.input_buf_ix == ps_enc.state_fxx[0].s_cmn.frame_length);
            (enc_control.n_channels_internal == 1 || ps_enc.state_fxx[1].s_cmn.input_buf_ix == ps_enc.state_fxx[1].s_cmn.frame_length);

            if ps_enc.state_fxx[0].s_cmn.n_frames_encoded == 0 && PREFILL_FLAG == 0 {
                i_cdf: [2] Uint8;
                i_cdf[0] =
                    cast,no_check(Uint8) (256 -
                        (cast(s32) 256) >> ((((ps_enc.state_fxx[0].s_cmn.n_frames_per_packet + 1) * enc_control.n_channels_internal)) & 31));
                ec_enc_icdf(ps_range_enc, 0, i_cdf.data, 8);
                curr_n_bits_used_lbrr = ec_tell_in_enc_api(ps_range_enc);

                n = 0;
                while n < enc_control.n_channels_internal {
                    lbrr_symbol = 0;
                    i = 0;
                    while i < ps_enc.state_fxx[n].s_cmn.n_frames_per_packet {
                        lbrr_symbol |=
                            cast,no_check(Int32) ((cast,no_check(Uint32) ps_enc.state_fxx[n].s_cmn.lbrr_flags[i]) << ((i) & 31));
                        i += 1;
                    }
                    ps_enc.state_fxx[n].s_cmn.lbrr_flag = cast(Int8) (lbrr_symbol > 0);
                    if lbrr_symbol != 0 && ps_enc.state_fxx[n].s_cmn.n_frames_per_packet > 1 {
                        ec_enc_icdf(
                            ps_range_enc,
                            lbrr_symbol - 1,
                            SILK_LBRR_FLAGS_I_CDF_PTR[ps_enc.state_fxx[n].s_cmn.n_frames_per_packet - 2],
                            8
                        );
                    }
                    n += 1;
                }

                i = 0;
                while i < ps_enc.state_fxx[0].s_cmn.n_frames_per_packet {
                    n = 0;
                    while n < enc_control.n_channels_internal {
                        if ps_enc.state_fxx[n].s_cmn.lbrr_flags[i] != 0 {
                            if enc_control.n_channels_internal == 2 && n == 0 {
                                silk_stereo_encode_pred(ps_range_enc, ps_enc.s_stereo.pred_ix[i].data);

                                if ps_enc.state_fxx[1].s_cmn.lbrr_flags[i] == 0 {
                                    silk_stereo_encode_mid_only(ps_range_enc, ps_enc.s_stereo.mid_only_flags[i]);
                                }
                            }

                            cond_coding: s32 = ifx i > 0 && ps_enc.state_fxx[n].s_cmn.lbrr_flags[i - 1] != 0
                                then cast(s32) 2
                                else 0;
                            (cast,no_check(#type (_: *Silk_Encoder_State, _: *Ec_Enc, _: s32, _: s32, _: s32)) (cast(*void) silk_encode_indices))(
                                *ps_enc.state_fxx[n].s_cmn,
                                ps_range_enc,
                                i,
                                1,
                                cond_coding
                            );
                            silk_encode_pulses(
                                ps_range_enc,
                                cast,no_check(s32) ps_enc.state_fxx[n].s_cmn.indices_lbrr[i].signal_type,
                                cast,no_check(s32) ps_enc.state_fxx[n].s_cmn.indices_lbrr[i].quant_offset_type,
                                ps_enc.state_fxx[n].s_cmn.pulses_lbrr[i].data,
                                ps_enc.state_fxx[n].s_cmn.frame_length
                            );
                        }
                        n += 1;
                    }
                    i += 1;
                }

                n = 0;
                while n < enc_control.n_channels_internal {
                    fill_memory(ps_enc.state_fxx[n].s_cmn.lbrr_flags.data, 0, 3 * cast(u64) size_of(s32));
                    n += 1;
                }
                curr_n_bits_used_lbrr = ec_tell_in_enc_api(ps_range_enc) - curr_n_bits_used_lbrr;
            }

            (cast,no_check(#type (_: *Silk_Encoder_State_FLP)) (cast(*void) silk_hp_variable_cutoff))(
                ps_enc.state_fxx.data
            );

            n_bits = enc_control.bit_rate * enc_control.payload_size_ms / 1000;

            if PREFILL_FLAG == 0 {
                if curr_n_bits_used_lbrr < 10 {
                    ps_enc.n_bits_used_lbrr = 0;
                } else if ps_enc.n_bits_used_lbrr < 10 {
                    ps_enc.n_bits_used_lbrr = curr_n_bits_used_lbrr;
                } else {
                    ps_enc.n_bits_used_lbrr = (ps_enc.n_bits_used_lbrr + curr_n_bits_used_lbrr) / 2;
                }
                n_bits = cast,no_check(s32) (n_bits - ps_enc.n_bits_used_lbrr);
            }

            n_bits = n_bits / ps_enc.state_fxx[0].s_cmn.n_frames_per_packet;

            if enc_control.payload_size_ms == 10 {
                target_rate_bps =
                    (cast,no_check(Int32) (cast,no_check(Int16) n_bits)) *
                        cast,no_check(Int32) (cast(Int16) 100);
            } else {
                target_rate_bps =
                    (cast,no_check(Int32) (cast,no_check(Int16) n_bits)) *
                        cast,no_check(Int32) (cast(Int16) 50);
            }

            target_rate_bps -= ps_enc.n_bits_exceeded * 1000 / 500;
            if PREFILL_FLAG == 0 && ps_enc.state_fxx[0].s_cmn.n_frames_encoded > 0 {
                bits_balance :=
                    ec_tell_in_enc_api(ps_range_enc) - ps_enc.n_bits_used_lbrr -
                        n_bits * ps_enc.state_fxx[0].s_cmn.n_frames_encoded;
                target_rate_bps -= bits_balance * 1000 / 500;
            }

            target_rate_bps =
                ifx enc_control.bit_rate > 5000 then (ifx target_rate_bps > enc_control.bit_rate then enc_control.bit_rate else (ifx target_rate_bps < 5000 then 5000 else target_rate_bps)) else (ifx target_rate_bps > 5000 then 5000 else (ifx target_rate_bps < enc_control.bit_rate then enc_control.bit_rate else target_rate_bps));

            if enc_control.n_channels_internal == 2 {
                (cast,no_check(#type (_: *Stereo_Enc_State, _: *Int16, _: *Int16, _: *[3] Int8, _: *Int8, _: *Int32, _: Int32, _: s32, _: s32, _: s32, _: s32)) (cast(*void) silk_stereo_lr_to_ms))(
                    *ps_enc.s_stereo,
                    ps_enc.state_fxx[0].s_cmn.input_buf.data + 2,
                    ps_enc.state_fxx[1].s_cmn.input_buf.data + 2,
                    ps_enc.s_stereo.pred_ix[ps_enc.state_fxx[0].s_cmn.n_frames_encoded].data,
                    ps_enc.s_stereo.mid_only_flags.data + ps_enc.state_fxx[0].s_cmn.n_frames_encoded,
                    m_starget_rates_bps.data,
                    target_rate_bps,
                    ps_enc.state_fxx[0].s_cmn.speech_activity_q8,
                    enc_control.to_mono,
                    ps_enc.state_fxx[0].s_cmn.fs_k_hz,
                    ps_enc.state_fxx[0].s_cmn.frame_length
                );
                if ps_enc.s_stereo.mid_only_flags[ps_enc.state_fxx[0].s_cmn.n_frames_encoded] == 0 {
                    if ps_enc.prev_decode_only_middle == 1 {
                        fill_memory(*ps_enc.state_fxx[1].s_shape, 0, size_of(Silk_Shape_State_FLP));
                        fill_memory(*ps_enc.state_fxx[1].s_cmn.s_nsq, 0, size_of(Silk_Nsq_State));
                        fill_memory(ps_enc.state_fxx[1].s_cmn.prev_nls_fq_q15.data, 0, 16 * cast(u64) size_of(Int16));
                        fill_memory(*ps_enc.state_fxx[1].s_cmn.s_lp.in_lp_state, 0, 2 * cast(u64) size_of(Int32));
                        ps_enc.state_fxx[1].s_cmn.prev_lag = 100;
                        ps_enc.state_fxx[1].s_cmn.s_nsq.lag_prev = 100;
                        ps_enc.state_fxx[1].s_shape.last_gain_index = 10;
                        ps_enc.state_fxx[1].s_cmn.prev_signal_type = 0;
                        ps_enc.state_fxx[1].s_cmn.s_nsq.prev_gain_q16 = 65536;
                        ps_enc.state_fxx[1].s_cmn.first_frame_after_reset = 1;
                    }
                    (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: s32)) (cast(*void) silk_encode_do_vad_flp))(
                        ps_enc.state_fxx.data + 1,
                        activity
                    );
                } else {
                    ps_enc.state_fxx[1].s_cmn.vad_flags[ps_enc.state_fxx[0].s_cmn.n_frames_encoded] = 0;
                }
                if PREFILL_FLAG == 0 {
                    silk_stereo_encode_pred(
                        ps_range_enc,
                        ps_enc.s_stereo.pred_ix[ps_enc.state_fxx[0].s_cmn.n_frames_encoded].data
                    );
                    if ps_enc.state_fxx[1].s_cmn.vad_flags[ps_enc.state_fxx[0].s_cmn.n_frames_encoded] == 0 {
                        silk_stereo_encode_mid_only(
                            ps_range_enc,
                            ps_enc.s_stereo.mid_only_flags[ps_enc.state_fxx[0].s_cmn.n_frames_encoded]
                        );
                    }
                }
            } else {
                copy_memory(
                    ps_enc.state_fxx[0].s_cmn.input_buf.data,
                    ps_enc.s_stereo.s_mid.data,
                    cast(u64) 2 * size_of(Int16)
                );
                copy_memory(
                    ps_enc.s_stereo.s_mid.data,
                    ps_enc.state_fxx[0].s_cmn.input_buf.data + ps_enc.state_fxx[0].s_cmn.frame_length,
                    cast(u64) 2 * size_of(Int16)
                );
            }
            (cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: s32)) (cast(*void) silk_encode_do_vad_flp))(
                ps_enc.state_fxx.data + 0,
                activity
            );

            n = 0;
            while n < enc_control.n_channels_internal {
                max_bits: s32 = ---;

                max_bits = enc_control.max_bits;
                if tot_blocks == 2 && curr_block == 0 {
                    max_bits = max_bits * 3 / 5;
                } else if tot_blocks == 3 {
                    if curr_block == 0 {
                        max_bits = max_bits * 2 / 5;
                    } else if curr_block == 1 {
                        max_bits = max_bits * 3 / 4;
                    }
                }
                use_cbr := cast(s32) (enc_control.use_cbr != 0 && curr_block == tot_blocks - 1);

                if enc_control.n_channels_internal == 1 {
                    channel_rate_bps = target_rate_bps;
                } else {
                    channel_rate_bps = m_starget_rates_bps[n];
                    if n == 0 && m_starget_rates_bps[1] > 0 {
                        use_cbr = 0;

                        max_bits -= enc_control.max_bits / (tot_blocks * 2);
                    }
                }

                if channel_rate_bps > 0 {
                    (cast,no_check(#type (_: *Silk_Encoder_State, _: Int32) -> s32) (cast(*void) silk_control_snr))(
                        *ps_enc.state_fxx[n].s_cmn,
                        channel_rate_bps
                    );

                    cond_coding: s32 = ifx ps_enc.state_fxx[0].s_cmn.n_frames_encoded - n <= 0
                        then cast(s32) 0
                        else ifx n > 0 && ps_enc.prev_decode_only_middle != 0
                            then cast(s32) 1
                            else 2;
                    if (ifx true { assignment_2: s32 = cast,no_check(s32) ((cast,no_check(#type (_: *Silk_Encoder_State_FLP, _: *Int32, _: *Ec_Enc, _: s32, _: s32, _: s32) -> s32) (cast(*void) silk_encode_frame_flp))(
                        ps_enc.state_fxx.data + n,
                        n_bytes_out,
                        ps_range_enc,
                        cond_coding,
                        max_bits,
                        use_cbr
                    )); (ret) = assignment_2; assignment_2; }) != 0 {
                    }
                }
                ps_enc.state_fxx[n].s_cmn.controlled_since_last_payload = 0;
                ps_enc.state_fxx[n].s_cmn.input_buf_ix = 0;
                ps_enc.state_fxx[n].s_cmn.n_frames_encoded += 1;
                n += 1;
            }
            ps_enc.prev_decode_only_middle =
                cast,no_check(s32) ps_enc.s_stereo.mid_only_flags[ps_enc.state_fxx[0].s_cmn.n_frames_encoded -
                    1];

            if n_bytes_out.* > 0 && ps_enc.state_fxx[0].s_cmn.n_frames_encoded == ps_enc.state_fxx[0].s_cmn.n_frames_per_packet {
                flags = 0;
                n = 0;
                while n < enc_control.n_channels_internal {
                    i = 0;
                    while i < ps_enc.state_fxx[n].s_cmn.n_frames_per_packet {
                        flags = cast,no_check(Int32) ((cast,no_check(Uint32) flags) << 1);
                        flags |= cast,no_check(s32) ps_enc.state_fxx[n].s_cmn.vad_flags[i];
                        i += 1;
                    }
                    flags = cast,no_check(Int32) ((cast,no_check(Uint32) flags) << 1);
                    flags |= cast,no_check(s32) ps_enc.state_fxx[n].s_cmn.lbrr_flag;
                    n += 1;
                }
                if PREFILL_FLAG == 0 {
                    ec_enc_patch_initial_bits(
                        ps_range_enc,
                        cast,no_check(u32) flags,
                        cast,no_check(u32) ((ps_enc.state_fxx[0].s_cmn.n_frames_per_packet + 1) *
                        enc_control.n_channels_internal)
                    );
                }

                if ps_enc.state_fxx[0].s_cmn.in_dtx != 0 && (enc_control.n_channels_internal == 1 || ps_enc.state_fxx[1].s_cmn.in_dtx != 0) {
                    n_bytes_out.* = 0;
                }

                ps_enc.n_bits_exceeded = cast,no_check(Int32) (ps_enc.n_bits_exceeded + (n_bytes_out.* * 8));
                ps_enc.n_bits_exceeded -= enc_control.bit_rate * enc_control.payload_size_ms / 1000;
                ps_enc.n_bits_exceeded =
                    ifx 0 > 10000 then (ifx ps_enc.n_bits_exceeded > 0 then 0 else (ifx ps_enc.n_bits_exceeded < 10000 then 10000 else ps_enc.n_bits_exceeded)) else (ifx ps_enc.n_bits_exceeded > 10000 then 10000 else (ifx ps_enc.n_bits_exceeded < 0 then 0 else ps_enc.n_bits_exceeded));

                speech_act_thr_for_switch_q8 =
                    cast,no_check(Int32) ((cast(Int64) (cast,no_check(Int32) (cast(float64) 13.300000190734864))) +
                        ((cast(Int64) (cast,no_check(Int32) (cast(float64) 3188.1708984375))) * cast,no_check(Int64) (cast,no_check(Int16) ps_enc.time_since_switch_allowed_ms)) >> 16);
                if ps_enc.state_fxx[0].s_cmn.speech_activity_q8 < speech_act_thr_for_switch_q8 {
                    ps_enc.allow_bandwidth_switch = 1;
                    ps_enc.time_since_switch_allowed_ms = 0;
                } else {
                    ps_enc.allow_bandwidth_switch = 0;
                    ps_enc.time_since_switch_allowed_ms += enc_control.payload_size_ms;
                }
            }

            if n_samples_in == 0 {
                break;
            }
        } else {
            break;
        }
        curr_block += 1;
    }

    ps_enc.n_prev_channels_internal = enc_control.n_channels_internal;

    enc_control.allow_bandwidth_switch = ps_enc.allow_bandwidth_switch;
    enc_control.in_w_bmode_without_variable_lp =
        cast(s32) (ps_enc.state_fxx[0].s_cmn.fs_k_hz == 16 &&
            ps_enc.state_fxx[0].s_cmn.s_lp.mode == 0);
    enc_control.internal_sample_rate =
        (cast,no_check(Int32) (cast,no_check(Int16) ps_enc.state_fxx[0].s_cmn.fs_k_hz)) *
            cast,no_check(Int32) (cast(Int16) 1000);
    enc_control.stereo_width_q14 =
        ifx enc_control.to_mono != 0 then 0 else cast,no_check(s32) ps_enc.s_stereo.smth_width_q14;
    if PREFILL_FLAG != 0 {
        enc_control.payload_size_ms = tmp_payload_size_ms;
        enc_control.complexity = tmp_complexity;
        n = 0;
        while n < enc_control.n_channels_internal {
            ps_enc.state_fxx[n].s_cmn.controlled_since_last_payload = 0;
            ps_enc.state_fxx[n].s_cmn.prefill_flag = 0;
            n += 1;
        }
    }

    enc_control.signal_type = cast,no_check(s32) ps_enc.state_fxx[0].s_cmn.indices.signal_type;
    enc_control.offset =
        cast,no_check(s32) SILK_QUANTIZATION_OFFSETS_Q10[(cast(s32) ps_enc.state_fxx[0].s_cmn.indices.signal_type) >> 1][ps_enc.state_fxx[0].s_cmn.indices.quant_offset_type];

    return ret;
}

float2_int16 :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int(x);
}

float2int :: (x: float32) -> Int32 {
    return mm_cvt_ss2si(mm_set_ss(x));
}

mm_set_ss :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

mm_cvt_ss2si :: inline (a: M128) -> s32 {
    return mm_cvtss_si32(a);
}

mm_cvtss_si32 :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

false__in_enc_api :: () -> s32 {
    return 0;
}

silk_clz16_in_enc_api :: (in16: Int16) -> Int32 {
    return 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) ((cast(s32) in16) << 16 | 0x8000)));
}

silk_clz32_in_enc_api :: (in32: Int32) -> Int32 {
    return ifx in32 != 0 then 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(cast,no_check(u32) in32)) else 32;
}

select_arch_in_enc_api :: () -> s32 {
    return 0;
}

silk_ror32_in_enc_api :: (a32: Int32, rot: s32) -> Int32 {
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

silk_min_int_in_enc_api :: (a: s32, b: s32) -> s32 {
    return min(a, b);
}

silk_min_16_in_enc_api :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (min(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_min_32_in_enc_api :: (a: Int32, b: Int32) -> Int32 {
    return min(a, b);
}

silk_min_64_in_enc_api :: (a: Int64, b: Int64) -> Int64 {
    return min(a, b);
}

silk_max_int_in_enc_api :: (a: s32, b: s32) -> s32 {
    return max(a, b);
}

silk_max_16_in_enc_api :: (a: Int16, b: Int16) -> Int16 {
    return cast,no_check(Int16) (max(cast,no_check(s32) a, cast,no_check(s32) b));
}

silk_max_32_in_enc_api :: (a: Int32, b: Int32) -> Int32 {
    return max(a, b);
}

silk_max_64_in_enc_api :: (a: Int64, b: Int64) -> Int64 {
    return max(a, b);
}

silk_clz64_in_enc_api :: (in: Int64) -> Int32 {
    in_upper := cast,no_check(Int32) (in >> 32);
    if in_upper == 0 {
        return 32 + silk_clz32_in_enc_api(cast,no_check(Int32) in);
    } else {
        return silk_clz32_in_enc_api(in_upper);
    }
}

silk_clz_frac_in_enc_api :: (in: Int32, lz: *Int32, frac_q7: *Int32) {
    lzeros := silk_clz32_in_enc_api(in);

    lz.* = lzeros;
    frac_q7.* = silk_ror32_in_enc_api(in, 24 - lzeros) & 0x7f;
}

silk_sqrt_approx_in_enc_api :: (x: Int32) -> Int32 {
    lz: Int32 = ---;
    frac_q7: Int32 = ---;

    if x <= 0 {
        return 0;
    }

    silk_clz_frac_in_enc_api(x, *lz, *frac_q7);

    y: Int32 = ifx lz & 1 != 0
        then cast(Int32) 32768
        else 46214;

    c_transpiler_compound_shr(*(y), ((((lz >> 1)) & 31)), Int32, Int32);

    y =
        cast,no_check(Int32) ((cast(Int64) y) +
            ((cast(Int64) y) * cast,no_check(Int64) (cast,no_check(Int16) ((cast,no_check(Int32) (cast(Int16) 213)) * cast,no_check(Int32) (cast,no_check(Int16) frac_q7)))) >> 16);

    return y;
}

silk_div32_var_q_in_enc_api :: (A32: Int32, B32: Int32, QRES: s32) -> Int32 {
    a_headrm := silk_clz32_in_enc_api((ifx A32 > 0 then A32 else -A32)) - 1;
    a32_nrm := cast,no_check(Int32) ((cast,no_check(Uint32) A32) << ((a_headrm) & 31));
    b_headrm := silk_clz32_in_enc_api((ifx B32 > 0 then B32 else -B32)) - 1;
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

silk_inverse32_var_q_in_enc_api :: (B32: Int32, QRES: s32) -> Int32 {
    b_headrm := silk_clz32_in_enc_api((ifx B32 > 0 then B32 else -B32)) - 1;
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

float2_int24 :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int(x);
}

silk_sigmoid :: (x: float32) -> float32 {
    return cast,no_check(float32) (1.0 / (1.0 + c_transpiler_math_exp(cast,no_check(float64) (-x))));
}

silk_float2int :: (x: float32) -> Int32 {
    return float2int(x);
}

silk_float2short_array :: (out: *Int16, in: *float32, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] =
            cast,no_check(Int16) ((ifx float2int(in[k]) > 0x7fff then 0x7fff else (ifx float2int(in[k]) < cast,no_check(s32) (cast(Int16) -32768) then cast,no_check(s32) (cast(Int16) -32768) else float2int(in[k]))));
        k -= 1;
    }
}

silk_short2float_array :: (out: *float32, in: *Int16, length: Int32) {
    k := length - 1;
    while k >= 0 {
        out[k] = cast,no_check(float32) in[k];
        k -= 1;
    }
}

silk_log2 :: (x: float64) -> float32 {
    return cast,no_check(float32) (3.32192809488736 * c_transpiler_math_log10(x));
}

M128 :: [4] float32;

V4sf :: [4] float32;

Silk_Encoder :: struct {
    s_stereo: Stereo_Enc_State #align 8;
    n_bits_used_lbrr: Int32 #align 1;
    n_bits_exceeded: Int32 #align 1;
    n_channels_api: s32 #align 1;
    n_channels_internal: s32 #align 1;
    n_prev_channels_internal: s32 #align 1;
    time_since_switch_allowed_ms: s32 #align 1;
    allow_bandwidth_switch: s32 #align 1;
    prev_decode_only_middle: s32 #align 1;
    state_fxx: [2] Silk_Encoder_State_FLP #align 1;
} #no_padding;

Silk_Encoder_State_FLP :: struct {
    s_cmn: Silk_Encoder_State #align 8;
    s_shape: Silk_Shape_State_FLP #align 1;
    x_buf: [720] float32 #align 1;
    ltp_corr: float32 #align 1;
} #no_padding;

Silk_Enc_Control_Struct :: struct {
    n_channels_api: Int32;
    n_channels_internal: Int32;
    api_sample_rate: Int32;
    max_internal_sample_rate: Int32;
    min_internal_sample_rate: Int32;
    desired_internal_sample_rate: Int32;
    payload_size_ms: s32;
    bit_rate: Int32;
    packet_loss_percentage: s32;
    complexity: s32;
    use_in_band_fec: s32;
    use_dred: s32;
    lbrr_coded: s32;
    use_dtx: s32;
    use_cbr: s32;
    max_bits: s32;
    to_mono: s32;
    can_switch: s32;
    reduced_dependency: s32;
    internal_sample_rate: Int32;
    allow_bandwidth_switch: s32;
    in_w_bmode_without_variable_lp: s32;
    stereo_width_q14: s32;
    switch_ready: s32;
    signal_type: s32;
    offset: s32;
}

Silk_LP_State :: struct {
    in_lp_state: [2] Int32;
    transition_frame_no: Int32;
    mode: s32;
    saved_fs_k_hz: Int32;
}

Silk_Encoder_State :: struct {
    in_hp_state: [2] Int32 #align 8;
    variable_hp_smth1_q15: Int32 #align 1;
    variable_hp_smth2_q15: Int32 #align 1;
    s_lp: Silk_LP_State #align 1;
    s_vad: Silk_VAD_State #align 1;
    s_nsq: Silk_Nsq_State #align 1;
    prev_nls_fq_q15: [16] Int16 #align 1;
    speech_activity_q8: s32 #align 1;
    allow_bandwidth_switch: s32 #align 1;
    lbr_rprev_last_gain_index: Int8 #align 1;
    prev_signal_type: Int8 #align 1;
    layout_padding_0: [2] u8 #align 1;
    prev_lag: s32 #align 1;
    pitch_lpc_win_length: s32 #align 1;
    max_pitch_lag: s32 #align 1;
    api_fs_hz: Int32 #align 1;
    prev_api_fs_hz: Int32 #align 1;
    max_internal_fs_hz: s32 #align 1;
    min_internal_fs_hz: s32 #align 1;
    desired_internal_fs_hz: s32 #align 1;
    fs_k_hz: s32 #align 1;
    nb_subfr: s32 #align 1;
    frame_length: s32 #align 1;
    subfr_length: s32 #align 1;
    ltp_mem_length: s32 #align 1;
    la_pitch: s32 #align 1;
    la_shape: s32 #align 1;
    shape_win_length: s32 #align 1;
    target_rate_bps: Int32 #align 1;
    packet_size_ms: s32 #align 1;
    packet_loss_perc: s32 #align 1;
    frame_counter: Int32 #align 1;
    complexity: s32 #align 1;
    n_states_delayed_decision: s32 #align 1;
    use_interpolated_nls_fs: s32 #align 1;
    shaping_lpc_order: s32 #align 1;
    predict_lpc_order: s32 #align 1;
    pitch_estimation_complexity: s32 #align 1;
    pitch_estimation_lpc_order: s32 #align 1;
    pitch_estimation_threshold_q16: Int32 #align 1;
    sum_log_gain_q7: Int32 #align 1;
    nlsf_msvq_survivors: s32 #align 1;
    first_frame_after_reset: s32 #align 1;
    controlled_since_last_payload: s32 #align 1;
    warping_q16: s32 #align 1;
    use_cbr: s32 #align 1;
    prefill_flag: s32 #align 1;
    layout_padding_1: [4] u8 #align 1;
    pitch_lag_low_bits_i_cdf: *Uint8 #align 1;
    pitch_contour_i_cdf: *Uint8 #align 1;
    ps_nlsf_cb: *Silk_NLSF_CB_Struct #align 1;
    input_quality_bands_q15: [4] s32 #align 1;
    input_tilt_q15: s32 #align 1;
    snr_d_b_q7: s32 #align 1;
    vad_flags: [3] Int8 #align 1;
    lbrr_flag: Int8 #align 1;
    lbrr_flags: [3] s32 #align 1;
    indices: Side_Info_Indices #align 1;
    pulses: [320] Int8 #align 1;
    arch: s32 #align 1;
    input_buf: [322] Int16 #align 1;
    input_buf_ix: s32 #align 1;
    n_frames_per_packet: s32 #align 1;
    n_frames_encoded: s32 #align 1;
    n_channels_api: s32 #align 1;
    n_channels_internal: s32 #align 1;
    channel_nb: s32 #align 1;
    frames_since_onset: s32 #align 1;
    ec_prev_signal_type: s32 #align 1;
    ec_prev_lag_index: Int16 #align 1;
    layout_padding_2: [2] u8 #align 1;
    resampler_state: Silk_Resampler_State_Struct #align 1;
    use_dtx: s32 #align 1;
    in_dtx: s32 #align 1;
    no_speech_counter: s32 #align 1;
    use_in_band_fec: s32 #align 1;
    lbrr_enabled: s32 #align 1;
    lbrr_gain_increases: s32 #align 1;
    indices_lbrr: [3] Side_Info_Indices #align 1;
    pulses_lbrr: [3] [320] Int8 #align 1;
    layout_padding_3: [4] u8 #align 1;
} #no_padding;

Stereo_Enc_State :: struct {
    pred_prev_q13: [2] Int16;
    s_mid: [2] Int16;
    s_side: [2] Int16;
    mid_side_amp_q0: [4] Int32;
    smth_width_q14: Int16;
    width_prev_q14: Int16;
    silent_side_len: Int16;
    pred_ix: [3] [2] [3] Int8;
    mid_only_flags: [3] Int8;
}

Silk_Shape_State_FLP :: struct {
    last_gain_index: Int8;
    harm_shape_gain_smth: float32;
    tilt_smth: float32;
}

Silk_Nsq_State :: struct {
    xq: [640] Int16;
    s_ltp_shp_q14: [640] Int32;
    s_lpc_q14: [96] Int32;
    s_ar2_q14: [24] Int32;
    s_lf_ar_shp_q14: Int32;
    s_diff_shp_q14: Int32;
    lag_prev: s32;
    s_ltp_buf_idx: s32;
    s_ltp_shp_buf_idx: s32;
    rand_seed: Int32;
    prev_gain_q16: Int32;
    rewhite_flag: s32;
}

Silk_VAD_State :: struct {
    ana_state: [2] Int32;
    ana_state1: [2] Int32;
    ana_state2: [2] Int32;
    xnrg_subfr: [4] Int32;
    nrg_ratio_smth_q8: [4] Int32;
    h_pstate: Int16;
    nl: [4] Int32;
    inv_nl: [4] Int32;
    noise_level_bias: [4] Int32;
    counter: Int32;
}

