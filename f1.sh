#!/bin/bash

# File containing ordered foods
Food_File="food.txt"
Bill_File="bill.txt"

# Ensure the file exists
if [ ! -f "$Food_File" ]; then
    touch "$Food_File"
fi
if [ ! -f "$Bill_File" ]; then
    touch "$Bill_File"
fi


# Price list for food items
declare -A prices
prices=(
    ["Vegetable_Soup"]=60
    ["Gobi_Manchurian"]=80
    ["Babycorn_Manchurian"]=80
    ["Paneer_Tikka"]=120
    ["Tandoori_Roti"]=25
    ["Butter_Naan"]=40
    ["Butter_Kulcha"]=40
    ["Stuffed_Paratha"]=60
    ["Veg_Kurma"]=120
    ["Paneer_Tikka_Masala"]=150
    ["Dal_Tadka"]=130
    ["Palak_Paneer"]=140
    ["Veg_Biryani"]=150
    ["Paneer_Biryani"]=180
    ["Fried_Rice"]=120
    ["Ghee_Rice"]=120
    ["Chicken_65"]=120
    ["Lemon_Chicken"]=150
    ["Kebab"]=120
    ["Chicken_Lollipop"]=150
    ["Chicken_Curry"]=220
    ["Mutton_Curry"]=310
    ["Fish_Curry"]=420
    ["Butter_Chicken"]=250
    ["Chicken_Biryani"]=150
    ["Chicken_Fried_Rice"]=150
    ["Mutton_Biryani"]=200
    ["Egg_Rice"]=120
)

# Function to display menus
function show_menu {
    zenity --list --title="$1" --column="Options" "${@:2}" --width=400 --height=400
}

# Function to view available foods
function view_available_foods {
    while true; do
        food_type=$(show_menu "Menu" "Veg" "Non-Veg" "Done")
        case $food_type in
            "Veg")
                while true; do
                    veg_category=$(show_menu "Veg Menu" "Starters" "Roti" "Curry" "Rice" "Done")
                    case $veg_category in
                        "Starters")
                            show_menu "Veg Starters" "Vegetable_Soup = 60" "Gobi_Manchurian = 80" "Babycorn_Manchurian = 80" "Paneer_Tikka = 120"
                            ;;
                        "Roti")
                            show_menu "Veg Roti" "Tandoori_Roti = 25" "Butter_Naan = 40" "Butter_Kulcha = 40" "Stuffed_Paratha = 60"
                            ;;
                        "Curry")
                            show_menu "Veg Curries" "Veg_Kurma = 120" "Paneer_Tikka_Masala = 150" "Dal_Tadka = 130" "Palak_Paneer = 140"
                            ;;
                        "Rice")
                            show_menu "Veg Rice" "Veg_Biryani = 150" "Paneer_Biryani = 180" "Fried_Rice = 120" "Ghee_Rice = 120"
                            ;;
                        "Done")
                            break
                            ;;
                    esac
                done
                ;;
            "Non-Veg")
                while true; do
                    nonveg_category=$(show_menu "Non-Veg Menu" "Starters" "Curry" "Rice" "Done")
                    case $nonveg_category in
                        "Starters")
                            show_menu "Non-Veg Starters" "Chicken_65 = 120" "Lemon_Chicken = 150" "Kebab = 120" "Chicken_Lollipop = 150"
                            ;;
                        "Curry")
                            show_menu "Non-Veg Curries" "Chicken_Curry = 220" "Mutton_Curry = 310" "Fish_Curry = 420" "Butter_Chicken = 250"
                            ;;
                        "Rice")
                            show_menu "Non-Veg Rice" "Chicken_Biryani = 150" "Chicken_Fried_Rice = 150" "Mutton_Biryani = 200" "Egg_Rice = 120"
                            ;;
                        "Done")
                            break
                            ;;
                    esac
                done
                ;;
            "Done")
                break
                ;;
        esac
    done
}

# Main infinite loop
while true; do
    choice=$(show_menu "Food Ordering System" "View Available Foods" "Add Food" "Remove Food" "View Selected Food" "Generate Bill" "Place Order")
    case $choice in
        "View Available Foods")
            view_available_foods
            ;;
        "Add Food")
            new_food=$(zenity --entry --title="Add Food" --text="Enter food item (case-sensitive):" --width=300)
            if [[ -n "$new_food" && -n "${prices[$new_food]}" ]]; then
                echo "$new_food" >> "$Food_File"
                zenity --info --title="Food Added" --text="$new_food has been added to your order." --width=300
            else
                zenity --warning --title="Invalid Food" --text="Food item not recognized or not priced." --width=300
            fi
            ;;
        "Remove Food")
            if [ -s "$Food_File" ]; then
                food_to_remove=$(zenity --list --title="Remove Food" --column="Foods" $(cat "$Food_File") --width=400 --height=400)
                if [ -n "$food_to_remove" ]; then
                    grep -vF "$food_to_remove" "$Food_File" > temp && mv temp "$Food_File"
                    zenity --info --title="Food Removed" --text="$food_to_remove removed successfully!" --width=300
                else
                    zenity --warning --title="No Selection" --text="Please select a food to remove." --width=300
                fi
            else
                zenity --warning --title="No Food" --text="You have not added any food to your order." --width=300
            fi
            ;;
        "View Selected Food")
            if [ -s "$Food_File" ]; then
                zenity --text-info --title="Your Order" --filename="$Food_File" --width=400 --height=400
            else
                zenity --warning --title="Empty Order" --text="No items in your order!" --width=300
            fi
            ;;
        "Generate Bill")
            total=0
            bill_content="Item\tPrice\n---------------------\n"
            while read -r item; do
                if [[ -n "${prices[$item]}" ]]; then
                    bill_content+="$item\t${prices[$item]} INR\n"
                    total=$((total + prices[$item]))
                else
                    bill_content+="$item\t(Not Priced)\n"
                fi
            done < "$Food_File"
            bill_content+="---------------------\nTotal: \t${total} INR\n"
            echo -e "$bill_content" > bill.txt
            zenity --text-info --title="Bill Summary" --filename="bill.txt" --width=400 --height=400
            ;;
        "Place Order")
            if [ -s "$Food_File" ]; then
                name=$(zenity --entry --title="Customer Name" --text="Enter your name:" --width=300)
                address=$(zenity --entry --title="Delivery Address" --text="Enter your address:" --width=300)
                email=$(zenity --entry --title="Email Address" --text="Enter your email address:" --width=300)

                if [ -z "$name" ] || [ -z "$address" ] || [ -z "$email" ]; then
                    zenity --warning --title="Missing Details" --text="All fields are required!" --width=300
                else
                    order_items=$(cat "$Food_File")
		    bill=$(cat "$Bill_File")
                    python3 send_email.py "$name" "$address" "$email" "$order_items" "$bill"
                    if [ $? -eq 0 ]; then
                        zenity --info --title="Order Status" --text="Order placed successfully!\nPlease wait for the food to be prepared." --width=300
                        > "$Food_File"
                        break
                    else
                        zenity --error --title="Email Error" --text="Failed to send email. Please try again!" --width=300
                    fi
                fi
            else
                zenity --warning --title="Empty Order" --text="No items in your order!" --width=300
            fi
            ;;
        *)
            zenity --error --title="Invalid Choice" --text="Please select a valid option." --width=300
            ;;
    esac
done
