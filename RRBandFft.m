function [lb,mb,hb,lbhb] = RRBandFft(rrIn1m)
% this function is to calculate power of spectrum density; it is one of
% features
xn=rrIn1m;
N=length(xn);n=0:N-1;
fs=1; t=n/fs; f=n*fs/N;

Xk=fft(xn);
mag=abs(Xk);

lb = f>=0.1 & f<0.2;%0.1-0.2Hz
mb = f>=0.2 & f<0.3;%0.2-0.3Hz
hb = f>=0.3 & f<0.4;%0.3-0.4Hz

lb = sum(mag(lb));
mb = sum(mag(mb));
hb = sum(mag(hb));
lbhb = lb/hb;

% figure;
% subplot(2,1,1);
% plot(t,xn,'.');
% title('RR Int. in 1 Minute');
% xlabel('Number of points');
% subplot(2,1,2);
% plot(f(1:round(N/2)),mag(1:round(N/2)));
% title(strcat({'FFT of RR Int. LB/HB = '},num2str(lbhb)));

end
