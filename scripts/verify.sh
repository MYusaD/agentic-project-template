#!/usr/bin/env bash
#
# verify.sh - Stack-aware doğrulama scripti
# Projedeki teknoloji stack'ini otomatik algılar ve uygun testleri çalıştırır
#

set -euo pipefail

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log fonksiyonları
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Sonuç takibi
PASSED=0
FAILED=0
SKIPPED=0

run_check() {
    local name="$1"
    local cmd="$2"

    log_info "$name çalıştırılıyor..."
    if eval "$cmd"; then
        log_success "$name başarılı"
        ((PASSED++))
    else
        log_error "$name başarısız"
        ((FAILED++))
        return 1
    fi
}

skip_check() {
    local name="$1"
    log_warning "$name atlandı (araç bulunamadı)"
    ((SKIPPED++))
}

# Banner
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║         🔍 Verify Script v1.0              ║"
echo "║     Stack-aware Doğrulama Sistemi          ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Proje kök dizini
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
cd "$PROJECT_ROOT"

log_info "Proje dizini: $PROJECT_ROOT"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Node.js / JavaScript / TypeScript
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ -f "package.json" ]]; then
    log_info "📦 Node.js projesi algılandı"

    # Paket yöneticisi algıla
    if [[ -f "pnpm-lock.yaml" ]]; then
        PKG_MGR="pnpm"
    elif [[ -f "yarn.lock" ]]; then
        PKG_MGR="yarn"
    else
        PKG_MGR="npm"
    fi
    log_info "Paket yöneticisi: $PKG_MGR"

    # Bağımlılıkları kontrol et
    if [[ ! -d "node_modules" ]]; then
        log_warning "node_modules bulunamadı, kurulum atlanıyor"
    fi

    # package.json scriptlerini kontrol et
    if command -v jq &> /dev/null; then
        SCRIPTS=$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null || echo "")
    else
        SCRIPTS=$(grep -oP '"(test|lint|type-check|build)"' package.json | tr -d '"' || echo "")
    fi

    # Test
    if echo "$SCRIPTS" | grep -q "test"; then
        run_check "Node.js testleri" "$PKG_MGR run test" || true
    else
        skip_check "Node.js testleri"
    fi

    # Lint
    if echo "$SCRIPTS" | grep -q "lint"; then
        run_check "ESLint" "$PKG_MGR run lint" || true
    else
        skip_check "ESLint"
    fi

    # Type check
    if echo "$SCRIPTS" | grep -q "type-check\|typecheck"; then
        run_check "TypeScript" "$PKG_MGR run type-check" || true
    elif [[ -f "tsconfig.json" ]] && command -v npx &> /dev/null; then
        run_check "TypeScript" "npx tsc --noEmit" || true
    else
        skip_check "TypeScript"
    fi

    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
    log_info "🐍 Python projesi algılandı"

    # Syntax check
    if command -v python &> /dev/null || command -v python3 &> /dev/null; then
        PYTHON_CMD=$(command -v python3 || command -v python)
        run_check "Python syntax" "$PYTHON_CMD -m compileall -q ." || true
    fi

    # pytest
    if command -v pytest &> /dev/null; then
        run_check "pytest" "pytest -q" || true
    elif $PYTHON_CMD -c "import pytest" 2>/dev/null; then
        run_check "pytest" "$PYTHON_CMD -m pytest -q" || true
    else
        skip_check "pytest"
    fi

    # Ruff (modern linter)
    if command -v ruff &> /dev/null; then
        run_check "Ruff lint" "ruff check ." || true
    else
        skip_check "Ruff"
    fi

    # Flake8 (fallback)
    if command -v flake8 &> /dev/null && ! command -v ruff &> /dev/null; then
        run_check "Flake8" "flake8 --max-line-length=120" || true
    fi

    # mypy
    if command -v mypy &> /dev/null; then
        run_check "mypy" "mypy --ignore-missing-imports ." || true
    else
        skip_check "mypy"
    fi

    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Go
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ -f "go.mod" ]]; then
    log_info "🔷 Go projesi algılandı"

    if command -v go &> /dev/null; then
        run_check "Go build" "go build ./..." || true
        run_check "Go test" "go test ./..." || true
        run_check "Go vet" "go vet ./..." || true
    else
        log_error "Go kurulu değil"
        ((FAILED++))
    fi

    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rust
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [[ -f "Cargo.toml" ]]; then
    log_info "🦀 Rust projesi algılandı"

    if command -v cargo &> /dev/null; then
        run_check "Cargo check" "cargo check" || true
        run_check "Cargo test" "cargo test" || true
        run_check "Cargo clippy" "cargo clippy -- -D warnings" || true
    else
        log_error "Cargo kurulu değil"
        ((FAILED++))
    fi

    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Shell scripts
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ls scripts/*.sh 1> /dev/null 2>&1; then
    log_info "🐚 Shell scriptleri algılandı"

    if command -v shellcheck &> /dev/null; then
        run_check "ShellCheck" "shellcheck scripts/*.sh" || true
    else
        skip_check "ShellCheck"
    fi

    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Markdown lint
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if command -v markdownlint &> /dev/null; then
    if ls *.md docs/*.md 1> /dev/null 2>&1; then
        run_check "Markdown lint" "markdownlint '**/*.md' --ignore node_modules --ignore vendor" || true
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Sonuç
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║              📊 SONUÇ                      ║"
echo "╠════════════════════════════════════════════╣"
printf "║  %-10s %3d                            ║\n" "✓ Başarılı:" "$PASSED"
printf "║  %-10s %3d                            ║\n" "✗ Başarısız:" "$FAILED"
printf "║  %-10s %3d                            ║\n" "! Atlanan:" "$SKIPPED"
echo "╚════════════════════════════════════════════╝"
echo ""

if [[ $FAILED -gt 0 ]]; then
    log_error "Doğrulama BAŞARISIZ ($FAILED hata)"
    exit 1
else
    log_success "Doğrulama BAŞARILI"
    exit 0
fi
