function [stateVector,timeVector] = importEphemeridesData(fileName)

% IMPORTEPHEMERIDESDATA - Imports numerical data from Ephemerides data file
%
%   This MATLAB function returns the state vector and the time vector (of the specified
%   length in the table, n) of a space object from an Ephemerides data file (.txt).
%
% Input arguments:
%   fileName    [1x1]   -     File name [string] 
%       
% Output arguments:
%   stateVector [nx6]   -     State vector [L, L/T]
%   timeVector  [1x6]   -     Time vector [T]
%
% CONTRIBUTORS:
%      Sara Monaco
%      Simone Montepiani
%
% VERSIONS
%      31-10-2024


% Read file as lines of string
fileLines = readlines(fileName);

% Find where the data starts and ends
startIn= find(contains(fileLines, "$$SOE"), 1);
endIn = find(contains(fileLines, "$$EOE"), 1);

% Save data contained in the aformentioned lines into a temporary file
tempFile = 'temp_data.txt';
writelines(fileLines(startIn + 1:endIn -1), tempFile);

% Import said data
data = importdata(tempFile);

% Delete prefix "A.D. "
dateStrings = strrep(data.textdata(:,2), 'A.D. ', '');

% Convert string to datetime elements
time = datetime(dateStrings, 'InputFormat', 'yyyy-MMM-dd HH:mm:ss.SSSS');

% Compute time vector in seconds wrt reference datatime (time(1))
timeVector = seconds(time - time(1));

stateVector = data.data;
