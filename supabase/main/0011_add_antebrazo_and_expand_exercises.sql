-- Migration 0011: Add 'antebrazo' to muscle_group enum + expand exercise catalog
-- Run against the PRODUCTION Supabase project.

-- 1. Add new enum value
alter type muscle_group add value if not exists 'antebrazo';

-- 2. Insert new exercises (on conflict = skip duplicates)
insert into public.exercises (name, muscle_group) values
  -- Pecho (nuevos)
  ('Press Declinado', 'pecho'),
  ('Aperturas Inclinadas', 'pecho'),
  ('Aperturas en Máquina', 'pecho'),
  ('Press con Mancuernas', 'pecho'),
  ('Press Inclinado con Mancuernas', 'pecho'),
  ('Press Declinado con Mancuernas', 'pecho'),
  ('Crossover en Polea', 'pecho'),
  ('Pullover con Mancuerna', 'pecho'),
  ('Flexiones de Pecho', 'pecho'),
  ('Press en Máquina', 'pecho'),
  ('Fondos para Pecho', 'pecho'),

  -- Espalda (nuevos)
  ('Dominadas con Agarre Cerrado', 'espalda'),
  ('Remo con Mancuerna', 'espalda'),
  ('Jalón Tras Nuca', 'espalda'),
  ('Jalón con Agarre Cerrado', 'espalda'),
  ('Remo en Polea Baja', 'espalda'),
  ('Remo con Barra T', 'espalda'),
  ('Peso Muerto', 'espalda'),
  ('Pullover en Polea', 'espalda'),
  ('Face Pull', 'espalda'),
  ('Remo Pendlay', 'espalda'),
  ('Encogimientos con Barra', 'espalda'),
  ('Encogimientos con Mancuernas', 'espalda'),
  ('Hiperextensiones', 'espalda'),

  -- Piernas (nuevos)
  ('Sentadilla Frontal', 'piernas'),
  ('Sentadilla Búlgara', 'piernas'),
  ('Sentadilla Hack', 'piernas'),
  ('Sentadilla Goblet', 'piernas'),
  ('Prensa de Piernas 45°', 'piernas'),
  ('Peso Muerto Sumo', 'piernas'),
  ('Curl Femoral Sentado', 'piernas'),
  ('Zancadas con Mancuernas', 'piernas'),
  ('Zancadas Caminando', 'piernas'),
  ('Step Up', 'piernas'),
  ('Aductores en Máquina', 'piernas'),
  ('Abductores en Máquina', 'piernas'),
  ('Buenos Días', 'piernas'),

  -- Hombros (nuevos)
  ('Press Militar con Mancuernas', 'hombros'),
  ('Press Arnold', 'hombros'),
  ('Elevaciones Laterales en Polea', 'hombros'),
  ('Elevaciones Frontales', 'hombros'),
  ('Elevaciones Frontales con Barra', 'hombros'),
  ('Pájaros', 'hombros'),
  ('Pájaros en Máquina', 'hombros'),
  ('Remo al Mentón', 'hombros'),
  ('Press en Máquina de Hombros', 'hombros'),
  ('Encogimientos en Máquina', 'hombros'),

  -- Bíceps (nuevos)
  ('Curl con Barra Z', 'biceps'),
  ('Curl con Mancuernas', 'biceps'),
  ('Curl Concentrado', 'biceps'),
  ('Curl en Banco Scott', 'biceps'),
  ('Curl en Polea', 'biceps'),
  ('Curl en Polea Alta', 'biceps'),
  ('Curl Inclinado con Mancuernas', 'biceps'),
  ('Curl Araña', 'biceps'),
  ('Curl 21s', 'biceps'),

  -- Tríceps (nuevos)
  ('Press Francés con Mancuernas', 'triceps'),
  ('Extensión Tríceps en Polea', 'triceps'),
  ('Extensión Tríceps con Cuerda', 'triceps'),
  ('Patada de Tríceps', 'triceps'),
  ('Press Cerrado', 'triceps'),
  ('Fondos en Banco', 'triceps'),
  ('Extensión Tríceps sobre Cabeza', 'triceps'),
  ('Extensión Tríceps con Barra Z', 'triceps'),

  -- Abdomen (nuevos)
  ('Plancha Lateral', 'abdomen'),
  ('Crunch en Polea', 'abdomen'),
  ('Crunch Invertido', 'abdomen'),
  ('Elevación de Piernas Colgado', 'abdomen'),
  ('Elevación de Piernas en Banco', 'abdomen'),
  ('Rueda Abdominal', 'abdomen'),
  ('Abdominales Bicicleta', 'abdomen'),
  ('Mountain Climbers', 'abdomen'),
  ('V-Ups', 'abdomen'),
  ('Woodchoppers', 'abdomen'),
  ('Sit Ups', 'abdomen'),

  -- Glúteos (nuevos)
  ('Hip Thrust con Barra', 'gluteos'),
  ('Hip Thrust en Máquina', 'gluteos'),
  ('Puente de Glúteos', 'gluteos'),
  ('Patada de Glúteo en Polea', 'gluteos'),
  ('Patada de Glúteo en Máquina', 'gluteos'),
  ('Sentadilla Sumo', 'gluteos'),
  ('Peso Muerto con Piernas Rígidas', 'gluteos'),
  ('Abducción de Cadera', 'gluteos'),
  ('Clamshell', 'gluteos'),

  -- Pantorrillas (nuevos)
  ('Elevación de Talones Sentado', 'pantorrillas'),
  ('Elevación de Talones en Prensa', 'pantorrillas'),
  ('Elevación de Talones con Mancuerna', 'pantorrillas'),
  ('Elevación de Talones a Una Pierna', 'pantorrillas'),
  ('Saltos de Pantorrilla', 'pantorrillas'),

  -- Antebrazo (todos nuevos)
  ('Curl de Muñeca con Barra', 'antebrazo'),
  ('Curl de Muñeca Inverso', 'antebrazo'),
  ('Curl Inverso con Barra', 'antebrazo'),
  ('Curl Inverso con Mancuernas', 'antebrazo'),
  ('Roller de Muñeca', 'antebrazo'),
  ('Farmer Walk', 'antebrazo'),
  ('Agarre con Pinza', 'antebrazo'),
  ('Dead Hang', 'antebrazo'),

  -- Cardio (todos nuevos)
  ('Caminata en Cinta', 'cardio'),
  ('Correr en Cinta', 'cardio'),
  ('Bicicleta Estática', 'cardio'),
  ('Elíptica', 'cardio'),
  ('Remo en Máquina Cardio', 'cardio'),
  ('Saltar la Cuerda', 'cardio'),
  ('Burpees', 'cardio'),
  ('Jumping Jacks', 'cardio'),
  ('Escaladora', 'cardio'),
  ('Sprint en Bicicleta', 'cardio')

on conflict (name) where owner_id is null do nothing;
