#!/usr/bin/env bash
#
# fetch_resources.sh - Vendor Repo İndirici
# Top agentic AI repolarını vendor/ dizinine klonlar
#

set -euo pipefail

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Log fonksiyonları
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Banner
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║      📦 Vendor Repo Fetcher v1.0           ║"
echo "║     Agentic AI Kaynak İndirici            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Proje kök dizini
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
VENDOR_DIR="$PROJECT_ROOT/vendor"

# Git kontrolü
if ! command -v git &> /dev/null; then
    log_error "Git kurulu değil!"
    exit 1
fi

# Vendor dizinini oluştur
mkdir -p "$VENDOR_DIR"

# Repo listesi (URL|Klasör Adı|Açıklama)
declare -a REPOS=(
    "https://github.com/github/spec-kit|spec-kit|Spec-driven geliştirme araç seti"
    "https://github.com/All-Hands-AI/OpenHands|OpenHands|AI yazılım geliştirme ajanı"
    "https://github.com/browser-use/browser-use|browser-use|AI destekli web otomasyonu"
    "https://github.com/Aider-AI/aider|aider|Terminal tabanlı pair programming"
    "https://github.com/Pythagora-io/gpt-pilot|gpt-pilot|Spec'ten uygulama üreten ajan"
    "https://github.com/langchain-ai/langgraph|langgraph|Multi-agent orchestration"
    "https://github.com/letta-ai/letta|letta|Stateful agents with memory"
    "https://github.com/openai/evals|evals|LLM evaluation framework"
    "https://github.com/princeton-nlp/SWE-agent|SWE-agent|Akademik SW engineering ajanı"
    "https://github.com/geekan/MetaGPT|MetaGPT|Multi-agent software company"
)

# İstatistikler
CLONED=0
SKIPPED=0
FAILED=0

log_info "Vendor dizini: $VENDOR_DIR"
log_info "Toplam repo sayısı: ${#REPOS[@]}"
echo ""

# Her repo için
for repo_entry in "${REPOS[@]}"; do
    IFS='|' read -r url name description <<< "$repo_entry"
    target_dir="$VENDOR_DIR/$name"

    echo "────────────────────────────────────────────"
    log_info "Repo: $name"
    log_info "URL: $url"
    log_info "Açıklama: $description"

    if [[ -d "$target_dir" ]]; then
        log_warning "Zaten mevcut, atlanıyor: $target_dir"
        ((SKIPPED++))
    else
        log_info "Klonlanıyor (depth=1)..."
        if git clone --depth 1 "$url" "$target_dir" 2>&1; then
            log_success "Başarıyla klonlandı: $name"
            ((CLONED++))
        else
            log_error "Klonlama başarısız: $name"
            ((FAILED++))
        fi
    fi
    echo ""
done

# INDEX.md oluştur
log_info "vendor/INDEX.md oluşturuluyor..."

cat > "$VENDOR_DIR/INDEX.md" << 'EOF'
# 📦 Vendor Repos Index

> Bu dosya `scripts/fetch_resources.sh` tarafından otomatik oluşturulmuştur.

## Repolar

| Repo | Açıklama | Durum |
|------|----------|-------|
EOF

for repo_entry in "${REPOS[@]}"; do
    IFS='|' read -r url name description <<< "$repo_entry"
    target_dir="$VENDOR_DIR/$name"

    if [[ -d "$target_dir" ]]; then
        status="✅ Mevcut"
    else
        status="❌ Eksik"
    fi

    echo "| [$name](./$name) | $description | $status |" >> "$VENDOR_DIR/INDEX.md"
done

cat >> "$VENDOR_DIR/INDEX.md" << 'EOF'

## Kullanım

Her repo `vendor/<repo-adı>` altında bulunur. Örnekler:

```bash
# Aider dökümanlarına bak
cat vendor/aider/README.md

# OpenHands kaynak kodunu incele
ls vendor/OpenHands/
```

## Güncelleme

Tüm repoları güncellemek için:

```bash
cd vendor/<repo-adı>
git pull --depth 1
```

Veya hepsini yeniden indirmek için:

```bash
rm -rf vendor/*
bash scripts/fetch_resources.sh
```

---

*Son güncelleme: TIMESTAMP*
EOF

# Timestamp ekle
sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$VENDOR_DIR/INDEX.md" 2>/dev/null || \
  sed "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$VENDOR_DIR/INDEX.md" > "$VENDOR_DIR/INDEX.md.tmp" && \
  mv "$VENDOR_DIR/INDEX.md.tmp" "$VENDOR_DIR/INDEX.md"

log_success "INDEX.md oluşturuldu"

# Final özet
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║              📊 SONUÇ                      ║"
echo "╠════════════════════════════════════════════╣"
printf "║  %-15s: %3d                         ║\n" "✓ Klonlanan" "$CLONED"
printf "║  %-15s: %3d                         ║\n" "! Atlanan" "$SKIPPED"
printf "║  %-15s: %3d                         ║\n" "✗ Başarısız" "$FAILED"
echo "╚════════════════════════════════════════════╝"
echo ""

if [[ $FAILED -gt 0 ]]; then
    log_warning "Bazı repolar indirilemedi. Network bağlantısını kontrol edin."
    exit 1
else
    log_success "Tüm repolar hazır!"
    log_info "Sonraki adım: bash scripts/ingest_knowledge.sh"
    exit 0
fi
