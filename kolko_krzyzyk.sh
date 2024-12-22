#!/bin/bash

init_message() {
    echo "-------------------"
    echo "--- TIC TAC TOE ---"
    echo "-------------------"
    echo "Click Enter to play multiplayer mode"
    echo "To play with computer press c"
    echo "Press l to load game"
}

print_board() {
    echo "${board[0]} ${board[1]} ${board[2]}"
    echo "${board[3]} ${board[4]} ${board[5]}"
    echo "${board[6]} ${board[7]} ${board[8]}"
}

set_player() {
    if [ "$player_turn" -eq 1 ]; then
        echo "Player 1 (X) turn"
        player=$player_1
    else
        if [ "$multiplayer" == "false" ]; then
            echo "Computer (O) turn"
            player="O"
        else
            echo "Player 2 (O) turn"
            player=$player_2
        fi
    fi
}

read_and_check() {
    if [ "$multiplayer" == "false" ] && [ "$player_turn" -eq 2 ]; then
        echo "Computer is making a move..."
        while true; do
            choice=$((RANDOM % 9 + 1))
            if [ "${board[$((choice-1))]}" == "." ]; then
                board[$((choice-1))]=$player
                break
            fi
        done
        if [ "$player_turn" -eq 1 ]; then
            player_turn=2
        else
            player_turn=1
        fi
    else
        while true; do
            read -p "Enter a number between 1 and 9 (or 's' to save): " choice
            if [[ "$choice" == 's' ]]; then
                save_game
            elif [[ "$choice" =~ ^[1-9]$ ]]; then
                if [ "${board[$((choice-1))]}" != "." ]; then
                    echo "Place $choice is already taken, try another number"
                else
                    board[$((choice-1))]=$player
                    if [ "$player_turn" -eq 1 ]; then
                        player_turn=2
                    else
                        player_turn=1
                    fi
                    break
                fi
            else
                echo "Incorrect input, please enter a number from 1 to 9 or s to save this game."
            fi
        done
    fi
}

check_win() {
    if [[ ${board[0]} == ${board[1]} && ${board[1]} == ${board[2]} && ${board[0]} != "." ]]; then
		game=0
    elif [[ ${board[3]} == ${board[4]} && ${board[4]} == ${board[5]} && ${board[5]} != "." ]]; then
		game=0
    elif [[ ${board[6]} == ${board[7]} && ${board[7]} == ${board[8]} && ${board[6]} != "." ]]; then
        game=0
    elif [[ ${board[0]} == ${board[3]} && ${board[3]} == ${board[6]} && ${board[0]} != "." ]]; then
        game=0
    elif [[ ${board[1]} == ${board[4]} && ${board[4]} == ${board[7]} && ${board[1]} != "." ]]; then
        game=0
    elif [[ ${board[2]} == ${board[5]} && ${board[5]} == ${board[8]} && ${board[2]} != "." ]]; then
        game=0
    elif [[ ${board[0]} == ${board[4]} && ${board[4]} == ${board[8]} && ${board[0]} != "." ]]; then
        game=0
    elif [[ ${board[2]} == ${board[4]} && ${board[4]} == ${board[6]} && ${board[2]} != "." ]]; then
        game=0

    else
        check_tie
        if [[ $? -eq 0 ]]; then
            game=0
            tie=1
        fi
    fi
}

check_tie() {
    for value in "${board[@]}"; do
        if [[ "$value" != "X" && "$value" != "O" ]]; then
            return 1
        fi
    done
    return 0
}

save_game() {
    echo "Saving game..."
    echo "$player_1" > saved_game.txt
    echo "$player_2" >> saved_game.txt
    echo "$player_turn" >> saved_game.txt
    echo "$game" >> saved_game.txt
    echo "$tie" >> saved_game.txt
    echo "$multiplayer" >> saved_game.txt
    printf "%s\n" "${board[@]}" >> saved_game.txt
    echo "Game saved."
}

read_game() {
    if [ -f saved_game.txt ]; then
        echo "Loading game..."
        player_1=$(sed -n '1p' saved_game.txt)
        player_2=$(sed -n '2p' saved_game.txt)
        player_turn=$(sed -n '3p' saved_game.txt)
        game=$(sed -n '4p' saved_game.txt)
        tie=$(sed -n '5p' saved_game.txt)
        multiplayer=$(sed -n '6p' saved_game.txt)
        board=($(sed -n '7,15p' saved_game.txt))
        echo "Game loaded."
        print_board
    else
        echo "No saved game found."
    fi
}



init_message

while true; do
    read user_input

    if [[ -z "$user_input" ]]; then
        board=( "." "." "." "." "." "." "." "." "." )
        player_1="X"
        player_2="O"
        player_turn=1
        game=1
        tie=0
        multiplayer="true"
        break
    elif [[ "$user_input" == "c" ]]; then
        board=( "." "." "." "." "." "." "." "." "." )
        player_1="X"
        player_2="O"
        player_turn=1
        game=1
        tie=0
        multiplayer="false"
        break
    elif [[ "$user_input" == "l" ]]; then
        read_game
        if [[ $game -eq 1 ]]; then
            break
        else
            echo "Please choose a valid option (Press Enter for multiplayer, 'c' for computer)."
        fi
    else
        echo "Invalid input."
    fi
done

while [[ $game -eq 1 ]]
do
    set_player
    read_and_check
    print_board
    check_win
done

if [[ $tie -eq 1 ]]; then
    echo "Tie. Try again!"
else
    echo "Player $((3 - player_turn)) wins!"
    echo "congratulations!"
fi
