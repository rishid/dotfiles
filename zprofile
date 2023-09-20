# run local .zprofile
if [ -f ~/.zprofile.local ]; then
    source ~/.zprofile.local
fi

# auto-run screen, but only once
# MUST be done after local .zprofile which usually include PATH munging.
# MUST be done last or the rest of the .zprofile script doesn't run until after screen terminates.
#if ps x | grep "SCREEN -S MainScreen" | grep -v grep &> /dev/null
#then
#    echo "Screen is already running."
#else
#    echo "Starting screen..."
#    if [ -z $SCREEN ]; then
#        SCREEN=screen
#    fi
#    $SCREEN -S MainScreen
#fi
