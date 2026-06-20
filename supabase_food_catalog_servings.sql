alter table public.food_catalog add column if not exists brand text;
alter table public.food_catalog add column if not exists serving_label text;
alter table public.food_catalog add column if not exists serving_qty numeric;
alter table public.food_catalog add column if not exists serving_unit text;
alter table public.food_catalog add column if not exists serving_grams numeric;
alter table public.food_catalog add column if not exists serving_options jsonb not null default '[]'::jsonb;
alter table public.food_catalog add column if not exists verified boolean not null default false;

create index if not exists food_catalog_brand_lower_idx
  on public.food_catalog (lower(brand));

comment on column public.food_catalog.serving_label is 'Porcao amigavel exibida ao cliente, ex: 1 pote, 1 fatia, 1 scoop.';
comment on column public.food_catalog.serving_qty is 'Quantidade padrao da porcao amigavel.';
comment on column public.food_catalog.serving_unit is 'Unidade da porcao amigavel, ex: un, fatia, pote, scoop.';
comment on column public.food_catalog.serving_grams is 'Equivalencia da porcao amigavel em g/ml para calculo nutricional.';
comment on column public.food_catalog.serving_options is 'Opcoes extras de porcao: [{"label":"1 fatia","qty":1,"unit":"fatia","grams":25}].';
