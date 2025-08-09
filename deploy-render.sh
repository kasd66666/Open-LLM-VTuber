#!/bin/bash

# Script per deploy automatico su Render
echo "🚀 Preparando deploy su Render..."

# Verifica che siamo nella directory corretta
if [ ! -f "render.yaml" ]; then
    echo "❌ File render.yaml non trovato. Assicurati di essere nella directory del progetto."
    exit 1
fi

# Verifica che Git sia configurato
if ! git config user.email > /dev/null; then
    echo "⚙️ Configurando Git..."
    git config user.email "deploy@openllmvtuber.com"
    git config user.name "Open-LLM-VTuber Deploy"
fi

# Aggiungi tutti i file necessari
echo "📁 Aggiungendo file per il deploy..."
git add render.yaml dockerfile.render conf.production.yaml .renderignore DEPLOY.md

# Commit delle modifiche
echo "💾 Committando modifiche..."
git commit -m "Update Render deployment configuration" || echo "Nessuna modifica da committare"

# Push al repository
echo "⬆️ Pushing al repository..."
git push origin main

echo "✅ Deploy preparato!"
echo ""
echo "🌐 Prossimi passi:"
echo "1. Vai su https://render.com"
echo "2. Crea un nuovo Web Service"
echo "3. Connetti il tuo repository GitHub"
echo "4. Usa dockerfile.render come Dockerfile"
echo "5. Configura le variabili d'ambiente:"
echo "   - PORT=12393"
echo "   - HOST=0.0.0.0"
echo "   - PYTHONUNBUFFERED=1"
echo "   - HF_HOME=/app/models"
echo "   - MODELSCOPE_CACHE=/app/models"
echo "6. Configura disco persistente: models-cache -> /app/models (10GB)"
echo ""
echo "🎉 Il tuo VTuber sarà disponibile su https://[service-name].onrender.com"
