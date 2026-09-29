-- Run in Supabase SQL Editor. Create owner Auth user, then add their UUID to admin_users.
create extension if not exists pgcrypto;
create table if not exists public.admin_users(user_id uuid primary key references auth.users(id) on delete cascade, created_at timestamptz not null default now());
create table if not exists public.conversations(id uuid primary key default gen_random_uuid(), visitor_name text not null check(char_length(visitor_name) between 1 and 100), visitor_email text not null check(char_length(visitor_email) between 3 and 254), status text not null default 'open' check(status in ('open','closed')), created_at timestamptz not null default now());
create table if not exists public.messages(id uuid primary key default gen_random_uuid(), conversation_id uuid not null references public.conversations(id) on delete cascade, sender_role text not null check(sender_role in ('visitor','admin')), body text not null check(char_length(body) between 1 and 4000), created_at timestamptz not null default now());
create index if not exists messages_thread_idx on public.messages(conversation_id,created_at);
create or replace function public.is_tbn_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()); $$;
alter table public.admin_users enable row level security; alter table public.conversations enable row level security; alter table public.messages enable row level security;
drop policy if exists admin_list_read on public.admin_users; create policy admin_list_read on public.admin_users for select to authenticated using(public.is_tbn_admin());
drop policy if exists admin_conversations_read on public.conversations; create policy admin_conversations_read on public.conversations for select to authenticated using(public.is_tbn_admin());
drop policy if exists admin_conversations_update on public.conversations; create policy admin_conversations_update on public.conversations for update to authenticated using(public.is_tbn_admin()) with check(public.is_tbn_admin());
drop policy if exists admin_messages_read on public.messages; create policy admin_messages_read on public.messages for select to authenticated using(public.is_tbn_admin());
drop policy if exists admin_reply_insert on public.messages; create policy admin_reply_insert on public.messages for insert to authenticated with check(public.is_tbn_admin() and sender_role='admin');
create or replace function public.start_public_conversation(p_name text,p_email text,p_body text) returns uuid language plpgsql security definer set search_path=public as $$ declare new_id uuid; begin
if p_name is null or char_length(trim(p_name)) not between 1 and 100 then raise exception 'Invalid name'; end if;
if p_email is null or char_length(trim(p_email)) not between 3 and 254 then raise exception 'Invalid email'; end if;
if p_body is null or char_length(trim(p_body)) not between 1 and 4000 then raise exception 'Invalid message'; end if;
insert into public.conversations(visitor_name,visitor_email) values(trim(p_name),trim(p_email)) returning id into new_id;
insert into public.messages(conversation_id,sender_role,body) values(new_id,'visitor',trim(p_body)); return new_id; end; $$;
revoke all on function public.start_public_conversation(text,text,text) from public;
grant execute on function public.start_public_conversation(text,text,text) to anon,authenticated;
grant select on public.conversations,public.messages,public.admin_users to authenticated; grant insert on public.messages to authenticated;
