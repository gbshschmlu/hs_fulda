def display_hello_world():
    # Console Output
    print("Hello, World!")
    
    # Write to a file
    with open("hello_world.txt", "w") as file:
        file.write("Hello, World!\n")
    
    # Append to a file
    with open("hello_world.txt", "a") as file:
        file.write("Appending Hello, World!\n")
    
    # Using a loop
    for i in range(3):
        print(f"Hello, World! {i + 1}")
    
    # Using a list
    greetings = ["Hello,World!", "Hi, Universe!", "Greetings, Earth!"]
    for greeting in greetings:
        print(greeting)
    
    # Using a function call
    def custom_greeting(name):
        return f"Hello, {name}!"
    
    print(custom_greeting("World"))

# Call the function to display "Hello, World!" in various ways
display_hello_world()
