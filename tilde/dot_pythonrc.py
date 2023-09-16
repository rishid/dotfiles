"""
This file is executed when the Python interactive shell is started if
$PYTHONSTARTUP is in your environment and points to this file. It's just
regular Python commands, so do what you will. Your ~/.inputrc file can greatly
complement this file.
"""

import os
import sys

VIRTUAL_ENV = os.environ.get('VIRTUAL_ENV', None)
HOME = VIRTUAL_ENV or os.environ.get('WORKON_HOME', None) or os.environ['HOME']

# dir() alternative http://inky.github.com/see
try:
    from see import see
except ImportError:
    print('\n`see()` not found, get it at http://inky.github.com/see or easy_install -U see\n')

#################################
# SAVE & RESTORE HISTORY STATES #
#################################

try:
    import readline
except ImportError:
    pass
else:
    
    ##################
    # TAB COMPLETION #
    ##################
    
    try:
        import rlcompleter
    except ImportError:
        pass
    else:
        if(sys.platform == 'darwin'):
            # Work around a bug in Mac OS X's readline module.
            readline.parse_and_bind("bind ^I rl_complete")
        else:
            readline.parse_and_bind("tab: complete")
    
    ######################
    # PERSISTENT HISTORY #
    ######################
    
    # Use separate history files for each virtual environment.
    HISTFILE = os.path.join(HOME, '.pyhistory')
    
    # Read the existing history if there is one.
    if os.path.exists(HISTFILE):
        try:
            readline.read_history_file(HISTFILE)
        except:
            # If there was a problem reading the history file then it may have
            # become corrupted, so we just delete it.
            os.remove(HISTFILE)
    
    # Set maximum number of commands written to the history file.
    readline.set_history_length(256)
    
    def savehist():
        try:
            readline.write_history_file(HISTFILE)
        except NameError:
            pass
        except Exception as err:
            print("Unable to save history file due to the following error: %s"
                  % err)
    
    # Register the ``savehist`` function to run when the user exits the shell.
    import atexit
    atexit.register(savehist)
