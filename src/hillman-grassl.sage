import copy
import time



#Converts an rpp to an s-tuple of multiplicities as specified in the Hillman-Grassl paper.
def hillman_grassl(rpp, verbose=False):
	n = get_rpp_size(rpp)

	col_lengths = get_col_lengths(rpp)

	if not verify_rpp(rpp, col_lengths):
		return

	path_lengths = []

	#Make m the same shape as rpp
	m = copy.deepcopy()



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

	indices = list(range(len(hook_lengths)))

	#Sort and return hook_lengths, indices
	hook_lengths, indices = (list(t) for t in zip(*sorted(zip(hook_lengths, indices))))

	hook_lengths.reverse()
	indices.reverse()

	return hook_lengths, indices



#shape is any rpp of the required shape
def lambda_arrays_of_given_shape(shape, n):
	col_lengths = get_col_lengths(shape)

	hook_lengths, indices = get_hook_lengths_list(shape, col_lengths)
	
	m = [0 for i in range(len(hook_lengths))]

	lambda_arrays = []

	_lambda_arrays_of_given_shape_step_(m, n, 0, hook_lengths, lambda_arrays)

	#unsort the hook_lengths
	for i in range(len(lambda_arrays)):
		_, lambda_arrays[i] = (list(t) for t in zip(*sorted(zip(indices, lambda_arrays[i]))))

	reshaped_lambda_arrays = [0 for i in range(len(lambda_arrays))]



	#now each lambda array is in the order we pulled them in (left to right, top to bottom)
	for i in range(len(lambda_arrays)):
		reshaped_lambda_arrays[i] = [shape[j].copy() for j in range(len(shape))]

		index = 0

		for k in range(len(shape[0])):
			for j in range(col_lengths[k]):
				reshaped_lambda_arrays[i][j][k] = lambda_arrays[i][index]
				index += 1

	return reshaped_lambda_arrays



#Find the smallest i with i >= last_index and hook_lengths[i] <= n
def _lambda_arrays_of_given_shape_step_(m, n, last_index, hook_lengths, lambda_arrays):
	#print(m, n, last_index, hook_lengths, lambda_arrays)

	if n == 0:
		lambda_arrays.append(m)
		return

	for i in range(last_index, len(m)):
		if hook_lengths[i] <= n:
			new_m = m.copy()
			new_m[i] += 1
			_lambda_arrays_of_given_shape_step_(new_m, n - hook_lengths[i], i, hook_lengths, lambda_arrays)



#gets all possible shapes for a rpp of n, which amounts to finding integer partitions of n
def get_valid_rpp_shapes(n):
	shapes = []

	for i in range(1, n + 1):
		partitions = Partitions(i)

		for partition in partitions:
			shape = []

			for j in partition:
				shape.append([0 for k in range(j)])

			shapes.append(shape)

	return shapes



def get_rpps(n, shape):
	rpps = []

	start_time = time.perf_counter()
	lambda_arrays = lambda_arrays_of_given_shape(shape, n)
	print(f"Time to get lambda arrays: {time.perf_counter() - start_time}")

	start_time = time.perf_counter()
	for lambda_array in lambda_arrays:
		rpps.append(hillman_grassl_inverse(lambda_array))
	print(f"Time to apply hillman grassl: {time.perf_counter() - start_time}")

	return rpps



shape = [
	[0, 0, 0, 0],
	[0, 0],
	[0]
]

rpps = get_rpps(30, shape)
