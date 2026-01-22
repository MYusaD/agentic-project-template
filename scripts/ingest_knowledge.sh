#!/usr/bin/env bash
#
# ingest_knowledge.sh - Bilgi Çıkarma Scripti
# Vendor repolarından yüksek değerli dökümanları çıkarır
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
echo "║      📚 Knowledge Ingestion v1.0           ║"
echo "║     Bilgi Çıkarma Sistemi                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Dizinler
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
VENDOR_DIR="$PROJECT_ROOT/vendor"
KNOWLEDGE_DIR="$PROJECT_ROOT/knowledge"
SOURCES_DIR="$KNOWLEDGE_DIR/sources"

# Kontrol
if [[ ! -d "$VENDOR_DIR" ]]; then
    log_error "Vendor dizini bulunamadı: $VENDOR_DIR"
    log_info "Önce şunu çalıştırın: bash scripts/fetch_resources.sh"
    exit 1
fi

# Dizinleri oluştur
mkdir -p "$SOURCES_DIR"

# İstatistikler
PROCESSED=0
FILES_COPIED=0

# Repo listesi
declare -a REPOS=(
    "spec-kit|Spec-driven geliştirme araç seti|PRD ve feature spec yazarken"
    "OpenHands|AI yazılım geliştirme ajanı|Full otonom geliştirme istediğinde"
    "browser-use|AI destekli web otomasyonu|E2E test ve web scraping için"
    "aider|Terminal tabanlı pair programming|Günlük kodlama asistanı olarak"
    "gpt-pilot|Spec'ten uygulama üreten ajan|Greenfield proje başlatırken"
    "langgraph|Multi-agent orchestration|Karmaşık ajan pipeline'ları için"
    "letta|Stateful agents with memory|Uzun süreli bellek gerektiren ajanlarda"
    "evals|LLM evaluation framework|Ajan performansını ölçerken"
    "SWE-agent|Akademik SW engineering ajanı|Issue çözme otomasyonu için"
    "MetaGPT|Multi-agent software company|Tam SDLC otomasyonu için"
)

# Her repo için bilgi çıkar
for repo_entry in "${REPOS[@]}"; do
    IFS='|' read -r name description usage <<< "$repo_entry"
    source_dir="$VENDOR_DIR/$name"
    target_dir="$SOURCES_DIR/$name"

    echo "────────────────────────────────────────────"
    log_info "İşleniyor: $name"

    if [[ ! -d "$source_dir" ]]; then
        log_warning "Kaynak bulunamadı: $source_dir"
        continue
    fi

    # Hedef dizini oluştur
    mkdir -p "$target_dir"
    repo_files=0

    # README.md
    if [[ -f "$source_dir/README.md" ]]; then
        cp "$source_dir/README.md" "$target_dir/"
        ((repo_files++))
        log_info "  README.md kopyalandı"
    fi

    # CONTRIBUTING.md, CHANGELOG.md vb.
    for file in CONTRIBUTING.md CHANGELOG.md ARCHITECTURE.md DESIGN.md; do
        if [[ -f "$source_dir/$file" ]]; then
            cp "$source_dir/$file" "$target_dir/"
            ((repo_files++))
            log_info "  $file kopyalandı"
        fi
    done

    # docs/ dizini
    if [[ -d "$source_dir/docs" ]]; then
        mkdir -p "$target_dir/docs"
        # Sadece .md ve .rst dosyalarını kopyala
        find "$source_dir/docs" -type f \( -name "*.md" -o -name "*.rst" -o -name "*.txt" \) \
            ! -path "*node_modules*" ! -path "*.git*" \
            -exec cp --parents {} "$target_dir/docs/" \; 2>/dev/null || \
        find "$source_dir/docs" -type f \( -name "*.md" -o -name "*.rst" -o -name "*.txt" \) \
            ! -path "*node_modules*" ! -path "*.git*" | while read -r f; do
                rel_path="${f#$source_dir/}"
                mkdir -p "$target_dir/$(dirname "$rel_path")"
                cp "$f" "$target_dir/$rel_path"
                ((repo_files++))
            done
        log_info "  docs/ dizini kopyalandı"
    fi

    # papers/ dizini (varsa)
    if [[ -d "$source_dir/papers" ]]; then
        mkdir -p "$target_dir/papers"
        find "$source_dir/papers" -type f \( -name "*.md" -o -name "*.pdf" -o -name "*.txt" \) \
            -exec cp {} "$target_dir/papers/" \; 2>/dev/null || true
        log_info "  papers/ dizini kopyalandı"
    fi

    # examples/ dizini (sadece README'ler)
    if [[ -d "$source_dir/examples" ]]; then
        mkdir -p "$target_dir/examples"
        find "$source_dir/examples" -name "README.md" \
            -exec cp {} "$target_dir/examples/" \; 2>/dev/null || true
        log_info "  examples/ README'leri kopyalandı"
    fi

    FILES_COPIED=$((FILES_COPIED + repo_files))
    ((PROCESSED++))
    log_success "$name işlendi ($repo_files dosya)"
