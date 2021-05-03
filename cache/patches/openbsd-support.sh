# Disable building with -fno-PIE on OpenBSD
patch -p1 << EOF
--- a/gcc/Makefile.in
+++ b/gcc/Makefile.in
@@ -270,9 +270,6 @@ COMPILER += \$(CET_HOST_FLAGS)
 NO_PIE_CFLAGS = @NO_PIE_CFLAGS@
 NO_PIE_FLAG = @NO_PIE_FLAG@
 
-# We don't want to compile the compilers with -fPIE, it make PCH fail.
-COMPILER += \$(NO_PIE_CFLAGS)
-
 # Link with -no-pie since we compile the compiler with -fno-PIE.
 LINKER += \$(NO_PIE_FLAG)
 
@@ -803,8 +800,6 @@ NO_PIE_FLAG_FOR_BUILD = @NO_PIE_FLAG_FOR_BUILD@
 BUILD_CFLAGS= @BUILD_CFLAGS@ \$(GENERATOR_CFLAGS) -DGENERATOR_FILE
 BUILD_CXXFLAGS = @BUILD_CXXFLAGS@ \$(GENERATOR_CFLAGS) -DGENERATOR_FILE
 BUILD_NO_PIE_CFLAGS = @BUILD_NO_PIE_CFLAGS@
-BUILD_CFLAGS += \$(BUILD_NO_PIE_CFLAGS)
-BUILD_CXXFLAGS += \$(BUILD_NO_PIE_CFLAGS)
 
 # Native compiler that we use.  This may be C++ some day.
 COMPILER_FOR_BUILD = \$(CXX_FOR_BUILD)
EOF

# Add /usr/lib to LINK_SPEC
patch -p1 << EOF
--- a/gcc/config/i386/openbsdelf.h
+++ b/gcc/config/i386/openbsdelf.h
@@ -76,7 +76,8 @@ along with GCC; see the file COPYING3.  If not see
    %{static:-Bstatic} \\
    %{!static:-Bdynamic} \\
    %{assert*} \\
-   -dynamic-linker /usr/libexec/ld.so"
+   -dynamic-linker /usr/libexec/ld.so \\
+   %{!nostdlib:-L/usr/lib}"
 
 #undef STARTFILE_SPEC
 #define STARTFILE_SPEC "\\
EOF

# Fix building target libraries
patch -p1 << EOF
--- a/gcc/config/t-openbsd
+++ b/gcc/config/t-openbsd
@@ -1,5 +1,9 @@
 # We don't need GCC's own include files.
-USER_H = \$(EXTRA_HEADERS)
+USER_H = \$(srcdir)/ginclude/stdfix.h \\
+	 \$(srcdir)/ginclude/stdnoreturn.h \\
+	 \$(srcdir)/ginclude/stdalign.h \\
+	 \$(srcdir)/ginclude/stdatomic.h \\
+	 \$(EXTRA_HEADERS)
 
 # OpenBSD-specific D support.
 openbsd-d.o: \$(srcdir)/config/openbsd-d.c
EOF
