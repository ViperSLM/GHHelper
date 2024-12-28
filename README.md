# GH Helper Script
This is a Windows Batch-based utility to help assist with mod development for Guitar Hero World Tour. In it's current form,
it is focused on custom venue mod development as well as compiling node scripts and/or converting script syntaxes. *(ROQ -> QBC)*

# How to use
In order to fully use this script, you'll also need GHSDK and it's prerequisites set up on your computer, especially Node.JS.
Please make sure that Node.JS is also set up in your system's PATH variable. (Should do that automatically by default, afaik.)

Running the batch script the first time will go through it's initial setup where you'll need to set up some variables.
These variables are then stored inside a configuration file (gh_helper.cfg), which the script then loads the next time it
is started, as long as it's in the same directory as the script. You can also easily modify settings just by editing this file.
a text editor.

***What each variable is used for:***
- **GHSDK:** The full path where GHSDK is located
- **GHWT_MODS:** The mods folder utilised by GHWT:DE
- **VENUE:** The internal name for the venue, which typically starts with the prefix 'z_' *(i.e. z_test)*
- **FINAL_OUTPUT:** The final name of the venue which is used when copying the packed venue to the path set via the *'GHWT_MODS'* variable. Change this variable to the folder where the venue is exported to.