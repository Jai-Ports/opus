TRIM_ICDF_in_opus: [11] u8;

SPREAD_ICDF_in_opus: [4] u8;

TAPSET_ICDF_in_opus: [3] u8;

packet_parse :: (data: *u8, len: Int32, out_toc: *u8, frames: **u8, size: *Int16, payload_offset: *s32) -> s32 {
    return packet_parse_impl(data, len, 0, out_toc, frames, size, payload_offset, null, null, null);
}

packet_parse_impl :: (
    data: *u8,
    len: Int32,
    self_delimited: s32,
    out_toc: *u8,
    frames: **u8,
    size: *Int16,
    payload_offset: *s32,
    packet_offset: *Int32,
    padding: **u8,
    padding_len: *Int32
) -> s32 {
    i, bytes: s32 = ---;
    count: s32 = ---;
    ch: u8 = ---;

    pad: Int32 = 0;
    data0 := data;

    if padding != null {
        padding.* = null;
        padding_len.* = 0;
    }

    if size == null || len < 0 {
        return -1;
    }
    if len == 0 {
        return -4;
    }

    framesize := packet_get_samples_per_frame(data, 48000);

    cbr: s32 = 0;
    toc := (c_transpiler_post_increment(*(data))).*;
    len -= 1;
    last_size := len;
    if ((cast(s32) toc) & 0x3) == {
        case 0;
            count = 1;
        case 1;
            count = 2;
            cbr = 1;
            if self_delimited == 0 {
                if len & 0x1 != 0 {
                    return -4;
                }
                last_size = len / 2;

                size[0] = cast,no_check(Int16) last_size;
            }
        case 2;
            count = 2;
            bytes = parse_size(data, len, size);
            len = cast,no_check(Int32) (len - bytes);
            if size[0] < 0 || cast,no_check(s32) size[0] > len {
                return -4;
            }
            data += bytes;
            last_size = len - cast(Int32) size[0];
        case;
            if len < 1 {
                return -4;
            }
            ch = (c_transpiler_post_increment(*(data))).*;
            count = (cast(s32) ch) & 0x3f;
            if count <= 0 || framesize * count > 5760 {
                return -4;
            }
            len -= 1;
            if ch & 0x40 != 0 {
                p: s32 = ---;
                while true {
                    {
                        if len <= 0 {
                            return -4;
                        }
                        p = cast,no_check(s32) ((c_transpiler_post_increment(*(data))).*);
                        len -= 1;
                        tmp := (ifx p == 255 then 254 else p);
                        len = cast,no_check(Int32) (len - tmp);
                        pad = cast,no_check(Int32) (pad + tmp);
                    }
                    if !(p == 255) break;
                }
            }
            if len < 0 {
                return -4;
            }
            cbr = cast(s32) ((cast(s32) ch) & 0x80 == 0);
            if cbr == 0 {
                last_size = len;
                i = 0;
                while i < count - 1 {
                    bytes = parse_size(data, len, size + i);
                    len = cast,no_check(Int32) (len - bytes);
                    if size[i] < 0 || cast,no_check(s32) size[i] > len {
                        return -4;
                    }
                    data += bytes;
                    last_size = cast,no_check(Int32) (last_size - (bytes + cast(s32) size[i]));
                    i += 1;
                }
                if last_size < 0 {
                    return -4;
                }
            } else if self_delimited == 0 {
                last_size = len / count;
                if last_size * count != len {
                    return -4;
                }
                i = 0;
                while i < count - 1 {
                    size[i] = cast,no_check(Int16) last_size;
                    i += 1;
                }
            }
    }

    if self_delimited != 0 {
        bytes = parse_size(data, len, size + count - 1);
        len = cast,no_check(Int32) (len - bytes);
        if size[count - 1] < 0 || cast,no_check(s32) size[count - 1] > len {
            return -4;
        }
        data += bytes;

        if cbr != 0 {
            if (cast(s32) size[count - 1]) * count > len {
                return -4;
            }
            i = 0;
            while i < count - 1 {
                size[i] = size[count - 1];
                i += 1;
            }
        } else if (bytes + cast(s32) size[count - 1]) > last_size {
            return -4;
        }
    } else {
        if last_size > 1275 {
            return -4;
        }
        size[count - 1] = cast,no_check(Int16) last_size;
    }

    if payload_offset != null {
        payload_offset.* = cast,no_check(s32) (data - data0);
    }

    i = 0;
    while i < count {
        if frames != null {
            frames[i] = data;
        }
        data += cast,no_check(s32) size[i];
        i += 1;
    }

    if padding != null {
        padding.* = data;
        padding_len.* = pad;
    }
    if packet_offset != null {
        packet_offset.* = pad + cast,no_check(Int32) (data - data0);
    }

    if out_toc != null {
        out_toc.* = toc;
    }

    return count;
}

