#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read INPUT_USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$INPUT_USERNAME'")

if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $INPUT_USERNAME! It looks like this is your first time here."

  GAMES_PLAYED=1
  INPUT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$INPUT_USERNAME', $GAMES_PLAYED)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$INPUT_USERNAME'")
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id = '$USER_ID'")
  
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRETNUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
(( NUMBER_GUESSES++ ))

while ! [[ $USER_GUESS =~ ^[0-9]+$ ]] || [[ -z $USER_GUESS ]]
    do
      echo "That is not an integer, guess again:"
      read USER_GUESS
    done

while [[ $USER_GUESS -ne $SECRETNUMBER ]]
    do
      if [[ $USER_GUESS -gt $SECRETNUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else
        echo -e "\nIt's higher than that, guess again:"
      fi
      read USER_GUESS
      (( NUMBER_GUESSES++ ))
    done

if [[ -z $BEST_GAME || $NUMBER_GUESSES -lt $BEST_GAME ]]
  then 
    INSERT_NEW_BEST=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $NUMBER_GUESSES WHERE user_id = $USER_ID")
  else
    UPDATE_NUMBER_GAMES=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
fi

echo -e "\nYou guessed it in $NUMBER_GUESSES tries. The secret number was $SECRETNUMBER. Nice job!"
exit
