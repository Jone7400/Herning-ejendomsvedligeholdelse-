-- Herning Ejendomsvedligeholdelse v1.0.0
-- KØR KUN EFTER DU HAR ERSTATTET UUID'ET NEDENFOR MED DIT EGET auth.users.id.
-- Find dit ID under Supabase > Authentication > Users. Brug IKKE din e-mailadresse.
-- Dette script ændrer IKKE pakkeshoppens tabeller.

create table if not exists public.hev_allowed_users (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.hev_allowed_users enable row level security;
-- Ingen client-rolle får adgang til at læse eller ændre listen.
revoke all on public.hev_allowed_users from anon, authenticated;

-- ERSTAT 00000000-0000-0000-0000-000000000000 MED DIT BRUGER-ID:
insert into public.hev_allowed_users(user_id)
values ('00000000-0000-0000-0000-000000000000')
on conflict do nothing;

create or replace function public.hev_is_owner()
returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.hev_allowed_users where user_id = (select auth.uid()));
$$;
revoke all on function public.hev_is_owner() from public, anon;
grant execute on function public.hev_is_owner() to authenticated;

create table if not exists public.hev_customers (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now(),
 name text not null,cvr text default '',email text default '',address text default '',phone text default '',notes text default ''
);
create table if not exists public.hev_visits (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now(),
 customer_id uuid not null references public.hev_customers(id),visit_date date not null,price numeric(12,2) not null default 200,status text not null default 'planned',notes text default ''
);
create table if not exists public.hev_jobs (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now(),
 customer_id uuid not null references public.hev_customers(id),description text not null,job_date date,status text not null default 'planned',hours numeric(12,2) default 0,hourly_rate numeric(12,2) default 0,materials numeric(12,2) default 0,fixed_price numeric(12,2) default 0
);
create table if not exists public.hev_invoices (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now(),
 customer_id uuid not null references public.hev_customers(id),invoice_number text not null unique,issue_date date not null,due_date date not null,
 lines jsonb not null default '[]',subtotal numeric(12,2) not null default 0,vat_rate numeric(6,2) not null default 25,vat_amount numeric(12,2) not null default 0,total numeric(12,2) not null default 0,notes text default '',status text not null default 'unpaid'
);
create table if not exists public.hev_expenses (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id),created_at timestamptz not null default now(),
 description text not null,expense_date date not null,supplier text default '',amount numeric(12,2) not null default 0,vat_amount numeric(12,2) not null default 0,receipt_path text
);

do $$ declare t text; begin
 foreach t in array array['hev_customers','hev_visits','hev_jobs','hev_invoices','hev_expenses'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('drop policy if exists hev_owner_all on public.%I',t);
  execute format('create policy hev_owner_all on public.%I for all to authenticated using (owner_id = (select auth.uid()) and (select public.hev_is_owner())) with check (owner_id = (select auth.uid()) and (select public.hev_is_owner()))',t);
  execute format('grant select, insert, update, delete on public.%I to authenticated',t);
 end loop;
end $$;

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('hev_receipts','hev_receipts',false,8388608,array['application/pdf','image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do nothing;

drop policy if exists hev_receipts_owner on storage.objects;
create policy hev_receipts_owner on storage.objects for all to authenticated
using (bucket_id = 'hev_receipts' and (storage.foldername(name))[1] = (select auth.uid())::text and (select public.hev_is_owner()))
with check (bucket_id = 'hev_receipts' and (storage.foldername(name))[1] = (select auth.uid())::text and (select public.hev_is_owner()));
