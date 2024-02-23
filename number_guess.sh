#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# WELCOME
WELCOME_MENU() {
  echo "Enter your username:"
  read USERNAME
  USERNAME_EXISTS_RESULT=$($PSQL "select user_id from users where username ilike '$USERNAME'")
  if [[ -z $USERNAME_EXISTS_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    ADD_USER_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
    RUN_ROUND $USERNAME
  else
    GAMES_PLAYED=$($PSQL "select games_played from users where username ilike '$USERNAME'")
    BEST_GAME=$($PSQL "select best_game from users where username ilike '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    RUN_ROUND $USERNAME
  fi
}
# GAME TIME
RUN_ROUND() {
  RANDOM_NUMBER=$((RANDOM % 1000 + 1))
  #echo $RANDOM_NUMBER
  NUMBER_OF_GUESSES=0
  USERNAME=$1
  echo $USERNAME
  echo "Guess the secret number between 1 and 1000:"
  while [[ $GUESS != $RANDOM_NUMBER ]]
  do
    read GUESS
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      while ! [[ $GUESS =~ ^[0-9]+$ ]]
      do
        echo "That is not an integer, guess again:"
        read GUESS
      done
    fi
    ((NUMBER_OF_GUESSES++))
    if [[ $RANDOM_NUMBER != $GUESS ]]
    then
      if [[ $GUESS > $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $GUESS < $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  done
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  # Log Number of Guesses and Increase Games Played
  USER_HIGH_SCORE=$($PSQL "select best_game from users where username ilike '$USERNAME'")
  if [[ $USER_HIGH_SCORE > $NUMBER_OF_GUESSES || -z $USER_HIGH_SCORE ]]
  then
    REPLACE_HIGH_SCORE_RESULT=$($PSQL "update users set best_game = $NUMBER_OF_GUESSES where username ilike '$USERNAME'")
  fi
  USER_INCREASE_GAMES_RESULT=$($PSQL "update users set games_played = games_played + 1 where username ilike '$USERNAME'")
}
WELCOME_MENU
