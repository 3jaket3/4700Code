clear all
clearvars
clearvars -GLOBAL
close all
set(0,'DefaultFigureWindowStyle','docked')

global C

addpath ../geom2d/geom2d

C.q_0 = 1.60217653e-19;             % electron charge
C.hb = 1.054571596e-34;             % Dirac constant
C.h = C.hb * 2 * pi;                    % Planck constant
C.m_0 = 9.10938215e-31;             % electron mass
C.kb = 1.3806504e-23;               % Boltzmann constant
C.eps_0 = 8.854187817e-12;          % vacuum permittivity
C.mu_0 = 1.2566370614e-6;           % vacuum permeability
C.c = 299792458;                    % speed of light
C.g = 9.80665 %metres (32.1740 ft) per s�

nTime = 100;
nTraj = 5;
nSims = 100;

InitalAngle = 55 * pi / 180;
MaxC = 10000;


V0 = 1000;
g = 1;
c = 2;
dt = 1;

Wind = @UniformRandWind;
WindParas = [10];

% Wind = @NormalRandWind;
% WindParas = [5];

% Wind = @ComplexRandWind;
% WindParas = [.35];

m = 10;

E = 0.5 * m .* (V0 * sin(InitalAngle))^2; % Initial is kinetic energy, Ek

initialEnergy = mean(E); % Calculate the Mean Initial Energy

Ek = zeros(1, nTraj);  % Set kinetic energy of projectiles to 0
Eg = zeros(1, nTraj);  % Set gravitional potential energy of projectiles to 0


for n = 1: nSims
    x(1, :) = zeros(1, nTraj);
    y(1, :) = zeros(1, nTraj);

    Vx(1:nTraj) = V0 * cos(InitalAngle);
    Vy(1:nTraj) = V0 * sin(InitalAngle);

    for c=2:MaxC

        dvx = Wind(nTraj,WindParas)*dt;
        Vx = Vx + dvx;
        dx = Vx * dt;

        dvy = -g * dt;
        Vy = Vy + dvy;
        dy = Vy * dt + g * dt^2 / 2;

        x(c,:) = x(c - 1,:) + dx;
        y(c,:) = y(c - 1,:) + dy;
        
        Eg = m .* g .* y(c,:);  % Calculate gravitational potential energy as Eg = m*g*y
        
        randLoss = (0.75 + 0.2 .* rand(1, nTraj)); % Random energy loss between 75-95% due to factors
                                                   % such as air resistance
        Ek = E - randLoss .* Eg;  % Calculate kinetic energy as Ek = E - Eg, with energy loss
        
        if max(Ek) <= 0  % Check if maximum height has been reached, i.e. Ek = 0;
            
            E = 0.85 .* abs(Eg);  % Ek = 0, total energy is Eg (with some loss)
            
        end
        
        if max(Eg) <= 0  % Check projectiles have reach ground level, i.e. Eg = 0
            
            E = 0.6 .* abs(Ek); % Eg = 0, total energy is Ek (with some loss)
            Vy = sqrt(2 .* E .* m^-1);  % Calculate new take-off velocity using remaining Ek
            
        end
        
        if min(y(c)) < 0  % Check if any projectiles are below ground level
            
            Ylt = y < 0;  % Determine which projectiles are below ground level
            y(Ylt) = 0;   % Set projectiles below ground level to 0
            
        end
        
        if E <= 0.005 .* initialEnergy  % Check if remaining total energy is negligible         
            break  % END SIMULATION IF TRUE
        end
        
    end

end

figure(1);
xlim([min(min(x)) max(max(x))]);
ylim([min(min(y)) max(max(y))]);
hold on;

for i = 1 : nTraj
    
    modifiedcomet(x(:,i),y(:,i),0.2,i); % Plot projectiles using the function modifiedcomet.m
    pause(0.2);
    
end

hold off;

% Improvements can be made by modelling actual losses instead of random
% energy loss. More projectiles can be simulated using plot(x,y) or by
% improving the function modifiedcomet.m