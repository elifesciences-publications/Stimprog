# Stimprog

### This code is associated with the paper "How spatial release from masking may fail to function in a highly directional auditory system". eLife, 2017. 10.7554/eLife.20731

Stimprog Stimulus Presentation and Data Collection Software

Version 5.14b ‘treadmill’

This software requires the following hardware devices:
1.	The highspeed trackball system described in Lott et al. (2007). 
2.	National Instruments acquisition hardware (NI USB-6251).
3.	Tucker-Davis Technologies PA5 Programmable Attenuators.

Start the software by entering ‘stimprog’ in the MATLAB command window. You will be prompted to locate the Excel Spreadsheet calibration file. Use ‘File’> ‘Load Stimulation Set’ to point program to the stimset folder to load sample stimuli. Use ‘Device’ > ‘Nidaq NI USB-6251’ to initiate Nidaq hardware. Use ‘Highspeed Treadmill System’ to initiate the treadmill.
Once this software is initiated, button press on ‘go (single shot)’ for single stimulus presentation. Button press on ‘Save’ to save raw data traces in *.mat format for offline analysis in MATLAB.

References
	Lott, G. K., Rosen, M. J. and Hoy, R. R. (2007). An Inexpensive Sub-Millisecond System for Walking Measurements of Small Animals Based on Optical Computer Mouse Technology. Journal of Neuroscience Methods 161, 55-61.
