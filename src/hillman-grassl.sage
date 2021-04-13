def hilmann_grassl(rpp):
    return



def verify_rpp(rpp):
    #Check that rpp is a Young tableau
    for i in range(len(rpp) - 1):
        if len(rpp[i]) < len(rpp[i + 1]):
            print(f"Not an Young tableau: row {i} is longer than row {i + 1}")
            return False

    #Check every row is weakly increasing
    for i in range(len(rpp)):
        row = rpp[i]

        for j in range(len(row) - 1):
            if row[j] > row[j + 1]:
                print(f"Not an rpp: ({i}, {j}) > ({i}, {j + 1})")
                return False

    #Check every column is weakly increasing
    for j in range(len(rpp[0])):
        col_length = sum([len(row) >= j + 1 for row in rpp])

        for i in range(col_length - 1):
            if rpp[i][j] > rpp[i + 1][j]:
                print(f"Not an rpp: ({i}, {j}) > ({i + 1}, {j})")
                return False

    return True



rpp = [
    [1, 2, 2],
    [1, 1]
]

print(verify_rpp(rpp))
