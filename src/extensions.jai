// Generated directly from C by cpp_transpiler.
TRIM_ICDF_in_extensions: [11] u8;

SPREAD_ICDF_in_extensions: [4] u8;

TAPSET_ICDF_in_extensions: [3] u8;

alloc__in_extensions :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_extensions :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_extensions :: (size: u64) -> *void {
    return alloc__in_extensions(size);
}

free__in_extensions :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

ec_range_bytes_in_extensions :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_extensions :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_extensions :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_extensions :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_extensions :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_extensions :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

select_arch_in_extensions :: () -> s32 {
    return 0;
}

bits_to_bitrate_in_extensions :: (bits: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bits * (6 * fs / frame_size) / 6;
}

bitrate_to_bits_in_extensions :: (bitrate: Int32, fs: Int32, frame_size: Int32) -> Int32 {
    return bitrate * 6 / (6 * fs / frame_size);
}

extension_iterator_init :: (iter: *Extension_Iterator, data: *u8, len: Int32, nb_frames: Int32) {
    (data != null || len == 0);
    (nb_frames >= 0 && nb_frames <= 48);
    iter.data = data;
    iter.curr_data = iter.data;
    iter.repeat_data = iter.curr_data;
    iter.src_data = null;
    iter.last_long = iter.src_data;
    iter.len = len;
    iter.curr_len = iter.len;
    iter.src_len = 0;
    iter.repeat_len = iter.src_len;
    iter.trailing_short_len = 0;
    iter.nb_frames = nb_frames;
    iter.frame_max = iter.nb_frames;
    iter.curr_frame = 0;
    iter.repeat_frame = iter.curr_frame;
    iter.repeat_l = 0;
}

extension_iterator_reset :: (iter: *Extension_Iterator) {
    iter.curr_data = iter.data;
    iter.repeat_data = iter.curr_data;
    iter.last_long = null;
    iter.curr_len = iter.len;
    iter.curr_frame = 0;
    iter.repeat_frame = iter.curr_frame;
    iter.trailing_short_len = 0;
}

extension_iterator_set_frame_max :: (iter: *Extension_Iterator, frame_max: s32) {
    iter.frame_max = frame_max;
}

extension_iterator_next :: (iter: *Extension_Iterator, ext: *Extension_Data) -> s32 {
    header_size: Int32 = ---;
    if iter.curr_len < 0 {
        return -4;
    }
    if iter.repeat_frame > 0 {
        ret := extension_iterator_next_repeat(iter, ext);
        if ret != 0 {
            return ret;
        }
    }

    if iter.curr_frame >= iter.frame_max {
        return 0;
    }
    while iter.curr_len > 0 {
        curr_data0 := iter.curr_data;
        id := (cast(s32) curr_data0.*) >> 1;
        l := (cast(s32) curr_data0.*) & 1;
        iter.curr_len = skip_extension(*iter.curr_data, iter.curr_len, *header_size);
        if iter.curr_len < 0 {
            return -4;
        }
        (iter.curr_data - iter.data == cast,no_check(s64) (iter.len - iter.curr_len));
        if id == 1 {
            if l == 0 {
                iter.curr_frame += 1;
            } else {
                if curr_data0[1] == 0 {
                    continue;
                }
                iter.curr_frame += cast,no_check(s32) curr_data0[1];
            }
            if iter.curr_frame >= iter.nb_frames {
                iter.curr_len = -1;
                return -4;
            }

            if iter.curr_frame >= iter.frame_max {
                iter.curr_len = 0;
            }
            iter.repeat_data = iter.curr_data;
            iter.last_long = null;
            iter.trailing_short_len = 0;
        } else if id == 2 {
            iter.repeat_l = cast,no_check(u8) l;
            iter.repeat_frame = iter.curr_frame + 1;
            iter.repeat_len = cast,no_check(Int32) (curr_data0 - iter.repeat_data);
            iter.src_data = iter.repeat_data;
            iter.src_len = iter.repeat_len;
            ret := extension_iterator_next_repeat(iter, ext);
            if ret != 0 {
                return ret;
            }
        } else if id > 2 {
            if id >= 32 {
                iter.last_long = iter.curr_data;
                iter.trailing_short_len = 0;
            } else {
                iter.trailing_short_len = cast,no_check(Int32) (iter.trailing_short_len + l);
            }
            if ext != null {
                ext.id = id;
                ext.frame = iter.curr_frame;
                ext.data = curr_data0 + header_size;
                ext.len = cast,no_check(Int32) (iter.curr_data - curr_data0 - cast(s64) header_size);
            }
            return 1;
        }
    }
    return 0;
}

