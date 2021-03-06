import pyPamtra
import pyPamtraLibWrapper
import pyPamtraImport
from copy import deepcopy

plt.figure()

pam = pyPamtra.pyPamtra()
#!name       as_ratio    liq_ice     rho_ms    a_ms    b_ms    alpha    beta   moment_in   nbin      dist_name        p_1     p_2     p_3     p_4     d_1       d_2           scat_name   vel_size_mod           canting
pam.df.addHydrometeor(('ice', 1.0, -1, 917,917 *  pi / 6., 3, pi/4., 2, 0, 10, 'exp', 3000, 3e8, -99.0, -99.0, 100e-6,  1000e-6, 'tmatrix', 'heymsfield10_particles',0.0))

pam = pyPamtraImport.createUsStandardProfile(pam,hgt_lev=np.arange(1000,1300,200))
pam.p["airturb"][:] = 0.2
freqs = [35.5]#,80,150]

pam.set["verbose"] = 0
pam.set["pyVerbose"] =0
pam.nmlSet["data_path"] = "/work/mmaahn/pamtra_data/"
pam.nmlSet["randomseed"] = 0
pam.nmlSet["radar_mode"] = "spectrum"
pam.nmlSet["radar_aliasing_nyquist_interv"] = 3
pam.p["hydro_q"][:] = 0.002

pam.runPamtra(freqs,checkData=False)
plt.plot(pam.r["radar_vel"],pam.r["radar_spectra"][0,0,0,0,0])

pamFS = pyPamtra.pyPamtra()
#!name       as_ratio    liq_ice     rho_ms    a_ms    b_ms    alpha    beta   moment_in   nbin      dist_name        p_1     p_2     p_3     p_4     d_1       d_2           scat_name   vel_size_mod           canting
pamFS.df.addHydrometeor(('ice', 1.0, -1, 917,917 *  pi / 6., 3, pi/4., 2, 0, 10, 'exp', 3000, 3e8, -99.0, -99.0, 100e-6,  1000e-6, 'tmatrix', 'heymsfield10_particles',0.0))

pamFS = pyPamtraImport.createUsStandardProfile(pamFS,hgt_lev=np.arange(1000,1300,200))
pamFS.p["airturb"][:] = 0.2
pamFS.set["verbose"] = 0
pamFS.set["pyVerbose"] =0
pamFS.nmlSet["data_path"] = "/work/mmaahn/pamtra_data/"
pamFS.nmlSet["randomseed"] = 0
pamFS.nmlSet["radar_mode"] = "spectrum"
pamFS.nmlSet["radar_aliasing_nyquist_interv"] = 3
pamFS.p["hydro_q"][:] = 0.002

pamFS.nmlSet["randomseed"] = 0

pamFS.nmlSet["hydro_fullspec"] = True
pamFS.df.addFullSpectra()

pamFS.df.dataFullSpec["d_bound_ds"][0,0,0,0,:] = np.linspace(100e-6,1000e-6,11)
pamFS.df.dataFullSpec["d_ds"][0,0,0,0,:] = pamFS.df.dataFullSpec["d_bound_ds"][0,0,0,0,:-1] + 0.5 * np.diff(pamFS.df.dataFullSpec["d_bound_ds"][0,0,0,0,:])
pamFS.df.dataFullSpec["rho_ds"][0,0,0,0,:] = 917
pamFS.df.dataFullSpec["n_ds"][0,0,0,0,:] = 3e8 * np.exp(-3000 * pamFS.df.dataFullSpec["d_ds"][0,0,0,0,:]) *np.diff(pamFS.df.dataFullSpec["d_bound_ds"][0,0,0,0,:])
pamFS.df.dataFullSpec["area_ds"][0,0,0,0,:] = pi/4. *  pamFS.df.dataFullSpec["d_ds"][0,0,0,0,:] ** 2
pamFS.df.dataFullSpec["mass_ds"][0,0,0,0,:] =pi / 6. *917 *  pamFS.df.dataFullSpec["d_ds"][0,0,0,0,:] ** 3

pamFS.df.dataFullSpec["as_ratio"][0,0,0,0,:] = 1.0



pamFS.runPamtra(freqs,checkData=False)

#plt.plot(pam.r["radar_vel"],pam.r["radar_spectra"][0,0,0,0])
plt.plot(pamFS.r["radar_vel"],pamFS.r["radar_spectra"][0,0,0,0,0])


