%% Données du problème
G = 5;              % Gain de l'ampli de puissance
g = 0.02;           % Gain de la génératrice tachymétrique (V/rad/s)
tau = 0.02;         % Constante de temps du capteur d'angle (en s)
omega_0 = 40;       % Fréquence de coupure (rad/s)
T_max = 0.03;       % Temps du premier maximum (30 ms)
Depassement = 0.2;  % Dépassement de 20 % (0.2 à 0.25 possible)
Kp = 5;             % Gain proportionnel
b = 3;              % Coefficient de correction

%% Calcul de Km
Km = (pi * omega_0) / (10 * G); % Gain Km
fprintf('Gain Km : %.4f\n', Km);

%% Définition de la fonction de transfert Hs(p)
numerateur = [10 * G * Km]; % Numérateur de Hs(p)
denominateur = [pi * tau, pi + tau, 1]; % Dénominateur de Hs(p)
Hs = tf(numerateur, denominateur);

% Affichage de la fonction de transfert initiale
disp('Fonction de transfert Hs(p) :');
disp(Hs);

%% Correction tachymétrique :
% La cassure doit se produire lorsque le gain est égal à 0.

% Définition de la fonction de transfert corrigée Hs_corrige(p)
numerateur_corrige = [Kp * G * Km * 10 / (pi * (1 + b * g * G * Km))]; % Numérateur corrigé
denominateur_corrige = [tau / (1 + Kp * g * G * Km), 1, 0];  % Dénominateur corrigé

Hs_corrige = tf(numerateur_corrige, denominateur_corrige);

% Affichage de la fonction de transfert corrigée
disp('Fonction de transfert corrigée Hs_corrige(p) :');
disp(Hs_corrige);

%% Tracé du diagramme de Bode de la boucle corrigée
figure;
bode(Hs_corrige);
grid on;
title('Diagramme de Bode de la boucle corrigée');

%% Tracé de la réponse indicielle pour vérifier les performances
figure;
step(Hs_corrige);
grid on;
title('Réponse indicielle de la boucle corrigée');
xlabel('Temps (s)');
ylabel('Amplitude');

%% Question 2.1 : Approximation en basse fréquence

% Définition des constantes
Kg = 8093;   % Gain du couple aérodynamique
tau_M = 0.05; % Constante de temps du capteur de couple

% Définition des fonctions de transfert
H_p = tf([0.282], [1, 0.81, 10.745]);  % H(p) dynamique du moteur et générateur
M_p = tf([1], [tau_M, 1]);             % M(p) capteur du couple

% Boucle interne : approximation par un gain
Hs_interne = H_p * M_p;  % Fonction de transfert totale de la boucle interne

% Tracé du diagramme de Bode pour voir le comportement en basse fréquence
figure;
bode(Hs_interne);
grid on;
title('Diagramme de Bode de la boucle interne');

% Approximation en basse fréquence
gain_pi_sur_10 = pi / 10; % Gain d'approximation attendu

% Superposition avec un gain constant pi/10
hold on;
bode(tf([gain_pi_sur_10], [1])); % Tracé du gain constant pour comparaison
legend('Boucle interne Hs(p)', 'Approximation pi/10');
hold off;

%% Question 2.2 : Fonction de transfert en boucle ouverte pour la commande du couple

% Transmittance du régulateur de couple (donnée) : Rr(p) = 1
Rr_p = 1;

% Approximation de la boucle interne par un gain constant Hs_interne = pi/10
Hs_interne = tf([pi/10], [1]); % Remplacement par un gain constant

% Fonction de transfert en boucle ouverte
H_bo = Rr_p * Kg * Hs_interne * H_p * M_p; % Formule de la boucle ouverte avec l'approximation

% Affichage de la fonction de transfert en boucle ouverte
disp('Fonction de transfert en boucle ouverte H_bo(p) :');
disp(H_bo);

% Tracé du diagramme de Bode de la boucle ouverte
figure;
bode(H_bo);
grid on;
title('Diagramme de Bode de la fonction de transfert en boucle ouverte');

% Analyse du comportement en boucle fermée
H_bf = feedback(H_bo, 1);  % Fermeture de la boucle avec retour unitaire

% Affichage de la fonction de transfert en boucle fermée
disp('Fonction de transfert en boucle fermée H_bf(p) :');
disp(H_bf);

% Tracé de la réponse indicielle pour la boucle fermée
figure;
step(H_bf);
grid on;
title('Réponse indicielle de la boucle fermée');
xlabel('Temps (s)');
ylabel('Amplitude');

%% Question 2.3
%% Question 2.3 : Synthèse d'un régulateur PI Rr(p)

% Définition du régulateur PI :
% - Permet d'annuler l'erreur statique (intégrateur)
% - Assure une pulsation de coupure à 1 rad/s
% - Conserve la phase pour les hautes fréquences

% Forme du régulateur PI : Rr(p) = Kp * (1 + 1 / (Ti * p))
Kp_pi = 0.013;       % Gain proportionnel du PI (ajustable)
Ti_pi = 2.5;        % Constante de temps intégrale (ajustable)

Rr_p = Kp_pi * tf([Ti_pi, 1], [Ti_pi, 0]);  % Définition du PI

% Boucle ouverte corrigée avec PI
H_bo_corrige = Rr_p * H_bo;

