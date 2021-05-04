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



rpp = [
	[0, 0, 0, 0],
	[0, 0, 0],
	[0]
]

rim_hooks = get_rim_hooks(rpp, get_col_lengths(rpp))

for rim_hook in rim_hooks:
	print(rim_hook)
