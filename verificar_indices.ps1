#!/usr/bin/env pwsh
# Script para verificar el estado de los índices de Firestore

Write-Host "🔍 Verificando estado de los índices de Firestore..." -ForegroundColor Cyan
Write-Host ""

# Información del proyecto
$PROJECT_ID = "agendawa-5d8a1"

Write-Host "📋 Índices requeridos para el proyecto: $PROJECT_ID" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  Colección: clientes" -ForegroundColor Green
Write-Host "   - Campo: terapeutaUid (Ascending)"
Write-Host "   - Campo: nombre (Ascending)"
Write-Host ""

Write-Host "2️⃣  Colección: papelera_clientes (Índice 1)" -ForegroundColor Green
Write-Host "   - Campo: terapeutaUid (Ascending)"
Write-Host "   - Campo: fechaEliminacion (Descending)"
Write-Host ""

Write-Host "3️⃣  Colección: papelera_clientes (Índice 2)" -ForegroundColor Green
Write-Host "   - Campo: terapeutaUid (Ascending)"
Write-Host "   - Campo: fechaEliminacion (Ascending)"
Write-Host ""

# Verificar si Firebase CLI está instalado
Write-Host "🔧 Verificando Firebase CLI..." -ForegroundColor Cyan
try {
    $firebaseVersion = firebase --version 2>$null
    if ($firebaseVersion) {
        Write-Host "✅ Firebase CLI instalado: $firebaseVersion" -ForegroundColor Green
        
        # Intentar verificar los índices
        Write-Host ""
        Write-Host "🔍 Verificando índices..." -ForegroundColor Cyan
        Write-Host "Ejecutando: firebase firestore:indexes --project $PROJECT_ID" -ForegroundColor Gray
        
        firebase firestore:indexes --project $PROJECT_ID
        
    } else {
        throw "Firebase CLI no encontrado"
    }
} catch {
    Write-Host "❌ Firebase CLI no está instalado o no está en PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "📖 Para instalar Firebase CLI:" -ForegroundColor Yellow
    Write-Host "   npm install -g firebase-tools"
    Write-Host ""
    Write-Host "🌐 O verifica manualmente en:" -ForegroundColor Yellow
    Write-Host "   https://console.firebase.google.com/project/$PROJECT_ID/firestore/indexes"
}

Write-Host ""
Write-Host "📊 Estado esperado de índices:" -ForegroundColor Cyan
Write-Host "   🟢 Enabled  = Índice listo para usar"
Write-Host "   🟡 Building = Índice en construcción (esperar)"
Write-Host "   🔴 Error    = Problema con el índice"
Write-Host ""

Write-Host "⏰ Tiempo típico de construcción: 2-15 minutos" -ForegroundColor Yellow
Write-Host "💡 Una vez que todos los índices estén 'Enabled', la papelera funcionará correctamente" -ForegroundColor Green
