function [ arrayFactorLevelParam ] = readFactorLevelParam_01( factorsFilename )

char4comment = '%';

fid = fopen(factorsFilename);

if (fid < 0)
    error('Could not open, or do not exist, the file %s',factorsFilename);    
end;

nLine = 0; nLineComments = 0;
while ( ~feof(fid) )
    % get a line 
    str = fgetl(fid);
    % check if the line is a comment 
    if  ( strcmp(str(1),char4comment))
        % The line is a comment
        nLineComments = nLineComment + 1;
    else
      % The line is not a comment line  
      nLine = nLine + 1;
      numsFromLine = str2num(str);
      for c = 1: numel(numsFromLine)
          arrayFactorLevelParam(nLine,c) = numsFromLine(c);
      end;
    end;

end;

fclose(fid);
fprintf('\nFile %s\n  num lines = %d   nLineComments = %d\n ',factorsFilename,nLine, nLineComments);
  
end

