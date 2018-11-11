#!/bin/bash

grep -ohE '[^\/]*\.git\-[^\/]+' Atlas.xcodeproj/project.pbxproj | sort --unique | while read -r INPUT ; do
    echo "Ensuring $INPUT exists"

    if [ -e ".build/checkouts/$INPUT" ]; then
        echo "$INPUT exists already."
    else
        NAME=$(grep -ohE -m 1 '^[^\.]*\.git' <<< $INPUT)
        if compgen -G ".build/checkouts/$NAME*" > /dev/null; then
          eval "mv .build/checkouts/$NAME* .build/checkouts/$INPUT"
          echo "Moved $NAME to $INPUT"
        else
          echo "No file found matching $NAME"
        fi
    fi

    echo ""
done