% Affichage de la fonction de transfert corrigée en boucle ouverte
disp('Fonction de transfert corrigée en boucle ouverte H_bo_corrige(p) :');
disp(H_bo_corrige);

% Tracé du diagramme de Bode de la boucle ouverte corrigée avec PI
figure;
bode(H_bo, H_bo_corrige);
grid on;
title('Comparaison de la boucle ouverte avant et après régulateur PI');
legend('Avant correction', 'Avec régulateur PI');

% Analyse du comportement en boucle fermée avec PI
H_bf_corrige = feedback(H_bo_corrige, 1);  % Fermeture de la boucle avec retour unitaire

% Affichage de la fonction de transfert en boucle fermée avec PI
disp('Fonction de transfert en boucle fermée avec PI H_bf_corrige(p) :');
disp(H_bf_corrige);

% Tracé de la réponse indicielle pour la boucle fermée avec PI
figure;
step(H_bf, H_bf_corrige);
grid on;
title('Comparaison de la réponse indicielle avant et après régulateur PI');
legend('Avant correction', 'Avec régulateur PI');
xlabel('Temps (s)');
ylabel('Amplitude');

%% Question 2.4 : Analyse de la stabilité avec Black-Nichols

% Tracé de la boucle ouverte corrigée dans le plan de Nichols
figure;
nichols(H_bo_corrige);
grid on;
title('Diagramme de Black-Nichols de la boucle ouverte corrigée');

% Ajout du point critique (-1,0) pour l'analyse de stabilité
hold on;
hold off;

% Affichage de la marge de gain et de phase
[Gm, Pm, Wcg, Wcp] = margin(H_bo_corrige);
fprintf('Marge de gain : %.2f dB\n', 20*log10(Gm));
fprintf('Marge de phase : %.2f°\n', Pm);
fprintf('Fréquence de gain crossover : %.2f rad/s\n', Wcg);
fprintf('Fréquence de phase crossover : %.2f rad/s\n', Wcp);

% Tracé de la réponse indicielle pour voir si le système est à la limite de l'instabilité
figure;
step(H_bf_corrige);
grid on;
title('Réponse indicielle en boucle fermée (vérification de la stabilité)');
xlabel('Temps (s)');
ylabel('Amplitude');
legend('Système en boucle fermée');

%% 2.5 : Ajustement du correcteur avance de phase pour 45° de marge de phase et coupure à 5 rad/s

% Définition de la pulsation cible pour l'avance de phase et la coupure
omega_cible = 5;  % Fixation de la coupure à 5 rad/s

% Phase requise : On vise 45° de marge de phase
phi_max = 45 * pi / 180;  % Conversion en radians
alpha = (1 - sin(phi_max)) / (1 + sin(phi_max));  % Calcul de alpha
T2 = 1 / (omega_cible * sqrt(alpha));  % Calcul de T2
T1 = T2 / alpha;  % Calcul de T1

% Ajustement du gain du correcteur pour fixer la coupure à 5 rad/s
Kc = 1 / abs(evalfr(H_bo_corrige, 1j*omega_cible));  % Ajustement de Kc

% Définition du correcteur avance de phase avec nouvelle coupure
C_p = Kc * tf([T1, 1], [T2, 1]);

% Nouvelle boucle ouverte corrigée avec le correcteur avance de phase
H_bo_corrige_avance = C_p * H_bo_corrige;

% Vérification des marges de gain et de phase après correction
[Gm_avance, Pm_avance, Wcg_avance, Wcp_avance] = margin(H_bo_corrige_avance);
fprintf('Marge de gain après correction avancée : %.2f dB\n', 20*log10(Gm_avance));
fprintf('Marge de phase après correction avancée : %.2f°\n', Pm_avance);
fprintf('Fréquence de gain crossover après correction : %.2f rad/s\n', Wcg_avance);
fprintf('Fréquence de phase crossover après correction : %.2f rad/s\n', Wcp_avance);

% Tracé du diagramme de Bode avant et après correcteur avance de phase
figure;
bode(H_bo_corrige, H_bo_corrige_avance);
grid on;
title('Comparaison de la boucle ouverte avant et après correction avancée');
legend('Avant correction', 'Avec correcteur avancé');

% Tracé des marges de gain et de phase après correction
figure;
margin(H_bo_corrige_avance);
grid on;
title('Marge de gain et de phase après correction avancée');

% Vérification dans le plan de Black-Nichols après correction avancée
figure;
nichols(H_bo_corrige_avance);
grid on;
title('Diagramme de Black-Nichols après correction avancée');

% Ajout du point critique (-1,0) pour vérifier la stabilité
hold on;
plot(-1, 0, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(-1, 0, '  (-1,0)', 'FontSize', 12, 'Color', 'red');
hold off;

% Tracé de la réponse indicielle pour voir l'amélioration en boucle fermée
H_bf_corrige_avance = feedback(H_bo_corrige_avance, 1);  % Fermeture de la boucle

figure;
step(H_bf_corrige, H_bf_corrige_avance);
grid on;
title('Comparaison des réponses indicielles avant et après correction avancée');
legend('Avant correction', 'Avec correcteur avancé');
xlabel('Temps (s)');
ylabel('Amplitude');
