function exifdiff
    # Usage: exifdiff path/file1.ext path/file2.ext parameters
    # eg:    exifdiff dsc_7811.nef ./jpegs/dsc_7811.jpg
    # eg:    exifdiff dsc_7811.nef ./jpegs/dsc_7811.jpg -a -G1 -datetimeoriginal

    set B1 (basename $argv[1])
    set B2 (basename $argv[2])

    exiftool $argv  -w! /tmp/%f.%e.txt
    diff -d -y --left-column /tmp/$B1.txt /tmp/$B2.txt  | less -i
end

function exif
    if test "$1" = "/dev/null"
        echo "/dev/null"
        return
    end

    set b (basename "$1")
    set d (mktemp -t "$b.XXXXXX")

    exiftool $1 | grep -v 'File Name' | \
                  grep -v 'Directory' | \
                  grep -v 'ExifTool Version Number' | \
                  grep -v 'File Inode Change' | \
                  grep -v 'File Access Date/Time' | \
                  grep -v 'File Modification Date/Time' | \
                  grep -v 'File Permissions' | \
                  grep -v 'File Type Extension' | \
                  sort \
      > $d
    echo $d
end

#d1="$(exif "$f1")"
#  d2="$(exif "$f2")"
#   git --no-pager diff --no-index --color-words "$1" "$2"  || true
#  set +e
#  diff -q "$d1" "$d2" >/dev/null
#  exifdiff=$?
#  set -e
