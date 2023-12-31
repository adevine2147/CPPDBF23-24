
scale = linspace(0.5,1.5);
max2 = 8/120;
max3 = 5*30/75;

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

max_air_time = 300; %5 min max for all missions
turn180 = 7; %7 seconds average turn with payload
turn360 = 16.25; %16.35 seconds average 360 with payload
lap_time = 2*turn180 + turn360 + 2000/velocity;
laps = floor(max_air_time/lap_time);

%passengers weigh 0.085 lbs each, additional 2 lbs
passenger = 25;
passengers = (zeros(1,100) + passenger).*scale;
%additionally, for each passenger we are adding 0.085lbs
% and for each two passengers, we are adding a length of payload with
% non-negligible weight. the weight added (based on area) is roughly 3*pi*1.5 in^2 per 2 passengers
% so for each person we need


BASELINE_SCORE = 1 + ...
                 1 + (payload_weight/(3*lap_time))/max2 + ...
                 2 + (laps*passenger/100)/max3;

%doesn't go through zero cause of battery capacity i think, maybe the -1\

batt_scores = zeros(1,100); 
for i=1:100
    M1 = 1; 
    M2 = 1 + (payload_weight/(3*lap_time))/max2;
    batt_capacities(i)
    M3 = 2 + (laps*passenger/batt_capacities(i))/max3
    total_score = M1 + M2 + M3;
    batt_scores(i) = 100*(total_score/BASELINE_SCORE -1.05);
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

BASELINE_SCORE = 1 + ...
                 1 + (payload_weight/(3*lap_time))/max2 + ...
                 2 + (laps*passenger/100)/max3;

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
xlabel('attribute multiplier') 
ylabel('%change in flyoff score') 
legend({'passengers','velocity','total payload','battery'},'Location','northeast')