extension_iterator_next_repeat :: (iter: *Extension_Iterator, ext: *Extension_Data) -> s32 {
    header_size: Int32 = ---;
    (iter.repeat_frame > 0);
    while iter.repeat_frame < iter.nb_frames {
        while iter.src_len > 0 {
            repeat_id_byte := cast,no_check(s32) iter.src_data.*;
            iter.src_len = skip_extension(*iter.src_data, iter.src_len, *header_size);

            (iter.src_len >= 0);

            if repeat_id_byte <= 3 {
                continue;
            }

            if iter.repeat_l == 0 && iter.repeat_frame + 1 >= iter.nb_frames && iter.src_data == iter.last_long {
                repeat_id_byte &= ~(cast(s32) 1);
            }
            curr_data0 := iter.curr_data;
            iter.curr_len =
                skip_extension_payload(
                    *iter.curr_data,
                    iter.curr_len,
                    *header_size,
                    repeat_id_byte,
                    iter.trailing_short_len
                );
            if iter.curr_len < 0 {
                return -4;
            }
            (iter.curr_data - iter.data == cast,no_check(s64) (iter.len - iter.curr_len));

            if iter.repeat_frame >= iter.frame_max {
                continue;
            }
            if ext != null {
                ext.id = repeat_id_byte >> 1;
                ext.frame = iter.repeat_frame;
                ext.data = curr_data0 + header_size;
                ext.len = cast,no_check(Int32) (iter.curr_data - curr_data0 - cast(s64) header_size);
            }
            return 1;
        }

        iter.src_data = iter.repeat_data;
        iter.src_len = iter.repeat_len;
        iter.repeat_frame += 1;
    }

    iter.repeat_data = iter.curr_data;
    iter.last_long = null;

    if iter.repeat_l == 0 {
        iter.curr_frame += 1;

        if iter.curr_frame >= iter.nb_frames {
            iter.curr_len = 0;
        }
    }
    iter.repeat_frame = 0;
    return 0;
}

skip_extension_payload :: (
    pdata: **u8,
    len: Int32,
    pheader_size: *Int32,
    id_byte: s32,
    trailing_short_len: Int32
) -> Int32 {
    data := pdata.*;
    header_size: Int32 = 0;
    id := id_byte >> 1;
    l := id_byte & 1;
    if !(id == 0 && l == 1 || id == 2) {
        if id > 0 && id < 32 {
            if len < l {
                return -1;
            }
            data += l;
            len = cast,no_check(Int32) (len - l);
        } else if l == 0 {
            if len < trailing_short_len {
                return -1;
            }
            data += len - trailing_short_len;
            len = trailing_short_len;
        } else {
            bytes: Int32 = 0;
            lacing: Int32 = ---;
            while true {
                if len < 1 {
                    return -1;
                }
                lacing = cast,no_check(Int32) ((c_transpiler_post_increment(*(data))).*);
                bytes += lacing;
                header_size += 1;
                len = cast,no_check(Int32) (len - (lacing + 1));
                if !(lacing == 255) break;
            }
            if len < 0 {
                return -1;
            }
            data += bytes;
        }
    }
    pdata.* = data;
    pheader_size.* = header_size;
    return len;
}

