#!/usr/bin/env sh
PKG_DIR="${1:-vendor}"
PKG_FILE="${2:-package.sh}"

. ./"$PKG_FILE"

get_val() {
    echo $(eval "echo \"\${$1[$2]}\"")
}

mkdir -p $PKG_DIR
cd $PKG_DIR
rm -rf -- *.mk

for package in $PACKAGES; do
    echo "Installing $package"
    url=$(get_val $package 0)
    commit=$(get_val $package 1)
    build=$(get_val $package 2)
    libfile=$(get_val $package 3)
    includes=$(get_val $package 4)

    if [ ! -d "$package" ]; then
        git clone $url $package
    fi
    cd $package
    git checkout $commit

    dir=$(pwd)
    eval $build

    cd $dir
    ARCHIVE=""
    for file in $libfile; do
        A=$(fd "$file" . -I -a | tr '\n' ' ')
        ARCHIVE="$ARCHIVE $A"
    done

    INCLUDES=""
    for i in $includes; do
        I=$(pwd)/$i
        INCLUDES="$INCLUDES $I"
    done
    cd ..

    cat <<EOF >$package.mk
ARCHIVE += $ARCHIVE
INCLUDES += $INCLUDES
EOF

done
