#!/bin/bash

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
    echo -en "\e]P0000000" #black
    echo -en "\e]P8e50000" #darkgrey
    echo -en "\e]P187cc00" #darkred
    echo -en "\e]P9fc8700" #red
    echo -en "\e]P26720ff" #darkgreen
    echo -en "\e]PAfa00cc" #green
    echo -en "\e]P300c8fc" #brown
    echo -en "\e]PBd8d8d8" #yellow
    echo -en "\e]P48a8a8a" #darkblue
    echo -en "\e]PCff4040" #blue
    echo -en "\e]P5c2fc4c" #darkmagenta
    echo -en "\e]PDffc342" #magenta
    echo -en "\e]P69e71ff" #darkcyan
    echo -en "\e]PEff58e0" #cyan
    echo -en "\e]P7a1efff" #lightgrey
    echo -en "\e]PFffffff" #white
    #clear #for background artifacting
fi
