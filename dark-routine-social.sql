-- Dark Routine Social MVP: execute inteiro no Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null check (char_length(username) between 3 and 24),
 display_name text not null default '', avatar text not null default '🏃',
 bio text not null default '', privacy text not null default 'friends' check (privacy in ('private','friends','public')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.friendships (
 id uuid primary key default gen_random_uuid(), requester uuid not null references auth.users(id) on delete cascade,
 addressee uuid not null references auth.users(id) on delete cascade,
 status text not null default 'pending' check(status in ('pending','accepted')),
 created_at timestamptz not null default now(),
 constraint friendship_no_self check(requester<>addressee),
 constraint friendship_unique_pair unique(requester,addressee)
);
create table if not exists public.social_posts (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 content text not null default '', activity_km numeric(8,2), activity_minutes integer,
 created_at timestamptz not null default now(),
 check(char_length(content)<=500), check(activity_km is null or activity_km>=0), check(activity_minutes is null or activity_minutes>=0)
);
create table if not exists public.post_reactions (
 post_id uuid not null references public.social_posts(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 reaction text not null default '❤️', created_at timestamptz not null default now(), primary key(post_id,user_id)
);
create table if not exists public.post_comments (
 id uuid primary key default gen_random_uuid(), post_id uuid not null references public.social_posts(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade, content text not null check(char_length(content) between 1 and 300),
 created_at timestamptz not null default now()
);
create table if not exists public.social_challenges (
 id uuid primary key default gen_random_uuid(), creator_id uuid not null references auth.users(id) on delete cascade,
 title text not null check(char_length(title) between 1 and 60), description text not null default '',
 target_km numeric(8,2), ends_at date, created_at timestamptz not null default now(),
 check(target_km is null or target_km>0)
);
create table if not exists public.challenge_members (
 challenge_id uuid not null references public.social_challenges(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade, progress_km numeric(8,2) not null default 0,
 joined_at timestamptz not null default now(), primary key(challenge_id,user_id), check(progress_km>=0)
);
create table if not exists public.private_backups (
 user_id uuid primary key references auth.users(id) on delete cascade, payload jsonb not null, updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.friendships enable row level security;
alter table public.social_posts enable row level security;
alter table public.post_reactions enable row level security;
alter table public.post_comments enable row level security;
alter table public.social_challenges enable row level security;
alter table public.challenge_members enable row level security;
alter table public.private_backups enable row level security;

-- Profile directory available only to signed-in accounts. Keep profile fields non-sensitive.
create policy "signed-in profile directory" on public.profiles for select to authenticated using (true);
create policy "edit own profile" on public.profiles for insert to authenticated with check(id=auth.uid());
create policy "update own profile" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());

create policy "read friendship rows involving self" on public.friendships for select to authenticated using(requester=auth.uid() or addressee=auth.uid());
create policy "send friend request" on public.friendships for insert to authenticated with check(requester=auth.uid() and status='pending');
create policy "recipient accepts" on public.friendships for update to authenticated using(addressee=auth.uid() and status='pending') with check(addressee=auth.uid() and status='accepted');
create policy "participants delete friendship" on public.friendships for delete to authenticated using(requester=auth.uid() or addressee=auth.uid());

-- Posts are visible to authenticated members; avoid posting GPS routes or identifying location details.
create policy "signed in read posts" on public.social_posts for select to authenticated using(true);
create policy "create own post" on public.social_posts for insert to authenticated with check(user_id=auth.uid());
create policy "delete own post" on public.social_posts for delete to authenticated using(user_id=auth.uid());
create policy "read reactions" on public.post_reactions for select to authenticated using(true);
create policy "add own reaction" on public.post_reactions for insert to authenticated with check(user_id=auth.uid());
create policy "update own reaction" on public.post_reactions for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "remove own reaction" on public.post_reactions for delete to authenticated using(user_id=auth.uid());
create policy "read comments" on public.post_comments for select to authenticated using(true);
create policy "write own comment" on public.post_comments for insert to authenticated with check(user_id=auth.uid());
create policy "delete own comment" on public.post_comments for delete to authenticated using(user_id=auth.uid());

create policy "read challenges" on public.social_challenges for select to authenticated using(true);
create policy "create challenges" on public.social_challenges for insert to authenticated with check(creator_id=auth.uid());
create policy "delete own challenges" on public.social_challenges for delete to authenticated using(creator_id=auth.uid());
create policy "read challenge memberships" on public.challenge_members for select to authenticated using(true);
create policy "join challenge as self" on public.challenge_members for insert to authenticated with check(user_id=auth.uid());
create policy "update own challenge progress" on public.challenge_members for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "leave own challenge" on public.challenge_members for delete to authenticated using(user_id=auth.uid());

create policy "read own backup" on public.private_backups for select to authenticated using(user_id=auth.uid());
create policy "write own backup" on public.private_backups for insert to authenticated with check(user_id=auth.uid());
create policy "update own backup" on public.private_backups for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
