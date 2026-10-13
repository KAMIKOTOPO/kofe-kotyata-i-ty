-- Выполни весь файл в Supabase Dashboard -> SQL Editor -> New query.
-- Ответы доступны для INSERT посетителям, но SELECT разрешён только вошедшим пользователям.
-- Не включай публичную регистрацию пользователей в Supabase Auth.

create table if not exists public.game_answers (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  final_answer text not null check (final_answer in ('yes', 'maybe', 'no')),
  answers jsonb not null default '[]'::jsonb
);

alter table public.game_answers enable row level security;

revoke all on table public.game_answers from anon, authenticated;
grant insert on table public.game_answers to anon;
grant select on table public.game_answers to authenticated;

-- Посетитель может только отправить один из допустимых финальных вариантов.
drop policy if exists "Visitors can submit an answer" on public.game_answers;
create policy "Visitors can submit an answer"
  on public.game_answers for insert to anon
  with check (
    final_answer in ('yes', 'maybe', 'no')
    and jsonb_typeof(answers) = 'array'
    and jsonb_array_length(answers) <= 20
  );

-- Чтение возможно только после входа через Supabase Auth.
-- Создай единственный аккаунт администратора вручную и оставь Sign-ups выключенными.
drop policy if exists "Signed-in admin can read answers" on public.game_answers;
create policy "Signed-in admin can read answers"
  on public.game_answers for select to authenticated
  using (true);
