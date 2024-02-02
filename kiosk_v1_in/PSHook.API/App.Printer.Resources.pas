unit App.Printer.Resources;

interface

const
  REALTIME_LOGO: array [0..6343] of Byte = (
    $1c,$71,$01,$48,$00,$0b,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $3c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$3f,$0f,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$07,$ff,$00,
    $00,$00,$00,$00,$00,$00,$00,$08,$03,$ff,$f0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$7f,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,
    $fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$fc,$00,$00,$00,$00,
    $00,$00,$00,$00,$01,$f0,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$03,
    $f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$f0,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $07,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$c0,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$07,$c0,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$07,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$80,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,
    $ff,$f8,$07,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$c7,$00,$00,
    $00,$00,$00,$00,$00,$03,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,
    $00,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$0f,$00,$3f,$e0,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$f0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$0f,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,
    $fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$3f,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$0e,$1f,$80,$00,$00,$00,$00,$00,$00,$00,$00,
    $0c,$07,$80,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$03,$c0,$00,$00,
    $00,$00,$00,$00,$00,$00,$1c,$01,$e0,$00,$00,$00,$00,$00,$00,$00,
    $00,$1c,$00,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$f0,$00,
    $00,$00,$00,$00,$00,$00,$00,$1c,$00,$78,$00,$00,$00,$00,$00,$00,
    $00,$00,$18,$00,$78,$00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$3c,
    $00,$00,$00,$00,$00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,$00,
    $00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,$00,
    $3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,
    $00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,
    $00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$30,$00,$3c,$00,$00,$00,
    $00,$00,$00,$00,$00,$30,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,
    $30,$00,$38,$00,$00,$00,$00,$00,$00,$01,$e0,$00,$00,$38,$00,$00,
    $00,$00,$00,$00,$00,$f8,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,
    $7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$1f,$80,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$1f,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$80,$40,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$01,$f0,$18,$00,$00,$00,$00,$00,
    $00,$00,$00,$03,$f0,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$03,$f8,
    $3c,$00,$00,$00,$00,$00,$00,$00,$00,$03,$f8,$3c,$00,$00,$00,$00,
    $00,$00,$00,$00,$07,$f8,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$07,
    $38,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$07,$38,$3c,$00,$00,$00,
    $00,$00,$00,$00,$00,$07,$3c,$3c,$00,$00,$00,$00,$00,$00,$00,$00,
    $07,$1c,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$06,$1c,$1c,$00,$00,
    $00,$00,$00,$00,$00,$00,$06,$1c,$1c,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$1e,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1e,$38,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$0f,$f8,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$0f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$f0,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$e0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$fe,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$01,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$ff,
    $80,$00,$00,$00,$00,$00,$00,$00,$00,$07,$ff,$80,$00,$00,$00,$00,
    $00,$00,$00,$00,$0f,$f1,$80,$00,$00,$00,$00,$00,$00,$00,$00,$0f,
    $c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$80,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$1f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $3f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$10,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$3e,$18,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$7c,$1e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$1f,$c0,$00,
    $00,$00,$00,$00,$00,$00,$00,$7c,$1f,$f0,$00,$00,$00,$00,$00,$00,
    $00,$00,$7c,$0f,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$0f,$ff,
    $e0,$00,$00,$00,$00,$00,$00,$00,$7c,$03,$ff,$fc,$00,$00,$00,$00,
    $00,$00,$00,$7c,$00,$1f,$ff,$80,$00,$00,$00,$00,$00,$00,$7c,$00,
    $00,$ff,$e0,$00,$00,$00,$00,$00,$00,$7c,$00,$06,$07,$f0,$00,$00,
    $00,$00,$00,$00,$7c,$00,$07,$80,$f0,$00,$00,$00,$00,$00,$00,$3e,
    $00,$07,$c0,$38,$00,$00,$00,$00,$00,$00,$3e,$00,$07,$f0,$00,$00,
    $00,$00,$00,$00,$00,$3f,$00,$0e,$f8,$00,$00,$00,$00,$00,$00,$00,
    $1f,$80,$0e,$7c,$00,$00,$00,$00,$00,$00,$00,$1f,$c0,$1c,$1e,$00,
    $00,$00,$00,$00,$00,$00,$0f,$f0,$3c,$0f,$00,$00,$00,$00,$00,$00,
    $00,$07,$ff,$f8,$0f,$80,$00,$00,$00,$00,$00,$00,$03,$ff,$f0,$07,
    $c0,$00,$00,$00,$00,$00,$00,$00,$ff,$e0,$03,$e0,$00,$00,$00,$00,
    $00,$00,$00,$1f,$00,$01,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $01,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7e,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$7e,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$7e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,
    $fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$f8,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $07,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$f0,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$3f,$e0,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$c0,$00,$00,
    $00,$00,$00,$00,$00,$00,$03,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,
    $00,$03,$87,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$07,$03,$e0,$00,
    $00,$00,$00,$00,$00,$00,$00,$0e,$01,$e0,$00,$00,$00,$00,$00,$00,
    $00,$00,$0e,$18,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$38,$f0,
    $00,$00,$00,$00,$00,$00,$00,$00,$1c,$78,$70,$00,$00,$00,$00,$00,
    $00,$00,$00,$1c,$f0,$70,$00,$00,$00,$00,$00,$00,$00,$00,$1d,$f0,
    $30,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$e0,$38,$00,$00,$00,$00,
    $00,$00,$00,$00,$3f,$e0,$38,$00,$00,$00,$00,$00,$00,$00,$00,$3f,
    $c0,$38,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$80,$18,$00,$00,$00,
    $00,$00,$00,$00,$00,$3f,$80,$18,$00,$00,$00,$00,$00,$00,$00,$00,
    $3f,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$00,$08,$00,$00,
    $00,$00,$00,$00,$00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$03,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$f8,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$f8,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$3f,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78,
    $78,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$78,$00,$00,$00,$00,
    $00,$00,$00,$00,$01,$c0,$78,$00,$00,$00,$00,$00,$00,$00,$00,$03,
    $c0,$78,$00,$00,$00,$00,$00,$00,$00,$00,$07,$80,$70,$00,$00,$00,
    $00,$00,$00,$00,$00,$0f,$80,$f0,$00,$00,$00,$00,$00,$00,$00,$00,
    $0f,$80,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$01,$e0,$00,$00,
    $00,$00,$00,$00,$00,$00,$1f,$01,$e0,$00,$00,$00,$00,$00,$00,$00,
    $00,$3f,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$3e,$03,$c0,$00,
    $00,$00,$00,$00,$00,$00,$00,$3e,$07,$80,$00,$00,$00,$00,$00,$00,
    $00,$00,$3c,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$38,$0f,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$1e,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$38,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$70,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$c0,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$03,$80,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$03,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$80,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$e0,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$03,$f0,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$f8,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$fc,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $7c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$fc,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$fc,$00,$00,$00,$00,
    $00,$00,$00,$00,$3f,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$3f,
    $ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$1f,$e0,$01,$f8,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$1f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$80,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$c0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$03,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,
    $f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f0,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $e0,$38,$00,$00,$00,$00,$00,$00,$00,$00,$01,$f0,$3c,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$f0,$3c,$00,$00,$00,$00,$00,$00,$00,$00,
    $03,$e0,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$07,$e0,$1e,$00,$00,
    $00,$00,$00,$00,$00,$00,$07,$c0,$1e,$00,$00,$00,$00,$00,$00,$00,
    $00,$07,$c0,$1e,$00,$00,$00,$00,$00,$00,$00,$00,$07,$80,$1e,$00,
    $00,$00,$00,$00,$00,$00,$00,$07,$80,$1e,$00,$00,$00,$00,$00,$00,
    $00,$00,$07,$00,$1c,$00,$00,$00,$00,$00,$00,$7f,$e0,$07,$00,$1c,
    $00,$00,$00,$00,$00,$01,$ff,$ff,$07,$00,$1c,$00,$00,$00,$00,$00,
    $03,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$01,$ff,$ff,$ff,$00,
    $00,$00,$00,$00,$00,$00,$00,$3f,$f9,$ff,$c0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$0f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,
    $f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$fc,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$0e,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $0e,$1f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$0f,$80,$00,$00,
    $00,$00,$00,$00,$00,$00,$0c,$03,$c0,$00,$00,$00,$00,$00,$00,$00,
    $00,$1c,$03,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$01,$f0,$00,
    $00,$00,$00,$00,$00,$00,$00,$1c,$00,$f0,$00,$00,$00,$00,$00,$00,
    $00,$00,$1c,$00,$78,$00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$78,
    $00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$78,$00,$00,$00,$00,$00,
    $00,$00,$00,$18,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,$00,
    $3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,
    $00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,
    $00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$38,$00,$1c,$00,$00,$00,
    $00,$00,$00,$00,$00,$38,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,
    $30,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$70,$00,$3c,$00,$00,
    $00,$00,$00,$00,$00,$00,$30,$00,$38,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,
    $00,$00,$00,$00,$00,$00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fe,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$3f,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$1f,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7e,$0f,$f8,
    $00,$00,$00,$00,$00,$00,$00,$00,$7e,$07,$ff,$80,$00,$00,$00,$00,
    $00,$00,$00,$38,$01,$ff,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $7f,$fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$fc,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$01,$fc,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$03,$e0,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$1f,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,$f0,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$f0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$01,$f1,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,
    $80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$80,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$03,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$80,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$01,$c0,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$01,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$7c,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$80,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $01,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$01,$e0,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$80,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$1f,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$7e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$01,$f8,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$03,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$c0,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$07,$c0,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$c0,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$e0,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$01,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,
    $f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$7f,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$e0,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$0f,$e0,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$07,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$c0,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$1f,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3f,
    $c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$e0,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$01,
    $c3,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$01,$81,$f0,$00,$00,$00,
    $00,$00,$00,$00,$00,$03,$80,$f0,$00,$00,$00,$00,$00,$00,$00,$00,
    $03,$04,$78,$00,$00,$00,$00,$00,$00,$00,$00,$07,$0c,$78,$00,$00,
    $00,$00,$00,$00,$00,$00,$06,$1c,$38,$00,$00,$00,$00,$00,$00,$00,
    $00,$0e,$3c,$38,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$78,$1c,$00,
    $00,$00,$00,$00,$00,$00,$00,$0e,$f8,$1c,$00,$00,$00,$00,$00,$00,
    $00,$00,$1f,$f0,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$f0,$1c,
    $00,$00,$00,$00,$00,$00,$00,$00,$1f,$e0,$0c,$00,$00,$00,$00,$00,
    $00,$00,$00,$1f,$e0,$0c,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$c0,
    $0c,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$80,$04,$00,$00,$00,$00,
    $00,$00,$00,$00,$0f,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$0e,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00
  );

implementation

end.











