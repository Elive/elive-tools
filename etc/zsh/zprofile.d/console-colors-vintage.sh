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
    echo -en "\e]P0010101" # black
    echo -en "\e]P1e50000" # red
    echo -en "\e]P287cc00" # green
    echo -en "\e]P3fc8700" # brown
    echo -en "\e]P46720ff" # blue
    echo -en "\e]P5fa00cc" # magenta
    echo -en "\e]P600c8fc" # cyan
    echo -en "\e]P7c8c8c8" # white
    # -----------------------------
    echo -en "\e]P8808080" # light black
    echo -en "\e]P9cc8888" # light red
    echo -en "\e]PA88cc88" # light green
    echo -en "\e]PBccaa88" # light brown
    echo -en "\e]PC8888cc" # light blue
    echo -en "\e]PDcc88cc" # light magenta
    echo -en "\e]PE88cccc" # light cyan
    echo -en "\e]PFcccccc" # light white

    #clear #for background artifacting
fi


