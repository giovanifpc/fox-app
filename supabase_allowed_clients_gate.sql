create or replace function public.is_allowed_client(check_email text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.clients
    where lower(email) = lower(trim(check_email))
  );
$$;

revoke all on function public.is_allowed_client(text) from public;
grant execute on function public.is_allowed_client(text) to anon;
grant execute on function public.is_allowed_client(text) to authenticated;
