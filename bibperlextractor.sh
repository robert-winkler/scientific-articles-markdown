perl -ne 'print "$1," if /(?<=@)(.+?)(?=[\],])/' agile-editing-pandoc.md
