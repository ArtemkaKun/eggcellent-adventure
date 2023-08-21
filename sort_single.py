import csv

# Read the profile data line by line, split each line
with open('profile.txt', 'r') as file:
    data = [line.split() for line in file.readlines() if line.strip()]

# Convert the self time values to int
for row in data:
    row[2] = int(row[2][:-2])

# Sort the data by the self time spent in each function
data.sort(key=lambda x: x[2], reverse=True)

# Print all the data
for row in data:
    print(f"Function: {row[-1]}, Self Time: {row[2]}ns, Calls: {row[0]}")
