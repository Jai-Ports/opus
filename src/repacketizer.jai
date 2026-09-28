TRIM_ICDF_in_repacketizer: [11] u8;

SPREAD_ICDF_in_repacketizer: [4] u8;

TAPSET_ICDF_in_repacketizer: [3] u8;

repacketizer_get_size :: () -> s32 {
    return cast,no_check(s32) (cast(u64) size_of(Repacketizer));
}

repacketizer_init :: (rp: *Repacketizer) -> *Repacketizer {
    rp.nb_frames = 0;
    return rp;
}

repacketizer_create :: () -> *Repacketizer {
    rp := cast(*Repacketizer) alloc__in_repacketizer(cast,no_check(u64) repacketizer_get_size());
    if rp == null {
        return null;
    }
    return repacketizer_init(rp);
}

alloc__in_repacketizer :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

repacketizer_destroy :: (rp: *Repacketizer) {
    free__in_repacketizer(cast(*void) rp);
}

free__in_repacketizer :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

repacketizer_cat :: (rp: *Repacketizer, data: *u8, len: Int32) -> s32 {
    return repacketizer_cat_impl(rp, data, len, 0);
}

repacketizer_cat_impl :: (rp: *Repacketizer, data: *u8, len: Int32, self_delimited: s32) -> s32 {
    tmp_toc: u8 = ---;

    if len < 1 {
        return -4;
    }
    if rp.nb_frames == 0 {
        rp.toc = data[0];
        rp.framesize = packet_get_samples_per_frame(data, 8000);
    } else if (cast(s32) rp.toc) & 0xfc != (cast(s32) data[0]) & 0xfc {
        return -4;
    }
    curr_nb_frames := packet_get_nb_frames(data, len);
    if curr_nb_frames < 1 {
        return -4;
    }

    if (curr_nb_frames + rp.nb_frames) * rp.framesize > 960 {
        return -4;
    }

    ret :=
        packet_parse_impl(
            data,
            len,
            self_delimited,
            *tmp_toc,
            rp.frames.data + rp.nb_frames,
            rp.len.data + rp.nb_frames,
            null,
            null,
            rp.paddings.data + rp.nb_frames,
            rp.padding_len.data + rp.nb_frames
        );
    if ret < 1 {
        return ret;
    }
    rp.padding_nb_frames[rp.nb_frames] = cast,no_check(u8) ret;

    while curr_nb_frames > 1 {
        rp.nb_frames += 1;
        rp.padding_len[rp.nb_frames] = 0;
        rp.padding_nb_frames[rp.nb_frames] = 0;
        rp.paddings[rp.nb_frames] = null;
        curr_nb_frames -= 1;
    }
    rp.nb_frames += 1;
    return 0;
}

repacketizer_out_range :: (rp: *Repacketizer, begin: s32, end: s32, data: *u8, maxlen: Int32) -> Int32 {
    return repacketizer_out_range_impl(rp, begin, end, data, maxlen, 0, 0, null, 0);
}

