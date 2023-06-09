#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

display_available_services() {
  echo -e "\n~~~~~ Treat-Yo-Self Salon ~~~~~\n"

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$AVAILABLE_SERVICES" | while read -r SERVICE_ID _ NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

validate_service_selection() {
  local service_id=$1
  SERVICE_FOUND_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $service_id")
  [[ -n $SERVICE_FOUND_RESULT ]]
}

get_customer_information() {
  echo -e "\nWhat is your phone number?"
  read -r CUSTOMER_PHONE

  CUSTOMER_FOUND_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_FOUND_RESULT ]]
  then
    echo -e "\nWhat is your name?"
    read -r CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
}

insert_appointment() {
  local customer_id=$1
  local service_id=$2
  local service_time=$3

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($customer_id, $service_id, '$service_time')")
}

# Display available services
display_available_services

# Get user's service selection
read -rp "Enter the service number you'd like to treat yo self with: " SERVICE_ID_SELECTED

while ! validate_service_selection "$SERVICE_ID_SELECTED"
do
  echo -e "\nInvalid service ID. Please try again."
  display_available_services
  read -rp "Enter the service ID you'd like to book: " SERVICE_ID_SELECTED
done

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Get customer information
get_customer_information

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Get appointment time
read -rp "What time would you like your appointment? " SERVICE_TIME

# Insert the appointment
insert_appointment "$CUSTOMER_ID" "$SERVICE_ID_SELECTED" "$SERVICE_TIME"

echo -e "\nThank you for scheduling with us! Your appointment for $(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g') at $SERVICE_TIME has been booked, $CUSTOMER_NAME."
