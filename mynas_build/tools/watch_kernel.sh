#!/bin/bash
# 设置你要监控的 kernel 版本（例如：6.5-rc4）
WATCH_VERSION=${1:-"6.15"}
HOOK=${2:-"compile_kernel"}
CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function check_ver() {
    # 从 kernel.org 获取 kdist XML 源
    XML_FEED=$(curl -s https://www.kernel.org/feeds/kdist.xml | sed 's/\&lt;/\</g' | sed 's/\&gt;/\>/g')
    #XML_FEED=$(cat $CURDIR/kdist.xml | sed 's/\&lt;/\</g' | sed 's/\&gt;/\>/g')

    table=$(echo "$XML_FEED"|xmllint --xpath '//item/description/table' - 2>/dev/null)
    echo "table==$table"
    IFS=$'\t' read -d '' -r -a table_array < <(
        echo "$table" | awk 'BEGIN{RS="</table>"; ORS=""} /<table/{print $0"</table>\t"}'
    )

    updated="false"
    old=$(cat $CURDIR/../.kernel_version|| echo "")

    for one in "${table_array[@]}"; do
        VER=$(echo "$one" | xmllint --xpath '//table//tr[1]/td[1]/strong/text()' - 2>/dev/null)
        # 如果发现版本号比 WATCH_VERSION 新（字符串不相等），就输出信息
        if [[ "$VER" == "$WATCH_VERSION"* ]]; then
            if [[ "$VER" == "$old" ]]; then
                echo "无更新，当前版本已是最新：$VER"
            else
                echo "✅ 新版本发布：$old --> $VER"
                # 获取对应的 changelog URL
                CHANGELOG=$(echo "$one" | xmllint --xpath '//table//tr[6]/td[1]/a/@href' - 2>/dev/null | sed -E 's/href="([^"]*)"/\1\n/g')
                $HOOK $VER
                if [ $? -eq 0 ]; then
                    echo "$VER" > $CURDIR/../.kernel_version
                    build_iso
                else
                    echo "last=="$?
                fi
                if [[ -n "$CHANGELOG_URL" ]]; then
                    echo "🔗 changelog: $CHANGELOG_URL"
                else
                    echo "ℹ️ 未找到 changelog 链接"
                fi
            fi
        fi
    done

}

function compile_kernel() {
    cd $CURDIR/../kernel
    #echo "skip"
    ./build.sh init_source --kernel_version=v$1 && ./build.sh clean && ./build.sh build --kernel_version=v$1 && ./build.sh copy_deb

}

function build_iso() {
    cd $CURDIR/../
    make
}

check_ver
