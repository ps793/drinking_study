function [lf,hf,lfhf] = RRFreqFft(rrIn5m)
%this function is to calculate another PSD feature in different frequency
xn=rrIn5m;
N=length(xn);n=0:N-1;
fs=1; t=n/fs; f=n*fs/N;

Xk=fft(xn);
mag=abs(Xk);

lf = f>=0.04 & f<0.15;%0.04-0.15Hz
hf = f>=0.15 & f<0.4;%0.15-0.4Hz

lf = sum(mag(lf));
hf = sum(mag(hf));
lfhf = lf/hf;

% figure;
% subplot(2,1,1);
% plot(t,xn,'.');
% title('RR Int. in 5 Minute');
% xlabel('Number of points');
% subplot(2,1,2);
% plot(f(1:round(N/2)),mag(1:round(N/2)));
% title(strcat('FFT of RR Int. LF/HF = ',num2str(lfhf)));


end
