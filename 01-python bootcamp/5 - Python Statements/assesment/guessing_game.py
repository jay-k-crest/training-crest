from random import randint

number_to_guess = randint(1,100)
guesses = []

guess = int(input("Enter your guess between 1 and 100: "))

while guess != number_to_guess:

    # OUT OF BOUNDS
    if guess < 1 or guess > 100:
        print("OUT OF BOUNDS")
    
    # FIRST GUESS
    elif not guesses:
        if abs(number_to_guess - guess) <= 10:
            print("WARM!")
        else:
            print("COLD!")
        guesses.append(guess)

    # SUBSEQUENT GUESSES
    else:
        if abs(number_to_guess - guess) < abs(number_to_guess - guesses[-1]):
            print("WARMER!")
        else:
            print("COLDER!")
        guesses.append(guess)

    # ask again every loop
    guess = int(input("Guess again: "))

print(f"CORRECT! You got it in {len(guesses)+1} guesses 🎉")

[50,60,70]