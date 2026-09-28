// Generated directly from C by cpp_transpiler.
alloc__in_entenc :: (size: u64) -> *void {
    return c_transpiler_allocate_memory(size);
}

realloc_in_entenc :: (ptr: *void, size: u64) -> *void {
    return c_transpiler_reallocate_memory(ptr, size);
}

alloc_scratch_in_entenc :: (size: u64) -> *void {
    return alloc__in_entenc(size);
}

free__in_entenc :: (ptr: *void) {
    c_transpiler_deallocate_memory(ptr);
}

ec_range_bytes_in_entenc :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_entenc :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_entenc :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_entenc :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

celt_udiv_in_entenc :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_entenc :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

ec_enc_init :: (this: *Ec_Enc, buf: *u8, size: Uint32) {
    this.buf = buf;
    this.end_offs = 0;
    this.end_window = 0;
    this.nend_bits = 0;

    this.nbits_total = cast,no_check(s32) ((32 + 1));
    this.offs = 0;
    this.rng = cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)));
    this.rem = -1;
    this.val = 0;
    this.ext = 0;
    this.storage = size;
    this.error = 0;
}

ec_encode :: (this: *Ec_Enc, fl: u32, fh: u32, ft: u32) {
    r := celt_udiv_in_entenc(this.rng, ft);
    if fl > 0 {
        this.val = cast,no_check(Uint32) (this.val + (this.rng - r * (ft - fl)));
        this.rng = r * (fh - fl);
    } else {
        this.rng = cast,no_check(Uint32) (this.rng - (r * (ft - fh)));
    }
    ec_enc_normalize(this);
}

ec_enc_normalize :: (this: *Ec_Enc) {
    while this.rng <= (cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) >> 8 {
        ec_enc_carry_out(this, cast,no_check(s32) (this.val >> ((((cast,no_check(s32) ((32 - 8))) - 1)) & 31)));

        this.val = this.val << 8 & ((cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) - 1);
        c_transpiler_compound_shl(*(this.rng), (cast(s32) 8), Uint32, Uint32);
        this.nbits_total += 8;
    }
}

