TRIM_ICDF_in_analysis: [11] u8;

SPREAD_ICDF_in_analysis: [4] u8;

TAPSET_ICDF_in_analysis: [3] u8;

STD_FEATURE_BIAS: [9] float32;

DCT_TABLE: [128] float32;

TBANDS: [19] s32;

ANALYSIS_WINDOW: [240] float32;

ec_range_bytes_in_analysis :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_analysis :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_analysis :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_analysis :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_analysis :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_analysis :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_analysis :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_analysis :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_analysis :: (size: u64) -> *void {
    return alloc__in_analysis(size);
}

free__in_analysis :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_analysis :: (y: float32, x: float32) -> float32 {
    x2: float32 = ---;
    x2 = x * x;
    y2 := y * y;

    if c_transpiler_float_less((x2 + y2), 1.0e-18) {
        return 0.0;
    }
    if c_transpiler_float_less(x2, y2) {
        den := (y2 + 0.67848403 * x2) * (y2 + 0.08595542 * x2);
        return -x * y * (y2 + 0.43157974 * x2) / den + (ifx c_transpiler_float_less(y, 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867);
    } else {
        den := (x2 + 0.67848403 * y2) * (x2 + 0.08595542 * y2);
        return (x * y * (x2 + 0.43157974 * y2) / den + (ifx c_transpiler_float_less(y, 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867)) - (ifx c_transpiler_float_less((x * y), 0.0) then cast(float32) -1.5707963705062867 else cast(float32) 1.5707963705062867);
    }
}

celt_maxabs16_in_analysis :: (x: *Val16, len: s32) -> Val32 {
    maxval: Val16 = 0.0;
    minval: Val16 = 0.0;
    if 0 < len {
        for i: 0..len - 1 {
            maxval = ifx c_transpiler_float_greater(maxval, x[i]) then maxval else x[i];
            minval = ifx c_transpiler_float_less(minval, x[i]) then minval else x[i];
        }
    }
    return ifx c_transpiler_float_greater(maxval, -minval) then maxval else -minval;
}

celt_atan_norm_in_analysis :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_analysis :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_analysis(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_analysis(x / y);
    }
}

celt_cos_norm2_in_analysis :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

select_arch_in_analysis :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_analysis :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_analysis :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

align_in_analysis :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

tonality_analysis_init :: (tonal: *Tonality_Analysis_State, fs: Int32) {
    tonal.arch = select_arch_in_analysis();
    tonal.fs = fs;

    tonality_analysis_reset(tonal);
}

tonality_analysis_reset :: (tonal: *Tonality_Analysis_State) {
    start := cast(*s8) *tonal.angle;
    fill_memory(start, 0, size_of(Tonality_Analysis_State) - cast,no_check(u64) (start - cast(*s8) tonal));
}

tonality_get_info :: (tonal: *Tonality_Analysis_State, info_out: *Analysis_Info, len: s32) {
    tonality_max: float32 = ---;
    tonality_avg: float32 = ---;

    mpos, vpos: s32 = ---;

    pos := tonal.read_pos;
    curr_lookahead := tonal.write_pos - tonal.read_pos;
    if curr_lookahead < 0 {
        curr_lookahead += 100;
    }

    tonal.read_subframe = cast,no_check(s32) (tonal.read_subframe + (len / (tonal.fs / 400)));
    while tonal.read_subframe >= 8 {
        tonal.read_subframe -= 8;
        tonal.read_pos += 1;
    }
    if tonal.read_pos >= 100 {
        tonal.read_pos -= 100;
    }

    if len > tonal.fs / 50 && pos != tonal.write_pos {
        pos += 1;
        if pos == 100 {
            pos = 0;
        }
    }
    if pos == tonal.write_pos {
        pos -= 1;
    }
    if pos < 0 {
        pos = cast,no_check(s32) ((100 - 1));
    }
    pos0 := pos;
    copy_memory(
        info_out,
        tonal.info.data + pos,
        (cast,no_check(u64) (1)) * size_of(Analysis_Info) + cast,no_check(u64) (0 * (info_out - tonal.info.data + pos))
    );
    if info_out.valid == 0 {
        return;
    }
    tonality_avg = info_out.tonality;
    tonality_max = tonality_avg;
    tonality_count: s32 = 1;

    bandwidth_span: s32 = 6;

    i: s32 = 0;
    while i < 3 {
        pos += 1;
        if pos == 100 {
            pos = 0;
        }
        if pos == tonal.write_pos {
            break;
        }
        tonality_max =
            ifx c_transpiler_float_greater(tonality_max, tonal.info[pos].tonality) then tonality_max else tonal.info[pos].tonality;
        tonality_avg += tonal.info[pos].tonality;
        tonality_count += 1;
        info_out.bandwidth =
            ifx info_out.bandwidth > tonal.info[pos].bandwidth then info_out.bandwidth else tonal.info[pos].bandwidth;
        bandwidth_span -= 1;
        i += 1;
    }
    pos = pos0;

    i = 0;
    while i < bandwidth_span {
        pos -= 1;
        if pos < 0 {
            pos = cast,no_check(s32) ((100 - 1));
        }
        if pos == tonal.write_pos {
            break;
        }
        info_out.bandwidth =
            ifx info_out.bandwidth > tonal.info[pos].bandwidth then info_out.bandwidth else tonal.info[pos].bandwidth;
        i += 1;
    }
    info_out.tonality =
        ifx c_transpiler_float_greater((tonality_avg / tonality_count), (tonality_max - 0.2)) then tonality_avg / tonality_count else tonality_max -
            0.2;

    vpos = pos0;
    mpos = vpos;

    if curr_lookahead > 15 {
        mpos += 5;
        if mpos >= 100 {
            mpos -= 100;
        }
        vpos += 1;
        if vpos >= 100 {
            vpos -= 100;
        }
    }

    prob_min: float32 = 1.0;
    prob_max: float32 = 0.0;
    vad_prob := tonal.info[vpos].activity_probability;
    prob_count := (ifx c_transpiler_float_greater(0.1, vad_prob) then 0.1 else vad_prob);
    prob_avg := (ifx c_transpiler_float_greater(0.1, vad_prob) then 0.1 else vad_prob) * tonal.info[mpos].music_prob;
    while ((cast(s32) 1) != 0) {
        mpos += 1;
        if mpos == 100 {
            mpos = 0;
        }
        if mpos == tonal.write_pos {
            break;
        }
        vpos += 1;
        if vpos == 100 {
            vpos = 0;
        }
        if vpos == tonal.write_pos {
            break;
        }
        pos_vad := tonal.info[vpos].activity_probability;
        prob_min =
            ifx c_transpiler_float_less(((prob_avg - 10.0 * (vad_prob - pos_vad)) / prob_count), prob_min) then (prob_avg - 10.0 * (vad_prob - pos_vad)) /
                prob_count else prob_min;
        prob_max =
            ifx c_transpiler_float_greater(((prob_avg + 10.0 * (vad_prob - pos_vad)) / prob_count), prob_max) then (prob_avg + 10.0 * (vad_prob - pos_vad)) /
                prob_count else prob_max;
        prob_count += (ifx c_transpiler_float_greater(0.1, pos_vad) then 0.1 else pos_vad);
        prob_avg += (ifx c_transpiler_float_greater(0.1, pos_vad) then 0.1 else pos_vad) * tonal.info[mpos].music_prob;
    }
    info_out.music_prob = prob_avg / prob_count;
    prob_min = ifx c_transpiler_float_less((prob_avg / prob_count), prob_min) then prob_avg / prob_count else prob_min;
    prob_max =
        ifx c_transpiler_float_greater((prob_avg / prob_count), prob_max) then prob_avg /
            prob_count else prob_max;
    prob_min = ifx c_transpiler_float_greater(prob_min, 0.0) then prob_min else 0.0;
    prob_max = ifx c_transpiler_float_less(prob_max, 1.0) then prob_max else 1.0;

    if curr_lookahead < 10 {
        pmin: float32 = ---;
        pmin = prob_min;
        pmax := prob_max;
        pos = pos0;

        i = 0;
        while i < (ifx tonal.count - 1 < 15 then tonal.count - 1 else 15) {
            pos -= 1;
            if pos < 0 {
                pos = cast,no_check(s32) ((100 - 1));
            }
            pmin =
                ifx c_transpiler_float_less(pmin, tonal.info[pos].music_prob) then pmin else tonal.info[pos].music_prob;
            pmax =
                ifx c_transpiler_float_greater(pmax, tonal.info[pos].music_prob) then pmax else tonal.info[pos].music_prob;
            i += 1;
        }

        pmin = ifx c_transpiler_float_greater(0.0, (pmin - 0.1 * vad_prob)) then 0.0 else pmin - 0.1 * vad_prob;
        pmax = ifx c_transpiler_float_less(1.0, (pmax + 0.1 * vad_prob)) then 1.0 else pmax + 0.1 * vad_prob;
        prob_min += (1.0 - 0.1 * cast,no_check(float32) curr_lookahead) * (pmin - prob_min);
        prob_max += (1.0 - 0.1 * cast,no_check(float32) curr_lookahead) * (pmax - prob_max);
    }
    info_out.music_prob_min = prob_min;
    info_out.music_prob_max = prob_max;
}

run_analysis :: (
    analysis: *Tonality_Analysis_State,
    celt_mode: *Custom_Mode,
    analysis_pcm: *void,
    analysis_frame_size: s32,
    frame_size: s32,
    c1: s32,
    c2: s32,
    c: s32,
    fs: Int32,
    lsb_depth: s32,
    downmix: Downmix_Func,
    analysis_info: *Analysis_Info
) {
    offset: s32 = ---;
    pcm_len: s32 = ---;

    analysis_frame_size -= analysis_frame_size & 1;
    if analysis_pcm != null {
        analysis_frame_size =
            ifx (cast,no_check(Int32) ((100 - 5))) * fs /
                50 < analysis_frame_size then (cast,no_check(Int32) ((100 - 5))) * fs / 50 else analysis_frame_size;

        pcm_len = analysis_frame_size - analysis.analysis_offset;
        offset = analysis.analysis_offset;
        while pcm_len > 0 {
            tonality_analysis(
                analysis,
                celt_mode,
                analysis_pcm,
                (ifx fs / 50 < pcm_len then fs / 50 else pcm_len),
                offset,
                c1,
                c2,
                c,
                lsb_depth,
                cast,no_check(Downmix_Func) (downmix)
            );
            offset = cast,no_check(s32) (offset + (fs / 50));
            pcm_len = cast,no_check(s32) (pcm_len - (fs / 50));
        }
        analysis.analysis_offset = analysis_frame_size;

        analysis.analysis_offset -= frame_size;
    }

    tonality_get_info(analysis, analysis_info, frame_size);
}

tonality_analysis :: (
    tonal: *Tonality_Analysis_State,
    celt_mode: *Custom_Mode,
    x: *void,
    len: s32,
    offset: s32,
    c1: s32,
    c2: s32,
    c: s32,
    lsb_depth: s32,
    downmix: Downmix_Func
) {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    b: s32 = ---;

    n: s32 = 480;
    n2: s32 = 240;
    a := tonal.angle.data;
    d_a := tonal.d_angle.data;
    d2_a := tonal.d2_angle.data;

    band_tonality: [18] float32 = ---;
    log_e: [18] float32 = ---;
    bfcc: [8] float32 = ---;
    features: [25] float32 = ---;

    PI4: float32 = cast(float32) 97.40908813476563;
    slope: float32 = 0.0;

    frame_probs: [2] float32 = ---;

    is_masked: [19] s32 = ---;
    bandwidth: s32 = 0;
    max_e: float32 = 0.0;

    tonality2: [240] float32 = ---;
    mid_e: [8] float32 = ---;
    spec_variability: float32 = 0.0;
    band_log2: [19] float32 = ---;
    leakage_from: [19] float32 = ---;
    leakage_to: [19] float32 = ---;
    layer_out: [32] float32 = ---;

    if tonal.initialized == 0 {
        tonal.mem_fill = 240;
        tonal.initialized = 1;
    }
    alpha := 1.0 / cast,no_check(float32) ((ifx 10 < 1 + tonal.count then 10 else 1 + tonal.count));
    alpha_e := 1.0 / cast,no_check(float32) ((ifx 25 < 1 + tonal.count then 25 else 1 + tonal.count));

    alpha_e2 := 1.0 / cast,no_check(float32) ((ifx 100 < 1 + tonal.count then 100 else 1 + tonal.count));
    if tonal.count <= 1 {
        alpha_e2 = 1.0;
    }

    if tonal.fs == 48000 {
        len /= 2;
        offset /= 2;
    } else if tonal.fs == 16000 {
        len = 3 * len / 2;
        offset = 3 * offset / 2;
    }

    kfft := celt_mode.mdct.kfft[0];
    tonal.hp_ener_accum +=
        downmix_and_resample(
            cast,no_check(Downmix_Func) (downmix),
            x,
            tonal.inmem.data + tonal.mem_fill,
            tonal.downmix_state.data,
            (ifx len < 720 - tonal.mem_fill then len else 720 - tonal.mem_fill),
            offset,
            c1,
            c2,
            c,
            tonal.fs
        );
    if tonal.mem_fill + len < 720 {
        tonal.mem_fill += len;

        return;
    }
    hp_ener := tonal.hp_ener_accum;
    info := tonal.info.data + c_transpiler_post_increment(*(tonal.write_pos));
    if tonal.write_pos >= 100 {
        tonal.write_pos -= 100;
    }

    is_silence := is_digital_silence(tonal.inmem.data, 720, 1, lsb_depth);

    in := cast(*Kiss_Fft_Cpx) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Kiss_Fft_Cpx))) * 480)));
    out := cast(*Kiss_Fft_Cpx) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(Kiss_Fft_Cpx))) * 480)));
    tonality := cast(*float32) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(float32))) * 240)));
    noisiness := cast(*float32) c_transpiler_alloca(cast(u64) (((cast,no_check(u64) (size_of(float32))) * 240)));
    i: s32 = 0;
    while i < n2 {
        w := ANALYSIS_WINDOW[i];
        in[i].r = w * tonal.inmem[i];
        in[i].i = w * tonal.inmem[n2 + i];
        in[n - i - 1].r = w * tonal.inmem[n - i - 1];
        in[n - i - 1].i = w * tonal.inmem[n + n2 - i - 1];
        i += 1;
    }
    move_memory(
        tonal.inmem.data,
        tonal.inmem.data + 720 - 240,
        (cast,no_check(u64) (240)) * size_of(Val32) +
        cast,no_check(u64) (0 * (tonal.inmem.data - (tonal.inmem.data + 720 - 240)))
    );
    remaining := len - (720 - tonal.mem_fill);
    tonal.hp_ener_accum =
        downmix_and_resample(
            cast,no_check(Downmix_Func) (downmix),
            x,
            tonal.inmem.data + 240,
            tonal.downmix_state.data,
            remaining,
            offset + 720 - tonal.mem_fill,
            c1,
            c2,
            c,
            tonal.fs
        );
    tonal.mem_fill = 240 + remaining;
    if is_silence != 0 {
        prev_pos := tonal.write_pos - 2;
        if prev_pos < 0 {
            prev_pos += 100;
        }
        copy_memory(
            info,
            tonal.info.data + prev_pos,
            (cast,no_check(u64) (1)) * size_of(Analysis_Info) +
            cast,no_check(u64) (0 * (info - tonal.info.data + prev_pos))
        );

        return;
    }
    tonal.arch;
    fft_c(kfft, in, out);

    if c_transpiler_float_not_equal(out[0].r, out[0].r) {
        info.valid = 0;

        return;
    }

    i = 1;
    while i < n2 {
        x1r := out[i].r + out[n - i].r;
        x1i := out[i].i - out[n - i].i;
        x2r := out[i].i + out[n - i].i;
        x2i := out[n - i].r - out[i].r;

        angle := (cast(float32) 0.15915493667125703) * fast_atan2f_in_analysis(x1i, x1r);
        d_angle := angle - a[i];
        d2_angle := d_angle - d_a[i];

        angle2 := (cast(float32) 0.15915493667125703) * fast_atan2f_in_analysis(x2i, x2r);
        d_angle2 := angle2 - angle;
        d2_angle2 := d_angle2 - d_angle;

        mod1 := d2_angle - cast,no_check(float32) float2int_in_analysis(d2_angle);
        noisiness[i] = cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) mod1);
        mod1 *= mod1;
        mod1 *= mod1;

        mod2 := d2_angle2 - cast,no_check(float32) float2int_in_analysis(d2_angle2);
        noisiness[i] += cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) mod2);
        mod2 *= mod2;
        mod2 *= mod2;

        avg_mod := 0.25 * (d2_a[i] + mod1 + 2.0 * mod2);

        tonality[i] = 1.0 / (1.0 + (cast(float32) 62341.81640625) * avg_mod) - 0.015;

        tonality2[i] = 1.0 / (1.0 + (cast(float32) 62341.81640625) * mod2) - 0.015;

        a[i] = angle2;
        d_a[i] = d_angle2;
        d2_a[i] = mod2;
        i += 1;
    }
    i = 2;
    while i < n2 - 1 {
        tt :=
            (ifx c_transpiler_float_less(tonality2[i], (ifx c_transpiler_float_greater(tonality2[i - 1], tonality2[i + 1]) then tonality2[i - 1] else tonality2[i + 1])) then tonality2[i] else (ifx c_transpiler_float_greater(tonality2[i - 1], tonality2[i + 1]) then tonality2[i -
                1] else tonality2[i + 1]));
        tonality[i] = 0.9 * (ifx c_transpiler_float_greater(tonality[i], (tt - 0.1)) then tonality[i] else tt - 0.1);
        i += 1;
    }
    frame_tonality: float32 = 0.0;
    max_frame_tonality: float32 = 0.0;

    info.activity = 0.0;
    frame_noisiness: float32 = 0.0;
    frame_stationarity: float32 = 0.0;
    if tonal.count == 0 {
        b = 0;
        while b < 18 {
            tonal.low_e[b] = cast(float32) 10000000000.0;
            tonal.high_e[b] = cast(float32) -10000000000.0;
            b += 1;
        }
    }
    relative_e: float32 = 0.0;
    frame_loudness: float32 = 0.0;

    {
        e: float32 = 0.0;
        x1r: float32 = ---;
        x1r = 2.0 * out[0].r;
        x2r := 2.0 * out[0].i;
        e = x1r * x1r + x2r * x2r;
        i = 1;
        while i < 4 {
            bin_e :=
                out[i].r * out[i].r + out[n - i].r * out[n - i].r +
                    out[i].i * out[i].i + out[n - i].i * out[n - i].i;
            e += bin_e;
            i += 1;
        }
        e = (cast(float32) 9.313225746154786e-10) * e;
        band_log2[0] =
            (cast(float32) 0.7213475108146668) *
                cast,no_check(float32) c_transpiler_math_log(cast,no_check(float64) (e + 1.0e-10));
    }
    b = 0;
    while b < 18 {
        e: float32 = 0.0;
        t_e: float32 = 0.0;
        n_e: float32 = 0.0;
        l1, l2: float32 = ---;

        i = TBANDS[b];
        while i < TBANDS[b + 1] {
            bin_e :=
                out[i].r * out[i].r + out[n - i].r * out[n - i].r +
                    out[i].i * out[i].i + out[n - i].i * out[n - i].i;
            bin_e = (cast(float32) 9.313225746154786e-10) * bin_e;
            e += bin_e;
            t_e += bin_e * (ifx c_transpiler_float_greater(0.0, tonality[i]) then 0.0 else tonality[i]);
            n_e += bin_e * 2.0 * (0.5 - noisiness[i]);
            i += 1;
        }

        if !(c_transpiler_float_less(e, 1.0e9)) || c_transpiler_float_not_equal(e, e) {
            info.valid = 0;

            return;
        }

        tonal.e[tonal.e_count][b] = e;
        frame_noisiness += n_e / (1.0e-15 + e);

        frame_loudness += cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) (e + 1.0e-10));
        log_e[b] = cast,no_check(float32) c_transpiler_math_log(cast,no_check(float64) (e + 1.0e-10));
        band_log2[b + 1] =
            (cast(float32) 0.7213475108146668) *
                cast,no_check(float32) c_transpiler_math_log(cast,no_check(float64) (e + 1.0e-10));
        tonal.log_e[tonal.e_count][b] = log_e[b];
        if tonal.count == 0 {
            tonal.low_e[b] = log_e[b];
            tonal.high_e[b] = tonal.low_e[b];
        }
        if c_transpiler_float_greater(cast,no_check(float64) tonal.high_e[b], ((cast,no_check(float64) tonal.low_e[b]) + 7.5)) {
            if c_transpiler_float_greater((tonal.high_e[b] - log_e[b]), (log_e[b] - tonal.low_e[b])) {
                tonal.high_e[b] -= 0.01;
            } else {
                tonal.low_e[b] += 0.01;
            }
        }
        if c_transpiler_float_greater(log_e[b], tonal.high_e[b]) {
            tonal.high_e[b] = log_e[b];
            tonal.low_e[b] =
                ifx c_transpiler_float_greater((tonal.high_e[b] - 15.0), tonal.low_e[b]) then tonal.high_e[b] -
                    15.0 else tonal.low_e[b];
        } else if c_transpiler_float_less(log_e[b], tonal.low_e[b]) {
            tonal.low_e[b] = log_e[b];
            tonal.high_e[b] =
                ifx c_transpiler_float_less((tonal.low_e[b] + 15.0), tonal.high_e[b]) then tonal.low_e[b] +
                    15.0 else tonal.high_e[b];
        }
        relative_e += (log_e[b] - tonal.low_e[b]) / (1.0e-5 + (tonal.high_e[b] - tonal.low_e[b]));

        l2 = 0.0;
        l1 = l2;
        i = 0;
        while i < 8 {
            l1 += cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) tonal.e[i][b]);
            l2 += tonal.e[i][b];
            i += 1;
        }

        stationarity :=
            (ifx c_transpiler_float_less(0.99, (l1 / cast,no_check(float32) c_transpiler_libm_sqrt(1.0e-15 + cast,no_check(float64) (8.0 * l2)))) then 0.99 else l1 /
                cast,no_check(float32) c_transpiler_libm_sqrt(1.0e-15 + cast,no_check(float64) (8.0 * l2)));
        stationarity *= stationarity;
        stationarity *= stationarity;
        frame_stationarity += stationarity;

        band_tonality[b] =
            ifx c_transpiler_float_greater((t_e / (1.0e-15 + e)), (stationarity * tonal.prev_band_tonality[b])) then t_e /
                (1.0e-15 + e) else stationarity * tonal.prev_band_tonality[b];

        frame_tonality += band_tonality[b];
        if b >= 18 - 9 {
            frame_tonality -= band_tonality[b - 18 + 9];
        }

        max_frame_tonality =
            ifx c_transpiler_float_greater(max_frame_tonality, ((1.0 + 0.03 * cast,no_check(float32) (b - 18)) * frame_tonality)) then max_frame_tonality else (1.0 + 0.03 * cast,no_check(float32) (b - 18)) *
                frame_tonality;
        slope += band_tonality[b] * (b - 8);

        tonal.prev_band_tonality[b] = band_tonality[b];
        b += 1;
    }

    leakage_from[0] = band_log2[0];
    leakage_to[0] = band_log2[0] - 2.5;
    b = 1;
    while b < 18 + 1 {
        leak_slope := (2.0 * cast,no_check(float32) (TBANDS[b] - TBANDS[b - 1])) / 4.0;
        leakage_from[b] =
            ifx c_transpiler_float_less((leakage_from[b - 1] + leak_slope), band_log2[b]) then leakage_from[b - 1] +
                leak_slope else band_log2[b];
        leakage_to[b] =
            ifx c_transpiler_float_greater((leakage_to[b - 1] - leak_slope), (band_log2[b] - 2.5)) then leakage_to[b - 1] -
                leak_slope else band_log2[b] - 2.5;
        b += 1;
    }
    b = cast,no_check(s32) ((18 - 2));
    while b >= 0 {
        leak_slope := (2.0 * cast,no_check(float32) (TBANDS[b + 1] - TBANDS[b])) / 4.0;
        leakage_from[b] =
            ifx c_transpiler_float_less((leakage_from[b + 1] + leak_slope), leakage_from[b]) then leakage_from[b + 1] +
                leak_slope else leakage_from[b];
        leakage_to[b] =
            ifx c_transpiler_float_greater((leakage_to[b + 1] - leak_slope), leakage_to[b]) then leakage_to[b + 1] -
                leak_slope else leakage_to[b];
        b -= 1;
    }
    (18 + 1 <= 19);
    b = 0;
    while b < 18 + 1 {
        boost :=
            (ifx c_transpiler_float_greater(0.0, (leakage_to[b] - band_log2[b])) then 0.0 else leakage_to[b] - band_log2[b]) +
                (ifx c_transpiler_float_greater(0.0, (band_log2[b] - (leakage_from[b] + 2.5))) then 0.0 else band_log2[b] - (leakage_from[b] + 2.5));
        info.leak_boost[b] =
            cast,no_check(u8) ((ifx 255 < cast,no_check(s32) floor(0.5 +
                cast,no_check(float64) (64.0 * boost)) then 255 else cast,no_check(s32) floor(0.5 + cast,no_check(float64) (64.0 * boost))));
        b += 1;
    }
    while b < 19 {
        info.leak_boost[b] = 0;
        b += 1;
    }

    i = 0;
    while i < 8 {
        mindist: float32 = 1.0e15;
        for j: 0..cast(s32) 8 - 1 {
            dist: float32 = 0.0;
            for k: 0..cast(s32) 18 - 1 {
                tmp := tonal.log_e[i][k] - tonal.log_e[j][k];
                dist += tmp * tmp;
            }
            if j != i {
                mindist = ifx c_transpiler_float_less(mindist, dist) then mindist else dist;
            }
        }
        spec_variability += mindist;
        i += 1;
    }
    spec_variability =
        cast,no_check(float32) c_transpiler_libm_sqrt(
            cast,no_check(float64) (spec_variability / 8.0 / 18.0)
        );
    bandwidth_mask: float32 = 0.0;
    bandwidth = 0;
    max_e = 0.0;
    noise_floor :=
        5.7e-4 /
            cast,no_check(float32) ((cast(s32) 1) << (((ifx 0 > lsb_depth - 8 then 0 else lsb_depth - 8)) & 31));
    noise_floor *= noise_floor;
    below_max_pitch: float32 = 0.0;
    above_max_pitch: float32 = 0.0;
    b = 0;
    while b < 18 {
        e: float32 = 0.0;
        band_start: s32 = ---;

        band_start = TBANDS[b];
        band_end := TBANDS[b + 1];
        i = band_start;
        while i < band_end {
            bin_e :=
                out[i].r * out[i].r + out[n - i].r * out[n - i].r +
                    out[i].i * out[i].i + out[n - i].i * out[n - i].i;
            e += bin_e;
            i += 1;
        }
        e = (cast(float32) 9.313225746154786e-10) * e;
        max_e = ifx c_transpiler_float_greater(max_e, e) then max_e else e;
        if band_start < 64 {
            below_max_pitch += e;
        } else {
            above_max_pitch += e;
        }
        tonal.mean_e[b] =
            ifx c_transpiler_float_greater(((1.0 - alpha_e2) * tonal.mean_e[b]), e) then (1.0 - alpha_e2) *
                tonal.mean_e[b] else e;
        em := (ifx c_transpiler_float_greater(e, tonal.mean_e[b]) then e else tonal.mean_e[b]);

        if c_transpiler_float_greater((e * 1.0e9), max_e) &&
            (c_transpiler_float_greater(em, (3.0 * noise_floor * (band_end - band_start))) ||
                c_transpiler_float_greater(e, (noise_floor * (band_end - band_start)))) {
            bandwidth = b + 1;
        }

        is_masked[b] =
            cast(s32) (c_transpiler_float_less(e, ((ifx tonal.prev_bandwidth >= b + 1 then 0.01 else 0.05) *
                bandwidth_mask)));

        bandwidth_mask = ifx c_transpiler_float_greater((0.05 * bandwidth_mask), e) then 0.05 * bandwidth_mask else e;
        b += 1;
    }

    if tonal.fs == 48000 {
        e := hp_ener * cast(float32) 0.00027777778450399637;
        noise_ratio: float32 = (ifx tonal.prev_bandwidth == 20 then 10.0 else 30.0);

        above_max_pitch += e;
        tonal.mean_e[b] =
            ifx c_transpiler_float_greater(((1.0 - alpha_e2) * tonal.mean_e[b]), e) then (1.0 - alpha_e2) *
                tonal.mean_e[b] else e;
        em := (ifx c_transpiler_float_greater(e, tonal.mean_e[b]) then e else tonal.mean_e[b]);
        if c_transpiler_float_greater(em, (3.0 * noise_ratio * noise_floor * 160.0)) ||
            c_transpiler_float_greater(e, (noise_ratio * noise_floor * 160.0)) {
            bandwidth = 20;
        }

        is_masked[b] =
            cast(s32) (c_transpiler_float_less(e, ((ifx tonal.prev_bandwidth == 20 then 0.01 else 0.05) *
                bandwidth_mask)));
    }
    if c_transpiler_float_greater(above_max_pitch, below_max_pitch) {
        info.max_pitch_ratio = below_max_pitch / above_max_pitch;
    } else {
        info.max_pitch_ratio = 1.0;
    }

    if bandwidth == 20 && is_masked[18] != 0 {
        bandwidth -= 2;
    } else if bandwidth > 0 && bandwidth <= 18 && is_masked[bandwidth - 1] != 0 {
        bandwidth -= 1;
    }
    if tonal.count <= 2 {
        bandwidth = 20;
    }
    frame_loudness = 20.0 * cast,no_check(float32) c_transpiler_math_log10(cast,no_check(float64) frame_loudness);
    tonal.etracker =
        ifx c_transpiler_float_greater((tonal.etracker - 0.003), frame_loudness) then tonal.etracker -
            0.003 else frame_loudness;
    tonal.low_e_count *= 1.0 - alpha_e;
    if c_transpiler_float_less(frame_loudness, (tonal.etracker - 30.0)) {
        tonal.low_e_count += alpha_e;
    }

    i = 0;
    while i < 8 {
        sum: float32 = 0.0;
        b = 0;
        while b < 16 {
            sum += DCT_TABLE[i * 16 + b] * log_e[b];
            b += 1;
        }
        bfcc[i] = sum;
        i += 1;
    }
    i = 0;
    while i < 8 {
        sum: float32 = 0.0;
        b = 0;
        while b < 16 {
            sum += DCT_TABLE[i * 16 + b] * 0.5 * (tonal.high_e[b] + tonal.low_e[b]);
            b += 1;
        }
        mid_e[i] = sum;
        i += 1;
    }

    frame_stationarity /= 18.0;
    relative_e /= 18.0;
    if tonal.count < 10 {
        relative_e = 0.5;
    }
    frame_noisiness /= 18.0;

    info.activity = frame_noisiness + (1.0 - frame_noisiness) * relative_e;

    frame_tonality = max_frame_tonality / 9.0;
    frame_tonality =
        ifx c_transpiler_float_greater(frame_tonality, (tonal.prev_tonality * 0.8)) then frame_tonality else tonal.prev_tonality *
            0.8;
    tonal.prev_tonality = frame_tonality;

    slope /= 64.0;
    info.tonality_slope = slope;

    tonal.e_count = (tonal.e_count + 1) % 8;
    tonal.count = ifx tonal.count + 1 < 10000 then tonal.count + 1 else 10000;
    info.tonality = frame_tonality;

    i = 0;
    while i < 4 {
        features[i] =
            (cast(float32) -0.12298999726772309) * (bfcc[i] + tonal.mem[i + 24]) +
                0.49195 * (tonal.mem[i] + tonal.mem[i + 16]) + 0.69693 * tonal.mem[i + 8] - 1.4349 * tonal.cmean[i];
        i += 1;
    }

    i = 0;
    while i < 4 {
        tonal.cmean[i] = (1.0 - alpha) * tonal.cmean[i] + alpha * bfcc[i];
        i += 1;
    }

    i = 0;
    while i < 4 {
        features[4 + i] = 0.63246 * (bfcc[i] - tonal.mem[i + 24]) + 0.31623 * (tonal.mem[i] - tonal.mem[i + 16]);
        i += 1;
    }
    i = 0;
    while i < 3 {
        features[8 + i] =
            0.53452 * (bfcc[i] + tonal.mem[i + 24]) -
                0.26726 * (tonal.mem[i] + tonal.mem[i + 16]) - 0.53452 * tonal.mem[i + 8];
        i += 1;
    }

    if tonal.count > 5 {
        i = 0;
        while i < 9 {
            tonal.std[i] = (1.0 - alpha) * tonal.std[i] + alpha * features[i] * features[i];
            i += 1;
        }
    }
    i = 0;
    while i < 4 {
        features[i] = bfcc[i] - mid_e[i];
        i += 1;
    }

    i = 0;
    while i < 8 {
        tonal.mem[i + 24] = tonal.mem[i + 16];
        tonal.mem[i + 16] = tonal.mem[i + 8];
        tonal.mem[i + 8] = tonal.mem[i];
        tonal.mem[i] = bfcc[i];
        i += 1;
    }
    i = 0;
    while i < 9 {
        features[11 + i] =
            (cast,no_check(float32) c_transpiler_libm_sqrt(cast,no_check(float64) tonal.std[i])) -
                STD_FEATURE_BIAS[i];
        i += 1;
    }
    features[18] = spec_variability - 0.78;
    features[20] = info.tonality - 0.154723;
    features[21] = info.activity - 0.724643;
    features[22] = frame_stationarity - 0.743717;
    features[23] = info.tonality_slope + 0.069216;
    features[24] = tonal.low_e_count - 0.067930;

    (cast,no_check(#type (_: *Analysis_Dense_Layer, _: *float32, _: *float32)) (cast(*void) analysis_compute_dense))(
        *LAYER0,
        layer_out.data,
        features.data
    );
    (cast,no_check(#type (_: *Analysis_GRU_Layer, _: *float32, _: *float32)) (cast(*void) analysis_compute_gru))(
        *LAYER1,
        tonal.rnn_state.data,
        layer_out.data
    );
    (cast,no_check(#type (_: *Analysis_Dense_Layer, _: *float32, _: *float32)) (cast(*void) analysis_compute_dense))(
        *LAYER2,
        frame_probs.data,
        tonal.rnn_state.data
    );

    info.activity_probability = frame_probs[1];
    info.music_prob = frame_probs[0];

    info.bandwidth = bandwidth;
    tonal.prev_bandwidth = bandwidth;

    info.noisiness = frame_noisiness;
    info.valid = 1;
}

tonality_analysis :: (
    tonal: *Tonality_Analysis_State,
    celt_mode: *Custom_Mode,
    x: *$Value,
    len: s32,
    offset: s32,
    c1: s32,
    c2: s32,
    c: s32,
    lsb_depth: s32,
    downmix: Downmix_Func
) {
    tonality_analysis(tonal, celt_mode, cast(*void) x, len, offset, c1, c2, c, lsb_depth, downmix);
}

float2int_in_analysis :: (x: float32) -> Int32 {
    return mm_cvt_ss2si_in_analysis(mm_set_ss_in_analysis(x));
}

mm_set_ss_in_analysis :: inline (w: float32) -> M128 {
    return (float32.[ w, 0.0, 0.0, 0.0 ]);
}

mm_cvt_ss2si_in_analysis :: inline (a: M128) -> s32 {
    return mm_cvtss_si32_in_analysis(a);
}

mm_cvtss_si32_in_analysis :: inline (a: M128) -> s32 {
    return c_transpiler_simd_cvtss2si32((cast(*V4sf) *(a)).*);
}

downmix_and_resample :: (
    downmix: Downmix_Func,
    x: *void,
    y: *Val32,
    s: *Val32,
    subframe: s32,
    offset: s32,
    c1: s32,
    c2: s32,
    c: s32,
    fs: s32
) -> Val32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    ret: Val32 = 0.0;

    if subframe == 0 {
        return 0.0;
    }
    if fs == 48000 {
        subframe *= 2;
        offset *= 2;
    } else if fs == 16000 {
        subframe = subframe * 2 / 3;
        offset = offset * 2 / 3;
    } else if fs != 24000 {
    }
    tmp := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) subframe)));

    downmix(x, tmp, subframe, offset, c1, c2, c);
    if c2 == -2 && c == 2 || c2 > -1 {
        if 0 < subframe {
            for j: 0..subframe - 1 {
                tmp[j] = 0.5 * tmp[j];
            }
        }
    }
    if fs == 48000 {
        ret = silk_resampler_down2_hp(s, y, tmp, subframe);
    } else if fs == 24000 {
        copy_memory(y, tmp, (cast,no_check(u64) subframe) * size_of(Val32) + cast,no_check(u64) (0 * (y - tmp)));
    } else if fs == 16000 {
        tmp3x := cast(*Val32) c_transpiler_alloca(cast(u64) ((size_of(Val32) * cast,no_check(u64) (3 * subframe))));

        if 0 < subframe {
            for j: 0..subframe - 1 {
                tmp3x[3 * j] = tmp[j];
                tmp3x[3 * j + 1] = tmp[j];
                tmp3x[3 * j + 2] = tmp[j];
            }
        }
        silk_resampler_down2_hp(s, y, tmp3x, 3 * subframe);
    }

    ret *= cast(float32) 9.313225746154786e-10;

    return ret;
}

