export red=$'\e[1;31m'
export grn=$'\e[1;32m'
export blu=$'\e[1;34m'
export mag=$'\e[1;35m'
export cyn=$'\e[1;36m'
export white=$'\e[0m'

function logStep() {
  printf $cyn"\n$@"$white""
}

function logNote() {
  printf $blu"\n$@"$white""
}

function logSubStep() {
  printf $mag"\n  - $@"$white""
}

function logErr() {
  printf $red"$@"$white"\n"
}
