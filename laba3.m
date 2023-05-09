clc

clear

f = @(x) sin(x);
n = 100 ;
function S = splinee(y,n,h)
    T = zeros(n);
    T(1,1)= 1;
    T(n,n) = 1;

    for i = 2:n-1
        T(i,i-1) = h;
        T(i,i) = 4*h;
        T(i,i+1) = h;
    end

    Y = zeros(n,1);
    for i = 2:n-1
        Y(i) = (3/h)*(y(i+1)-y(i)) - (3/h)*(y(i)-y(i-1));
    end
    b_i = T\Y;

    c_i = zeros(n-1,1);
    for i = 1:n-1
        c_i(i) = (1/h)*(y(i+1)-y(i)) - (h/3)*(2*b_i(i)+b_i(i+1));
    end

    a_i = zeros(n-1,1);
    for i = 1:n-1
        a_i(i) = (1/(3*h)) * (b_i(i+1)-b_i(i));
    end

    S = zeros(n-1,4);
    for i = 1:n-1
        S(i,1) = a_i(i);
        S(i,2) = b_i(i);
        S(i,3) = c_i(i);
        S(i,4) = y(i);
    end
end

startX = 1;
endX = 10;

n_0 = 1;
while n > n_0
    n_0= n_0 + 1;

    x = linspace(startX,endX,n_0);
    y = f(x);
    h = x(2) - x(1);

    S = splinee(y,n_0,h);

    xxx = linspace(startX, endX, 1000);
    yyy = f(xxx);

    xx = linspace(startX,endX,1000);
    yy = zeros(size(xx));
    for i = 1:length(xx)
        for j = 1:length(x)-1
            if xx(i) >= x(j) && xx(i) <= x(j+1)
                yy(i) = S(j,1)*(xx(i)-x(j))^3 + S(j,2)*(xx(i)-x(j))^2 + S(j,3)*(xx(i)-x(j)) + S(j,4);
            end
        end
    end
    diff = abs(yyy - yy);
    diff_n(n_0-1) = max(diff);
end

diff = abs(yyy - yy);
[max_diff, idx_max_diff] = max(diff);
fprintf('Максимальное отклонение исходной функции от кубических Сплайнов: %.20f\n', min(diff_n));


figure;
hold on;
grid on;
title('Динамика отклонения');

plot(2:n, diff_n,'b-', 'LineWidth', 2);
plot(2:n, diff_n,'r*', 'MarkerSize', 8, 'LineWidth', 2);

figure;
hold on;
grid on;
plot(x,y,'k*', 'MarkerSize', 12, 'LineWidth', 2);
title('Сплайс');
plot(xxx, yyy, 'y', 'LineWidth', 2);

pause;
for i = 1:n-1
    xxS = linspace(x(i), x(i+1), 1000);
    start_xx = linspace(-h,-h+1,1000);
    yyS = S(i,1)*(xxS-x(i)).^3 + S(i,2)*(xxS-x(i)).^2 + S(i,3)*(xxS-x(i)) + S(i,4);
    disp("Коэффициенты полинома по которому строится текущая функция:");
    fprintf("%.4f %.4f %.4f %.4f \n",S(i,1),S(i,2),S(i,3),S(i,4));
    plot(start_xx,yyS, 'r', 'LineWidth', 2);
    plot(xxS, yyS, 'r', 'LineWidth', 2);
    pause;
    q = findobj(gca, 'type', 'line', 'xdata', start_xx, 'ydata', yyS);
    delete(q);
    clc

end


