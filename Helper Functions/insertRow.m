function data = insertRow(data, rows, index)
%% INSERTROW   Inserts a row in a matrix or table at the specified index
%
% data:                     Integer for the different classes
% row:                      Depth for each class point
% index:                    Start and end age of interval
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Assertions
assert(exist('data', 'var')== true, 'data must be provided');
assert(exist('rows', 'var')== true, 'rows must be provided');
assert(size(rows,2) == size(data,2), 'Number of columns in data and row must be equal');

% Defaults
if ~exist('index', 'var'); index = size(data,1)+1; end

% Assertions 2
assert(isscalar(index) && isnumeric(index), 'index must be a scalar numeric');
assert(index >=1 && index <= size(data,1)+1, 'index must be between 1 and number of rows of data + 1');

%% Main

data = [data(1:index-1,:); rows ;data(index:end,:)];


end