#Converts an rpp to an s-tuple of multiplicities as specified in the Hillman-Grassl paper.
def hilmann_grassl(rpp, verbose=False):
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

    pivot = (0, 0)

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



def _derive_rpp_(rpp, zigzag_path):
    for box in zigzag_path:
        rpp[box[0]][box[1]] -= 1
    
    return



rpp = [
    [1, 2, 4],
    [3, 5, 5],
    [4]
]

print_rpp(hilmann_grassl(rpp, False))