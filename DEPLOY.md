# 🚀 Deploy Open-LLM-VTuber su Render

Questa guida ti aiuterà a deployare Open-LLM-VTuber su Render con il modello gratuito DeepSeek Chat V3.

## 📋 Prerequisiti

1. Account GitHub
2. Account Render (gratuito)
3. Fork di questo repository

## 🔧 Configurazione

### 1. Fork del Repository
1. Vai su GitHub e fai fork di questo repository
2. Clona il tuo fork localmente

### 2. Deploy su Render

1. **Vai su [render.com](https://render.com)** e accedi
2. **Clicca "New +"** → **"Web Service"**
3. **Connetti il tuo repository GitHub**
4. **Configura il servizio:**
   - **Name**: `open-llm-vtuber`
   - **Environment**: `Docker`
   - **Region**: `Oregon`
   - **Branch**: `main`
   - **Dockerfile Path**: `./dockerfile.render`

### 3. Variabili d'Ambiente

Aggiungi queste variabili in Render Dashboard:

```
PORT=12393
HOST=0.0.0.0
PYTHONUNBUFFERED=1
HF_HOME=/app/models
MODELSCOPE_CACHE=/app/models
ENVIRONMENT=production
LOG_LEVEL=INFO
```

### 4. Disco Persistente

Configura un disco persistente per i modelli:
- **Nome**: `models-cache`
- **Mount Path**: `/app/models`
- **Dimensione**: `10 GB`

## 🎯 Modello Configurato

- **Modello**: `deepseek/deepseek-chat-v3-0324:free`
- **Provider**: OpenRouter
- **Costo**: Completamente gratuito
- **Potenza**: 222B parametri

## 🌐 Accesso

Dopo il deploy, il tuo VTuber sarà disponibile su:
```
https://[your-service-name].onrender.com
```

## 🔒 HTTPS e Microfono

Render fornisce automaticamente HTTPS, necessario per l'accesso al microfono nel browser.

## 📊 Monitoraggio

Render fornisce:
- Logs in tempo reale
- Metriche CPU/RAM
- Uptime monitoring
- Health checks automatici

## 💰 Costi

- **Starter Plan**: $7/mese
- **Professional**: $25/mese per uso intensivo

## 🛠️ Troubleshooting

### Build Fails
- Controlla i logs di build in Render Dashboard
- Verifica che tutti i file siano committati

### App Non Risponde
- Controlla i logs dell'applicazione
- Verifica le variabili d'ambiente
- Controlla lo stato del disco persistente

### Modello Non Funziona
- Verifica la configurazione OpenRouter
- Controlla i logs per errori API

## 📞 Supporto

Per problemi specifici:
1. Controlla i logs in Render Dashboard
2. Verifica la configurazione in `conf.production.yaml`
3. Consulta la documentazione ufficiale di Open-LLM-VTuber

## 🎉 Successo!

Una volta deployato, avrai:
- ✅ VTuber AI accessibile via web
- ✅ HTTPS automatico
- ✅ Modello gratuito potente
- ✅ Scaling automatico
- ✅ Backup automatici
