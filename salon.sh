#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  echo -e "\n$1\n"

  #get all ther services offered and print them to console
  SERVICES=$($PSQL "select * from services order by service_id")
  
  echo "$SERVICES" | while read SERVICE_ID SEPERATOR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #ask for a service
  read SERVICE_ID_SELECTED

  #check if service choice is a positive number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #DISPLAY THE MENU AGAIN
    MAIN_MENU "Please enter a valid number. What would you like today?"
  else
    #check if service exists
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED" | sed 's/^ *//')

    if [[ -z $SERVICE_NAME ]]
    then
      #DISPLAY THE MENU AGAIN
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #ask for a phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      #Check to see if a customer already exist
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'"  | sed 's/^ *//')

      #add customers if they dont exist in the database
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_RESULTS=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      #get customer id, service name and ask for appointment time
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      #finish the appointment and return to main menu
      INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"