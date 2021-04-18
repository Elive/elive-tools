elive-tools
===========

Set of handy and useful tools by Elive, for specially use in the Elive project

**UPDATE**: this repo has a big ton of amazing tools and features, but i have not the time to maintain the readme, sorry for that! If you would like this README to be expanded, please send a pull request :) 

This is a brief summary of tools and features:

<details><summary>audio-configurator</summary>

It let's you to configure and use a specific alsa card (yes, really!)

</details>
<details>
<summary>bkp</summary>

One of the most AMAZING tools ever made, extremely handy. It saves "states" of your actual working directories, being able to recover them, to make a diff, or to visualize differences and merge them. It even creates a separated working dir if you want to run "make" or doing massive changes just for test. Yes, it's similar to git, but the main goals of this tool are:
  * idependent
  * fast
  * handy

TODO for Thanatermesis : Here add the full documentation for bkp!

</details>
<details>
<summary>elivepaste</summary>

elivepaste
A small tool for using pastebin and sending the link to the elive channels

Run elivepaste on a text file; it will be uploaded to a service similar to pastebin, and will give you the link.

</details>

<details><summary>waitfor</summary>

Let's say you have a workflow where normally you would run `rebuild-packages && rebuild-iso`. Oh no - you accidentally forgot the `&& rebuild-iso`, and you don't want to kill the process since then it'd have to restart! waitfor is designed for this use-case. It blocks the shell until a process you specify exits! You use it like so: `waitfor <process_to_wait_for> && <second_command>`

</details>

<details><summary>user-manager</summary>

The tool to create users in Elive, it is meant to include all the user-creation features. Simply run the command and voilà!

</details>

<details><summary>el_ commands</summary>

In your terminal, enter `el_` and press TAB. You now have a list of commands that can **power up your shell, especially your scripts**! Elive uses them for most of its shell scripts. It can be very helpful.

</details>

<details><summary>make-cookies-with-chocolate</summary>

A tool for making delicious cookies, using a protocol similar to [HTCPCP](https://en.wikipedia.org/wiki/Hyper_Text_Coffee_Pot_Control_Protocol)

Well, I'm joking, of course, but you can add it :)

</details>
