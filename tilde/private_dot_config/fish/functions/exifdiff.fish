function exifdiff
    # Usage: exifdiff path/file1.ext path/file2.ext parameters
    # eg:    exifdiff dsc_7811.nef ./jpegs/dsc_7811.jpg
    # eg:    exifdiff dsc_7811.nef ./jpegs/dsc_7811.jpg -a -G1 -datetimeoriginal

    set B1 (basename $argv[1])
    set B2 (basename $argv[2])

    exiftool $argv  -w! /tmp/%f.%e.txt
    diff -d -y --left-column /tmp/$B1.txt /tmp/$B2.txt  | less -i
end
