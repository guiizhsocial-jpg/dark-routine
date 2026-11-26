
-- Dark Routine Social v2
-- Execute once in Supabase > SQL Editor > New query.
-- This migration adds follows, private-account follow requests and post visibility.
-- It preserves the existing friendships, posts, comments, reactions, challenges and DMs.

alter table public.profiles
  add column if not exists privacy text not null default 'friends';

alter table public.social_posts
  add column if not exists visibility text not null default 'public';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'social_posts_visibility_check'
      and conrelid = 'public.social_posts'::regclass
  ) then
    alter table public.social_posts
      add constraint social_posts_visibility_check
      check (visibility in ('public','followers'));
  end if;
end $$;

create table if not exists public.social_follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  unique (follower_id, following_id),
  check (follower_id <> following_id)
);

create index if not exists social_follows_following_status_idx
  on public.social_follows(following_id, status);
create index if not exists social_follows_follower_status_idx
  on public.social_follows(follower_id, status);

alter table public.social_follows enable row level security;

drop policy if exists drs_follows_select_participants on public.social_follows;
create policy drs_follows_select_participants
  on public.social_follows for select to authenticated
  using (auth.uid() = follower_id or auth.uid() = following_id);

drop policy if exists drs_follows_delete_participants on public.social_follows;
create policy drs_follows_delete_participants
  on public.social_follows for delete to authenticated
  using (auth.uid() = follower_id or auth.uid() = following_id);

create or replace function public.social_follow_user(target_user uuid)
returns text
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid uuid := auth.uid();
  v_privacy text;
  v_status text;
begin
  if v_uid is null then raise exception 'Faça login para seguir pessoas.'; end if;
  if target_user is null or target_user = v_uid then raise exception 'Não é possível seguir esta conta.'; end if;

  select coalesce(privacy, 'friends') into v_privacy
  from public.profiles where id = target_user;

  if not found then raise exception 'Perfil não encontrado.'; end if;

  v_status := case when v_privacy = 'public' then 'accepted' else 'pending' end;

  insert into public.social_follows(follower_id, following_id, status)
  values (v_uid, target_user, v_status)
  on conflict (follower_id, following_id)
  do update set status = case
    when social_follows.status = 'accepted' then 'accepted'
    else excluded.status
  end;

  select status into v_status from public.social_follows
  where follower_id = v_uid and following_id = target_user;

  return v_status;
end;
$$;

create or replace function public.social_respond_follow(follow_id uuid, approve boolean)
returns text
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid uuid := auth.uid();
  v_status text;
begin
  if v_uid is null then raise exception 'Faça login novamente.'; end if;

  if approve then
    update public.social_follows
      set status = 'accepted'
      where id = follow_id and following_id = v_uid and status = 'pending'
      returning status into v_status;
    if v_status is null then raise exception 'Solicitação não encontrada.'; end if;
    return 'accepted';
  else
    delete from public.social_follows
      where id = follow_id and following_id = v_uid and status = 'pending';
    return 'rejected';
  end if;
end;
$$;

create or replace function public.social_follow_counts(target_user uuid)
returns table(followers bigint, following bigint)
language sql
security definer
set search_path = public
as $$
  select
    (select count(*) from public.social_follows sf
      where sf.following_id = target_user and sf.status = 'accepted'),
    (select count(*) from public.social_follows sf
      where sf.follower_id = target_user and sf.status = 'accepted');
$$;

revoke all on function public.social_follow_user(uuid) from public, anon;
revoke all on function public.social_respond_follow(uuid, boolean) from public, anon;
revoke all on function public.social_follow_counts(uuid) from public, anon;
grant execute on function public.social_follow_user(uuid) to authenticated;
grant execute on function public.social_respond_follow(uuid, boolean) to authenticated;
grant execute on function public.social_follow_counts(uuid) to authenticated;

-- Discovery only exposes profile presentation fields used by the app.
-- Do not add email, phone, health metrics or private backup fields to profiles.
alter table public.profiles enable row level security;
drop policy if exists drs_profiles_discovery_read on public.profiles;
create policy drs_profiles_discovery_read
  on public.profiles for select to authenticated
  using (true);

-- A permissive policy is paired with a RESTRICTIVE privacy guard below.
-- The restrictive policy is important because PostgreSQL ORs permissive policies.
alter table public.social_posts enable row level security;
drop policy if exists drs_posts_read_base on public.social_posts;
create policy drs_posts_read_base
  on public.social_posts for select to authenticated
  using (true);

