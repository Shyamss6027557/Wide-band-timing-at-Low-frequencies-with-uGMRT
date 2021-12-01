Band 3 of uGMRT -- 300-500   MHz\n
Band 4          -- 550-750   MHz\n
Band 5          -- 1060-1460 MHz\n
J2145-0750, J1640+2224, and J1713-0747 are bright very MSP's with stable period, period dot values. We've observed these pulsars in Band 3, Band 5 of uGMRT. 
J1646-2142 is a GMRT discovered MSP with strange features which can be seen in it's profile (as a function of frequency). GMRT discovered pulsars are observed in Band 3 and Band 4. Most of the GMRT discovered MSP's are not visible in Band 5 due to their steep spectral indices ~2.\n
As a sample I've attached Band 3 jupyter notebooks for J2145-0750, J1640+2224, and J1713-0747 + Band 5 notebook for J2145-0750 + Band 3 and Band 4 notebooks for J1646-2142.\n
All notebooks require folded data cube in PSRCHIVE FITS format. \n
Initial guess for aligning, in each notebook, is provided as the highest SNR data among the set of epochs.\n
Details about the wide-band timing software "Pulse Portraiture" are available at https://github.com/pennucci/PulsePortraiture. \n
