-- Seed global exercises (owner_id = NULL) for every muscle group.
-- Uses ON CONFLICT to skip if the exercise already exists.

INSERT INTO public.exercises (owner_id, name, muscle_group, equipment) VALUES

-- ── PECHO ──────────────────────────────────────────────────────────────
(NULL, 'Press de banca con barra',       'pecho', 'Barra'),
(NULL, 'Press de banca inclinado',        'pecho', 'Barra'),
(NULL, 'Press de banca declinado',        'pecho', 'Barra'),
(NULL, 'Press con mancuernas',            'pecho', 'Mancuernas'),
(NULL, 'Press inclinado con mancuernas',  'pecho', 'Mancuernas'),
(NULL, 'Aperturas con mancuernas',        'pecho', 'Mancuernas'),
(NULL, 'Aperturas en polea',              'pecho', 'Polea'),
(NULL, 'Fondos en paralelas',             'pecho', 'Peso corporal'),
(NULL, 'Press en máquina',                'pecho', 'Máquina'),
(NULL, 'Flexiones de pecho',              'pecho', 'Peso corporal'),

-- ── ESPALDA ────────────────────────────────────────────────────────────
(NULL, 'Dominadas',                       'espalda', 'Peso corporal'),
(NULL, 'Jalón al pecho',                  'espalda', 'Polea'),
(NULL, 'Remo con barra',                  'espalda', 'Barra'),
(NULL, 'Remo con mancuerna',              'espalda', 'Mancuernas'),
(NULL, 'Remo en polea baja',              'espalda', 'Polea'),
(NULL, 'Remo en máquina',                 'espalda', 'Máquina'),
(NULL, 'Pullover con mancuerna',          'espalda', 'Mancuernas'),
(NULL, 'Jalón tras nuca',                 'espalda', 'Polea'),
(NULL, 'Peso muerto',                     'espalda', 'Barra'),
(NULL, 'Face pull',                       'espalda', 'Polea'),

-- ── PIERNAS ────────────────────────────────────────────────────────────
(NULL, 'Sentadilla con barra',            'piernas', 'Barra'),
(NULL, 'Prensa de piernas',               'piernas', 'Máquina'),
(NULL, 'Sentadilla búlgara',              'piernas', 'Mancuernas'),
(NULL, 'Extensión de cuádriceps',         'piernas', 'Máquina'),
(NULL, 'Curl femoral acostado',           'piernas', 'Máquina'),
(NULL, 'Curl femoral sentado',            'piernas', 'Máquina'),
(NULL, 'Sentadilla hack',                 'piernas', 'Máquina'),
(NULL, 'Zancadas con mancuernas',         'piernas', 'Mancuernas'),
(NULL, 'Peso muerto rumano',              'piernas', 'Barra'),
(NULL, 'Sentadilla goblet',               'piernas', 'Mancuernas'),

-- ── HOMBROS ────────────────────────────────────────────────────────────
(NULL, 'Press militar con barra',         'hombros', 'Barra'),
(NULL, 'Press con mancuernas (hombro)',   'hombros', 'Mancuernas'),
(NULL, 'Elevaciones laterales',           'hombros', 'Mancuernas'),
(NULL, 'Elevaciones frontales',           'hombros', 'Mancuernas'),
(NULL, 'Pájaros con mancuernas',          'hombros', 'Mancuernas'),
(NULL, 'Press Arnold',                    'hombros', 'Mancuernas'),
(NULL, 'Elevaciones laterales en polea',  'hombros', 'Polea'),
(NULL, 'Press en máquina (hombro)',       'hombros', 'Máquina'),

-- ── BÍCEPS ─────────────────────────────────────────────────────────────
(NULL, 'Curl con barra',                  'biceps', 'Barra'),
(NULL, 'Curl con mancuernas',             'biceps', 'Mancuernas'),
(NULL, 'Curl martillo',                   'biceps', 'Mancuernas'),
(NULL, 'Curl en banco Scott',             'biceps', 'Barra'),
(NULL, 'Curl en polea',                   'biceps', 'Polea'),
(NULL, 'Curl concentrado',                'biceps', 'Mancuernas'),
(NULL, 'Curl con barra Z',               'biceps', 'Barra'),

-- ── TRÍCEPS ────────────────────────────────────────────────────────────
(NULL, 'Extensión de tríceps en polea',   'triceps', 'Polea'),
(NULL, 'Press francés',                   'triceps', 'Barra'),
(NULL, 'Fondos en banco',                 'triceps', 'Peso corporal'),
(NULL, 'Extensión con mancuerna',         'triceps', 'Mancuernas'),
(NULL, 'Patada de tríceps',               'triceps', 'Mancuernas'),
(NULL, 'Press cerrado',                   'triceps', 'Barra'),
(NULL, 'Extensión de tríceps con cuerda', 'triceps', 'Polea'),

-- ── ABDOMEN ────────────────────────────────────────────────────────────
(NULL, 'Crunch abdominal',                'abdomen', 'Peso corporal'),
(NULL, 'Crunch en polea',                 'abdomen', 'Polea'),
(NULL, 'Plancha frontal',                 'abdomen', 'Peso corporal'),
(NULL, 'Plancha lateral',                 'abdomen', 'Peso corporal'),
(NULL, 'Elevación de piernas colgado',    'abdomen', 'Peso corporal'),
(NULL, 'Russian twist',                   'abdomen', 'Mancuernas'),
(NULL, 'Ab wheel',                        'abdomen', 'Rueda abdominal'),

-- ── GLÚTEOS ────────────────────────────────────────────────────────────
(NULL, 'Hip thrust con barra',            'gluteos', 'Barra'),
(NULL, 'Patada de glúteo en polea',       'gluteos', 'Polea'),
(NULL, 'Puente de glúteos',               'gluteos', 'Peso corporal'),
(NULL, 'Abducción de cadera en máquina',  'gluteos', 'Máquina'),
(NULL, 'Sentadilla sumo',                 'gluteos', 'Mancuernas'),
(NULL, 'Step up con mancuernas',          'gluteos', 'Mancuernas'),

-- ── PANTORRILLAS ───────────────────────────────────────────────────────
(NULL, 'Elevación de talones de pie',     'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones sentado',    'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones en prensa',  'pantorrillas', 'Máquina'),
(NULL, 'Elevación de talones con mancuerna', 'pantorrillas', 'Mancuernas'),

-- ── CARDIO ─────────────────────────────────────────────────────────────
(NULL, 'Cinta de correr',                 'cardio', 'Máquina'),
(NULL, 'Bicicleta estática',              'cardio', 'Máquina'),
(NULL, 'Elíptica',                        'cardio', 'Máquina'),
(NULL, 'Remo ergómetro',                  'cardio', 'Máquina'),
(NULL, 'Saltar la cuerda',                'cardio', 'Cuerda'),
(NULL, 'Escaladora',                      'cardio', 'Máquina'),
(NULL, 'Burpees',                         'cardio', 'Peso corporal')

ON CONFLICT DO NOTHING;
