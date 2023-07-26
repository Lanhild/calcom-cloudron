#/usr/bin/env bash

# This script is used to prevent UI inconsistencies on links and buttons
# by replacing the placeholder URL with the actual URL of the app.

FROM=$1
TO=$2

if [ "${FROM}" = "${TO}" ]; then
    echo "FROM and TO are the same, nothing to do"
    exit 0
fi

# Only perform action if $FROM and $TO are different.
echo "Replacing all statically built instances of $FROM with $TO."

find /app/code/apps/web/.next /app/code/apps/web/public -type -f |
while read file; do
    sed -i "s|$FROM|$TO|g" "$file"
done