downmix_and_resample :: (
    downmix: Downmix_Func,
    x: *$Value,
    y: *Val32,
    s: *Val32,
    subframe: s32,
    offset: s32,
    c1: s32,
    c2: s32,
    c: s32,
    fs: s32
) -> Val32 {
    return downmix_and_resample(downmix, cast(*void) x, y, s, subframe, offset, c1, c2, c, fs);
}

silk_resampler_down2_hp :: (s: *Val32, out: *Val32, in: *Val32, in_len: s32) -> Val32 {
    len2 := in_len / 2;

    hp_ener: Val64 = 0.0;

    if 0 < len2 {
        for k: 0..len2 - 1 {
            in32 := in[2 * k];

            y := in32 - s[0];
            x := 0.6074371 * y;
            out32 := s[0] + x;
            s[0] = in32 + x;
            out32_hp := out32;

            in32 = in[2 * k + 1];

            y = in32 - s[1];
            x = 0.15063 * y;
            out32 = out32 + s[1];
            out32 = out32 + x;
            s[1] = in32 + x;

            y = -in32 - s[2];
            x = 0.15063 * y;
            out32_hp = out32_hp + s[2];
            out32_hp = out32_hp + x;
            s[2] = -in32 + x;

            hp_ener += out32_hp * out32_hp;

            out[k] = 0.5 * out32;
        }
    }

    return hp_ener;
}