skip_extension :: (pdata: **u8, len: Int32, pheader_size: *Int32) -> Int32 {
    if len == 0 {
        pheader_size.* = 0;
        return 0;
    }
    if len < 1 {
        return -1;
    }
    data := pdata.*;
    id_byte := cast,no_check(s32) ((c_transpiler_post_increment(*(data))).*);
    len -= 1;
    len = skip_extension_payload(*data, len, pheader_size, id_byte, 0);
    if len >= 0 {
        pdata.* = data;
        pheader_size.* += 1;
    }
    return len;
}

extension_iterator_find :: (iter: *Extension_Iterator, ext: *Extension_Data, id: s32) -> s32 {
    curr_ext: Extension_Data = ---;

    while true {
        ret := extension_iterator_next(iter, *curr_ext);
        if ret <= 0 {
            return ret;
        }
        if curr_ext.id == id {
            ext.* = curr_ext;
            return ret;
        }
    }
    return unreachable_value(s32);
}

align_in_extensions :: (i: s32) -> s32 {

    alignment := cast,no_check(u32) (cast(u64) 8);

    return cast,no_check(s32) (((cast,no_check(u32) i) + alignment - 1) / alignment * alignment);
}

packet_extensions_parse :: (
    data: *u8,
    len: Int32,
    extensions: *Extension_Data,
    nb_extensions: *Int32,
    nb_frames: s32
) -> Int32 {
    iter: Extension_Iterator = ---;

    ret: s32 = ---;

    (extensions != null || nb_extensions.* == 0);
    extension_iterator_init(*iter, data, len, nb_frames);
    count: s32 = 0;
    while true {
        ext: Extension_Data = ---;
        ret = extension_iterator_next(*iter, *ext);
        if ret <= 0 {
            break;
        }
        if count == nb_extensions.* {
            return -2;
        }
        extensions[count] = ext;
        count += 1;
    }
    nb_extensions.* = count;
    return ret;
}

packet_extensions_parse_ext :: (
    data: *u8,
    len: Int32,
    extensions: *Extension_Data,
    nb_extensions: *Int32,
    nb_frame_exts: *Int32,
    nb_frames: s32
) -> Int32 {
    iter: Extension_Iterator = ---;
    ext: Extension_Data = ---;
    nb_frames_cum: [49] Int32 = ---;

    ret: s32 = ---;

    (extensions != null || nb_extensions.* == 0);

    prev_total: s32 = 0;
    count: s32 = 0;
    while count < nb_frames {
        total := nb_frame_exts[count] + prev_total;
        nb_frames_cum[count] = prev_total;
        prev_total = total;
        count += 1;
    }
    nb_frames_cum[count] = prev_total;
    extension_iterator_init(*iter, data, len, nb_frames);
    count = 0;
    while true {
        ret = extension_iterator_next(*iter, *ext);
        if ret <= 0 {
            break;
        }
        idx := c_transpiler_post_increment(*(nb_frames_cum[ext.frame]));
        if idx >= nb_extensions.* {
            return -2;
        }
        (idx < nb_frames_cum[ext.frame + 1]);
        extensions[idx] = ext;
        count += 1;
    }
    nb_extensions.* = count;
    return ret;
}

