
s1TSeriesNormalized = zeros(size(s1TSeries));

for i = 1:size(s1TSeriesNormalized,2)
   s1TSeriesNormalized(:,i) = normalize(s1TSeries(:,i));
end

x0=100;
nSteps = size(s1TSeriesNormalized,1);
crossCorrelation = [];
for i = 1:5000
    crossCorrelation = [crossCorrelation s1TSeriesNormalized(:,i)' * s1TSeriesNormalized(:,x0)];
end
crossCorrelation = crossCorrelation / nSteps;
plot(0:800,crossCorrelation(:,100:900))
xlabel('Space');
ylabel('Prey-prey spatial cross-correlation');

