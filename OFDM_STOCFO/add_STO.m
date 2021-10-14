function y=add_STO(x,NSTO)
if NSTO>=0    
  y = [x(NSTO+1:end),x(1:NSTO)];
else
    y=[zeros(1,-NSTO),x];
end