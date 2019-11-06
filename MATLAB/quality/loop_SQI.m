
lis= dir('G:/biomusic_MSC/data/time_clean/cleaned/*.csv');
for i= 1:length(lis)
    clf;
    temp=strcat('G:/biomusic_MSC/data/time_clean/cleaned/' , lis(i).name);
    [bvp, sc, tmp, textHeader, output_data ]=comp_SQI_3(temp);
    disp(temp)
    fig_t=strcat(temp, '.fig');
    
    
    if (bvp>= 0.55 && sc>=0.60 && tmp>=0.7)
        fig_temp= ['cleaned/good/' lis(i).name, '.fig'];
        savefig(fig_temp)
        
        %write header to file
        fid = fopen(['cleaned/good/' lis(i).name(1:end-4) '_sqi.csv'],'w'); 
        fprintf(fid,'%s\n',textHeader);
        fclose(fid);

        %write data to end of file
        dlmwrite(['cleaned/good/' lis(i).name(1:end-4) '_sqi.csv'], output_data,'-append');
    else
        fig_temp= ['cleaned/bad/' lis(i).name, '.fig'];
        savefig(fig_temp)
        
        %write header to file
        fid = fopen(['cleaned/bad/' lis(i).name(1:end-4) '_sqi.csv'],'w'); 
        fprintf(fid,'%s\n',textHeader);
        fclose(fid);

        %write data to end of file
        dlmwrite(['cleaned/bad/' lis(i).name(1:end-4) '_sqi.csv'], output_data,'-append');
        
    end
end
