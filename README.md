elive-tools
===========

Set of handy and useful tools by Elive, for specially use in the Elive project

**UPDATE**: this repo has a big ton of amazing tools and features, but i have not the time to maintain the readme, sorry for that!

This is a brief summary of tools and features:

* audio-configurator  
It let's you to configure and use a specific alsa card (yes, really!)

* bkp  
One of the most AMAZING tools ever made, extremely handy. It saves "states" of your actual working directories, being able to recover them, to make a diff, or to visualize differences and merge them. It even creates a separated working dir if you want to run "make" or doing massive changes just for test. Yes, it's similar to git, but the main goals of this tool are:
  * idependent
  * fast
  * handy

* elivepaste  
A small tool for using pastebin and sending the link to the elive channels

* waitfor  
It waits on the shell for a process that terminates and exits, you can use it to do things like when you run `rebuild-packages` but forgot you need to rebuild the iso after, so you can do `waitfor rebuild-packages && rebuild-iso` which will wait for the rebuilding of the packages to complete before it rebuilds the ISO, similar to simply typing `rebuild-packages && rebuild-iso` but works without having to quit the rebuild-packages process; you can just run waitfor from another shell!

* user-manager  
The tool to create users in Elive, it is meant to include all the user-creation features

* el_
Typing el_ in your Elive shell will show you many commands that can power up your shell!

* make-cookies-with-chocolate  
A tool for making delicious cookies  
Well, I'm joking, of course, but you can add it :)

