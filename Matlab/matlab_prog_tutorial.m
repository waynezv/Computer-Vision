echo off
clear all
home;
echo on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Programming in Matlab  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%% Scripts
%
%   - Simple sequence of commands.
%   - Variables located in global workspace
%   - No memory allocation or prior declaration of variables
%  


home

%
%% Functions
%
%   - Like a function or procedure you would write in any other language
%   - Can return multiple arguments, accepts variable numbers of inputs
%   - Just like a script except first line should be:
%
%   function [out1, out2, ..., outN] = MyFunction(in1, in2, ..., inN)
%
%   - Variables only have local scope of course
%   - Can make variables global using 'global'
%   - Can make variables persistent (=static) using 'persistent'
%   - You cannot put a function inside a script file
%

 
home

%
%% Inline functions
%
% function_name = inline('function description', 'var1', 'var2', ...)
% 
% Example:
%

my_func = inline('(x+y)*pi/3 - x^2', 'x', 'y');

my_func(3,4) % x=3, y=4


home


% %
% %  In a script file or function, you can use 'keyboard' to 
% %  help debug.  Typing 'return' at the 'K>>' prompt returns
% %  to the script or function.
% %
% keyboard; 



%
%% Some programming guides:
%
% - IF, ELSEIF (one word!!), ELSE, END ladders:
%
% x = rand(1);
% y = rand(1);
%
% disp([x y])
%
% IF(my_func(x, y) > pi)
%     disp('GREATER THAN PI')
% ELSEIF(x < y)
%     disp('X LESS THAN Y')
% ELSE
%     disp('NONE OF THE ABOVE')
% END
%

echo off
x = rand(1);
y = rand(1);
disp([x y])
if(my_func(x, y) > pi)
    disp('GREATER THAN PI')
elseif(x < y)
    disp('X LESS THAN Y')
else
    disp('NONE OF THE ABOVE')
end
echo on



% 
% - NOT is represented by '~' instead of '!'
%
% if( x ~= y)
%     disp('X NOT EQUAL TO Y')
% end
%
echo off
if( x ~= y)
    disp('X NOT EQUAL TO Y')
end


echo on
%
% - AND and OR use && and ||
%
% if( x < y && x < .5)
%     disp('TRUE')
% end
%

echo off
if( x < y && x < .5)
    disp('TRUE')
end


echo on
home

%
% - FOR and WHILE as you would expect
% - Note that your use of FOR and WHILE loops should be
%   _very_ minimal.  Matlab is MUCH faster at vectorized 
%   operations.  Almost any operation can be vectorized with
%   a little (or a lot of) thought!!
% - Nested FOR loops are usually a very bad idea!
%
% for i=1:10
%    disp(i)
% end
%

 
echo off
for i=1:10
    disp(i)
end
echo on

 
home
%
%% Indexing
%
%   - Matlab arrays start indexing from 1, not 0 like C!!!
%   - Remember that the x axis corresponds to COLUMN and the
%     y axis corresponds to ROW!  It is very easy to confuse
%     (row,col) and (x,y) between various operations.
%


home
%
%% Getting results on lots of training or sample files:
%
% - Use the 'dir' command to help get a struct containing all 
%   files/directories
% - First to entries will be '.' and '..'
% 

d = dir;
d(3:end).name


home

%
% Can also assemble image names using vectors:
%
% for(i=1:5)
%     filename = ['image' num2str(i) '.jpg'];
%     disp(filename)
% end
%

echo off
for i=1:5
    filename = ['image' num2str(i) '.jpg'];
    disp(filename)
end
echo on




echo off
