-- Migration 0018: Expand the 'hombros' exercise catalog
-- Run against the STAGING Supabase project.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Press militar con mancuernas, Press Arnold, Elevaciones laterales,
--   Pájaros con mancuernas, Press militar con barra, Elevaciones frontales
--   con barra (exact matches);
--   Press de hombro sentado con mancuernas, Elevaciones frontales con
--   mancuernas, Reverse fly con mancuernas (= Pájaros con mancuernas),
--   Remo al mentón con barra, Handstand push-up asistido en pared,
--   Press de hombro en máquina, Elevación lateral en polea, Press militar
--   sentado, Press militar de pie (confirmed near-duplicates of the
--   existing generic entries).
--
-- Also NOT inserted: Reverse Pec Deck, Pájaros en Polea, Face Pull (con
-- énfasis en deltoide posterior) — already exist in the catalog under
-- 'espalda'; per decision, kept single-categorized there rather than
-- duplicated for 'hombros'.
--
-- "Elevación frontal unilateral" and "Press unilateral en polea" appeared
-- generically enough to collide/confuse with existing entries in other
-- muscle groups (or within this same list across equipment sections), so
-- they were qualified with their equipment for clarity.

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Press de Hombro de Pie con Mancuernas',     'hombros', 'Mancuernas'),
('Press Unilateral con Mancuerna',            'hombros', 'Mancuernas'),
('Elevaciones Laterales Sentado',             'hombros', 'Mancuernas'),
('Elevaciones Laterales Inclinadas',          'hombros', 'Mancuernas'),
('Elevaciones Laterales Acostado de Lado',    'hombros', 'Mancuernas'),
('Elevaciones Laterales Unilaterales',        'hombros', 'Mancuernas'),
('Elevación Frontal Unilateral con Mancuerna', 'hombros', 'Mancuernas'),
('Elevación Frontal Alternada',               'hombros', 'Mancuernas'),
('Pájaros con Pecho Apoyado',                 'hombros', 'Mancuernas'),
('Reverse Fly Acostado en Banco Inclinado',   'hombros', 'Mancuernas'),

-- Barra
('Press tras Nuca',                       'hombros', 'Barra'),
('Push Press',                            'hombros', 'Barra'),
('Press Z',                               'hombros', 'Barra'),
('Press Bradford',                        'hombros', 'Barra'),
('Press Unilateral con Barra tipo Landmine', 'hombros', 'Barra'),
('Press Landmine a Dos Manos',            'hombros', 'Barra'),

-- Peso corporal
('Pike Push-Up',                    'hombros', 'Peso corporal'),
('Pike Push-Up con Pies Elevados',  'hombros', 'Peso corporal'),
('Handstand Push-Up',               'hombros', 'Peso corporal'),
('Handstand Push-Up con Mayor Recorrido', 'hombros', 'Peso corporal'),
('Shoulder Taps',                   'hombros', 'Peso corporal'),
('Handstand Shoulder Taps',         'hombros', 'Peso corporal'),
('Wall Walks',                      'hombros', 'Peso corporal'),
('Planche Lean',                    'hombros', 'Peso corporal'),
('Pseudo Planche Push-Up',          'hombros', 'Peso corporal'),

-- Máquinas
('Press de Hombro Convergente',        'hombros', 'Máquina'),
('Press de Hombro Unilateral',         'hombros', 'Máquina'),
('Press Tipo Hammer Strength',         'hombros', 'Máquina'),
('Press de Hombro con Agarre Neutro',  'hombros', 'Máquina'),
('Máquina de Elevaciones Laterales',   'hombros', 'Máquina'),
('Elevación Lateral Unilateral en Máquina', 'hombros', 'Máquina'),
('Máquina de Deltoide Posterior',      'hombros', 'Máquina'),
('Reverse Fly en Máquina',             'hombros', 'Máquina'),

-- Poleas
('Press de Hombro en Polea',              'hombros', 'Polea'),
('Press de Hombro Unilateral en Polea',   'hombros', 'Polea'),
('Press de Hombro Arrodillado en Polea',  'hombros', 'Polea'),
('Elevación Lateral Unilateral en Polea', 'hombros', 'Polea'),
('Elevación Lateral desde Atrás del Cuerpo', 'hombros', 'Polea'),
('Elevación Lateral Cruzando el Cuerpo',  'hombros', 'Polea'),
('Elevación Lateral Inclinada con Polea', 'hombros', 'Polea'),
('Elevación Frontal en Polea',            'hombros', 'Polea'),
('Elevación Frontal Unilateral en Polea', 'hombros', 'Polea'),
('Reverse Fly en Polea',                  'hombros', 'Polea'),
('Reverse Fly Unilateral en Polea',       'hombros', 'Polea'),
('Cruce Inverso de Poleas',               'hombros', 'Polea')

on conflict (name) where owner_id is null do nothing;
