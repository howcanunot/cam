#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

home=$1
temp=$2

max=1024

list="${temp}/files-with-long-lines.txt"
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
touch "${list}"

candidates="${temp}/files-to-check-line-lengths.txt"
find "${home}" -type f -name '*.java' -print > "${candidates}"
while read -r f; do
    length=$(awk '{ print length }' < "${f}" | sort -n | tail -1)
    if [ "${length}" -gt "${max}" ]; then
        echo "${f}" >> "${list}"
        rm "${f}"
    fi
done < "${candidates}"

if [ -s "${list}" ]; then
    printf "There were %d files total; %d of them had at least one line longer than %d characters, which most probably is a symptom of an auto-generated code; that's why they all were deleted" \
        "$(wc -l < "${candidates}" | xargs)" "$(wc -l < "${list}" | xargs)" "${max}"
else
    printf "There were no files among %d total with lines longer than %d characters" \
        "$(wc -l < "${candidates}" | xargs)" "${max}"
fi
