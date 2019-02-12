#!/bin/zsh

# Who works on console? only vintage people, so let's put for them a really vintage-looking colors feeling, it looks gorgeous! :)
# update: this colorscheme don't looks  so nice, so let's use the same as we have for Elive, which looks more yummy!
#if [ "$TERM" = "linux" ]; then
    ##echo -en "\e]P0222222" #black
    #echo -en "\e]P0121212" #black
    #echo -en "\e]P84d4d4d" #darkgrey
    #echo -en "\e]P1803232" #darkred
    #echo -en "\e]P9982b2b" #red
    #echo -en "\e]P25b762f" #darkgreen
    #echo -en "\e]PA89b83f" #green
    #echo -en "\e]P3aa9943" #brown
    #echo -en "\e]PBefef60" #yellow
    #echo -en "\e]P4324c80" #darkblue
    #echo -en "\e]PC2b4f98" #blue
    #echo -en "\e]P5706c9a" #darkmagenta
    #echo -en "\e]PD826ab1" #magenta
    #echo -en "\e]P692b19e" #darkcyan
    #echo -en "\e]PEa1cdcd" #cyan
    #echo -en "\e]P7b6bdaa" #lightgrey
    #echo -en "\e]PFdedede" #white
    ##clear #for background artifacting
#fi

# colorscheme based in Elive terminal colorschemes (similar to molokai/monokai)
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0000000" # black
    echo -en "\e]P1e50000" # red
    echo -en "\e]P287cc00" # green
    echo -en "\e]P3fc8700" # brown
    echo -en "\e]P46720ff" # blue
    echo -en "\e]P5fa00cc" # magenta
    echo -en "\e]P600c8fc" # cyan
    echo -en "\e]P7d8d8d8" # white
    # -----------------------------
    echo -en "\e]P88a8a8a" # light black
    echo -en "\e]P9ff4040" # light red
    echo -en "\e]PAc2fc4c" # light green
    echo -en "\e]PBffc342" # light brown
    echo -en "\e]PC9e71ff" # light blue
    echo -en "\e]PDff58e0" # light magenta
    echo -en "\e]PEa1efff" # light cyan
    echo -en "\e]PFffffff" # light white

    #clear #for background artifacting
fi


# dynamically use the same colorschemes that we have for our X terminals
if [ "$TERM" = "linux" ]; then
    _SEDCMD='s/^[^\!].*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
    for i in $(sed -n "$_SEDCMD" "$HOME/.Xdefaults" 2>/dev/null | awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
        echo -en "$i"
    done
    #clear
fi
