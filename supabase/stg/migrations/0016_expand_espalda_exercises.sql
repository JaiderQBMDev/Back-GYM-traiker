-- Migration 0016: Expand the 'espalda' exercise catalog
-- Run against the STAGING Supabase project.
--
-- Source list was reviewed against the catalog (post-0014/0015) to avoid
-- duplicates. NOT re-inserted here because they already exist:
--   Pullover con mancuerna, Remo con barra, Remo Pendlay
--   (exact matches);
--   Remo con dos mancuernas / Remo inclinado con mancuernas
--   (= Remo con mancuerna), Remo T-bar (= Remo con Barra T),
--   Dominadas pronas (= Dominadas), Dominadas con agarre cerrado
--   (= Dominadas con Agarre Cerrado), Jalón dorsal en máquina / Jalón al
--   pecho con agarre ancho (= Jalón al pecho), Jalón al pecho con agarre
--   cerrado (= Jalón con Agarre Cerrado), Remo sentado en máquina
--   (= Remo en máquina), Remo sentado en polea / Remo bajo en polea
--   (= Remo en polea baja), Pullover en polea (= Pullover en Polea)
--   (confirmed near/exact duplicates);
--   Pullover con barra (already exists under 'pecho', added in 0015) —
--   confirmed cross-muscle-group duplicate, left where it is.
--
-- Two names collided with themselves across equipment sections in the
-- source list ("Remo con pecho apoyado" under both Mancuernas and
-- Máquinas; "Jalón unilateral" under both Máquinas and Poleas); qualified
-- with equipment to keep names unique.

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Remo con Mancuerna a Una Mano',      'espalda', 'Mancuernas'),
('Remo con Pecho Apoyado (Mancuernas)', 'espalda', 'Mancuernas'),
('Remo Unilateral con Apoyo en Banco', 'espalda', 'Mancuernas'),
('Remo con Codos Pegados',             'espalda', 'Mancuernas'),
('Remo con Agarre Neutro',             'espalda', 'Mancuernas'),
('Remo Tipo Kroc',                     'espalda', 'Mancuernas'),
('Pullover con Dos Mancuernas',        'espalda', 'Mancuernas'),

-- Barra
('Remo Yates',                          'espalda', 'Barra'),
('Remo con Agarre Prono',               'espalda', 'Barra'),
('Remo con Agarre Supino',              'espalda', 'Barra'),
('Remo con Agarre Ancho',               'espalda', 'Barra'),
('Remo con Agarre Cerrado',             'espalda', 'Barra'),
('Remo con Pausa',                      'espalda', 'Barra'),
('Remo Meadows con Barra',              'espalda', 'Barra'),
('Remo con Pecho Apoyado en Banco Inclinado', 'espalda', 'Barra'),

-- Peso corporal
('Dominadas Supinas',                'espalda', 'Peso corporal'),
('Dominadas con Agarre Neutro',      'espalda', 'Peso corporal'),
('Dominadas con Agarre Ancho',       'espalda', 'Peso corporal'),
('Dominadas con Pausa',              'espalda', 'Peso corporal'),
('Dominadas Explosivas',             'espalda', 'Peso corporal'),
('Dominadas Archer',                 'espalda', 'Peso corporal'),
('Dominadas Typewriter',             'espalda', 'Peso corporal'),
('Dominadas Asistidas a Una Mano',   'espalda', 'Peso corporal'),
('Dominadas Escapulares',            'espalda', 'Peso corporal'),
('Remo Invertido',                   'espalda', 'Peso corporal'),
('Remo Invertido con Agarre Prono',  'espalda', 'Peso corporal'),
('Remo Invertido con Agarre Supino', 'espalda', 'Peso corporal'),
('Remo Invertido con Agarre Ancho',  'espalda', 'Peso corporal'),
('Remo Invertido con Agarre Cerrado', 'espalda', 'Peso corporal'),
('Remo Invertido con Pies Elevados', 'espalda', 'Peso corporal'),
('Remo Invertido Unilateral',        'espalda', 'Peso corporal'),

-- Máquinas
('Jalón Convergente',              'espalda', 'Máquina'),
('Jalón Unilateral en Máquina',    'espalda', 'Máquina'),
('Remo Convergente',               'espalda', 'Máquina'),
('Remo Unilateral en Máquina',     'espalda', 'Máquina'),
('Remo con Pecho Apoyado en Máquina', 'espalda', 'Máquina'),
('Remo Hammer Strength',           'espalda', 'Máquina'),
('High Row en Máquina',            'espalda', 'Máquina'),
('Low Row en Máquina',             'espalda', 'Máquina'),
('Iso-Lateral Row',                'espalda', 'Máquina'),
('Pullover en Máquina',            'espalda', 'Máquina'),
('Máquina de Dominadas Asistidas', 'espalda', 'Máquina'),

-- Poleas
('Jalón con Agarre Neutro',       'espalda', 'Polea'),
('Jalón con Agarre Supino',       'espalda', 'Polea'),
('Jalón Unilateral en Polea',     'espalda', 'Polea'),
('Jalón con Agarre V',            'espalda', 'Polea'),
('Remo en Polea Agarre Ancho',    'espalda', 'Polea'),
('Remo en Polea Agarre Cerrado',  'espalda', 'Polea'),
('Remo Unilateral en Polea',      'espalda', 'Polea'),
('Remo Alto en Polea',            'espalda', 'Polea'),
('Remo Arrodillado Unilateral',   'espalda', 'Polea'),
('Pullover Unilateral en Polea',  'espalda', 'Polea'),
('Jalón con Brazos Rectos',       'espalda', 'Polea')

on conflict (name) where owner_id is null do nothing;
