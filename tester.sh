#!/bin/bash
#set -e

DIR=$(dirname "$0")
PUSH_SWAP="${1:-$DIR/../push_swap/push_swap}"
CHECKER="${2:-$DIR/../checker_linux}"

echo_success() { echo -e "\033[32m$1\033[0m"; }
echo_error() { echo -e "\033[31m$1\033[0m"; }

if [ ! -f "$PUSH_SWAP" ]; then echo_error "Invalid push_swap path: $PUSH_SWAP"; exit 1; fi
if [ ! -f "$CHECKER" ]; then echo_error "Invalid checker path: $CHECKER"; exit 1; fi

test_random()
{
  NUM=$1
  ARG=$(shuf -i 1-100000 -n "$NUM" | tr '\n' ' ')
  OUTPUT=$($PUSH_SWAP "$ARG" | $CHECKER "$ARG")
  if [ "$OUTPUT" = "OK" ];
  then echo_success "OK" | tr -d '\n'
  else echo_error "KO" | tr -d '\n'; fi
  echo " $NUM ($($PUSH_SWAP "$ARG" | wc -l) moves)" | tr -d '\n'
  echo
}

test_manual()
{
  NAME=$1; shift
  ARG=$@
  OUTPUT=$($PUSH_SWAP $ARG | $CHECKER "$ARG")
  if [ "$OUTPUT" = "OK" ];
  then echo_success "OK" | tr -d '\n'
  else echo_error "KO" | tr -d '\n'; fi
  echo " $NAME ($($PUSH_SWAP $ARG | wc -l) moves)" | tr -d '\n'
  echo
}

test_expect_error()
{
  NAME=$1; shift
  ARG=$@
  OUTPUT=$($PUSH_SWAP $ARG 2>&1 | grep "Error" | tr -d '\n')
  if [ "$OUTPUT" = "Error" ];
  then echo_success "OK" | tr -d '\n'
  else echo_error "KO" | tr -d '\n'; fi
  echo " $NAME"
}

test_no_args()
{
  OUTPUT=$($PUSH_SWAP | wc -l)
  if [ "$OUTPUT" -eq 0 ]; then echo_success "OK"; else echo_error "KO"; fi
}

test_expect_nothing()
{
  OUTPUT=$($PUSH_SWAP $@ | wc -l)
  if [ "$OUTPUT" -eq 0 ]; then echo_success "OK"; else echo_error "KO"; fi
}

echo
echo "Random args"
test_random 1
test_random 2
test_random 3
test_random 3
test_random 3
test_random 3
test_random 3
test_random 4
test_random 4
test_random 4
test_random 4
test_random 4
test_random 5
test_random 5
test_random 5
test_random 5
test_random 5
test_random 10
test_random 50
test_random 100
test_random 100
test_random 100
test_random 100
test_random 100
test_random 500
test_random 500
test_random 500
test_random 500
test_random 500

echo
echo "Fixed args"
test_manual "negative values" -1 "-5 -3" -4 -2
test_manual "negative and positive values" -1 5 -3 4 -2
test_manual "reverse order" 5 4 3 2 1
test_manual "sorted" 1 2 3 4 5

echo
echo "Error handling"
test_expect_error "non integer 1" 1 "2a 5" 4 5
test_expect_error "non integer 2" 1 "2 a5" 4 5
test_expect_error "non integer 3" 1 "2 a 5" 4 5
test_expect_error "non integer 4" 1a "2 5" 4 5
test_expect_error "non integer 5" a1 "2 5" 4 5
test_expect_error "non integer 6" 1 a "2 5" 4 5
test_expect_error "non integer 7" 1 2 5 "4 5"
test_manual "= INT_MAX" 1 2 2147483647 "4 5"
test_expect_error "> INT_MAX" 1 2 2147483648 "4 5"
test_manual "= INT_MIN" 1 2 -2147483648 "4 5"
test_expect_error "< INT_MIN" 1 2 -2147483649 "4 5"
test_expect_error "duplicates 1" 1 "2 5" 4 5
test_expect_error "duplicates 2" 1 2 5 "4 5"

echo
echo "No args"
test_no_args

echo
echo "Empty arg"
test_expect_nothing "" "" "" ""
test_expect_nothing "" ""
test_expect_nothing ""
