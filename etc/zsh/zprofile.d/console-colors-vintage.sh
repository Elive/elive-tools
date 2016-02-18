#!/bin/zsh

# Who works on console? only vintage people, so let's put for them a really vintage-looking colors feeling, it looks gorgeous! :)

if [ "$TERM" = "linux" ]; then
    #echo -en "\e]P0222222" #black
    echo -en "\e]P0121212" #black
    echo -en "\e]P84d4d4d" #darkgrey
    echo -en "\e]P1803232" #darkred
    echo -en "\e]P9982b2b" #red
    echo -en "\e]P25b762f" #darkgreen
    echo -en "\e]PA89b83f" #green
    echo -en "\e]P3aa9943" #brown
    echo -en "\e]PBefef60" #yellow
    echo -en "\e]P4324c80" #darkblue
    echo -en "\e]PC2b4f98" #blue
    echo -en "\e]P5706c9a" #darkmagenta
    echo -en "\e]PD826ab1" #magenta
    echo -en "\e]P692b19e" #darkcyan
    echo -en "\e]PEa1cdcd" #cyan
    echo -en "\e]P7b6bdaa" #lightgrey
    echo -en "\e]PFdedede" #white

    # Matrix style colors:
    #
    ##echo -en "\e]P789b83f" #white (dark cazador)
    ##echo -en "\e]P73CEC3C" #white main (lighter matrix)
    #echo -en "\e]P6bfffb2" #white hilighted (light almost white matrix)
    #echo -en "\e]P738D838" #white (matrix)
    #echo -en "\e]P698FF98" #white hilighted (matrix light)
    #echo -en "\e]PC10CDCD" #blue
    #echo -en "\e]P414FFFF" #darkblue
    #echo -en "\e]P3E6B032" #brown
    #echo -en "\e]PBFDDD39" #yellow
    #echo -en "\e]P1F30B34" #darkred
    #echo -en "\e]P9FF0E46" #red
    #echo -en "\e]P5B1429F" #darkmagenta
    #echo -en "\e]PDE456CD" #magenta
    #echo -en "\e]P22ED86B" #darkgreen
    #echo -en "\e]PA37FF7F" #green

    #clear #for background artifacting
fi


