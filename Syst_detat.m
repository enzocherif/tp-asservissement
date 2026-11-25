% Données du système
omega = 7.8; % Vitesse angulaire en km/s

% Matrices du système
%Matrice A
A = [0, 1, 0, 0;
     3*omega^2, 0, 0, 2*omega;
     0, 0, 0, 1;
     0, -2*omega, 0, 0];
%Matrice B
B = [0, 0;
     1, 0;
     0, 0;
     0, 1];
%Matrice C 
C = [1, 0, 0, 0];

%Vérification de l'obsevabilté 
Ob=obsv(A,C);
rank_Ob = rank(Ob); 
disp('Rang de la matrice de lobsevabilte :');
disp(rank_Ob);

%Vérification de la controlabité
Co=ctrb(A,B);
rank_Co = rank(Co); 
disp('Rang de la matrice de commandabilité :');
disp(rank_Co);

% Dimensions du système
n = size(A, 1);


%Résultats
if rank_Ob == n
    disp('Le système est observable.');
else
    disp('Le système n''est pas observable.');
end

if rank_Co == n
    disp('Le système est commandable.');
else
    disp('Le système n''est pas commandable.');
end

% Cas 1 : Désactiver u_r 
B_no_ur = [0;
           0;
           0;
           1];
Co_no_ur = ctrb(A, B_no_ur); % Matrice de commandabilité
rank_Co_no_ur = rank(Co_no_ur);

% Cas 2 : Désactiver u_theta
B_no_utheta = [0;
               1;
               0;
               0];
Co_no_utheta = ctrb(A, B_no_utheta); % Matrice de commandabilité
rank_Co_no_utheta = rank(Co_no_utheta);

% Résultats
disp('Rang de la matrice de commandabilité sans u_r :');
disp(rank_Co_no_ur);

disp('Rang de la matrice de commandabilité sans u_theta :');
disp(rank_Co_no_utheta);

if rank_Co_no_ur == n
    disp('Le système reste commandable sans u_r.');
else
    disp('Le système n''est pas commandable sans u_r.');
end

if rank_Co_no_utheta == n
    disp('Le système reste commandable sans u_theta.');
else
    disp('Le système n''est pas commandable sans u_theta.');
end

C_r = [1, 0, 0, 0]; % Sortie mesurée : r (position radiale)

% Calcul de la matrice d'observabilité
Ob_r = obsv(A, C_r); % Matrice d'observabilité
rank_Ob_r = rank(Ob_r); % Rang de la matrice d'observabilité

% Dimension du système
n = size(A, 1);

% Affichage des résultats
disp('Rang de la matrice d''observabilité avec la sortie r :');
disp(rank_Ob_r);

if rank_Ob_r == n
    disp('Le système est observable lorsque la sortie mesurée est r (position radiale).');
else
    disp('Le système n''est pas observable lorsque la sortie mesurée est r (position radiale).');
end

% Nouvelle matrice C avec r et dr/dt (vitesse radiale)
C_new = [0, 0, 1, 0]; % Mesure de dr/dt (vitesse radiale)
Ob=obsv(A,C_new);
rank_Ob = rank(Ob); 
disp('Rang de la matrice de lobsevabilte :');
disp(rank_Ob);

%Résultats
if rank_Ob == n
    disp('Le système est observable.');
else
    disp('Le système n''est pas observable.');
end