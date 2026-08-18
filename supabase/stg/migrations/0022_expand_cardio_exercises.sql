-- Migration 0022: Expand the 'cardio' exercise catalog
-- Run against the STAGING Supabase project.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Jumping jacks, Burpees, Bicicleta estática, Elíptica, Remo ergómetro
--   (exact matches);
--   Caminadora (= Cinta de correr), Caminata inclinada (= Caminata en
--   Cinta), Carrera en caminadora (= Cinta de correr, same reasoning as
--   'Correr en Cinta' merged earlier), Escaladora / StairMaster
--   (= Escaladora), Salto básico (= Saltar la cuerda), Sprints en
--   bicicleta (= Sprint en Bicicleta) (confirmed near-duplicates of
--   existing entries);
--   Speed skaters (= Skater jumps), Stepper (= Escaladora / StairMaster),
--   Ondas alternas con battle rope (= Battle ropes), Med ball slams
--   (= Lanzamientos de balón medicinal), Suicide runs (= Shuttle runs),
--   Spinning (= Bicicleta de spinning) (confirmed internal duplicates
--   within this same list).
--
-- Also NOT inserted: Mountain climbers (already exists under 'abdomen'),
-- Farmer carry rápido (already exists under 'antebrazo' as 'Farmer
-- Walk') — confirmed cross-muscle-group duplicates.
--
-- "Espalda" (swim stroke) was renamed to "Nado de Espalda" to avoid
-- confusion with the 'espalda' muscle group in exercise pickers.
--
-- New equipment tags introduced for implements/contexts not covered by
-- the existing set: 'Battle Rope', 'Sled', 'Sandbag', 'Balón Medicinal',
-- 'Kettlebell', 'Bicicleta', 'Natación'.

insert into public.exercises (name, muscle_group, equipment) values

-- Peso corporal
('High Knees',                    'cardio', 'Peso corporal'),
('Butt Kicks',                    'cardio', 'Peso corporal'),
('Squat Jumps',                   'cardio', 'Peso corporal'),
('Jump Lunges',                   'cardio', 'Peso corporal'),
('Skater Jumps',                  'cardio', 'Peso corporal'),
('Lateral Hops',                  'cardio', 'Peso corporal'),
('Tuck Jumps',                    'cardio', 'Peso corporal'),
('Broad Jumps',                   'cardio', 'Peso corporal'),
('Star Jumps',                    'cardio', 'Peso corporal'),
('Bear Crawl Rápido',             'cardio', 'Peso corporal'),
('Crab Walk Rápido',              'cardio', 'Peso corporal'),
('Inchworm Dinámico',             'cardio', 'Peso corporal'),
('Shadow Boxing',                 'cardio', 'Peso corporal'),
('Sprint en el Sitio',            'cardio', 'Peso corporal'),
('Marcha Rápida en el Sitio',     'cardio', 'Peso corporal'),
('Step-Ups Rápidos',              'cardio', 'Peso corporal'),
('Plank Jacks',                   'cardio', 'Peso corporal'),
('Lateral Shuffle',               'cardio', 'Peso corporal'),
('Carioca / Grapevine',           'cardio', 'Peso corporal'),
('Saltos de Cuerda sin Cuerda',   'cardio', 'Peso corporal'),

-- Máquinas de cardio
('Trote en Caminadora',                  'cardio', 'Máquina'),
('Sprint en Caminadora',                 'cardio', 'Máquina'),
('Bicicleta de Spinning',                'cardio', 'Máquina'),
('Bicicleta Reclinada',                  'cardio', 'Máquina'),
('SkiErg',                               'cardio', 'Máquina'),
('Air Bike / Assault Bike',              'cardio', 'Máquina'),
('Bicicleta de Brazos / Arm Ergometer',  'cardio', 'Máquina'),
('Arc Trainer',                          'cardio', 'Máquina'),

-- Con cuerda
('Salto Alternando Pies',       'cardio', 'Cuerda'),
('Boxer Step',                  'cardio', 'Cuerda'),
('High Knees con Cuerda',       'cardio', 'Cuerda'),
('Saltos Laterales',            'cardio', 'Cuerda'),
('Saltos Adelante y Atrás',     'cardio', 'Cuerda'),
('Double Unders',               'cardio', 'Cuerda'),
('Crossovers',                  'cardio', 'Cuerda'),
('Saltos a Una Pierna',         'cardio', 'Cuerda'),
('Running Step con Cuerda',     'cardio', 'Cuerda'),

-- Con implementos
('Battle Ropes',                              'cardio', 'Battle Rope'),
('Ondas Dobles',                              'cardio', 'Battle Rope'),
('Slams con Battle Rope',                     'cardio', 'Battle Rope'),
('Círculos con Battle Rope',                  'cardio', 'Battle Rope'),
('Sled Push',                                 'cardio', 'Sled'),
('Sled Pull',                                 'cardio', 'Sled'),
('Sandbag Carry',                             'cardio', 'Sandbag'),
('Lanzamientos de Balón Medicinal',           'cardio', 'Balón Medicinal'),
('Kettlebell Swings',                         'cardio', 'Kettlebell'),
('Step-Ups con Carga Ligera a Ritmo Continuo', 'cardio', 'Mancuernas'),

-- Carrera y desplazamientos
('Caminata Rápida',        'cardio', 'Peso corporal'),
('Trote',                  'cardio', 'Peso corporal'),
('Carrera Continua',       'cardio', 'Peso corporal'),
('Sprint',                 'cardio', 'Peso corporal'),
('Sprint en Cuesta',       'cardio', 'Peso corporal'),
('Intervalos de Carrera',  'cardio', 'Peso corporal'),
('Shuttle Runs',           'cardio', 'Peso corporal'),
('Fartlek',                'cardio', 'Peso corporal'),
('Carrera Lateral',        'cardio', 'Peso corporal'),
('Backward Running',       'cardio', 'Peso corporal'),
('Subir Escaleras',        'cardio', 'Peso corporal'),
('Subir Cuestas',          'cardio', 'Peso corporal'),
('Hiking a Ritmo Intenso', 'cardio', 'Peso corporal'),

-- Bicicleta
('Pedaleo Continuo Suave',        'cardio', 'Bicicleta'),
('Pedaleo Moderado',              'cardio', 'Bicicleta'),
('Intervalos de Alta Intensidad', 'cardio', 'Bicicleta'),
('Subidas con Alta Resistencia',  'cardio', 'Bicicleta'),
('Bicicleta al Aire Libre',       'cardio', 'Bicicleta'),

-- Natación
('Crol',           'cardio', 'Natación'),
('Nado de Espalda', 'cardio', 'Natación'),
('Braza',          'cardio', 'Natación'),
('Mariposa',       'cardio', 'Natación'),
('Nado Continuo',  'cardio', 'Natación'),
('Series Rápidas', 'cardio', 'Natación'),
('Aqua Jogging',   'cardio', 'Natación')

on conflict (name) where owner_id is null do nothing;