done

# BRIEF.md oluştur
log_info "knowledge/BRIEF.md güncelleniyor..."

cat > "$KNOWLEDGE_DIR/BRIEF.md" << 'EOF'
# 📖 Bilgi Tabanı Özeti

> Bu dosya `scripts/ingest_knowledge.sh` tarafından otomatik oluşturulmuştur.
> Son güncelleme: TIMESTAMP

---

## Genel Bakış

Bu bilgi tabanı, `vendor/` altındaki agentic AI repolarından çıkarılan yüksek değerli dokümantasyonu içerir.

---

## Repo Özetleri

EOF

for repo_entry in "${REPOS[@]}"; do
    IFS='|' read -r name description usage <<< "$repo_entry"
    target_dir="$SOURCES_DIR/$name"

    cat >> "$KNOWLEDGE_DIR/BRIEF.md" << EOF
### $name
- **Ne için**: $description
- **Ne zaman kullan**: $usage
- **Kaynak**: \`knowledge/sources/$name/\`
EOF

    if [[ -d "$target_dir" ]]; then
        file_count=$(find "$target_dir" -type f 2>/dev/null | wc -l)
        echo "- **Dosya sayısı**: $file_count" >> "$KNOWLEDGE_DIR/BRIEF.md"
    else
        echo "- **Durum**: ⚠️ Henüz indirilmedi" >> "$KNOWLEDGE_DIR/BRIEF.md"
    fi

    echo "" >> "$KNOWLEDGE_DIR/BRIEF.md"
done

cat >> "$KNOWLEDGE_DIR/BRIEF.md" << 'EOF'
---

## Hızlı Erişim

### Temel Kavramlar
- **Spec-driven**: Önce spesifikasyon, sonra kod
- **Eval-driven**: Sürekli değerlendirme ve doğrulama
- **Multi-agent**: Birden fazla ajanın orkestra edilmesi
- **Stateful agents**: Uzun süreli bellek ile çalışan ajanlar

### Başlama Noktaları

| Görev | Başvurulacak Repo |
|-------|-------------------|
| PRD yazmak | spec-kit |
| Günlük kodlama | aider |
| Yeni proje başlatmak | gpt-pilot |
| E2E test | browser-use |
| Issue çözmek | SWE-agent |
| Performans ölçmek | evals |

---

## Dikkat Edilmesi Gerekenler

1. **Token kullanımı**: gpt-pilot ve MetaGPT yüksek miktarda token tüketir
2. **Bağımlılıklar**: Her repo farklı bağımlılık gereksinimine sahip
3. **API anahtarları**: Çoğu OpenAI veya Anthropic API anahtarı gerektirir
4. **Resource kullanımı**: OpenHands ve MetaGPT yoğun kaynak kullanır

---

*Bu dosya otomatik oluşturulmuştur. Manuel düzenlemeler üzerine yazılabilir.*
EOF

# Timestamp ekle
sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$KNOWLEDGE_DIR/BRIEF.md" 2>/dev/null || \
  sed "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$KNOWLEDGE_DIR/BRIEF.md" > "$KNOWLEDGE_DIR/BRIEF.md.tmp" && \
  mv "$KNOWLEDGE_DIR/BRIEF.md.tmp" "$KNOWLEDGE_DIR/BRIEF.md"

log_success "BRIEF.md güncellendi"

# Final özet
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║              📊 SONUÇ                      ║"
echo "╠════════════════════════════════════════════╣"
printf "║  %-20s: %3d                      ║\n" "İşlenen repo" "$PROCESSED"
printf "║  %-20s: %3d                      ║\n" "Kopyalanan dosya" "$FILES_COPIED"
echo "╚════════════════════════════════════════════╝"
echo ""

log_success "Bilgi tabanı oluşturuldu!"
log_info "Özet: knowledge/BRIEF.md"
log_info "Kaynaklar: knowledge/sources/"
exit 0