parse_size :: (data: *u8, len: Int32, size: *Int16) -> s32 {
    if len < 1 {
        size.* = -1;
        return -1;
    } else if data[0] < 252 {
        size.* = cast,no_check(Int16) data[0];
        return 1;
    } else if len < 2 {
        size.* = -1;
        return -1;
    } else {
        size.* = cast,no_check(Int16) ((4 * cast(s32) data[1]) + cast(s32) data[0]);
        return 2;
    }
}

packet_get_samples_per_frame :: (data: *u8, fs: Int32) -> s32 {
    audiosize: s32 = ---;
    if data[0] & 0x80 != 0 {
        audiosize = (cast(s32) data[0]) >> 3 & 0x3;
        audiosize = fs << ((audiosize) & 31) / 400;
    } else if (cast(s32) data[0]) & 0x60 == 0x60 {
        audiosize = ifx data[0] & 0x8 != 0 then fs / 50 else fs / 100;
    } else {
        audiosize = (cast(s32) data[0]) >> 3 & 0x3;
        if audiosize == 3 {
            audiosize = fs * 60 / 1000;
        } else {
            audiosize = fs << ((audiosize) & 31) / 100;
        }
    }
    return audiosize;
}

pcm_soft_clip :: (x: *float32, n: s32, c: s32, declip_mem: *float32) {
    pcm_soft_clip_impl(x, n, c, declip_mem, 0);
}

pcm_soft_clip_impl :: (x_value: *float32, n: s32, c_value: s32, declip_mem: *float32, arch: s32) {
    i: s32 = ---;

    if c_value < 1 || n < 1 || x_value == null || declip_mem == null {
        return;
    }

    all_within_neg1pos1 := limit2_checkwithin1_c(x_value, n * c_value);

    if 0 < c_value {
        for c: 0..c_value - 1 {
            x := x_value + c;
            a := declip_mem[c];

            i = 0;
            while i < n {
                if c_transpiler_float_greater_equal((x[i * c_value] * a), 0.0) {
                    break;
                }
                x[i * c_value] = x[i * c_value] + a * x[i * c_value] * x[i * c_value];
                i += 1;
            }

            curr: s32 = 0;
            x0 := x[0];
            while ((cast(s32) 1) != 0) {
                start, end: s32 = ---;

                special: s32 = 0;

                if all_within_neg1pos1 != 0 {
                    i = n;
                } else {
                    i = curr;
                    while i < n {
                        if c_transpiler_float_greater(x[i * c_value], 1.0) || c_transpiler_float_less(x[i * c_value], -1.0) {
                            break;
                        }
                        i += 1;
                    }
                }
                if i == n {
                    a = 0.0;
                    break;
                }
                peak_pos := i;
                end = i;
                start = end;
                maxval := cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) x[i * c_value]);

                while start > 0 && c_transpiler_float_greater_equal((x[i * c_value] * x[(start - 1) * c_value]), 0.0) {
                    start -= 1;
                }

                while end < n && c_transpiler_float_greater_equal((x[i * c_value] * x[end * c_value]), 0.0) {
                    if c_transpiler_float_greater(cast,no_check(float32) c_transpiler_math_fabs(cast,no_check(float64) x[end * c_value]), maxval) {
                        maxval =
                            cast,no_check(float32) c_transpiler_math_fabs(
                                cast,no_check(float64) x[end * c_value]
                            );
                        peak_pos = end;
                    }
                    end += 1;
                }

                special = cast(s32) (start == 0 && c_transpiler_float_greater_equal((x[i * c_value] * x[0]), 0.0));

                a = (maxval - 1.0) / (maxval * maxval);

                a += a * 2.4e-7;
                if c_transpiler_float_greater(x[i * c_value], 0.0) {
                    a = -a;
                }

                i = start;
                while i < end {
                    x[i * c_value] = x[i * c_value] + a * x[i * c_value] * x[i * c_value];
                    i += 1;
                }

                if special != 0 && peak_pos >= 2 {
                    offset := x0 - x[0];
                    delta := offset / peak_pos;
                    i = curr;
                    while i < peak_pos {
                        offset -= delta;
                        x[i * c_value] += offset;
                        x[i * c_value] =
                            ifx c_transpiler_float_greater(-1.0, (ifx c_transpiler_float_less(1.0, x[i * c_value]) then 1.0 else x[i * c_value])) then -1.0 else (ifx c_transpiler_float_less(1.0, x[i * c_value]) then 1.0 else x[i *
                                c_value]);
                        i += 1;
                    }
                }
                curr = end;
                if curr == n {
                    break;
                }
            }
            declip_mem[c] = a;
        }
    }
}

