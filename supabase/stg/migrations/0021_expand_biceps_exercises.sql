-- Migration 0021: Expand the 'biceps' exercise catalog
-- Run against the STAGING Supabase project.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Curl inclinado con mancuernas, Curl martillo (exact matches);
--   Curl concentración (= Curl concentrado), Curl con barra recta
--   (= Curl con barra), Curl con barra EZ (= Curl con barra Z), Curl
--   predicador con barra (= Curl en banco Scott), Curl tipo Scott en
--   máquina (= Curl predicador en máquina), Curl de pie con polea baja
--   (= Curl en polea), Curl con giro de muñeca (= Curl Zottman), Curl
--   Bayesian unilateral (= Curl Bayesian), Bodyweight biceps curl en
--   barra baja (= Curl de bíceps invertido bajo barra) (confirmed
--   near-duplicates);
--   Curl alterno con mancuernas (confirmed = the existing generic 'Curl
--   con mancuernas'), Curl spider con mancuernas (confirmed = the
--   existing generic 'Curl Araña'), Curl 21 con barra (confirmed = the
--   existing generic 'Curl 21s').
--
-- Also NOT inserted: Curl inverso con barra / Curl inverso en polea
-- (already exist under 'antebrazo'); Chin-up / dominada supina and its
-- variants — agarre cerrado, con pausa, archer, asistido a una mano —
-- (already exist under 'espalda' as 'Dominadas...', added in 0016).

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Curl Simultáneo con Mancuernas',              'biceps', 'Mancuernas'),
('Curl Sentado con Mancuernas',                 'biceps', 'Mancuernas'),
('Curl de Pie con Mancuernas',                  'biceps', 'Mancuernas'),
('Curl Predicador con Mancuerna',                'biceps', 'Mancuernas'),
('Curl Supino Unilateral',                       'biceps', 'Mancuernas'),
('Curl Martillo Cruzado',                        'biceps', 'Mancuernas'),
('Curl Zottman',                                 'biceps', 'Mancuernas'),
('Curl Bayesian Improvisado con Banco y Mancuerna', 'biceps', 'Mancuernas'),
('Curl 21 con Mancuernas',                       'biceps', 'Mancuernas'),

-- Barra
('Curl con Agarre Ancho',        'biceps', 'Barra'),
('Curl con Agarre Cerrado',      'biceps', 'Barra'),
('Curl Spider con Barra',        'biceps', 'Barra'),
('Curl de Arrastre / Drag Curl', 'biceps', 'Barra'),
('Curl Estricto con Barra',      'biceps', 'Barra'),
('Curl Sentado con Barra',       'biceps', 'Barra'),
('Curl con Pausa',               'biceps', 'Barra'),
('Curl con Tempo Lento',         'biceps', 'Barra'),

-- Peso corporal
('Chin-Up Excéntrico',                'biceps', 'Peso corporal'),
('Chin-Up Isométrico',                'biceps', 'Peso corporal'),
('Curl de Bíceps Invertido bajo Barra', 'biceps', 'Peso corporal'),
('Curl de Bíceps en Anillas',         'biceps', 'Peso corporal'),
('Curl Unilateral Asistido en Anillas', 'biceps', 'Peso corporal'),
('Curl de Bíceps con Toalla',         'biceps', 'Peso corporal'),

-- Máquinas
('Curl de Bíceps en Máquina',              'biceps', 'Máquina'),
('Curl Predicador en Máquina',             'biceps', 'Máquina'),
('Curl Unilateral en Máquina',             'biceps', 'Máquina'),
('Curl Convergente en Máquina',            'biceps', 'Máquina'),
('Curl Sentado en Máquina',                'biceps', 'Máquina'),
('Curl Tipo Hammer Strength para Bíceps',  'biceps', 'Máquina'),
('Máquina de Curl con Agarre Neutro',      'biceps', 'Máquina'),

-- Poleas
('Curl con Barra Recta en Polea Baja',   'biceps', 'Polea'),
('Curl con Barra EZ en Polea',           'biceps', 'Polea'),
('Curl con Cuerda',                      'biceps', 'Polea'),
('Curl Martillo con Cuerda',             'biceps', 'Polea'),
('Curl Unilateral en Polea',             'biceps', 'Polea'),
('Curl Bayesian',                        'biceps', 'Polea'),
('Curl Predicador en Polea',             'biceps', 'Polea'),
('Curl Spider en Polea',                 'biceps', 'Polea'),
('Curl con Polea Alta',                  'biceps', 'Polea'),
('Curl Doble desde Poleas Altas',        'biceps', 'Polea'),
('Curl Detrás de la Cabeza con Poleas',  'biceps', 'Polea'),
('Curl Acostado en Polea',               'biceps', 'Polea'),
('Drag Curl en Polea',                   'biceps', 'Polea'),
('Curl 21 en Polea',                     'biceps', 'Polea')

on conflict (name) where owner_id is null do nothing;
