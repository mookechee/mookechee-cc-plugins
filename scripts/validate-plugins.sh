#!/bin/bash

# Claude Code Plugin Validator
# 验证插件格式是否符合 Claude Code 官方标准

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGINS_DIR="$ROOT_DIR/plugins"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERRORS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_info() {
    echo -e "[INFO] $1"
}

# 验证 JSON 文件语法
validate_json_syntax() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        log_error "$file: JSON 语法错误"
        return 1
    fi
    return 0
}

# 验证 plugin.json
validate_plugin_json() {
    local plugin_dir="$1"
    local plugin_json="$plugin_dir/.claude-plugin/plugin.json"
    local plugin_name=$(basename "$plugin_dir")

    log_info "验证插件: $plugin_name"

    # 检查 plugin.json 是否存在
    if [[ ! -f "$plugin_json" ]]; then
        log_error "$plugin_name: 缺少 .claude-plugin/plugin.json"
        return 1
    fi

    # 验证 JSON 语法
    if ! validate_json_syntax "$plugin_json"; then
        return 1
    fi

    # 验证必需字段
    local name=$(jq -r '.name // empty' "$plugin_json")
    local version=$(jq -r '.version // empty' "$plugin_json")
    local description=$(jq -r '.description // empty' "$plugin_json")
    local author_name=$(jq -r '.author.name // empty' "$plugin_json")

    if [[ -z "$name" ]]; then
        log_error "$plugin_name: plugin.json 缺少 'name' 字段"
    fi

    if [[ -z "$version" ]]; then
        log_error "$plugin_name: plugin.json 缺少 'version' 字段"
    elif ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        log_warning "$plugin_name: version '$version' 不符合语义化版本规范 (x.y.z)"
    fi

    if [[ -z "$description" ]]; then
        log_error "$plugin_name: plugin.json 缺少 'description' 字段"
    fi

    if [[ -z "$author_name" ]]; then
        log_warning "$plugin_name: plugin.json 缺少 'author.name' 字段"
    fi

    # 验证引用的目录/文件是否存在
    local commands=$(jq -r '.commands // empty' "$plugin_json")
    local skills=$(jq -r '.skills // empty' "$plugin_json")
    local hooks=$(jq -r '.hooks // empty' "$plugin_json")

    if [[ -n "$commands" ]]; then
        local commands_path="$plugin_dir/$commands"
        commands_path="${commands_path%/}"  # 移除末尾斜杠
        if [[ ! -d "$commands_path" ]]; then
            log_error "$plugin_name: commands 目录不存在: $commands"
        fi
    fi

    if [[ -n "$skills" ]]; then
        local skills_path="$plugin_dir/$skills"
        skills_path="${skills_path%/}"
        if [[ ! -d "$skills_path" ]]; then
            log_error "$plugin_name: skills 目录不存在: $skills"
        fi
    fi

    if [[ -n "$hooks" ]]; then
        local hooks_path="$plugin_dir/$hooks"
        if [[ ! -f "$hooks_path" ]]; then
            log_error "$plugin_name: hooks 文件不存在: $hooks"
        else
            validate_hooks_json "$hooks_path" "$plugin_name"
        fi
    fi

    log_success "$plugin_name: plugin.json 验证完成"
}

# 验证 hooks.json
validate_hooks_json() {
    local hooks_file="$1"
    local plugin_name="$2"

    # 验证 JSON 语法
    if ! validate_json_syntax "$hooks_file"; then
        return 1
    fi

    # 检查 hooks 字段类型（必须是对象，不能是数组）
    local hooks_type=$(jq -r '.hooks | type' "$hooks_file")
    if [[ "$hooks_type" == "array" ]]; then
        log_error "$plugin_name: hooks.json 中 'hooks' 字段必须是对象 {}，不能是数组 []"
        return 1
    elif [[ "$hooks_type" != "object" ]]; then
        log_error "$plugin_name: hooks.json 中 'hooks' 字段类型错误，期望对象，实际为 $hooks_type"
        return 1
    fi

    # 验证 hooks 中的事件类型
    local valid_events=("SessionStart" "SessionEnd" "PreToolUse" "PostToolUse" "Stop" "Notification")
    local hook_events=$(jq -r '.hooks | keys[]' "$hooks_file" 2>/dev/null || echo "")

    for event in $hook_events; do
        local found=0
        for valid in "${valid_events[@]}"; do
            if [[ "$event" == "$valid" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            log_warning "$plugin_name: hooks.json 中存在未知事件类型: $event"
        fi
    done

    log_success "$plugin_name: hooks.json 验证完成"
}

# 检查文档质量
validate_documentation() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local has_error=0

    # 检查乱码字符 (UTF-8 replacement character U+FFFD)
    local garbled_files
    garbled_files=$(grep -rln $'\xEF\xBF\xBD' "$plugin_dir" --include="*.md" 2>/dev/null || true)

    if [[ -n "$garbled_files" ]]; then
        for file in $garbled_files; do
            log_error "$plugin_name: 发现乱码字符: $file"
            grep -n $'\xEF\xBF\xBD' "$file" | head -5
        done
        has_error=1
    fi

    if [[ $has_error -eq 0 ]]; then
        log_success "$plugin_name: 文档质量检查通过"
    fi
}

# 验证 commands 目录
validate_commands() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local commands_dir="$plugin_dir/commands"

    if [[ ! -d "$commands_dir" ]]; then
        return 0
    fi

    local md_files=$(find "$commands_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null)
    if [[ -z "$md_files" ]]; then
        log_warning "$plugin_name: commands 目录存在但没有 .md 文件"
    fi
}

# 验证 skills 目录
validate_skills() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")
    local skills_dir="$plugin_dir/skills"

    if [[ ! -d "$skills_dir" ]]; then
        return 0
    fi

    # 遍历每个 skill 子目录
    for skill_subdir in "$skills_dir"/*/; do
        if [[ ! -d "$skill_subdir" ]]; then
            continue
        fi

        local skill_name=$(basename "$skill_subdir")
        local skill_md="$skill_subdir/SKILL.md"

        if [[ ! -f "$skill_md" ]]; then
            log_error "$plugin_name: skill '$skill_name' 缺少 SKILL.md"
        fi
    done
}

# 主函数
main() {
    echo "=========================================="
    echo "Claude Code Plugin Validator"
    echo "=========================================="
    echo ""

    if [[ ! -d "$PLUGINS_DIR" ]]; then
        log_error "plugins 目录不存在: $PLUGINS_DIR"
        exit 1
    fi

    # 遍历所有插件
    for plugin_dir in "$PLUGINS_DIR"/*/; do
        if [[ ! -d "$plugin_dir" ]]; then
            continue
        fi

        echo ""
        validate_plugin_json "$plugin_dir"
        validate_commands "$plugin_dir"
        validate_skills "$plugin_dir"
        validate_documentation "$plugin_dir"
        echo ""
    done

    echo "=========================================="
    echo "验证结果"
    echo "=========================================="
    echo "错误: $ERRORS"
    echo "警告: $WARNINGS"

    if [[ $ERRORS -gt 0 ]]; then
        echo ""
        log_error "验证失败，请修复上述错误"
        exit 1
    fi

    echo ""
    log_success "所有插件验证通过"
    exit 0
}

main "$@"
