-- Migration 0017: Expand 'piernas', 'gluteos' and 'pantorrillas' catalogs
-- Run against the STAGING Supabase project.
--
-- Source list was submitted as "piernas" but included a lot of glute
-- (hip thrust, puente de glúteos, patada/abducción/aducción de cadera)
-- and calf-raise exercises. Per decision, those are routed to their
-- existing dedicated 'gluteos' / 'pantorrillas' muscle groups instead of
-- 'piernas', to stay consistent with the rest of the catalog.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Sentadilla goblet, Sentadilla búlgara, Peso muerto rumano, Prensa de
--   piernas, Extensión de cuádriceps, Curl femoral sentado, Curl femoral
--   acostado (exact matches, piernas);
--   Zancadas caminando, Sentadilla frontal (case-insensitive exact,
--   piernas);
--   Step-up (con/sin mancuernas) (= Step Up), Sentadilla trasera
--   (= Sentadilla con barra), Buenos días con barra (= Buenos Días),
--   Hack squat (= Sentadilla hack), Sentadilla sumo (already exists,
--   under 'gluteos'), Prensa inclinada (= Prensa de Piernas 45°),
--   Máquina de abductores (= Abductores en Máquina) (confirmed);
--   Hip thrust con barra, Puente de glúteos, Hip thrust en máquina,
--   Patada de glúteo en polea (exact/near-exact matches, gluteos);
--   Elevación de talones (bare, = Elevación de talones de pie, per the
--   same precedent set in 0014), Elevación de talón unilateral
--   (= Elevación de Talones a Una Pierna), Elevación de talones de pie
--   con mancuernas (= Elevación de talones con mancuerna), Elevación de
--   pantorrillas sentado/de pie (= Elevación de talones sentado/de pie)
--   (confirmed, pantorrillas).
--
-- A few names collided with themselves across equipment sections in the
-- source list (e.g. "Split squat" and "Zancadas hacia adelante/atrás/
-- laterales" appeared under both Mancuernas and Peso corporal; "Sentadilla
-- con pausa" appeared under both Barra and Peso corporal) — kept the bare
-- name for the bodyweight version and qualified the weighted one with its
-- equipment.

-- Piernas
insert into public.exercises (name, muscle_group, equipment) values
('Sentadilla con Dos Mancuernas',            'piernas', 'Mancuernas'),
('Sentadilla Sumo con Mancuerna',            'piernas', 'Mancuernas'),
('Zancadas hacia Adelante con Mancuernas',   'piernas', 'Mancuernas'),
('Zancadas hacia Atrás con Mancuernas',      'piernas', 'Mancuernas'),
('Zancadas Laterales con Mancuernas',        'piernas', 'Mancuernas'),
('Split Squat con Mancuernas',               'piernas', 'Mancuernas'),
('Peso Muerto Rumano con Mancuernas',        'piernas', 'Mancuernas'),
('Peso Muerto Piernas Rígidas con Mancuernas', 'piernas', 'Mancuernas'),
('Sentadilla Ciclista con Mancuernas',       'piernas', 'Mancuernas'),

('Sentadilla Zercher',            'piernas', 'Barra'),
('Sentadilla con Pausa (Barra)',  'piernas', 'Barra'),
('Sentadilla a Caja',             'piernas', 'Barra'),
('Sentadilla Hack con Barra',     'piernas', 'Barra'),
('Split Squat con Barra',         'piernas', 'Barra'),
('Sentadilla Búlgara con Barra',  'piernas', 'Barra'),
('Zancadas con Barra',            'piernas', 'Barra'),
('Step-Up con Barra',             'piernas', 'Barra'),
('Peso Muerto Piernas Rígidas',   'piernas', 'Barra'),

('Sentadilla Libre',                  'piernas', 'Peso corporal'),
('Sentadilla Profunda',               'piernas', 'Peso corporal'),
('Sentadilla Isométrica en Pared',    'piernas', 'Peso corporal'),
('Sentadilla con Pausa',              'piernas', 'Peso corporal'),
('Sentadilla con Salto',              'piernas', 'Peso corporal'),
('Sentadilla Pistol',                 'piernas', 'Peso corporal'),
('Sentadilla Shrimp',                 'piernas', 'Peso corporal'),
('Split Squat',                       'piernas', 'Peso corporal'),
('Zancadas hacia Adelante',           'piernas', 'Peso corporal'),
('Zancadas hacia Atrás',              'piernas', 'Peso corporal'),
('Zancadas Laterales',                'piernas', 'Peso corporal'),
('Nordic Curl',                       'piernas', 'Peso corporal'),
('Sliding Leg Curl',                  'piernas', 'Peso corporal'),
('Curl Femoral Deslizante Unilateral', 'piernas', 'Peso corporal'),
('Saltos al Cajón',                   'piernas', 'Peso corporal'),
('Saltos Verticales',                 'piernas', 'Peso corporal'),

('Prensa Horizontal',            'piernas', 'Máquina'),
('Pendulum Squat',               'piernas', 'Máquina'),
('V-Squat',                      'piernas', 'Máquina'),
('Sentadilla en Máquina Smith',  'piernas', 'Máquina'),
('Sentadilla Búlgara en Smith',  'piernas', 'Máquina'),
('Zancadas en Smith',            'piernas', 'Máquina'),
('Curl Femoral de Pie',          'piernas', 'Máquina'),
('Máquina de Aductores',         'piernas', 'Máquina'),
('Prensa Unilateral',            'piernas', 'Máquina'),
('Hack Squat Unilateral',        'piernas', 'Máquina'),

('Sentadilla con Polea Baja',      'piernas', 'Polea'),
('Sentadilla Goblet con Polea',    'piernas', 'Polea'),
('Zancadas con Polea',             'piernas', 'Polea'),
('Split Squat con Polea',          'piernas', 'Polea'),
('Sentadilla Búlgara con Polea',   'piernas', 'Polea'),
('Peso Muerto Rumano con Polea',   'piernas', 'Polea'),
('Curl Femoral con Tobillera',     'piernas', 'Polea'),
('Extensión de Rodilla con Polea', 'piernas', 'Polea')

on conflict (name) where owner_id is null do nothing;

-- Glúteos
insert into public.exercises (name, muscle_group, equipment) values
('Hip Thrust con Mancuerna',        'gluteos', 'Mancuernas'),
('Puente de Glúteos con Mancuerna', 'gluteos', 'Mancuernas'),
('Puente de Glúteos con Barra',     'gluteos', 'Barra'),
('Puente de Glúteos Unilateral',    'gluteos', 'Peso corporal'),
('Hip Thrust con Peso Corporal',    'gluteos', 'Peso corporal'),
('Glute Drive',                     'gluteos', 'Máquina'),
('Pull-Through',                    'gluteos', 'Polea'),
('Abducción de Cadera en Polea',    'gluteos', 'Polea'),
('Aducción de Cadera en Polea',     'gluteos', 'Polea')

on conflict (name) where owner_id is null do nothing;

-- Pantorrillas
insert into public.exercises (name, muscle_group, equipment) values
('Elevación de Talón Unilateral con Mancuerna', 'pantorrillas', 'Mancuernas'),
('Elevación de Talones con Barra',              'pantorrillas', 'Barra'),
('Donkey Calf Raise en Máquina',                'pantorrillas', 'Máquina'),
('Elevación de Talones con Polea',              'pantorrillas', 'Polea')

on conflict (name) where owner_id is null do nothing;
