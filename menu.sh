#!/bin/bash
#
# ©2020 Copyright 2020 Robert D. Chin
#
# Usage: bash menu.sh
#        (not sh menu.sh)
#
# +----------------------------------------+
# |        Default Variable Values         |
# +----------------------------------------+
#
VERSION="2020-06-22 14:43"
THIS_FILE="menu.sh"
TEMP_FILE="$THIS_FILE_temp.txt"
GENERATED_FILE="$THIS_FILE_menu_generated.lib"
#
# +----------------------------------------+
# |            Brief Description           |
# +----------------------------------------+
#
#@ Brief Description
#@
#@ This script will generate either a text menu, or "Dialog" or "Whiptail"
#@ GUI menu from an array using data in clear text in scripts:
#@ menu_module_main.lib, menu_module_sub1.lib
#@ or any other menu_modules... you wish to add. 
#@
#@ Required scripts: menu.sh, menu_module_main.lib,
#@                   menu_module_sub0.lib, menu_module_sub1.lib
#@
#@ Usage: bash menu.sh
#@        (not sh menu.sh)
#
# +----------------------------------------+
# |             Help and Usage             |
# +----------------------------------------+
#
#?    Usage: bash menu.sh [OPTION]
#? Examples:
#?
#?bash menu.sh text       # Use Cmd-line user-interface (80x24 min.).
#?             dialog     # Use Dialog   user-interface.
#?             whiptail   # Use Whiptail user-interface.
#?
#?bash menu.sh --help     # Displays this help message.
#?             -?
#?
#?bash menu.sh --about    # Displays script version.
#?             --version
#?             --ver
#?             -v
#?
#?bash menu.sh --history  # Displays script code history.
#?             --hist
#
# +----------------------------------------+
# |           Code Change History          |
# +----------------------------------------+
#
## Code Change History
##
## (After each edit made, please update Code History and VERSION.)
##
## 2020-06-22 *Updated to latest standards.
##
## 2020-05-14 *f_yn_question fixed bug where temp file was undefined.
##            *msg_ui_str_nok, f_msg_txt_str_nok changed wait time
##             from 5 to 3 seconds.
##            *f_exit_script to latest standard; clean-up temp files on exit.
##            *f_message, f_msg_ui_file_box_size, f_msg_ui_str_box_size,
##             f_ui_file_ok/nok, f_ui_str_ok/nok f_yn_question/defaults
##             specified parameter passing.
##            *f_menu_arrays, f_update_menu_txt/gui bug fixed to not unset
##             TEMP_FILE variable since it is used globally.
##
## 2020-05-06 *f_msg_ui_file_box_size, f_msg_ui_file_ok bug fixed in display.
##
## 2020-05-04 *f_update_menu_gui adjusted menu display parameters for Whiptail.
##
## 2020-04-22 *f_message split into several functions for clarity and
##             simplicity f_msg_(txt/ui)_(file/string)_(ok/nok).
##            *f_yn_question split off f_yn_defaults.
##
## 2020-04-19 *Found bug in VERSION setting in f_about, f_code_history,
##             f_help_message. Need to set $VERSION using correct $THIS_FILE.
##
## 2020-04-18 *Updated scripts for bug fixes and enhancements.
##
## 2020-03-25 *f_arguments added to support double-dash [OPTIONS] after
##             invoking the script. i.e. $ bash menu.sh --help
##                                       $ bash menu.sh text
##            *f_code_history, f_help_message, f_about bug fixes.
##            *menu_module_main.lib added "Help" menu option.
##
## 2020-03-22 *Main explicitly invoked menu_module_main.lib with full
##             pathname (in case there are multiple copies in different
##             file folders).
##            *f_update_menu_txt, f_update_menu_gui automatically updated
##              copyright notice in generated file, menu_generated.lib.
##            *f_create_show_menu and various functions in menu_module
##             libraries, use clear command to blank screen so Dialog and
##             Whiptail look better when transitioning from text UI.
##
## 2019-01-23 *f_update_menu_gui adjusted menu so menu height was maximized.
##            *f_about_txt added display of Brief Description.
##
## 2019-01-19 *Bug fix in return to previous menu.
##            *Clean up code and comments.
##
## 2018-01-18 *Cosmetic improvements to automatically fit the Dialog or 
##             Whiptail frame size to the amount of text.
##            *Optimized the generation of menus.
##
## 2018-01-17 *Initial release.
#
# +----------------------------------------+
# |         Function f_script_path         |
# +----------------------------------------+
#
#     Rev: 2020-04-20
#  Inputs: $BASH_SOURCE (System variable).
#    Uses: None.
# Outputs: SCRIPT_PATH, THIS_DIR.
#
f_script_path () {
      #
      # BASH_SOURCE[0] gives the filename of the script.
      # dirname "{$BASH_SOURCE[0]}" gives the directory of the script
      # Execute commands: cd <script directory> and then pwd
      # to get the directory of the script.
      # NOTE: This code does not work with symlinks in directory path.
      #
      # !!!Non-BASH environments will give error message about line below!!!
      SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
      THIS_DIR=$SCRIPT_PATH  # Set $THIS_DIR to location of this script.
      #
} # End of function f_script_path.
#
# +----------------------------------------+
# |         Function f_arguments           |
# +----------------------------------------+
#
#     Rev: 2020-06-21
#  Inputs: $1=Argument
#             [--help] [ -h ] [ -? ]
#             [--about]
#             [--version] [ -ver ] [ -v ] [--about ]
#             [--history] [--hist ]
#             [] [ text ] [ dialog ] [ whiptail ]
#    Uses: None.
# Outputs: GUI, ERROR.
#
f_arguments () {
      #
      # If there is more than two arguments, display help USAGE message, because only one argument is allowed.
      if [ $# -ge 3 ] ; then
         f_help_message text
         #
         clear # Blank the screen.
         #
         exit 0  # This cleanly closes the process generated by #!bin/bash. 
                 # Otherwise every time this script is run, another instance of
                 # process /bin/bash is created using up resources.
      fi
      #
      case $2 in
           "text" | "dialog" | "whiptail")
           GUI=$2
           ;;
      esac
      #
      case $1 in
           --help | "-?")
              # If the one argument is "--help" display help USAGE message.
              if [ -z $GUI ] ; then
                 f_help_message text
              else
                 f_help_message $GUI
              fi
              #
              clear # Blank the screen.
              #
              exit 0  # This cleanly closes the process generated by #!bin/bash. 
                      # Otherwise every time this script is run, another instance of
                      # process /bin/bash is created using up resources.
           ;;
           --about | --version | --ver | -v)
              if [ -z $GUI ] ; then
                 f_about text
              else
                 f_about $GUI
              fi
              #
              clear # Blank the screen.
              #
              exit 0  # This cleanly closes the process generated by #!bin/bash. 
                      # Otherwise every time this script is run, another instance of
                      # process /bin/bash is created using up resources.
           ;;
           --history | --hist)
              if [ -z $GUI ] ; then
                 f_code_history text
              else
                 f_code_history $GUI
              fi
              #
              clear # Blank the screen.
              #
              exit 0  # This cleanly closes the process generated by #!bin/bash. 
                      # Otherwise every time this script is run, another instance of
                      # process /bin/bash is created using up resources.
           ;;
           -*)
              # If the one argument is "-<unrecognized>" display help USAGE message.
              if [ -z $GUI ] ; then
                 f_help_message text
              else
                 f_help_message $GUI
              fi
              #
              clear # Blank the screen.
              #
              exit 0  # This cleanly closes the process generated by #!bin/bash. 
                      # Otherwise every time this script is run, another instance of
                      # process /bin/bash is created using up resources.
           ;;
           "text" | "dialog" | "whiptail")
              GUI=$1
           ;;
           "")
           # No action taken as null is a legitimate and valid argument.
           ;;
           *)
              # Check for 1st argument as a valid TARGET DIRECTORY.
              if [ -d $1 ] ; then
                 TARGET_DIR=$1
              else
                 # Display help USAGE message.
                 f_message "text" "OK" "Error Invalid Directory Name" "\Zb\Z1This directory does not exist:\Zn\n $1"
                 f_help_message "text"
                 exit 0  # This cleanly closes the process generated by #!bin/bash. 
                         # Otherwise every time this script is run, another instance of
                         # process /bin/bash is created using up resources.
              fi
           ;;
      esac
      #
}  # End of function f_arguments.
#
# +----------------------------------------+
# |          Function f_detect_ui          |
# +----------------------------------------+
#
#     Rev: 2020-04-20
#  Inputs: None.
#    Uses: ERROR.
# Outputs: GUI (dialog, whiptail, text).
#
f_detect_ui () {
      #
      command -v dialog >/dev/null
      # "&>/dev/null" does not work in Debian distro.
      # 1=standard messages, 2=error messages, &=both.
      ERROR=$?
      # Is Dialog GUI installed?
      if [ $ERROR -eq 0 ] ; then
         # Yes, Dialog installed.
         GUI="dialog"
      else
         # Is Whiptail GUI installed?
         command -v whiptail >/dev/null
         # "&>/dev/null" does not work in Debian distro.
         # 1=standard messages, 2=error messages, &=both.
         ERROR=$?
         if [ $ERROR -eq 0 ] ; then
            # Yes, Whiptail installed.
            GUI="whiptail"
         else
            # No CLI GUIs installed
            GUI="text"
         fi
      fi
      #
} # End of function f_detect_ui.
#
# +----------------------------------------+
# |      Function f_test_environment       |
# +----------------------------------------+
#
#     Rev: 2020-05-01
#  Inputs: $1=GUI.
#          $BASH_VERSION (System variable).
#    Uses: None.
# Outputs: None.
#
f_test_environment () {
      #
      # What shell is used? DASH or BASH?
      f_test_dash $1
      #
      # Test for X-Windows environment. Cannot run in CLI for LibreOffice.
      #if [ x$DISPLAY = x ] ; then
      #   f_message $1 "OK" "Cannot run LibreOffice" "Cannot run LibreOffice without an X-Windows environment.\ni.e. LibreOffice must run in a terminal emulator in an X-Window."
      #   f_abort $1
      #fi
      #
} # End of function f_test_environment.
#
# +----------------------------------------+
# |          Function f_test_dash          |
# +----------------------------------------+
#
#     Rev: 2020-06-22
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          $BASH_VERSION (System variable), GUI.
#    Uses: None.
# Outputs: exit 1.
#
# Test the environment. Are you in the BASH environment?
# Some scripts will have errors in the DASH environment that is the
# default command-line interface shell in Ubuntu.
#
f_test_dash () {
      #
      # $BASH_VERSION is null if you are not in the BASH environment.
      # Typing "sh" at the CLI may invoke a different shell other than BASH.
      # if [ -z "$BASH_VERSION" ]; then
      # if [ "$BASH_VERSION" = '' ]; then
      #
      if [ -z "$BASH_VERSION" ]; then 
         # DASH Environment detected, display error message 
         # to invoke the BASH environment.
         f_detect_ui # Automatically detect UI environment.
         #
         TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
         #
         clear  # Blank the screen.
         #
         f_message $1 "OK" ">>> Warning: Must use BASH <<<" "\n                   You are using the DASH environment.\n\n        *** This script cannot be run in the DASH environment. ***\n\n    Ubuntu and Linux Mint default to DASH but also have BASH available."
         f_message $1 "OK" "HOW-TO" "\n  You can invoke the BASH environment by typing:\n    \"bash $THIS_FILE\"\nat the command line prompt (without the quotation marks).\n\n          >>> Now exiting script <<<"
         #
         f_abort $1
      fi
      #
} # End of function f_test_dash
#
# +----------------------------------------+
# | Function f_press_enter_key_to_continue |
# +----------------------------------------+
#
#     Rev: 2020-04-20
#  Inputs: None.
#    Uses: X.
# Outputs: None.
#
f_press_enter_key_to_continue () { # Display message and wait for user input.
      #
      echo
      echo -n "Press '"Enter"' key to continue."
      read X
      unset X  # Throw out this variable.
      #
} # End of function f_press_enter_key_to_continue.
#
# +----------------------------------------+
# |         Function f_exit_script         |
# +----------------------------------------+
#
#     Rev: 2020-05-28
#  Inputs: $1=GUI.
#    Uses: None.
# Outputs: None.
#
f_exit_script() {
      #
      f_message $1 "NOK" "End of script" " \nExiting script." 1
      #
      # Blank the screen. Nicer ending especially if you chose custom colors for this script.
      clear 
      #
      if [ -r  $TEMP_FILE ] ; then
         rm  $TEMP_FILE
      fi
      #
      exit 0
} # End of function f_exit_script
#
# +----------------------------------------+
# |              Function f_abort          |
# +----------------------------------------+
#
#     Rev: 2020-05-28
#  Inputs: $1=GUI.
#    Uses: None.
# Outputs: None.
#
f_abort () {
      #
      # Temporary file has \Z commands embedded for red bold font.
      #
      # \Z commands are used by Dialog to change font attributes 
      # such as color, bold/normal.
      #
      # A single string is used with echo -e \Z1\Zb\Zn commands
      # and output as a single line of string wit \Zn commands embedded.
      #
      # Single string is neccessary because \Z commands will not be
      # recognized in a temp file containing <CR><LF> multiple lines also.
      #
      f_message $1 "NOK" "Exiting script" " \Z1\ZbAn error occurred, cannot continue. Exiting script.\Zn"
      exit 1
      #
      if [ -r  $TEMP_FILE ] ; then
         rm  $TEMP_FILE
      fi
      #
} # End of function f_abort.
#
# +------------------------------------+
# |          Function f_about          |
# +------------------------------------+
#
#     Rev: 2020-05-28
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: X.
# Outputs: None.
#
f_about () {
      #
      # Specify $THIS_FILE name of any file containing the text to be displayed.
      THIS_FILE="menu.sh"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      # Set $VERSION according as it is set in the beginning of $THIS_FILE.
      X=$(grep --max-count=1 "VERSION" $THIS_FILE)
      # X="VERSION=YYYY-MM-DD HH:MM"
      # Use command "eval" to set $VERSION.
      eval $X
      #
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning ("^") with "#& " but do not print "#& ").
      # sed substitutes null for "#& " at the beginning of each line
      # so it is not printed.
      DELIM="^#&"
      sed -n "s/$DELIM//"p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "About (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of f_about.
