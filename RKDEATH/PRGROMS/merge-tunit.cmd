@echo off
rem the u12* files must be created in dosbox by the ff8.bat command.
c:\bin\far\srec_cat -o ROM.bin -binary rkff.00 -binary -unsplit 4 0 rkff.01 -binary -unsplit 4 1 rkff.02 -binary -unsplit 4 2 rkff.03 -binary -unsplit 4 3
