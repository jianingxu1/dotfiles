"""Exercise installer failures in temporary directories, without running setup."""
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
INSTALLER = (REPO / "bin/dotfiles").read_text()
FUNCTIONS = INSTALLER.split("# Initialize.\ninit_file=", 1)[1].split(
    "# Enough with the functions", 1
)[0]
FUNCTIONS = "init_file=" + FUNCTIONS


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "copy").mkdir()
        (self.root / "backups").mkdir()
        self.destination = self.root / "destination"
        self.destination.write_text("original")
        (self.root / "copy" / "sample").write_text("replacement")

    def run_shell(self, body):
        setup = '''
DOTFILES="$1"
backup_dir="$DOTFILES/backups"
e_header() { :; }
e_success() { :; }
e_error() { :; }
e_arrow() { :; }
shopt -s nullglob dotglob
'''
        actions = '''
copy_dest() { echo "$DOTFILES/destination"; }
copy_test() { :; }
copy_do() { cp "$2" "$DOTFILES/destination"; }
'''
        return subprocess.run(
            ["bash", "-c", setup + FUNCTIONS + actions + body, "test", str(self.root)],
            text=True, capture_output=True,
        )

    def test_failed_backup_does_not_replace_destination(self):
        result = self.run_shell("mv() { return 1; }; do_stuff copy")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.destination.read_text(), "original")

    def test_failed_backup_directory_does_not_replace_destination(self):
        result = self.run_shell("mkdir() { return 1; }; do_stuff copy")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.destination.read_text(), "original")

    def test_failed_action_is_reported(self):
        result = self.run_shell("copy_do() { return 1; }; do_stuff copy")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.root / "backups" / "destination").read_text(), "original")

    def test_successful_backup_and_copy(self):
        result = self.run_shell("do_stuff copy")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.destination.read_text(), "replacement")
        self.assertEqual((self.root / "backups" / "destination").read_text(), "original")

    def test_empty_directory_succeeds(self):
        (self.root / "copy" / "sample").unlink()
        self.assertEqual(self.run_shell("do_stuff copy").returncode, 0)

    def test_failed_file_selection_is_reported(self):
        result = self.run_shell("copy_files() { return 1; }; do_stuff copy")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.destination.read_text(), "original")

    def test_config_link_creates_missing_parent(self):
        source = self.root / "config" / "nvim"
        source.mkdir(parents=True)
        result = self.run_shell('''
config_dest() { echo "$DOTFILES/user-config/$1"; }
do_stuff config
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        destination = self.root / "user-config" / "nvim"
        self.assertTrue(destination.is_symlink())
        self.assertEqual(destination.resolve(), source.resolve())
        self.assertEqual(self.run_shell('''
config_dest() { echo "$DOTFILES/user-config/$1"; }
do_stuff config
''').returncode, 0)

    def test_failed_pull_stops_before_copying(self):
        main = INSTALLER.split('# Initialize.\nif [[ ! -d $DOTFILES ]]', 1)[1]
        main = 'if [[ ! -d $DOTFILES ]]' + main
        result = self.run_shell('''
git() {
  case "$1" in
    rev-parse) echo unchanged ;;
    pull) return 1 ;;
    *) return 0 ;;
  esac
}
do_stuff() { echo "unexpected action"; }
''' + main)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected action", result.stdout)

    def test_bootstrap_uses_personal_repository_over_https(self):
        main = INSTALLER.split('# Initialize.\nif [[ ! -d $DOTFILES ]]', 1)[1]
        result = self.run_shell('''
unset DOTFILES_GH_USER DOTFILES_GH_BRANCH
DOTFILES="$DOTFILES/not-cloned"
git() { printf '%s\n' "$@"; return 1; }
''' + 'if [[ ! -d $DOTFILES ]]' + main)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("https://github.com/jianingxu1/dotfiles.git", result.stdout)
        self.assertIn("main", result.stdout.splitlines())
        self.assertNotIn("All done!", result.stdout)

    def run_homebrew_setup(self, failure):
        scripts = "\n".join(
            (REPO / "init" / name).read_text()
            for name in ("20_osx_homebrew.sh", "30_osx_homebrew_recipes.sh")
        )
        return self.run_shell('''
is_osx() { return 0; }
type() { echo brew; }
brew() {
  echo "brew $*"
  [[ "$1" != "''' + failure + '''" ]]
}
''' + 'run_init() {\n' + scripts + '\n}; run_init')

    def test_homebrew_doctor_warnings_do_not_block_packages(self):
        result = self.run_homebrew_setup("doctor")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("brew update", result.stdout)
        self.assertIn("brew bundle install --no-upgrade", result.stdout)

    def test_homebrew_update_failure_blocks_packages(self):
        result = self.run_homebrew_setup("update")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("brew bundle", result.stdout)

    def test_failed_homebrew_command_stops_later_commands(self):
        script = (REPO / "init/30_osx_homebrew_recipes.sh").read_text()
        result = self.run_shell('''
is_osx() { return 0; }
type() { echo brew; }
brew() { echo "brew $*"; return 1; }
''' + 'run_init() {\n' + script + '\n}; run_init')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("brew cleanup", result.stdout)
        self.assertEqual(len(result.stdout.splitlines()), 1)

    def test_homebrew_setup_does_not_upgrade_or_cleanup(self):
        script = (REPO / "init/30_osx_homebrew_recipes.sh").read_text()
        result = self.run_shell('''
is_osx() { return 0; }
type() { echo brew; }
brew() {
  case "$1" in upgrade|cleanup) return 99 ;; esac
  echo "$*"
}
''' + 'run_init() {\n' + script + '\n}; run_init')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--no-upgrade", result.stdout)
        self.assertNotIn("brew cleanup", result.stdout)

    def test_other_os_is_skipped(self):
        script = (REPO / "init/30_osx_homebrew_recipes.sh").read_text()
        result = self.run_shell('is_osx() { return 1; }; brew() { exit 99; };\nrun_init() {\n' + script + '\n}; run_init')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
