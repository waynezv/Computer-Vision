echo off
clear all
home
!del data.mat
!del data_backup.mat

echo on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  BASIC MATRIX/VECTOR OPERATIONS  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Define a vector/Matrix/n-D Array: NO MEMORY ALLOCATION IS REQUIRED 
%
%% A row vector
%
a = [1 2 4 -7]



%
%% Or a column vector (use ';' between rows)
%
b = [1; 2; 4; -7]



%
%% or using tranpose:
%
c = [1 2 4 -7]'


home

%
%% Pull out individual elements, ranges, etc:
%

b(2)

% the 'end' operator is very useful!
a(end)


%
% NOTE: without a semicolon the end of a line or command, the results are output
% to the screen.  
% With a semicolon, output is suppressed -- usually what you want.
% 
% (ALSO SEE 'help display' and 'help fprintf')
%


home
%
%% List the variables in the workspace
%
who


%
%% List the variables with their sizes
%
whos

 
home

%
%% Saving data:
%

save data.mat a b c


home

%
%% Clear a variable from memory 
%

clear b
whos


home

%
%% Loading a variable from a saved file
%

who
load data.mat b
who

 
home

%
%% Check to see if a file exists or a variable is defined
%% Return value specifies if the argument is a var, file, etc.
%

exist('b')
exist('blah')
exist('b', 'file')
exist('matlab_ops_tutorial')


home


%
%% Shell commands - using '!'
%% (Note that '!' does not mean NOT like in C!!!)
%

!dir
!copy data.mat data_backup.mat

 
home


%
%% A simple matrix
%

A = [1 2 ; 3 4]


clear b
home
%
%% Defining rows or columns of a matrix
%  ':' means 'all'

% 
%% first row of matrix b is a
%
b(1, :) = a

%
%% and second row is defined manually
%
b(2, :) = [9 5 -3 2]

%
%% and let's reassign the third column
%
b(:, 3) = [10; 4]


home;
%
%% Can also show a variable's contents with
% display (shows variable name)
% disp (just shows contents)

display(b)

disp(b)


home;
%
%% Defining Ranges using FROM:INCR:TO notation
%

x = 1:10

y = 100:-15:1


home;

%
%% A vector to index a matrix
%
b 

ind = [1 3];

c = b(:, ind)


home;
%
%% Delete the second column of b
%
b
b(:,2) = []


home;

%
%% Get the Size of the matrix b (SEE 'help size & 'help length')
%
[rowsB, colsB] = size(b)


home;

%
%% Convert the matrix into a column vector
%
b

b = b(:)


home

b
%
%% Want to make b size [2 x 3] again
%
b = reshape(b, [rowsB, colsB]) 



%% Find the maximum of b in each col (SEE 'help max')
%
maxColVal = max(b)



%
%%  Find the maximum of b in each row
%
maxRowVal = max(b, [], 2)


home

%
%% Find the maximum of b
%
maxB = max(max(b))

%
%% or use the column trick:
%
maxB = max( b(:) )


home;

%
%% Find the sum of all the elements (SEE help 'sum')
%
sumB = sum(sum(b))

%
%% or with the column trick again:
%
sumB = sum( b(:) )

%
%% Similarly 'help prod' for products
%


home;


%
%% 'repmat' is also very useful for repeating matrices:
%

a = [1 2 3]'
repmat(a, [1 10])


home;

%
%% Matrix multiplication
%
A = [1 2 3; 4 5 6; 7 8 9]
b(3,:) = [4 2 -1]

A*b



% 
%% Element-by-element multiplication:
%

A.*b

 
home

%
%% 'Element-by-element' is also important for division
%% and exponents
%
A.^3
A./b

 
home

%
%% Computing the Singular Value Decomposition:
%

[U,S,V] = svd(b)

%
%% NOTES: 
% 1. The representation is slightly different from the one
%   which will be shown in the class but it does NOT matter
%
% 2. (BIG CAVEAT!!) The matrix V is actually V of SVD, not V' 
%


home;

%
%% Computing eigenvalues and eigenvectors
%

[V, D] = eig(b)


home

%
%% Special Matrices (arguments indicate size):
%

% Identity:
eye(3)
%
% All ones:
%
ones(4,3)
%
% All zeros:
%
zeros(2,5)


home

%
%% Generating random values
%

%
% Uniform random values between 0 and 1
%
rand(3)
%
% Random values ~ N(0,1)
%
randn(1,20)



home

%
%%  There are MANY more built-in functions, not to mention
%%  toolboxes.  If your questions is "Can Matlab do __X__ ?", 
%%  The answer is almost always YES!!
%
%%  Other things to check out:
%%   cells, structs, squeeze, round, hist, meshgrid, and HELP!!
%



echo off
