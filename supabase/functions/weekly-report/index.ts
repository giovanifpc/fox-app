import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Json = Record<string, unknown>;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const adminSecret = Deno.env.get("WEEKLY_REPORT_SECRET") || "";
const adminEmail = (Deno.env.get("ADMIN_EMAIL") || "giovani.work@hotmail.com").toLowerCase();
const anthropicApiKey = Deno.env.get("ANTHROPIC_API_KEY") || "";
const anthropicModel = Deno.env.get("ANTHROPIC_MODEL") || "claude-3-5-sonnet-20241022";

const supa = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

function isoDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

function defaultPreviousWeek() {
  const now = new Date();
  const utc = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const day = utc.getUTCDay() || 7;
  const thisMonday = new Date(utc);
  thisMonday.setUTCDate(utc.getUTCDate() - day + 1);
  const start = new Date(thisMonday);
  start.setUTCDate(thisMonday.getUTCDate() - 7);
  const end = new Date(start);
  end.setUTCDate(start.getUTCDate() + 6);
  return { start: isoDate(start), end: isoDate(end) };
}

function numberValue(value: unknown) {
  const n = Number(value || 0);
  return Number.isFinite(n) ? n : 0;
}

async function getRequesterEmail(req: Request) {
  const authHeader = req.headers.get("authorization") || "";
  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!token) return "";
  const { data, error } = await supa.auth.getUser(token);
  if (error || !data.user?.email) return "";
  return data.user.email.toLowerCase();
}

async function isAuthorized(req: Request) {
  const received = req.headers.get("x-weekly-report-secret") || "";
  if (adminSecret && received === adminSecret) return true;
  const requester = await getRequesterEmail(req);
  return requester === adminEmail;
}

function performedTraining(row: Json) {
  return numberValue(row.sets_done) > 0 || numberValue(row.exercises_done) > 0;
}

function summarizeTraining(rows: Json[]) {
  const sessions = rows.filter(performedTraining);
  const complete = sessions.filter((row) => row.incomplete !== true);
  return {
    sessions: sessions.length,
    complete_sessions: complete.length,
    incomplete_sessions: sessions.length - complete.length,
    sets_done: sessions.reduce((sum, row) => sum + numberValue(row.sets_done), 0),
    exercises_done: sessions.reduce((sum, row) => sum + numberValue(row.exercises_done), 0),
    minutes: sessions.reduce((sum, row) => sum + numberValue(row.minutes), 0),
    workouts: sessions.map((row) => ({
      date: String(row.completed_at || "").slice(0, 10),
      workout_name: row.workout_name || null,
      sets_done: row.sets_done || 0,
      exercises_done: row.exercises_done || 0,
      incomplete: row.incomplete === true,
    })),
  };
}

function summarizeNutri(rows: Json[]) {
  const daysWithFood = rows.filter((row) => numberValue(row.kcal) > 0).length;
  const daysWithWater = rows.filter((row) => numberValue(row.water_ml) > 0).length;
  const totalKcal = rows.reduce((sum, row) => sum + numberValue(row.kcal), 0);
  const totalProtein = rows.reduce((sum, row) => sum + numberValue(row.protein_g), 0);
  const totalWater = rows.reduce((sum, row) => sum + numberValue(row.water_ml), 0);
  return {
    registered_days: rows.length,
    food_days: daysWithFood,
    water_days: daysWithWater,
    avg_kcal: daysWithFood ? Math.round(totalKcal / daysWithFood) : 0,
    avg_protein_g: daysWithFood ? Math.round(totalProtein / daysWithFood) : 0,
    avg_water_ml: daysWithWater ? Math.round(totalWater / daysWithWater) : 0,
    days: rows.map((row) => ({
      date: row.date_key,
      kcal: row.kcal || 0,
      protein_g: row.protein_g || 0,
      water_ml: row.water_ml || 0,
    })),
  };
}

