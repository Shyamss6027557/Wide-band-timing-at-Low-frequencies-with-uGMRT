import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import pandas as pd
from scipy import stats
from numpy.polynomial.polynomial import polyfit

fil1=open('raw_dedisp_Q_128chan_folded.txt', 'r') # Q file
fil2=open('raw_dedisp_U_128chan_folded.txt', 'r') # U file
fil_I=open('raw_dedisp_I_128chan_folded.txt', 'r') # I file
fil_V=open('raw_dedisp_V_128chan_folded.txt', 'r') # V file

n_chan=128
n_bins=64
rotation_cut_off=150
sigma_for_fitting=5
chan_min=20
chan_max=110
Q_array = [[0 for i in range(n_bins)] for j in range(n_chan)]
U_array = [[0 for i in range(n_bins)] for j in range(n_chan)]
I_array = [[0 for i in range(n_bins)] for j in range(n_chan)]
V_array = [[0 for i in range(n_bins)] for j in range(n_chan)]

rotated_Q_array = [[0 for i in range(n_chan)] for j in range(n_bins)]
rotated_U_array = [[0 for i in range(n_chan)] for j in range(n_bins)]
I_chan_averaged =[0 for i in range(n_bins)]
V_chan_averaged =[0 for i in range(n_bins)]
Q_chan_averaged1=[0 for i in range(n_bins)]
U_chan_averaged1=[0 for i in range(n_bins)]
Q_chan_averaged2=[0 for i in range(n_bins)]
U_chan_averaged2=[0 for i in range(n_bins)]
raw_linear_1D=[0 for i in range(n_bins)]
calibrated_linear_1D=[0 for i in range(n_bins)]

mean_Q_array=np.zeros(n_bins)
mean_U_array=np.zeros(n_bins)
angle=np.zeros(n_chan)
position_angle=np.zeros(n_bins)
shifted_angle=np.zeros(n_chan)
serial_bins=np.arange(n_bins)
serial_chans=np.arange(n_chan)
i=0
for line in fil1:
	for j in range(n_chan):
		Q_array[j][i]=float(line.split()[j])
	i=i+1
i=0
for line in fil2:
        for j in range(n_chan):
                U_array[j][i]=float(line.split()[j])
        i=i+1
i=0
for line in fil_I:
        for j in range(n_chan):
                I_array[j][i]=float(line.split()[j])
        i=i+1
i=0
for line in fil_V:
        for j in range(n_chan):
                V_array[j][i]=float(line.split()[j])
        i=i+1


mean_Q_array=np.mean(Q_array, axis=0)
mean_U_array=np.mean(U_array, axis=0)
selected_bin=np.argmax(mean_Q_array)
print('selected_bin', selected_bin)
plt.plot(serial_bins, mean_Q_array)
plt.plot(serial_bins, mean_U_array)
plt.show()

for j in range(n_chan):
	if U_array[j][selected_bin]==0 or Q_array[j][selected_bin]==0 :
		angle[j]=0
	else:
		angle[j]=0.5*np.arctan2(Q_array[j][selected_bin],U_array[j][selected_bin])*180/np.pi
plt.plot(serial_chans, angle, 'o', markersize=2)
plt.show()
shift=0
rotation_cut_off=170 # in degrees
for j in range(n_chan):
	if j > 0 and j < n_chan-1:
		if angle[j-1]-angle[j] > rotation_cut_off:
			if angle[j+1]-angle[j]<180-rotation_cut_off:
				shift=shift+180
				shifted_angle[j]=angle[j]+shift
		else:
			shifted_angle[j]=angle[j]+shift
	else:
		shifted_angle[j]=angle[j]+shift	

plt.plot(serial_chans, shifted_angle, 'o', markersize=2)
plt.show()

df = pd.DataFrame(zip(shifted_angle, serial_chans))
df = df[(np.abs(stats.zscore(df)) < sigma_for_fitting).all(axis=1)]
b, m = polyfit(df[1], df[0], 1)
plt.plot(df[1], df[0], 'o', markersize=2)
plt.plot(df[1], m*df[1] + b, 'r')
plt.legend()
plt.show()

plt.plot(serial_chans, shifted_angle, 'o', markersize=2)
plt.plot(serial_chans, m*serial_chans+b)
plt.show()


