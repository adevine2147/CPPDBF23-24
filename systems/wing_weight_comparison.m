%for a given airfoil, span and chord length
%    compare foam+glass and monokote+birch


% ASSUMPTIONS FOR BOTH
% using NACA 4412
% Carbon fiber spars will be the same weight in both and will be neglected
% motor mounting will be the same weight in both and will be neglected
% only wing structure mass will be calculated
% control surfaces are not being calcualted
% mass will be in lbm, length will be ft
% calculate_weight(span (ft), chord(ft))

trailing_edge_from_chord = 1/24; %dimensionless
area_from_chord = 16.56/12; %dimensionless
rib_thickness = 0.0083; %ft
spar_wt = 0.063; %lb/ft

% ASSMUMPTIONS LAMINATE
% resin = 1.75* fiberglass mass, 4oz/yd^2 fabric, go lb/in^2
fabric_awt = 0.02777; %lb/ft^2;  4oz / yd^2 = .25lb / 9ft^2 = 0.0277 
resin_awt = 1.75*fabric_awt; %_awt is weight per unit area
foam_den = 1.3; %lb/ft^3


% ASSUMPTIONS ULTRACOTE
% ribs are on either end, made of birch plywood
% ribs in the center are balsa, and are spaced ~5" apart
% leading edge is balsa paper, neglecting weight
% trailing edge is birch, it is 25% of chord from trailing edge, 1/24 of
% chord length
% max, ribs are 0.1" thick. JB weld is 0.125lb per 6ft^2

ultracote_awt = 0.01875; %lb/ft^2
jb_awt = 0.0208; %lb/ft^2
birch_den = 42; %lb/ft^3
balsa_den = 10; %lb/ft^3

x = 0.5:0.01:1.5; 
y = 2:0.02:4;
ultracotes=zeros(101);
foams= zeros(101);

for i=1:100
    for j = 1:100
        ultracotes(i,j) = ultracote(x(i), y(j));
        foams(i,j) = laminate(x(i), y(j));
    end
end
%mesh(x,y,ultracotes)
surf(x,y,foams) 
xlabel("wing chords (ft)")
ylabel("wing spans (ft)")
zlabel("weight (lbs)")
xlim([0.5 1.49])
ylim([2 3.95])
hold on
surf(x,y,ultracotes)
legend('foams','ultracotes')


function total = ultracote(chord, span)

    ultracote_awt = 0.01875; %lb/ft^2
    jb_awt = 0.0208; %lb/ft^2
    birch_den = 42; %lb/ft^3
    balsa_den = 10; %lb/ft^3
    spar_lwt = 0.063; %lb/ft

    
    trailing_edge_from_chord = 1/24; %dimensionless
    area_from_chord = .115; %ft^2 per foot chord
    rib_thickness = 0.0083; %ft

    total = 0;
    area = chord*span; 
    spar_weight = 2*spar_lwt*span;
    te_weight = total + chord*trailing_edge_from_chord*rib_thickness*span*birch_den; %trailing edge weight
    tip_weight = total + 2*area_from_chord*chord*rib_thickness*birch_den; %mass of root and tip chord
    balsa_weight = total + floor(span/4.5)*area_from_chord*rib_thickness*balsa_den; %mass of balsa ribs
    ultracote_weight = total + 2*area*ultracote_awt; %weight of ultracote
    jb_weight = total + area*jb_awt; %weight of JB weld
    total = spar_weight + te_weight + tip_weight + balsa_weight + ultracote_weight+jb_weight;
end

function total = laminate(chord, span)

    resin_from_glass = 1.75;  %resin estimate of fiberglass total
    fabric_awt = 0.02777; %lb/ft^2;  4oz / yd^2 = .25lb / 9ft^2 = 0.0277 
    foam_den = 1.3; %lb/ft^3
    area_from_chord = .115; %ft^2 per ft chord

    area = chord*span;

    glass_weight = 2*area*fabric_awt;
    resin_weight = glass_weight*resin_from_glass;
    foam_weight = area_from_chord*chord*span*foam_den;

    total = glass_weight + resin_weight + foam_weight;
end









