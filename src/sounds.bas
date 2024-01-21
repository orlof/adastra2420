'INCLUDE "../libs/lib_common.bas"
'INCLUDE "../libs/lib_sfx.bas"

DIM SHARED SfxGameStart AS SFX
    SfxGameStart.Duration = 70
    SfxGameStart.Waveform = TRIANGLE
    SfxGameStart.AttackDecay = $71
    SfxGameStart.SustainRelease = $a9
    SfxGameStart.Frequency = $0764
    SfxGameStart.FrequencySlide = 63
    SfxGameStart.Bounce = 0
    SfxGameStart.Pulse = 0

DIM SHARED SfxEngine AS SFX
    SfxEngine.Duration = 16
    SfxEngine.Waveform = NOISE
    SfxEngine.AttackDecay = $00
    SfxEngine.SustainRelease = $c4
    SfxEngine.Frequency = $0264
    SfxEngine.FrequencySlide = 0
    SfxEngine.Bounce = 6
    SfxEngine.Pulse = 0

DIM SHARED SfxExplosion AS SFX
    SfxExplosion.Duration = 50
    SfxExplosion.Waveform = NOISE
    SfxExplosion.AttackDecay = $00
    SfxExplosion.SustainRelease = $fc
    SfxExplosion.Frequency = $0664
    SfxExplosion.FrequencySlide = -10
    SfxExplosion.Bounce = 0
    SfxExplosion.Pulse = 0

DIM SHARED SfxShot AS SFX
    SfxShot.Duration = 25
    SfxShot.Waveform = NOISE
    SfxShot.AttackDecay = $0a
    SfxShot.SustainRelease = $0a
    SfxShot.Frequency = $28c8
    SfxShot.FrequencySlide = -50
    SfxShot.Bounce = 0
    SfxShot.Pulse = 0

DIM SHARED SfxGold AS SFX
    SfxGold.Duration = 25
    SfxGold.Waveform = TRIANGLE
    SfxGold.AttackDecay = $a6
    SfxGold.SustainRelease = $96
    SfxGold.Frequency = $0004
    SfxGold.FrequencySlide = $3201
    SfxGold.Bounce = 3
    SfxGold.Pulse = 0

DIM SHARED SfxFuel AS SFX
    SfxFuel.Duration = 45
    SfxFuel.Waveform = TRIANGLE
    SfxFuel.AttackDecay = $85
    SfxFuel.SustainRelease = $76
    SfxFuel.Frequency = $0004
    SfxFuel.FrequencySlide = $1201
    SfxFuel.Bounce = 5
    SfxFuel.Pulse = 0

DIM SHARED SfxAsteroid AS SFX
    SfxAsteroid.Duration = 12
    SfxAsteroid.Waveform = NOISE
    SfxAsteroid.AttackDecay = $04
    SfxAsteroid.SustainRelease = $a4
    SfxAsteroid.Frequency = 5000
    SfxAsteroid.FrequencySlide = -1407
    SfxAsteroid.Bounce = 3
    SfxAsteroid.Pulse = 0

DIM SHARED VergeField AS SFX
    VergeField.Duration = 50
    VergeField.Waveform = TRIANGLE
    VergeField.AttackDecay = $0a
    VergeField.SustainRelease = $f6
    VergeField.Frequency = $28c8
    VergeField.FrequencySlide = 100
    VergeField.Bounce = 25
    VergeField.Pulse = 0
