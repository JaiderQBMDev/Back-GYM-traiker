-- Migration 0020: Expand the 'antebrazo' exercise catalog
-- Run against the STAGING Supabase project.
--
-- Some items from the source list were self-excluded by the user's own
-- notes (e.g. "Curl Zottman con barra no es habitual; mejor hacerlo con
-- mancuernas") and are not inserted.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Curl de muñeca con barra, Curl inverso con barra (exact matches);
--   Curl de muñeca con palmas hacia arriba (= Curl de muñeca con
--   mancuerna), Curl de muñeca con palmas hacia abajo (= Curl de muñeca
--   inverso con mancuerna), Curl de muñeca inverso con barra (confirmed
--   = the existing 'Curl de Muñeca Inverso', which is the barra variant),
--   Farmer's carry con mancuernas (= Farmer Walk), Pinch grip con
--   mancuerna (= Agarre con Pinza), Dead hang / colgarse de una barra
--   (= Dead Hang), Fingertip plank (= Plancha apoyado sobre los dedos),
--   Escalada en barra (= Monkey bars), Máquina de agarre (= Hand gripper
--   machine), Wrist roller improvisado con barra (= Roller de Muñeca),
--   Wrist roller machine (= Máquina de Antebrazo con Rodillo), Sostén
--   isométrico de barra / Farmer hold con barra (merged into one entry)
--   (confirmed near-duplicates).
--
-- Also NOT inserted: Suitcase carry — already exists under 'abdomen'
-- ("Marcha de Granjero Unilateral / Suitcase Carry", added in 0019).

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Curl de Muñeca con Mancuerna',            'antebrazo', 'Mancuernas'),
('Curl de Muñeca Unilateral',               'antebrazo', 'Mancuernas'),
('Curl de Muñeca Inverso con Mancuerna',    'antebrazo', 'Mancuernas'),
('Curl Martillo',                           'antebrazo', 'Mancuernas'),
('Curl Martillo Cruzado',                   'antebrazo', 'Mancuernas'),
('Curl Zottman',                            'antebrazo', 'Mancuernas'),
('Pronación con Mancuerna',                 'antebrazo', 'Mancuernas'),
('Supinación con Mancuerna',                'antebrazo', 'Mancuernas'),
('Desviación Radial con Mancuerna',         'antebrazo', 'Mancuernas'),
('Desviación Cubital con Mancuerna',        'antebrazo', 'Mancuernas'),
('Sostén Isométrico Pesado con Mancuernas', 'antebrazo', 'Mancuernas'),

-- Barra
('Curl de Muñeca Detrás de la Espalda', 'antebrazo', 'Barra'),
('Sostén Isométrico de Barra',          'antebrazo', 'Barra'),
('Finger Curls con Barra',              'antebrazo', 'Barra'),

-- Peso corporal
('Dead Hang con Una Mano Asistida',          'antebrazo', 'Peso corporal'),
('Dead Hang con Toalla',                     'antebrazo', 'Peso corporal'),
('Dead Hang con Agarre Grueso Improvisado',  'antebrazo', 'Peso corporal'),
('Flexiones sobre los Dedos',                'antebrazo', 'Peso corporal'),
('Flexiones sobre Nudillos',                 'antebrazo', 'Peso corporal'),
('Plancha Apoyado sobre los Dedos',          'antebrazo', 'Peso corporal'),
('Monkey Bars',                              'antebrazo', 'Peso corporal'),
('Rope Climb',                               'antebrazo', 'Peso corporal'),
('Towel Pull-Up',                            'antebrazo', 'Peso corporal'),
('Hang Escapular con Énfasis en Agarre',     'antebrazo', 'Peso corporal'),

-- Máquinas
('Máquina de Curl de Muñeca',       'antebrazo', 'Máquina'),
('Máquina de Extensión de Muñeca',  'antebrazo', 'Máquina'),
('Hand Gripper Machine',            'antebrazo', 'Máquina'),
('Máquina de Pronación/Supinación', 'antebrazo', 'Máquina'),
('Máquina de Curl Inverso',         'antebrazo', 'Máquina'),
('Máquina de Antebrazo con Rodillo', 'antebrazo', 'Máquina'),

-- Poleas
('Curl de Muñeca en Polea Baja',        'antebrazo', 'Polea'),
('Curl de Muñeca Inverso en Polea',     'antebrazo', 'Polea'),
('Curl Inverso en Polea',               'antebrazo', 'Polea'),
('Curl Martillo con Cuerda',            'antebrazo', 'Polea'),
('Pronación con Polea',                 'antebrazo', 'Polea'),
('Supinación con Polea',                'antebrazo', 'Polea'),
('Desviación Radial con Polea',         'antebrazo', 'Polea'),
('Desviación Cubital con Polea',        'antebrazo', 'Polea'),
('Sostén Isométrico en Polea',          'antebrazo', 'Polea'),
('Wrist Curl Unilateral en Polea',      'antebrazo', 'Polea'),
('Reverse Wrist Curl Unilateral en Polea', 'antebrazo', 'Polea')

on conflict (name) where owner_id is null do nothing;