packet_extensions_generate :: (
    data: *u8,
    len: Int32,
    extensions: *Extension_Data,
    nb_extensions: Int32,
    nb_frames: s32,
    pad: s32
) -> Int32 {
    frame_min_idx: [48] Int32 = ---;
    frame_max_idx: [48] Int32 = ---;
    frame_repeat_idx: [48] Int32 = ---;

    curr_frame: s32 = 0;
    pos: Int32 = 0;
    written: Int32 = 0;

    if nb_frames > 48 {
        return -1;
    }

    f: s32 = 0;
    while f < nb_frames {
        frame_min_idx[f] = nb_extensions;
        f += 1;
    }
    fill_memory(frame_max_idx.data, 0, cast,no_check(u64) nb_frames * size_of(Int32));
    i: Int32 = 0;
    while i < nb_extensions {
        f = extensions[i].frame;
        if f < 0 || f >= nb_frames {
            return -1;
        }
        if extensions[i].id < 3 || extensions[i].id > 127 {
            return -1;
        }
        frame_min_idx[f] = ifx frame_min_idx[f] < i then frame_min_idx[f] else i;
        frame_max_idx[f] = ifx frame_max_idx[f] > i + 1 then frame_max_idx[f] else i + 1;
        i += 1;
    }
    f = 0;
    while f < nb_frames {
        frame_repeat_idx[f] = frame_min_idx[f];
        f += 1;
    }
    f = 0;
    while f < nb_frames {
        repeat_count: s32 = 0;
        last_long_idx: Int32 = -1;
        if f + 1 < nb_frames {
            i = frame_min_idx[f];
            while i < frame_max_idx[f] {
                if extensions[i].frame == f {
                    g := f + 1;
                    while g < nb_frames {
                        if frame_repeat_idx[g] >= frame_max_idx[g] {
                            break;
                        }
                        (extensions[frame_repeat_idx[g]].frame == g);
                        if extensions[frame_repeat_idx[g]].id != extensions[i].id {
                            break;
                        }
                        if extensions[frame_repeat_idx[g]].id < 32 && extensions[frame_repeat_idx[g]].len != extensions[i].len {
                            break;
                        }
                        g += 1;
                    }
                    if g < nb_frames {
                        break;
                    }

                    if extensions[i].id >= 32 {
                        last_long_idx = frame_repeat_idx[nb_frames - 1];
                    }

                    g = f + 1;
                    while g < nb_frames {
                        j := frame_repeat_idx[g] + 1;
                        while j < frame_max_idx[g] && extensions[j].frame != g {
                            j += 1;
                        }
                        frame_repeat_idx[g] = j;
                        g += 1;
                    }
                    repeat_count += 1;

                    frame_repeat_idx[f] = i;
                }
                i += 1;
            }
        }
        i = frame_min_idx[f];
        while i < frame_max_idx[f] {
            if extensions[i].frame == f {
                if f != curr_frame {
                    diff := f - curr_frame;
                    if len - pos < 2 {
                        return -2;
                    }
                    if diff == 1 {
                        if data != null {
                            data[pos] = 0x2;
                        }
                        pos += 1;
                    } else {
                        if data != null {
                            data[pos] = 0x3;
                        }
                        pos += 1;
                        if data != null {
                            data[pos] = cast,no_check(u8) diff;
                        }
                        pos += 1;
                    }
                    curr_frame = f;
                }

                pos = write_extension(data, len, pos, extensions + i, cast(s32) (written == nb_extensions - 1));
                if pos < 0 {
                    return pos;
                }
                written += 1;

                if repeat_count > 0 && frame_repeat_idx[f] == i {
                    nb_repeated := repeat_count * (nb_frames - (f + 1));
                    last :=
                        cast(s32) (written + nb_repeated == nb_extensions ||
                            last_long_idx < 0 && i + 1 >= frame_max_idx[f]);
                    if len - pos < 1 {
                        return -2;
                    }
                    if data != null {
                        data[pos] = cast,no_check(u8) (0x4 + cast(s32) (last == 0));
                    }
                    pos += 1;
                    g := f + 1;
                    while g < nb_frames {
                        j := frame_min_idx[g];
                        while j < frame_repeat_idx[g] {
                            if extensions[j].frame == g {
                                pos =
                                    write_extension_payload(
                                        data,
                                        len,
                                        pos,
                                        extensions + j,
                                        cast(s32) (last != 0 && j == last_long_idx)
                                    );
                                if pos < 0 {
                                    return pos;
                                }
                                written += 1;
                            }
                            j += 1;
                        }
                        frame_min_idx[g] = j;
                        g += 1;
                    }
                    if last != 0 {
                        curr_frame += 1;
                    }
                }
            }
            i += 1;
        }
        f += 1;
    }

    if pad != 0 && pos < len {
        padding := len - pos;
        if data != null {
            move_memory(
                data + padding,
                data,
                (cast,no_check(u64) pos) * size_of(u8) + cast,no_check(u64) (0 * (data + padding - data))
            );
            i = 0;
            while i < padding {
                data[i] = 0x1;
                i += 1;
            }
        }
        pos += padding;
    }
    return pos;
}

