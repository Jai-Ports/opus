alloc__in_entdec :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_entdec :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_entdec :: (size: u64) -> *void {
    return alloc__in_entdec(size);
}

free__in_entdec :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

ec_range_bytes_in_entdec :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_entdec :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_entdec :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_entdec :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_entdec :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_entdec :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

ec_dec_init :: (this: *Ec_Dec, buf: *u8, storage: Uint32) {
    this.buf = buf;
    this.storage = storage;
    this.end_offs = 0;
    this.end_window = 0;
    this.nend_bits = 0;

    this.nbits_total = (cast,no_check(s32) ((32 + 1))) - (32 - ((cast,no_check(s32) ((32 - 2))) % 8 + 1)) / 8 * 8;
    this.offs = 0;
    this.rng = cast,no_check(Uint32) (((cast(u32) 1) << ((((cast,no_check(s32) ((32 - 2))) % 8 + 1)) & 31)));
    this.rem = ec_read_byte(this);
    this.val =
        (this.rng - 1) -
            cast,no_check(Uint32) (this.rem >> (((8 - ((cast,no_check(s32) ((32 - 2))) % 8 + 1))) & 31));
    this.error = 0;

    ec_dec_normalize(this);
}

ec_dec_normalize :: (this: *Ec_Dec) {
    while this.rng <= (cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) >> 8 {
        this.nbits_total += 8;
        c_transpiler_compound_shl(*(this.rng), (cast(s32) 8), Uint32, Uint32);

        sym := this.rem;

        this.rem = ec_read_byte(this);

        sym = sym << 8 | this.rem >> (((8 - ((cast,no_check(s32) ((32 - 2))) % 8 + 1))) & 31);

        this.val =
            (this.val << 8 +
                ((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1) & cast,no_check(u32) (~(sym))) & ((cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) - 1);
    }
}

ec_read_byte :: (this: *Ec_Dec) -> s32 {
    return ifx this.offs < this.storage then cast,no_check(s32) (this.buf[c_transpiler_post_increment(*(this.offs))]) else 0;
}

ec_decode :: (this: *Ec_Dec, ft: u32) -> u32 {
    this.ext = celt_udiv_in_entdec(this.rng, ft);
    s := this.val / this.ext;
    return ft - ((s + 1) + (ft - (s + 1)) & cast,no_check(u32) (-(cast(s32) (ft < s + 1))));
}

ec_decode_bin :: (this: *Ec_Dec, bits: u32) -> u32 {
    this.ext = this.rng >> ((bits) & 31);
    s := this.val / this.ext;
    return (cast(u32) 1) << ((bits) & 31) - (s + 1 + ((cast(u32) 1) << ((bits) & 31) - (s + 1)) & cast,no_check(u32) (-(cast(s32) ((cast(u32) 1) << ((bits) & 31) < s + 1))));
}

ec_dec_update :: (this: *Ec_Dec, fl: u32, fh: u32, ft: u32) {
    s := this.ext * (ft - fh);
    this.val -= s;
    this.rng = ifx fl > 0 then this.ext * (fh - fl) else this.rng - s;
    ec_dec_normalize(this);
}

ec_dec_bit_logp :: (this: *Ec_Dec, logp: u32) -> s32 {
    r := this.rng;
    d := this.val;
    s := r >> ((logp) & 31);
    ret := cast(s32) (d < s);
    if ret == 0 {
        this.val = d - s;
    }
    this.rng = ifx ret != 0 then s else r - s;
    ec_dec_normalize(this);
    return ret;
}

ec_dec_icdf :: (this: *Ec_Dec, icdf: *u8, ftb: u32) -> s32 {
    t: Uint32 = ---;

    s := this.rng;
    d := this.val;
    r := s >> ((ftb) & 31);
    ret: s32 = -1;
    while true {
        t = s;
        s = r * cast(Uint32) (icdf[c_transpiler_pre_increment(*(ret))]);
        if !(d < s) break;
    }
    this.val = d - s;
    this.rng = t - s;
    ec_dec_normalize(this);
    return ret;
}

ec_dec_icdf16 :: (this: *Ec_Dec, icdf: *Uint16, ftb: u32) -> s32 {
    t: Uint32 = ---;

    s := this.rng;
    d := this.val;
    r := s >> ((ftb) & 31);
    ret: s32 = -1;
    while true {
        t = s;
        s = r * cast(Uint32) (icdf[c_transpiler_pre_increment(*(ret))]);
        if !(d < s) break;
    }
    this.val = d - s;
    this.rng = t - s;
    ec_dec_normalize(this);
    return ret;
}

ec_dec_uint :: (this: *Ec_Dec, ft_value: Uint32) -> Uint32 {
    ft: u32 = ---;
    s: u32 = ---;

    ft_value -= 1;
    ftb := (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(ft_value);
    if ftb > 8 {
        ftb -= 8;
        ft = ft_value >> ((ftb) & 31) + 1;
        s = ec_decode(this, ft);
        ec_dec_update(this, s, s + 1, ft);
        t := s << ((ftb) & 31) | ec_dec_bits(this, cast,no_check(u32) ftb);
        if t <= ft_value {
            return t;
        }
        this.error = 1;
        return ft_value;
    } else {
        ft_value += 1;
        s = ec_decode(this, ft_value);
        ec_dec_update(this, s, s + 1, ft_value);
        return s;
    }
}

ec_dec_bits :: (this: *Ec_Dec, bits: u32) -> Uint32 {
    window := this.end_window;
    available := this.nend_bits;
    if cast,no_check(u32) available < bits {
        while true {
            window |= (cast,no_check(Ec_Window) ec_read_byte_from_end(this)) << ((available) & 31);
            available += 8;
            if !(available <= (cast,no_check(s32) (cast(u64) size_of(Ec_Window))) * 8 - 8) break;
        }
    }
    ret := window & ((cast(Uint32) 1) << ((bits) & 31) - 1);
    c_transpiler_compound_shr(*(window), (((bits) & 31)), Ec_Window, Ec_Window);
    available = cast,no_check(s32) ((cast,no_check(u32) available) - bits);
    this.end_window = window;
    this.nend_bits = available;
    this.nbits_total = cast,no_check(s32) ((cast,no_check(u32) this.nbits_total) + bits);
    return ret;
}

ec_read_byte_from_end :: (this: *Ec_Dec) -> s32 {
    return ifx this.end_offs < this.storage then cast,no_check(s32) (this.buf[this.storage - c_transpiler_pre_increment(*(this.end_offs))]) else 0;
}