repacketizer_out_range_impl :: (
    rp: *Repacketizer,
    begin: s32,
    end: s32,
    data: *u8,
    maxlen: Int32,
    self_delimited: s32,
    pad: s32,
    extensions: *Extension_Data,
    nb_extensions: s32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    ones_begin: s32 = 0;
    ones_end: s32 = 0;
    ext_begin: s32 = 0;
    ext_len: s32 = 0;

    if begin < 0 || begin >= end || end > rp.nb_frames {
        return -1;
    }
    count := end - begin;

    len := rp.len.data + begin;
    frames := rp.frames.data + begin;
    tot_size: Int32 = ifx self_delimited != 0
        then 1 + cast(s32) (len[count - 1] >= 252)
        else 0;

    total_ext_count := nb_extensions;
    i := begin;
    while i < end {
        n: s32 = packet_extensions_count(rp.paddings[i], rp.padding_len[i], cast,no_check(s32) rp.padding_nb_frames[i]);
        if n > 0 {
            total_ext_count += n;
        }
        i += 1;
    }
    all_extensions :=
        cast(*Extension_Data) c_transpiler_alloca(cast(u64) ((size_of(Extension_Data) *
            cast,no_check(u64) ((ifx total_ext_count != 0 then total_ext_count else 0)))));

    ext_count: s32 = 0;
    while ext_count < nb_extensions {
        all_extensions[ext_count] = extensions[ext_count];
        ext_count += 1;
    }

    i = begin;
    while i < end {
        frame_ext_count := total_ext_count - ext_count;
        ret :=
            packet_extensions_parse(
                rp.paddings[i],
                rp.padding_len[i],
                *all_extensions[ext_count],
                *frame_ext_count,
                cast,no_check(s32) rp.padding_nb_frames[i]
            );
        if ret < 0 {
            return -3;
        }

        j: s32 = 0;
        while j < frame_ext_count {
            all_extensions[ext_count + j].frame += i - begin;
            j += 1;
        }
        ext_count = cast,no_check(s32) (ext_count + frame_ext_count);
        i += 1;
    }

    ptr := data;
    if count == 1 {
        tot_size = cast,no_check(Int32) (tot_size + ((cast(s32) len[0]) + 1));
        if tot_size > maxlen {
            return -2;
        }
        ptr.* = cast,no_check(u8) ((cast(s32) rp.toc) & 0xfc);
        ptr += 1;
    } else if count == 2 {
        if len[1] == len[0] {
            tot_size = cast,no_check(Int32) (tot_size + ((2 * cast(s32) len[0]) + 1));
            if tot_size > maxlen {
                return -2;
            }
            ptr.* = cast,no_check(u8) ((cast(s32) rp.toc) & 0xfc | 0x1);
            ptr += 1;
        } else {
            tot_size = cast,no_check(Int32) (tot_size + ((((cast(s32) len[0]) + cast(s32) len[1]) + 2) + cast(s32) (len[0] >= 252)));
            if tot_size > maxlen {
                return -2;
            }
            ptr.* = cast,no_check(u8) ((cast(s32) rp.toc) & 0xfc | 0x2);
            ptr += 1;
            ptr += encode_size(cast,no_check(s32) len[0], ptr);
        }
    }
    if count > 2 || pad != 0 && tot_size < maxlen || ext_count > 0 {
        pad_amount: s32 = 0;

        ptr = data;
        if self_delimited != 0 {
            tot_size = 1 + cast(s32) (len[count - 1] >= 252);
        } else {
            tot_size = 0;
        }
        vbr: s32 = 0;
        i = 1;
        while i < count {
            if len[i] != len[0] {
                vbr = 1;
                break;
            }
            i += 1;
        }
        if vbr != 0 {
            tot_size = cast,no_check(Int32) (tot_size + 2);
            i = 0;
            while i < count - 1 {
                tot_size = cast,no_check(Int32) (tot_size + ((1 + cast(s32) (len[i] >= 252)) + cast(s32) len[i]));
                i += 1;
            }
            tot_size = cast,no_check(Int32) (tot_size + cast,no_check(s32) len[count - 1]);

            if tot_size > maxlen {
                return -2;
            }
            ptr.* = cast,no_check(u8) ((cast(s32) rp.toc) & 0xfc | 0x3);
            ptr += 1;
            ptr.* = cast,no_check(u8) (count | 0x80);
            ptr += 1;
        } else {
            tot_size = cast,no_check(Int32) (tot_size + ((count * cast(s32) len[0]) + 2));
            if tot_size > maxlen {
                return -2;
            }
            ptr.* = cast,no_check(u8) ((cast(s32) rp.toc) & 0xfc | 0x3);
            ptr += 1;
            ptr.* = cast,no_check(u8) count;
            ptr += 1;
        }
        pad_amount = ifx pad != 0 then maxlen - tot_size else 0;
        if ext_count > 0 {
            ext_len = packet_extensions_generate(null, maxlen - tot_size, all_extensions, ext_count, count, 0);
            if ext_len < 0 {
                return ext_len;
            }
            if pad == 0 {
                pad_amount = ext_len + (ifx ext_len != 0 then (ext_len + 253) / 254 else 1);
            }
        }
        if pad_amount != 0 {
            data[1] = cast,no_check(u8) ((cast,no_check(s32) data[1]) | 0x40);
            nb_255s := (pad_amount - 1) / 255;
            if tot_size + ext_len + nb_255s + 1 > maxlen {
                return -2;
            }
            ext_begin = tot_size + pad_amount - ext_len;

            ones_begin = tot_size + nb_255s + 1;
            ones_end = tot_size + pad_amount - ext_len;
            i = 0;
            while i < nb_255s {
                ptr.* = 255;
                ptr += 1;
                i += 1;
            }
            ptr.* = cast,no_check(u8) (pad_amount - 255 * nb_255s - 1);
            ptr += 1;
            tot_size = cast,no_check(Int32) (tot_size + pad_amount);
        }
        if vbr != 0 {
            i = 0;
            while i < count - 1 {
                ptr += encode_size(cast,no_check(s32) len[i], ptr);
                i += 1;
            }
        }
    }
    if self_delimited != 0 {
        sdlen := encode_size(cast,no_check(s32) len[count - 1], ptr);
        ptr += sdlen;
    }

    i = 0;
    while i < count {
        move_memory(
            ptr,
            frames[i],
            (cast,no_check(u64) len[i]) * size_of(u8) + cast,no_check(u64) (0 * (ptr - frames[i]))
        );
        ptr += cast,no_check(s32) len[i];
        i += 1;
    }
    if ext_len > 0 {
        ret: s32 = packet_extensions_generate(*data[ext_begin], ext_len, all_extensions, ext_count, count, 0);
    }
    i = ones_begin;
    while i < ones_end {
        data[i] = 0x1;
        i += 1;
    }
    if pad != 0 && ext_count == 0 {
        while ptr < data + maxlen {
            ptr.* = 0;
            ptr += 1;
        }
    }

    return tot_size;
}

repacketizer_get_nb_frames :: (rp: *Repacketizer) -> s32 {
    return rp.nb_frames;
}

