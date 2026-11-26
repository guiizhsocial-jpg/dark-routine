-- Dark Routine Social: migration de reparo e permissões. Execute uma vez no Supabase SQL Editor.
-- Reforça grants e substitui políticas de perfil para corrigir bloqueios comuns de RLS.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.friendships to authenticated;
grant select, insert, update, delete on public.social_posts to authenticated;
grant select, insert, update, delete on public.post_reactions to authenticated;
grant select, insert, update, delete on public.post_comments to authenticated;
grant select, insert, update, delete on public.social_challenges to authenticated;
grant select, insert, update, delete on public.challenge_members to authenticated;
grant select, insert, update, delete on public.private_backups to authenticated;

-- Remove políticas anteriores de perfis e recria políticas permissivas, mas limitando escrita ao proprietário.
drop policy if exists "signed-in profile directory" on public.profiles;
drop policy if exists "edit own profile" on public.profiles;
drop policy if exists "update own profile" on public.profiles;
drop policy if exists "profile select signed in" on public.profiles;
drop policy if exists "profile insert self" on public.profiles;
drop policy if exists "profile update self" on public.profiles;
create policy "profile select signed in" on public.profiles for select to authenticated using (true);
create policy "profile insert self" on public.profiles for insert to authenticated with check (id=auth.uid());
create policy "profile update self" on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());

-- Deixa o diretório de username e posts acessível somente para usuários autenticados.
-- Mantém os grants e RLS existentes nas demais tabelas. Nenhuma chave service_role deve ir ao frontend.

-- Reforça permissões de amizade (apenas o destinatário pode aceitar uma solicitação pendente).
drop policy if exists "read friendship rows involving self" on public.friendships;
drop policy if exists "send friend request" on public.friendships;
drop policy if exists "recipient accepts" on public.friendships;
drop policy if exists "participants delete friendship" on public.friendships;
create policy "read friendship rows involving self" on public.friendships for select to authenticated using (requester=auth.uid() or addressee=auth.uid());
create policy "send friend request" on public.friendships for insert to authenticated with check (requester=auth.uid() and status='pending');
create policy "recipient accepts" on public.friendships for update to authenticated using (addressee=auth.uid() and status='pending') with check (addressee=auth.uid() and status='accepted');
create policy "participants delete friendship" on public.friendships for delete to authenticated using (requester=auth.uid() or addressee=auth.uid());
