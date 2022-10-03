# FUNCTIONS
stripe(){
  eval printf %.0s$1 '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
}

stripe_(){
  stripe "-"
}

stripe__(){
  stripe "="
}