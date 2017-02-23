function void = showbestpts(subim1, subim2, best_pts)

h=impoint(subim1,best_pts(1,[1 2]));setColor(h,'r');
h=impoint(subim2,best_pts(1,[3 4]));setColor(h,'r');
h=impoint(subim1,best_pts(2,[1 2]));setColor(h,'g');
h=impoint(subim2,best_pts(2,[3 4]));setColor(h,'g');
h=impoint(subim1,best_pts(3,[1 2]));setColor(h,'y');
h=impoint(subim2,best_pts(3,[3 4]));setColor(h,'y');
if size(best_pts,1)>=4
    h=impoint(subim1,best_pts(4,[1 2]));setColor(h,'b');
    h=impoint(subim2,best_pts(4,[3 4]));setColor(h,'b');
end
if size(best_pts,1)>=5
    h=impoint(subim1,best_pts(5,[1 2]));setColor(h,'black');
    h=impoint(subim2,best_pts(5,[3 4]));setColor(h,'black');
end

end