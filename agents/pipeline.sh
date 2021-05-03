#!/bin/bash

# List of all target name/triplet that we build.
targets=(
    #'ubuntu-alpha/alpha-linux-gnu/linux'
    'ubuntu-arm/arm-linux-gnueabi/linux'
    'ubuntu-armhf/arm-linux-gnueabihf/linux'
    'ubuntu-aarch64/aarch64-linux-gnu/linux'
    #'ubuntu-hppa/hppa-linux-gnu/linux'
    #'ubuntu-hppa64/hppa64-linux-gnu/linux'
    'ubuntu-mips/mips-linux-gnu/linux'
    #'ubuntu-mips64/mips64-linux-gnuabi64/linux'
    'ubuntu-mips64el/mips64el-linux-gnuabi64/linux'
    'ubuntu-mipsel/mipsel-linux-gnu/linux'
    #'ubuntu-powerpc/powerpc-linux-gnu/linux'
    #'ubuntu-powerpc64/powerpc64-linux-gnu/linux'
    'ubuntu-powerpc64le/powerpc64le-linux-gnu/linux'
    'ubuntu-systemz/s390x-linux-gnu/linux'
    #'ubuntu-sh4/sh4-linux-gnu/linux'
    'ubuntu-sparc64/sparc64-linux-gnu/linux'
    'ubuntu-x86_64/x86_64-linux-gnu/linux'
    'openbsd-amd64/amd64-unknown-openbsd6.9/openbsd'
)

# Agents where host == target.
declare -A native_targets
native_targets['ubuntu-x86_64']=1
#native_targets['ubuntu-arm']=1
#native_targets['ubuntu-armhf']=1
#native_targets['ubuntu-aarch64']=1
native_targets['openbsd-amd64']=1

# Agents where to build bootstrap.
declare -A bootstrap_targets
bootstrap_targets['ubuntu-x86_64']=1

cat << 'EOF'
steps:
EOF

for target in "${targets[@]}"; do
    name=$(cut -d/ -f1 <<< ${target})
    triplet=$(cut -d/ -f2 <<< ${target})
    os=$(cut -d/ -f3 <<< ${target})
    bootstrap='disable'

    # TODO: Get a working D compiler on native targets.
    # Unfortunately we don't have a working D compiler for them.
    if [ "${native_targets[$name]:-x}" != 'x' ]; then
        host='native'
        if [ "${bootstrap_targets[$name]:-x}" != 'x' ]; then
            host='bootstrap'
            bootstrap='enable'
        fi
    else
        host='cross'
        os='linux'
    fi

cat << EOF
  - label: "${name}"
    command: |
      echo "--- Configure gdc"
      ./buildci.sh configure
      echo "--- Build gdc"
      ./buildci.sh build
      echo "--- Run testsuite"
      ./buildci.sh testsuite
      echo "--- Run unittests"
      ./buildci.sh unittests
    env:
      BUILDKITE_OS: ${os}
      BUILDKITE_TARGET: ${triplet}
      BUILDKITE_CACHE_DIR: '/buildkite/cache'
      BUILDKITE_BOOTSTRAP: ${bootstrap}
    agents:
      - ${name}=1
      - ${host}=1
    artifact_paths:
      - "logs/**/*"

EOF
done