repacketizer_out :: (rp: *Repacketizer, data: *u8, maxlen: Int32) -> Int32 {
    return repacketizer_out_range_impl(rp, 0, rp.nb_frames, data, maxlen, 0, 0, null, 0);
}

packet_pad :: (data: *u8, len: Int32, new_len: Int32) -> s32 {
    ret := packet_pad_impl(data, len, new_len, 1, null, 0);

    if ret > 0 {
        return 0;
    } else {
        return ret;
    }
}

packet_pad_impl :: (
    data: *u8,
    len: Int32,
    new_len: Int32,
    pad: s32,
    extensions: *Extension_Data,
    nb_extensions: s32
) -> Int32 {
    c_transpiler_alloca_mark := c_transpiler_alloca_checkpoint();
    defer c_transpiler_alloca_release(c_transpiler_alloca_mark);
    rp: Repacketizer = ---;

    if len < 1 {
        return -1;
    }
    if len == new_len {
        return 0;
    } else if len > new_len {
        return -1;
    }
    copy := cast(*u8) c_transpiler_alloca(cast(u64) ((size_of(u8) * cast,no_check(u64) len)));
    repacketizer_init(*rp);

    copy_memory(copy, data, (cast,no_check(u64) len) * size_of(u8) + cast,no_check(u64) (0 * (copy - data)));
    ret := repacketizer_cat(*rp, copy, len);
    if ret != 0 {
        return ret;
    }
    ret = repacketizer_out_range_impl(*rp, 0, rp.nb_frames, data, new_len, 0, pad, extensions, nb_extensions);

    return ret;
}

packet_unpad :: (data: *u8, len: Int32) -> Int32 {
    rp: Repacketizer = ---;

    if len < 1 {
        return -1;
    }
    repacketizer_init(*rp);
    ret := repacketizer_cat(*rp, data, len);
    if ret < 0 {
        return ret;
    }

    i: s32 = 0;
    while i < rp.nb_frames {
        rp.padding_len[i] = 0;
        rp.paddings[i] = null;
        i += 1;
    }
    ret = repacketizer_out_range_impl(*rp, 0, rp.nb_frames, data, len, 0, 0, null, 0);
    (ret > 0 && ret <= len);
    return ret;
}

multistream_packet_pad :: (data: *u8, len: Int32, new_len: Int32, nb_streams: s32) -> s32 {
    toc: u8 = ---;
    size: [48] Int16 = ---;
    packet_offset: Int32 = ---;

    if len < 1 {
        return -1;
    }
    if len == new_len {
        return 0;
    } else if len > new_len {
        return -1;
    }
    amount := new_len - len;

    s: s32 = 0;
    while s < nb_streams - 1 {
        if len <= 0 {
            return -4;
        }
        count := packet_parse_impl(data, len, 1, *toc, null, size.data, null, *packet_offset, null, null);
        if count < 0 {
            return count;
        }
        data += packet_offset;
        len -= packet_offset;
        s += 1;
    }
    return packet_pad(data, len, len + amount);
}

multistream_packet_unpad :: (data: *u8, len: Int32, nb_streams: s32) -> Int32 {
    toc: u8 = ---;
    size: [48] Int16 = ---;
    packet_offset: Int32 = ---;
    rp: Repacketizer = ---;

    if len < 1 {
        return -1;
    }
    dst := data;
    dst_len: Int32 = 0;

    if 0 < nb_streams {
        for s: 0..nb_streams - 1 {
            self_delimited := cast(s32) (s != nb_streams - 1);
            if len <= 0 {
                return -4;
            }
            repacketizer_init(*rp);
            ret :=
                packet_parse_impl(data, len, self_delimited, *toc, null, size.data, null, *packet_offset, null, null);
            if ret < 0 {
                return ret;
            }
            ret = repacketizer_cat_impl(*rp, data, packet_offset, self_delimited);
            if ret < 0 {
                return ret;
            }

            i: s32 = 0;
            while i < rp.nb_frames {
                rp.padding_len[i] = 0;
                rp.paddings[i] = null;
                i += 1;
            }
            ret = repacketizer_out_range_impl(*rp, 0, rp.nb_frames, dst, len, self_delimited, 0, null, 0);
            if ret < 0 {
                return ret;
            } else {
                dst_len += ret;
            }
            dst += ret;
            data += packet_offset;
            len -= packet_offset;
        }
    }
    return dst_len;
}

ec_range_bytes_in_repacketizer :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_repacketizer :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_repacketizer :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_repacketizer :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_repacketizer :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_repacketizer :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_repacketizer :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_repacketizer :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_repacketizer :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

align_in_repacketizer :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

realloc_in_repacketizer :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_repacketizer :: (size: u64) -> *void {
    return alloc__in_repacketizer(size);
}

false__in_repacketizer :: () -> s32 {
    return 0;
}

globals_initialization_state_for_repacketizer: u32;
initialize_globals_for_repacketizer :: () {
    {
        state := atomic_load(*globals_initialization_state_for_repacketizer);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_repacketizer, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_repacketizer) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_repacketizer =
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
    SPREAD_ICDF_in_repacketizer = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_repacketizer = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_repacketizer, 2);
}