write_extension_payload :: (data: *u8, len: Int32, pos: Int32, ext: *Extension_Data, last: s32) -> s32 {
    (ext.id >= 3 && ext.id <= 127);
    if ext.id < 32 {
        if ext.len < 0 || ext.len > 1 {
            return -1;
        }
        if ext.len > 0 {
            if len - pos < ext.len {
                return -2;
            }
            if data != null {
                data[pos] = ext.data[0];
            }
            pos += 1;
        }
    } else {
        if ext.len < 0 {
            return -1;
        }
        length_bytes := 1 + ext.len / 255;
        if last != 0 {
            length_bytes = 0;
        }
        if len - pos < length_bytes + ext.len {
            return -2;
        }
        if last == 0 {
            j: Int32 = 0;
            while j < ext.len / 255 {
                if data != null {
                    data[pos] = 255;
                }
                pos += 1;
                j += 1;
            }
            if data != null {
                data[pos] = cast,no_check(u8) (ext.len % 255);
            }
            pos += 1;
        }
        if data != null {
            copy_memory(
                *data[pos],
                ext.data,
                (cast,no_check(u64) ext.len) * size_of(u8) + cast,no_check(u64) (0 * (*data[pos] - ext.data))
            );
        }
        pos += ext.len;
    }
    return pos;
}

write_extension :: (data: *u8, len: Int32, pos: Int32, ext: *Extension_Data, last: s32) -> s32 {
    if len - pos < 1 {
        return -2;
    }
    (ext.id >= 3 && ext.id <= 127);
    if data != null {
        data[pos] = cast,no_check(u8) (ext.id << 1 + (ifx ext.id < 32 then ext.len else cast(Int32) (last == 0)));
    }
    pos += 1;
    return write_extension_payload(data, len, pos, ext, last);
}

packet_extensions_count :: (data: *u8, len: Int32, nb_frames: s32) -> Int32 {
    iter: Extension_Iterator = ---;

    extension_iterator_init(*iter, data, len, nb_frames);
    count: s32 = 0;
    while extension_iterator_next(*iter, null) > 0 {
        count += 1;
    }
    return count;
}

packet_extensions_count_ext :: (data: *u8, len: Int32, nb_frame_exts: *Int32, nb_frames: s32) -> Int32 {
    iter: Extension_Iterator = ---;
    ext: Extension_Data = ---;

    extension_iterator_init(*iter, data, len, nb_frames);
    fill_memory(nb_frame_exts, 0, cast,no_check(u64) nb_frames * size_of(Int32));
    count: s32 = 0;
    while extension_iterator_next(*iter, *ext) > 0 {
        nb_frame_exts[ext.frame] += 1;
        count += 1;
    }
    return count;
}

globals_initialization_state_for_extensions: u32;
initialize_globals_for_extensions :: () {
    {
        state := atomic_load(*globals_initialization_state_for_extensions);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_extensions, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_extensions) != 2 {}
            return;
        }
    }
    TRIM_ICDF_in_extensions =
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
    SPREAD_ICDF_in_extensions = u8.[ 25, 23, 2, 0 ];
    TAPSET_ICDF_in_extensions = u8.[ 2, 1, 0 ];
    atomic_store(*globals_initialization_state_for_extensions, 2);
}

