function errorMsg = saveDataUnivariateTSValue( tsDataF1 , filename)

  errorMsg = '-';
  fId = fopen(filename,'w');
  
  if (fId < 0)
      errorMsg = 'Error opening the file';
      return;
  else    
      
      for i = 1:numel(tsDataF1)
          fprintf(fId,'%10d\n', tsDataF1(i));
      end
      fclose(fId);
  end

end