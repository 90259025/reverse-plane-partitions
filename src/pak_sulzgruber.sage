import copy
import time



#Returns an array C, where C[j] is the length of column j of rpp.
def get_col_lengths(rpp):
	return [sum([len(row) >= j + 1 for row in rpp]) for j in range(len(rpp[0]))]



def get_hook_length(rpp, col_lengths, box):
	return len(rpp[box[0]]) - box[1] + col_lengths[box[1]] - box[0] - 1



#One hook per entry in the rpp.
def get_rim_hooks(rpp, col_lengths):
	rim_hooks = []

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

			rim_hooks.append(rim_hook)

	return rim_hooks



#Returns (I, O, A, B), where each is a set of contents.
def get_corners(rpp, col_lengths):
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



		if i == col_lengths[j] - 1 and (j == 0 or (col_lengths[j - 1] >= i + 1 and j < len(rpp[0]) - 1 and col_lengths[j + 1] >= i + 1)):
			A.append(content)

		elif j == len(rpp[i]) - 1 and (i == 0 or (len(rpp[i - 1]) >= j + 1 and i < len(rpp) - 1 and len(rpp[i + 1]) >= j + 1)):
			B.append(content)

		#At this point, it must be a corner.
		elif i == col_lengths[j] - 1:
			O.append(content)

		else:
			I.append(content)

	return I, O, A, B



def get_candidates(rpp, col_lengths):
	candidates = []

	for i in range(len(rpp)):
		for j in range(len(rpp[i])):
			#If [i, j] \in O, we need rpp[i][j] > rpp[i][j - 1].
			pass



rpp = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0],
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]

I, O, A, B = get_corners(rpp, get_col_lengths(rpp))

print(I)
print(O)
print(A)
print(B)