#
# +------------------------------------+
# |      Function f_code_history       |
# +------------------------------------+
#
#     Rev: 2020-05-24
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: X.
# Outputs: None.
#
f_code_history () {
      #
      # Specify $THIS_FILE name of any file containing the text to be displayed.
      THIS_FILE="menu.sh"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      # Set $VERSION according as it is set in the beginning of $THIS_FILE.
      X=$(grep --max-count=1 "VERSION" $THIS_FILE)
      # X="VERSION=YYYY-MM-DD HH:MM"
      # Use command "eval" to set $VERSION.
      eval $X
      #
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning ("^") with "##" but do not print "##").
      # sed substitutes null for "##" at the beginning of each line
      # so it is not printed.
      DELIM="^##"
      sed -n "s/$DELIM//"p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "Code History (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of function f_code_history.
#
# +------------------------------------+
# |      Function f_help_message       |
# +------------------------------------+
#
#     Rev: 2020-05-24
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          THIS_DIR, THIS_FILE, VERSION.
#    Uses: X.
# Outputs: None.
#
f_help_message () {
      #
      # Specify $THIS_FILE name of any file containing the text to be displayed.
      THIS_FILE="menu.sh"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      # Set $VERSION according as it is set in the beginning of $THIS_FILE.
      X=$(grep --max-count=1 "VERSION" $THIS_FILE)
      # X="VERSION=YYYY-MM-DD HH:MM"
      # Use command "eval" to set $VERSION.
      eval $X
      #
      echo "Script: $THIS_FILE. Version: $VERSION" >$TEMP_FILE
      echo >>$TEMP_FILE
      #
      # Display text (all lines beginning ("^") with "#?" but do not print "#?").
      # sed substitutes null for "#?" at the beginning of each line
      # so it is not printed.
      DELIM="^#?"
      sed -n "s/$DELIM//"p $THIS_DIR/$THIS_FILE >> $TEMP_FILE
      #
      f_message $1 "OK" "Usage (use arrow keys to scroll up/down/side-ways)" $TEMP_FILE
      #
} # End of f_help_message.
#
# +----------------------------------------+
# |          Function f_yn_question        |
# +----------------------------------------+
#
#     Rev: 2020-05-24
#  Inputs: $1=GUI - "text", "dialog" or "whiptail" the preferred user-interface.
#          $2 - "Y" or "N" - the default answer.
#          $3 - Title string (may be null).
#          $4 - Question text string.
#    Uses: None.
# Outputs: ANS=0 is "Yes".
#          ANS=1 is "No".
#          ANS=255 if <Esc> is pressed in dialog/whiptail --yesno box.
# Example: f_yn_question $GUI "Y" "Title Goes Here" "I am hungry.\nAre you hungry?"
#          f_yn_question "dialog" "Y" "Title Goes Here" hungry.txt
#
# This will display a title and a question using dialog/whiptail/text.
# It will automatically calculate the optimum size of the displayed
# Dialog or Whiptail box depending on screen resolution, number of lines
# of text, and length of sentences to be displayed. 
#
# It is a lengthy function, but using it allows for an easy way to display 
# a yes/no question using either Dialog, Whiptail or text.
#
# You do not have to worry about the differences in syntax between Dialog
# and Whiptail, handling the answer, or about calculating the box size for
# each text message.
#
f_yn_question () {
      #
      # Ask Yes/No question.
      #
      # Set Temporary file name.
      #THIS_FILE="example_library.lib"
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      # Get the screen resolution or X-window size.
      # Get rows (height).
      YSCREEN=$(stty size | awk '{ print $1 }')
      # Get columns (width).
      XSCREEN=$(stty size | awk '{ print $2 }')
      #
      case $1 in
           dialog | whiptail)
           # Calculate dialog/whiptail box dimensions $YBOX, $XBOX.
           f_msg_ui_str_box_size $1 $2 "$3" "$4"
      esac
      #
      case $1 in
           dialog)
              # Dialog needs about 5 more lines for the header and [OK] button.
              let Y=$YBOX+5
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Dialog needs about 10 more spaces for the right and left window frame. 
              let X=$XBOX+10
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
           ;;
           whiptail)
              # Whiptail only has options --textbox or--msgbox (not --infobox).
              # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
              # Filter out any "\Z" commands when using the same string for both Dialog and Whiptail.
              # Use command "sed" with "-e" to filter out multiple "\Z" commands.
              # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
              ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
              #
              # Whiptail needs about 6 more lines for the header and [OK] button.
              let Y=$YBOX+6
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Whiptail needs about 6 more spaces for the right and left window frame. 
              let X=$XBOX+6
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
           ;;
      esac
      #
      case $1 in
           dialog | whiptail)
              # Default answer.
              f_yn_defaults $1 $2 "$3" "$4" $Y $X
           ;;
           text)
              #
              clear  # Blank screen.
              #
              # Does $4 contain "\n"?  Does the string $4 contain multiple sentences?
              case $4 in
                   *\n*)
                      # Yes, string $4 contains multiple sentences.
                      #
                      # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                      # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                      ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
                      #
                      # Create a text file from the string.
                      echo -e $ZNO > $TEMP_FILE
                   ;;
                   *)
                      # No, string $4 contains a single sentence. 
                      #
                      # Create a text file from the string.
                      echo $4 > $TEMP_FILE
                   ;;
              esac
              #
              # Calculate number of lines or Menu Choices to find maximum menu lines for Dialog or Whiptail.
              Y=$(wc --lines < $TEMP_FILE)
              #
              # Display Title and Question.
              echo $3
              echo
              NSEN=1
              while read XSTR
                    do
                       if [ $NSEN -lt $Y ] ; then
                          echo $XSTR
                       fi
                       let NSEN=NSEN+1
                    done < $TEMP_FILE
                    #
              XSTR=$(tail -n 1 $TEMP_FILE)
              #
              # Default answer.
              f_yn_defaults $1 $2 "$3" "$4"
           ;;
      esac
      #
} # End of function f_yn_question
#
# +------------------------------+
# |    Function f_yn_defaults    |
# +------------------------------+
#
#     Rev: 2020-05-14
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file.
#          $5 - Box Height in characters.
#          $6 - Box Width  in characters.
#    Uses: None.
# Outputs: ANS. 
# Example:
#         whiptail --yesno text height width
#                  --defaultno
#                  --yes-button text
#                  --no-button text
#                  --backtitle backtitle
#                  --title title
#
#         dialog --yesno text height width
#                --defaultno
#                --yes-label string
#                --default-button string
#                --backtitle backtitle
#                --title title
#
f_yn_defaults () {
      #
      case $1 in
           dialog | whiptail)
              case $2 in
                   [Yy] | [Yy][Ee][Ss])
                      # "Yes" is the default answer.
                      $1 --title "$3" --yesno "$4" $5 $6
                      ANS=$?
                   ;;
                   [Nn] | [Nn][Oo])
                      # "No" is the default answer.
                      $1 --title "$3" --defaultno --yesno "$4" $5 $6
                      ANS=$?
                   ;;
              esac
           #
           ;;
           text)
              case $2 in
                   [Yy] | [Yy][Ee][Ss])
                      # "Yes" is the default answer.
                      echo -n "$XSTR (Y/n) "; read ANS
                      #
                      case $ANS in
                           [Nn] | [Nn][Oo])
                              ANS=1  # No.
                           ;;
                           *)
                              ANS=0  # Yes (Default).
                           ;;
                      esac
                   ;;
                   [Nn] | [Nn][Oo])
                      # "No" is the default answer.
                      echo -n "$XSTR (y/N) "; read ANS
                      case $ANS in
                           [Yy] | [Yy][Ee] | [Yy][Ee][Ss])
                              ANS=0  # Yes.
                           ;;
                           *)
                              ANS=1  # No (Default).
                           ;;
                      esac
                   ;;
              esac
           ;;
      esac
      #
} # End of function f_yn_defaults
#
# +------------------------------+
# |       Function f_message     |
# +------------------------------+
#
#     Rev: 2020-06-03
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#          $5 - (Optional for functions f_msg_ui/txt_str_nok) Pause for $5 seconds to allow text to be read.
#    Uses: None.
# Outputs: ERROR.
#   Usage: 1. f_message $GUI "OK" "Test of String in quotes" "This is a test of \Z6cyan software BASH script.\Zn\nI hope it works!"
#
#          2. In this example, the quotation marks around the "$STRING" variable name are required.
#             STRING=$(echo "\"Roses are \Z1\ZbRED\Zn, Violets are \Z4BLUE\Zn, what say you?\"")
#             f_message $GUI "OK" "Test of String in a variable" "$STRING" <---!!Note required quotation marks around variable name!!
#
#          3. echo "Line 1 of text file" >$TEMP_FILE
#             echo "Line 2 of text file" >>$TEMP_FILE
#             echo "Line 3 of text file" >>$TEMP_FILE
#             f_message $GUI "OK" "Test of Text file" $TEMP_FILE
#
# This will display a title and some text using dialog/whiptail/text.
# It will automatically calculate the optimum size of the displayed
# Dialog or Whiptail box depending on screen resolution, number of lines
# of text, and length of sentences to be displayed. 
#
# It is a lengthy function, but using it allows for an easy way to display 
# some text (in a string or text file) using either Dialog, Whiptail or text.
#
# You do not have to worry about the differences in syntax between Dialog
# and Whiptail or about calculating the box size for each text message.
#
f_message () {
      #
      case $1 in
           "dialog" | "whiptail")
              # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
              # Dialog box "--textbox" and Whiptail cannot use option --colors with "\Z" commands for font color bold/normal.
              #
              # If text strings have Dialog "\Z" commands for font color bold/normal, 
              # they must be used AFTER \n (line break) commands.
              # Example: "This is a test.\n\Z1\ZbThis is in bold-red letters.\n\ZnThis is in normal font."
              #
              # Get the screen resolution or X-window size.
              # Get rows (height).
              YSCREEN=$(stty size | awk '{ print $1 }')
              # Get columns (width).
              XSCREEN=$(stty size | awk '{ print $2 }')
              #
              # Is $4 a text string or a text file?
              if [ -r "$4" ] ; then
                 #
                 # If $4 is a text file, then calculate number of lines and length
                 # of sentences to calculate height and width of Dialog box.
                 # Calculate dialog/whiptail box dimensions $YBOX, $XBOX.
                 f_msg_ui_file_box_size $1 $2 "$3" "$4"
                 #
                 if [ "$2" = "OK" ] ; then
                    # Display contents of text file with an [OK] button.
                    f_msg_ui_file_ok $1 $2 "$3" "$4" $YBOX $XBOX
                 else
                    # Display contents of text file with a pause for n seconds.
                    f_msg_ui_file_nok $1 $2 "$3" "$4" $YBOX $XBOX
                 fi
                 #
              else
                 # If $4 is a text string, then does it contain just one
                 # sentence or multiple sentences delimited by "\n"?
                 # Calculate the length of the longest of sentence.
                 # Calculate dialog/whiptail box dimensions $YBOX, $XBOX.
                 f_msg_ui_str_box_size $1 $2 "$3" "$4"
                 #
                 if [ "$2" = "OK" ] ; then
                    # Display contents of text string with an [OK] button.
                    f_msg_ui_str_ok $1 $2 "$3" "$4" $YBOX $XBOX
                 else
                    # Display contents of text string with a pause for n seconds.
                    f_msg_ui_str_nok $1 $2 "$3" "$4" $YBOX $XBOX "$5"
                 fi
              fi
              ;;
           *)
              #
              # Text only.
              # Is $4 a text string or a text file?
              #
              # Change font color according to Dialog "\Z" commands.
              # Replace font color "\Z" commands with "tput" commands.
              # Output result to string $ZNO.
              f_msg_color "$4"
              #
              if [ -r "$4" ] ; then
                 # If $4 is a text file.
                 #
                 if [ "$2" = "OK" ] ; then
                    # Display contents of text file using command "less" <q> to quit.
                    f_msg_txt_file_ok $1 $2 "$3" "$4"
                 else
                    f_msg_txt_file_nok $1 $2 "$3" "$4" "$5"
                    # Display contents of text file using command "cat" then pause for n seconds.
                 fi
                 #
              else
                 # If $4 is a text string.
                 #
                 if [ "$2" = "OK" ] ; then
                    # Display contents of text string using command "echo -e" then
                    # use f_press_enter_key_to_continue.
                    f_msg_txt_str_ok $1 $2 "$3" "$ZNO"
                 else
                    # Display contents of text string using command "echo -e" then pause for n seconds.
                    f_msg_txt_str_nok $1 $2 "$3" "$ZNO" "$5"
                 fi
              fi
              #
              # Restore default font color.
              echo -n $(tput sgr0)
              #
           ;;
      esac
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      #
} # End of function f_message.
#
# +-------------------------------+
# |      Function f_msg_color     |
# +-------------------------------+
#
#     Rev: 2020-06-04
#  Inputs: $1 - Text string or text file. 
#    Uses: None.
# Outputs: ZNO. 
#
f_msg_color () {
      #
      # 1. Does the text string or file have embedded Dialog "\Z" commands?
      # 2. If so, what color?
      # 3. Use corresponding "tput" command to set same color for the text.
      # 4. Remove or filter out embedded dialog "\Z" commands.
      # 5. Display (colored) text on screen.
      # 6. Reset text color when done.
      #
      # man dialog --colors
      # Interpret embedded "\Z" sequences in the Dialog text by the following
      # character, which tells Dialog to set colors or video attributes:
      # •   0 through 7 are the ANSI color numbers used in curses: black, red, green,
      #     yellow, blue, magenta, cyan and white respectively.
      # •   Bold is set by 'b', reset by 'B'.
      # •   Reverse is set by 'r', reset by 'R'.
      # •   Underline is set by 'u', reset by 'U'.
      # •   The settings are cumulative, e.g., "\Zb\Z1" makes the following text bold
      #     (perhaps bright) red.
      # •   Restore normal settings with "\Zn".
      #
      # BASH commands to change the color of characters in a terminal.
      # bold    "$(tput bold)"
      # black   "$(tput setaf 0)"
      # red     "$(tput setaf 1)"
      # green   "$(tput setaf 2)"
      # yellow  "$(tput setaf 3)"
      # blue    "$(tput setaf 4)"
      # magenta "$(tput setaf 5)"
      # cyan    "$(tput setaf 6)"
      # white   "$(tput setaf 7)"
      # reset   "$(tput sgr0)"
      #
      # Change font color according to Dialog "\Z" commands.
      # Then delete the Dialog "\Z" commands from the text string/file.
      #
      if [ -r "$1" ] ; then
         # If $1 is a text file.
         for COLOR in 0 1 2 3 4 5 6 7 8 9
             do
                # Search the text file for a Dialog "\Z" command.
                ZCMD=$(grep --max-count=1 \\Z$COLOR "$1")
                #
                # Change font color according to Dialog "\Z" command.
                if [ -n "$ZCMD" ] ; then
                   # Delete Dialog "\Z" commands.
                   # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                   # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                   sed -i -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g' $1
                   # Change font color using "tput" and "setaf" commands.
                   echo -n $(tput setaf $COLOR)
                fi
             done
      else
         # If $1 is a text string.
         for COLOR in 0 1 2 3 4 5 6 7 8 9
             do
                case "$1" in
                     *\Z0* | *\Z1* | *\Z2* | *\Z3* | *\Z4* | *\Z5* | *\Z6* | *\Z7* | *\Z8* | *\Z9*)
                        # Change font color using "tput" and "setaf" commands.
                        echo -n $(tput setaf $COLOR)
                        #
                        # Delete Dialog "\Z" commands.
                        # Use command "sed" with "-e" to filter out multiple "\Z" commands.
                        # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
                        ZNO=$(echo $1 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
                     ;;
                     *)
                        ZNO=$1
                esac
             done
         #
      fi
} # End of function f_msg_color.
#
# +-------------------------------+
# |Function f_msg_ui_file_box_size|
# +-------------------------------+
#
#     Rev: 2020-05-14
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#    Uses: None.
# Outputs: XBOX, YBOX.
#
f_msg_ui_file_box_size () {
      #
      # If $4 is a text file.
      # Calculate dialog/whiptail box dimensions $X, $Y.
      #
      # If text file, calculate number of lines and length of sentences.
      # to calculate height and width of Dialog box.
      #
      # Calculate longest line length in TEMP_FILE to find maximum menu width for Dialog or Whiptail.
      # The "Word Count" wc command output will not include the TEMP_FILE name
      # if you redirect "<$TEMP_FILE" into wc.
      XBOX=$(wc --max-line-length <$4)
      #
      # Calculate number of lines or Menu Choices to find maximum menu lines for Dialog or Whiptail.
      YBOX=$(wc --lines <$4)
      #
} # End of function f_msg_ui_file_box_size.
#
# +------------------------------+
# |   Function f_msg_ui_file_ok  |
# +------------------------------+
#
#     Rev: 2020-05-14
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#          $5 - Box Height in characters.
#          $6 - Box Width  in characters.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_ui_file_ok () {
      #
      # $4 is a text file.
      # If $2 is "OK" then use a Dialog/Whiptail textbox.
      #
      case $1 in
           dialog)
              # Dialog needs about 6 more lines for the header and [OK] button.
              let Y=$5+6
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Dialog needs about 10 more spaces for the right and left window frame. 
              let X=$6+10
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              # Dialog box "--textbox" and Whiptail cannot use "\Z" commands.
              # No --colors option for Dialog --textbox.
              dialog --title "$3" --textbox "$4" $Y $X
           ;;
           whiptail)
              # Whiptail needs about 7 more lines for the header and [OK] button.
              let Y=$5+7
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Whiptail needs about 5 more spaces for the right and left window frame. 
              let X=$6+5
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              whiptail --scrolltext --title "$3" --textbox "$4" $Y $X
           ;;
      esac
      #
} # End of function f_msg_ui_file_ok
#
# +------------------------------+
# |  Function f_msg_ui_file_nok  |
# +------------------------------+
#
#     Rev: 2020-06-03
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file.
#          $5 - Box Height in characters.
#          $6 - Box Width  in characters.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_ui_file_nok () {
      #
      # $4 is a text file.
      # If $2 is "NOK" then use a Dialog infobox or Whiptail textbox.
      case $1 in
           dialog)
              # Dialog needs about 6 more lines for the header and [OK] button.
              let Y=$5+6
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Dialog needs about 10 more spaces for the right and left window frame. 
              let X=$6+10
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
              dialog --colors --title "$3" --textbox "$4" $Y $X
           ;;
           whiptail)
              # Whiptail only has options --textbox or --msgbox (not --infobox).
              # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
              #
              # Whiptail needs about 7 more lines for the header and [OK] button.
              let Y=$5+7
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Whiptail needs about 5 more spaces for the right and left window frame. 
              let X=$6+5
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              whiptail --title "$3" --textbox "$4" $Y $X
           ;;
      esac
      #
} # End of function f_msg_ui_file_nok
#
# +------------------------------+
# |Function f_msg_ui_str_box_size|
# +------------------------------+
#
#     Rev: 2020-05-23
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#    Uses: None.
# Outputs: XBOX, YBOX, ZNO (string stripped of Dialog "\Z" commands).
#
f_msg_ui_str_box_size () {
      #
      # Calculate dialog/whiptail box dimensions $X, $Y.
      #
      # Does $4 string contain "\n"?  Does the string $4 contain multiple sentences?
      #
      # Debug hint: If the box has the minimum size regardless of length or width of text,
      #             the variable $TEMP_FILE may have been unset (i.e. unset TEMP_FILE).
      #             If the $TEMP_FILE is undefined, you will have a minimum box size.
      #
      case $4 in
           *\n*)
              # Yes, string $4 contains multiple sentences.
              #
              # Use command "sed" with "-e" to filter out multiple "\Z" commands.
              # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
              ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
              #
              # Calculate the length of the longest sentence with the $4 string.
              # How many sentences?
              # Replace "\n" with "%" and then use awk to count how many sentences.
              # Save number of sentences.
              YBOX=$(echo $ZNO | sed 's|\\n|%|g'| awk -F '%' '{print NF}')
              #
              # Output string without Dialog "\Z" commands into file $TEMP_FILE for wc processing.
              # The echo -e option replaces "\n" with actual <CR><LF> for wc to calculate actual longest line length.
              echo -e "$ZNO" > $TEMP_FILE
              #
              # More complex method to calculate longest sentence length,
              # without depending on "wc" but using "awk" instead.
              # Extract each sentence
              # Replace "\n" with "%" and then use awk to print current sentence.
              # This is the long way... echo $ZNO | sed 's|\\n|%|g'| awk -F "%" '{ for (i=1; i<NF+1; i=i+1) print $i }' >$TEMP_FILE
              #
              # Simpler method to calculate longest sentence length,
              # using "wc".
              # Calculate longest line length in TEMP_FILE
              # to find maximum menu width for Dialog or Whiptail.
              # The "Word Count" wc command output will not include
              # the TEMP_FILE name if you redirect "<$TEMP_FILE" into wc.
              XBOX=$(wc --max-line-length < $TEMP_FILE)
           ;;
           *)
              # Use command "sed" with "-e" to filter out multiple "\Z" commands.
              # Filter out "\Z[0-7]", "\Zb", \ZB", "\Zr", "\ZR", "\Zu", "\ZU", "\Zn".
              ZNO=$(echo $4 | sed -e 's|\\Z0||g' -e 's|\\Z1||g' -e 's|\\Z2||g' -e 's|\\Z3||g' -e 's|\\Z4||g' -e 's|\\Z5||g' -e 's|\\Z6||g' -e 's|\\Z7||g' -e 's|\\Zb||g' -e 's|\\ZB||g' -e 's|\\Zr||g' -e 's|\\ZR||g' -e 's|\\Zu||g' -e 's|\\ZU||g' -e 's|\\Zn||g')
              #
              # No, line length is $4 string length. 
              XBOX=$(echo -n "$ZNO" | wc -c)
              YBOX=1
           ;;
      esac
      #
} # End of function f_msg_ui_str_box_size
#
# +------------------------------+
# |   Function f_msg_ui_str_ok   |
# +------------------------------+
#
#     Rev: 2020-05-14
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#          $5 - Box Height in characters.
#          $6 - Box Width  in characters.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_ui_str_ok () {
      #
      # $4 is a text string.
      # If $2 is "OK" then use a Dialog/Whiptail msgbox.
      #
      # Calculate line length of $4 if it contains "\n" <new line> markers.
      # Find length of all sentences delimited by "\n"
      #
      case $1 in
           dialog)
              # Dialog needs about 5 more lines for the header and [OK] button.
              let Y=$5+5
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Dialog needs about 10 more spaces for the right and left window frame. 
              let X=$6+10
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
              dialog --colors --title "$3" --msgbox "$4" $Y $X
           ;;
           whiptail)
              # Whiptail only has options --textbox or--msgbox (not --infobox).
              # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
              #
              # Whiptail needs about 6 more lines for the header and [OK] button.
              let Y=$5+6
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Whiptail needs about 5 more spaces for the right and left window frame. 
              let X=$6+5
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              # Whiptail only has options --textbox or--msgbox (not --infobox in earlier versions).
              # f_msg_ui_str_box_size creates $ZNO which is the text string $4 but stripped of any Dialog "\Z" commands.
              whiptail --title "$3" --msgbox "$ZNO" $Y $X
           ;;
      esac
      #
} # End of function f_msg_ui_str_ok.
#
# +------------------------------+
# |   Function f_msg_ui_str_nok  |
# +------------------------------+
#
#     Rev: 2020-05-22
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#          $5 - Box Height in characters.
#          $6 - Box Width  in characters.
#          $7 - Pause for $7 seconds to allow text to be read.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_ui_str_nok () {
      #
      # $4 is a text string.
      # If $2 in "NOK" then use a Dialog infobox or Whiptail msgbox.
      #
      case $1 in
           dialog)
              # Dialog boxes "--msgbox" "--infobox" can use option --colors with "\Z" commands for font color bold/normal.
              # Dialog needs about 5 more lines for the header and [OK] button.
              let Y=$5+5
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Dialog needs about 10 more spaces for the right and left window frame. 
              let X=$6+6
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              dialog --colors --no-ok --title "$3" --infobox "$4" $Y $X
              #
              if [ -z $7 ] ; then
                 sleep 3
              else
                 sleep "$7"
              fi
           ;;
           whiptail)
              # Whiptail only has options --textbox or--msgbox (not --infobox).
              # Whiptail does not have option "--colors" with "\Z" commands for font color bold/normal.
              #
              # Whiptail needs about 6 more lines for the header and [OK] button.
              let Y=$5+6
              # If number of lines exceeds screen/window height then set textbox height.
              if [ $Y -ge $YSCREEN ] ; then
                 Y=$YSCREEN
              fi
              #
              # Whiptail needs about 5 more spaces for the right and left window frame. 
              let X=$6+5
              # If line length exceeds screen/window width then set textbox width.
              if [ $X -ge $XSCREEN ] ; then
                 X=$XSCREEN
              fi
              #
              # Whiptail only has options --textbox or--msgbox (not --infobox in earlier versions).
              # f_msg_ui_str_box_size creates $ZNO which is the text string $4 but stripped of any Dialog "\Z" commands.
              # Ideally we want to use whiptail --title "$3" --infobox "$ZNO" $Y $X
              whiptail --title "$3" --msgbox "$ZNO" $Y $X
           ;;
      esac
      #
} # End of function f_msg_ui_str_nok.
#
# +------------------------------+
# |  Function f_msg_txt_str_ok   |
# +------------------------------+
#
#     Rev: 2020-04-22
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_txt_str_ok () {
      #
      # If $2 is "OK" then use f_press_enter_key_to_continue.
      #
      clear  # Blank the screen.
      #
      # Display title.
      echo
      echo -e $3
      echo
      echo
      # Display text string contents.
      echo -e $4
      echo
      f_press_enter_key_to_continue
      #
      clear  # Blank the screen.
      #
} # End of function f_msg_txt_str_ok
#
# +------------------------------+
# |  Function f_msg_txt_str_nok  |
# +------------------------------+
#
#     Rev: 2020-05-22
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file.
#          $5 - Pause for $5 seconds to allow text to be read.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_txt_str_nok () {
      #
      # If $2 is "NOK" then use "echo" followed by "sleep" commands
      # to give time to read it.
      #
      clear  # Blank the screen.
      #
      # Display title.
      echo
      echo -e "$3"
      echo
      echo
      # Display text string contents.
      echo -e "$4"
      echo
      echo
      #
      if [ -z $5 ] ; then
         sleep 3
      else
         sleep "$5"
      fi
      #
      clear  # Blank the screen.
      #
} # End of function f_msg_txt_str_nok
#
# +------------------------------+
# |  Function f_msg_txt_file_ok  |
# +------------------------------+
#
#     Rev: 2020-04-22
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file. 
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_txt_file_ok () {
      #
      # If $2 is "OK" then use command "less".
      #
      clear  # Blank the screen.
      #
      # Display text file contents.
      less -P '%P\% (Spacebar, PgUp/PgDn, Up/Dn arrows, press q to quit)' $4
      #
      clear  # Blank the screen.
      #
} # End of function f_msg_txt_file_ok
#
# +------------------------------+
# |  Function f_msg_txt_file_nok |
# +------------------------------+
#
#     Rev: 2020-05-22
#  Inputs: $1 - "text", "dialog" or "whiptail" The CLI GUI application in use.
#          $2 - "OK"  [OK] button at end of text.
#               "NOK" No [OK] button or "Press Enter key to continue"
#               at end of text but pause n seconds
#               to allow reader to read text by using sleep n command.
#          $3 - Title.
#          $4 - Text string or text file.
#          $5 - Pause for $5 seconds to allow text to be read.
#    Uses: None.
# Outputs: ERROR. 
#
f_msg_txt_file_nok () {
      #
      # If $2 is "NOK" then use "cat" and "sleep" commands to give time to read it.
      #
      clear  # Blank the screen.
      # Display title.
      echo
      echo $3
      echo
      echo
      # Display text file contents.
      cat $4
      if [ -z $5 ] ; then
         sleep 3
      else
         sleep "$5"
      fi
      #
      #
      clear  # Blank the screen.
      #
} # End of function f_msg_txt_file_nok
#
# +----------------------------------------+
# |        Function f_menu_arrays          |
# +----------------------------------------+
#
#     Rev: 2020-05-18
#  Inputs: $1=file of menu choice strings.
#    Uses: ARRAY_NUM, ARRAY_NAME, ARRAY_VALUE, TEMP_FILE, XSTR.
# Outputs: MAX_CHOICE_LENGTH, MAX_SUMMARY_LENGTH, arrays CHOICE(n), SUMMARY(n), FUNC(n). 
#
f_menu_arrays () {
      #
      # Create arrays CHOICE, SUMMARY, FUNC to store menu option information.
      #
      # Example:
      # Menu option name is "Directory Listing"
      # Shared directory to be mounted is "//hansolo/public/contacts"
      # Local PC mount-point is "/mnt/hansolo/contacts"
      #
      #     CHOICE[1]="Directory Listing"
      #     SUMMARY[1]="get a listing of files in a directory."
      #     FUNC[1]="f_dir_listing"     # Function to do command "ls -l".
      #
      unset CHOICE SUMMARY FUNC  # Delete arrays in memory.
      ARRAY_NUM=1
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      #
      #                 Field-1 (null)  Field-2                      Field-3                     Field-4
      # Format of XSTR="<Delimiter> <Choice Title> <Delimiter> <Short Description> <Delimiter> <function>"
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      #
      DELIM="#@@"
      while read XSTR
            do
               case $XSTR in
                    $DELIM*)
                       echo $XSTR >>$TEMP_FILE
                    ;;
               esac
            done < $1  # Read lines from file $1.
      #
      # Calculate number of lines or Menu Choices to find maximum menu lines 
      # for Dialog or Whiptail.
      MAX_LINES=$(wc --lines <$TEMP_FILE)
      #
      MAX_CHOICE_LENGTH=0
      MAX_SUMMARY_LENGTH=0
      #
      while read XSTR
            do
               # Set array CHOICE[n] = <field-2> or "Choice Title" of XSTR.
               ARRAY_NAME="CHOICE"
               ARRAY_VALUE=$(echo $XSTR | awk -F "$DELIM" '{ if ( $3 ) { print $2 }}')
               ARRAY_VALUE=$(echo $ARRAY_VALUE | tr ' ' '_')
               eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
               #
               # Calculate length of next Menu Option Choice string.
               CHOICE_LENGTH=${#ARRAY_VALUE}
               # Save the value of the longest length of the Menu Option Choice.
               # This is for the text menu justification padding calculations.
               if [ $CHOICE_LENGTH -gt $MAX_CHOICE_LENGTH ] ; then
                  # Save new maximum string length.
                  MAX_CHOICE_LENGTH=$CHOICE_LENGTH
               fi
               #
               # Set array SUMMARY[n]=<field-3> or "Summary" of XSTR.
               ARRAY_NAME="SUMMARY"
               ARRAY_VALUE=$(echo $XSTR | awk -F "$DELIM" '{ if ( $3 ) { print $3 }}')
               ARRAY_VALUE=$(echo $ARRAY_VALUE | tr ' ' '_')
               eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
               #
               # Calculate length of next Menu Option Summary string.
               SUMMARY_LENGTH=${#ARRAY_VALUE}
               # Save the value of the longest length of the Menu Option Choice.
               # This is for the text menu justification padding calculations.
               if [ $SUMMARY_LENGTH -gt $MAX_SUMMARY_LENGTH ] ; then
                  # Save new maximum string length.
                  MAX_SUMMARY_LENGTH=$SUMMARY_LENGTH
               fi
               #
               # Set array $FUNC=<field-4> or "Function" of XSTR.
               ARRAY_NAME="FUNC"
               ARRAY_VALUE=$(echo $XSTR | awk -F "$DELIM" '{ if ( $3 ) { print $4 }}')
               ARRAY_VALUE=$(echo $ARRAY_VALUE | tr ' ' '_')
               eval $ARRAY_NAME[$ARRAY_NUM]=$ARRAY_VALUE
               #
               let ARRAY_NUM=$ARRAY_NUM+1
            done < $TEMP_FILE
      #
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      unset XSTR  # Throw out this variable.
      #
} # End of f_menu_arrays.
#
# +----------------------------------------+
# |        Function f_update_menu_txt      |
# +----------------------------------------+
#
#     Rev: 2020-06-03
#  Inputs: $1=GUI - "dialog" or "whiptail" The CLI GUI application in use.
#          $2=GENERATED_FILE.
#          $3=Menu Title.
#          $4=MAX_CHOICE_LENGTH.
#          $5=TEMP_FILE
#    Uses: X, Y, XNUM, YNUM, ARRAY_NAME, ARRAY_LEN, PAD, CHOICE.
# Outputs: None.
#
f_update_menu_txt () {
      #
      EXT=$(echo $2 | sed 's|\/|-|g')
      #
      echo "#!/bin/bash" >$2
      echo "#" >>$2
      grep --max-count=1 Copyright $THIS_FILE >>$2
      echo "#" >>$2
      echo "# +----------------------------------------+" >>$2
      echo "# |        Default Variable Values         |" >>$2
      echo "# +----------------------------------------+" >>$2
      echo "#" >>$2
      echo "VERSION=\"$VERSION\"" >>$2
      echo "#" >>$2
      echo "#***********************************CAUTION***********************************" >>$2
      echo "# Any edits made to this code will be lost since this code is" >>$2
      echo "# automatically generated and updated by running the script," >>$2
      echo "or library file which contains data for the menu." >>$2
      echo "#***********************************CAUTION***********************************" >>$2
      echo "#" >>$2
      echo "# *** Function f_menu_txt$EXT ***" >>$2
      echo "#" >>$2
      echo "#  Inputs: $1=GUI" >>$2
      echo "#    Uses: X, MENU_TITLE, ARRAY_NAME, ARRAY_LEN, CHOICE, SUMMARY, FUNC." >>$2
      echo "# Outputs: None." >>$2
      echo "#" >>$2
      echo "f_menu_txt$EXT () {" >>$2
      echo "      . $ARRAY_FILE   # invoke the necessary files." >>$2
      echo "      #" >>$2
      echo "      CHOICE=\"\"  # Initialize variable." >>$2
      echo "      until [ \"\$CHOICE\" = \"QUIT\" ]" >>$2
      echo "            do    # Start of menu until loop." >>$2
      echo "               clear  #Clear screen." >>$2
      MENU_TITLE=$(echo $3 | tr '_' ' ') # Do not >>$2 this line.
      echo "               MENU_TITLE=\"$MENU_TITLE\"" >>$2
      echo "               echo \"               \$MENU_TITLE\"; echo" >>$2
      #
      # Get display screen or window size to get maximum width.
      # Get the screen resolution or X-window size.
      # Get rows (height).
      Y=$(stty size | awk '{ print $1 }')
      # Get columns (width).
      X=$(stty size | awk '{ print $2 }')
      #
      # Read both CHOICE and SUMMARY arrays and format strings to display
      # in a pretty formatted menu.
      ARRAY_NAME="CHOICE"
      ARRAY_LEN=$(eval "echo \$\{#$ARRAY_NAME[@]\}")
      ARRAY_LEN=$(eval echo $ARRAY_LEN)
      TEMP_FILE=$5
      #
      for (( XNUM=1; XNUM<=${ARRAY_LEN}; XNUM++ ));
          do
             ARRAY_NAME="CHOICE"
             CHOICE=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
             CHOICE=$(eval echo $CHOICE)
             CHOICE=$(echo $CHOICE | tr '_' ' ')
             # CHOICE_LC is a lower-case CHOICE string for the purpose of easier pattern matching in a case statement.
             CHOICE_LC=$(echo $CHOICE | tr \'[:upper:]\' \'[:lower:]\')
             #
             ARRAY_NAME="SUMMARY"
             SUMMARY=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
             SUMMARY=$(eval echo $SUMMARY)
             SUMMARY=$(echo $SUMMARY | tr '_' ' ')
             #
             ARRAY_NAME="FUNC"
             FUNC=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
             FUNC=$(eval echo $FUNC)
             # Allow for the passing of arguments when calling the function.
             # Change from FUNC="f_function^arg1^arg2" change to FUNC="f_function arg1 arg2".
             FUNC=$(echo $FUNC | tr '^' ' ')
             #
             let YNUM=$XNUM-1  # Start numbering choices from zero so zero selects CHOICE[1]
             #
             # Save the pattern matching for the case statement which is later inserted into the function, "f_menu_txt".
             echo "                    $YNUM | \"${CHOICE_LC:0:1}\" | \"${CHOICE_LC:0:2}\" | \"${CHOICE_LC:0:3}\" | \"${CHOICE_LC:0:4}\" | \"${CHOICE_LC:0:5}\" | \"${CHOICE_LC:0:6}\" | \"${CHOICE_LC:0:7}\" | \"${CHOICE_LC:0:8}\" | \"${CHOICE_LC:0:9}\" | \"${CHOICE_LC:0:10}\" | \"${CHOICE_LC:0:11}\" | \"${CHOICE_LC:0:12}\" | \"${CHOICE_LC:0:13}\" | \"${CHOICE_LC:0:14}\" | \"${CHOICE_LC:0:15}\"*) $FUNC  ;;" >>$TEMP_FILE
             #
             if [ -n "$CHOICE" ] ; then
                # Read next Menu Option Choice string and get its string length.
                CHOICE_LENGTH=${#CHOICE}
                if [ $CHOICE_LENGTH -lt $4 ] ; then
                   let PAD=$4-$CHOICE_LENGTH
                   until [ $PAD -eq 0 ]
                         do
                            # Pad spaces to right (left-justify CHOICE).
                            # CHOICE     - Summary description.
                            CHOICE=$CHOICE" "
                            #
                            # Pad spaces to left (right-justify CHOICE).
                            #     CHOICE - Summary description.
                            #CHOICE=" "$CHOICE
                            #
                            let PAD=$PAD-1
                         done
                fi
                # Truncate "CHOICE - Summary description"
                # if longer than maximum window or screen width.
                #
                # Example: "$YNUM $CHOICE - $SUMMARY"
                # CHOICE="0 Quit - Quit to command-line prompt." where array CHOICE[1]="Quit"
                CHOICE="$YNUM $CHOICE - $SUMMARY"
                CHOICE_LENGTH=${#CHOICE}
                # Is the length of string CHOICE plus SUMMARY > Maximum window width?
                if [ $CHOICE_LENGTH -gt $X ] ; then
                   # Yes, truncate SUMMARY length to fit maximum window or screen width.
                   let X=$X-3
                   CHOICE=${CHOICE:0:$X}"..."
                fi
                # No, leave length alone, just print to screen.
                echo "               echo \"$CHOICE\"" >>$2
             fi
          done
      echo "               echo" >>$2
      echo "               echo -n \" Enter 0-$YNUM or letters (0): \" ; read CHOICE" >>$2
      echo "               #CHOICE Convert to lower-case." >>$2
      echo "               CHOICE=\$(echo \$CHOICE | tr \'[:upper:]\' \'[:lower:]\')" >>$2
      echo "               #" >>$2
      echo "               case \$CHOICE in" >>$2
      echo "                    \"\") CHOICE=\"QUIT\" ;;  # Set default choice pattern match." >>$2
      # Case pattern matching statements are read from TEMP_FILE to be included here.
      cat $TEMP_FILE >>$2
      echo "               esac" >>$2
      echo "           done" >>$2
      echo "       unset MENU_TITLE CHOICE  # Throw out this variable." >>$2
      echo "       #" >>$2
      echo "       } # End of function f_menu_txt." >>$2
      #
      # Remove $TEMP_FILE.
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      unset X Y XNUM YNUM MENU_TITLE ARRAY_NAME ARRAY_LEN CHOICE SUMMARY FUNC
      #
} # End of function f_update_menu_txt.
#
# +----------------------------------------+
# |        Function f_update_menu_gui      |
# +----------------------------------------+
#
#     Rev: 2020-06-03
#  Inputs: $1=GUI - "dialog" or "whiptail" The CLI GUI application in use.
#          $2=GENERATED_FILE.
#          $3=Menu Title.
#          $4=MAX_LENGTH
#          $5=MAX_LINES
#          $6=TEMP_FILE
#    Uses: GENERATED_FILE, ARRAY_NAME, ARRAY_LEN, XNUM.
# Outputs: None.
#
f_update_menu_gui () {
      #
      EXT=$(echo $2 | sed 's|\/|-|g')
      #
      echo "#!/bin/bash" >$2
      echo "#" >>$2
      grep --max-count=1 Copyright $THIS_FILE >>$2
      echo "#" >>$2
      echo "# +----------------------------------------+" >>$2
      echo "# |        Default Variable Values         |" >>$2
      echo "# +----------------------------------------+" >>$2
      echo "#" >>$2
      echo "VERSION=\"$VERSION\"" >>$2
      echo "#" >>$2
      echo "#***********************************CAUTION***********************************" >>$2
      echo "# Any edits made to this code will be lost since this code is" >>$2
      echo "# automatically generated and updated by running the script," >>$2
      echo "# or library file which contains data for the menu." >>$2
      echo "#***********************************CAUTION***********************************" >>$2
      echo "#" >>$2
      echo "# *** Function f_menu_txt$EXT ***" >>$2
      echo "#" >>$2
      echo "#  Inputs: \$1=GUI." >>$2
      echo "#          \$2=MENU_TITLE" >>$2
      echo "#    Uses: VERSION, THIS_FILE, CHOICE, SUMMARY, MENU_TITLE." >>$2
      echo "# Outputs: None." >>$2
      echo "#" >>$2
      echo "f_menu_gui$EXT () {" >>$2
      echo "      . $ARRAY_FILE   # invoke the necessary files." >>$2
      echo "      #" >>$2
      echo "      # CHOICE=\"\"  # Initialize variable." >>$2
      #
      # Get the screen resolution or X-window size.
      # Get rows (height).
      Y=$(stty size | awk '{ print $1 }')
      # Get columns (width).
      X=$(stty size | awk '{ print $2 }')
      #
      echo "      until [ \"\$CHOICE\" = \"QUIT\" ]" >>$2
      echo "            do    # Start of Menu until loop." >>$2
                           MENU_TITLE=$(echo $3 | tr '_' ' ')
      echo "               MENU_TITLE=\"$MENU_TITLE\"" >>$2
      #
      # Pad menu contents width and height to include the menu frame.
      let XBOX=$4+9
      let YBOX=$5+9
      #
      # If screen or window width is greater than MAX_LENGTH_UI (number of characters).
      # Then shrink menu display to fit number of characters.
      if [ $XBOX -le $X ] ; then
         let X=$XBOX
      fi
      #
      # Pad vertical menu box display for a minimum display area.
      if [ $YBOX -le $Y ] ; then
         let Y=$YBOX
      fi
      #
      # Menu height - actual height of menu options.
      let Z=$5
      #
      case $1 in
           dialog)
              if [ $3 = "Main_Menu" ] ; then    
                 echo "               CHOICE=\$(\$GUI --no-cancel --clear --title \"\$MENU_TITLE\" --menu \"\n\nUse (up/down arrow keys) or (letters):\" $Y $X $Z \\" >>$2
              else
                 echo "               CHOICE=\$(\$GUI --clear --title \"\$MENU_TITLE\" --menu \"\n\nUse (up/down arrow keys) or (letters):\" $Y $X $Z \\" >>$2
              fi
           ;;
           whiptail)
              if [ $3 = "Main_Menu" ] ; then    
                 echo "               CHOICE=\$(\$GUI --nocancel --clear --title \"\$MENU_TITLE\" --menu \"\n\nUse (up/down arrow keys) or (letters):\" $Y $X $Z \\" >>$2
              else
                 echo "               CHOICE=\$(\$GUI --clear --title \"\$MENU_TITLE\" --menu \"\n\nUse (up/down arrow keys) or (letters):\" $Y $X $Z \\" >>$2
              fi
           ;;
      esac
      #
      #TEMP_FILE=$THIS_DIR/$THIS_FILE"_temp.txt"
      TEMP_FILE=$6
      ARRAY_NAME="CHOICE"
      ARRAY_LEN=$(eval "echo \$\{#$ARRAY_NAME[@]\}")
      ARRAY_LEN=$(eval echo $ARRAY_LEN)
            for (( XNUM=1; XNUM<=${ARRAY_LEN}; XNUM++ ));
                do
                   ARRAY_NAME="CHOICE"
                   CHOICE=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
                   CHOICE=$(eval echo $CHOICE)
                   CHOICE=$(echo $CHOICE | tr '_' ' ')
                   #
                   ARRAY_NAME="SUMMARY"
                   SUMMARY=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
                   SUMMARY=$(eval echo $SUMMARY)
                   SUMMARY=$(echo $SUMMARY | tr '_' ' ')
                   #
                   ARRAY_NAME="FUNC"
                   FUNC=$(eval "echo \$\{$ARRAY_NAME[$XNUM]\}")
                   FUNC=$(eval echo $FUNC)
                   # Allow for the passing of arguments when calling the function.
                   # Change from FUNC="f_function^arg1^arg2" change to FUNC="f_function arg1 arg2".
                   FUNC=$(echo $FUNC | tr '^' ' ')
                   #
                   if [ -n "$CHOICE" ] ; then
                      echo "                     \"$CHOICE\" \"$SUMMARY\" \\" >>$2
                      echo "                    \"$CHOICE\") $FUNC  ;;" >>$TEMP_FILE
                   fi
                done
      echo "               2>&1 >/dev/tty)" >>$2
      echo "               case \$CHOICE in" >>$2
      # Case pattern matching statements are read from TEMP_FILE to be included here.
      cat $TEMP_FILE >>$2
      echo "               esac" >>$2
      echo "            done" >>$2
      echo "       unset MENU_TITLE CHOICE  # Throw out this variable." >>$2
      echo "       #" >>$2
      echo "       } # End of function f_menu_gui." >>$2
      #
      # Remove $TEMP_FILE.
      if [ -r $TEMP_FILE ] ; then
         rm $TEMP_FILE
      fi
      unset X Y XNUM ARRAY_NAME ARRAY_LEN CHOICE SUMMARY FUNC 
      #
} # End of function f_update_menu_gui.
#
# +----------------------------------------+
# |          Function f_menu_main          |
# +----------------------------------------+
#
#     Rev: 2020-06-04
#  Inputs: None.
#    Uses: ARRAY_FILE, GENERATED_FILE, MENU_TITLE.
# Outputs: None.
#
f_menu_main () { # Create and display the Main Menu.
      #
      #THIS_FILE="menu.sh"
      GENERATED_FILE=$THIS_DIR/$THIS_FILE"_menu_main_generated.lib"
      #
      # Does this file have menu items in the comment lines starting with "#@@"?
      grep --silent ^\#@@ $THIS_DIR/$THIS_FILE
      ERROR=$?
      # exit code 0 - menu items in this file.
      #           1 - no menu items in this file.
      #               file name of file containing menu items must be specified.
      if [ $ERROR -eq 0 ] ; then
         # Extract menu items from this file and insert them into the Generated file.
         # This is required because f_menu_arrays cannot read this file directly without
         # going into an infinite loop.
         grep ^\#@@ $THIS_DIR/$THIS_FILE >$GENERATED_FILE
         #
         # Specify file name with data.
         ARRAY_FILE="$GENERATED_FILE"
      else
         # Specify file name with data.
         ARRAY_FILE="menu_module_main.lib"
      fi
      #
      # Create arrays from data.
      f_menu_arrays $ARRAY_FILE
      #
      # Calculate longest line length to find maximum menu width
      # for Dialog or Whiptail using lengths calculated by f_menu_arrays.
      let MAX_LENGTH=$MAX_CHOICE_LENGTH+$MAX_SUMMARY_LENGTH
      #
      # Create generated menu script from array data.
      MENU_TITLE="Main_Menu"  # Menu title must substitute underscores for spaces
      TEMP_FILE=$THIS_DIR/$THIS_FILE"_menu_main_temp.txt"
      #
      f_create_show_menu $GUI $GENERATED_FILE $MENU_TITLE $MAX_LENGTH $MAX_LINES $MAX_CHOICE_LENGTH $TEMP_FILE
      #
      if [ -r $GENERATED_FILE ] ; then
         rm $GENERATED_FILE
      fi
      #
} # End of function f_menu_main.
#
# +----------------------------------------+
# |       Function f_create_show_menu      |
# +----------------------------------------+
#
#     Rev: 2020-05-15
#  Inputs: $1=GUI - "dialog" or "whiptail" The CLI GUI application in use.
#          $2=GENERATED_FILE.
#          $3=Menu Title.
#          $4=MAX_LENGTH.
#          $5=MAX_LINES.
#          $6=MAX_CHOICE_LENGTH
#          $7=TEMP_FILE
#    Uses: GENERATED_FILE, ARRAY_NAME, ARRAY_LEN, XNUM.
# Outputs: None.
#
f_create_show_menu () {
      #
      case $1 in
           "dialog" | "whiptail")
              f_update_menu_gui $1 $2 $3 $4 $5 $7
           ;;
           "text")
              f_update_menu_txt $1 $2 $3 $6 $7
           ;;
      esac
      #
      . $2  # Invoke Generated File.
      #
      # Use generated menu script to display menu.
      # Create a unique function name extension used in the Generated File.
      EXT=$(echo $2 | sed 's|\/|-|g')
      #
      case $1 in
           "dialog" | "whiptail") 
              f_menu_gui$EXT $1 $3
              clear  # Clear screen.
           ;;
           "text")
              f_menu_txt$EXT
           ;;
       esac
      #
      if [ -r $2 ] ; then
         rm $2
      fi
      #
} # End of function f_create_show_menu.
#
# **************************************
# ***     Start of Main Program      ***
# **************************************
#
if [ -e $TEMP_FILE ] ; then
   rm $TEMP_FILE
