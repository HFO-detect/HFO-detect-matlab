% Library of functions for simulated data creation

function [y]=pinknoise(N)

% Create a pink noise (1/f) with N points.
%
% Parameters:
% ----------
% N - Number of samples to be returned

M = N;
% ensure that the N is even
if mod(N,2)==1
    N=N+1;
end

x = randn(1,N); % generate a white noise
X = fft(x); %FFT

% prepare a vector for 1/f multiplication
nPts = N/2;
n = 1:nPts;
n = sqrt(n);

% multiplicate the left half of the spectrum
X_left = X(1:nPts)./n;

% prepare a right half of the spectrum - a copy of the left one
X_right = real(X_left(N/2:-1:1))-1j*imag(X_left(N/2:-1:1));
X = [X_left X_right];

y = ifft(X); %IFFT

y = real(y);
%normalising
y = y - mean(y);
y = y / sqrt(mean(y.^2));
%returning size of N
if mod(M,2)==1
    y = y(1:end-1);
end