@echo off
rem This will split the 1MB rom into two parts so we can shove it into NBA Jam driver
rem
rem UJ12 odd
c:\bin\far\srec_cat ROM.bin -binary -split 2 0 -o l3_nba_jam_game_rom_uj12.uj12 -binary
rem UG12 even
c:\bin\far\srec_cat ROM.bin -binary -split 2 1 -o l3_nba_jam_game_rom_ug12.ug12 -binary
