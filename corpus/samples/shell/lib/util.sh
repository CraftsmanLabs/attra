# A second source root.
add() {
  echo $(($1 + $2))
}

unused() {
  add "$1" 1
}
