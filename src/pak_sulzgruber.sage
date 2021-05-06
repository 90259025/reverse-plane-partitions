import copy
import time



def print_rpp(rpp):
	for row in rpp:
		for entry in row:
			print(entry, end=" ")

		print("")



#Returns an array C, where C[j] is the length of column j of rpp.
def get_col_lengths(rpp):
	return [sum([len(row) >= j + 1 for row in rpp]) for j in range(len(rpp[0]))]



def get_hook_length(rpp, col_lengths, box):
	return len(rpp[box[0]]) - box[1] + col_lengths[box[1]] - box[0] - 1



#One hook per entry in the rpp.
def get_rim_hooks(rpp, col_lengths):
	rim_hooks = copy.deepcopy(rpp)

	for i in range(len(rpp)):
		for j in range(len(rpp[i])):
			rim_hook = []

			#The current column.
			current_j = j

			#The current row.
			for k in range(col_lengths[j] - 1, i - 1, -1):
				#Add all possible entries.
				next_j = len(rpp[k]) - 1

				rim_hook += [[k, l] for l in range(current_j, next_j + 1)]

				current_j = next_j

			rim_hooks[i][j] = rim_hook

	return rim_hooks



#Returns (I, O, A, B), where each is a set of contents.
def get_IOAB(rpp, col_lengths):
	I = []
	O = []
	A = []
	B = []

	max_content = len(rpp[0]) - 1
	min_content = -(col_lengths[0] - 1)

	for content in range(min_content, max_content + 1):
		i = 0
		j = 0

		if content > 0:
			j = content

		elif content < 0:
			i = -content

		while i + 1 < len(rpp) and j + 1 < len(rpp[i + 1]):
			i += 1
			j += 1



		if j == len(rpp[i]) - 1 and i == col_lengths[j] - 1:
			O.append(content)

		elif j < len(rpp[i]) - 1 and i < col_lengths[j] - 1 and (i == len(rpp) - 1 or j == len(rpp[i + 1]) - 1):
			I.append(content)

		elif i == col_lengths[j] - 1 and (j == 0 or (col_lengths[j - 1] >= i + 1 and j < len(rpp[0]) - 1 and col_lengths[j + 1] >= i + 1)):
			A.append(content)

		elif j == len(rpp[i]) - 1 and (i == 0 or (len(rpp[i - 1]) >= j + 1 and i < len(rpp) - 1 and len(rpp[i + 1]) >= j + 1)):
			B.append(content)

	return I, O, A, B



def get_candidates(rpp, col_lengths, O, A):
	candidates = []

	for i in range(len(rpp)):
		for j in range(len(rpp[i])):
			if j - i in O and ((j == 0 and rpp[i][j] > 0) or (j != 0 and rpp[i][j - 1] < rpp[i][j])) or (j - i in A and ((j == 0 and rpp[i][j] > 0) or (j != 0 and rpp[i][j - 1] < rpp[i][j])) and ((i == 0 and rpp[i][j] > 0) or (i != 0 and rpp[i - 1][j] < rpp[i][j]))):
				candidates.append([i, j])

	return candidates



def get_compatible_path(rpp, col_lengths, candidate):
	path = []

	i = candidate[0]
	j = candidate[1]

	I, O, A, B = get_IOAB(rpp, col_lengths)

	while True:
		path.append([i, j])

		if (j - i in I or j - i in A) and j < len(rpp[i]) - 1:
			j += 1

		elif (j - i in O or j - i in B) and i != 0 and rpp[i - 1][j] == rpp[i][j]:
			i -= 1

		elif j < len(rpp[i]) - 1 and (i == 0 or rpp[i - 1][j] < rpp[i][j]):
			j += 1

		else:
			break

	return path



def get_factor_entry_from_compatible_path(rpp, col_lengths, path):
	path_length = len(path)
	i = path[-1][0]
	j = path[-1][1]

	start_i = i

	for k in range(path_length - 1):
		if i < col_lengths[j] - 1:
			i += 1

		else:
			j -= 1

	return [start_i, j]



def sulzgruber_inverse(input_rpp):
	rpp = copy.deepcopy(input_rpp)
	lambda_array = copy.deepcopy(input_rpp)

	for i in range(len(lambda_array)):
		for j in range(len(lambda_array[i])):
			lambda_array[i][j] = 0

	col_lengths = get_col_lengths(rpp)

	I, O, A, B = get_IOAB(rpp, col_lengths)

	while True:
		candidates = get_candidates(rpp, col_lengths, O, A)
		#Iterate over candidates in reverse content order.
		min_candidate = candidates[0]

		for candidate in candidates:
			if candidate[1] - candidate[0] > min_candidate[1] - min_candidate[0] or (candidate[1] - candidate[0] == min_candidate[1] - min_candidate[0] and candidate[0] > min_candidate[0]):
				min_candidate = candidate

		#Find the compatible path corresponding to this candidate and decrement rpp by it
		compatible_path = get_compatible_path(rpp, col_lengths, min_candidate)

		entry = get_factor_entry_from_compatible_path(rpp, col_lengths, compatible_path)

		lambda_array[entry[0]][entry[1]] += 1

		for box in compatible_path:
			rpp[box[0]][box[1]] -= 1

		if sum([sum(row) for row in rpp]) == 0:
			break

	return lambda_array


rpp = [
	[1, 1, 4],
	[2, 3, 4],
	[4, 4, 4]
]

print_rpp(sulzgruber_inverse(rpp))
