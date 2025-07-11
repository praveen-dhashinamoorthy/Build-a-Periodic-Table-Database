#!/bin/bash

# Check if argument is passed
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Set up database command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Decide which column to search
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $1"
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
  CONDITION="e.symbol = '$1'"
else
  CONDITION="e.name = '$1'"
fi

# Query the database
RESULT=$($PSQL "
SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t USING(type_id)
WHERE $CONDITION;
")

# Handle not found
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Read the result into variables
IFS='|' read -r NUM NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# Output clean sentence
echo "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
