#!/usr/bin/env bash
#
# loop.sh - Ralph Döngü Koşucusu
# Ajan çalışma döngüsünü yönetir
#

set -euo pipefail

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Konfigürasyon
MAX_ITERATIONS="${MAX_ITERATIONS:-10}"
AGENT_CMD="${AGENT_CMD:-claude}"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
LOGS_DIR="$PROJECT_ROOT/logs/loops"
DOCS_DIR="$PROJECT_ROOT/docs"

# Güvenlik bayrakları
ALLOW_DANGEROUS="${ALLOW_DANGEROUS:-false}"

# Log fonksiyonları
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_agent() { echo -e "${PURPLE}[AGENT]${NC} $1"; }

# Banner
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║         🔄 Ralph Loop Runner v1.0          ║"
echo "║       Ajan Döngü Sistemi                   ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Ön kontroller
log_info "Ön kontroller yapılıyor..."

# Logs dizinini oluştur
mkdir -p "$LOGS_DIR"

# Gerekli dosyaları kontrol et
required_files=(
    "$DOCS_DIR/AGENTS.md"
    "$DOCS_DIR/PRD.md"
    "$DOCS_DIR/TASKS.md"
    "$DOCS_DIR/PROMPT.md"
    "$PROJECT_ROOT/logs/progress.md"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        log_error "Gerekli dosya bulunamadı: $file"
        exit 1
    fi
done

# Agent komutunu kontrol et
if ! command -v "$AGENT_CMD" &> /dev/null; then
    log_error "Agent komutu bulunamadı: $AGENT_CMD"
    log_info "AGENT_CMD environment variable'ını doğru ayarlayın"
    log_info "Örnek: AGENT_CMD='claude' bash scripts/loop.sh"
    exit 1
fi

log_success "Tüm ön kontroller başarılı"
echo ""

# Konfigürasyon özeti
echo "┌────────────────────────────────────────────┐"
echo "│ Konfigürasyon                              │"
echo "├────────────────────────────────────────────┤"
printf "│ %-20s: %-20s │\n" "Agent" "$AGENT_CMD"
printf "│ %-20s: %-20s │\n" "Max Iterasyon" "$MAX_ITERATIONS"
printf "│ %-20s: %-20s │\n" "Proje Dizini" "${PROJECT_ROOT:0:18}..."
printf "│ %-20s: %-20s │\n" "Tehlikeli Mod" "$ALLOW_DANGEROUS"
echo "└────────────────────────────────────────────┘"
echo ""

# Güvenlik uyarısı
if [[ "$ALLOW_DANGEROUS" == "true" ]]; then
    log_warning "⚠️  TEHLİKELİ MOD AKTİF - Dikkatli olun!"
    echo ""
fi

# Prompt'u oluştur
build_prompt() {
    local prompt=""

    # AGENTS.md
    prompt+="# Ajan Kuralları (AGENTS.md)"$'\n'
    prompt+="$(cat "$DOCS_DIR/AGENTS.md")"$'\n\n'

    # PRD.md
    prompt+="# Ürün Gereksinimleri (PRD.md)"$'\n'
    prompt+="$(cat "$DOCS_DIR/PRD.md")"$'\n\n'

    # TASKS.md
    prompt+="# Görevler (TASKS.md)"$'\n'
    prompt+="$(cat "$DOCS_DIR/TASKS.md")"$'\n\n'

    # progress.md
    prompt+="# İlerleme Günlüğü (progress.md)"$'\n'
    prompt+="$(cat "$PROJECT_ROOT/logs/progress.md")"$'\n\n'

    # PROMPT.md talimatları
    prompt+="# Çalışma Talimatları"$'\n'
    prompt+="$(cat "$DOCS_DIR/PROMPT.md")"$'\n'

    echo "$prompt"
}

# Döngü
iteration=1
complete=false

while [[ $iteration -le $MAX_ITERATIONS ]] && [[ "$complete" == "false" ]]; do
    echo ""
    echo "═══════════════════════════════════════════════"
    echo "  🔄 İterasyon $iteration / $MAX_ITERATIONS"
    echo "═══════════════════════════════════════════════"
    echo ""

    log_file="$LOGS_DIR/loop_${iteration}.log"
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    log_info "Log dosyası: $log_file"
    log_info "Başlangıç: $timestamp"

    # Log başlığı
    {
        echo "═══════════════════════════════════════════════"
        echo "İterasyon: $iteration"
        echo "Zaman: $timestamp"
        echo "Agent: $AGENT_CMD"
        echo "═══════════════════════════════════════════════"
        echo ""
    } > "$log_file"

    # Prompt'u oluştur
    log_info "Prompt oluşturuluyor..."
    prompt=$(build_prompt)

    # Prompt'u log'a yaz
    {
        echo "=== PROMPT ==="
        echo "$prompt"
        echo ""
        echo "=== AGENT OUTPUT ==="
    } >> "$log_file"

    # Agent'ı çalıştır
    log_agent "Agent çalıştırılıyor..."

    agent_output=""

    # Agent komutunu çalıştır
    # Not: Her agent farklı CLI'a sahip olabilir
    case "$AGENT_CMD" in
        claude)
            # Claude CLI
            if [[ "$ALLOW_DANGEROUS" == "true" ]]; then
                agent_output=$($AGENT_CMD --dangerously-skip-permissions -p "$prompt" 2>&1) || true
            else
                agent_output=$($AGENT_CMD -p "$prompt" 2>&1) || true
            fi
            ;;
        aider)
            # Aider CLI
            echo "$prompt" | $AGENT_CMD --message /dev/stdin 2>&1 | tee -a "$log_file" || true
            agent_output=$(cat "$log_file" | tail -100)
            ;;
        *)
            # Generic: stdin'e prompt gönder
            agent_output=$(echo "$prompt" | $AGENT_CMD 2>&1) || true
            ;;
    esac

    # Çıktıyı log'a yaz
    echo "$agent_output" >> "$log_file"

    # Tamamlanma kontrolü
    if echo "$agent_output" | grep -q "<promise>COMPLETE</promise>"; then
        log_success "🎉 Tamamlanma sinyali algılandı!"
        complete=true
    fi

    # Özet bilgi
    end_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    {
        echo ""
        echo "═══════════════════════════════════════════════"
        echo "Bitiş: $end_timestamp"
        echo "Durum: $(if [[ "$complete" == "true" ]]; then echo "TAMAMLANDI"; else echo "DEVAM EDİYOR"; fi)"
        echo "═══════════════════════════════════════════════"
    } >> "$log_file"

    log_info "İterasyon $iteration tamamlandı"
    log_info "Detaylar: $log_file"

    ((iteration++))

    # Eğer tamamlanmadıysa kısa bekle
    if [[ "$complete" == "false" ]] && [[ $iteration -le $MAX_ITERATIONS ]]; then
        log_info "Sonraki iterasyona geçiliyor (2 saniye bekleniyor)..."
        sleep 2
    fi
done

# Final özet
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║              📊 DÖNGÜ SONUCU               ║"
echo "╠════════════════════════════════════════════╣"
if [[ "$complete" == "true" ]]; then
    echo "║  Durum: ✅ TAMAMLANDI                      ║"
    echo "║  Tüm görevler başarıyla tamamlandı        ║"
else
    echo "║  Durum: ⏹️  DURDURULDU                      ║"
    echo "║  Max iterasyon sayısına ulaşıldı          ║"
fi
printf "║  %-20s: %-19s ║\n" "Toplam İterasyon" "$((iteration - 1))"
printf "║  %-20s: %-19s ║\n" "Log Dizini" "logs/loops/"
echo "╚════════════════════════════════════════════╝"
echo ""

if [[ "$complete" == "true" ]]; then
    log_success "Döngü başarıyla tamamlandı!"
    exit 0
else
    log_warning "Döngü max iterasyonda durduruldu"
    log_info "Görevleri kontrol edin: docs/TASKS.md"
    log_info "İlerlemeyi inceleyin: logs/progress.md"
    exit 0
fi