false__in_analysis :: () -> s32 {
    return 0;
}

float2_int16_in_analysis :: (x: float32) -> Int16 {
    x = x * 32768.0;
    x = ifx c_transpiler_float_greater(x, -32768.0) then x else -32768.0;
    x = ifx c_transpiler_float_less(x, 32767.0) then x else 32767.0;
    return cast,no_check(Int16) float2int_in_analysis(x);
}

float2_int24_in_analysis :: (x: float32) -> Int32 {
    x = x * 8388608.0;
    x = ifx c_transpiler_float_greater(x, cast(float32) -16777216.0) then x else cast(float32) -16777216.0;
    x = ifx c_transpiler_float_less(x, cast(float32) 16777216.0) then x else cast(float32) 16777216.0;
    return float2int_in_analysis(x);
}

globals_initialization_state_for_analysis: u32;
initialize_globals_for_analysis :: () {
    {
        state := atomic_load(*globals_initialization_state_for_analysis);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_analysis, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_analysis) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_analysis =
        u8.[
            126,
            124,
            119,
            109,
            87,
            41,
            19,
            9,
            4,
            2,
            0
        ];
    SPREAD_ICDF_in_analysis = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_analysis = u8.[ 2, 1, 0 ];
    DCT_TABLE =
        float32.[
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.250000,
            0.351851,
            0.338330,
            0.311806,
            0.273300,
            0.224292,
            0.166664,
            0.102631,
            0.034654,
            cast(float32) -0.03465399891138077,
            cast(float32) -0.10263100266456604,
            cast(float32) -0.1666640043258667,
            cast(float32) -0.22429199516773225,
            cast(float32) -0.2732999920845032,
            cast(float32) -0.31180599331855776,
            cast(float32) -0.3383300006389618,
            cast(float32) -0.3518509864807129,
            0.346760,
            0.293969,
            0.196424,
            0.068975,
            cast(float32) -0.06897500157356262,
            cast(float32) -0.19642400741577149,
            cast(float32) -0.2939690053462982,
            cast(float32) -0.34676000475883486,
            cast(float32) -0.34676000475883486,
            cast(float32) -0.2939690053462982,
            cast(float32) -0.19642400741577149,
            cast(float32) -0.06897500157356262,
            0.068975,
            0.196424,
            0.293969,
            0.346760,
            0.338330,
            0.224292,
            0.034654,
            cast(float32) -0.1666640043258667,
            cast(float32) -0.31180599331855776,
            cast(float32) -0.3518509864807129,
            cast(float32) -0.2732999920845032,
            cast(float32) -0.10263100266456604,
            0.102631,
            0.273300,
            0.351851,
            0.311806,
            0.166664,
            cast(float32) -0.03465399891138077,
            cast(float32) -0.22429199516773225,
            cast(float32) -0.3383300006389618,
            0.326641,
            0.135299,
            cast(float32) -0.13529899716377259,
            cast(float32) -0.3266409933567047,
            cast(float32) -0.3266409933567047,
            cast(float32) -0.13529899716377259,
            0.135299,
            0.326641,
            0.326641,
            0.135299,
            cast(float32) -0.13529899716377259,
            cast(float32) -0.3266409933567047,
            cast(float32) -0.3266409933567047,
            cast(float32) -0.13529899716377259,
            0.135299,
            0.326641,
            0.311806,
            0.034654,
            cast(float32) -0.2732999920845032,
            cast(float32) -0.3383300006389618,
            cast(float32) -0.10263100266456604,
            0.224292,
            0.351851,
            0.166664,
            cast(float32) -0.1666640043258667,
            cast(float32) -0.3518509864807129,
            cast(float32) -0.22429199516773225,
            0.102631,
            0.338330,
            0.273300,
            cast(float32) -0.03465399891138077,
            cast(float32) -0.31180599331855776,
            0.293969,
            cast(float32) -0.06897500157356262,
            cast(float32) -0.34676000475883486,
            cast(float32) -0.19642400741577149,
            0.196424,
            0.346760,
            0.068975,
            cast(float32) -0.2939690053462982,
            cast(float32) -0.2939690053462982,
            0.068975,
            0.346760,
            0.196424,
            cast(float32) -0.19642400741577149,
            cast(float32) -0.34676000475883486,
            cast(float32) -0.06897500157356262,
            0.293969,
            0.273300,
            cast(float32) -0.1666640043258667,
            cast(float32) -0.3383300006389618,
            0.034654,
            0.351851,
            0.102631,
            cast(float32) -0.31180599331855776,
            cast(float32) -0.22429199516773225,
            0.224292,
            0.311806,
            cast(float32) -0.10263100266456604,
            cast(float32) -0.3518509864807129,
            cast(float32) -0.03465399891138077,
            0.338330,
            0.166664,
            cast(float32) -0.2732999920845032
        ];
    ANALYSIS_WINDOW =
        float32.[
            0.000043,
            0.000171,
            0.000385,
            0.000685,
            0.001071,
            0.001541,
            0.002098,
            0.002739,
            0.003466,
            0.004278,
            0.005174,
            0.006156,
            0.007222,
            0.008373,
            0.009607,
            0.010926,
            0.012329,
            0.013815,
            0.015385,
            0.017037,
            0.018772,
            0.020590,
            0.022490,
            0.024472,
            0.026535,
            0.028679,
            0.030904,
            0.033210,
            0.035595,
            0.038060,
            0.040604,
            0.043227,
            0.045928,
            0.048707,
            0.051564,
            0.054497,
            0.057506,
            0.060591,
            0.063752,
            0.066987,
            0.070297,
            0.073680,
            0.077136,
            0.080665,
            0.084265,
            0.087937,
            0.091679,
            0.095492,
            0.099373,
            0.103323,
            0.107342,
            0.111427,
            0.115579,
            0.119797,
            0.124080,
            0.128428,
            0.132839,
            0.137313,
            0.141849,
            0.146447,
            0.151105,
            0.155823,
            0.160600,
            0.165435,
            0.170327,
            0.175276,
            0.180280,
            0.185340,
            0.190453,
            0.195619,
            0.200838,
            0.206107,
            0.211427,
            0.216797,
            0.222215,
            0.227680,
            0.233193,
            0.238751,
            0.244353,
            0.250000,
            0.255689,
            0.261421,
            0.267193,
            0.273005,
            0.278856,
            0.284744,
            0.290670,
            0.296632,
            0.302628,
            0.308658,
            0.314721,
            0.320816,
            0.326941,
            0.333097,
            0.339280,
            0.345492,
            0.351729,
            0.357992,
            0.364280,
            0.370590,
            0.376923,
            0.383277,
            0.389651,
            0.396044,
            0.402455,
            0.408882,
            0.415325,
            0.421783,
            0.428254,
            0.434737,
            0.441231,
            0.447736,
            0.454249,
            0.460770,
            0.467298,
            0.473832,
            0.480370,
            0.486912,
            0.493455,
            0.500000,
            0.506545,
            0.513088,
            0.519630,
            0.526168,
            0.532702,
            0.539230,
            0.545751,
            0.552264,
            0.558769,
            0.565263,
            0.571746,
            0.578217,
            0.584675,
            0.591118,
            0.597545,
            0.603956,
            0.610349,
            0.616723,
            0.623077,
            0.629410,
            0.635720,
            0.642008,
            0.648271,
            0.654508,
            0.660720,
            0.666903,
            0.673059,
            0.679184,
            0.685279,
            0.691342,
            0.697372,
            0.703368,
            0.709330,
            0.715256,
            0.721144,
            0.726995,
            0.732807,
            0.738579,
            0.744311,
            0.750000,
            0.755647,
            0.761249,
            0.766807,
            0.772320,
            0.777785,
            0.783203,
            0.788573,
            0.793893,
            0.799162,
            0.804381,
            0.809547,
            0.814660,
            0.819720,
            0.824724,
            0.829673,
            0.834565,
            0.839400,
            0.844177,
            0.848895,
            0.853553,
            0.858151,
            0.862687,
            0.867161,
            0.871572,
            0.875920,
            0.880203,
            0.884421,
            0.888573,
            0.892658,
            0.896677,
            0.900627,
            0.904508,
            0.908321,
            0.912063,
            0.915735,
            0.919335,
            0.922864,
            0.926320,
            0.929703,
            0.933013,
            0.936248,
            0.939409,
            0.942494,
            0.945503,
            0.948436,
            0.951293,
            0.954072,
            0.956773,
            0.959396,
            0.961940,
            0.964405,
            0.966790,
            0.969096,
            0.971321,
            0.973465,
            0.975528,
            0.977510,
            0.979410,
            0.981228,
            0.982963,
            0.984615,
            0.986185,
            0.987671,
            0.989074,
            0.990393,
            0.991627,
            0.992778,
            0.993844,
            0.994826,
            0.995722,
            0.996534,
            0.997261,
            0.997902,
            0.998459,
            0.998929,
            0.999315,
            0.999615,
            0.999829,
            0.999957,
            1.000000
        ];
    TBANDS =
        s32.[
            4,
            8,
            12,
            16,
            20,
            24,
            28,
            32,
            40,
            48,
            56,
            64,
            80,
            96,
            112,
            136,
            160,
            192,
            240
        ];
    STD_FEATURE_BIAS =
        float32.[
            5.684947,
            3.475288,
            1.770634,
            1.599784,
            3.773215,
            2.163313,
            1.260756,
            1.116868,
            1.918795
        ];
    atomic_store(*globals_initialization_state_for_analysis, 2);
}

Analysis_Dense_Layer :: struct {
    bias: *Int8;
    input_weights: *Int8;
    nb_inputs: s32;
    nb_neurons: s32;
    sigmoid: s32;
}

Analysis_GRU_Layer :: struct {
    bias: *Int8;
    input_weights: *Int8;
    recurrent_weights: *Int8;
    nb_inputs: s32;
    nb_neurons: s32;
}

