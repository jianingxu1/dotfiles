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

    def test_other_os_is_skipped(self):
        script = (REPO / "init/30_osx_homebrew_recipes.sh").read_text()
        result = self.run_shell('is_osx() { return 1; }; brew() { exit 99; };\nrun_init() {\n' + script + '\n}; run_init')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
