grant usage on schema public to authenticated;
grant usage on schema public to service_role;

grant select on public.clients to authenticated;
grant select, insert, update, delete on public.clients to service_role;

grant select on public.weekly_goals to authenticated;
grant select, insert, update, delete on public.weekly_goals to service_role;

grant select on public.training_history to authenticated;
grant select, insert, update, delete on public.training_history to service_role;

grant select on public.nutri_history to authenticated;
grant select, insert, update, delete on public.nutri_history to service_role;

grant select, insert, update, delete on public.client_context to authenticated;
grant select, insert, update, delete on public.client_context to service_role;

grant select, insert, update, delete on public.client_weekly_notes to authenticated;
grant select, insert, update, delete on public.client_weekly_notes to service_role;

grant select, insert, update, delete on public.weekly_reports to authenticated;
grant select, insert, update, delete on public.weekly_reports to service_role;
