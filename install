#!/usr/bin/env python
 
import os
import shutil
import optparse
import sys

def main():
    def exclude_list(option, opt_str, value, parser):
        parser.values.exclude = parser.values.exclude + value.split(',')
        
    parser = optparse.OptionParser(usage='Usage: %prog [OPTIONS]', description='Install all files and directories as dotfiles.')
    parser.add_option('-b', '--backup', action='store_true', dest='backup', default=False, help='Backup old files')
    parser.add_option('-c', '--copy', action='store_true', dest='copy', default=False, help='Copy files instead of hard-linking them')
    parser.add_option('-e', '--exclude', action='callback', callback=exclude_list, type='string', dest='exclude', default=['README', 'install.py', '.git', '.gitignore'], help='Comma seperated list of files to exclude', metavar='FILES')
    parser.add_option('-f', '--force', action='store_true', dest='force', default=False, help='Overwrite without confirmation')
    parser.add_option('-p', '--prefix', action='store', dest='prefix', default=os.path.expanduser('~'), help='Install location [default: %default]', metavar='PATH')
 
    (options, args) = parser.parse_args()
 
    def traverse(path):
        for item in os.listdir(path):
            source = os.path.join(path, item)          

            if item.startswith('.'):
                destination = os.path.join(options.prefix, item)
            elif item == "bin":
                destination = os.path.join(options.prefix, item)
            else:
                destination = os.path.join(options.prefix, '.' + item)
                    
            if item in options.exclude:
                continue
                    
            install(source, destination)

    def install(source, destination):
        if os.path.exists(destination):
            if options.backup:
                shutil.move(destination, destination + '.bak')
            elif options.force:
                os.remove(destination)
            else:
                answer = raw_input(destination + ': File already exists, overwrite? [y/N]')

                if answer.lower() in ('y', 'yes'):
                    if (os.path.isfile(destination)):
                      os.remove(destination)
                    else:
                      shutil.rmtree(destination)
                else:
                    return
                
        if options.copy:
            shutil.copy(source, destination)
        else:
            os.symlink(source, destination)
                                                
    traverse(os.path.dirname( os.path.realpath( __file__ ) ) )    
                                                
if __name__ == '__main__':
    try:
        main()
        print "Install complete"
    except (KeyboardInterrupt, SystemExit):
        sys.exit(1)
                                                        
