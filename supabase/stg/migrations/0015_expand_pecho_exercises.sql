-- Migration 0015: Expand the 'pecho' exercise catalog
-- Run against the STAGING Supabase project.
--
-- Source list was reviewed against the catalog (post-0014 cleanup) to avoid
-- duplicates. The following were confirmed as already existing and are NOT
-- re-inserted here:
--   Press inclinado con mancuernas, Press declinado con mancuernas,
--   Aperturas inclinadas, Pullover con mancuerna, Aperturas en máquina,
--   Press banca plano/inclinado/declinado (= Press de banca con barra/
--   inclinado/declinado), Flexiones clásicas (= Flexiones de pecho),
--   "Fondos en paralelas inclinando el torso hacia adelante"
--   (= Fondos en paralelas), Press de pecho horizontal en máquina
--   (= Press en máquina), Cruce de poleas alto a bajo (= Crossover en
--   Polea), Aperturas en polea de pie (= Aperturas en polea), and
--   Pullover en Polea (already exists, tagged 'espalda' — left as-is).
--
-- A couple of names collided with themselves across equipment sections in
-- the source list ("Press con agarre neutro" appeared under both Mancuernas
-- and Máquinas) or were ambiguous against unilateral variants elsewhere in
-- the catalog; those were qualified with their equipment for clarity/
-- uniqueness (name is globally unique regardless of muscle_group).
--
-- Uses ON CONFLICT DO NOTHING as a safety net in case any of these already
-- slipped in some other way.

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Press con Agarre Neutro (Mancuernas)', 'pecho', 'Mancuernas'),
('Press Alterno con Mancuernas',          'pecho', 'Mancuernas'),
('Press Unilateral con Mancuerna',        'pecho', 'Mancuernas'),
('Press de Suelo con Mancuernas',         'pecho', 'Mancuernas'),
('Squeeze Press / Hex Press',             'pecho', 'Mancuernas'),
('Aperturas Planas',                      'pecho', 'Mancuernas'),
('Aperturas Declinadas',                  'pecho', 'Mancuernas'),
('Aperturas en el Suelo',                 'pecho', 'Mancuernas'),
('Press-Around con Mancuerna',            'pecho', 'Mancuernas'),
('Svend Press con Mancuerna',             'pecho', 'Mancuernas'),

-- Barra
('Press Banca con Agarre Ancho',    'pecho', 'Barra'),
('Press Banca con Pausa',           'pecho', 'Barra'),
('Press Banca Spoto',               'pecho', 'Barra'),
('Press Banca con Tempo',           'pecho', 'Barra'),
('Press Banca Larsen',              'pecho', 'Barra'),
('Press Banca con Agarre Inverso',  'pecho', 'Barra'),
('Press Inclinado con Agarre Inverso', 'pecho', 'Barra'),
('Press de Suelo con Barra',        'pecho', 'Barra'),
('Guillotine Press',                'pecho', 'Barra'),
('Press desde Pines',               'pecho', 'Barra'),
('Pullover con Barra',              'pecho', 'Barra'),

-- Peso corporal
('Flexiones Anchas',                    'pecho', 'Peso corporal'),
('Flexiones Cerradas',                  'pecho', 'Peso corporal'),
('Flexiones Inclinadas',                'pecho', 'Peso corporal'),
('Flexiones Declinadas',                'pecho', 'Peso corporal'),
('Flexiones con Pies Elevados',         'pecho', 'Peso corporal'),
('Flexiones Profundas',                 'pecho', 'Peso corporal'),
('Flexiones con Pausa',                 'pecho', 'Peso corporal'),
('Flexiones con Tempo Lento',           'pecho', 'Peso corporal'),
('Flexiones Explosivas',                'pecho', 'Peso corporal'),
('Flexiones con Palmada',               'pecho', 'Peso corporal'),
('Flexiones Pliométricas',              'pecho', 'Peso corporal'),
('Flexiones Archer',                    'pecho', 'Peso corporal'),
('Flexiones Typewriter',                'pecho', 'Peso corporal'),
('Flexiones a Una Mano',                'pecho', 'Peso corporal'),
('Flexiones Pseudo Planche',            'pecho', 'Peso corporal'),
('Flexiones Déficit',                   'pecho', 'Peso corporal'),
('Flexiones Spiderman',                 'pecho', 'Peso corporal'),
('Flexiones con Desplazamiento Lateral', 'pecho', 'Peso corporal'),
('Fondos Profundos',                    'pecho', 'Peso corporal'),
('Fondos Coreanos',                     'pecho', 'Peso corporal'),
('Flexiones en Anillas',                'pecho', 'Peso corporal'),
('Fondos en Anillas',                   'pecho', 'Peso corporal'),

-- Máquinas
('Press Convergente',                   'pecho', 'Máquina'),
('Press Divergente',                    'pecho', 'Máquina'),
('Press Inclinado en Máquina',          'pecho', 'Máquina'),
('Press Declinado en Máquina',          'pecho', 'Máquina'),
('Press Unilateral en Máquina',         'pecho', 'Máquina'),
('Press en Máquina con Agarre Neutro',  'pecho', 'Máquina'),
('Press con Agarre Ancho en Máquina',   'pecho', 'Máquina'),
('Press Tipo Hammer Strength Plano',    'pecho', 'Máquina'),
('Press Hammer Strength Inclinado',     'pecho', 'Máquina'),
('Press Hammer Strength Declinado',     'pecho', 'Máquina'),
('Pec Deck / Contractor de Pecho',      'pecho', 'Máquina'),
('Aperturas Unilaterales en Máquina',   'pecho', 'Máquina'),

-- Poleas
('Cruce de Poleas a la Altura del Pecho', 'pecho', 'Polea'),
('Cruce de Poleas Bajo a Alto',           'pecho', 'Polea'),
('Aperturas en Polea Acostado',           'pecho', 'Polea'),
('Aperturas Unilaterales en Polea',       'pecho', 'Polea'),
('Press de Pecho en Polea',               'pecho', 'Polea'),
('Press Unilateral en Polea',             'pecho', 'Polea'),
('Press Inclinado en Polea',              'pecho', 'Polea'),
('Press Declinado en Polea',              'pecho', 'Polea'),
('Press-Around en Polea',                 'pecho', 'Polea'),
('Svend Press en Polea',                  'pecho', 'Polea')

on conflict (name) where owner_id is null do nothing;