drop policy if exists drs_posts_privacy_guard on public.social_posts;
create policy drs_posts_privacy_guard
  on public.social_posts as restrictive for select to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1
      from public.profiles p
      where p.id = social_posts.user_id
        and (
          (p.privacy = 'public' and coalesce(social_posts.visibility, 'public') = 'public')
          or exists (
            select 1 from public.social_follows sf
            where sf.follower_id = auth.uid()
              and sf.following_id = p.id
              and sf.status = 'accepted'
          )
          or exists (
            select 1 from public.friendships f
            where f.status = 'accepted'
              and (
                (f.requester = auth.uid() and f.addressee = p.id)
                or (f.requester = p.id and f.addressee = auth.uid())
              )
          )
        )
    )
  );

drop policy if exists drs_posts_insert_own on public.social_posts;
create policy drs_posts_insert_own
  on public.social_posts for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists drs_posts_update_own on public.social_posts;
create policy drs_posts_update_own
  on public.social_posts for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists drs_posts_delete_own on public.social_posts;
create policy drs_posts_delete_own
  on public.social_posts for delete to authenticated
  using (user_id = auth.uid());


-- Protect reactions and comments attached to posts hidden by account privacy.
alter table public.post_comments enable row level security;
drop policy if exists drs_comments_read_base on public.post_comments;
create policy drs_comments_read_base
  on public.post_comments for select to authenticated using (true);
drop policy if exists drs_comments_privacy_guard on public.post_comments;
create policy drs_comments_privacy_guard
  on public.post_comments as restrictive for select to authenticated
  using (
    exists (
      select 1 from public.social_posts sp
      where sp.id = post_comments.post_id
        and (
          sp.user_id = auth.uid()
          or exists (
            select 1 from public.profiles p
            where p.id = sp.user_id
              and (
                (p.privacy = 'public' and coalesce(sp.visibility, 'public') = 'public')
                or exists (select 1 from public.social_follows sf
                  where sf.follower_id = auth.uid() and sf.following_id = p.id and sf.status = 'accepted')
                or exists (select 1 from public.friendships f
                  where f.status = 'accepted'
                    and ((f.requester = auth.uid() and f.addressee = p.id)
                      or (f.requester = p.id and f.addressee = auth.uid())))
              )
          )
        )
    )
  );

alter table public.post_reactions enable row level security;
drop policy if exists drs_reactions_read_base on public.post_reactions;
create policy drs_reactions_read_base
  on public.post_reactions for select to authenticated using (true);
drop policy if exists drs_reactions_privacy_guard on public.post_reactions;
create policy drs_reactions_privacy_guard
  on public.post_reactions as restrictive for select to authenticated
  using (
    exists (
      select 1 from public.social_posts sp
      where sp.id = post_reactions.post_id
        and (
          sp.user_id = auth.uid()
          or exists (
            select 1 from public.profiles p
            where p.id = sp.user_id
              and (
                (p.privacy = 'public' and coalesce(sp.visibility, 'public') = 'public')
                or exists (select 1 from public.social_follows sf
                  where sf.follower_id = auth.uid() and sf.following_id = p.id and sf.status = 'accepted')
                or exists (select 1 from public.friendships f
                  where f.status = 'accepted'
                    and ((f.requester = auth.uid() and f.addressee = p.id)
                      or (f.requester = p.id and f.addressee = auth.uid())))
              )
          )
        )
    )
  );


-- Do not let older permissive policies expose another person's posts.
drop policy if exists drs_posts_update_guard on public.social_posts;
create policy drs_posts_update_guard
  on public.social_posts as restrictive for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists drs_posts_delete_guard on public.social_posts;
create policy drs_posts_delete_guard
  on public.social_posts as restrictive for delete to authenticated
  using (user_id = auth.uid());

-- A user may only add comments/reactions to a post they are allowed to see.
drop policy if exists drs_comments_insert_guard on public.post_comments;
create policy drs_comments_insert_guard
  on public.post_comments as restrictive for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.social_posts sp
      where sp.id = post_comments.post_id
    )
  );

drop policy if exists drs_reactions_insert_guard on public.post_reactions;
create policy drs_reactions_insert_guard
  on public.post_reactions as restrictive for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.social_posts sp
      where sp.id = post_reactions.post_id
    )
  );


drop policy if exists drs_reactions_update_guard on public.post_reactions;
create policy drs_reactions_update_guard
  on public.post_reactions as restrictive for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
