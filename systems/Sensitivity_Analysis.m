
scale = linspace(0.5,1.5);
max2 = 5/40;
max3 = 8*20/75;

%What variables should we change?
%velocity (ft/s), total payload capacity (lbs), battery capacity (Wh)

% 66 percent of 100Wh (max battery), we can't go over 100Wh 
battery_capacity = 67;
batt_capacities = (zeros(1,100) + battery_capacity).*scale;

%best guess for the amt of payload we might carry(based on last year)
payload_weight = 3;
payload_weights = (zeros(1,100) + payload_weight).*scale;

%time for max payload lap = 63 avg lap time for 15lb plane
velocity = 61;
velocities = (zeros(1,100) + velocity).*scale;

max_air_time = 600; %10 minutes on a single battery probably...
turn180 = 7; %7 seconds average turn with payload
turn360 = 16.25; %16.35 seconds average 360 with payload
lap_time = 2*turn180 + turn360 + 2000/velocity;
laps = floor(max_air_time/lap_time);

%passengers weigh 0.085 lbs each, additional 2 lbs
passenger = 25;
passengers = (zeros(1,100) + passenger).*scale;

% BASELINE_SCORE = 1 + ...
%                  1 + (payload_weight/(3*lap_time))/max2 + ...
%                  2 + (laps*passengers/100)/max3;
BASELINE_SCORE = 5.18; 
%also equivalent to 5.1818

%doesn't go through zero cause of battery capacity i think, maybe the -1\

batt_scores = zeros(1,100); 
for i=1:100
    M1 = 1; 
    M2 = 1 + (payload_weight/(3*lap_time))/max2;
    batt_capacities(i)
    M3 = 2 + (laps*passenger/batt_capacities(i))/max3
    total_score = M1 + M2 + M3;
    batt_scores(i) = 100*(total_score/BASELINE_SCORE -1.1);
end

payload_scores = zeros(1,100);
for i=1:100
    M1 = 1; 
    M2 = 1 + (payload_weights(i)/(3*lap_time))/max2;
    M3 = 2 + (laps*passenger/100)/max3;
    total_score = M1 + M2 + M3; 
    payload_scores(i) = 100*(total_score/BASELINE_SCORE -1);
end

velocity_scores = zeros(1,100);
for i=1:100

    lap_time = 2*turn180 + turn360 + 2000/velocities(i);
    laps = floor(max_air_time/lap_time);

    M1 = 1; 
    M2 = 1 + (payload_weight/(3*lap_time))/max2;
    M3 = 2 + (laps*passenger/100)/max3;
    total_score = M1 + M2 + M3; 
    velocity_scores(i) = 100*(total_score/BASELINE_SCORE -1);
end

%resetting lap time, laps and baseline score
lap_time = 2*turn180 + turn360 + 2000/velocity;
laps = floor(max_air_time/lap_time);
BASELINE_SCORE = 5.18;

passenger_scores = zeros(1,100);
for i=1:100
    M1 = 1; 
    M2 = 1 + (payload_weight/(3*lap_time))/max2;
    M3 = 2 + (laps*passengers(i)/100)/max3;
    total_score = M1 + M2 + M3; 
    passenger_scores(i) = 100*(total_score/BASELINE_SCORE -1);
end

plot(scale, passenger_scores)
hold on 
plot(scale, velocity_scores)
hold on
plot(scale, payload_scores)
hold on
plot(scale, batt_scores)
grid on
xlabel('multiplier * attribute') 
ylabel('%change in flyoff score') 
legend({'passengers','velocity','total payload','battery'},'Location','northeast')

