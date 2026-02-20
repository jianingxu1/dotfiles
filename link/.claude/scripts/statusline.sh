#!/bin/bash

# Claude Code Status Line Script
# Inspired by robbyrussell Oh My Zsh theme

# ============================================================================
# CONFIGURATION
# ============================================================================

# Configuration file path (can be overridden via environment variable)
CONFIG_FILE="${CONFIG_FILE:-$HOME/.claude/statusline.config}"

# Default configuration values
# These can be overridden by the config file
TOKEN_DISPLAY="separate"  # "separate" or "combined"
THRESHOLD_YELLOW=40
THRESHOLD_ORANGE=50
THRESHOLD_RED=70
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_ORANGE='\033[38;5;208m'
COLOR_RED='\033[31m'
COLOR_COST='\033[38;2;215;176;135m'  # Bright gold for cost display

# Map color name to ANSI code
color_name_to_code() {
    local color_name="$1"
    # Convert to lowercase for case-insensitive matching
    color_name=$(echo "$color_name" | tr '[:upper:]' '[:lower:]')

    case "$color_name" in
        green)   echo "32" ;;
        yellow)  echo "33" ;;
        orange)  echo "38;5;208" ;;
        red)     echo "31" ;;
        blue)    echo "34" ;;
        cyan)    echo "36" ;;
        magenta|purple) echo "35" ;;
        white)   echo "37" ;;
        pink)    echo "38;5;213" ;;
        bright-green)  echo "92" ;;
        bright-yellow) echo "93" ;;
        bright-red)    echo "91" ;;
        bright-blue)   echo "94" ;;
        bright-cyan)   echo "96" ;;
        bright-magenta) echo "95" ;;
        *)       echo "" ;; # Unknown color
    esac
}

