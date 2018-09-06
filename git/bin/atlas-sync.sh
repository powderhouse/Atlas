#!/bin/sh

DATE=`date '+%Y-%m-%d %H:%M:%S'`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "<STARTENTRY>"
echo ""
echo "Recorded: ${DATE}"
echo ""

export AWS_ACCESS_KEY_ID=AKIAJHOYA3XIQOYIBHKA
export AWS_SECRET_ACCESS_KEY=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

(cd "${DIR}" && cd "../.." && git pull origin master) || true
(cd "${DIR}" && cd "../.." && git push --set-upstream origin master) || true
(cd "${DIR}" && cd "../.." && git annex sync --content) || true

echo ""
echo "</ENDENTRY>"
