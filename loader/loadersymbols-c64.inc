; repository version 194, built on Sun, 14 Jan 2024 16:51:30 +0200 for project "loader" using
; make PLATFORM=c64 save INSTALL=4000 RESIDENT=440 TRANSIENT=bb00 ZP=16 PROJECT=

; configuration
config_ALLOW_2_MHZ_ON_C128      = 0
config_DECOMPRESSOR             = 0; NONE
config_DIRTRACK                 = 18
config_DIRTRACK81               = 40
config_END_ADDRESS_API          = 0
config_FILENAME_MAXLENGTH       = 16
config_FILE_EXISTS_API          = 0
config_INTERNAL                 = 0
config_LOAD_COMPD_API           = 0
config_LOAD_RAW_API             = 1
config_LOAD_TO_API              = 0
config_LOAD_UNDER_D000_DFFF     = 0
config_LOAD_VIA_KERNAL_FALLBACK = 0
config_MEM_DECOMP_API           = 0
config_MEM_DECOMP_TO_API        = 0
config_NTSC_COMPATIBILITY       = 0
config_ONLY_1541_AND_COMPATIBLE = 1
config_PREFER_SPEED_OVER_SIZE   = 0
config_UNINSTALL_API            = 0

; status codes
status_OK                       = $00
status_FILE_TOO_LARGE           = $f7
status_FILE_ON_DISK_TOO_SMALL   = $f8
status_FILE_ON_DISK_TOO_LARGE   = $f9
status_WRITE_PROTECT_ON         = $fa
status_DEVICE_INCOMPATIBLE      = $fb
status_TOO_MANY_DEVICES         = $fc
status_GENERIC_KERNAL_ERROR     = $fd
status_DEVICE_NOT_PRESENT       = $fe
status_FILE_NOT_FOUND           = $ff

; zeropage $16-$2d
loader_zp_first                 = $16
loadaddrlo                      = $16
loadaddrhi                      = $17
loader_zp_last                  = $1a
plugin_zp_last                  = $2c

; install $4000-$4c97
install                         = $4000

; resident $0440-$0520
loadraw                         = $0440

; transient $bb00-$bfbb
save                            = $bb00
swapdrvcod                      = $bd75
restoreldr                      = $bdfc
sendbyte                        = $be1e
receivbyte                      = $be3a