for j in range(n_chan):
	for i in range(n_bins):
            	rotated_Q_array[i][j]=Q_array[j][i]*np.cos(2*(m*j+b)*np.pi/180.0)-U_array[j][i]*np.sin(2*(m*j+b)*np.pi/180.0)
		rotated_U_array[i][j]=Q_array[j][i]*np.sin(2*(m*j+b)*np.pi/180.0)+U_array[j][i]*np.cos(2*(m*j+b)*np.pi/180.0)

fil3=open('Calibrated_dedisp_Q_128chan_folded.txt', 'w')
fil4=open('Calibrated_dedisp_U_128chan_folded.txt', 'w')
for i in range(n_bins):
	fil3.write(' '.join(map(str, rotated_Q_array[i])))
	fil3.write("\n")
        fil4.write(' '.join(map(str, rotated_U_array[i])))
        fil4.write("\n")
fil3.close()
fil4.close()

for i in range(n_bins):
	for j in range(n_chan):
		if j<chan_min or j>chan_max:
			I_array[j][i]=0
			V_array[j][i]=0
			Q_array[j][i]=0
			U_array[j][i]=0
			rotated_Q_array[i][j]=0
			rotated_U_array[i][j]=0
		I_chan_averaged[i]=I_chan_averaged[i]+I_array[j][i]
		V_chan_averaged[i]=V_chan_averaged[i]+V_array[j][i]
		Q_chan_averaged1[i]=Q_chan_averaged1[i]+Q_array[j][i]
		U_chan_averaged1[i]=U_chan_averaged1[i]+U_array[j][i]
                Q_chan_averaged2[i]=Q_chan_averaged2[i]+rotated_Q_array[i][j]
                U_chan_averaged2[i]=U_chan_averaged2[i]+rotated_U_array[i][j]
median_I_chan_averaged=np.median(I_chan_averaged)
median_V_chan_averaged=np.median(V_chan_averaged)
median_Q_chan_averaged1=np.median(Q_chan_averaged1)
median_U_chan_averaged1=np.median(U_chan_averaged1)
median_Q_chan_averaged2=np.median(Q_chan_averaged2)
median_U_chan_averaged2=np.median(U_chan_averaged2)
for i in range(n_bins):
	I_chan_averaged[i]=I_chan_averaged[i]-median_I_chan_averaged
	V_chan_averaged[i]=V_chan_averaged[i]-median_V_chan_averaged
	Q_chan_averaged1[i]=Q_chan_averaged1[i]-median_Q_chan_averaged1
        U_chan_averaged1[i]=U_chan_averaged1[i]-median_U_chan_averaged1
        Q_chan_averaged2[i]=Q_chan_averaged2[i]-median_Q_chan_averaged2
        U_chan_averaged2[i]=U_chan_averaged2[i]-median_U_chan_averaged2

fil_I_w=open('Dedisp_I_FT_folded.txt', 'w')
fil_V_w=open('Dedisp_V_FT_folded.txt', 'w')
fil_I_w.write('\n'.join(map(str, I_chan_averaged)))
fil_V_w.write('\n'.join(map(str, V_chan_averaged)))
fil_I_w.close()
fil_V_w.close()
	
for j in range(n_bins):
	raw_linear_1D[j]=np.sqrt((Q_chan_averaged1[j])**2+(U_chan_averaged1[j])**2)
        calibrated_linear_1D[j]=np.sqrt((Q_chan_averaged2[j])**2+(U_chan_averaged2[j])**2)

        if Q_chan_averaged2[j]==0 or U_chan_averaged2[j]==0 :
                position_angle[j]=0
        else:
                position_angle[j]=0.5*np.arctan2(Q_chan_averaged2[j],U_chan_averaged2[j])*180/np.pi
fil5=open('Raw_Dedisp_L_FT_folded.txt', 'w')
fil6=open('Calibrated_Dedisp_L_FT_folded.txt', 'w')
fil7=open('Calibrated_Position_angle.txt', 'w')

fil5.write('\n'.join(map(str, raw_linear_1D)))
fil6.write('\n'.join(map(str, calibrated_linear_1D)))
fil7.write('\n'.join(map(str, position_angle)))

fil5.close()
fil6.close()
fil7.close()

plt.plot(serial_bins, position_angle, 'o', markersize=2)
plt.show()

