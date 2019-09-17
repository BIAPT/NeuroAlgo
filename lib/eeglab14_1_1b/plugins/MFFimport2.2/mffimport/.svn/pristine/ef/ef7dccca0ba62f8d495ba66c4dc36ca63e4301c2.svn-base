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

