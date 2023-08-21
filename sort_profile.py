import csv

# Read the profile data line by line, split each line
with open('profile.txt', 'r') as file:
    data = [line.split() for line in file.readlines() if line.strip()]

# Convert the time values to float
for row in data:
    row[1] = float(row[1][:-2])

# Sort the data by the total time spent in each function
data.sort(key=lambda x: x[1], reverse=True)

# Print all the data
for row in data:
    print(f"Function: {row[-1]}, Time: {row[1]}ms, Calls: {row[0]}")