fi
#
clear  # Clear screen.
#
echo "***********************************"
echo "***  Running script $THIS_FILE  ***"
echo "***   Rev. $VERSION     ***"
echo "***********************************"
echo
sleep 1  # pause for 1 second automatically.
#
clear  # Blank the screen.
#
#
# If an error occurs, the f_abort() function will be called.
# f_abort depends on f_message which must be in this script.
# (especially if library file *.lib is missing).
#
# trap 'f_abort' 0
# set -e
#
# Set THIS_DIR, SCRIPT_PATH to directory path of script.
f_script_path
#
if [ -r /$THIS_DIR/menu_module_main.lib ] ; then
   # Invoke library file menu_module_main.lib
   . /$THIS_DIR/menu_module_main.lib
else
   echo $(tput setaf 1) # Set font to color red.
   echo "Required module file \"menu_module_main.lib\" is missing."
   echo "Cannot continue, exiting program script."
   echo
   # f_abort depends on f_message which must be in this script.
   # (especially if library file *.lib is missing).
   f_abort text
fi
#
# Test for Optional Arguments.
f_arguments $1  # Also sets variable GUI.
#
# Uncomment the following lines if a test is needed.
# Test for X-Windows environment. Cannot run in CLI for LibreOffice.
#if [ x$DISPLAY = x ] ; then
#   echo -n $(tput setaf 1) # Set font to color red.
#   echo -n $(tput bold)
#   f_message text "OK" "Cannot run <GUI Application Name> without an X-Windows environment."
#   echo -n $(tput sgr0) # Set font to normal color.
#   echo
#   echo
#   f_abort
#fi
#
# If command already specifies GUI, then do not detect GUI i.e. "bash dropfsd.sh dialog" or "bash dropfsd.sh text".
if [ -z $GUI ] ; then
   # Test for GUI (Whiptail or Dialog) or pure text environment.
   f_detect_ui
fi
#
#GUI="whiptail"  # Diagnostic line.
#GUI="dialog"    # Diagnostic line.
#GUI="text"      # Diagnostic line.
#
# Test for BASH environment.
f_test_environment
#
f_main_menu
#
clear # Blank the screen. Nicer ending especially if you chose custom colors for this script.
#
exit 0  # This cleanly closes the process generated by #!bin/bash. 
        # Otherwise every time this script is run, another instance of
        # process /bin/bash is created using up resources.
# all dun dun noodles.
