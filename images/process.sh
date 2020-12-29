awk -F'[/._]' '{ printf "mkdir -p %s/%s && cp %s %s/%s/%s.png\n", $5, $6, $0, $5, $6, $7}' files
