#!/usr/bin/env python
# coding: utf-8

# In[1]:


metafile="J2145-0750_C.meta"

import ppalign as ppa
import numpy as np




# In[2]:


outfile = "J2145-0750chnavgport.port"
ppa.align_archives(metafile=metafile, initial_guess="300_coherent_GWB/J2145-0750_500_200_512_2.31may2k21.raw0.new_freq.128_PSR_2145-0750.FITS16",
                   tscrunch=True, pscrunch=True, SNR_cutoff=0.0, outfile=outfile, niter=1, quiet=False)

# Initial guess is an initial guess for an average portrait. I used the highest SNR profile for this.
# In this case, J1646-2142f64avgport.port is the average portrait created from the data files listed in the
# metafile. "f64" denotes that the files have been scrunched to have 64 frequency channels

# It is important to note that bad channels zeroed in the GMRT data processing pipeline must be fully zapped
# before being run through this notebook. I created a very simple shell script to do this and f scrunch to 
# a given number of frequency channels. I have only had total functionality with 64 channels. Input files also
# must be in FITS format. The shell script requires PSRCHIVE tools to work.




# In[3]:


import ppspline as pps
avgport = outfile
dp = pps.DataPortrait(avgport)
dp.normalize_portrait("prof")

# This initializes the portrait be modeled by the spline model later. It is normalized 
# by the average portrait created earlier, so as to clearly model any frequency-dependent
# profile evolution.


# In[4]:


dp.show_data_portrait()


# In[5]:


# Mainly set to defaults. SNR cutoffs removed
smooth = True
rchi2_tol = 0.1 #What is this factor
k = 5
sfac = 1.0
max_nbreak = 2

# Setting default arguments for the make_spline_model() seen below. It is important to set
# max_nbreak = None. Otherwise, the spline model will have many breakpoints and not accurately
# model the profile evolution.
dp.make_spline_model(smooth=smooth, rchi2_tol=rchi2_tol, k=k, sfac=sfac,
                    max_nbreak=max_nbreak, model_name=None, quiet=False, snr_cutoff=25.0)
# Creation of spline model. snr_cutoff is default to 150 but tweaking may be needed to
# get 1 - 2 "significant" eigenprofiles. Somewhat arbitrary.


# In[6]:


dp.show_eigenprofiles(show_snrs=True)
# Showing average profile and eigenprofile(s)


# In[7]:


dp.show_spline_curve_projections()
# Shows a projection of how the eigenprofile(s) changes according to frequency and to each other.


# In[8]:


J2145_fit_modelfile = "J2145-0750_splinefit.spl"
dp.write_model(J2145_fit_modelfile, quiet=False)

# Writes spline model to a file.


# In[9]:


import pptoas as ppt
from pplib import write_TOAs
toaprogmeta = "J2145-0750_C.meta"
gt = ppt.GetTOAs(toaprogmeta, J2145_fit_modelfile)
gt.get_TOAs(bary=True,show_plot=True)


# In[10]:


# TOAs produced. Can see number of TOAs produced per epoch as well as median TOA error for
# each epoch.
#gt.show_fit(datafile=None, isub=0)  # datafile=None will just select the first datafile from the metafile
timfile = "11OctSep2k21_WB_C_J2145-0750_2eigenvector.tim"
write_TOAs(gt.TOA_list, SNR_cutoff=0.0, outfile=timfile, append=False)

# Writing of TOAs to tim file. Writes in TEMPO format. Can copy paste "freq MJD uncert"
# information into another tim file.


# In[11]:


fil = open('11OctSep2k21_WB_C_J2145-0750_2eigenvector.tim', 'r')
for line in fil:
    print(line)

