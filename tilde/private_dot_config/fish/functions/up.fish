function up -d "cd up N directory levels"
  for count in (seq $argv)
    cd ..
  end
end
