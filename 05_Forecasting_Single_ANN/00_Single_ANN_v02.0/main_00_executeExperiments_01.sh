#
# This line is a comment
#    call this script as: 
#                            nohup ./main_00_executeExperiments_01.sh > salida_2017_02_22-01.log &
#
# matlab -nodisplay -nodesktop -nosplash -r "try;main_01_ANN4TSF_Call_Several_Experiments_v01;catch;end;quit;" -logfile outputScript_2017_02_22.log

matlab -nodisplay -nodesktop -nosplash -r main_01_ANN4TSF_Call_Several_Experiments_v01.m -logfile outputScript_2017_12_07.log