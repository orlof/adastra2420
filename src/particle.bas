CONST NUM_PARTICLES = 16
DIM asm_num_particles AS BYTE
    asm_num_particles = NUM_PARTICLES

DIM ParticleX(NUM_PARTICLES) AS BYTE
DIM ParticleY(NUM_PARTICLES) AS BYTE
DIM ParticleDX(NUM_PARTICLES) AS BYTE
DIM ParticleDY(NUM_PARTICLES) AS BYTE
DIM ParticleTTL(NUM_PARTICLES) AS BYTE
DIM ParticleAlive(NUM_PARTICLES) AS BYTE
DIM ParticleAddrHi(NUM_PARTICLES) AS BYTE
DIM ParticleAddrLo(NUM_PARTICLES) AS BYTE
DIM ParticleAddrY(NUM_PARTICLES) AS BYTE
DIM ParticleDelay(NUM_PARTICLES) AS BYTE

DIM NextParticle AS BYTE

SUB ParticleInit() SHARED STATIC
    FOR ZP_B0 = 0 TO NUM_PARTICLES - 1
        ParticleX(ZP_B0) = 0
        ParticleY(ZP_B0) = 0
        ParticleDX(ZP_B0) = 0
        ParticleDY(ZP_B0) = 0
        ParticleTTL(ZP_B0) = 0
        ParticleAlive(ZP_B0) = FALSE
        
        ParticleAddrHi(ZP_B0) = bitmap_y_tbl_hi(255)
        ParticleAddrLo(ZP_B0) = bitmap_y_tbl_lo(255)
        ParticleAddrY(ZP_B0) = 0
    NEXT ZP_B0
    NextParticle = 0
END SUB

SUB ParticleEmit(x AS BYTE, y AS BYTE, dx AS BYTE, dy AS BYTE, ttl AS BYTE, Speed AS BYTE) SHARED STATIC
    ParticleX(NextParticle) = x
    ParticleY(NextParticle) = y
    ParticleDX(NextParticle) = dx
    ParticleDY(NextParticle) = dy
    ParticleTTL(NextParticle) = ttl + GameTime
    ParticleAlive(NextParticle) = TRUE
    ParticleDelay(NextParticle) = Speed

    NextParticle = NextParticle + 1
    IF NextParticle = NUM_PARTICLES THEN NextParticle = 0
END SUB

SUB ParticleUpdate() SHARED STATIC
    ASM
        ldx {asm_num_particles}
particle_update_loop:
        dex
        bpl particle_update_continue
        jmp particle_update_end

particle_update_delay
        lda {ParticleTTL},x
        cmp {GameTime}
        beq particle_update_clear

        jmp particle_update_loop

particle_update_continue:
        lda {ParticleAlive},x
        beq particle_update_loop

        lda {ParticleDelay},x
        and {GameTime}
        bne particle_update_delay

particle_update_clear
        ; clear previous
        lda {ParticleAddrLo},x
        sta {ZP_W0}
        lda {ParticleAddrHi},x
        sta {ZP_W0}+1
        ldy {ParticleAddrY},x
        lda #0
        sta ({ZP_W0}),y

        lda {ParticleTTL},x
        cmp {GameTime}
        bne particle_update_update_dx

particle_update_disable:
        lda #0
        sta {ParticleAlive},x
        jmp particle_update_loop

particle_update_update_dx:
        lda {ParticleX},x
        sec
        sbc {ParticleDX},x

        ldy {ParticleDX},x
        bpl particle_update_dx_positive
particle_update_dx_negative:
        bcs particle_update_disable
        jmp particle_update_update_dy
particle_update_dx_positive:
        bcc particle_update_disable

particle_update_update_dy:
        sta {ParticleX},x

        lda {ParticleY},x
        sec
        sbc {ParticleDY},x

        ldy {ParticleDY},x
        bpl particle_update_dy_positive
particle_update_dy_negative:
        bcs particle_update_disable
        jmp particle_update_update_addr
particle_update_dy_positive:
        bcc particle_update_disable

particle_update_update_addr:
        sta {ParticleY},x

        tay
        lda {bitmap_y_tbl_lo},y
        sta {ZP_W0}
        sta {ParticleAddrLo},x
        lda {bitmap_y_tbl_hi},y
        sta {ZP_W0}+1
        sta {ParticleAddrHi},x
        lda {ParticleX},x
        and #%11111000
        sta {ParticleAddrY},x

        lda {ParticleX},x
        and #%00000111
        tay
        lda {hires_mask1},y
        ldy {ParticleAddrY},x
        sta ({ZP_W0}),y

        jmp particle_update_loop
particle_update_end:
    END ASM
END SUB
