function repeat -d "Repeat a command a given number of times"
  for i in (seq $argv[1])
    if eval "$argv[2..-1]"
    else
      echo "Error on iteration: $i Status: $status"
      return 1
    end
  end
end
