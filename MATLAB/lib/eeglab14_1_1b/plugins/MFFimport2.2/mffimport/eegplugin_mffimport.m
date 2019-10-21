function ver = eegplugin_mffimport(fig, trystrs, catchstrs)

ver = 'mffimport2.2';
if nargin < 3
    error('eegplugin_mffimport requires 3 arguments');
end;

% find import data menu
% ---------------------
menu = findobj(fig, 'tag', 'import data');

% menu callbacks
% --------------
comcnt = [ trystrs.no_check 'EEG = pop_readegimff();'     catchstrs.new_and_hist ];

% create menus
% ------------
uimenu( menu, 'label', 'From EGI Net Station .MFF file', 'callback', comcnt, 'position', 3 );


% put MFF jar into static java class path
% ------------
userdir = strtok(userpath,pathsep);
javaclasspathfile = sprintf('%s%sjavaclasspath.txt',userdir,filesep);
mffjarfile = sprintf('%s%sMFF-1.2.jar',fileparts(mfilename('fullpath')),filesep);

if all(cellfun(@isempty,strfind(javaclasspath('-all'),mffjarfile)))
    fid = fopen(javaclasspathfile,'a');
    if fid == -1
        error('Could not open %s for writing.',javaclasspath);
    end
    
    fprintf(fid,'\n%s',mffjarfile);
    fclose(fid);
    
    fprintf('\nMFFimport: added MFF jar file to static javaclasspath.\n');
    fprintf('MFFimport: MATLAB needs to be restarted for changes to take effect.\n');
    fprintf('\nMFFimport: press ENTER to exit and restart MATLAB.\n');
    pause;
    exit
end
