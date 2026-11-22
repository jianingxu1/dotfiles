"""Run the real plugin manager against local stand-ins, without network access."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


class PluginTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-plugins-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        manager = self.root / "link" / ".zgenom"
        shutil.copytree(
            REPO / "link/.zgenom", manager,
            ignore=shutil.ignore_patterns(".git", "sources", "*.zwc", ".last_autoupdate_log"),
        )
        for filename in ["source/20_plugins.sh", "conf/zsh/fzf.zsh"]:
            destination = self.root / filename
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO / filename, destination)
        self.plugins = self.root / "plugins"
        self.expected = ["completions", "framework", "fzf", "fzf-tab", "alias-tips",
                         "zoxide", "dot-up", "p10k", "autoupdate", "autosuggestions", "highlighting"]
        fixtures = [
            ("zsh-users/zsh-completions", "plugin.zsh", "completions"),
            ("ohmyzsh/ohmyzsh", "oh-my-zsh.sh", "framework"),
            ("aloxaf/fzf-tab", "plugin.zsh", "fzf-tab"),
            ("djui/alias-tips", "plugin.zsh", "alias-tips"),
            ("ajeetdsouza/zoxide", "plugin.zsh", "zoxide"),
            ("toku-sa-n/zsh-dot-up", "plugin.zsh", "dot-up"),
            ("romkatv/powerlevel10k", "powerlevel10k.zsh-theme", "p10k"),
            ("unixorn/autoupdate-zgenom", "plugin.zsh", "autoupdate"),
            ("zsh-users/zsh-autosuggestions", "plugin.zsh", "autosuggestions"),
            ("zsh-users/zsh-syntax-highlighting", "plugin.zsh", "highlighting"),
        ]
        for repository, filename, marker in fixtures:
            destination = self.plugins / repository / "___" / filename
            destination.parent.mkdir(parents=True, exist_ok=True)
            content = f'startup_trace+=({marker})\n'
            if marker == "framework":
                content += 'autoload -Uz compinit; compinit -i -d "$ZGEN_DIR/test-zcompdump"\n'
            elif marker == "fzf-tab":
                content += '(( ${+_comps} )) || exit 99\n'
            destination.write_text(content)
        binary = self.root / "bin" / "fzf"
        binary.parent.mkdir()
        binary.write_text("#!/bin/sh\nprintf '%s\\n' 'startup_trace+=(fzf)'\n")
        binary.chmod(0o755)
        self.environment = dict(os.environ, DOTFILES=str(self.root),
                                ZGEN_DIR=str(self.plugins),
                                ZGEN_INIT=str(self.plugins / "init.zsh"))

    def run_shell(self):
        result = subprocess.run(
            ["zsh", "-f", "-c", '''
PATH="$DOTFILES/bin:$PATH"
typeset -a startup_trace
source "$DOTFILES/source/20_plugins.sh" || exit 1
# Reloading the module must not initialize integrations a second time.
source "$DOTFILES/source/20_plugins.sh" || exit 1
print -l -- $startup_trace
'''], env=self.environment, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.splitlines()

    def test_fresh_and_cached_startup_keep_dependency_order(self):
        self.assertEqual(self.run_shell(), self.expected)
        self.assertEqual(self.run_shell(), self.expected)

    def test_old_cache_is_rebuilt(self):
        self.plugins.mkdir(exist_ok=True)
        (self.plugins / "init.zsh").write_text('startup_trace+=(obsolete)\n')
        self.assertEqual(self.run_shell(), self.expected)

    def test_configuration_changes_invalidate_cache(self):
        self.assertEqual(self.run_shell(), self.expected)
        config = self.root / "source/20_plugins.sh"
        config.write_text(config.read_text().replace(
            "  zgenom save", "  zgenom load local/new-plugin || return 1\n  zgenom save"))
        future = config.stat().st_mtime + 2
        os.utime(config, (future, future))
        fixture = self.plugins / "local/new-plugin/___/plugin.zsh"
        fixture.parent.mkdir(parents=True)
        fixture.write_text('startup_trace+=(new-plugin)\n')
        trace = self.run_shell()
        self.assertEqual(trace[-len(self.expected) - 1:], self.expected + ["new-plugin"])
        self.assertEqual(self.run_shell(), self.expected + ["new-plugin"])


if __name__ == "__main__":
    unittest.main()
