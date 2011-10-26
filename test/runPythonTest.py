import sys
import numpy as np

#ensure that you take the lib from the build directory!!
#sys.path.insert(0,"../py/lib/") #doesn't have impact on pp, so discarded
import pyPamtra



inputFile="../test/referenceProfile/testProfiles.dat"

t = pyPamtra.pyPamtra()
t.readPamtraProfile(inputFile)

t.set["data_path"]='/home/mech/models/pamtra/data/'
t.set["verbose"]=0
t.set["pyVerbose"]=1

#make artificially less levels for on eprofile!
t.p["nlyrs"][2,0] = 25

#change atrificially one timestamp
t.p["unixtime"][0,0] = 600 #1970-01-01 00:10

testNo = sys.argv[1]

if testNo == "1":


	t.runParallelPamtra([24,90,150],pp_local_workers=2,pp_deltaF=1,pp_deltaX=1)
	
elif testNo == "2":

	t.set["passive"]=False
	t.set["active"]=True
	t.set["EM_snow"]='liudb'
	t.set["isnow_n0"]=0
	t.set["N_0snowDsnow"]=1
	t.set["liu_type"]=4


	t.runPamtra(35)
elif testNo == "3":

	t.set["passive"]=True
	t.set["active"]=False
	t.set["EM_snow"]='liudb'
	t.set["isnow_n0"]=0
	t.set["N_0snowDsnow"]=1
	t.set["liu_type"]=8
	
	t.runPamtra(35)
elif testNo == "4":

	t.set["EM_snow"]='icesf'
	t.set["isnow_n0"]=2
	t.set["EM_grau"]='icesf'
	

	
	t.runPamtra(35)
	t.writeResultsToNetCDF("../test/tmp/pythontest4.nc")
	
else:
	sys.exit("unknown test number "+testNo)
	


if testNo != "4":

	#uncomment if test should be defined again
	#print "warning, rewrting tests!!"
	#t.writeResultsToNumpy("../test/referenceOutput/"+testNo+"/python"+testNo+".pickle")


	reference = pyPamtra.pyPamtra()
	reference.loadResultsFromNumpy("../test/referenceOutput/"+testNo+"/python"+testNo+".pickle")
	#import pdb; pdb.set_trace()
	error = 0
	for key in ["angles","tb","hgt","Ze", "Ze_rr ", "Ze_ci", "Ze_sn", "Ze_gr ", "Ze_ha", "Att_hydro", "Att_cw", "Att_rr", "Att_ci", "Att_sn", "Att_gr", "Att_ha", "Att_atmo"]:
		if np.any(reference.r[key] != t.r[key]):
			error += 1
			print key, "max. difference:", np.max(reference.r[key] - t.r[key])
	if error > 0:
		raise IOError("do not match")
		#else:
			#print key, "OK"

			#for key in self.__dict__.keys():
				#print key,type(self.__dict__[key]),self.__dict__[key]

