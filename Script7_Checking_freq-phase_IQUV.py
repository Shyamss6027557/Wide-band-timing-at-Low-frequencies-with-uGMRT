import numpy as np
import matplotlib.pyplot as plt

fil1=open('raw_dedisp_I_sub-band_folded.plot', 'r')
fil2=open('raw_dedisp_I_sub-int_folded.plot', 'r')
fil3=open('raw_dedisp_I_FT_folded.plot', 'r')
n_chan=1
n_bins=519
n_parts=1848
subint_min=70000000
subint_max=80000000
chan_min=-1
chan_max=10000
serial_chan=np.arange(n_chan)
serial_bins=np.arange(n_bins)
serial_subint=np.arange(n_parts)
array = [[0 for i in range(n_bins)] for j in range(n_chan)]
subint_array = [[0 for i in range(n_bins)] for j in range(n_parts)]
array_chan_averaged =[0 for i in range(n_bins)]
median_array_chan=np.zeros(n_chan)
median_array_subint=np.zeros(n_parts)
mean_profile_array=np.zeros(n_bins)
mean_profile_array_subint=np.zeros(n_bins)
Folded_prof=np.zeros(n_bins)

i=0
for line in fil1:
	for j in range(n_chan):
		array[j][i]=float(line.split()[j])
	i=i+1
i=0
for line in fil2:
        for j in range(n_parts):
                subint_array[j][i]=float(line.split()[j])
        i=i+1
i=0
for line in fil3:
	Folded_prof[i]=float(line.split()[0])
	i=i+1

median_array_chan=np.median(array, axis=1)
median_array_subint=np.median(subint_array, axis=1)
mean_profile_array=np.mean(array, axis=0)
median_mean_profile=np.median(mean_profile_array)
mean_profile_array_subint=np.mean(subint_array, axis=0)
median_mean_profile_subint=np.median(mean_profile_array_subint)
median_Folded_prof=np.median(Folded_prof)
for i in range(n_bins):
	for j in range(n_chan):
		array[j][i]=array[j][i]-median_array_chan[j]
		if j<chan_min or j>chan_max:
			array[j][i]=0
arr=np.array(array)
for i in range(n_bins):
        for j in range(n_parts):
                subint_array[j][i]=subint_array[j][i]-median_array_subint[j]
		if j<subint_min and j>subint_max:
                        subint_array[j][i]=0

arr_subint=np.array(subint_array)
max_subint1=np.max(arr_subint, axis=1)
for i in range(n_bins):
        for j in range(n_parts):
                subint_array[j][i]=subint_array[j][i]/max_subint1[j]


for i in range(n_bins):
	mean_profile_array[i]=mean_profile_array[i]-median_mean_profile
	mean_profile_array_subint[i]=mean_profile_array_subint[i]-median_mean_profile_subint
	Folded_prof[i]=Folded_prof[i]-median_Folded_prof
max_mean_profile_array=np.max(mean_profile_array)
max_mean_profile_array_subint=np.max(mean_profile_array_subint)
max_Folded_prof=np.max(Folded_prof)
for i in range(n_bins):
	mean_profile_array[i]=mean_profile_array[i]/max_mean_profile_array
        mean_profile_array_subint[i]=mean_profile_array_subint[i]/max_mean_profile_array_subint
        Folded_prof[i]=Folded_prof[i]/max_Folded_prof
	print  mean_profile_array_subint[i]
a1=[x + n_bins for x in serial_bins]
a1=np.concatenate((serial_bins, a1))
a2=np.concatenate((mean_profile_array_subint, mean_profile_array_subint))

fig=plt.figure(figsize=(15,12))
plt.subplots_adjust(left=0.12, bottom =0.1, right=0.99, top=0.95, wspace=0.2, hspace=0.0)

ax = fig.add_subplot(3,2,1)   #two row, three column, combine cell 1 and 2
#ax.plot(serial_bins, mean_profile_array, color='blue',label='subband-averaged')
#ax.plot(serial_bins, mean_profile_array_subint, color='black', label='subint-averaged')
#ax.plot(serial_bins, Folded_prof, color='yellowgreen', label='Folded prof')
ax.plot(a1, a2, color='blue',label='subband-averaged')

ax.tick_params(axis='x', labelsize=25)
ax.tick_params(axis='y', labelsize=25)

ax.tick_params(left = False, labelleft = False , labelbottom = False, bottom = False)
#ax.set_xlim(0,n_bins)
ax.set_ylim(top=1.1)
#ax.legend(loc='upper left',fontsize=18)
#ax.set_xlim(0,n_bins)



ax = fig.add_subplot(3,2,(3,5))
ax.pcolormesh(arr_subint, cmap='gist_heat') #plotting Intensity as a function of bins and channels as colourmap. This plot will show nu^2 variation of time of arrivals of different frequency signals due of ISM.
ax.tick_params(axis='x', labelsize=25)
ax.tick_params(axis='y', labelsize=25)

ax.set_ylim(0,n_parts)
ax.set_xlim(0,n_bins)
ax.set_xlabel('Phase Bins' , fontsize=25, ha='center')
ax.set_ylabel('Sub-integrations', fontsize=25, va='center', rotation='vertical')

ax = fig.add_subplot(2,2,(2,4))
ax.pcolormesh(arr, cmap='gist_heat') #plotting Intensity as a function of bins and channels as colourmap. This plot will show nu^2 variation of time of arrivals of different frequency signals due of ISM.
ax.tick_params(axis='x', labelsize=25)
ax.tick_params(axis='y', labelsize=25)
ax.set_ylim(0,n_chan)
ax.set_xlim(0,n_bins)
ax.set_xlabel('Phase Bins' , fontsize=25, ha='center')
ax.set_ylabel('Channels', fontsize=25, va='center', rotation='vertical')



plt.show()

