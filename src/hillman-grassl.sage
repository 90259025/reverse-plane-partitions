#Converts an rpp to an s-tuple of multiplicities as specified in the Hillman-Grassl paper
def hilmann_grassl(rpp):
    n = sum([sum(row) for row in rpp])

    col_lengths = get_col_lengths(rpp)

    if not verify_rpp(rpp, col_lengths):
        return

    pivot, zigzag_path = get_zigzag_path(rpp, col_lengths)



    return



#Returns an array C, where C[j] is the length of column j of rpp
def get_col_lengths(rpp):
    return [sum([len(row) >= j + 1 for row in rpp]) for j in range(len(rpp[0]))]



#Verifies that an rpp with specified column lengths is in fact an rpp
def verify_rpp(rpp, col_lengths):
    #Check that rpp is a Young tableau
    for i in range(len(rpp) - 1):
        if len(rpp[i]) < len(rpp[i + 1]):
            print(f"Not an Young tableau: row {i} is longer than row {i + 1}")
            return False

    #Check that every entry is nonnegative
    for i in range(len(rpp)):
        for j in range(len(rpp[i])):
            if rpp[i][j] < 0:
                print(f"Not an Young tableau: ({i}, {j}) < 0")
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
        for i in range(col_lengths[j] - 1):
            if rpp[i][j] > rpp[i + 1][j]:
                print(f"Not an rpp: ({i}, {j}) > ({i + 1}, {j})")
                return False

    return True



#Returns the zigzag path for an rpp
def get_zigzag_path(rpp, col_lengths):
    path = []

    c = 0
    start_j = 0
    r = 0

    pivot = (0, 0)

    #First, find the smallest j so that (q_j, j > 0).
    for j in range(len(rpp[0])):
        if rpp[col_lengths[j] - 1][j] != 0:
            start_j = j
            c = j
            r = col_lengths[j] - 1
            break



    for i in range(r, -1, -1):
        #Find the smallest j bigger than the current one (i.e. c) with (i, j) = (i - 1, j)

        found_zigzag = False

        for j in range(start_j, len(rpp[i])):
            if i != 0 and rpp[i][j] == rpp[i - 1][j]:
                path += [[i, k] for k in range(start_j, j + 1)]
                start_j = j
                found_zigzag = True
                break

        #If we failed to find that, just add the end of the row to the path and stop
        if i == 0 or not found_zigzag:
            path += [[i, k] for k in range(start_j, len(rpp[i]))]
            break



    return ([i, c], path)



rpp = [
    [0, 2, 4, 5],
    [1, 3, 4],
    [1, 3, 4],
    [3, 3]
]

hilmann_grassl(rpp)
