#!/bin/bash

# List of all target name/triplet that we build.
targets=(
    #'ubuntu-alpha/alpha-linux-gnu'
    'ubuntu-arm/arm-linux-gnueabi'
    'ubuntu-armhf/arm-linux-gnueabihf'
    'ubuntu-aarch64/aarch64-linux-gnu'
    #'ubuntu-hppa/hppa-linux-gnu'
    #'ubuntu-hppa64/hppa64-linux-gnu'
    'ubuntu-mips/mips-linux-gnu'
    #'ubuntu-mips64/mips64-linux-gnuabi64'
    'ubuntu-mips64el/mips64el-linux-gnuabi64'
    'ubuntu-mipsel/mipsel-linux-gnu'
    #'ubuntu-powerpc/powerpc-linux-gnu'
    #'ubuntu-powerpc64/powerpc64-linux-gnu'
    'ubuntu-powerpc64le/powerpc64le-linux-gnu'
    'ubuntu-systemz/s390x-linux-gnu'
    #'ubuntu-sh4/sh4-linux-gnu'
    'ubuntu-sparc64/sparc64-linux-gnu'
    'ubuntu-x86_64/x86_64-linux-gnu'
)

# Agents where host == target.
declare -A native_targets
native_targets['ubuntu-x86_64']=1
declare -A native_ports
native_ports['ubuntu-arm']=1
native_ports['ubuntu-armhf']=1
native_ports['ubuntu-aarch64']=1

cat << 'EOF'
steps:
EOF

for target in "${targets[@]}"; do
    name=$(cut -d/ -f1 <<< ${target})
    triplet=$(cut -d/ -f2 <<< ${target})
    bootstrap='disable'

    # Don't build the self-hosted compiler on native ports.
    # Unfortunately we don't have a working D compiler for them.
    if [ "${native_ports[$name]:-x}" != 'x' ]; then
        if [ `expr "${BUILDKITE_BRANCH}" : '.*stable'` -ne 0 ]; then
            host='native'
        elif [ `expr "${BUILDKITE_PULL_REQUEST_BASE_BRANCH}" : '.*stable'` -ne 0 ]; then
            host='native'
        else
            host='cross'
        fi
    elif [ "${native_targets[$name]:-x}" != 'x' ]; then
        # Test bootstrap builds on master branches where supported.
        if [ `expr "${BUILDKITE_BRANCH}" : '.*stable'` -eq 0 ]; then
            bootstrap='enable'
        elif [ `expr "${BUILDKITE_PULL_REQUEST_BASE_BRANCH}" : '.*stable'` -eq 0 ]; then
            bootstrap='enable'
        fi
        host='bootstrap'
    else
        host='cross'
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
