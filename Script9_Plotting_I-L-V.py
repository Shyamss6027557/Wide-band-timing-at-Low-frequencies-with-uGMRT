import matplotlib.pyplot as plt
import numpy as np
import matplotlib.ticker as ticker
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from mpl_toolkits.axes_grid1.inset_locator import mark_inset

fil1=open('Dedisp_I_FT_folded.txt', 'r')    # Folded I n_channels
fil2=open('Raw_Dedisp_L_FT_folded.txt', 'r') # Folded linear - uncalibrated n_channels
fil3=open('Calibrated_Dedisp_L_FT_folded.txt', 'r') # Folded Calibrated linear n_channels
fil4=open('Dedisp_V_FT_folded.txt', 'r')  # Folded V n_channels
fil5=open('Calibrated_Position_angle.txt', 'r') # Position angle of calibrated profile n_channels
n_bin=64
I_p=np.zeros(n_bin)
Q_p=np.zeros(n_bin)
U_p=np.zeros(n_bin)
V_p=np.zeros(n_bin)
L_p=np.zeros(n_bin)
Position_angle=np.zeros(n_bin)
serial=np.arange(n_bin)
i=0
for line in fil1:
	I_p[i]=float(line.split()[0])
	i=i+1
i=0
for line in fil2:
        Q_p[i]=float(line.split()[0])
        i=i+1
i=0
for line in fil3:
        U_p[i]=float(line.split()[0])
        i=i+1
i=0
for line in fil4:
        V_p[i]=float(line.split()[0])
        i=i+1
i=0
for line in fil5:
        Position_angle[i]=float(line.split()[0])
        i=i+1

fil1.close()
fil2.close()
fil3.close()
fil4.close()
fil5.close()
I_median=np.median(I_p)
Q_median=np.median(Q_p)
U_median=np.median(U_p)
V_median=np.median(V_p)

for i in range(n_bin):
	I_p[i]=I_p[i]-I_median
        Q_p[i]=Q_p[i]-Q_median
        U_p[i]=U_p[i]-U_median
        V_p[i]=V_p[i]-V_median
I_max=np.max(I_p)
for i in range(n_bin):
        I_p[i]=I_p[i]/I_max
        Q_p[i]=Q_p[i]/I_max
        U_p[i]=U_p[i]/I_max
        V_p[i]=V_p[i]/I_max
	L_p[i]=np.sqrt((Q_p[i])**2+(U_p[i])**2)
#plt.plot(serial+1, I_p, label='I')
#plt.plot(serial+1, L_p, label='Uncalibrated L')
plt.plot(serial+1, Q_p, label='uncalibrated linear')
plt.plot(serial+1, U_p, label='calibrated linear')
#plt.plot(serial+1, V_p, label='V')

plt.legend()
#plt.ylim(-0.15,1.05)
plt.xlim(1,n_bin)
plt.show()

fig, axs=plt.subplots(nrows=2, ncols=1, sharex=True, sharey=False, figsize=(15, 9),gridspec_kw={'height_ratios': [2, 1]})
#fig.suptitle('B1929+10', fontsize=25)
fig.text(0.55, 0.04, r'$n_{bin}$', ha='center', fontsize=25)
fig.text(0.02, 0.25, r'$\psi\,(degrees)$', va='center', rotation='vertical', fontsize=25)
plt.subplots_adjust(left=0.1, bottom =0.124, right=0.963, top=0.97, wspace=0, hspace=0)
ax=axs[0]
ax.plot(serial+1, I_p, label='I')
#plt.plot(serial+1, L_p, label='Uncalibrated L')
#plt.plot(serial+1, Q_p, label='uncalibrated linear')
ax.plot(serial+1, U_p, label='L')
ax.plot(serial+1, V_p, label='V')

ax.legend(fontsize=18)
#ax.set_ylim(-0.22,1.02)
ax.set_xlim(1,n_bin)
ax.yaxis.set_major_locator(ticker.MultipleLocator(0.25))
ax.yaxis.set_minor_locator(ticker.MultipleLocator(0.05))
plt.setp(ax.get_yticklabels(), fontsize=22)
ax.axhline(y=0.0, color='black', linestyle= 'dotted')
ax=axs[1]
ax.plot(serial+1, Position_angle, 'o',markersize=3)
ax.xaxis.set_major_locator(ticker.MultipleLocator(100))
ax.xaxis.set_minor_locator(ticker.MultipleLocator(10))
ax.yaxis.set_major_locator(ticker.MultipleLocator(45))
ax.yaxis.set_minor_locator(ticker.MultipleLocator(4.5))
ax.set_ylim(-95,95)
plt.setp(ax.get_xticklabels(), fontsize=22)
plt.setp(ax.get_yticklabels(), fontsize=22)
ax.axhline(y=0.0, color='black', linestyle= 'dotted')

plt.show()







