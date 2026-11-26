-- Migration V3: fotos de perfil e Storage. Execute uma vez no SQL Editor.
alter table public.profiles add column if not exists avatar_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('social-avatars','social-avatars',true,4194304,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=true, file_size_limit=4194304, allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "avatar files public read" on storage.objects;
drop policy if exists "avatar upload own folder" on storage.objects;
drop policy if exists "avatar update own folder" on storage.objects;
drop policy if exists "avatar delete own folder" on storage.objects;
create policy "avatar files public read" on storage.objects for select using (bucket_id='social-avatars');
create policy "avatar upload own folder" on storage.objects for insert to authenticated with check (bucket_id='social-avatars' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "avatar update own folder" on storage.objects for update to authenticated using (bucket_id='social-avatars' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='social-avatars' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "avatar delete own folder" on storage.objects for delete to authenticated using (bucket_id='social-avatars' and (storage.foldername(name))[1]=auth.uid()::text);
