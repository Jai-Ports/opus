CORRECTION: [8] u32;

ec_range_bytes_in_entcode :: (this: *Ec_Ctx) -> Uint32 {
    return this.offs;
}

ec_get_buffer_in_entcode :: (this: *Ec_Ctx) -> *u8 {
    return this.buf;
}

ec_get_error_in_entcode :: (this: *Ec_Ctx) -> s32 {
    return this.error;
}

ec_tell_in_entcode :: (this: *Ec_Ctx) -> s32 {
    return this.nbits_total - ((cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng));
}

ec_tell_frac :: (this: *Ec_Ctx) -> Uint32 {

    nbits := cast,no_check(Uint32) (this.nbits_total << 3);
    l := (cast,no_check(s32) (cast(u64) size_of(u32))) * 8 - c_transpiler_clz32(this.rng);
    r := this.rng >> (((l - 16)) & 31);
    b := r >> 12 - 8;
    b += cast(u32) (r > CORRECTION[b]);
    l = cast,no_check(s32) ((cast,no_check(u32) (l << 3)) + b);
    return nbits - cast,no_check(Uint32) l;
}

celt_udiv_in_entcode :: (n: Uint32, d: Uint32) -> Uint32 {
    return n / d;
}

celt_sudiv_in_entcode :: (n: Int32, d: Int32) -> Int32 {
    return n / d;
}

globals_initialization_state_for_entcode: u32;
initialize_globals_for_entcode :: () {
    {
        state := atomic_load(*globals_initialization_state_for_entcode);
        if state == 2 return;
        won, _ := compare_and_swap(*globals_initialization_state_for_entcode, 0, 1);
        if !won {
            while atomic_load(*globals_initialization_state_for_entcode) != 2 {}
            return;
        }
    }
    CORRECTION =
        u32.[
            35733,
            38967,
            42495,
            46340,
            50535,
            55109,
            60097,
            65535
        ];
    atomic_store(*globals_initialization_state_for_entcode, 2);
}