ec_enc_carry_out :: (this: *Ec_Enc, c: s32) {
    if cast,no_check(u32) c != (cast,no_check(u32) (((cast(u32) 1) << 8))) - 1 {
        carry := c >> 8;

        if this.rem >= 0 {
            this.error |= ec_write_byte(this, cast,no_check(u32) (this.rem + carry));
        }
        if this.ext > 0 {
            sym :=
                (((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1) +
                    cast,no_check(u32) carry) & ((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1);
            while true {
                this.error |= ec_write_byte(this, sym);
                if !(c_transpiler_pre_decrement(*(this.ext)) > 0) break;
            }
        }
        this.rem = cast,no_check(s32) ((cast,no_check(u32) c) & ((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1));
    } else {
        this.ext += 1;
    }
}

ec_write_byte :: (this: *Ec_Enc, value: u32) -> s32 {
    if this.offs + this.end_offs >= this.storage {
        return -1;
    }
    this.buf[this.offs] = cast,no_check(u8) value;
    this.offs += 1;
    return 0;
}

ec_encode_bin :: (this: *Ec_Enc, fl: u32, fh: u32, bits: u32) {
    r := this.rng >> ((bits) & 31);
    if fl > 0 {
        this.val = cast,no_check(Uint32) (this.val + (this.rng - r * ((cast(u32) 1) << ((bits) & 31) - fl)));
        this.rng = r * (fh - fl);
    } else {
        this.rng = cast,no_check(Uint32) (this.rng - (r * ((cast(u32) 1) << ((bits) & 31) - fh)));
    }
    ec_enc_normalize(this);
}

ec_enc_bit_logp :: (this: *Ec_Enc, val: s32, logp: u32) {
    r := this.rng;
    l := this.val;
    s := r >> ((logp) & 31);
    r -= s;
    if val != 0 {
        this.val = l + r;
    }
    this.rng = ifx val != 0 then s else r;
    ec_enc_normalize(this);
}

ec_enc_icdf :: (this: *Ec_Enc, s: s32, icdf: *u8, ftb: u32) {
    r := this.rng >> ((ftb) & 31);
    if s > 0 {
        this.val += this.rng - r * cast(Uint32) icdf[s - 1];
        this.rng = r * cast,no_check(Uint32) ((cast(s32) icdf[s - 1]) - cast(s32) icdf[s]);
    } else {
        this.rng -= r * cast(Uint32) icdf[s];
    }
    ec_enc_normalize(this);
}

ec_enc_icdf16 :: (this: *Ec_Enc, s: s32, icdf: *Uint16, ftb: u32) {
    r := this.rng >> ((ftb) & 31);
    if s > 0 {
        this.val += this.rng - r * cast(Uint32) icdf[s - 1];
        this.rng = r * cast,no_check(Uint32) ((cast(s32) icdf[s - 1]) - cast(s32) icdf[s]);
    } else {
        this.rng -= r * cast(Uint32) icdf[s];
    }
    ec_enc_normalize(this);
}

ec_enc_uint :: (this: *Ec_Enc, fl_value: Uint32, ft_value: Uint32) {
    ft: u32 = ---;
    fl: u32 = ---;

    ft_value -= 1;
    ftb := (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(ft_value);
    if ftb > 8 {
        ftb -= 8;
        ft = ft_value >> ((ftb) & 31) + 1;
        fl = fl_value >> ((ftb) & 31);
        ec_encode(this, fl, fl + 1, ft);
        ec_enc_bits(this, fl_value & ((cast(Uint32) 1) << ((ftb) & 31) - 1), cast,no_check(u32) ftb);
    } else {
        ec_encode(this, fl_value, fl_value + 1, ft_value + 1);
    }
}

ec_enc_bits :: (this: *Ec_Enc, fl: Uint32, bits: u32) {
    window := this.end_window;
    used := this.nend_bits;

    if (cast,no_check(u32) used) + bits > cast,no_check(u32) ((cast,no_check(s32) (cast(u64) size_of(Ec_Window))) * 8) {
        while true {
            this.error |= ec_write_byte_at_end(this, window & ((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1));
            c_transpiler_compound_shr(*(window), (cast(s32) 8), Ec_Window, Ec_Window);
            used -= 8;
            if !(used >= 8) break;
        }
    }
    window |= fl << ((used) & 31);
    used = cast,no_check(s32) ((cast,no_check(u32) used) + bits);
    this.end_window = window;
    this.nend_bits = used;
    this.nbits_total = cast,no_check(s32) ((cast,no_check(u32) this.nbits_total) + bits);
}

ec_write_byte_at_end :: (this: *Ec_Enc, value: u32) -> s32 {
    if this.offs + this.end_offs >= this.storage {
        return -1;
    }
    assignment_0: u8 = cast,no_check(u8) value;
    (this.buf[this.storage - c_transpiler_pre_increment(*(this.end_offs))]) = assignment_0;
    return 0;
}

ec_enc_patch_initial_bits :: (this: *Ec_Enc, val: u32, nbits: u32) {
    shift := cast,no_check(s32) (8 - nbits);
    mask := cast,no_check(u32) (((cast(s32) 1) << ((nbits) & 31) - 1) << ((shift) & 31));
    if this.offs > 0 {
        this.buf[0] = cast,no_check(u8) ((cast(u32) this.buf[0]) & ~(mask) | (val << ((shift) & 31)));
    } else if this.rem >= 0 {
        this.rem = cast,no_check(s32) ((cast,no_check(u32) this.rem) & ~(mask) | (val << ((shift) & 31)));
    } else if this.rng <= (cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) >> ((nbits) & 31) {
        this.val =
            this.val & ~(mask << ((((cast,no_check(s32) ((32 - 8))) -
                1)) & 31)) | (val << ((((cast,no_check(s32) ((32 - 8))) - 1 + shift)) & 31));
    } else {
        this.error = -1;
    }
}

ec_enc_shrink :: (this: *Ec_Enc, size: Uint32) {
    (this.offs + this.end_offs <= size);
    move_memory(
        this.buf + size - this.end_offs,
        this.buf + this.storage - this.end_offs,
        (cast(u64) this.end_offs) * size_of(u8) +
        cast,no_check(u64) (0 * (this.buf + size - this.end_offs - (this.buf + this.storage - this.end_offs)))
    );
    this.storage = size;
}

ec_enc_done :: (this: *Ec_Enc) {
    l := 32 - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
    msk := ((cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) - 1) >> ((l) & 31);
    end := (this.val + msk) & ~(msk);
    if end | msk >= this.val + this.rng {
        l += 1;
        c_transpiler_compound_shr(*(msk), (cast(s32) 1), Uint32, Uint32);
        end = (this.val + msk) & ~(msk);
    }
    while l > 0 {
        ec_enc_carry_out(this, cast,no_check(s32) (end >> ((((cast,no_check(s32) ((32 - 8))) - 1)) & 31)));
        end = end << 8 & ((cast,no_check(Uint32) (((cast(u32) 1) << (((32 - 1)) & 31)))) - 1);
        l -= 8;
    }

    if this.rem >= 0 || this.ext > 0 {
        ec_enc_carry_out(this, 0);
    }

    window := this.end_window;
    used := this.nend_bits;
    while used >= 8 {
        this.error |= ec_write_byte_at_end(this, window & ((cast,no_check(u32) (((cast(u32) 1) << 8))) - 1));
        c_transpiler_compound_shr(*(window), (cast(s32) 8), Ec_Window, Ec_Window);
        used -= 8;
    }

    if this.error == 0 {
        if this.buf != null {
            fill_memory(this.buf + this.offs, 0, cast,no_check(u64) (this.storage - this.offs - this.end_offs));
        }
        if used > 0 {
            if this.end_offs >= this.storage {
                this.error = -1;
            } else {
                l = -l;

                if this.offs + this.end_offs >= this.storage && l < used {
                    window &= cast,no_check(Ec_Window) ((cast(s32) 1) << ((l) & 31) - 1);
                    this.error = -1;
                }
                this.buf[this.storage - this.end_offs - 1] = cast,no_check(u8) ((cast,no_check(s32) this.buf[this.storage - this.end_offs - 1]) | cast,no_check(s32) (cast,no_check(u8) window));
            }
        }
    }
}

