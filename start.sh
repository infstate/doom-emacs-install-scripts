
#!/bin/sh -e
# This script if just for the one line quick start 
# Credits to Linutil by ChrisTitus.
# Prevent execution if this script was only partially downloaded
{
RC='\033[0m'
RED='\033[0;31m'

URL="https://raw.githubusercontent.com/infstate/doom-emacs-install-scripts/refs/heads/main/doom-universal-linux.sh"
TMPFILE=$(mktemp)
check() {
    exit_code=$1
    message=$2

    if [ "$exit_code" -ne 0 ]; then
        printf "%b\n" "${RED}ERROR: $message${RC}"
        exit 1
    fi
}
check $? "Creating the temporary file"

printf "%b\n" "Downloading universal script from $URL"
curl -fsL "$URL" -o "$TMPFILE"
check $? "Downloading unversal"

chmod +x "$TMPFILE"
check $? "Making script executable"

"$TMPFILE" "$@"
check $? "Executing doom-emacs-install-scripts"

rm -f "$TMPFILE"
check $? "Deleting the temporary file"
} # End of wrapping
