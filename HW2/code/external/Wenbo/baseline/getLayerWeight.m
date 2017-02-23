function [weight] = getLayerWeight(l, L)

if(l==0 || l==1)
    weight = 2^(-L);
else
    weight = 2^(l-L-1);
end

end