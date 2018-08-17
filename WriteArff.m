function WriteArff(name, data)
% covert data into arff file for weka 
farff=fopen(name,'w');

fprintf(farff, '%s\n', '@RELATION feature');
fprintf(farff, '%s\n', '');
fprintf(farff, '%s\n', '@ATTRIBUTE hr REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE mean REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE median REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE qd REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE prct20 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE prct80 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE vari REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE rmssd REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE sdsd REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE nn50 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE pnn50 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE nn20 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE pnn20 REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE lb REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE mb REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE hb REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE lbhb REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE sdann REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE lf REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE hf REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE lfhf REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE br REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE brnorm REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE minv REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE minvnorm REAL');
fprintf(farff, '%s\n', '@ATTRIBUTE class {0,1}');
fprintf(farff, '%s\n', '');
fprintf(farff, '%s\n', '@DATA');

fclose(farff);

dlmwrite(name,data,'-append');

end