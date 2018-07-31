# Fix multilib support on ARM to test soft-float ABI on a hard-float host.
# Taken and abridged from Ubuntu patches.
cat >> gcc/config/arm/linux-eabi.h << EOF

#undef  TARGET_DEFAULT_FLOAT_ABI
#define TARGET_DEFAULT_FLOAT_ABI ARM_FLOAT_ABI_HARD

#if TARGET_BIG_ENDIAN_DEFAULT
#define MULTILIB_DEFAULT_ENDIAN "mbig-endian"
#else
#define MULTILIB_DEFAULT_ENDIAN "mlittle-endian"
#endif

#undef  MULTILIB_DEFAULTS
#define MULTILIB_DEFAULTS \
       { "mthumb", MULTILIB_DEFAULT_ENDIAN, \
         "mfloat-abi=hard", "mno-thumb-interwork" }
EOF

cat >> gcc/config/arm/t-linux-eabi << EOF

MULTILIB_OPTIONS       = mfloat-abi=soft/mfloat-abi=hard
MULTILIB_DIRNAMES      = sf hf
MULTILIB_EXCEPTIONS    =
MULTILIB_MATCHES       = mfloat-abi?hard=mhard-float mfloat-abi?soft=msoft-float mfloat-abi?soft=mfloat-abi?softfp
MULTILIB_OSDIRNAMES    = arm-linux-gnueabi:arm-linux-gnueabi ../lib:arm-linux-gnueabihf
EOF
