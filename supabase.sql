-- Rode no Supabase: SQL Editor > New query > Run
-- TROQUE o e-mail abaixo pelo e-mail que vai logar no painel
create table consultas (
  id uuid primary key default gen_random_uuid(),
  data date not null,
  hora time not null,
  nome text not null,
  whatsapp text,
  modalidade text not null default 'Presencial',
  link_sessao text,
  status text not null default 'Nova',
  pago boolean not null default false,
  valor numeric(10,2) not null default 180,
  criado_em timestamptz not null default now()
);
create unique index consultas_horario on consultas (data, hora) where status <> 'Cancelada';

alter table consultas enable row level security;

create policy "paciente agenda" on consultas for insert to anon
  with check (status = 'Nova' and pago = false);
create policy "dona le" on consultas for select to authenticated
  using ((auth.jwt() ->> 'email') = 'lucasvieira.pro@hotmail.com');
create policy "dona edita" on consultas for update to authenticated
  using ((auth.jwt() ->> 'email') = 'lucasvieira.pro@hotmail.com');
create policy "dona apaga" on consultas for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'lucasvieira.pro@hotmail.com');

-- O site público só descobre QUAIS horários estão ocupados, nunca quem marcou
create function horarios_ocupados(dia date) returns table(hora time)
language sql security definer set search_path = public as $$
  select hora from consultas where data = dia and status <> 'Cancelada'
$$;
grant execute on function horarios_ocupados(date) to anon, authenticated;