function summarizeGoals(goalsRow: Json | null, training: Json, nutri: Json) {
  const metas = Array.isArray(goalsRow?.metas) ? goalsRow?.metas as Json[] : [];
  return metas.map((goal) => {
    const name = String(goal.nome || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    let realized = numberValue(goal.realizado);
    if (name.includes("treino")) realized = Math.max(realized, numberValue(training.sessions));
    if (name.includes("hidrat")) realized = Math.max(realized, numberValue(nutri.water_days));
    if (name.includes("nutri")) realized = Math.max(realized, numberValue(nutri.food_days));
    return { ...goal, realizado: realized };
  });
}

function compactForPrompt(value: unknown) {
  return JSON.stringify(value, null, 2).slice(0, 12000);
}

function fallbackDraft(reportData: Json, training: Json, nutri: Json, goals: Json[]) {
  const client = reportData.client as Json;
  const period = reportData.period as Json;
  const context = (reportData.context as Json) || {};
  const weeklyNote = (reportData.weekly_note as Json) || {};
  return [
    `Devolutiva semanal - ${client?.nome || client?.email || "cliente"}`,
    `Periodo: ${period?.start || "-"} a ${period?.end || "-"}`,
    "",
    "Resumo objetivo:",
    `- Treinos realizados: ${training.sessions || 0}, sendo ${training.complete_sessions || 0} completos.`,
    `- Series registradas: ${training.sets_done || 0}.`,
    `- Dias com alimentacao registrada: ${nutri.food_days || 0}.`,
    `- Dias com hidratacao registrada: ${nutri.water_days || 0}.`,
    "",
    "Metas:",
    goals.length
      ? goals.map((goal) => `- ${goal.nome || "Meta"}: ${goal.realizado || 0}/${goal.meta_valor || 0}`).join("\n")
      : "- Sem metas no periodo.",
    "",
    "Contexto do cliente:",
    context.primary_goal ? `- Objetivo: ${context.primary_goal}` : "- Objetivo nao registrado.",
    context.limitations ? `- Rotina/limitacoes: ${context.limitations}` : "",
    context.injuries_pain ? `- Dores/lesoes: ${context.injuries_pain}` : "",
    weeklyNote.note ? `- Nota semanal do Giovani: ${weeklyNote.note}` : "",
    weeklyNote.instruction ? `- Instrucao da semana: ${weeklyNote.instruction}` : "",
    "",
    "Pontos para revisao do Giovani:",
    "- Validar aderencia real do cliente antes de publicar.",
    "- Ajustar tom e recomendacoes conforme contexto da semana.",
  ].join("\n");
}

async function generateClaudeDraft(input: {
  reportData: Json;
  trainingSummary: Json;
  nutriSummary: Json;
  goalsSnapshot: Json[];
}) {
  if (!anthropicApiKey) {
    return fallbackDraft(input.reportData, input.trainingSummary, input.nutriSummary, input.goalsSnapshot);
  }

  const prompt = [
    "Voce e assistente do Giovani, treinador da Fox Performance.",
    "Gere uma devolutiva semanal curta, humana e revisavel para o cliente.",
    "Nao invente dados. Use somente o JSON fornecido.",
    "Considere contexto fixo, anamnese e nota semanal do Giovani como prioridade para personalizar a resposta.",
    "Se houver instrucao semanal, siga essa instrucao acima das regras gerais de tom.",
    "Tom: direto, cuidadoso, profissional e motivador, sem exagero.",
    "Estrutura obrigatoria:",
    "1. Saudacao breve pelo nome.",
    "2. Leitura da semana em 1 paragrafo.",
    "3. Pontos fortes em bullets.",
    "4. Pontos de ajuste em bullets.",
    "5. Recomendacao pratica para a proxima semana.",
    "6. Uma frase final que aproxime o cliente do Giovani.",
    "",
    "Dados:",
    compactForPrompt(input),
  ].join("\n");

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": anthropicApiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: anthropicModel,
      max_tokens: 1200,
      temperature: 0.4,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    }),
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Claude API falhou: ${res.status} ${text.slice(0, 300)}`);
  }

  const data = await res.json();
  const blocks = Array.isArray(data.content) ? data.content : [];
  const text = blocks
    .filter((block: Json) => block.type === "text" && typeof block.text === "string")
    .map((block: Json) => block.text)
    .join("\n\n")
    .trim();

  return text || fallbackDraft(input.reportData, input.trainingSummary, input.nutriSummary, input.goalsSnapshot);
}

async function buildReportForClient(client: Json, start: string, end: string) {
  const email = String(client.email || "").toLowerCase();
  const ciclo = Number(client.ciclo_atual || 1);
  const semana = Number(client.semana_atual || 1);

  const [trainingRes, nutriRes, goalsRes, contextRes, noteRes] = await Promise.all([
    supa.from("training_history")
      .select("*")
      .eq("client_email", email)
      .gte("completed_at", `${start}T00:00:00.000Z`)
      .lte("completed_at", `${end}T23:59:59.999Z`)
      .order("completed_at", { ascending: true }),
    supa.from("nutri_history")
      .select("*")
      .eq("client_email", email)
      .gte("date_key", start)
      .lte("date_key", end)
      .order("date_key", { ascending: true }),
    supa.from("weekly_goals")
      .select("metas,foco_semana,data_inicio,data_fim,ciclo,semana")
      .eq("client_email", email)
      .eq("ciclo", ciclo)
      .eq("semana", semana)
      .eq("publicado", true)
      .maybeSingle(),
    supa.from("client_context")
      .select("*")
      .eq("client_email", email)
      .maybeSingle(),
    supa.from("client_weekly_notes")
      .select("*")
      .eq("client_email", email)
      .eq("ciclo", ciclo)
      .eq("semana", semana)
      .maybeSingle(),
  ]);

  if (trainingRes.error) throw trainingRes.error;
  if (nutriRes.error) throw nutriRes.error;
  if (goalsRes.error) throw goalsRes.error;
  if (contextRes.error) throw contextRes.error;
  if (noteRes.error) throw noteRes.error;

  const trainingSummary = summarizeTraining((trainingRes.data || []) as Json[]);
  const nutriSummary = summarizeNutri((nutriRes.data || []) as Json[]);
  const goalsSnapshot = summarizeGoals((goalsRes.data || null) as Json | null, trainingSummary, nutriSummary);

  const reportData = {
    client: {
      email,
      nome: client.nome || null,
      ciclo,
      semana,
      whatsapp: client.numero_whatsapp || null,
      folder_id: client.folder_id || null,
    },
    period: { start, end },
    foco_semana: goalsRes.data?.foco_semana || null,
    context: contextRes.data || {},
    weekly_note: noteRes.data || {},
    generated_by: "weekly-report-edge-function",
  };

  let aiDraft = "";
  let aiStatus = "generated";
  try {
    aiDraft = await generateClaudeDraft({
      reportData,
      trainingSummary,
      nutriSummary,
      goalsSnapshot,
    });
  } catch (error) {
    aiStatus = "error";
    aiDraft = fallbackDraft(reportData, trainingSummary, nutriSummary, goalsSnapshot);
    reportData["ai_error"] = error instanceof Error ? error.message : String(error);
  }

  const payload = {
    client_email: email,
    ciclo,
    semana,
    period_start: start,
    period_end: end,
    status: "draft",
    generated_at: new Date().toISOString(),
    training_summary: trainingSummary,
    nutri_summary: nutriSummary,
    sleep_summary: {},
    checkin_summary: {},
    goals_snapshot: goalsSnapshot,
    report_data: reportData,
    ai_draft: aiDraft,
    raw_data: {
      training: trainingRes.data || [],
      nutri: nutriRes.data || [],
      weekly_goal: goalsRes.data || null,
      client_context: contextRes.data || null,
      weekly_note: noteRes.data || null,
      ai_status: aiStatus,
      ai_model: anthropicApiKey ? anthropicModel : "fallback",
    },
    updated_at: new Date().toISOString(),
  };

  const { data, error } = await supa
    .from("weekly_reports")
    .upsert(payload, { onConflict: "client_email,period_start,period_end" })
    .select("id,client_email,period_start,period_end,status")
    .single();

  if (error) throw error;
  return data;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY nao configurado.");
    }

    if (!(await isAuthorized(req))) {
      return new Response(JSON.stringify({ error: "unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = (req.method === "POST" ? await req.json().catch(() => ({})) : {}) as Record<string, unknown>;
    const period = {
      start: String(body.period_start || body.start || defaultPreviousWeek().start),
      end: String(body.period_end || body.end || defaultPreviousWeek().end),
    };

    let clientsQuery = supa
      .from("clients")
      .select("email,nome,ciclo_atual,semana_atual,total_semanas,folder_id,numero_whatsapp")
      .order("nome", { ascending: true });

    if (body.client_email) {
      clientsQuery = clientsQuery.eq("email", String(body.client_email).toLowerCase());
    }

    const { data: clients, error } = await clientsQuery;
    if (error) throw error;

    const results = [];
    for (const client of clients || []) {
      results.push(await buildReportForClient(client as Json, String(period.start), String(period.end)));
    }

    return new Response(JSON.stringify({ ok: true, period, reports: results }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ ok: false, error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
