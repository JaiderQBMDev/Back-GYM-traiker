-- Migration 0019: Expand the 'abdomen' exercise catalog
-- Run against the STAGING Supabase project.
--
-- NOT re-inserted here because they already exist (confirmed duplicates):
--   Plancha frontal, Plancha lateral, Mountain climbers, Russian twist
--   (bare bodyweight version — name text conflicts with the existing
--   'Russian twist' which already has equipment 'Mancuernas') (exact
--   matches);
--   Russian twist con mancuerna (= Russian twist), Crunch (= Crunch
--   abdominal), Crunch inverso (= Crunch Invertido), Sit-up (= Sit Ups),
--   V-up (= V-Ups), Bicycle crunch (= Abdominales Bicicleta), Hanging leg
--   raise (= Elevación de piernas colgado), Crunch abdominal en máquina /
--   Crunch con carga selectorizada (= Crunch en Máquina), Woodchopper
--   alto a bajo (= Woodchoppers), Crunch en polea alta / Crunch
--   arrodillado en polea (= Crunch en polea), Ab wheel improvisado con
--   barra y discos / Barbell rollout de rodillas (= Rollout con barra),
--   Anti-rotación en polea (= Pallof press) (confirmed near-duplicates).

insert into public.exercises (name, muscle_group, equipment) values

-- Mancuernas
('Crunch con Mancuerna en el Pecho',           'abdomen', 'Mancuernas'),
('Crunch con Mancuerna Detrás de la Cabeza',   'abdomen', 'Mancuernas'),
('Sit-Up con Mancuerna',                       'abdomen', 'Mancuernas'),
('Sit-Up con Press de Mancuerna',              'abdomen', 'Mancuernas'),
('Giro Ruso Unilateral',                       'abdomen', 'Mancuernas'),
('Side Bend con Mancuerna',                    'abdomen', 'Mancuernas'),
('Crunch Lateral con Mancuerna',               'abdomen', 'Mancuernas'),
('Dead Bug con Mancuerna',                     'abdomen', 'Mancuernas'),
('Hollow Hold con Mancuerna',                  'abdomen', 'Mancuernas'),
('V-Up Sosteniendo Mancuerna',                 'abdomen', 'Mancuernas'),
('Toe Touch con Mancuerna',                    'abdomen', 'Mancuernas'),
('Sit-Up Tipo Pullover con Mancuerna',         'abdomen', 'Mancuernas'),
('Marcha de Granjero Unilateral / Suitcase Carry', 'abdomen', 'Mancuernas'),

-- Barra
('Rollout con Barra',                'abdomen', 'Barra'),
('Sit-Up con Barra Ligera',          'abdomen', 'Barra'),
('Sit-Up con Barra Sobre la Cabeza', 'abdomen', 'Barra'),
('Russian Twist con Barra',          'abdomen', 'Barra'),
('Landmine Rotation',                'abdomen', 'Barra'),
('Landmine Anti-Rotation',           'abdomen', 'Barra'),
('Barbell Rollout de Pie, Avanzado', 'abdomen', 'Barra'),

-- Peso corporal
('Crunch con Piernas Elevadas',          'abdomen', 'Peso corporal'),
('Sit-Up Mariposa',                      'abdomen', 'Peso corporal'),
('Tuck-Up',                              'abdomen', 'Peso corporal'),
('Toe Touches',                          'abdomen', 'Peso corporal'),
('Elevaciones de Piernas Acostado',      'abdomen', 'Peso corporal'),
('Elevaciones de Rodillas',              'abdomen', 'Peso corporal'),
('Flutter Kicks',                        'abdomen', 'Peso corporal'),
('Scissor Kicks',                        'abdomen', 'Peso corporal'),
('Hollow Body Hold',                     'abdomen', 'Peso corporal'),
('Hollow Rocks',                         'abdomen', 'Peso corporal'),
('Dead Bug',                             'abdomen', 'Peso corporal'),
('Plancha Lateral con Elevación de Cadera', 'abdomen', 'Peso corporal'),
('Plancha con Toque de Hombros',         'abdomen', 'Peso corporal'),
('Body Saw',                             'abdomen', 'Peso corporal'),
('Cross-Body Mountain Climbers',         'abdomen', 'Peso corporal'),
('Heel Touches',                         'abdomen', 'Peso corporal'),
('Crunch Oblicuo',                       'abdomen', 'Peso corporal'),
('Windshield Wipers',                    'abdomen', 'Peso corporal'),
('Dragon Flag',                          'abdomen', 'Peso corporal'),
('L-Sit',                                'abdomen', 'Peso corporal'),
('Tuck L-Sit',                           'abdomen', 'Peso corporal'),
('Hanging Knee Raise',                   'abdomen', 'Peso corporal'),
('Toes to Bar',                          'abdomen', 'Peso corporal'),
('Hanging Windshield Wipers',            'abdomen', 'Peso corporal'),
('Garhammer Raise',                      'abdomen', 'Peso corporal'),
('Plank Walkout',                        'abdomen', 'Peso corporal'),
('Bear Plank',                           'abdomen', 'Peso corporal'),

-- Máquinas
('Crunch Abdominal Sentado',           'abdomen', 'Máquina'),
('Máquina de Abdominales Convergente', 'abdomen', 'Máquina'),
('Máquina de Rotación de Torso',       'abdomen', 'Máquina'),
('Máquina de Oblicuos',                'abdomen', 'Máquina'),
('Captain''s Chair Knee Raise',        'abdomen', 'Máquina'),
('Captain''s Chair Leg Raise',         'abdomen', 'Máquina'),
('Ab Coaster',                         'abdomen', 'Máquina'),
('Máquina de Crunch Arrodillado',      'abdomen', 'Máquina'),

-- Poleas
('Crunch de Pie en Polea',           'abdomen', 'Polea'),
('Crunch Unilateral en Polea',       'abdomen', 'Polea'),
('Crunch Lateral en Polea',          'abdomen', 'Polea'),
('Woodchopper Bajo a Alto',          'abdomen', 'Polea'),
('Rotación Horizontal en Polea',     'abdomen', 'Polea'),
('Pallof Press',                     'abdomen', 'Polea'),
('Pallof Hold',                      'abdomen', 'Polea'),
('Pallof Press Arrodillado',         'abdomen', 'Polea'),
('Pallof Press Medio Arrodillado',   'abdomen', 'Polea'),
('Reverse Crunch con Polea Baja',    'abdomen', 'Polea')

on conflict (name) where owner_id is null do nothing;
