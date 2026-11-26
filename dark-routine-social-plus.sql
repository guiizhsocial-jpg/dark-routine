-- Dark Routine Social Plus migration. Run once in Supabase SQL Editor.
-- Does not delete existing profiles, posts, friendships, or activities.

alter table public.social_posts add column if not exists media_url text;

-- Storage bucket for user-post photos (public image URLs; post visibility is governed by the feed/table policies).
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('social-post-images','social-post-images',true,6291456,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=true,file_size_limit=6291456,allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "social post images public read" on storage.objects;
drop policy if exists "social post images upload own" on storage.objects;
drop policy if exists "social post images delete own" on storage.objects;
create policy "social post images public read" on storage.objects for select using (bucket_id='social-post-images');
create policy "social post images upload own" on storage.objects for insert to authenticated with check (bucket_id='social-post-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "social post images delete own" on storage.objects for delete to authenticated using (bucket_id='social-post-images' and (storage.foldername(name))[1]=auth.uid()::text);

-- Direct messages. Each row is visible only to its sender or recipient.
create table if not exists public.direct_messages (
 id uuid primary key default gen_random_uuid(),
 sender_id uuid not null references auth.users(id) on delete cascade,
 recipient_id uuid not null references auth.users(id) on delete cascade,
 content text not null check (length(trim(content)) between 1 and 1000),
 created_at timestamptz not null default now(),
 constraint dm_not_self check (sender_id <> recipient_id)
);
create index if not exists direct_messages_pair_created on public.direct_messages(sender_id,recipient_id,created_at);
create index if not exists direct_messages_recipient_created on public.direct_messages(recipient_id,created_at);

alter table public.direct_messages enable row level security;
revoke all on public.direct_messages from anon;
grant select,insert on public.direct_messages to authenticated;
drop policy if exists "dm participant read" on public.direct_messages;
drop policy if exists "dm sender insert" on public.direct_messages;
create policy "dm participant read" on public.direct_messages for select to authenticated
 using (auth.uid()=sender_id or auth.uid()=recipient_id);
create policy "dm sender insert" on public.direct_messages for insert to authenticated
 with check (auth.uid()=sender_id and recipient_id<>sender_id and exists (select 1 from public.friendships f where f.status='accepted' and ((f.requester=auth.uid() and f.addressee=recipient_id) or (f.addressee=auth.uid() and f.requester=recipient_id))));

-- Add column grants where needed; existing RLS policies continue to govern rows.
grant select,insert,update on public.social_posts to authenticated;