# Load configuration file if it exists
# Security: Source config file safely with validation
if [ -f "$CONFIG_FILE" ]; then
    # Security: Check that config file is not a symlink (TOCTOU protection)
    if [ -L "$CONFIG_FILE" ]; then
        # Skip loading config if it's a symlink to prevent TOCTOU attacks
        :
    else
        # Security: Validate config file permissions (owned by user and readable)
        # Only accept 600 (user read/write) or 400 (user read-only)
        file_perms=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CONFIG_FILE" 2>/dev/null)
        # Check that file_perms was successfully retrieved and has valid permissions
        if [ -n "$file_perms" ] && [ -O "$CONFIG_FILE" ] && [ -r "$CONFIG_FILE" ] && [[ "$file_perms" =~ ^[64]00$ ]]; then
        # Create a temporary file to validate config before sourcing
        # This prevents arbitrary code execution from malicious config
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

            # Security: Only allow specific variable assignments
            # Pattern: VARIABLE_NAME=value (where VARIABLE_NAME matches our known configs)
            if [[ "$line" =~ ^[[:space:]]*(TOKEN_DISPLAY|THRESHOLD_YELLOW|THRESHOLD_ORANGE|THRESHOLD_RED|COLOR_GREEN|COLOR_YELLOW|COLOR_ORANGE|COLOR_RED)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                var_value="${BASH_REMATCH[2]}"

                # Remove leading/trailing whitespace and quotes from value
                var_value=$(echo "$var_value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e "s/^['\"]//g" -e "s/['\"]$//g")

                # Validate based on variable type
                # Security: Use explicit assignment instead of declare to prevent injection
                case "$var_name" in
                    TOKEN_DISPLAY)
                        # Only allow "separate" or "combined"
                        if [[ "$var_value" == "separate" || "$var_value" == "combined" ]]; then
                            TOKEN_DISPLAY="$var_value"
                        fi
                        ;;
                    THRESHOLD_YELLOW)
                        # Validate numeric thresholds (0-100)
                        if [[ "$var_value" =~ ^[0-9]+$ ]] && [ "$var_value" -ge 0 ] && [ "$var_value" -le 100 ]; then
                            THRESHOLD_YELLOW="$var_value"
                        fi
                        ;;
                    THRESHOLD_ORANGE)
                        # Validate numeric thresholds (0-100)
                        if [[ "$var_value" =~ ^[0-9]+$ ]] && [ "$var_value" -ge 0 ] && [ "$var_value" -le 100 ]; then
                            THRESHOLD_ORANGE="$var_value"
                        fi
                        ;;
                    THRESHOLD_RED)
                        # Validate numeric thresholds (0-100)
                        if [[ "$var_value" =~ ^[0-9]+$ ]] && [ "$var_value" -ge 0 ] && [ "$var_value" -le 100 ]; then
                            THRESHOLD_RED="$var_value"
                        fi
                        ;;
                    COLOR_GREEN)
                        # Validate color codes - allow color names, ANSI escape sequences, or numeric codes
                        _color_code=$(color_name_to_code "$var_value")
                        if [ -n "$_color_code" ]; then
                            # Color name found - convert to ANSI escape
                            COLOR_GREEN="\\033[${_color_code}m"
                        elif [[ "$var_value" =~ ^\\(033|e)\[[0-9\;]+m$ ]]; then
                            # Already an ANSI escape sequence
                            COLOR_GREEN="$var_value"
                        elif [[ "$var_value" =~ ^[0-9\;]+$ ]]; then
                            # Numeric code - wrap in ANSI escape format
                            COLOR_GREEN="\\033[${var_value}m"
                        fi
                        ;;
                    COLOR_YELLOW)
                        # Validate color codes - allow color names, ANSI escape sequences, or numeric codes
                        _color_code=$(color_name_to_code "$var_value")
                        if [ -n "$_color_code" ]; then
                            # Color name found - convert to ANSI escape
                            COLOR_YELLOW="\\033[${_color_code}m"
                        elif [[ "$var_value" =~ ^\\(033|e)\[[0-9\;]+m$ ]]; then
                            # Already an ANSI escape sequence
                            COLOR_YELLOW="$var_value"
                        elif [[ "$var_value" =~ ^[0-9\;]+$ ]]; then
                            # Numeric code - wrap in ANSI escape format
                            COLOR_YELLOW="\\033[${var_value}m"
                        fi
                        ;;
                    COLOR_ORANGE)
                        # Validate color codes - allow color names, ANSI escape sequences, or numeric codes
                        _color_code=$(color_name_to_code "$var_value")
                        if [ -n "$_color_code" ]; then
                            # Color name found - convert to ANSI escape
                            COLOR_ORANGE="\\033[${_color_code}m"
                        elif [[ "$var_value" =~ ^\\(033|e)\[[0-9\;]+m$ ]]; then
                            # Already an ANSI escape sequence
                            COLOR_ORANGE="$var_value"
                        elif [[ "$var_value" =~ ^[0-9\;]+$ ]]; then
                            # Numeric code - wrap in ANSI escape format
                            COLOR_ORANGE="\\033[${var_value}m"
                        fi
                        ;;
                    COLOR_RED)
                        # Validate color codes - allow color names, ANSI escape sequences, or numeric codes
                        _color_code=$(color_name_to_code "$var_value")
                        if [ -n "$_color_code" ]; then
                            # Color name found - convert to ANSI escape
                            COLOR_RED="\\033[${_color_code}m"
                        elif [[ "$var_value" =~ ^\\(033|e)\[[0-9\;]+m$ ]]; then
                            # Already an ANSI escape sequence
                            COLOR_RED="$var_value"
                        elif [[ "$var_value" =~ ^[0-9\;]+$ ]]; then
                            # Numeric code - wrap in ANSI escape format
                            COLOR_RED="\\033[${var_value}m"
                        fi
                        ;;
                esac
            fi
        done < "$CONFIG_FILE"
        fi
    fi
fi

# Security: Validate threshold ordering to prevent logic errors
# Reset to defaults if thresholds are not in ascending order (yellow <= orange <= red)
if [ "$THRESHOLD_YELLOW" -gt "$THRESHOLD_ORANGE" ] || [ "$THRESHOLD_ORANGE" -gt "$THRESHOLD_RED" ]; then
    # Reset to safe defaults if invalid
    THRESHOLD_YELLOW=40
    THRESHOLD_ORANGE=50
    THRESHOLD_RED=70
fi

# ============================================================================
# CONSTANTS
# ============================================================================

# Security: Maximum input size (1MB)
readonly MAX_INPUT_SIZE=1048576

# Security: Maximum value for numeric validation (prevents overflow)
readonly MAX_NUMBER_VALUE=9999999999

# String length limits
readonly MAX_STRING_LENGTH=1024
readonly MAX_USERNAME_LENGTH=64
readonly MAX_HOSTNAME_LENGTH=64
readonly MAX_DIR_LENGTH=256
readonly MAX_BRANCH_LENGTH=128

# Token formatting threshold (display as K when >= 1000)
readonly TOKEN_FORMAT_THRESHOLD=1000

# ============================================================================
# SECURITY FUNCTIONS
# ============================================================================

# Security: Validate that a value is a non-negative integer
validate_number() {
    local value="$1"
    local max="${2:-$MAX_NUMBER_VALUE}"  # Default max to prevent overflow

    # Check if value matches only digits
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    # Check if value is within acceptable range
    if [ "$value" -gt "$max" ]; then
        return 1
    fi

    return 0
}

# Security: Sanitize string to remove control characters and ANSI escape sequences
sanitize_string() {
    local input="$1"
    local max_length="${2:-$MAX_STRING_LENGTH}"

    # Remove all control characters (0x00-0x1F, 0x7F) except newline/tab
    # Also remove ANSI escape sequences (CSI sequences, OSC sequences, etc.)
    local sanitized
    sanitized=$(printf '%s' "$input" | \
        tr -d '\000-\010\013\014\016-\037\177' | \
        sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
            -e 's/\x1b\][0-9]*;[^\x07]*\x07//g' \
            -e 's/\x1b[()][AB012]//g' \
            -e 's/\x1b[=>]//g' | \
        head -c "$max_length")

    printf '%s' "$sanitized"
}

# Security: Validate directory path (prevent path traversal)
# Note: Uses 'realpath' to canonicalize paths. Tries -m flag first (GNU) which
# allows non-existent paths, falls back to regular realpath (BSD/macOS) if -m fails.
validate_directory() {
    local dir="$1"

    # Check if path is empty
    if [ -z "$dir" ]; then
        return 1
    fi

    # Resolve to absolute path to prevent traversal attacks
    local resolved
    # Try GNU realpath with -m flag first (allows non-existent paths)
    resolved=$(realpath -m "$dir" 2>/dev/null)

    # If that failed (BSD/macOS), try without -m (requires path to exist)
    if [ -z "$resolved" ]; then
        resolved=$(realpath "$dir" 2>/dev/null)
    fi

    # If still empty, validation failed
    if [ -z "$resolved" ]; then
        return 1
    fi

    # Security: Additional check for null bytes using grep (more reliable than pattern matching)
    if printf '%s' "$resolved" | tr -d '\0' | diff -q - <(printf '%s' "$resolved") > /dev/null 2>&1; then
        # No null bytes found (strings are identical after removing null bytes)
        :
    else
        # Null bytes detected
        return 1
    fi

    printf '%s' "$resolved"
}

# Security: Validate JSON structure before processing
validate_json() {
    local input="$1"

    # Check if input is valid JSON
    if ! echo "$input" | jq empty 2>/dev/null; then
        return 1
    fi

    return 0
}

# Security: Safe extraction of JSON string value with validation
extract_json_string() {
    local input="$1"
    local path="$2"
    local default="${3:-}"

    local value
    value=$(echo "$input" | jq -r "$path" 2>/dev/null)

    # Return default if extraction failed or returned null
    if [ $? -ne 0 ] || [ "$value" = "null" ] || [ -z "$value" ]; then
        printf '%s' "$default"
        return
    fi

    # Sanitize the extracted value
    sanitize_string "$value"
}

# Security: Safe extraction of JSON number value with validation
# Note: Only integer values are accepted. Floating-point numbers will be rejected
# and will fall back to the default value.
extract_json_number() {
    local input="$1"
    local path="$2"
    local default="${3:-0}"

    local value
    value=$(echo "$input" | jq -r "$path" 2>/dev/null)

    # Return default if extraction failed or returned null
    if [ $? -ne 0 ] || [ "$value" = "null" ]; then
        echo "$default"
        return
    fi

    # Validate the number
    if validate_number "$value"; then
        echo "$value"
    else
        echo "$default"
    fi
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Helper function to format numbers as K (thousands)
# Security: Using pure bash arithmetic instead of bc
format_tokens() {
    local num="$1"

    # Validate input is a number
    if ! validate_number "$num"; then
        echo "0"
        return
    fi

    if [ "$num" -ge "$TOKEN_FORMAT_THRESHOLD" ]; then
        # Convert to K with one decimal place using bash arithmetic
        local thousands=$((num / 1000))
        local remainder=$((num % 1000))
        local decimal=$((remainder / 100))
        printf "%d.%dK" "$thousands" "$decimal"
    else
        echo "$num"
    fi
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Security: Read input with size limit
input=$(head -c "$MAX_INPUT_SIZE")

# Security: Validate JSON structure
if ! validate_json "$input"; then
    # Fallback to safe defaults if JSON is invalid
    printf '\033[31mInvalid JSON input\033[0m'
    exit 1
fi

# Security: Extract and sanitize values from JSON
cwd=$(extract_json_string "$input" '.workspace.current_dir' "$HOME")
model=$(extract_json_string "$input" '.model.display_name' 'unknown')
output_style=$(extract_json_string "$input" '.output_style.name // "default"' 'default')

# Security: Validate and sanitize directory path
if ! cwd=$(validate_directory "$cwd"); then
    cwd="$HOME"
fi

# Get username and hostname with sanitization
user=$(sanitize_string "$(whoami)" "$MAX_USERNAME_LENGTH")
host=$(sanitize_string "$(hostname -s 2>/dev/null || echo 'localhost')" "$MAX_HOSTNAME_LENGTH")

# Get directory (basename of current directory)
# Security: Using parameter expansion instead of basename to avoid command injection
if [ "$cwd" = "$HOME" ]; then
    dir="~"
else
    # Safe basename using parameter expansion
    dir="${cwd##*/}"
    # Sanitize in case directory name contains control characters
    dir=$(sanitize_string "$dir" "$MAX_DIR_LENGTH")
    # Fallback if empty (root directory)
    if [ -z "$dir" ]; then
        dir="/"
    fi
fi

# Get git branch if in a git repo
git_branch=""
if command -v git &> /dev/null; then
    # Security: Validate directory before passing to git
    if [ -d "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
        # Disable git color output to prevent ANSI injection
        branch=$(git -c color.ui=never -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -c color.ui=never -C "$cwd" rev-parse --short HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            # Security: Sanitize branch name to prevent ANSI injection and strip any remaining color codes
            branch=$(sanitize_string "$branch" "$MAX_BRANCH_LENGTH")
            git_branch=" (${branch})"
        fi
    fi
fi

# ============================================================================
# TOKEN CALCULATION AND DISPLAY
# ============================================================================

# Extract context usage percentage and cost from JSON
token_info=""
cost_info=""

# Security: Extract used_percentage directly (it's already a percentage value)
used_pct=$(extract_json_number "$input" '.context_window.used_percentage' 0)

# Security: Extract total cost and round to 2 decimal places
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' 2>/dev/null)
if [ $? -ne 0 ] || [ "$total_cost" = "null" ]; then
    total_cost="0.00"
else
    # Round to 2 decimal places using printf
    total_cost=$(printf "%.2f" "$total_cost" 2>/dev/null || echo "0.00")
fi

# Build cost info string: "$0.92" with bright gold color
cost_info=$(printf ' | %b$%s\033[0m' "$COLOR_COST" "$total_cost")

# Check if we have valid percentage data
if [ "$used_pct" -ne 0 ]; then
    # Clamp percentage to valid range (0-100)
    if [ "$used_pct" -gt 100 ]; then
        used_pct=100
    fi

    # Choose color based on percentage thresholds
    # Green: < THRESHOLD_YELLOW, Yellow: >= THRESHOLD_YELLOW,
    # Orange: >= THRESHOLD_ORANGE, Red: >= THRESHOLD_RED
    pct_color="$COLOR_GREEN"  # Green by default
    if [ "$used_pct" -ge "$THRESHOLD_RED" ]; then
        pct_color="$COLOR_RED"
    elif [ "$used_pct" -ge "$THRESHOLD_ORANGE" ]; then
        pct_color="$COLOR_ORANGE"
    elif [ "$used_pct" -ge "$THRESHOLD_YELLOW" ]; then
        pct_color="$COLOR_YELLOW"
    fi

    # Build token info string: "24% context used"
    # Security: All variables are validated/sanitized, safe to use in printf
    token_info=$(printf ' \033[90m│\033[0m %b%s%% context used\033[0m' \
        "$pct_color" "$used_pct")
fi

# ============================================================================
# OUTPUT FORMATTING
# ============================================================================

# Build the status line with colors
# Format: user@host:dir (branch) │ % context used | $cost │ Model
# Security: All variables are sanitized, safe to output
printf '\033[32m%s@%s\033[0m:\033[34m%s\033[0m%s%s%s \033[90m│\033[0m \033[36m%s\033[0m' \
    "$user" "$host" "$dir" "$git_branch" "$token_info" "$cost_info" "$model"