ec_range_bytes_in_opus :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_opus :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_opus :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_opus :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_opus :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_opus :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

alloc__in_opus :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_opus :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_opus :: (size: u64) -> *void {
    return alloc__in_opus(size);
}

free__in_opus :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

fast_atan2f_in_opus :: (y: float32, x: float32) -> float32 {
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

celt_maxabs16_in_opus :: (x: *Val16, len: s32) -> Val32 {
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

celt_atan_norm_in_opus :: (x: float32) -> float32 {
    x_sq := x * x;

    return (cast(float32) 0.6366197466850281) * (x + x * x_sq * ((cast(float32) -0.3333165943622589) + x_sq * ((cast(float32) 0.19962704181671143) + x_sq * ((cast(float32) -0.13976582884788514) + x_sq * ((cast(float32) 0.09794234484434128) + x_sq * ((cast(float32) -0.057773590087890628) + x_sq * ((cast(float32) 0.023040136322379113) + x_sq * cast(float32) -0.0043554059229791168)))))));
}

celt_atan2p_norm_in_opus :: (y: float32, x: float32) -> float32 {
    (c_transpiler_float_greater_equal(x, 0.0) && c_transpiler_float_greater_equal(y, 0.0));

    if c_transpiler_float_less((x * x + y * y), 1.0e-18) {
        return 0.0;
    }

    if c_transpiler_float_less(y, x) {
        return celt_atan_norm_in_opus(y / x);
    } else {
        return 1.0 - celt_atan_norm_in_opus(x / y);
    }
}

celt_cos_norm2_in_opus :: (x: float32) -> float32 {
    x -= cast,no_check(float32) (4.0 * floor(0.25 * cast,no_check(float64) (x + 1.0)));

    output_sign := 1 - 2 * cast(s32) (c_transpiler_float_greater(x, 1.0));

    x -= cast,no_check(float32) (2 * cast(s32) (c_transpiler_float_greater(x, 1.0)));

    x_norm_sq := x * x;

    return output_sign * ((cast(float32) 0.9999999403953552) + x_norm_sq * ((cast(float32) -1.2336982488632203) + x_norm_sq * ((cast(float32) 0.2536507546901703) + x_norm_sq * ((cast(float32) -0.020810628309845926) + x_norm_sq * cast(float32) 0.0008581906440667808))));
}

select_arch_in_opus :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_opus :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_opus :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

encode_size :: (size: s32, data: *u8) -> s32 {
    if size < 252 {
        data[0] = cast,no_check(u8) size;
        return 1;
    } else {
        data[0] = cast,no_check(u8) (252 + size & 0x3);
        data[1] = cast,no_check(u8) ((size - cast,no_check(s32) data[0]) >> 2);
        return 2;
    }
}

align :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

globals_initialization_state_for_opus: u32;
initialize_globals_for_opus :: () {
    {
        state := atomic_load(*globals_initialization_state_for_opus);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_opus, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_opus) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_opus =
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
    SPREAD_ICDF_in_opus = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_opus = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_opus, 2);
}

