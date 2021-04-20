#Converts an rpp to an s-tuple of multiplicities as specified in the Hillman-Grassl paper.
def hillman_grassl(rpp, verbose=False):
    n = get_rpp_size(rpp)

    col_lengths = get_col_lengths(rpp)

    if not verify_rpp(rpp, col_lengths):
        return

    path_lengths = []

    m = []

    for i in range(len(rpp)):
        m.append([])

        for j in range(len(rpp[i])):
        	m[i].append(0)



    while n > 0:
        if verbose:
            print_rpp(rpp)

            print("")



        pivot, zigzag_path = get_zigzag_path(rpp, col_lengths)

        m[pivot[0]][pivot[1]] += 1

        path_lengths.append(len(zigzag_path))

        _derive_rpp_(rpp, zigzag_path)

        n = get_rpp_size(rpp)



    return m



def hillman_grassl_inverse(m, verbose=False):
    col_lengths = get_col_lengths(m)

    pivots = get_pivots(m, col_lengths)



    rpp = []

    for i in range(len(m)):
        rpp.append([])

        for j in range(len(m[i])):
        	    rpp[i].append(0)



    for pivot in pivots:
        return_path = get_return_path(rpp, col_lengths, pivot)

        _antiderive_rpp_(rpp, return_path)

        if verbose:
            print_rpp(rpp)

            print("")


    return rpp



def print_rpp(rpp):
	for row in rpp:
		for entry in row:
			print(entry, end=" ")

		print("")



def get_rpp_size(rpp):
    return sum([sum(row) for row in rpp])



#Returns an array C, where C[j] is the length of column j of rpp.
def get_col_lengths(rpp):
    return [sum([len(row) >= j + 1 for row in rpp]) for j in range(len(rpp[0]))]



def get_hook_length(rpp, col_lengths, box):
    return len(rpp[box[0]]) - box[1] + col_lengths[box[1]] - box[0] - 1



#Verifies that an rpp with specified column lengths is in fact an rpp.
def verify_rpp(rpp, col_lengths):
    #Check that rpp is a Young tableau.
    for i in range(len(rpp) - 1):
        if len(rpp[i]) < len(rpp[i + 1]):
            print(f"Not an Young tableau: row {i} is longer than row {i + 1}")
            return False

    #Check that every entry is nonnegative.
    for i in range(len(rpp)):
        for j in range(len(rpp[i])):
            if rpp[i][j] < 0:
                print(f"Not an Young tableau: ({i}, {j}) < 0")
                return False

    #Check every row is weakly increasing.
    for i in range(len(rpp)):
        row = rpp[i]

        for j in range(len(row) - 1):
            if row[j] > row[j + 1]:
                print(f"Not an rpp: ({i}, {j}) > ({i}, {j + 1})")
                return False

    #Check every column is weakly increasing.
    for j in range(len(rpp[0])):
        for i in range(col_lengths[j] - 1):
            if rpp[i][j] > rpp[i + 1][j]:
                print(f"Not an rpp: ({i}, {j}) > ({i + 1}, {j})")
                return False

    return True



#Returns the zigzag path for an rpp.
def get_zigzag_path(rpp, col_lengths):
    path = []

    c = 0
    start_j = 0
    r = 0

    #First, find the smallest j so that (q_j, j > 0).
    for j in range(len(rpp[0])):
        if rpp[col_lengths[j] - 1][j] != 0:
            start_j = j
            c = j
            r = col_lengths[j] - 1
            break



    for i in range(r, -1, -1):
        #Find the smallest j bigger than the current one (i.e. c) with (i, j) = (i - 1, j).

        found_zigzag = False

        for j in range(start_j, len(rpp[i])):
            if i != 0 and rpp[i][j] == rpp[i - 1][j]:
                path += [[i, k] for k in range(start_j, j + 1)]
                start_j = j
                found_zigzag = True
                break

        #If we failed to find that, just add the end of the row to the path and stop.
        if i == 0 or not found_zigzag:
            path += [[i, k] for k in range(start_j, len(rpp[i]))]
            break



    return ([i, c], path)



#Returns the return path for an rpp -- the inverse of a zigzag path.
def get_return_path(rpp, col_lengths, pivot):
    path = []

    start_i = pivot[0]
    end_i = col_lengths[pivot[1]] - 1

    #Start j at the end of the pivot's row.
    start_j = len(rpp[pivot[0]]) - 1
    end_j = pivot[1]

    #We'll deal with the final row separately.
    for i in range(start_i, end_i):
        for j in range(start_j, end_j - 1, -1):
            if col_lengths[j] >= i + 2 and rpp[i][j] == rpp[i + 1][j]:
                path += [[i, k] for k in range(start_j, j - 1, -1)]
                start_j = j
                break

    path += [[end_i, k] for k in range(start_j, end_j - 1, -1)]

    return path



def _derive_rpp_(rpp, zigzag_path):
    for box in zigzag_path:
        rpp[box[0]][box[1]] -= 1

    return



def _antiderive_rpp_(rpp, return_path):
    for box in return_path:
        rpp[box[0]][box[1]] += 1

    return



#Returns the array of pivots corresponding to the lambda-array m.
def get_pivots(m, col_lengths):
    pivots = []

    for j in range(len(m[0]) - 1, -1, -1):
        for i in range(col_lengths[j]):
            for k in range(m[i][j]):
                pivots.append([i, j])

    return pivots



#Returns the array of hook lengths corresponding to the lambda-array m, in order of size (biggest to smallest).
def get_hook_lengths_list(m, col_lengths):
    hook_lengths = []

    for j in range(len(m[0])):
        for i in range(col_lengths[j]):
            hook_lengths.append(len(m[i]) - j + col_lengths[j] - i - 1)

	indices = list(range(len(hook_lengths))

	#Sort
	hook_lengths, indices = (list(t) for t in zip(*sorted(zip(hook_lengths, indices))))

    return hook_lengths, indices



rpp = \
[
    [1, 2, 4],
    [3, 5, 5],
    [4]
]

m = hillman_grassl(rpp, True)

print("\n")

print_rpp(hillman_grassl_inverse(m, True))
