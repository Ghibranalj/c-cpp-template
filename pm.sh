#!/usr/bin/env sh
PKG_DIR="$PWD/${1:-vendor}"
PKG_FILE="$PWD/${2:-package.sh}"

. "$PKG_FILE"

get_val() {
    eval "echo \"\${$1[$2]}\""
}

mkdir -p $PKG_DIR
cd $PKG_DIR
rm -rf -- *.mk

get_pkgs() {
    # get variable value of the string $1
    PKG=$(eval "echo \${$1}")
    #only set when its test
    SUFFIX=$2
    #if suffix is set then prefix = suffix_
    if [ ! -z "$SUFFIX" ]; then
        PREFIX="${2}_"
    fi
       
    for package in $PKG; do
        echo "Installing $package"
        url=$(get_val $package 0)
        commit=$(get_val $package 1)
        build=$(get_val $package 2)
        libfile=$(get_val $package 3)
        includes=$(get_val $package 4)

        if [ ! -d "$package" ]; then
            git clone --recurse-submodules $url $package
        fi

        cd $package
        git checkout $commit

        eval $build

        cd "$PKG_DIR/$package"
        ARCHIVE=""
        for file in $libfile; do
            A=$(fd "$file" . -I -a | tr '\n' ' ')
            echo "Found $(realpath --relative-to=$PKG_DIR $A)"
            ARCHIVE="$ARCHIVE $A"
        done

        INCLUDES=""
        for i in $includes; do
            I=$(pwd)/$i
            echo "Adding $(realpath --relative-to=$PKG_DIR $I) to includes"
            INCLUDES="$INCLUDES $I"
        done

        cd $PKG_DIR

        FILE_NAME="$package"
        if [ ! -z "$SUFFIX" ]; then
            FILE_NAME="$FILE_NAME.mk_$SUFFIX"
        else
            FILE_NAME="$FILE_NAME.mk"
        fi
        cat <<EOF >$FILE_NAME
${PREFIX}ARCHIVE += $ARCHIVE
${PREFIX}INCLUDES += $INCLUDES
EOF
    done
}

get_pkgs "PACKAGES"
get_pkgs "TESTS" "TEST"
