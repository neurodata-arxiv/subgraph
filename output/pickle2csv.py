import pickle
import os
import json
import numpy
import collections

basepath = "/home/leo/git/subgraph/output/genotype2"

# curr = "./genotype1_betweenness_centrality.pkl"


fnames = [name for name in os.listdir(basepath)
  if os.path.splitext(name)[1] == '.pkl']
fnames = sorted(fnames)

paths = [os.path.join(basepath, item) for item in fnames]
keys = ["_".join(n.split('.')[0].split('_')[1:]) for n in fnames]

data = {}

for idx, curr in enumerate(paths):
	f = open(curr)
	dat = pickle.load(f)[keys[idx]]
	f.close()
	if isinstance(dat, numpy.ndarray):
			dat = dat.tolist()
	else:
		for i in dat.keys():
			if isinstance(dat[i], numpy.ndarray):
				dat[i] = dat[i].tolist()
			if isinstance(dat[i], collections.OrderedDict):
				for j in dat[i].keys():
					if isinstance(dat[i][j], numpy.ndarray):
						dat[i][j] = dat[i][j].tolist()
			# print type(dat[i])
	data[keys[idx]] = dat

with open("output_data_genotype2.json", 'w') as outfile:
	json.dump(data, outfile)