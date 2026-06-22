#!/usr/bin/env python3
"""
Fox Performance — Script de Atualização do exercises.json
Execute sempre que adicionar novos GIFs ao Drive.

Requisitos: pip install google-api-python-client google-auth

Uso:
  python3 update_exercises.py

O script lê todos os GIFs da pasta do Drive, preserva IDs existentes,
adiciona novos e remove os deletados. Salva em fox-app/data/exercises.json
"""

import json, re, os

# ── CONFIGURAÇÃO ──────────────────────────────────────────────────────────────
DRIVE_FOLDER_ID = "1HRZKkVupI7tYBTzN1x0vhmRReWwq1Xhy"  # pasta raiz dos GIFs
OUTPUT_FILE = "data/exercises.json"
# ─────────────────────────────────────────────────────────────────────────────

def get_grupo(caminho):
    c = caminho.lower()
    if 'bíceps' in c or 'biceps' in c: return 'Bíceps'
    if 'tríceps' in c or 'triceps' in c: return 'Tríceps'
    if 'peitoral' in c: return 'Peitoral'
    if 'costas' in c: return 'Costas'
    if 'ombros' in c: return 'Ombros'
    if 'pernas' in c: return 'Pernas'
    if 'glúteos' in c or 'gluteos' in c: return 'Glúteos'
    if 'panturrilha' in c: return 'Panturrilhas'
    if 'antebraço' in c: return 'Antebraços'
    if 'trapézio' in c or 'trapezio' in c: return 'Trapézio'
    if 'ereto' in c or 'espinha' in c: return 'Core/Lombar'
    if 'cardio' in c: return 'Cardio'
    if 'calistenia' in c: return 'Calistenia'
    if 'funcional' in c or 'hiit' in c: return 'Funcional/HIIT'
    if 'mobilidade' in c or 'alongamento' in c: return 'Mobilidade'
    if 'crossfit' in c: return 'Crossfit'
    if 'pescoço' in c: return 'Pescoço'
    if 'feminino' in c or 'mulher' in c: return 'Feminino'
    if 'masculino' in c or 'homem' in c: return 'Masculino'
    if 'iniciante' in c: return 'Iniciante'
    return 'Geral'

def list_gifs_recursive(service, folder_id, path=""):
    results = []
    query = f"'{folder_id}' in parents and trashed=false"
    page_token = None
    while True:
        response = service.files().list(
            q=query,
            fields="nextPageToken, files(id, name, mimeType)",
            pageToken=page_token,
            pageSize=1000
        ).execute()
        for f in response.get('files', []):
            if f['mimeType'] == 'application/vnd.google-apps.folder':
                results.extend(list_gifs_recursive(service, f['id'], path + '/' + f['name']))
            elif f['name'].lower().endswith('.gif'):
                results.append({
                    'drive_id': f['id'],
                    'name': f['name'],
                    'path': path
                })
        page_token = response.get('nextPageToken')
        if not page_token:
            break
    return results

def main():
    from googleapiclient.discovery import build
    from google.oauth2 import service_account

    # Carregar credenciais da Service Account
    creds = service_account.Credentials.from_service_account_file(
        'service_account.json',
        scopes=['https://www.googleapis.com/auth/drive.readonly']
    )
    service = build('drive', 'v3', credentials=creds)

    print("Listando GIFs no Drive...")
    gifs = list_gifs_recursive(service, DRIVE_FOLDER_ID)
    print(f"Encontrados: {len(gifs)} GIFs")

    # Carregar JSON existente (preservar IDs)
    existing = {}
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
            existing = json.load(f)

    # Mapear drive_id → exercise_id existente
    drive_id_to_ex_id = {ex['drive_id']: k for k, ex in existing.items()}

    # Próximo ID disponível
    next_id = max([int(k) for k in existing.keys()], default=0) + 1

    new_exercises = {}
    for gif in gifs:
        drive_id = gif['drive_id']
        nome = re.sub(r'\.gif$', '', gif['name'], flags=re.IGNORECASE).strip()

        if drive_id in drive_id_to_ex_id:
            # Preservar ID existente
            ex_id = drive_id_to_ex_id[drive_id]
            new_exercises[ex_id] = existing[ex_id]
        else:
            # Novo GIF
            ex_id = str(next_id)
            next_id += 1
            new_exercises[ex_id] = {
                "exercise_id": int(ex_id),
                "name": nome,
                "gif_file": gif['name'],
                "gif_url": f"https://drive.google.com/uc?export=view&id={drive_id}",
                "drive_id": drive_id,
                "grupo_muscular": get_grupo(gif['path']),
                "categoria": gif['path'].split('/')[-1] if gif['path'] else 'Geral'
            }

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(new_exercises, f, ensure_ascii=False, indent=2)

    print(f"✅ {OUTPUT_FILE} atualizado — {len(new_exercises)} exercícios")
    print(f"   Preservados: {len([k for k in new_exercises if k in existing])}")
    print(f"   Novos: {len(new_exercises) - len([k for k in new_exercises if k in existing])}")
    print(f"   Removidos: {len(existing) - len([k for k in existing if k in new_exercises])}")

if __name__ == '__main__':
    main()
