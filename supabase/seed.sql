-- Global exercise catalog (owner_id null = visible to all users).
-- Covers the routines shown in the design: Pecho y Tríceps, Espalda y
-- Bíceps, Piernas, Full Body.

insert into public.exercises (name, muscle_group) values
  ('Press de Banca', 'pecho'),
  ('Press Inclinado', 'pecho'),
  ('Aperturas', 'pecho'),
  ('Fondos en paralelas', 'triceps'),
  ('Press Francés', 'triceps'),
  ('Extensión Tríceps', 'triceps'),
  ('Dominadas', 'espalda'),
  ('Remo con Barra', 'espalda'),
  ('Jalón al Pecho', 'espalda'),
  ('Remo en Máquina', 'espalda'),
  ('Curl con Barra', 'biceps'),
  ('Curl Martillo', 'biceps'),
  ('Sentadilla', 'piernas'),
  ('Prensa de Piernas', 'piernas'),
  ('Peso Muerto Rumano', 'piernas'),
  ('Extensión de Cuádriceps', 'piernas'),
  ('Curl Femoral', 'piernas'),
  ('Elevación de Talones', 'pantorrillas'),
  ('Press Militar', 'hombros'),
  ('Elevaciones Laterales', 'hombros'),
  ('Plancha', 'abdomen'),
  ('Crunch en Máquina', 'abdomen')
on conflict (name) where owner_id is null do nothing;
